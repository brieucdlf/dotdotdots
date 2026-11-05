-- Clipboard for sessions whose yanks may need to reach another machine:
-- every copy is emitted as OSC 52 (inside tmux this becomes a tmux buffer,
-- rebroadcast to every attached client, local or SSH). Paste prefers the
-- local Wayland clipboard when one is available, so content copied in other
-- apps remains pasteable; without a display, paste is an OSC 52 query that
-- tmux (or the terminal) answers.
local M = {}

function M.setup()
  local in_tmux = vim.env.TMUX ~= nil
  local in_ssh = vim.env.SSH_TTY ~= nil or vim.env.SSH_CONNECTION ~= nil
  -- herdr-core can run on another machine than the window showing it.
  local in_hc = vim.env.HC_TERMINAL_ID ~= nil

  if not (in_tmux or in_ssh or in_hc) then
    return
  end

  local osc52 = require("vim.ui.clipboard.osc52")
  local has_wayland = vim.env.WAYLAND_DISPLAY ~= nil
    and vim.fn.executable("wl-copy") == 1
    and vim.fn.executable("wl-paste") == 1

  local function copy(register)
    local emit = osc52.copy(register)

    return function(lines)
      if has_wayland then
        local cmd = { "wl-copy", "--sensitive", "--type", "text/plain" }
        if register == "*" then
          cmd[#cmd + 1] = "--primary"
        end
        vim.fn.system(cmd, lines)
      end

      if vim.g.omarchy_remote_clipboard_osc52 ~= false then
        emit(lines)
      end
    end
  end

  local function paste(register)
    if not has_wayland then
      return osc52.paste(register)
    end

    return function()
      local cmd = { "wl-paste", "--no-newline" }
      if register == "*" then
        cmd[#cmd + 1] = "--primary"
      end

      local lines = vim.fn.systemlist(cmd, "", 1)
      return vim.v.shell_error == 0 and lines or {}
    end
  end

  vim.g.clipboard = {
    name = "OmarchyRemoteClipboard",
    copy = { ["+"] = copy("+"), ["*"] = copy("*") },
    paste = { ["+"] = paste("+"), ["*"] = paste("*") },
    cache_enabled = 0,
  }
end

return M
