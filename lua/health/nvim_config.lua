local M = {}

local function check_exe(name)
  if vim.fn.executable(name) == 1 then
    vim.health.report_ok(name .. " is available")
  else
    vim.health.report_warn(name .. " is not available")
  end
end

function M.check()
  vim.health.report_start("nvim config checks")
  check_exe("git")
  check_exe("rg")
  check_exe("fd")
  check_exe("node")
end

return M
