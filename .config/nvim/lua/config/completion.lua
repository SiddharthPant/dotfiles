local M = {}

-- Setup Supermaven (disabled by default - use <leader>ts to toggle)
require("supermaven-nvim").setup({
	silent = true,
	log_level = "off",
	-- Don't use default keymaps - we define our own
	disable_keymaps = true,
})

-- Start supermaven then immediately stop it so it's "off" by default
-- User can toggle on with :SupermavenToggle or <leader>ts
vim.defer_fn(function()
	local api = require("supermaven-nvim.api")
	if api.is_running() then
		api.stop()
	end
end, 100)

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
		default = { "lsp", "path", "buffer", "snippets" },
		per_filetype = {
			lua = { inherit_defaults = true, "lazydev" },
		},
		providers = {
			lazydev = {
				name = "LazyDev",
				module = "lazydev.integrations.blink",
				score_offset = 100,
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
		vim.schedule(function()
			supermaven.on_accept_suggestion()
		end)
		return ""
	end
	return "<C-y>"
end, { expr = true, desc = "Accept Supermaven Suggestion" })

M.capabilities = blink.get_lsp_capabilities()

return M
