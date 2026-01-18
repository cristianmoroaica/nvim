# Neovim Configuration

Personal Neovim configuration with a focus on productivity, search/navigation, and AI assistance.

## Highlights

- File explorer with icons: `nvim-tree.lua` + `nvim-web-devicons`
- Fast search and pickers: `telescope.nvim`, `telescope-fzf-native.nvim`, `snacks.nvim`
- LSP support: `nvim-lspconfig` (HTML, JSON, TypeScript, Angular, Kotlin)
- Completion and snippets: `blink.cmp`, `LuaSnip`, `friendly-snippets`
- AI assistance: `codecompanion.nvim` (OpenAI/Copilot adapters), `supermaven-nvim`
- Diagnostics and context: `trouble.nvim`, `workspace-diagnostics.nvim`, `treesitter-context`
- UI polish: `rose-pine`, `vim-airline`, `satellite.nvim`, `mini.nvim`
- Markdown and notes: `render-markdown.nvim`, `mimirs_notes.nvim`
- Utilities: `neoformat`, `emmet-vim`, `yaml.nvim`, `other.nvim`, `ccc.nvim`, `nvim-colorizer.lua`
- Custom features: floating terminals, news command, tabline resource monitor

## Plugins (grouped)

- **Core UI**: `rose-pine`, `vim-airline`, `satellite.nvim`, `mini.nvim`, `snacks.nvim`
- **Navigation/Search**: `nvim-tree.lua`, `telescope.nvim`, `telescope-fzf-native.nvim`, `harpoon`
- **LSP/Diagnostics**: `nvim-lspconfig`, `trouble.nvim`, `workspace-diagnostics.nvim`, `treesitter-context`
- **Completion/Snippets**: `blink.cmp`, `LuaSnip`, `friendly-snippets`
- **AI**: `codecompanion.nvim`, `supermaven-nvim`
- **Editing Helpers**: `emmet-vim`, `other.nvim`, `neoformat`, `yaml.nvim`
- **Colors/Markdown/Notes**: `ccc.nvim`, `nvim-colorizer.lua`, `render-markdown.nvim`, `mimirs_notes.nvim`

## Custom Commands

- `:News` - Open/refresh the daily news file (uses Langflow)
- `:ResMonToggle` - Toggle the tabline resource monitor
- `:Floaterminal` - Toggle the floating terminal

## Setup

### 1. Configure secrets

Create/edit a `.env` file in the repo root with your secrets:

```env
OPENAI_API_KEY=your-openai-api-key
LANGFLOW_API_KEY=your-langflow-api-key
LANGFLOW_NEWS_FLOW_URL=
MIMIR_PROJECTS_PATH=C:\path\to\mimir
```

### 2. Install plugins

Open Neovim and run `:Lazy` to install all plugins.

## Structure

- `init.lua` - Main entry point
- `lua/config/` - Core configuration
  - `lazy.lua` - Plugin manager setup (`lazy.nvim`)
  - `options.lua` - Vim options and keymaps
  - `dotenv.lua` - Loads `.env` file for secrets
  - `news.lua` - News aggregation feature
  - `terminal.lua` - Floating terminal toggles
  - `resmon.lua` - Tabline resource monitor
- `lua/plugins/` - Plugin configurations

## Secrets

The `.env` file is gitignored. Never commit secrets!