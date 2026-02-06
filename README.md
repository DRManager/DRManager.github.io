# DRManager.github.io

https://drmanager.github.io/

## Automated Blog Publishing Prototype

Hugo-based blog with automated publishing via GitHub Actions.

### Architecture

```
Claude Code (write) --> content/post/*.md --> git push --> GitHub Actions (Hugo build) --> GitHub Pages
```

**Framework:** Hugo with hugo-lithium-theme
**Deploy:** GitHub Actions builds on push to `sources` branch, deploys to GitHub Pages
**Automation:** Node.js scripts for draft creation, listing, and publishing

### Quick Start

```bash
cd D:\Claude\github-pages

# List available templates
node scripts/gh-pages-workflow.js list-templates

# Create a new post from a template
node scripts/gh-pages-workflow.js draft technical_article "My Article Title"

# Edit the post in content/post/YYYY-MM-DD-my-article-title.md

# Publish (git add, commit, push — triggers GitHub Actions deploy)
node scripts/gh-pages-workflow.js publish YYYY-MM-DD-my-article-title.md

# List all posts
node scripts/gh-pages-workflow.js list-drafts

# Check repo status
node scripts/gh-pages-workflow.js status
```

### Workflow: Claude Code to Published Blog

**Step 1: Write**
Ask Claude Code to write a blog post:
> "Write a technical blog post about cryogenic ALE for 3D NAND"

Claude will read a template from `templates/`, write content, and save to `content/post/`.

**Step 2: Review**
Review the markdown file in `content/post/`. Edit as needed.

**Step 3: Publish**
```bash
node scripts/gh-pages-workflow.js publish YYYY-MM-DD-your-post.md
```
This commits and pushes to the `sources` branch. GitHub Actions automatically builds with Hugo and deploys to GitHub Pages.

### Directory Structure

```
DRManager.github.io/
├── .github/workflows/
│   └── deploy.yml              # GitHub Actions: Hugo build + deploy
├── config.toml                 # Hugo site configuration
├── content/post/               # Blog posts (Hugo content)
├── templates/                  # Post templates (3 types)
│   ├── technical_article.md
│   ├── company_news.md
│   └── industry_insight.md
├── scripts/
│   └── gh-pages-workflow.js    # CLI orchestrator (Node.js)
└── public/                     # Built output (managed by Hugo/Actions)
```

### Templates

| Template | Use Case |
|----------|----------|
| `technical_article` | Deep-dive technical articles |
| `company_news` | Product launches, events, partnerships |
| `industry_insight` | Industry trends and market analysis |

### GitHub Actions Setup

The workflow in `.github/workflows/deploy.yml` automatically:
1. Installs Hugo on push to `sources` branch
2. Clones the hugo-lithium-theme
3. Builds the site with `hugo --minify`
4. Deploys to GitHub Pages

**First-time setup:** In your GitHub repo settings, go to **Settings > Pages** and set the source to **GitHub Actions**.
