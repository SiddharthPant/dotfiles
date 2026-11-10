-- Neovim port of ~/.vimrc, plus LSP, completion, formatting and treesitter via vim.pack.

vim.g.mapleader = ' '
vim.g.maplocalleader = ','

-- 0.12's experimental message/cmdline UI: no "Press ENTER" prompts, highlighted cmdline, pager buffer.
require('vim._core.ui2').enable({})

-- Detection must be registered before the BufReadPost autocmd below, which reads 'filetype'.
vim.cmd('filetype plugin indent on')

-- Appearance
vim.o.termguicolors = true
vim.cmd.colorscheme('lunaperche')
-- Set after the colorscheme, which may reset 'background'.
vim.o.background = 'dark'

vim.o.number = true
vim.o.relativenumber = true
vim.o.cursorline = true
vim.o.scrolloff = 10
vim.o.sidescrolloff = 10
vim.o.signcolumn = 'yes'
vim.o.showmatch = true
vim.o.listchars = 'tab:^ ,nbsp:¬,extends:»,precedes:«,trail:•'
vim.o.laststatus = 2
-- LSP progress is left to fidget, so the statusline only adds diagnostic counts.
vim.o.statusline = '%f %m%=%{% luaeval("next(vim.diagnostic.count(0)) and vim.diagnostic.status() .. \' \' or \'\'") %}%y %{&fileencoding ==# "" ? &encoding : &fileencoding}'
vim.o.winborder = 'rounded'
vim.o.pumborder = 'rounded'

-- Treesitter supplies 'foldexpr' per buffer; start with everything open and folded lines still highlighted.
vim.o.foldlevelstart = 99
vim.o.foldtext = ''

-- Editing
vim.o.backspace = 'indent,eol,start'
vim.o.autoindent = true
vim.o.shiftround = true
vim.o.linebreak = true
vim.o.breakindent = true
vim.o.confirm = true
vim.o.autoread = true
vim.o.hidden = true
vim.o.mouse = 'a'
vim.o.history = 10000

vim.o.timeout = true
vim.o.timeoutlen = 400
vim.o.ttimeoutlen = 10
vim.o.updatetime = 300

vim.o.tabstop = 2
vim.o.shiftwidth = 2
vim.o.softtabstop = -1
vim.o.expandtab = true
vim.o.smarttab = true
vim.opt.iskeyword:append('-')

vim.o.splitbelow = true
vim.o.splitright = true

vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.incsearch = true
vim.o.hlsearch = true
vim.o.wrapscan = true

-- blink.cmp drives insert completion; these still shape native <C-n>/<C-p>, which blink falls back to.
vim.o.autocompletedelay = 100
vim.o.complete = '.^5,w^5,b^5,u^5'
vim.o.completeopt = 'menu,noselect,popup,fuzzy'
vim.o.pumheight = 15

vim.keymap.set('i', '<Tab>', function() return vim.fn.pumvisible() == 1 and '<C-n>' or '<Tab>' end, { expr = true, silent = true })
vim.keymap.set('i', '<S-Tab>', function() return vim.fn.pumvisible() == 1 and '<C-p>' or '<S-Tab>' end, { expr = true, silent = true })

vim.o.wildmenu = true
vim.o.wildmode = 'noselect:lastused,full'
vim.o.wildoptions = 'fuzzy,pum'
vim.o.wildignorecase = true
vim.cmd('set wildchar=<Tab> wildcharm=<C-@>') -- <C-@> lets mappings start command-line completion.
vim.o.wildignore = '.git,.jj,node_modules,target,vendor,dist,*.o,*.swp'

vim.keymap.set('c', '<Up>', function() return vim.fn.wildmenumode() == 1 and '<C-E><Up>' or '<Up>' end, { expr = true })
vim.keymap.set('c', '<Down>', function() return vim.fn.wildmenumode() == 1 and '<C-E><Down>' or '<Down>' end, { expr = true })

vim.opt.diffopt:append({ 'algorithm:histogram', 'vertical' })

-- Backup, swap and undo files stay in Neovim's state dir so they never collide with Vim's ~/.vim ones.
vim.o.undofile = true

-- matchit, editorconfig and gc commenting are built into Neovim; these optional packages ship with it.
vim.cmd.packadd('nohlsearch') -- Clear search highlighting after 'updatetime' or on entering Insert mode.
vim.cmd.packadd('nvim.undotree') -- :Undotree
vim.cmd.packadd('nvim.difftool') -- :DiffTool for directory diffs, replacing vim-dirdiff.

