local M = {}

M.actions = {}

local function run(action_kind)
  local clients = vim.lsp.get_active_clients({ bufnr = 0 })
  if #clients == 0 then
    return
  end

  local params = vim.lsp.util.make_range_params()
  params.context = { diagnostics = {} }

  local results = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, 100)
  if not results then
    return
  end

  for _, result in pairs(results) do
    for _, action in pairs(result.result or {}) do
      if action.kind == action_kind then
        if action.edit then
          vim.lsp.util.apply_workspace_edit(action.edit, "utf-16")
        elseif action.command then
          vim.lsp.buf.execute_command(action.command)
        else
          vim.notify("Action '" .. action.title .. "' has no command or edit", vim.log.levels.ERROR)
        end
        return
      end
    end
  end
end

function M.register(pattern, action_kind)
  if not M.actions[pattern] then
    M.actions[pattern] = {}
  end
  table.insert(M.actions[pattern], action_kind)

  vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = pattern,
    callback = function()
      run(action_kind)
    end,
    desc = "Auto-run code action " .. action_kind .. " on save",
  })
end

return M
