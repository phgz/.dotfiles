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
				return require("packer.util").float({ border = "none" })
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
			vim.cmd([[packadd packer.nvim]])
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

		use({
			"nvim-treesitter/nvim-treesitter",
			run = ":TSUpdate",
			config = function()
				require("config.treesitter")
			end,
		}) -- using Treesitter
		use({ "nvim-treesitter/playground" }) -- See parsed tree
		use({ "nvim-treesitter/nvim-treesitter-textobjects" }) -- More text motions
		use({ "nvim-treesitter/nvim-treesitter-refactor" }) -- Highlight definitions, Rename
		use({
			"RRethy/vim-illuminate",
			config = function()
				require("config.illuminate")
			end,
		}) -- Word highlighting
		use({ "RRethy/nvim-treesitter-endwise" }) -- Add `end` statement when opening a context
		use({ "p00f/nvim-ts-rainbow" }) -- "Enclosers" coloring
		use({
			"s1n7ax/nvim-comment-frame",
			config = function()
				require("config.commentframe")
			end,
		}) -- Comment frame
		use({
			"SmiteshP/nvim-gps",
			config = function()
				require("config.gps")
			end,
		}) -- Context in the status bar
		use({
			"ThePrimeagen/refactoring.nvim",
			requires = "plenary.nvim",
			config = function()
				require("config.refactoring")
			end,
		}) --  Extract block in new function
		use({
			"danymat/neogen",
			config = function()
				require("config.neogen")
			end,
		}) -- Annotation generator

		use({ "https://gitlab.com/yorickpeterse/vim-paper.git" })
		use({ "neovim/nvim-lspconfig" }) -- LSP and completion
		use({
			"williamboman/mason.nvim",
		}) -- LSP installer
		use({ "williamboman/mason-lspconfig.nvim" })
		-- use { 'WhoIsSethDaniel/mason-tool-installer.nvim' } -- Auto install tools like shellcheck
		use({ "onsails/lspkind-nvim" }) -- LSP pictograms
		-- use({
		-- 	"codota/tabnine-nvim",
		-- 	run = "./dl_binaries.sh",
		-- 	config = function()
		-- 		require("tabnine").setup({
		-- 			disable_auto_comment = true,
		-- 			accept_keymap = "<right>",
		-- 			debounce_ms = 300,
		-- 			suggestion_color = { gui = "#808080", cterm = 244 },
		-- 		})
		-- 	end,
		-- })
		use({
			"Shougo/ddc.vim",
			requires = {
				"vim-denops/denops.vim",
				"matsui54/denops-popup-preview.vim",
				"matsui54/ddc-ultisnips",
				"LumaKernel/ddc-file",
				"Shougo/ddc-converter_remove_overlap",
				"Shougo/ddc-nvim-lsp",
				"Shougo/ddc-source-around",
				"Shougo/ddc-ui-inline",
				"Shougo/ddc-ui-native",
				"tani/ddc-fuzzy",
				"tani/ddc-path",
			},
			config = function()
				require("config.ddc")
			end,
		}) -- Completion engine

		use({
			"nvim-telescope/telescope.nvim",
			requires = { "popup.nvim", "plenary.nvim" },
			config = function()
				require("config.telescope")
			end,
		}) -- Fuzzy finder

		use({ "cljoly/telescope-repo.nvim" }) --Jump around the repositories in the filesystem

		use({
			"kylechui/nvim-surround",
			config = function()
				require("config.surround")
			end,
		})

		use({
			"beauwilliams/focus.nvim",
			config = function()
				require("config.focus")
			end,
		}) -- Split and resize window intelligently

		use({
			"mhartington/formatter.nvim",
			config = function()
				require("config.formatting")
			end,
		}) -- Formatting

		use({
			"lewis6991/gitsigns.nvim",
			config = function()
				require("config.gitsigns")
			end,
		}) -- Git integration

		use({ "honza/vim-snippets" }) -- Snippets
		use({
			"SirVer/ultisnips",
			config = function()
				require("config.ultisnips")
			end,
		}) -- Snippets engine

		-- use({
		-- 	"ibhagwan/smartyank.nvim",
		-- 	config = function()
		-- 		require("config.smartyank")
		-- 	end,
		-- })

		use({
			"numToStr/Comment.nvim",
			config = function()
				require("config.comment")
			end,
		}) -- Comments

		use({
			"windwp/nvim-autopairs",
			config = function()
				require("config.autopairs")
			end,
		}) -- Pairwise

		use({
			"lukas-reineke/indent-blankline.nvim",
			config = function()
				require("config.indentblankline")
			end,
		}) -- Indentation line

		use({ "tpope/vim-repeat" }) -- Repeat plugins commands

		use({
			"phaazon/hop.nvim",
			config = function()
				require("config.hop")
			end,
		}) -- Vim Motions

		use({
			"Weissle/easy-action",
			requires = {
				{
					"kevinhwang91/promise-async",
					module = { "async" },
				},
			},
			config = function()
				require("config.easy-action")
			end,
		})

		use({
			"diegoulloao/nvim-file-location",
			config = function()
				require("config.file-location")
			end,
		})

		use({ "jose-elias-alvarez/null-ls.nvim", config = function() end })

		use({
			"Houl/repmo-vim",
			config = function()
				require("config.repmotion")
			end,
		}) -- More motions with , and ;

		use({ "wellle/targets.vim" }) -- More motions objects

		use({
			"junegunn/vim-easy-align",
			config = function()
				require("config.easyalign")
			end,
		}) -- Tabularize

		use({ "airblade/vim-matchquote" }) -- Add matching for ' " ` |

		use({ "machakann/vim-swap" }) -- Swap delimited items, like function arguments

		use({
			"smjonas/live-command.nvim",
			config = function()
				require("config.live-command")
			end,
		}) -- Live :norm

		use({
			"folke/noice.nvim",
			requires = {
				"MunifTanjim/nui.nvim",
			},
			config = function()
				require("config.noice")
			end,
		})

		use({
			"nixon/vim-vmath",
			config = function()
				require("config.vmath")
			end,
		}) -- Visual block math mode

		use({ "dahu/vim-fanfingtastic" }) -- Use f/F/t/T multiline

		-- use({
		-- 	"nacro90/numb.nvim",
		-- 	config = function()
		-- 		require("numb").setup()
		-- 	end,
		-- }) -- Line preview

		use({
			"philipGaudreau/nvim-cheat.sh",
			branch = "feature/rounded-borders",
			requires = "popfix",
			config = function()
				require("config.cheat")
			end,
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
