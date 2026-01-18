-- resmon.nvim - one-row resource monitor in the TABLINE (no overlap)
-- Put at: ~/.config/nvim/lua/resmon.lua
--
-- Commands:
--   :ResMonToggle
--   :ResMonOpen
--   :ResMonClose
--
-- If you keep it at lua/config/resmon.lua, set setup({ module = "config.resmon" })
-- and require("config.resmon").setup(...)

local M = {}

local uv = vim.uv or vim.loop

local defaults = {
  enabled = true,
  ui = {
    mode = "tabline", -- "tabline" (recommended). "float" not provided in this build.
    center = true,
  },

  module = "resmon", -- module path used to set vim.o.tabline = "%!v:lua.require'<module>'.tabline()"

  interval_ms = 1000,
  disk_interval_ms = 5000,
  gpu_interval_ms = 3000,

  icons = true,
  show = { cpu = true, ram = true, disk = true, net = true, gpu = true },

  highlight = "ResMonBar",

  symbols = {
    cpu  = "",
    ram  = "󰍛",
    disk = "󰋊",
    dn   = "󰛴",
    up   = "󰛶",
    gpu  = "󰢮",
    sep  = "      ",
  },
}

local state = {
  cfg = nil,
  os = nil,      -- "windows" | "linux" | "mac"
  ps = nil,      -- "pwsh" | "powershell"
  timer = nil,

  -- previous tabline options to restore
  prev_tabline = nil,
  prev_showtabline = nil,

  metrics = {
    cpu = nil,
    mem_used = nil,
    mem_total = nil,
    disk_used = nil,
    disk_total = nil,
    rx_rate = nil,
    tx_rate = nil,
    gpu = nil, -- {util, mem_used_mib, mem_total_mib, temp_c}
  },

  last_ts = nil,
  prev_rx = nil,
  prev_tx = nil,

  prev_linux_total = nil,
  prev_linux_idle = nil,
  prev_mac = nil, -- {total, idle}

  last_disk_at = 0,
  last_gpu_at = 0,

  pending = { base = false, disk = false, gpu = false },

  -- rendered text cached for tabline()
  tabline_text = "",
}

-- ---------------- utils ----------------

local function merge(a, b)
  local out = vim.deepcopy(a)
  for k, v in pairs(b or {}) do
    if type(v) == "table" and type(out[k]) == "table" then
      out[k] = merge(out[k], v)
    else
      out[k] = v
    end
  end
  return out
end

local function now_ns()
  return uv.hrtime()
end

local function ns_to_s(ns)
  return ns / 1e9
end

local function exe_exists(name)
  return vim.fn.executable(name) == 1
end

local function fmt_rate(bps)
  if not bps then return nil end
  local units = { "B/s", "KB/s", "MB/s", "GB/s" }
  local u, v = 1, tonumber(bps) or 0
  while v >= 1024 and u < #units do
    v = v / 1024
    u = u + 1
  end
  return string.format("%.1f%s", v, units[u])
end

local function bytes_to_gib(b)
  return (tonumber(b) or 0) / 1024 / 1024 / 1024
end

local function ensure_highlight()
  if vim.fn.hlexists(state.cfg.highlight) == 0 then
    vim.api.nvim_set_hl(0, state.cfg.highlight, { link = "TabLine" })
  end
end

-- SAFE process runner: vim.system() callback is a fast-event => schedule it
local function run(argv, cb)
  if vim.system then
    vim.system(argv, { text = true }, function(res)
      vim.schedule(function()
        cb(res.code or 1, res.stdout or "", res.stderr or "")
      end)
    end)
  else
    local out = vim.fn.system(argv)
    cb(vim.v.shell_error, out or "", "")
  end
end

-- ---------------- collectors ----------------

local function detect_os()
  local sys = uv.os_uname().sysname
  if sys:match("Windows") then return "windows" end
  if sys == "Linux" then return "linux" end
  if sys == "Darwin" then return "mac" end
  return "linux"
end

local function choose_powershell()
  return exe_exists("pwsh") and "pwsh" or "powershell"
end

