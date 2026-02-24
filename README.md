# Neovim Configuration

Personal Neovim configuration with a focus on productivity.

## Highlights

- File explorer with icons: `nvim-tree.lua` + `nvim-web-devicons`
- Fast search and pickers: `telescope.nvim`, `telescope-fzf-native.nvim`, `snacks.nvim`
- LSP support: `nvim-lspconfig` + `mason.nvim` (HTML, JSON, TypeScript, Angular, Kotlin, Lua, Rust, TexLab)
- Completion and snippets: `blink.cmp`, `LuaSnip`, `friendly-snippets`
- AI assistance: `supermaven-nvim`, `copilot.vim`
- Diagnostics and context: `trouble.nvim`, `workspace-diagnostics.nvim`, `treesitter-context`
- UI polish: `rose-pine`, `gruvbox-material`, `vim-airline`, `satellite.nvim`, `mini.nvim`, `snacks.nvim`
- Markdown and notes: `render-markdown.nvim`, `mimirs_notes.nvim`
- LaTeX editing: `vimtex` with Zathura viewer
- Code formatting: `conform.nvim` (Prettier, Stylua)
- Utilities: `emmet-vim`, `yaml.nvim`, `other.nvim`, `ccc.nvim`, `nvim-colorizer.lua`, `which-key.nvim`
- Remote editing: `remote-sshfs.nvim`
- Git tools: `vim-fugitive`, `mini.git`, `codediff.nvim`
- Custom features: floating terminals, news command, tabline resource monitor, WPM mode signal

## Plugins (grouped)

- **Core UI**: `rose-pine`, `gruvbox-material`, `vim-airline`, `satellite.nvim`, `mini.nvim`, `snacks.nvim`, `which-key.nvim`
- **Navigation/Search**: `nvim-tree.lua`, `telescope.nvim`, `telescope-fzf-native.nvim`, `harpoon`
- **LSP/Diagnostics**: `nvim-lspconfig`, `mason.nvim`, `mason-lspconfig.nvim`, `mason-tool-installer.nvim`, `trouble.nvim`, `workspace-diagnostics.nvim`, `treesitter-context`
- **Treesitter**: `nvim-treesitter`, `nvim-treesitter-textobjects`, `nvim-ts-autotag`
- **Completion/Snippets**: `blink.cmp`, `LuaSnip`, `friendly-snippets`
- **AI**: `supermaven-nvim`
- **Git**: `vim-fugitive`, `mini.git`, `codediff.nvim`
- **Editing Helpers**: `emmet-vim`, `other.nvim`, `conform.nvim`, `yaml.nvim`, `mini.pairs`, `mini.surround`, `mini.comment`, `mini.move`, `mini.splitjoin`
- **Colors/Markdown/Notes**: `ccc.nvim`, `nvim-colorizer.lua`, `render-markdown.nvim`, `mimirs_notes.nvim`
- **LaTeX**: `vimtex`
- **Remote**: `remote-sshfs.nvim`
- **Tracking**: `TakaTime`
- **Custom Local**: `resmon` (tabline resource monitor), `wpm-mode` (WPM mode signal)

## Custom Commands

- `:ResMonToggle` / `:ResMonOpen` / `:ResMonClose` - Control the tabline resource monitor
- `:Floaterminal` / `<leader>tt` - Toggle the floating terminal (supports up to 4 independent terminals)
- `:SavePDF` - Convert markdown to PDF via mdpdf with font selection. REQUIRES mdpdf.
- `:checkhealth nvim_config` - Basic config health checks (git, rg, fd, node)

## Setup

### 1. Prerequisites

Ensure the following are installed (checked by `:checkhealth nvim_config`):

- `git`
- `rg` (ripgrep)
- `fd`
- `node`

### 2. Install plugins

Open Neovim and run `:Lazy` to install all plugins.

## Structure

- `init.lua` - Main entry point
- `lua/config/` - Core configuration
  - `lazy.lua` - Plugin manager setup (`lazy.nvim`)
  - `options.lua` - Vim options
  - `keymaps.lua` - Keymaps
  - `autocmds.lua` - Autocommands (file change detection, `:SavePDF`, format on save)
  - `dotenv.lua` - Loads `.env` file for secrets
  - `news.lua` - News aggregation feature (Langflow API)
  - `terminal.lua` - Floating terminal toggles (4 independent terminals)
  - `resmon.lua` - Tabline resource monitor (CPU, RAM, disk, network, GPU)
  - `sshfs.lua` - SSH remote filesystem configuration
- `lua/plugins/` - Plugin configurations (24 files)
- `lua/health/` - Health check module
