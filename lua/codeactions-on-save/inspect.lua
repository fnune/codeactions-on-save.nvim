---@alias Inspect fun(): nil

---@class CodeActionsOnSaveInspect
---@field register Inspect
local M = {}

function M.inspect()
  local params = vim.lsp.util.make_range_params(0, "utf-8")
  params.context = { diagnostics = {} }

  local results = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, 100)
  if not results then
    vim.notify("No actions available", vim.log.levels.INFO)
    return
  end

  for _, result in pairs(results) do
    for _, action in pairs(result.result or {}) do
      vim.notify("Title: " .. action.title .. " | Kind: " .. (action.kind or "N/A"))
    end
  end
end

return M
