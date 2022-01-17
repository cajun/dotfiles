-- this will bootstrap Packer
local install_path = vim.fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
	packer_bootstrap = fn.system({
		"git",
		"clone",
		"--depth",
		"1",
		"https://github.com/wbthomason/packer.nvim",
		install_path,
	})
end

require("packer").startup(function(use)
	-- Packer can manage itself
	use("wbthomason/packer.nvim")

	-- The tpope
	use("tpope/vim-surround")
	use("tpope/vim-commentary")
	use("tpope/vim-rails")
	use("tpope/vim-unimpaired")
	use("tpope/vim-fugitive")

	use("neovim/nvim-lspconfig")
	use("nvim-lua/lsp-status.nvim")
	use("mhartington/formatter.nvim")
	use("simrat39/rust-tools.nvim")
	use({ "nvim-treesitter/nvim-treesitter", run = ":TSUpdate" })
	use("nvim-treesitter/nvim-treesitter-textobjects")
	use("williamboman/nvim-lsp-installer")

	use({ "ms-jpq/coq_nvim", branch = "coq" })
	use({ "ms-jpq/coq.artifacts", branch = "artifacts" })
	use({ "ms-jpq/chadtree", branch = "chad", run = "python3 -m chadtree deps" })

	use({ "ibhagwan/fzf-lua", requires = { "kyazdani42/nvim-web-devicons" } })
	use({ "junegunn/fzf", run = "./install --bin" })
	use({ "lewis6991/gitsigns.nvim", requires = { "nvim-lua/plenary.nvim" } })
	use("ggandor/lightspeed.nvim")

	use({ "nvim-lualine/lualine.nvim", requires = { "kyazdani42/nvim-web-devicons", opt = true } })
	use("rebelot/kanagawa.nvim")

	use("SmiteshP/nvim-gps")

	-- Automatically set up your configuration after cloning packer.nvim
	-- Put this at the end after all plugins
	if packer_bootstrap then
		require("packer").sync()
	end
end)

-- Settings
vim.api.nvim_set_keymap("", "<Space>", "<Nop>", { noremap = true, silent = true })
vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.o.wrap = false
vim.o.splitright = true
vim.o.cursorline = true
vim.o.relativenumber = true
vim.o.list = true
vim.o.undodir = vim.fn.stdpath("config") .. "/undo"
vim.o.backupdir = vim.fn.stdpath("config") .. "/backup"
vim.o.directory = vim.fn.stdpath("config") .. "/swap"
vim.o.swapfile = true
vim.o.undofile = true
vim.o.backup = true
vim.o.undolevels = 1000
vim.o.undoreload = 10000
vim.o.termguicolors = true
vim.cmd([[colorscheme kanagawa ]])

vim.cmd([[
  augroup TrimWhitespace
    autocmd!
    autocmd BufWritePre * :%s/\s\+$//e
  augroup end
]])

-- Coq
vim.g.coq_settings = { auto_start = "shut-up", clients = { tabnine = { enabled = true } } }

-- Helper for keymaps
local map = vim.api.nvim_set_keymap

-- LSP Installer
local lsp_installer = require("nvim-lsp-installer")

-- Include the servers you want to have installed by default below
local servers = {
	"bashls",
	"cssls",
	"dockerls",
	"html",
	"jsonls",
	"pyright",
	"rome",
	"rust_analyzer",
	"taplo",
	"sumneko_lua",
}

local lsp_status = require("lsp-status")
lsp_status.register_progress()

