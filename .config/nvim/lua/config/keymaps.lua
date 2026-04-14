vim.g.mapleader = " " -- space for leader
vim.g.maplocalleader = " " -- space for localleader

-- better movement in wrapped text
vim.keymap.set("n", "j", function()
	return vim.v.count == 0 and "gj" or "j"
end, { expr = true, silent = true, desc = "Down (wrap-aware)" })
vim.keymap.set("n", "k", function()
	return vim.v.count == 0 and "gk" or "k"
end, { expr = true, silent = true, desc = "Up (wrap-aware)" })

vim.keymap.set("n", "n", "nzzzv", { desc = "Next search result (centered)" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Previous search result (centered)" })
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Half page down (centered)" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Half page up (centered)" })
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR><Esc>", { silent = true, desc = "Escape and clear search highlight" })
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
vim.keymap.set("n", "]d", function()
	vim.diagnostic.jump({ count = 1 })
end, { desc = "Next diagnostic" })
vim.keymap.set("n", "[d", function()
	vim.diagnostic.jump({ count = -1 })
end, { desc = "Previous diagnostic" })

vim.keymap.set("x", "<leader>p", '"_dP', { desc = "Paste without yanking" })
vim.keymap.set("n", "<leader>x", function()
	require("snacks").bufdelete()
end, { desc = "Delete Buffer" })

vim.keymap.set("n", "<leader>bl", "<cmd>BufferLineCloseLeft<CR>", { desc = "Delete buffers to the left" })
vim.keymap.set("n", "<leader>br", "<cmd>BufferLineCloseRight<CR>", { desc = "Delete buffers to the right" })
vim.keymap.set("n", "<leader>bo", "<cmd>BufferLineCloseOthers<CR>", { desc = "Delete other buffers" })

-- Tmux Navigator - seamless navigation between Neovim and tmux panes
vim.keymap.set("n", "<C-h>", "<cmd>TmuxNavigateLeft<cr>", { desc = "Navigate left (tmux aware)" })
vim.keymap.set("n", "<C-j>", "<cmd>TmuxNavigateDown<cr>", { desc = "Navigate down (tmux aware)" })
vim.keymap.set("n", "<C-k>", "<cmd>TmuxNavigateUp<cr>", { desc = "Navigate up (tmux aware)" })
vim.keymap.set("n", "<C-l>", "<cmd>TmuxNavigateRight<cr>", { desc = "Navigate right (tmux aware)" })

vim.keymap.set("n", "<leader>sv", ":vsplit<CR>", { desc = "Split window vertically" })
vim.keymap.set("n", "<leader>sh", ":split<CR>", { desc = "Split window horizontally" })
vim.keymap.set("n", "<C-Up>", ":resize +2<CR>", { desc = "Increase window height" })
vim.keymap.set("n", "<C-Down>", ":resize -2<CR>", { desc = "Decrease window height" })
vim.keymap.set("n", "<C-Left>", ":vertical resize -2<CR>", { desc = "Decrease window width" })
vim.keymap.set("n", "<C-Right>", ":vertical resize +2<CR>", { desc = "Increase window width" })

