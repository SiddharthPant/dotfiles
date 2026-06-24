local function setup_treesitter()
	local treesitter = require("nvim-treesitter")
	treesitter.setup({})

	local ensure_installed = {
		"vim",
		"vimdoc",
		"rust",
		"c",
		"cpp",
		"go",
		"templ",
		"html",
		"css",
		"javascript",
		"json",
		"lua",
		"markdown",
		"python",
		"typescript",
		"vue",
		"svelte",
		"bash",
	}

	treesitter.install(ensure_installed)

	local group = vim.api.nvim_create_augroup("TreeSitterConfig", { clear = true })
	vim.api.nvim_create_autocmd("FileType", {
		group = group,
		callback = function(args)
			local lang = vim.treesitter.language.get_lang(args.match)
			if vim.list_contains(treesitter.get_installed(), lang) then
				vim.treesitter.start(args.buf)
			end
		end,
	})
end

setup_treesitter()

require("lazydev").setup({
	library = {
		{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
		{ path = "snacks.nvim", words = { "Snacks" } },
		{ path = "nvim-lspconfig", words = { "lspconfig", "vim%.lsp%.config" } },
	},
})

require("snacks").setup({
	bigfile = { enabled = true },
	bufdelete = { enabled = true },
	explorer = {
		enabled = true,
		replace_netrw = true,
	},
	git = { enabled = true },
	gitbrowse = { enabled = true },
	indent = { enabled = true },
	input = { enabled = true },
	notifier = { enabled = true },
	notify = { enabled = true },
	picker = {
		enabled = true,
		sources = {
			explorer = {
				hidden = true,
				ignored = true,
				layout = {
					layout = {
						position = "right",
					},
				},
				actions = {
					explorer_update = function(picker)
						local cwd = picker:cwd()
						require("snacks.explorer.git").refresh(cwd)
						require("snacks.explorer.tree"):refresh(cwd)
						picker.list:set_target()
						picker:find()
					end,
				},
				win = {
					list = {
						keys = {
							["<C-l>"] = function()
								if vim.env.TMUX and vim.env.TMUX ~= "" then
									vim.system({ "tmux", "select-pane", "-R" })
								end
							end,
						},
					},
				},
			},
		},
	},
	quickfile = { enabled = true },
	scope = { enabled = true },
	statuscolumn = { enabled = true },
	words = { enabled = true },
})

require("flash").setup({})

-- fff.nvim: file finder + live grep. Its native search binary is built on
-- install/update by the PackChanged hook in lua/plugins/pack.lua.
require("fff").setup({
	layout = {
		height = 0.8,
		width = 0.8,
		prompt_position = "bottom",
		preview_position = "right",
		preview_size = 0.5,
	},
})

require("grug-far").setup({})

require("gitsigns").setup({
	signs = {
		add = { text = "▎" },
		change = { text = "▎" },
		delete = { text = "" },
		topdelete = { text = "" },
		changedelete = { text = "▎" },
		untracked = { text = "▎" },
	},
	signs_staged = {
		add = { text = "▎" },
		change = { text = "▎" },
		delete = { text = "" },
		topdelete = { text = "" },
		changedelete = { text = "▎" },
	},
	signcolumn = true,
	current_line_blame = false,
})

require("codediff").setup({
	keymaps = {
		view = {
			next_hunk = "]h",
			prev_hunk = "[h",
		},
	},
})

require("bufferline").setup({
	options = {
		numbers = "buffer_id",
		indicator = { style = "underline" },
		separator_style = "thin",
		show_buffer_icons = false,
		show_close_icon = false,
		show_tab_indicators = false,
		modified_icon = "●",
		buffer_close_icon = "×",
		close_command = function(bufnr)
			require("snacks").bufdelete({ buf = bufnr })
		end,
		right_mouse_command = function(bufnr)
			require("snacks").bufdelete({ buf = bufnr })
		end,
		tab_size = 14,
		max_name_length = 14,
		truncate_names = true,
	},
})

-- Session restore: persistence.nvim auto-saves the session on exit and restores
-- it when nvim is started without file arguments.
require("persistence").setup({
	need = 1,
	branch = true,
})

local persistence_group = vim.api.nvim_create_augroup("PersistenceRestore", { clear = true })

vim.api.nvim_create_autocmd("StdinReadPre", {
	group = persistence_group,
	callback = function()
		vim.g.started_stdin = true
	end,
})

vim.api.nvim_create_autocmd("VimEnter", {
	group = persistence_group,
	callback = function()
		if vim.fn.argc() == 0 and not vim.g.started_stdin then
			require("persistence").load()
		end
	end,
})

-- The snacks explorer opens as a real split. If it is open during session save,
-- persistence can restore it as an empty window, so close picker/explorer windows
-- synchronously before the session is written.
vim.api.nvim_create_autocmd("User", {
	group = persistence_group,
	pattern = "PersistenceSavePre",
	callback = function()
		for _, picker in ipairs(require("snacks").picker.get({ source = "explorer" })) do
			picker:close()
		end

		local wins = vim.api.nvim_tabpage_list_wins(0)
		for _, win in ipairs(wins) do
			if not vim.api.nvim_win_is_valid(win) then
				goto continue
			end

			local buf = vim.api.nvim_win_get_buf(win)
			local ok, ft = pcall(function()
				return vim.bo[buf].filetype
			end)
			local is_snacks_ft = ok
				and (
					ft == "snacks_picker_list"
					or ft == "snacks_picker_input"
					or ft == "snacks_picker_preview"
					or ft == "snacks_win"
				)
			local is_snacks_win = vim.w[win] ~= nil and vim.w[win].snacks_win ~= nil
			local is_empty_placeholder = ok
				and ft == ""
				and vim.bo[buf].buftype == ""
				and not vim.bo[buf].modified
				and vim.api.nvim_buf_get_name(buf) == ""
				and vim.api.nvim_buf_line_count(buf) <= 1

			if (is_snacks_ft or is_snacks_win or is_empty_placeholder) and #vim.api.nvim_tabpage_list_wins(0) > 1 then
				pcall(vim.api.nvim_win_close, win, true)
			end
			::continue::
		end
	end,
})

-- Session restore loads buffers via `badd`, which can skip FileType detection
-- and leave restored buffers without Treesitter highlighting.
vim.api.nvim_create_autocmd("User", {
	group = persistence_group,
	pattern = "PersistenceLoadPost",
	callback = function()
		vim.schedule(function()
			for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
				if vim.api.nvim_buf_is_loaded(bufnr) and vim.bo[bufnr].buftype == "" then
					if vim.bo[bufnr].filetype == "" then
						vim.api.nvim_buf_call(bufnr, function()
							vim.cmd("filetype detect")
						end)
					end
					if vim.bo[bufnr].filetype ~= "" and not vim.treesitter.highlighter.active[bufnr] then
						pcall(vim.treesitter.start, bufnr)
					end
				end
			end
		end)
	end,
})

vim.keymap.set("n", "<leader>qs", function()
	require("persistence").load()
end, { desc = "Restore session for cwd" })
vim.keymap.set("n", "<leader>qS", function()
	require("persistence").select()
end, { desc = "Select session" })
vim.keymap.set("n", "<leader>ql", function()
	require("persistence").load({ last = true })
end, { desc = "Restore last session" })
vim.keymap.set("n", "<leader>qD", function()
	require("persistence").stop()
end, { desc = "Stop session save on exit" })
