---@alias PatternList string[] List of file patterns for autocmds (e.g., { "*.lua" })
---@alias KindList string[] List of code action kinds (e.g., { "source.organizeImports" })
---@alias ActionTimeoutMs integer Timeout for synchronous requests, defaulting to 100ms

---@alias Register fun(pattern: PatternList, kinds: KindList, timeout_ms?: ActionTimeoutMs): nil

---@class CodeActionsOnSaveMain
---@field register Register
local M = {}

---@param action table
---@param buf integer
---@param timeout_ms ActionTimeoutMs
---@param attempts integer
local function handle_action_sync(action, buf, timeout_ms, attempts)
  if attempts > 3 then
    vim.notify("Max resolve attempts reached for action " .. action.kind, vim.log.levels.WARN)
    return
  end

  if action.edit then
    vim.lsp.util.apply_workspace_edit(action.edit, "utf-16")
  elseif action.command then
    vim.lsp.buf.execute_command(action.command)
  else
    -- neovim:runtime/lua/vim/lsp/buf.lua shows how to run a code action
    -- synchronously. This section is based on that.
    local resolve_result = vim.lsp.buf_request_sync(buf, "codeAction/resolve", action, timeout_ms)
    if resolve_result then
      for _, resolved_action in pairs(resolve_result) do
        handle_action_sync(resolved_action.result, buf, timeout_ms, attempts + 1)
      end
    else
      vim.notify("Failed to resolve code action " .. action.kind .. " without edit or command", vim.log.levels.WARN)
    end
  end
end

---@param kinds KindList
---@param buf integer
---@param timeout_ms ActionTimeoutMs
local function handle_write_pre(kinds, buf, timeout_ms)
  local params = vim.lsp.util.make_range_params(0, "utf-8")
  params.context = { diagnostics = {} }

  local results = vim.lsp.buf_request_sync(buf, "textDocument/codeAction", params, timeout_ms)
  if not results then
    return
  end

  for _, result in pairs(results) do
    for _, action in pairs(result.result or {}) do
      for _, kind in pairs(kinds) do
        if action.kind == kind then
          handle_action_sync(action, buf, timeout_ms, 0)
        end
      end
    end
  end
end

function M.register(pattern, kinds, timeout_ms)
  vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = pattern,
    callback = function(args)
      handle_write_pre(kinds, args.buf, timeout_ms or 100)
    end,
    desc = "Auto-run code actions " .. table.concat(kinds, ", ") .. " on save",
  })
end

return M