vim.keymap.set("n", "<A-j>", ":m .+1<CR>==", { desc = "Move line down" })
vim.keymap.set("n", "<A-k>", ":m .-2<CR>==", { desc = "Move line up" })
vim.keymap.set("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
vim.keymap.set("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

vim.keymap.set("v", "<", "<gv", { desc = "Indent left and reselect" })
vim.keymap.set("v", ">", ">gv", { desc = "Indent right and reselect" })

vim.keymap.set("n", "J", "mzJ`z", { desc = "Join lines and keep cursor position" })

vim.keymap.set("n", "<leader>pa", function() -- show file path
	local path = vim.fn.expand("%:p")
	vim.fn.setreg("+", path)
	print("file:", path)
end, { desc = "Copy full file path" })

vim.keymap.set("n", "<leader>td", function()
	local enabled = vim.diagnostic.is_enabled()
	vim.diagnostic.enable(not enabled)
	require("snacks").notify(enabled and "Diagnostics disabled" or "Diagnostics enabled", {
		title = "LSP Diagnostics",
		icon = enabled and "🚫" or "🩺",
		level = "info",
	})
end, { desc = "Toggle diagnostics" })

-- Yank to system clipboard (visual and normal mode)
vim.keymap.set({ "n", "v" }, "<leader>y", '"+y', { desc = "Yank to system clipboard" })
vim.keymap.set("n", "<leader>Y", '"+Y', { desc = "Yank line to system clipboard" })

-- Delete to system clipboard
vim.keymap.set({ "n", "v" }, "<leader>d", '"+d', { desc = "Delete to system clipboard" })
vim.keymap.set("n", "<leader>D", '"+D', { desc = "Delete line to system clipboard" })

-- Snacks Explorer (replaces nvim-tree)
vim.keymap.set("n", "<leader>e", function()
	require("snacks").explorer()
end, { desc = "Toggle Explorer" })

-- Snacks Picker (replaces fzf-lua)
local function find_files()
	require("snacks").picker.files()
end

vim.keymap.set("n", "<leader><leader>", find_files, { desc = "Find Files" })
vim.keymap.set("n", "<leader>ff", find_files, { desc = "Find Files" })
vim.keymap.set("n", "<leader>fo", function()
	require("snacks").picker.recent()
end, { desc = "Find Old Files" })
vim.keymap.set("n", "<leader>fg", function()
	require("snacks").picker.grep()
end, { desc = "Live Grep" })
vim.keymap.set("n", "<leader>fb", function()
	require("snacks").picker.buffers()
end, { desc = "Find Buffers" })
vim.keymap.set("n", "<leader>fh", function()
	require("snacks").picker.help()
end, { desc = "Find Help" })
vim.keymap.set("n", "<leader>fk", function()
	require("snacks").picker.keymaps()
end, { desc = "Find Keymaps" })
vim.keymap.set("n", "<leader>fx", function()
	require("snacks").picker.diagnostics_buffer()
end, { desc = "Find Diagnostics (Buffer)" })
vim.keymap.set("n", "<leader>fX", function()
	require("snacks").picker.diagnostics()
end, { desc = "Find Diagnostics (Workspace)" })

-- Snacks Git
vim.keymap.set("n", "<leader>gb", function()
	require("snacks").git.blame_line()
end, { desc = "Git Blame Line" })
vim.keymap.set("n", "<leader>gB", function()
	require("snacks").gitbrowse()
end, { desc = "Git Browse" })

-- Snacks Buffer Delete (replaces mini.bufremove)
vim.keymap.set("n", "<leader>bd", function()
	require("snacks").bufdelete()
end, { desc = "Delete Buffer" })

-- Snacks Notifications
vim.keymap.set("n", "<leader>fn", function()
	require("snacks").notifier.show_history()
end, { desc = "Show Notifications" })

-- Close current buffer with leader + bc (buffer close)
vim.keymap.set("n", "<leader>bc", function()
	local current = vim.api.nvim_get_current_buf()
	local buffers = vim.tbl_filter(function(buf)
		return vim.bo[buf].buflisted and vim.api.nvim_buf_is_valid(buf)
	end, vim.api.nvim_list_bufs())

	local next_buf = nil
	for i, buf in ipairs(buffers) do
		if buf == current then
			next_buf = buffers[i + 1] or buffers[i - 1]
			break
		end
	end

	if next_buf and next_buf ~= current then
		vim.api.nvim_set_current_buf(next_buf)
	elseif #buffers > 1 then
		for _, buf in ipairs(buffers) do
			if buf ~= current then
				vim.api.nvim_set_current_buf(buf)
				break
			end
		end
	end

	local ok, snacks = pcall(require, "snacks")
	if ok then
		snacks.bufdelete({ buf = current })
	else
		vim.cmd("bdelete! " .. current)
	end
end, { desc = "Close current buffer" })

-- Tab navigation keymaps
vim.keymap.set("n", "<Tab>", ":bnext<CR>", { silent = true, desc = "Next buffer" })
vim.keymap.set("n", "<S-Tab>", ":bprevious<CR>", { silent = true, desc = "Previous buffer" })

-- Keep ]h/[h consistent everywhere; plain diff windows still use Vim's native motions underneath.
local function nav_hunk(direction, diff_key)
	if vim.wo.diff then
		vim.cmd.normal({ diff_key, bang = true })
		return
	end
	require("gitsigns").nav_hunk(direction)
end

vim.keymap.set("n", "]h", function()
	nav_hunk("next", "]c")
end, { desc = "Next git hunk" })
vim.keymap.set("n", "[h", function()
	nav_hunk("prev", "[c")
end, { desc = "Previous git hunk" })
vim.keymap.set("n", "]H", function()
	require("gitsigns").nav_hunk("last")
end, { desc = "Last git hunk" })
vim.keymap.set("n", "[H", function()
	require("gitsigns").nav_hunk("first")
end, { desc = "First git hunk" })
vim.keymap.set("n", "<leader>hs", function()
	require("gitsigns").stage_hunk()
end, { desc = "Stage hunk" })
vim.keymap.set("n", "<leader>hr", function()
	require("gitsigns").reset_hunk()
end, { desc = "Reset hunk" })
vim.keymap.set("n", "<leader>hp", function()
	require("gitsigns").preview_hunk()
end, { desc = "Preview hunk" })
vim.keymap.set("n", "<leader>hb", function()
	require("gitsigns").blame_line({ full = true })
end, { desc = "Blame line" })
vim.keymap.set("n", "<leader>hB", function()
	require("gitsigns").toggle_current_line_blame()
end, { desc = "Toggle inline blame" })
vim.keymap.set("n", "<leader>uG", function()
	local config = require("gitsigns.config").config
	require("gitsigns").toggle_signs(not config.signcolumn)
end, { desc = "Toggle git signs" })
vim.keymap.set("n", "<leader>uu", "<cmd>UndotreeToggle<CR>", { desc = "Toggle undo tree" })
vim.keymap.set("n", "<leader>gs", function()
	require("snacks").picker.git_status()
end, { desc = "Git status (all files with diff)" })
vim.keymap.set("n", "<leader>gd", ":CodeDiff<cr>", { desc = "Git diff view (codediff)" })
vim.keymap.set("n", "<leader>gg", function()
	require("snacks").lazygit()
end, { desc = "Open lazygit" })

-- Supermaven toggle (blink.cmp unaffected)
vim.keymap.set("n", "<leader>ts", function()
	vim.cmd("SupermavenToggle")
	local api = require("supermaven-nvim.api")
	local is_running = api.is_running()
	require("snacks").notify(is_running and "Supermaven AI enabled" or "Supermaven AI disabled", {
		title = "Supermaven",
		icon = is_running and "✨" or "🚫",
		level = "info",
	})
end, { desc = "Toggle Supermaven AI suggestions" })