local on_attach = function(client, bufnr)
	lsp_status.on_attach(client)
	local opts = { noremap = true, silent = true }
	vim.api.nvim_buf_set_keymap(bufnr, "n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>", opts)
	vim.api.nvim_buf_set_keymap(bufnr, "n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", opts)
	vim.api.nvim_buf_set_keymap(bufnr, "n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", opts)
	vim.api.nvim_buf_set_keymap(bufnr, "n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts)
	vim.api.nvim_buf_set_keymap(bufnr, "n", "<C-k>", "<cmd>lua vim.lsp.buf.signature_help()<CR>", opts)
	vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>wa", "<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>", opts)
	vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>wr", "<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>", opts)
	vim.api.nvim_buf_set_keymap(
		bufnr,
		"n",
		"<leader>wl",
		"<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>",
		opts
	)
	vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>D", "<cmd>lua vim.lsp.buf.type_definition()<CR>", opts)
	vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>rn", "<cmd>lua vim.lsp.buf.rename()<CR>", opts)
	vim.api.nvim_buf_set_keymap(bufnr, "n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>", opts)
	vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>", opts)
	vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>e", "<cmd>lua vim.diagnostic.open_float()<CR>", opts)
	vim.api.nvim_buf_set_keymap(bufnr, "n", "[d", "<cmd>lua vim.diagnostic.goto_prev()<CR>", opts)
	vim.api.nvim_buf_set_keymap(bufnr, "n", "]d", "<cmd>lua vim.diagnostic.goto_next()<CR>", opts)
	vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>q", "<cmd>lua vim.diagnostic.setloclist()<CR>", opts)
end

-- Setting up rust
require("rust-tools").setup({
	tools = {
		autoSetHints = true,
		hover_with_actions = true,
		inlay_hints = {
			show_parameter_hints = false,
			parameter_hints_prefix = "",
			other_hints_prefix = "",
		},
	},
	server = {
		settings = {
			["rust-analyzer"] = {
				cargo = { loadOutDirsFromCheck = true },
				checkOnSave = { command = "clippy" },
			},
		},
	},
})

for _, name in pairs(servers) do
	local server_is_found, server = lsp_installer.get_server(name)
	if server_is_found then
		if not server:is_installed() then
			print("Installing " .. name)
			server:install()
		end
	end
end

lsp_installer.on_server_ready(function(server)
	local opts = { on_attach = on_attach, capabibilities = lsp_status.capabibilities }
	server:setup(require("coq").lsp_ensure_capabilities(opts))
end)

-- Treesitter
require("nvim-treesitter.configs").setup({
	ensure_installed = "maintained",
	highlight = { enable = true },
	indent = { enable = true },
	incremental_selection = { enable = true },
})

-- CHADtree
map("n", "<leader>v", "<cmd>CHADopen<cr>", {})

-- fzf-lua
map("n", "<leader><space>", [[<cmd>lua require('fzf-lua').buffers()<CR>]], { noremap = true, silent = true })
map("n", "<leader>sf", [[<cmd>lua require('fzf-lua').files()<CR>]], { noremap = true, silent = true })
map("n", "<leader>sb", [[<cmd>lua require('fzf-lua').blines()<CR>]], { noremap = true, silent = true })
map("n", "<leader>sh", [[<cmd>lua require('fzf-lua').help_tags()<CR>]], { noremap = true, silent = true })
map("n", "<leader>sk", [[<cmd>lua require('fzf-lua').keymaps()<CR>]], { noremap = true, silent = true })
map("n", "<leader>sd", [[<cmd>lua require('fzf-lua').grep()<CR>]], { noremap = true, silent = true })
map("n", "<leader>sp", [[<cmd>lua require('fzf-lua').live_grep()<CR>]], { noremap = true, silent = true })
map("n", "<leader>sg", [[<cmd>lua require('fzf-lua').git_commits()<CR>]], { noremap = true, silent = true })
map("n", "<leader>?", [[<cmd>lua require('fzf-lua').lsp_definitions()<CR>]], { noremap = true, silent = true })

-- Gisigns
require("gitsigns").setup()

-- Formatter
require("formatter").setup({
	filetype = {
		javascript = {
			-- prettier
			function()
				return {
					exe = "prettier",
					args = { "--stdin-filepath", vim.fn.fnameescape(vim.api.nvim_buf_get_name(0)), "--single-quote" },
					stdin = true,
				}
			end,
		},
		rust = {
			-- Rustfmt
			function()
				return {
					exe = "rustfmt",
					args = { "--emit=stdout" },
					stdin = true,
				}
			end,
		},
		sh = {
			-- Shell Script Formatter
			function()
				return {
					exe = "shfmt",
					args = { "-i", 2 },
					stdin = true,
				}
			end,
		},
		lua = {
			function()
				return {
					exe = "stylua",
					args = {
						"--config-path " .. "~/.config/" .. "/stylua/stylua.toml",
						"-",
					},
					stdin = true,
				}
			end,
		},
		ruby = {
			-- rubocop
			function()
				return {
					exe = "rubocop", -- might prepend `bundle exec `
					args = {
						"--auto-correct",
						"--stdin",
						"%:p",
						"2>/dev/null",
						"|",
						"awk 'f; /^====================$/{f=1}'",
					},
					stdin = true,
				}
			end,
		},
		python = {
			function()
				return {
					exe = "python3 -m autopep8",
					args = {
						"--in-place --aggressive --aggressive",
						vim.fn.fnameescape(vim.api.nvim_buf_get_name(0)),
					},
					stdin = false,
				}
			end,
		},
	},
})

vim.api.nvim_exec(
	[[
augroup FormatAutogroup
  autocmd!
  autocmd BufWritePost *.js,*.rs,*.lua,*.rb FormatWrite
augroup END
]],
	true
)

-- Lualine
local gps = require("nvim-gps")
require("lualine").setup({
	options = { theme = "kanagawa" },
	sections = {
		lualine_c = {
			{ gps.get_location, cond = gps.is_available },
		},
	},
})