-- Only over SSH, where Neovim would otherwise also try OSC 52 paste, which many terminals block.
if vim.env.SSH_TTY then
  local osc52 = require('vim.ui.clipboard.osc52')
  local function paste()
    return { vim.split(vim.fn.getreg(''), '\n'), vim.fn.getregtype('') }
  end
  vim.g.clipboard = {
    name = 'OSC 52 copy',
    copy = { ['+'] = osc52.copy('+'), ['*'] = osc52.copy('*') },
    paste = { ['+'] = paste, ['*'] = paste },
  }
end

vim.g.netrw_banner = 0
-- vim.g.netrw_liststyle = 3
-- Negative means absolute columns, so :Lexplore opens 25 columns wide.
vim.g.netrw_winsize = -25
-- netrw binds <C-h> to its hiding list unless that action has another key, which would shadow tmux
-- navigation; vim-tmux-navigator takes <C-l>, so refresh gets a key here too.
vim.keymap.set('n', '<leader>eh', '<Plug>NetrwHideEdit', { desc = 'netrw: edit hiding list' })
vim.keymap.set('n', '<leader>er', '<Plug>NetrwRefresh', { desc = 'netrw: refresh listing' })

--- Looks up vim.notify at call time so messages go through fidget once it has taken over.
local function notify(message)
  vim.notify(message)
end

local map = vim.keymap.set

map('n', 'j', function() return vim.v.count == 0 and 'gj' or 'j' end, { expr = true })
map('n', 'k', function() return vim.v.count == 0 and 'gk' or 'k' end, { expr = true })
map('n', 'n', 'nzzzv')
map('n', 'N', 'Nzzzv')
map('n', '<C-d>', '<C-d>zz')
map('n', '<C-u>', '<C-u>zz')
map('n', '<leader>zj', 'zcjzo')
map('n', '<leader>zk', 'zckzo')

map('n', 'J', function()
  local view = vim.fn.winsaveview()
  vim.cmd('normal! ' .. vim.v.count1 .. 'J')
  vim.fn.winrestview(view)
end, { silent = true, desc = 'Join lines without moving the cursor' })

map('x', '<', '<gv')
map('x', '>', '>gv')

-- Keep q safe while retaining macro recording on Q.
map('n', 'Q', 'q')
map('n', 'q', '<Nop>')

map('n', '<leader>th', function()
  vim.wo.list = not vim.wo.list
  notify('Hidden characters ' .. (vim.wo.list and 'enabled' or 'disabled'))
end, { silent = true, desc = 'Toggle hidden characters' })

local system_clipboard_copy = false

map('n', '<leader>tc', function()
  system_clipboard_copy = not system_clipboard_copy
  notify('System clipboard copy ' .. (system_clipboard_copy and 'enabled' or 'disabled'))
end, { silent = true, desc = 'Toggle copying yanks to the system clipboard' })

local function listed_buffers()
  return vim.fn.getbufinfo({ buflisted = 1 })
end

map('n', '<leader>bd', function()
  local current = vim.api.nvim_get_current_buf()
  if vim.bo.modified then
    notify('Buffer has unsaved changes')
    return
  end
  -- Put another buffer in the window first so the window survives the delete.
  if #listed_buffers() == 1 then
    vim.cmd.enew()
  else
    vim.cmd.bnext()
  end
  vim.cmd('bdelete ' .. current)
end, { silent = true, desc = 'Delete buffer, keep window' })

map('n', '<leader>bo', function()
  local current = vim.api.nvim_get_current_buf()
  local closed, modified = 0, 0
  for _, buffer in ipairs(listed_buffers()) do
    if buffer.bufnr ~= current then
      if buffer.changed == 1 then
        modified = modified + 1
      else
        vim.cmd('silent bdelete ' .. buffer.bufnr)
        closed = closed + 1
      end
    end
  end
  local message = ('Closed %d other buffer%s'):format(closed, closed == 1 and '' or 's')
  if modified > 0 then
    message = message .. ('; kept %d modified buffer%s'):format(modified, modified == 1 and '' or 's')
  end
  notify(message)
end, { silent = true, desc = 'Delete other unmodified buffers' })

-- Fuzzy file, buffer and live-grep completion on the command line, as in the vimrc.
local selected_match = ''
local allfiles = nil

