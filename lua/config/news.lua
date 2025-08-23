local function news(force)
  local file_path = [[E:\Projects\mimir\current-news.md]]
  local last_run_path = [[E:\Projects\mimir\last_news_run.txt]]
  local error_log_path = [[E:\Projects\mimir\news_error.log]]
  local six_hours = 21600  -- 6 * 3600 seconds

  local function get_last_run()
    local f = io.open(last_run_path, 'r')
    if f then
      local timestamp = tonumber(f:read('*a')) or 0
      f:close()
      return timestamp
    else
      vim.notify('Last run file not found, using 0', vim.log.levels.WARN)
      return 0
    end
  end

  local function set_last_run(timestamp)
    local f = io.open(last_run_path, 'w')
    if f then
      f:write(tostring(timestamp))
      f:close()
    else
      vim.notify('Failed to write last run timestamp', vim.log.levels.ERROR)
    end
  end

  local now = os.time()
  local last_run = get_last_run()
  local time_diff = now - last_run

  -- Validate timestamp to avoid future dates
  if last_run > now + 86400 then -- If last_run is more than 1 day in the future
    vim.notify('Invalid last run timestamp (future date: ' .. last_run .. '), resetting to 0', vim.log.levels.WARN)
    last_run = 0
  end

  local should_run = (force == 'update') or time_diff >= six_hours

  if should_run then
    -- Need to trigger a Langflow update
    local spinner_timer = nil
    local function start_spinner()
      local symbols = {'/', '-', '\\', '|'}
      local index = 1
      spinner_timer = vim.loop.new_timer()
      spinner_timer:start(0, 100, vim.schedule_wrap(function()
        vim.api.nvim_echo({{'Synthetizing todays news ' .. symbols[index], 'None'}}, false, {})
        index = (index % 4) + 1
      end))
    end

    local function stop_spinner()
      if spinner_timer then
        spinner_timer:stop()
        spinner_timer:close()
        spinner_timer = nil
        vim.api.nvim_echo({{''}}, false, {})
      end
    end

    start_spinner()

    local api_key = os.getenv("LANGFLOW_API_KEY")

    local flow_url = os.getenv("LANGFLOW_NEWS_FLOW_URL")

    if not api_key then
      stop_spinner()
      vim.notify('LANGFLOW_API_KEY not set', vim.log.levels.ERROR)
      vim.cmd('edit ' .. vim.fn.fnameescape(file_path))
      return
    end

    if not flow_url then
      stop_spinner()
      vim.notify('LANGFLOW_NEWS_FLOW_URL not set', vim.log.levels.ERROR)
      vim.cmd('edit ' .. vim.fn.fnameescape(file_path))
      return
    end

    local python_code = [[
import requests
import json
import sys
import time

# API Configuration
api_key = "]]..api_key..[["
url = "]]..flow_url..[["

# Request payload configuration
payload = {
    "output_type": "text",
    "input_type": "text",
    "input_value": ""
}

# Request headers
headers = {
    "Content-Type": "application/json",
    "x-api-key": api_key
}

try:
    response = requests.post(url, headers=headers, json=payload)
    response.raise_for_status()
    time.sleep(2)
except requests.exceptions.RequestException as e:
    sys.stderr.write(f"Error triggering update: {e}\n")
    sys.exit(1)
]]

    local error_output = ''
    local job_id = vim.fn.jobstart({'py', '-c', python_code}, {
      on_stdout = function(_, data)
        if data then
          error_output = error_output .. table.concat(data, '\n') .. '\n'
        end
      end,
      on_stderr = function(_, data)
        if data then
          error_output = error_output .. table.concat(data, '\n') .. '\n'
        end
      end,
      on_exit = function(_, exit_code)
        stop_spinner()
        if exit_code == 0 then
          set_last_run(now)
        else
          local f = io.open(error_log_path, 'w')
          if f then
            f:write(error_output)
            f:close()
          end
          vim.notify('Failed to trigger news update (exit code: ' .. exit_code .. '). Check ' .. error_log_path .. ' for details.', vim.log.levels.ERROR)
        end
        -- Open the file regardless
        vim.cmd('edit ' .. vim.fn.fnameescape(file_path))
      end
    })

    if job_id <= 0 then
      stop_spinner()
      vim.notify('Failed to start Python job', vim.log.levels.ERROR)
      vim.cmd('edit ' .. vim.fn.fnameescape(file_path))
    end
  else
    -- No need to update, just open the file
    vim.cmd('edit ' .. vim.fn.fnameescape(file_path))
  end
end

vim.api.nvim_create_user_command('News', function(opts)
  news(opts.args)
end, { nargs = '?' })


