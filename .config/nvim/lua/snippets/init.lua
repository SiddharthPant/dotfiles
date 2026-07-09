-- Snippet loader {{{
local by_ft = {
	lua = require("snippets.lua"),
	rust = require("snippets.rust"),
	go = require("snippets.go"),
	python = require("snippets.python"),
	javascript = require("snippets.javascript"),
	typescript = require("snippets.typescript"),
	php = require("snippets.php"),
	blade = require("snippets.blade"),
}

local M = {}

function M.get(trigger)
	local ft = vim.bo.filetype
	local snippets = by_ft[ft] or by_ft[ft:gsub("react$", "")]
	return snippets and snippets[trigger]
end

return M
-- }}}

-- vim: foldmethod=marker foldlevel=0
