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

    max_jobs = 50
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
    use {'wbthomason/packer.nvim'}

    -- Load time optimization
    use { 'nathom/filetype.nvim' }
    use { 'lewis6991/impatient.nvim' }
    use { 'antoinemadec/FixCursorHold.nvim' }

    use { 'nvim-lua/plenary.nvim' } -- Lua functions

    -- Modules
    use { 'philipGaudreau/popfix', module = 'popfix' }
    use { 'vim-test/vim-test', module = 'vim-test' }
    use { 'nvim-lua/popup.nvim', module = 'popup.nvim' }
    use { 'kyazdani42/nvim-web-devicons', module = 'nvim-web-devicons' }

    ---

    use { 'sainnhe/gruvbox-material' } -- Color scheme
    use { 'luisiacc/gruvbox-baby' } -- Color scheme
    use { 'projekt0n/github-nvim-theme' } -- Color scheme

    use { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' } -- using Treesitter
    use { 'nvim-treesitter/playground' } -- See parsed tree
    use { 'nvim-treesitter/nvim-treesitter-textobjects' } -- More text motions
    use { 'nvim-treesitter/nvim-treesitter-refactor' } -- Highlight definitions, Rename
    -- use { 'RRethy/vim-illuminate' } -- Word highlighting
    use { 'RRethy/nvim-treesitter-endwise' } -- Add `end` statement when opening a context
    use { 'p00f/nvim-ts-rainbow' } -- "Enclosers" coloring
    use { 's1n7ax/nvim-comment-frame' } -- Comment frame
    use { "SmiteshP/nvim-gps" } -- Context in the status bar
    use { 'ThePrimeagen/refactoring.nvim', requires = 'plenary.nvim' } --  Extract block in new function
    use { "danymat/neogen" } -- Annotation generator

    use { 'neovim/nvim-lspconfig' } -- LSP and completion
    use {'williamboman/nvim-lsp-installer'} -- LSP installer
    -- use {'ray-x/lsp_signature.nvim'} -- Signature help
    use { 'onsails/lspkind-nvim' } -- LSP pictograms
    -- use { 'github/copilot.vim' } -- AI completion
    use {
      'Shougo/ddc.vim', requires = {'vim-denops/denops.vim',
        'matsui54/ddc-ultisnips', 'Shougo/ddc-omni', 'Shougo/ddc-nvim-lsp',
        'Shougo/ddc-converter_remove_overlap', 'LumaKernel/ddc-file', 'delphinus/ddc-treesitter',
        'Shougo/ddc-matcher_length', 'tani/ddc-fuzzy', 'matsui54/denops-popup-preview.vim'},
    } -- Completion engine
    use {
      'folke/trouble.nvim',
      requires = 'nvim-web-devicons',
    } -- Diagnistic list

    use {
      'nvim-telescope/telescope.nvim',
      requires = {'popup.nvim', 'plenary.nvim'}
    } -- Fuzzy finder

    use { "beauwilliams/focus.nvim",
      config = function()
        require("focus").setup({signcolumn = false, cursorline = false})
      end
    } -- Split and resize window intelligently

    use { 'mhartington/formatter.nvim' } -- Formatting

    use { 'lewis6991/gitsigns.nvim' } -- Git integration

    use { 'honza/vim-snippets' } -- Snippets
    use { 'SirVer/ultisnips' } -- Snippets engine

    use { 'ojroques/vim-oscyank' } -- Global TMUX yank

    use {
      'numToStr/Comment.nvim',
      config = function()
        require('Comment').setup()
      end
    } -- Comments

    use { 'tpope/vim-surround' } -- Surround

    use { 'windwp/nvim-autopairs' } -- Pairwise

    use { 'AndrewRadev/dsf.vim' } -- Delete function surround

    use { 'lukas-reineke/indent-blankline.nvim' } -- Indentation line

    use { 'tpope/vim-repeat' } -- Repeat plugins commands

    use { 'phaazon/hop.nvim' } -- Vim Motions

    use { "rcarriga/vim-ultest",
      wants = {"vim-test"},
      cmd = { "UltestNearest" },
      run = ":UpdateRemotePlugins",
    } -- Tests

    -- use {
    --   --"michaelb/sniprun",
    --   "philipgaudreau/sniprun",
    --   branch = "feature/hide-kernel-launched",
    --   run = "bash ./install.sh",
    --   config = function()
    --     require("config.sniprun").setup()
    --   end,
    --   ft = { "python" }
    -- } -- Execute code snippets

    use { 'Houl/repmo-vim' } -- More motions with , and ;

    use { 'wellle/targets.vim' } -- More motions objects

    use { 'junegunn/vim-easy-align' } -- Tabularize

    use { 'airblade/vim-matchquote' } -- Add matching for ' " ` |
    -- use { 'andymass/vim-matchup' } -- Extend % matching to objects start/end

    use { 'machakann/vim-swap' } -- Swap delimited items, like function arguments

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
      'philipGaudreau/nvim-cheat.sh',
      branch = 'feature/rounded-borders',
      requires = 'popfix'
    } -- cheat.sh

    use { 'stevearc/dressing.nvim' } -- Use Telescope for input

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