-- Linux
local function linux_read_cpu()
  local line = vim.fn.readfile("/proc/stat", "", 1)[1]
  if not line then return nil end
  local nums = {}
  for n in line:gmatch("%s+(%d+)") do nums[#nums+1] = tonumber(n) end

  local user = nums[1] or 0
  local nice = nums[2] or 0
  local sys  = nums[3] or 0
  local idle = nums[4] or 0
  local iow  = nums[5] or 0
  local irq  = nums[6] or 0
  local sirq = nums[7] or 0
  local stl  = nums[8] or 0

  local idle_all = idle + iow
  local non_idle = user + nice + sys + irq + sirq + stl
  local total = idle_all + non_idle

  if state.prev_linux_total then
    local dt = total - state.prev_linux_total
    local di = idle_all - state.prev_linux_idle
    if dt > 0 then
      local usage = (dt - di) / dt * 100
      usage = math.max(0, math.min(100, usage))
      state.prev_linux_total, state.prev_linux_idle = total, idle_all
      return usage
    end
  end

  state.prev_linux_total, state.prev_linux_idle = total, idle_all
  return nil
end

local function linux_read_mem()
  local lines = vim.fn.readfile("/proc/meminfo")
  local total_kb, avail_kb
  for _, ln in ipairs(lines) do
    if ln:match("^MemTotal:") then total_kb = tonumber(ln:match("(%d+)")) end
    if ln:match("^MemAvailable:") then avail_kb = tonumber(ln:match("(%d+)")) end
    if total_kb and avail_kb then break end
  end
  if not total_kb or not avail_kb then return nil end
  return (total_kb - avail_kb) * 1024, total_kb * 1024
end

local function linux_read_net()
  local lines = vim.fn.readfile("/proc/net/dev")
  local rx, tx = 0, 0
  for _, ln in ipairs(lines) do
    if ln:find(":") and not ln:match("^%s*lo:") then
      local rest = ln:match(":%s*(.*)$")
      if rest then
        local cols = {}
        for w in rest:gmatch("%S+") do cols[#cols+1] = tonumber(w) end
        rx = rx + (cols[1] or 0)
        tx = tx + (cols[9] or 0)
      end
    end
  end
  return rx, tx
end

local function unix_read_disk(cb)
  run({ "df", "-kP", "/" }, function(code, out)
    if code ~= 0 or not out then return cb(nil) end
    local line = out:match("[^\n]*\n([^\n]+)")
    if not line then return cb(nil) end
    local _, blocks, used = line:match("^(%S+)%s+(%d+)%s+(%d+)")
    if not blocks then return cb(nil) end
    cb({ total = tonumber(blocks) * 1024, used = tonumber(used) * 1024 })
  end)
end

-- macOS CPU via kern.cp_time delta
local function mac_read_cpu(cb)
  run({ "sysctl", "-n", "kern.cp_time" }, function(code, out)
    if code ~= 0 or not out then return cb(nil) end
    local nums = {}
    for n in out:gmatch("(%d+)") do nums[#nums+1] = tonumber(n) end
    local user = nums[1] or 0
    local nice = nums[2] or 0
    local sys  = nums[3] or 0
    local idle = nums[4] or 0
    local irq  = nums[5] or 0
    local total = user + nice + sys + idle + irq

    if state.prev_mac then
      local dt = total - state.prev_mac.total
      local di = idle - state.prev_mac.idle
      if dt > 0 then
        local usage = (dt - di) / dt * 100
        usage = math.max(0, math.min(100, usage))
        state.prev_mac = { total = total, idle = idle }
        return cb(usage)
      end
    end

    state.prev_mac = { total = total, idle = idle }
    cb(nil)
  end)
end

local function mac_read_mem(cb)
  run({ "sysctl", "-n", "hw.memsize" }, function(c1, out1)
    if c1 ~= 0 then return cb(nil) end
    local total = tonumber((out1 or ""):match("%d+")) or 0
    if total == 0 then return cb(nil) end

    run({ "vm_stat" }, function(c2, out2)
      if c2 ~= 0 or not out2 then return cb(nil) end
      local pagesize = tonumber(out2:match("page size of (%d+) bytes")) or 4096
      local function pages(name)
        local v = out2:match(name .. ":%s+(%d+)%.")
        return tonumber(v) or 0
      end
      local used_pages =
        pages("Pages active") +
        pages("Pages wired down") +
        pages("Pages occupied by compressor")
      cb({ used = used_pages * pagesize, total = total })
    end)
  end)
end

local function mac_read_net(cb)
  run({ "netstat", "-ib" }, function(code, out)
    if code ~= 0 or not out then return cb(nil) end

    local header
    for line in out:gmatch("[^\n]+") do
      if line:match("^Name%s+") then header = line; break end
    end
    if not header then return cb(nil) end

    local cols = {}
    for c in header:gmatch("%S+") do cols[#cols+1] = c end

    local i_idx, o_idx
    for i, c in ipairs(cols) do
      if c == "Ibytes" then i_idx = i end
      if c == "Obytes" then o_idx = i end
    end
    if not i_idx or not o_idx then return cb(nil) end

    local function nth(line, n)
      local k = 0
      for tok in line:gmatch("%S+") do
        k = k + 1
        if k == n then return tok end
      end
      return nil
    end

    local rx, tx = 0, 0
    for line in out:gmatch("[^\n]+") do
      if not line:match("^Name%s+") and not line:match("^lo0%s") then
        local ib = tonumber(nth(line, i_idx) or "")
        local ob = tonumber(nth(line, o_idx) or "")
        if ib and ob then rx = rx + ib; tx = tx + ob end
      end
    end
    cb({ rx = rx, tx = tx })
  end)
end

-- Windows: single sample call (CPU/MEM/DISK/NET cumulative bytes)
local function win_sample(cb)
  local ps = state.ps
  local script =
    "$ProgressPreference='SilentlyContinue';$ErrorActionPreference='SilentlyContinue';" ..
    "$cpu=(Get-CimInstance Win32_Processor|Measure-Object -Property LoadPercentage -Average).Average;" ..
    "$os=Get-CimInstance Win32_OperatingSystem;" ..
    "$mt=[int64]$os.TotalVisibleMemorySize*1KB;$mf=[int64]$os.FreePhysicalMemory*1KB;$mu=$mt-$mf;" ..
    "$d=Get-PSDrive -Name E;$dt=[int64]($d.Used+$d.Free);$du=[int64]$d.Used;" ..
    "$rx=0;$tx=0;" ..
    "try{" ..
      "$ifs=[System.Net.NetworkInformation.NetworkInterface]::GetAllNetworkInterfaces()|" ..
           "Where-Object{$_.NetworkInterfaceType -ne 'Loopback' -and $_.NetworkInterfaceType -ne 'Tunnel'};" ..
      "foreach($i in $ifs){try{$s=$i.GetIPStatistics();$rx+=[int64]$s.BytesReceived;$tx+=[int64]$s.BytesSent}catch{}}" ..
    "}catch{}" ..
    "Write-Output ($cpu.ToString()+'|'+$mt.ToString()+'|'+$mu.ToString()+'|'+$dt.ToString()+'|'+$du.ToString()+'|'+$rx.ToString()+'|'+$tx.ToString());"

  run({ ps, "-NoLogo", "-NoProfile", "-NonInteractive", "-ExecutionPolicy", "Bypass", "-Command", script }, function(code, out)
    if code ~= 0 or not out then return cb(nil) end
    out = out:gsub("\r", "")
    out = (out:match("([^\n]+)") or ""):gsub("^%s+", ""):gsub("%s+$", "")
    local cpu, mt, mu, dt, du, rx, tx = out:match("([^|]+)|([^|]+)|([^|]+)|([^|]+)|([^|]+)|([^|]+)|([^|]+)")
    if not cpu then return cb(nil) end
    cb({
      cpu = tonumber(cpu),
      mem_total = tonumber(mt),
      mem_used = tonumber(mu),
      disk_total = tonumber(dt),
      disk_used = tonumber(du),
      rx = tonumber(rx),
      tx = tonumber(tx),
    })
  end)
end

-- GPU: NVIDIA only (if nvidia-smi exists)
local function read_gpu_nvidia(cb)
  if not exe_exists("nvidia-smi") then return cb(nil) end
  run({
    "nvidia-smi",
    "--query-gpu=utilization.gpu,memory.used,memory.total,temperature.gpu",
    "--format=csv,noheader,nounits",
  }, function(code, out)
    if code ~= 0 or not out or out == "" then return cb(nil) end
    local line = out:match("([^\r\n]+)")
    if not line then return cb(nil) end
    local u, mu, mt, t = line:match("^%s*(%d+)%s*,%s*(%d+)%s*,%s*(%d+)%s*,%s*(%d+)")
    if not u then return cb(nil) end
    cb({ util = tonumber(u), mem_used_mib = tonumber(mu), mem_total_mib = tonumber(mt), temp_c = tonumber(t) })
  end)
end

-- ---------------- rendering ----------------

local function make_segment(icon, text)
  if not text or text == "" then return nil end
  if state.cfg.icons and icon and icon ~= "" then
    return icon .. " " .. text
  end
  return text
end

function M.text()
  local c = state.cfg
  local s = c.symbols
  local m = state.metrics

  local parts = {}

  if c.show.cpu and m.cpu then
    parts[#parts+1] = make_segment(s.cpu, string.format("%2.0f%%", m.cpu))
  end

  if c.show.ram and m.mem_used and m.mem_total and m.mem_total > 0 then
    parts[#parts+1] = make_segment(s.ram, string.format("%.1f/%.1fG", bytes_to_gib(m.mem_used), bytes_to_gib(m.mem_total)))
  end

  if c.show.disk and m.disk_used and m.disk_total and m.disk_total > 0 then
    local pct = (m.disk_used / m.disk_total) * 100
    parts[#parts+1] = make_segment(s.disk, string.format("%2.0f%%", pct))
  end

  if c.show.net and m.rx_rate and m.tx_rate then
    local dn = fmt_rate(m.rx_rate)
    local up = fmt_rate(m.tx_rate)
    if dn and up then
      if c.icons then
        parts[#parts+1] = string.format("%s %s %s %s", s.dn, dn, s.up, up)
      else
        parts[#parts+1] = string.format("DN %s UP %s", dn, up)
      end
    end
  end

  if c.show.gpu and m.gpu and m.gpu.util then
    local g = m.gpu
    local seg = g.temp_c and string.format("%2.0f%% %dC", g.util, g.temp_c) or string.format("%2.0f%%", g.util)
    parts[#parts+1] = make_segment(s.gpu, seg)
  end

  return table.concat(parts, s.sep)
end

local function render_to_tabline()
  state.tabline_text = M.text()
  vim.cmd("redrawtabline")
end

-- Called by Vim's tabline expression
function M.tabline()
  local hl = (state.cfg and state.cfg.highlight) or "TabLine"
  local txt = state.tabline_text or ""

  -- Escape % because tabline uses statusline syntax
  txt = txt:gsub("%%", "%%%%")

  if txt == "" then txt = "resmon" end

  if state.cfg and state.cfg.ui and state.cfg.ui.center then
    return string.format("%%#%s#%%=%s%%=", hl, txt)
  end

  return string.format("%%#%s#%s", hl, txt)
end

-- ---------------- update loop ----------------

local function update_deltas(rx, tx)
  local t = now_ns()
  if not state.last_ts then
    state.last_ts = t
    state.prev_rx, state.prev_tx = rx, tx
    return
  end
  local dt = ns_to_s(t - state.last_ts)
  state.last_ts = t
  if dt <= 0 then return end
  if rx and tx and state.prev_rx and state.prev_tx then
    state.metrics.rx_rate = (rx - state.prev_rx) / dt
    state.metrics.tx_rate = (tx - state.prev_tx) / dt
  end
  state.prev_rx, state.prev_tx = rx, tx
end

local function refresh_disk_if_due()
  local t = now_ns()
  if (t - state.last_disk_at) < (state.cfg.disk_interval_ms * 1e6) then return end
  if state.pending.disk then return end
  state.pending.disk = true
  state.last_disk_at = t

  if state.os == "windows" then
    state.pending.disk = false
    return
  end

  unix_read_disk(function(d)
    state.pending.disk = false
    if d then
      state.metrics.disk_total = d.total
      state.metrics.disk_used = d.used
      render_to_tabline()
    end
  end)
end

local function refresh_gpu_if_due()
  local t = now_ns()
  if (t - state.last_gpu_at) < (state.cfg.gpu_interval_ms * 1e6) then return end
  if state.pending.gpu then return end
  state.pending.gpu = true
  state.last_gpu_at = t

  read_gpu_nvidia(function(g)
    state.pending.gpu = false
    state.metrics.gpu = g
    render_to_tabline()
  end)
end

local function refresh_base()
  if state.pending.base then return end
  state.pending.base = true

  if state.os == "linux" then
    local cpu = linux_read_cpu()
    local mem_used, mem_total = linux_read_mem()
    local rx, tx = linux_read_net()

    if cpu then state.metrics.cpu = cpu end
    if mem_used and mem_total then
      state.metrics.mem_used = mem_used
      state.metrics.mem_total = mem_total
    end
    update_deltas(rx, tx)

    state.pending.base = false
    render_to_tabline()
    return
  end

  if state.os == "mac" then
    mac_read_cpu(function(cpu)
      if cpu then state.metrics.cpu = cpu end
      mac_read_mem(function(mem)
        if mem then
          state.metrics.mem_used = mem.used
          state.metrics.mem_total = mem.total
        end
        mac_read_net(function(net)
          if net then update_deltas(net.rx, net.tx) end
          state.pending.base = false
          render_to_tabline()
        end)
      end)
    end)
    return
  end

  -- windows
  win_sample(function(samp)
    state.pending.base = false
    if samp then
      if samp.cpu then state.metrics.cpu = samp.cpu end
      if samp.mem_used and samp.mem_total then
        state.metrics.mem_used = samp.mem_used
        state.metrics.mem_total = samp.mem_total
      end
      if samp.disk_used and samp.disk_total then
        state.metrics.disk_used = samp.disk_used
        state.metrics.disk_total = samp.disk_total
      end
      update_deltas(samp.rx, samp.tx)
    end
    render_to_tabline()
  end)
end

local function tick()
  if not state.cfg.enabled then return end
  refresh_base()
  refresh_disk_if_due()
  refresh_gpu_if_due()
end

-- ---------------- tabline install/remove ----------------

local function install_tabline()
  ensure_highlight()

  if state.prev_tabline == nil then
    state.prev_tabline = vim.o.tabline
    state.prev_showtabline = vim.o.showtabline
  end

  vim.o.showtabline = 2
  vim.o.tabline = string.format("%%!v:lua.require'%s'.tabline()", state.cfg.module)
  vim.cmd("redrawtabline")
end

local function restore_tabline()
  if state.prev_tabline ~= nil then
    vim.o.tabline = state.prev_tabline
    vim.o.showtabline = state.prev_showtabline
    state.prev_tabline, state.prev_showtabline = nil, nil
    vim.cmd("redrawtabline")
  end
end

-- ---------------- public API ----------------

function M.open()
  state.cfg.enabled = true
  install_tabline()
  tick()
end

function M.close()
  state.cfg.enabled = false
  restore_tabline()
end

function M.toggle()
  if state.cfg.enabled then M.close() else M.open() end
end

function M.setup(opts)
  state.cfg = merge(defaults, opts or {})
  state.os = detect_os()
  state.ps = choose_powershell()

  ensure_highlight()

  local aug = vim.api.nvim_create_augroup("ResMonTabline", { clear = true })

  vim.api.nvim_create_autocmd("ColorScheme", {
    group = aug,
    callback = function()
      ensure_highlight()
      if state.cfg.enabled then vim.cmd("redrawtabline") end
    end,
  })

  vim.api.nvim_create_autocmd("VimLeavePre", {
    group = aug,
    callback = function()
      if state.timer then
        state.timer:stop()
        state.timer:close()
        state.timer = nil
      end
      restore_tabline()
    end,
  })

  vim.api.nvim_create_user_command("ResMonOpen", function() M.open() end, {})
  vim.api.nvim_create_user_command("ResMonClose", function() M.close() end, {})
  vim.api.nvim_create_user_command("ResMonToggle", function() M.toggle() end, {})

  if state.timer then
    state.timer:stop()
    state.timer:close()
  end

  state.timer = uv.new_timer()
  state.timer:start(0, state.cfg.interval_ms, vim.schedule_wrap(tick))

  if state.cfg.enabled then M.open() else M.close() end
end

return M

