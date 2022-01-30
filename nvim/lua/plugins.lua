local M = {}

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
                return require("packer.util").float { border = "rounded" }
            end,
        },
    }

    -- Check if packer.nvim is installed
    -- Run PackerCompile if there are changes in this file
    local function packer_init()
        local fn = vim.fn
        local install_path = fn.stdpath "data" .. "/site/pack/packer/start/packer.nvim"
        if fn.empty(fn.glob(install_path)) > 0 then
            packer_bootstrap = fn.system {
                "git",
                "clone",
                "--depth",
                "1",
                "https://github.com/wbthomason/packer.nvim",
                install_path,
            }
            vim.cmd [[packadd packer.nvim]]
        end
        vim.cmd "autocmd BufWritePost plugins.lua source <afile> | PackerCompile"
    end


-- Plugings
    local function plugins(use)
        -- Packer can manage itself as an optional plugin
        use {'wbthomason/packer.nvim', opt = true}

        -- Load time optimization
        use { 'lewis6991/impatient.nvim' }

        -- Color scheme
        use { 'sainnhe/gruvbox-material' }

        -- Fuzzy finder
        use {
            'nvim-telescope/telescope.nvim',
            requires = {{'nvim-lua/popup.nvim'}, {'nvim-lua/plenary.nvim'}}
        }

        -- GitHub Copilot
        use { 'github/copilot.vim' }

        -- using Treesitter
        use { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' }

        use { 'nvim-treesitter/playground' } -- See parsed tree
        use { 'nvim-treesitter/nvim-treesitter-textobjects' } -- More text motions
        use { 'nvim-treesitter/nvim-treesitter-refactor' } -- Highlight definitions, Rename
        use { 'romgrk/nvim-treesitter-context' } -- Keep context in sight
        use { 'RRethy/nvim-treesitter-endwise' } -- Add `end` statement when opening a context
        use { 'p00f/nvim-ts-rainbow' } -- "Enclosers" coloring
        use { 's1n7ax/nvim-comment-frame' } -- Comment frame
        use { "SmiteshP/nvim-gps" }
        use { 'ThePrimeagen/refactoring.nvim' }
        use { "danymat/neogen" }

        -- LSP and completion
        use { 'neovim/nvim-lspconfig' }
        use {'ray-x/lsp_signature.nvim'}

        use {
            'Shougo/ddc.vim',
            requires = {'vim-denops/denops.vim', 'matsui54/ddc-ultisnips',
                'Shougo/ddc-around', 'Shougo/ddc-omni', 'Shougo/ddc-sorter_rank',
                'Shougo/ddc-matcher_head', 'Shougo/ddc-converter_remove_overlap',
                'delphinus/ddc-tmux', 'LumaKernel/ddc-file', 'matsui54/ddc-buffer',
                'delphinus/ddc-treesitter', 'Shougo/ddc-rg', 'Shougo/ddc-line',
                'ddc-converter_remove_overlap', 'Shougo/ddc-matcher_length',
                'Shougo/ddc-nvim-lsp', 'statiolake/ddc-ale', 'Shougo/pum.vim',
                'tani/ddc-fuzzy', 'tani/ddc-onp', 'matsui54/ddc-nvim-lsp-doc'}
        }

        use { "beauwilliams/focus.nvim", 
            config = function()
                require("focus").setup({signcolumn = false, cursorline = false}) 
            end
        }

        -- Formatting
        use { 'mhartington/formatter.nvim' }

        -- Vim dispatch
        use { 'tpope/vim-dispatch' }

        -- Git
        -- use { 'tpope/vim-fugitive' }
        -- use { 'philipgaudreau/vim-gitgutter', branch = 'feature/win-border-option' }
        use { 'lewis6991/gitsigns.nvim' }
        use { 'itchyny/vim-gitbranch' }

        -- Snippets
        use { 'honza/vim-snippets' }
        use { 'SirVer/ultisnips' }

        -- TMUX
        --use { 'roxma/vim-tmux-clipboard' }
        use { 'ojroques/vim-oscyank' }

        -- Comments
        use { 'scrooloose/nerdcommenter' }
        use { 'tpope/vim-commentary' }

        -- Utils

        -- use { 'dense-analysis/ale' } -- Lint

        use { 'tpope/vim-surround' } -- Surround
        use { 'windwp/nvim-autopairs' } -- Pairwise
        use { 'AndrewRadev/dsf.vim' } -- Delete function surround

        -- use { 'Yggdroot/indentLine' } -- Indentation
        use { 'lukas-reineke/indent-blankline.nvim' }

        use { 'tpope/vim-repeat' } -- Repeat plugins commands

        use { 'phaazon/hop.nvim' } -- Vim Motions

        --use { 'unblevable/quick-scope' } -- f/F/t/T highlight helper

        use { 'metakirby5/codi.vim' } -- Scratch pad

        use { "rcarriga/vim-ultest", 
            requires = {"vim-test/vim-test"},
            run = ":UpdateRemotePlugins"
        } -- tests

        use {
            "philipgaudreau/sniprun",
            branch = "feature/hide-kernel-launched",
            run = "bash ./install.sh",
            config = function()
                require("config.sniprun").setup()
            end,
        }

        use { 'Houl/repmo-vim' } -- More motions with , and ;

        use { 'wellle/targets.vim' } -- More motions objects

        use { 'junegunn/vim-easy-align' } -- Tabularize

        use { 'airblade/vim-matchquote' } -- Add matching for ' " ` |

        use { 'machakann/vim-swap' } -- Swap text

        -- use { 'RRethy/vim-illuminate' } -- Word highlighting

        use { 'onsails/lspkind-nvim' } -- LSP pictograms

        use { 'rcarriga/nvim-notify' } --  Notifications

        use { 'nixon/vim-vmath' } -- Visual block math mode

        use { 'dahu/vim-fanfingtastic' } -- Use f/F/t/T multiline

        use {
            "nacro90/numb.nvim",
            config = function()
                require("numb").setup()
            end,
        } -- Line preview

        use {
            'folke/trouble.nvim',
            requires = 'kyazdani42/nvim-web-devicons',
        } -- Diagnistic list

        use {
            'philipGaudreau/nvim-cheat.sh',
            branch = 'feature/rounded-borders',
            requires = 'RishabhRD/popfix'
        } -- cheat.sh

        -- Bootstrap Neovim
        if packer_bootstrap then
            print "Restart Neovim required after installation!"
            require("packer").sync()
        end
    end

    packer_init()

    local packer = require("packer")
    packer.init(conf)
    packer.startup(plugins)
end

return M
