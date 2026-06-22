vim.g.mapleader = " "
vim.g.maplocalleader = ","

local map = vim.keymap.set

-- Movement and editing basics
map("n", "j", function()
	return vim.v.count == 0 and "gj" or "j"
end, { expr = true, silent = true, desc = "Down (wrap-aware)" })
map("n", "k", function()
	return vim.v.count == 0 and "gk" or "k"
end, { expr = true, silent = true, desc = "Up (wrap-aware)" })
map("n", "n", "nzzzv", { desc = "Next search result (centered)" })
map("n", "N", "Nzzzv", { desc = "Previous search result (centered)" })
map("n", "<C-d>", "<C-d>zz", { desc = "Half page down (centered)" })
map("n", "<C-u>", "<C-u>zz", { desc = "Half page up (centered)" })
map("n", "<Esc>", "<cmd>nohlsearch<CR><Esc>", { silent = true, desc = "Escape and clear search highlight" })
map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
map("x", "<leader>P", '"_dP', { desc = "Paste without yanking" })
map("n", "J", "mzJ`z", { desc = "Join lines and keep cursor position" })

map("n", "<A-j>", ":m .+1<CR>==", { desc = "Move line down" })
map("n", "<A-k>", ":m .-2<CR>==", { desc = "Move line up" })
map("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
map("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })
map("v", "<", "<gv", { desc = "Indent left and reselect" })
map("v", ">", ">gv", { desc = "Indent right and reselect" })

-- Windows, splits, and tmux panes
map("n", "<C-h>", "<cmd>TmuxNavigateLeft<CR>", { desc = "Navigate left (tmux aware)" })
map("n", "<C-j>", "<cmd>TmuxNavigateDown<CR>", { desc = "Navigate down (tmux aware)" })
map("n", "<C-k>", "<cmd>TmuxNavigateUp<CR>", { desc = "Navigate up (tmux aware)" })
map("n", "<C-l>", "<cmd>TmuxNavigateRight<CR>", { desc = "Navigate right (tmux aware)" })

map("n", "<leader>sv", ":vsplit<CR>", { desc = "Split window vertically" })
map("n", "<leader>sh", ":split<CR>", { desc = "Split window horizontally" })
map("n", "<C-Up>", ":resize +2<CR>", { desc = "Increase window height" })
map("n", "<C-Down>", ":resize -2<CR>", { desc = "Decrease window height" })
map("n", "<C-Left>", ":vertical resize -2<CR>", { desc = "Decrease window width" })
map("n", "<C-Right>", ":vertical resize +2<CR>", { desc = "Increase window width" })

-- Buffers
map("n", "<leader>bd", function()
	require("snacks").bufdelete()
end, { desc = "Delete buffer" })
map("n", "<leader>bl", "<cmd>BufferLineCloseLeft<CR>", { desc = "Delete buffers to the left" })
map("n", "<leader>br", "<cmd>BufferLineCloseRight<CR>", { desc = "Delete buffers to the right" })
map("n", "<leader>bo", "<cmd>BufferLineCloseOthers<CR>", { desc = "Delete other buffers" })

-- Flash
map({ "n", "x", "o" }, "s", function()
	require("flash").jump()
end, { desc = "Flash" })
map({ "n", "o", "x" }, "S", function()
	require("flash").treesitter()
end, { desc = "Flash Treesitter" })
map("o", "r", function()
	require("flash").remote()
end, { desc = "Remote Flash" })
map({ "o", "x" }, "R", function()
	require("flash").treesitter_search()
end, { desc = "Treesitter Search" })

-- Toggles
map("n", "<leader>tf", function()
	require("flash").toggle()
end, { desc = "Toggle Flash Search" })
map("n", "<leader>tw", function()
	vim.wo.wrap = not vim.wo.wrap
	require("snacks").notify(vim.wo.wrap and "Line wrap enabled" or "Line wrap disabled", {
		title = "Wrap",
		level = "info",
	})
end, { desc = "Toggle line wrap" })
map("n", "<leader>td", function()
	local enabled = vim.diagnostic.is_enabled()
	vim.diagnostic.enable(not enabled)
	require("snacks").notify(enabled and "Diagnostics disabled" or "Diagnostics enabled", {
		title = "LSP Diagnostics",
		level = "info",
	})
end, { desc = "Toggle diagnostics" })
map("n", "<leader>tc", function()
	local enabled = vim.list_contains(vim.opt.clipboard:get(), "unnamedplus")
	if enabled then
		vim.opt.clipboard:remove("unnamedplus")
	else
		vim.opt.clipboard:append("unnamedplus")
	end
	require("snacks").notify(enabled and "System clipboard disabled" or "System clipboard enabled", {
		title = "Clipboard",
		level = "info",
	})
end, { desc = "Toggle system clipboard" })
map("n", "<leader>tg", function()
	local config = require("gitsigns.config").config
	require("gitsigns").toggle_signs(not config.signcolumn)
end, { desc = "Toggle git signs" })
map("n", "<leader>tu", "<cmd>UndotreeToggle<CR>", { desc = "Toggle undo tree" })
map("n", "<leader>tb", function()
	require("gitsigns").toggle_current_line_blame()
end, { desc = "Toggle inline blame" })
map("n", "<leader>ts", function()
	vim.cmd("SupermavenToggle")
	local api = require("supermaven-nvim.api")
	local is_running = api.is_running()
	require("snacks").notify(is_running and "Supermaven AI enabled" or "Supermaven AI disabled", {
		title = "Supermaven",
		level = "info",
	})
end, { desc = "Toggle Supermaven AI suggestions" })

-- Path/project utilities
map("n", "<leader>pa", function()
	local path = vim.fn.expand("%:p")
	vim.fn.setreg("+", path)
	print("file:", path)
end, { desc = "Copy full file path" })

-- Explorer
map("n", "<leader>e", function()
	require("snacks").explorer()
end, { desc = "Toggle Explorer" })

-- Find/search
map("n", "<leader><leader>", function()
	require("fff").find_files()
end, { desc = "Find files" })
map("n", "<leader>fo", function()
	require("snacks").picker.recent()
end, { desc = "Find old files" })
map("n", "<leader>fg", function()
	require("fff").live_grep()
end, { desc = "Live grep" })
map("n", "<leader>fc", function()
	require("fff").live_grep({ query = vim.fn.expand("<cword>") })
end, { desc = "Grep current word" })
map("n", "<leader>fb", function()
	require("snacks").picker.buffers()
end, { desc = "Find buffers" })
map("n", "<leader>fh", function()
	require("snacks").picker.help()
end, { desc = "Find help" })
map("n", "<leader>fk", function()
	require("snacks").picker.keymaps()
end, { desc = "Find keymaps" })
map("n", "<leader>fx", function()
	require("snacks").picker.diagnostics_buffer()
end, { desc = "Find diagnostics (buffer)" })
map("n", "<leader>fX", function()
	require("snacks").picker.diagnostics()
end, { desc = "Find diagnostics (workspace)" })
map("n", "<leader>fn", function()
	require("snacks").notifier.show_history()
end, { desc = "Show notifications" })

-- Replace
map({ "n", "x" }, "<leader>rr", function()
	require("grug-far").open({
		prefills = {
			paths = vim.fn.expand("%"),
		},
		visualSelectionUsage = "auto-detect",
	})
end, { desc = "Search and replace in file" })
map({ "n", "x" }, "<leader>rR", function()
	require("grug-far").open({ visualSelectionUsage = "auto-detect" })
end, { desc = "Search and replace" })

-- Git
map("n", "<leader>gb", function()
	require("snacks").git.blame_line()
end, { desc = "Git blame line" })
map("n", "<leader>gB", function()
	require("snacks").gitbrowse()
end, { desc = "Git browse" })
map("n", "<leader>gs", function()
	require("snacks").picker.git_status()
end, { desc = "Git status" })
map("n", "<leader>gd", ":CodeDiff<CR>", { desc = "Git diff view (codediff)" })
map("n", "<leader>gg", function()
	require("snacks").lazygit()
end, { desc = "Open lazygit" })

local function nav_hunk(direction, diff_key)
	if vim.wo.diff then
		vim.cmd.normal({ diff_key, bang = true })
		return
	end
	require("gitsigns").nav_hunk(direction)
end

map("n", "]h", function()
	nav_hunk("next", "]c")
end, { desc = "Next git hunk" })
map("n", "[h", function()
	nav_hunk("prev", "[c")
end, { desc = "Previous git hunk" })
map("n", "]H", function()
	require("gitsigns").nav_hunk("last")
end, { desc = "Last git hunk" })
map("n", "[H", function()
	require("gitsigns").nav_hunk("first")
end, { desc = "First git hunk" })
map("n", "<leader>hs", function()
	require("gitsigns").stage_hunk()
end, { desc = "Stage hunk" })
map("n", "<leader>hr", function()
	require("gitsigns").reset_hunk()
end, { desc = "Reset hunk" })
map("n", "<leader>hp", function()
	require("gitsigns").preview_hunk()
end, { desc = "Preview hunk" })

-- Sessions and quit
map("n", "<leader>qq", "<cmd>qall<CR>", { desc = "Quit all" })
