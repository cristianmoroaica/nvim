# Neovim Configuration

Personal Neovim configuration managed with [chezmoi](https://chezmoi.io/).

## Setup

### 1. Install chezmoi (if not already installed)

```powershell
winget install twpayne.chezmoi
```

### 2. Initialize chezmoi and apply dotfiles

```powershell
chezmoi init --apply <your-github-username>
```

### 3. Configure secrets

Create/edit `~/.config/chezmoi/chezmoi.toml` with your secrets:

```toml
[data]
    openai_api_key = "your-openai-api-key"
    langflow_api_key = "your-langflow-api-key"
    langflow_news_flow_url = "http://localhost:7860/api/v1/run/your-flow-id"
    mimir_projects_path = "C:\\path\\to\\mimir"
```

Then regenerate the .env file:

```powershell
chezmoi apply
```

### 4. Install plugins

Open Neovim and run `:Lazy` to install all plugins.

## Structure

- `init.lua` - Main entry point
- `lua/config/` - Core configuration
  - `lazy.lua` - Plugin manager setup
  - `options.lua` - Vim options and keymaps
  - `dotenv.lua` - Loads `.env` file for secrets
  - `news.lua` - News aggregation feature
- `lua/plugins/` - Plugin configurations

## Secrets

The `.env` file is gitignored and generated from a chezmoi template. Never commit secrets!

Required environment variables:
- `OPENAI_API_KEY` - For CodeCompanion with OpenAI
- `LANGFLOW_API_KEY` - For news feature
- `LANGFLOW_NEWS_FLOW_URL` - Langflow endpoint
- `MIMIR_PROJECTS_PATH` - Path to mimir project folder

