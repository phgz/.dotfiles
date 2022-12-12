local M = {}
local call = vim.api.nvim_call_function
local cmd = vim.cmd

function M.setup()
	-- Indicate first time installation
	local packer_bootstrap = false

	-- packer.nvim configuration
	local conf = {
		profile = {
			enable = true,
			threshold = 0, -- the amount in ms that a plugins load time must be over for it to be included in the profile
		},

		display = {
			open_fn = function()
				return require("packer.util").float({ border = "rounded" })
			end,
		},

		max_jobs = 50,
	}

	-- Check if packer.nvim is installed
	-- Run PackerCompile if there are changes in this file
	local function packer_init()
		local install_path = call("stdpath", { "data" }) .. "/site/pack/packer/start/packer.nvim"

		if call("empty", { call("glob", { install_path }) }) > 0 then
			packer_bootstrap = call(
				"system",
				{ { "git", "clone", "--depth", "1", "https://github.com/wbthomason/packer.nvim", install_path } }
			)
			cmd([[packadd packer.nvim]])
		end
		cmd("autocmd BufWritePost plugins.lua source <afile> | PackerCompile")
	end

	-- Plugings
	local function plugins(use)
		-- Packer can manage itself as an optional plugin
		use({ "wbthomason/packer.nvim" })

		-- Load time optimization
		-- use({
		-- 	"nathom/filetype.nvim",
		-- 	setup = [[vim.cmd('runtime! autoload/dist/ft.vim')]],
		-- })
		use({ "lewis6991/impatient.nvim" })

		use({ "nvim-lua/plenary.nvim" }) -- Lua functions

		-- Modules
		use({ "philipGaudreau/popfix", module = "popfix" })
		use({ "nvim-lua/popup.nvim", module = "popup.nvim" })

		---

		use({ "sainnhe/gruvbox-material" }) -- Color scheme
		use({ "luisiacc/gruvbox-baby" }) -- Color scheme
		use({ "projekt0n/github-nvim-theme" }) -- Color scheme

		use({ "nvim-treesitter/nvim-treesitter", run = ":TSUpdate" }) -- using Treesitter
		use({ "nvim-treesitter/playground" }) -- See parsed tree
		use({ "nvim-treesitter/nvim-treesitter-textobjects" }) -- More text motions
		use({ "nvim-treesitter/nvim-treesitter-refactor" }) -- Highlight definitions, Rename
		use({ "RRethy/vim-illuminate" }) -- Word highlighting
		use({ "RRethy/nvim-treesitter-endwise" }) -- Add `end` statement when opening a context
		use({ "p00f/nvim-ts-rainbow" }) -- "Enclosers" coloring
		use({ "s1n7ax/nvim-comment-frame" }) -- Comment frame
		use({ "SmiteshP/nvim-gps" }) -- Context in the status bar
		use({ "ThePrimeagen/refactoring.nvim", requires = "plenary.nvim" }) --  Extract block in new function
		use({ "danymat/neogen" }) -- Annotation generator

		use({ "neovim/nvim-lspconfig" }) -- LSP and completion
		use({ "williamboman/mason.nvim" }) -- LSP installer
		use({ "williamboman/mason-lspconfig.nvim" })
		-- use { 'WhoIsSethDaniel/mason-tool-installer.nvim' } -- Auto install tools like shellcheck
		use({ "onsails/lspkind-nvim" }) -- LSP pictograms
		-- use({
		-- 	"codota/tabnine-nvim",
		-- 	run = "./dl_binaries.sh",
		-- 	config = function()
		-- 		require("tabnine").setup({
		-- 			disable_auto_comment = true,
		-- 			accept_keymap = "<Tab>",
		-- 			debounce_ms = 300,
		-- 			suggestion_color = { gui = "#808080", cterm = 244 },
		-- 		})
		-- 	end,
		-- })
		use({
			"Shougo/ddc.vim",
			requires = {
				"vim-denops/denops.vim",
				"matsui54/ddc-ultisnips",
				"Shougo/ddc-omni",
				"Shougo/ddc-nvim-lsp",
				"Shougo/ddc-converter_remove_overlap",
				"Shougo/ddc-ui-inline",
				"Shougo/ddc-ui-native",
				"LumaKernel/ddc-file",
				"LumaKernel/ddc-tabnine",
				"nabezokodaikon/ddc-nvim-lsp_by-treesitter",
				"delphinus/ddc-treesitter",
				"Shougo/ddc-matcher_length",
				"tani/ddc-fuzzy",
				"matsui54/denops-popup-preview.vim",
			},
			-- commit = "042e3b1d4df310d5bbaba7a6c2e7f36a94e27977",
		}) -- Completion engine

		use({
			"nvim-telescope/telescope.nvim",
			requires = { "popup.nvim", "plenary.nvim" },
		}) -- Fuzzy finder

		use({ "cljoly/telescope-repo.nvim" }) --Jump around the repositories in the filesystem

		use({ "kylechui/nvim-surround" })

		use({
			"beauwilliams/focus.nvim",
			config = function()
				require("focus").setup({ signcolumn = false, cursorline = false })
			end,
		}) -- Split and resize window intelligently

		use({ "mhartington/formatter.nvim" }) -- Formatting

		use({ "lewis6991/gitsigns.nvim" }) -- Git integration

		use({ "honza/vim-snippets" }) -- Snippets
		use({ "SirVer/ultisnips" }) -- Snippets engine

		use({ "ibhagwan/smartyank.nvim" })

		use({
			"numToStr/Comment.nvim",
			config = function()
				require("Comment").setup()
			end,
		}) -- Comments

		use({ "windwp/nvim-autopairs" }) -- Pairwise

		use({ "lukas-reineke/indent-blankline.nvim" }) -- Indentation line

		use({ "tpope/vim-repeat" }) -- Repeat plugins commands

		use({ "phaazon/hop.nvim" }) -- Vim Motions

		use({
			"Weissle/easy-action",
			requires = {
				{
					"kevinhwang91/promise-async",
					module = { "async" },
				},
			},
		})

		use({ "diegoulloao/nvim-file-location" })

		use({ "jose-elias-alvarez/null-ls.nvim" })

		use({ "Houl/repmo-vim" }) -- More motions with , and ;

		use({ "wellle/targets.vim" }) -- More motions objects

		use({ "junegunn/vim-easy-align" }) -- Tabularize

		use({ "airblade/vim-matchquote" }) -- Add matching for ' " ` |

		use({ "machakann/vim-swap" }) -- Swap delimited items, like function arguments

		use({ "smjonas/live-command.nvim" }) -- Live :norm

		use({
			"folke/noice.nvim",
			requires = {
				"MunifTanjim/nui.nvim",
			},
			-- commit = "7b62ccfc236e51e78e5b2fc7d3068eacd65e4590"
		})

		use({ "nixon/vim-vmath" }) -- Visual block math mode

		use({ "dahu/vim-fanfingtastic" }) -- Use f/F/t/T multiline

		use({
			"nacro90/numb.nvim",
			config = function()
				require("numb").setup()
			end,
		}) -- Line preview

		use({
			"philipGaudreau/nvim-cheat.sh",
			branch = "feature/rounded-borders",
			requires = "popfix",
		}) -- cheat.sh

		-- use { 'vimpostor/vim-tpipeline' } -- Status line in TMUX bar
		-- use { 'andymass/vim-matchup' } -- Extend % matching to objects start/end

		-- Bootstrap Neovim
		if packer_bootstrap then
			print("Restart Neovim required after installation!")
			require("packer").sync()
		end
	end

	packer_init()

	local packer = require("packer")
	packer.init(conf)
	packer.startup(plugins)
end

return M