local function grep_complete(arglead)
  if #arglead < 2 then
    return {}
  end
  if vim.fn.executable('rg') == 1 then
    return vim.fn.systemlist("rg --vimgrep --smart-case --hidden --glob '!.git' -- " .. vim.fn.shellescape(arglead))
  end
  return vim.fn.systemlist(
    'grep -REIHns --exclude-dir=.git --exclude-dir=.jj --exclude-dir=node_modules --exclude-dir=target --exclude="tags" --exclude="*.swp" -- '
      .. vim.fn.shellescape(arglead)
      .. ' .'
  )
end

--- Lists project files once per command-line session, preferring fd over find.
local function fuzzy_find(arglead)
  if not allfiles then
    local root = vim.g.fzfind_root or '.'
    if vim.fn.executable('fd') == 1 then
      allfiles = vim.fn.systemlist(
        'fd --color=never --hidden --type f --type l --exclude .git --exclude .jj --exclude node_modules --exclude target --exclude vendor --exclude dist . '
          .. vim.fn.shellescape(root)
      )
    else
      allfiles = vim.fn.systemlist(
        'find '
          .. vim.fn.shellescape(root)
          .. ' \\( -path "*/.git" -o -path "*/.jj" -o -path "*/node_modules" -o -path "*/target" -o -path "*/vendor" -o -path "*/dist" \\) -prune -o \\( -type f -o -type l \\) -print'
      )
    end
  end
  return arglead == '' and allfiles or vim.fn.matchfuzzy(allfiles, arglead)
end

--- Listed buffers with the alternate buffer promoted first.
local function fuzzy_buffer(arglead)
  local buffers = vim.split(vim.fn.execute('buffers', 'silent!'), '\n', { trimempty = true })
  for i, line in ipairs(buffers) do
    if line:match('^%s*%d+%s+#') then
      buffers[1], buffers[i] = buffers[i], buffers[1]
      break
    end
  end
  return arglead == '' and buffers or vim.fn.matchfuzzy(buffers, arglead)
end

--- Saves the popup selection before Neovim tears down a custom command line.
local function select_command_line_item()
  selected_match = ''
  if vim.fn.match(vim.fn.getcmdline(), [[^\s*\%(Grep\|Find\|Buffer\)\s]]) == -1 then
    return
  end
  local info = vim.fn.cmdcomplete_info()
  local pum_visible = info.pum_visible == true or info.pum_visible == 1
  if vim.tbl_isempty(info) or not pum_visible or #info.matches == 0 then
    return
  end
  -- Use the highlighted item, or the first candidate when nothing is highlighted.
  selected_match = info.selected ~= -1 and info.matches[info.selected + 1] or info.matches[1]
  vim.fn.setcmdline(info.cmdline_orig)
end

local function first_match(pattern, complete)
  if selected_match == '' and pattern ~= '' then
    selected_match = complete(pattern)[1] or ''
  end
  return selected_match
end

local function visit_grep_match(pattern)
  if first_match(pattern, grep_complete) == '' then
    notify('No grep match selected')
    return
  end
  local item = vim.fn.getqflist({ lines = { selected_match } }).items[1]
  if not item then
    notify('Could not parse grep match')
    return
  end
  if (item.bufnr or 0) == 0 or item.lnum <= 0 then
    notify('Could not open grep match')
    return
  end
  vim.cmd('buffer ' .. item.bufnr)
  vim.fn.cursor(item.lnum, math.max(item.col, 1))
  vim.bo[item.bufnr].buflisted = true
  vim.cmd('normal! zvzz')
end

local function open_selected_file(pattern)
  if first_match(pattern, fuzzy_find) ~= '' then
    vim.cmd('edit ' .. vim.fn.fnameescape(selected_match))
  end
end

local function open_selected_buffer(pattern)
  local number = first_match(pattern, fuzzy_buffer):match('^%s*(%d+)')
  if number then
    vim.cmd('buffer ' .. number)
  end
end

vim.api.nvim_create_user_command('Grep', function(o) visit_grep_match(o.args) end, { nargs = '+', complete = grep_complete })
vim.api.nvim_create_user_command('Find', function(o) open_selected_file(o.args) end, { nargs = '*', complete = fuzzy_find })
vim.api.nvim_create_user_command('Buffer', function(o) open_selected_buffer(o.args) end, { nargs = '*', complete = fuzzy_buffer })

