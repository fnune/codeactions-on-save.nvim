local main = require("codeactions-on-save.main")
local inspect = require("codeactions-on-save.inspect")

local M = {}

M.register = main.register
M.inspect = inspect.inspect

return M
