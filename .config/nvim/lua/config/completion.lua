local M = {}

-- Setup Supermaven
require("supermaven-nvim").setup({
	silent = true,
	log_level = "off",
})

local blink = require("blink.cmp")

blink.setup({
	keymap = {
		preset = "none",
		["<C-Space>"] = { "show", "hide" },
		["<CR>"] = { "accept", "fallback" },
		["<C-n>"] = { "select_next", "fallback" },
		["<C-p>"] = { "select_prev", "fallback" },
		["<Tab>"] = { "snippet_forward", "fallback" },
		["<S-Tab>"] = { "snippet_backward", "fallback" },
	},
	appearance = { nerd_font_variant = "mono" },
	completion = { menu = { auto_show = true } },
	sources = {
		default = { "lsp", "path", "buffer", "snippets", "supermaven" },
		per_filetype = {
			lua = { inherit_defaults = true, "lazydev" },
		},
		providers = {
			lazydev = {
				name = "LazyDev",
				module = "lazydev.integrations.blink",
				score_offset = 100,
			},
			supermaven = {
				name = "Supermaven",
				module = "blink.compat.source.supermaven",
				score_offset = 50,
			},
		},
	},
	snippets = {
		-- Use native Neovim snippets.
		expand = function(snippet)
			vim.snippet.expand(snippet)
		end,
		active = function(filter)
			return vim.snippet.active(filter)
		end,
		jump = function(direction)
			vim.snippet.jump(direction)
		end,
	},
	fuzzy = {
		implementation = "prefer_rust",
		prebuilt_binaries = { download = true },
	},
})

vim.keymap.set("i", "<C-y>", function()
	local supermaven = require("supermaven-nvim.completion_preview")
	if supermaven.has_suggestion() then
		supermaven.on_accept_suggestion()
		return ""
	end
	return "<C-y>"
end, { expr = true, desc = "Accept Supermaven Suggestion" })

M.capabilities = blink.get_lsp_capabilities()

return M