map('n', '<leader><Space>', ':Find <C-@>')
map('n', '<leader><BS>', ':Buffer <C-@>')
map('n', '<leader>/', ':Grep <C-@>')
map('n', '<leader>?', ":Grep <C-R>=expand('<cword>')<CR><C-@>")
map('n', '<leader>fh', ':help <C-@>')

local group = vim.api.nvim_create_augroup('UserConfig', { clear = true })
local autocmd = function(event, opts)
  vim.api.nvim_create_autocmd(event, vim.tbl_extend('force', { group = group }, opts))
end

autocmd('CmdlineChanged', { pattern = { ':', '/', '?' }, callback = function() vim.fn.wildtrigger() end })
autocmd('CmdlineEnter', { pattern = ':', callback = function() allfiles = nil end })
autocmd('CmdlineLeavePre', { pattern = ':', callback = select_command_line_item })

autocmd('TextYankPost', {
  callback = function()
    vim.hl.on_yank()
    local event = vim.v.event
    if system_clipboard_copy and event.operator == 'y' and event.regname ~= '_' then
      vim.fn.setreg('+', event.regcontents, event.regtype)
    end
  end,
})

autocmd('BufReadPost', {
  desc = 'Restore the cursor to its last position',
  callback = function(ev)
    -- Diff and VCS/editing utility buffers should always use their deliberate initial position.
    if vim.wo.diff or vim.tbl_contains({ 'gitcommit', 'gitrebase', 'xxd' }, vim.bo[ev.buf].filetype) then
      return
    end
    local mark = vim.api.nvim_buf_get_mark(ev.buf, '"')
    if mark[1] > 0 and mark[1] <= vim.api.nvim_buf_line_count(ev.buf) then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

autocmd({ 'FocusGained', 'BufEnter' }, {
  callback = function()
    if vim.fn.getcmdwintype() == '' then
      vim.cmd.checktime()
    end
  end,
})

autocmd('FileType', { pattern = { 'help', 'qf' }, command = 'nnoremap <buffer> q <Cmd>close<CR>' })
autocmd('FileType', { pattern = 'gitcommit', command = 'setlocal spell' })
autocmd('FileType', { pattern = 'make', command = 'setlocal noexpandtab' })
autocmd('FileType', {
  pattern = { 'yaml', 'yml', 'json', 'lua', 'html', 'css', 'javascript', 'typescript' },
  command = 'setlocal tabstop=2 shiftwidth=2 softtabstop=-1 expandtab',
})
-- `templ fmt` writes gofmt-style tabs, and Go comments work in both Go code and component bodies.
autocmd('FileType', { pattern = 'templ', command = 'setlocal noexpandtab softtabstop=0 shiftwidth=0 commentstring=//\\ %s' })

-- Plugins

-- Must exist before vim.pack.add so it also fires on the first install.
autocmd('PackChanged', {
  callback = function(ev)
    local name, kind = ev.data.spec.name, ev.data.kind
    if name == 'nvim-treesitter' and kind == 'update' then
      if not ev.data.active then
        vim.cmd.packadd('nvim-treesitter')
      end
      vim.cmd('TSUpdate')
    end
  end,
})

local function gh(repo)
  return 'https://github.com/' .. repo
end

vim.pack.add({
  gh('neovim/nvim-lspconfig'),
  gh('mason-org/mason.nvim'),
  gh('mason-org/mason-lspconfig.nvim'),
  gh('WhoIsSethDaniel/mason-tool-installer.nvim'),
  gh('folke/lazydev.nvim'),
  gh('rafamadriz/friendly-snippets'),
  -- Release tags ship a prebuilt fuzzy matcher; a branch would need a Rust build.
  { src = gh('saghen/blink.cmp'), version = vim.version.range('1.*') },
  gh('stevearc/conform.nvim'),
  { src = gh('nvim-treesitter/nvim-treesitter'), version = 'main' },
  gh('j-hui/fidget.nvim'),
  gh('folke/which-key.nvim'),
  gh('folke/flash.nvim'),
  { src = gh('jake-stewart/multicursor.nvim'), version = '1.0' },
  gh('stevearc/oil.nvim'),
  { src = gh('nvim-treesitter/nvim-treesitter-textobjects'), version = 'main' },
  gh('nvim-lua/plenary.nvim'),
  gh('m00qek/baleia.nvim'),
  gh('ej-shafran/compile-mode.nvim'),
  gh('lewis6991/gitsigns.nvim'),
  gh('dlyongemallo/diffview-plus.nvim'),
  gh('NeogitOrg/neogit'),
  -- <C-h/j/k/l> and <C-\> move across Neovim splits and tmux panes; .tmux.conf holds the other half.
  gh('christoomey/vim-tmux-navigator'),
})

-- Notifications and LSP progress in a corner overlay, instead of the message area.
require('fidget').setup({ notification = { override_vim_notify = true } })

-- Treesitter

local parsers = {
  'bash', 'css', 'diff', 'fish', 'git_config', 'gitcommit', 'go', 'gomod', 'gosum', 'gowork',
  'html', 'javascript', 'json', 'lua', 'luadoc', 'markdown', 'markdown_inline', 'python', 'query',
  'rust', 'templ', 'toml', 'tsx', 'typescript', 'vim', 'vimdoc', 'yaml',
}
require('nvim-treesitter').install(parsers)

autocmd('FileType', {
  callback = function(ev)
    local lang = vim.treesitter.language.get_lang(ev.match)
    if not lang or not pcall(vim.treesitter.start, ev.buf, lang) then
      return
    end
    -- Treesitter indent is experimental, so only fill in where no indent script already applies (e.g. templ).
    if vim.bo[ev.buf].indentexpr == '' and vim.treesitter.query.get(lang, 'indents') then
      vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end
    if vim.treesitter.query.get(lang, 'folds') then
      vim.wo[0][0].foldmethod = 'expr'
      vim.wo[0][0].foldexpr = 'v:lua.vim.treesitter.foldexpr()'
    end
    if vim.treesitter.query.get(lang, 'textobjects') then
      local function bmap(mode, lhs, rhs, desc)
        map(mode, lhs, rhs, { buffer = ev.buf, desc = desc })
      end
      for key, capture in pairs({
        af = '@function.outer',
        ['if'] = '@function.inner',
        aa = '@parameter.outer',
        ia = '@parameter.inner',
        ac = '@class.outer',
        ic = '@class.inner',
      }) do
        bmap({ 'x', 'o' }, key, function()
          require('nvim-treesitter-textobjects.select').select_textobject(capture, 'textobjects')
        end, 'Select ' .. capture:sub(2))
      end
      bmap('n', '<leader>a', function() require('nvim-treesitter-textobjects.swap').swap_next('@parameter.inner') end, 'Swap argument with next')
      bmap('n', '<leader>A', function() require('nvim-treesitter-textobjects.swap').swap_previous('@parameter.inner') end, 'Swap argument with previous')
      for key, method in pairs({
        [']f'] = 'goto_next_start',
        ['[f'] = 'goto_previous_start',
        [']F'] = 'goto_next_end',
        ['[F'] = 'goto_previous_end',
      }) do
        bmap({ 'n', 'x', 'o' }, key, function()
          require('nvim-treesitter-textobjects.move')[method]('@function.outer', 'textobjects')
        end, method:gsub('_', ' ') .. ' function')
      end
    end
  end,
})

require('nvim-treesitter-textobjects').setup({
  select = { lookahead = true },
  move = { set_jumps = true },
})

-- LSP

require('lazydev').setup({
  library = { { path = '${3rd}/luv/library', words = { 'vim%.uv' } } },
})

require('mason').setup()
-- Servers installed through Mason are enabled automatically; stylua is only wanted as conform's formatter.
require('mason-lspconfig').setup({ automatic_enable = { exclude = { 'stylua' } } })
require('mason-tool-installer').setup({
  ensure_installed = {
    'basedpyright', 'bashls', 'cssls', 'html', 'jsonls', 'lua_ls', 'rust_analyzer', 'taplo', 'ts_ls', 'yamlls',
    'prettier', 'shfmt', 'stylua',
  },
})
-- templ comes from each project's mise pin so the LSP matches the generated code; the rest from Homebrew.
vim.lsp.enable({ 'gopls', 'templ', 'ruff', 'golangci_lint_ls' })

-- Tag and attribute completion inside templ components; the templ server only covers the Go side.
vim.lsp.config('html', { filetypes = { 'html', 'templ' } })

vim.lsp.config('gopls', {
  settings = {
    gopls = {
      -- staticcheck stays at gopls's default subset: golangci-lint runs the full suite on save,
      -- and enabling it here too would report every finding twice.
      semanticTokens = true,
      -- Shown only while inlay hints are toggled on with <leader>ti.
      hints = {
        assignVariableTypes = true,
        compositeLiteralFields = true,
        compositeLiteralTypes = true,
        constantValues = true,
        functionTypeParameters = true,
        parameterNames = true,
        rangeVariableTypes = true,
      },
      -- "run test" is the only lens gopls leaves off; generate, tidy and upgrade are on already.
      codelenses = { test = true },
    },
  },
})

vim.diagnostic.config({
  severity_sort = true,
  underline = { severity = vim.diagnostic.severity.ERROR },
  virtual_text = { source = 'if_many', spacing = 2 },
  float = { source = 'if_many' },
})

-- Neovim already maps grn, gra, grr, gri, grt, gO, K, [d and ]d, and highlights LSP document colors.
autocmd('LspAttach', {
  callback = function(ev)
    local client = assert(vim.lsp.get_client_by_id(ev.data.client_id))
    map('n', 'gd', vim.lsp.buf.definition, { buffer = ev.buf, desc = 'Go to definition' })
    map('n', 'gD', vim.lsp.buf.declaration, { buffer = ev.buf, desc = 'Go to declaration' })
    -- basedpyright gives the richer hover for Python.
    if client.name == 'ruff' then
      client.server_capabilities.hoverProvider = false
    end
    -- Lenses such as "run test" and "go mod tidy"; grx runs the one on the cursor line.
    if client.name == 'gopls' then
      vim.lsp.codelens.enable(true, { bufnr = ev.buf })
    end
    -- Renaming an HTML/templ open tag also renames its closing tag.
    if client:supports_method('textDocument/linkedEditingRange') then
      vim.lsp.linked_editing_range.enable(true, { client_id = client.id })
    end
  end,
})

map('n', '<leader>ti', function()
  local enabled = not vim.lsp.inlay_hint.is_enabled({ bufnr = 0 })
  vim.lsp.inlay_hint.enable(enabled, { bufnr = 0 })
  notify('Inlay hints ' .. (enabled and 'enabled' or 'disabled'))
end, { desc = 'Toggle inlay hints' })

-- Completion

-- Off by default, as in the vimrc; <C-Space> or <C-n> opens the menu on demand.
vim.g.autocomplete = false

require('blink.cmp').setup({
  keymap = {
    preset = 'default',
    ['<C-n>'] = { 'show', 'select_next', 'fallback' },
    ['<Tab>'] = { 'select_next', 'snippet_forward', 'fallback' },
    ['<S-Tab>'] = { 'select_prev', 'snippet_backward', 'fallback' },
  },
  completion = {
    menu = { auto_show = function() return vim.g.autocomplete end },
    list = { selection = { preselect = false, auto_insert = true } },
    documentation = { auto_show = true, auto_show_delay_ms = 200 },
  },
  sources = {
    default = { 'lsp', 'path', 'snippets', 'buffer' },
    per_filetype = { lua = { inherit_defaults = true, 'lazydev' } },
    providers = {
      lazydev = { name = 'LazyDev', module = 'lazydev.integrations.blink', score_offset = 100 },
    },
  },
  signature = { enabled = true },
  -- The command line keeps the native wildmenu that :Find, :Buffer and :Grep rely on.
  cmdline = { enabled = false },
  fuzzy = { implementation = 'prefer_rust_with_warning' },
})

map('n', '<leader>ta', function()
  vim.g.autocomplete = not vim.g.autocomplete
  notify('Autocomplete ' .. (vim.g.autocomplete and 'enabled' or 'disabled'))
end, { desc = 'Toggle completion menu auto-show' })

-- Formatting

require('conform').setup({
  formatters_by_ft = {
    lua = { 'stylua' },
    -- A project with a golangci-lint config gets the formatters it enables there, so saving matches
    -- what its lint step checks. Elsewhere goimports gives gofmt plus import fixing.
    go = function(bufnr)
      local has_config = vim.fs.root(bufnr, { '.golangci.yml', '.golangci.yaml', '.golangci.toml', '.golangci.json' })
      return { has_config and 'golangci-lint' or 'goimports' }
    end,
    templ = { 'templ' },
    python = { 'ruff_organize_imports', 'ruff_format' },
    rust = { 'rustfmt' },
    javascript = { 'prettier' },
    typescript = { 'prettier' },
    javascriptreact = { 'prettier' },
    typescriptreact = { 'prettier' },
    css = { 'prettier' },
    html = { 'prettier' },
    json = { 'prettier' },
    yaml = { 'prettier' },
    markdown = { 'prettier' },
    sh = { 'shfmt' },
    bash = { 'shfmt' },
    fish = { 'fish_indent' },
    toml = { 'taplo' },
  },
  default_format_opts = { lsp_format = 'fallback' },
  format_on_save = function(buf)
    if vim.g.disable_autoformat or vim.b[buf].disable_autoformat then
      return nil
    end
    return { timeout_ms = 500 }
  end,
})
vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"

map({ 'n', 'x' }, '<leader>cf', function() require('conform').format({ async = true }) end, { desc = 'Format buffer or selection' })
map('n', '<leader>tf', function()
  vim.g.disable_autoformat = not vim.g.disable_autoformat
  notify('Format on save ' .. (vim.g.disable_autoformat and 'disabled' or 'enabled'))
end, { desc = 'Toggle format on save' })

-- Navigation and editing

-- Files as an editable buffer on `-`; netrw stays the handler for directories and :Explore.
-- Oil's <C-h> (horizontal split) and <C-l> (refresh) would shadow tmux navigation in its buffers.
require('oil').setup({ default_file_explorer = false, keymaps = { ['<C-h>'] = false, ['<C-l>'] = false } })
map('n', '-', '<Cmd>Oil<CR>', { desc = 'Open parent directory in oil' })

map('n', '<leader>u', '<Cmd>Undotree<CR>', { desc = 'Toggle undo tree' })

-- f/t/;/, keep their Vim behaviour; flash only owns its own keys.
require('flash').setup({ modes = { char = { enabled = false } } })
map({ 'n', 'x', 'o' }, 's', function() require('flash').jump() end, { desc = 'Flash jump' })
map({ 'n', 'x', 'o' }, 'S', function() require('flash').treesitter() end, { desc = 'Flash treesitter select' })
map('o', 'r', function() require('flash').remote() end, { desc = 'Flash remote operation' })
map({ 'o', 'x' }, 'R', function() require('flash').treesitter_search() end, { desc = 'Flash treesitter search' })
map('c', '<C-s>', function() require('flash').toggle() end, { desc = 'Toggle flash labels in search' })

local mc = require('multicursor-nvim')
mc.setup()
map({ 'n', 'x' }, '<Up>', function() mc.lineAddCursor(-1) end, { desc = 'Add cursor above' })
map({ 'n', 'x' }, '<Down>', function() mc.lineAddCursor(1) end, { desc = 'Add cursor below' })
map({ 'n', 'x' }, '<leader><Up>', function() mc.lineSkipCursor(-1) end, { desc = 'Skip line above' })
map({ 'n', 'x' }, '<leader><Down>', function() mc.lineSkipCursor(1) end, { desc = 'Skip line below' })
map({ 'n', 'x' }, '<leader>n', function() mc.matchAddCursor(1) end, { desc = 'Add cursor at next match' })
map({ 'n', 'x' }, '<leader>N', function() mc.matchAddCursor(-1) end, { desc = 'Add cursor at previous match' })
map({ 'n', 'x' }, '<leader>s', function() mc.matchSkipCursor(1) end, { desc = 'Skip next match' })
map({ 'n', 'x' }, '<leader>S', function() mc.matchSkipCursor(-1) end, { desc = 'Skip previous match' })
map({ 'n', 'x' }, '<leader>m', mc.matchAllAddCursors, { desc = 'Add cursors at all matches' })
map({ 'n', 'x' }, '<C-q>', mc.toggleCursor, { desc = 'Toggle cursor' })
map('n', '<C-LeftMouse>', mc.handleMouse)
map('n', '<C-LeftDrag>', mc.handleMouseDrag)
map('n', '<C-LeftRelease>', mc.handleMouseRelease)
-- These only exist while there is more than one cursor.
mc.addKeymapLayer(function(layer)
  layer({ 'n', 'x' }, '<Left>', mc.prevCursor)
  layer({ 'n', 'x' }, '<Right>', mc.nextCursor)
  layer({ 'n', 'x' }, '<leader>x', mc.deleteCursor)
  layer('n', '<Esc>', function()
    if mc.cursorsEnabled() then
      mc.clearCursors()
    else
      mc.enableCursors()
    end
  end)
end)
vim.api.nvim_set_hl(0, 'MultiCursorCursor', { reverse = true, default = true })
vim.api.nvim_set_hl(0, 'MultiCursorVisual', { link = 'Visual', default = true })
vim.api.nvim_set_hl(0, 'MultiCursorSign', { link = 'SignColumn', default = true })
vim.api.nvim_set_hl(0, 'MultiCursorMatchPreview', { link = 'Search', default = true })
vim.api.nvim_set_hl(0, 'MultiCursorDisabledCursor', { reverse = true, default = true })
vim.api.nvim_set_hl(0, 'MultiCursorDisabledVisual', { link = 'Visual', default = true })
vim.api.nvim_set_hl(0, 'MultiCursorDisabledSign', { link = 'SignColumn', default = true })

-- Git

require('gitsigns').setup({
  on_attach = function(buf)
    local gs = require('gitsigns')
    local function bmap(mode, lhs, rhs, desc)
      map(mode, lhs, rhs, { buffer = buf, desc = desc })
    end
    -- In diff mode ]c/[c keep their built-in meaning.
    bmap('n', ']c', function()
      if vim.wo.diff then
        vim.cmd.normal({ ']c', bang = true })
      else
        gs.nav_hunk('next')
      end
    end, 'Next hunk')
    bmap('n', '[c', function()
      if vim.wo.diff then
        vim.cmd.normal({ '[c', bang = true })
      else
        gs.nav_hunk('prev')
      end
    end, 'Previous hunk')
    bmap('n', '<leader>gs', gs.stage_hunk, 'Stage or unstage hunk')
    bmap('n', '<leader>gr', gs.reset_hunk, 'Reset hunk')
    bmap('x', '<leader>gs', function() gs.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') }) end, 'Stage selected lines')
    bmap('x', '<leader>gr', function() gs.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') }) end, 'Reset selected lines')
    bmap('n', '<leader>go', gs.preview_hunk_inline, 'Preview hunk inline')
    bmap('n', '<leader>gb', function() gs.blame_line({ full = true }) end, 'Blame line')
    bmap({ 'o', 'x' }, 'ih', gs.select_hunk, 'Select hunk')
  end,
})

local close_diffview = '<Cmd>DiffviewClose<CR>'
require('diffview').setup({
  -- Tried first, so colocated jj repos show jj changes; plain git repos still work.
  preferred_adapter = 'jj',
  use_icons = false,
  keymaps = {
    view = { { 'n', 'q', close_diffview, { desc = 'Close Diffview' } } },
    file_panel = { { 'n', 'q', close_diffview, { desc = 'Close Diffview' } } },
    file_history_panel = { { 'n', 'q', close_diffview, { desc = 'Close Diffview' } } },
  },
})
map('n', '<leader>gd', '<Cmd>DiffviewToggle<CR>', { desc = 'Toggle Diffview' })
map('n', '<leader>gh', '<Cmd>DiffviewFileHistory %<CR>', { desc = 'File history' })
map('x', '<leader>gh', ':DiffviewFileHistory<CR>', { desc = 'History of selected lines' })

require('neogit').setup({ integrations = { diffview = true } })
map('n', '<leader>gg', '<Cmd>Neogit<CR>', { desc = 'Neogit status' })

-- Build

vim.g.baleia = require('baleia').setup({})
vim.api.nvim_create_user_command('BaleiaColorize', function() vim.g.baleia.once(vim.api.nvim_get_current_buf()) end, {})

vim.g.compile_mode = {
  default_command = 'mise lint',
  ansi_color = { kind = 'render', baleia_options = {} },
  recompile_no_fail = true,
  ask_to_interrupt = false,
  use_circular_error_navigation = true,
  -- Cargo strips colours when it isn't writing to a terminal; baleia renders them.
  environment = { CARGO_TERM_COLOR = 'always' },
  error_regexp_table = {
    rust = {
      regex = [[^\s*-->\s\+\(.\+\):\([0-9]\+\):\([0-9]\+\)$]],
      filename = 1,
      row = 2,
      col = 3,
    },
  },
}
map('n', '<leader>cc', '<Cmd>Compile<CR>', { desc = 'Compile' })
map('n', '<leader>cr', '<Cmd>Recompile<CR>', { desc = 'Recompile' })
map('n', ']e', '<Cmd>NextError<CR>', { desc = 'Next compile error' })
map('n', '[e', '<Cmd>PrevError<CR>', { desc = 'Previous compile error' })

require('which-key').setup({
  spec = {
    { '<leader>b', group = 'buffer' },
    { '<leader>c', group = 'code' },
    { '<leader>f', group = 'find' },
    { '<leader>g', group = 'git' },
    { '<leader>t', group = 'toggle' },
    { '<leader>z', group = 'fold' },
    { 'gr', group = 'lsp' },
  },
})
