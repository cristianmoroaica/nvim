-- lua/config/dotenv.lua
local function trim(s) return (s:gsub("^%s+", ""):gsub("%s+$", "")) end

local function unquote(v)
  -- strip surrounding single/double quotes
  local q1 = v:match('^"(.*)"$')
  if q1 then return q1 end
  local q2 = v:match("^'(.*)'$")
  if q2 then return q2 end
  return v
end

local function strip_bom(s)
  -- remove UTF-8 BOM if present
  if s:sub(1,3) == "\239\187\191" then
    return s:sub(4)
  end
  return s
end

local function load_env(path)
  local f = io.open(path, "r")
  if not f then
    vim.notify("dotenv: no .env at " .. path, vim.log.levels.WARN)
    return
  end

  for rawline in f:lines() do
    local line = strip_bom(rawline)
    line = line:gsub("\r$", "")              -- CRLF -> LF
    line = trim(line)

    if line ~= "" and not line:match("^#") and not line:match("^;") then
      -- KEY = value   (allow spaces and underscores)
      local key, val = line:match("^([%w_%.%-]+)%s*=%s*(.+)$")
      if key and val then
        val = trim(unquote(val))
        -- export to Neovim environment
        vim.fn.setenv(key, val)
        vim.env[key] = val
        -- Uncomment if you want to see each set:
        -- vim.notify("dotenv: set " .. key, vim.log.levels.INFO)
      else
        -- Uncomment to debug skipped lines:
        -- vim.notify("dotenv: skipped line: " .. rawline, vim.log.levels.DEBUG)
      end
    end
  end
  f:close()
end

-- load from your config root: AppData/Local/nvim/.env
load_env(vim.fn.stdpath("config") .. "/.env")

