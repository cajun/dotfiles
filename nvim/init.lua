-- this will bootstrap Packer
local install_path = vim.fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
	packer_bootstrap = vim.fn.system({
		"git",
		"clone",
		"--depth",
		"1",
		"https://github.com/wbthomason/packer.nvim",
		install_path,
	})
end

require("packer").startup({ function(use)
	-- Packer can manage itself
	use("wbthomason/packer.nvim")

	-- The tpope
	use("tpope/vim-surround")
	use("tpope/vim-commentary")
	use("tpope/vim-rails")
	-- use("tpope/vim-unimpaired")
	use("tpope/vim-fugitive")
	use("tpope/vim-vinegar")
	use("tpope/vim-dadbod")
	use("kristijanhusak/vim-dadbod-ui")

	-- Making UI nicer
	-- use("rcarriga/nvim-notify")
	use("hood/popui.nvim")
	use("RishabhRD/popfix")

	-- use("github/copilot.vim")

	-- LSP Tools
	use("neovim/nvim-lspconfig")
	use("williamboman/nvim-lsp-installer")
	use("nvim-lua/lsp-status.nvim")
	use("simrat39/rust-tools.nvim")

	use("editorconfig/editorconfig-vim")
	-- General formatter
	use("mhartington/formatter.nvim")

	-- Syntax highlighting and awesomness
	use({ "nvim-treesitter/nvim-treesitter", run = ":TSUpdate" })
	use({ "nvim-treesitter/playground" })

	-- Auto complete
	use({ "ms-jpq/coq_nvim", branch = "coq", run = ":COQdeps" })
	use({ "ms-jpq/coq.artifacts", branch = "artifacts" })

	-- fzf finder
	use({ "ibhagwan/fzf-lua", requires = { "kyazdani42/nvim-web-devicons" } })
	use({ "junegunn/fzf", run = "./install --bin" })

	-- Git in side bar
	use({ "lewis6991/gitsigns.nvim", requires = { "nvim-lua/plenary.nvim" } })

	-- Status line
	use("NTBBloodbath/galaxyline.nvim")

	-- Color scheme
	use({ "catppuccin/nvim", as = "catppuccin" })

	use 'folke/lsp-colors.nvim'

	-- Line to display scoping
	use("lukas-reineke/indent-blankline.nvim")

	-- Jummping around quickly in a file
	use("ggandor/lightspeed.nvim")

	-- Highlight the word under the cursor
	use("RRethy/vim-illuminate")



	-- Add documentation to class / function / method
	use({
		"danymat/neogen",
		config = function()
			require('neogen').setup()
		end
	})

	use('simrat39/symbols-outline.nvim')

	-- Automatically set up your configuration after cloning packer.nvim
	use({
		"folke/trouble.nvim",
		requires = "kyazdani42/nvim-web-devicons",
		config = function()
			require("trouble").setup {
				-- your configuration comes here
				-- or leave it empty to use the default settings
				-- refer to the configuration section below
			}
		end
	})
	-- Put this at the end after all plugins
	if packer_bootstrap then
		require("packer").sync()
	end
end,
	config = {
		display = {
			open_fn = require('packer.util').float,
		}
	}
})

local catppuccin = require('catppuccin')
catppuccin.setup({
	transparent_background = true,
	integrations = {
		lightspeed = true
	}

})

vim.api.nvim_set_keymap("", "<Space>", "<Nop>", { noremap = true, silent = true })
vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.o.wrap = false
vim.o.spell = true
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
vim.cmd([[colorscheme catppuccin ]])

local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
for type, icon in pairs(signs) do
	local hl = "DiagnosticSign" .. type
	vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

vim.cmd([[
  augroup TrimWhitespace
  autocmd!
  autocmd BufWritePre * :%s/\s\+$//e
  augroup end
]])

vim.cmd([[
  augroup ReloadInit
  autocmd!
  autocmd BufWritePost $MYVIMRC :source $MYVIMRC
  augroup end
]])

-- Coq
vim.g.coq_settings = { auto_start = "shut-up", clients = { tabnine = { enabled = true } } }

-- Helper for keymaps
local map = vim.api.nvim_set_keymap

-- LSP Installer
require("nvim-lsp-installer").setup {}
local lspconfig = require('lspconfig')

local lsp_status = require("lsp-status")
lsp_status.register_progress()

local on_attach = function(client, bufnr)
	lsp_status.on_attach(client)
	require 'illuminate'.on_attach(client)

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


local opts = { on_attach = on_attach, capabilities = lsp_status.capabilities }
local servers = { 'clangd', 'rust_analyzer', 'pyright', 'tsserver', 'solargraph' };

for _, lsp in ipairs(servers) do
	lspconfig[lsp].setup(require("coq").lsp_ensure_capabilities(opts))
end

-- Make runtime files discoverable to the server
local runtime_path = vim.split(package.path, ';')
table.insert(runtime_path, 'lua/?.lua')
table.insert(runtime_path, 'lua/?/init.lua')

lspconfig.sumneko_lua.setup {
	on_attach = on_attach,
	capabilities = lsp_status.capabilities,
	settings = {
		Lua = {
			runtime = {
				-- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
				version = 'LuaJIT',
				-- Setup your lua path
				path = runtime_path,
			},
			diagnostics = {
				-- Get the language server to recognize the `vim` global
				globals = { 'vim' },
			},
			workspace = {
				-- Make the server aware of Neovim runtime files
				library = vim.api.nvim_get_runtime_file('', true),
			},
			-- Do not send telemetry data containing a randomized but unique identifier
			telemetry = {
				enable = false,
			},
		},
	},
}

require("rust-tools").setup({
	tools = {
		autoSetHints = true,
		hover_with_actions = true,
		inlay_hints = {
			show_variable_name = true,
			parameter_hints_prefix = "",
			other_hints_prefix = "",
		},
	},
	server = require("coq").lsp_ensure_capabilities({
		on_attach = on_attach,
		capabilities = lsp_status.capabilities,
		settings = {
			["rust-analyzer"] = {
				cargo = { loadOutDirsFromCheck = true },
				checkOnSave = { command = "clippy" },
				procMacro = { enable = true },
			},
		},
	}),
})

-- Setting up rust

-- Treesitter
require("nvim-treesitter.configs").setup({
	ensure_installed = { "ruby", "rust", "javascript", "proto", "html", "css", "dockerfile", "fish" },
	highlight = { enable = true },
	indent = { enable = true },
	incremental_selection = { enable = true },
	playground = { enable = true },
	query_linter = { enable = true },
})

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
					args = { "--emit=stdout", "--edition=2021" },
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
		autocmd BufWritePost *.js,*.rs,*.lua,*.rb,*.erb,*.rake,*.py FormatWrite
		autocmd BufWritePre *.js,*.rs,*.lua,*.rb,*.erb,*.rake,*.py lua vim.lsp.buf.formatting_sync(nil,200)
	augroup END
]],
	true
)

-- vim.notify = require("notify")
vim.ui.select = require("popui.ui-overrider")
vim.g.popui_border_style = "rounded"
require("galaxyline.themes.eviline")

vim.opt.list = true
vim.opt.listchars:append("space:⋅")
vim.opt.listchars:append("eol:↴")

require("indent_blankline").setup({
	space_char_blankline = " ",
	show_current_context = true,
	show_current_context_start = true,
	use_treesitter = true,
	char_list = { '|', '¦', '┆', '┊' }
})
