#!/usr/bin/env node
/**
 * GitHub Pages Blog Workflow for DRManager.github.io
 *
 * Automates: create drafts from templates, commit, push to trigger deploy.
 *
 * Usage:
 *   node gh-pages-workflow.js draft <template> "<title>"
 *   node gh-pages-workflow.js list-drafts
 *   node gh-pages-workflow.js list-templates
 *   node gh-pages-workflow.js publish <post-file>
 *   node gh-pages-workflow.js status
 */

const fs = require("fs");
const path = require("path");
const { execSync } = require("child_process");

// Resolve paths relative to the repo root (parent of scripts/)
const REPO_ROOT = path.resolve(__dirname, "..");
const CONTENT_DIR = path.join(REPO_ROOT, "content", "post");
const TEMPLATES_DIR = path.join(REPO_ROOT, "templates");

function slugify(text) {
  return text
    .toLowerCase()
    .trim()
    .replace(/[^\w\s-]/g, "")
    .replace(/[\s_]+/g, "-")
    .replace(/-+/g, "-")
    .replace(/^-|-$/g, "");
}

function getISODate() {
  const now = new Date();
  // Format: YYYY-MM-DDTHH:MM:SS+08:00 (SGT)
  const offset = "+08:00";
  const pad = (n) => String(n).padStart(2, "0");
  return (
    `${now.getFullYear()}-${pad(now.getMonth() + 1)}-${pad(now.getDate())}` +
    `T${pad(now.getHours())}:${pad(now.getMinutes())}:${pad(now.getSeconds())}${offset}`
  );
}

function getDatePrefix() {
  const now = new Date();
  const pad = (n) => String(n).padStart(2, "0");
  return `${now.getFullYear()}-${pad(now.getMonth() + 1)}-${pad(now.getDate())}`;
}

function git(args) {
  return execSync(`git ${args}`, { cwd: REPO_ROOT, encoding: "utf-8" }).trim();
}

// --- Commands ---

function cmdDraft(templateName, title) {
  // Find template
  const templatePath = path.join(TEMPLATES_DIR, `${templateName}.md`);
  if (!fs.existsSync(templatePath)) {
    const available = fs
      .readdirSync(TEMPLATES_DIR)
      .filter((f) => f.endsWith(".md"))
      .map((f) => f.replace(".md", ""));
    console.error(`Template not found: ${templateName}`);
    console.error(`Available: ${available.join(", ")}`);
    process.exit(1);
  }

  const slug = slugify(title);
  const datePrefix = getDatePrefix();
  const isoDate = getISODate();
  const filename = `${datePrefix}-${slug}.md`;
  const postPath = path.join(CONTENT_DIR, filename);

  if (fs.existsSync(postPath)) {
    console.error(`Post already exists: ${postPath}`);
    process.exit(1);
  }

  // Read template and customize
  let content = fs.readFileSync(templatePath, "utf-8");

  // Replace template placeholders in frontmatter
  content = content.replace(
    /title: "[^"]*"/,
    `title: "${title}"`
  );
  content = content.replace(
    /date: "[^"]*"/,
    `date: "${isoDate}"`
  );
  content = content.replace(
    /slug: "[^"]*"/,
    `slug: "${slug}"`
  );

  // Ensure content directory exists
  if (!fs.existsSync(CONTENT_DIR)) {
    fs.mkdirSync(CONTENT_DIR, { recursive: true });
  }

  fs.writeFileSync(postPath, content, "utf-8");

  console.log(`Draft created: ${postPath}`);
  console.log(`Slug: ${slug}`);
  console.log(`Template: ${templateName}`);
  console.log();
  console.log("Next steps:");
  console.log(`  1. Edit the draft: ${postPath}`);
  console.log(`  2. Publish: node scripts/gh-pages-workflow.js publish ${filename}`);
}

function cmdListDrafts() {
  if (!fs.existsSync(CONTENT_DIR)) {
    console.log("No content/post directory found.");
    return;
  }

  const posts = fs
    .readdirSync(CONTENT_DIR)
    .filter((f) => f.endsWith(".md"))
    .sort();

  if (posts.length === 0) {
    console.log("No posts found.");
    return;
  }

  console.log(`Posts (${posts.length}):`);
  for (const p of posts) {
    const content = fs.readFileSync(path.join(CONTENT_DIR, p), "utf-8");
    let title = "Untitled";
    const match = content.match(/title:\s*"([^"]*)"/);
    if (match) title = match[1];
    console.log(`  ${p.padEnd(55)} | ${title}`);
  }
}

function cmdListTemplates() {
  if (!fs.existsSync(TEMPLATES_DIR)) {
    console.log("No templates directory found.");
    return;
  }

  const templates = fs
    .readdirSync(TEMPLATES_DIR)
    .filter((f) => f.endsWith(".md"));

  if (templates.length === 0) {
    console.log("No templates found.");
    return;
  }

  console.log(`Templates (${templates.length}):`);
  for (const t of templates) {
    console.log(`  ${t.replace(".md", "")}`);
  }
}

function cmdPublish(postFile) {
  // Resolve post file path
  let postPath;
  if (path.isAbsolute(postFile)) {
    postPath = postFile;
  } else {
    // Check if it's just a filename (look in content/post/)
    const inContent = path.join(CONTENT_DIR, postFile);
    if (fs.existsSync(inContent)) {
      postPath = inContent;
    } else {
      postPath = path.resolve(postFile);
    }
  }

  if (!postPath.endsWith(".md")) postPath += ".md";

  if (!fs.existsSync(postPath)) {
    console.error(`Post not found: ${postPath}`);
    process.exit(1);
  }

  // Read and display post info
  const content = fs.readFileSync(postPath, "utf-8");
  let title = "Untitled";
  const match = content.match(/title:\s*"([^"]*)"/);
  if (match) title = match[1];

  const relativePath = path.relative(REPO_ROOT, postPath).replace(/\\/g, "/");

  console.log(`Publishing: ${title}`);
  console.log(`File: ${relativePath}`);
  console.log();

  // Git operations: add, commit, push
  try {
    // Check for uncommitted changes first
    const status = git("status --porcelain");
    if (!status.includes(relativePath) && !status) {
      console.log("No changes to commit. Post may already be published.");
      console.log("Pushing to ensure deployment...");
      git("push origin sources");
      console.log("Done! GitHub Actions will build and deploy.");
      return;
    }

    git(`add "${relativePath}"`);
    const commitMsg = `Publish: ${title}`;
    git(`commit -m "${commitMsg}"`);
    console.log(`Committed: ${commitMsg}`);

    git("push origin sources");
    console.log();
    console.log("Pushed to sources branch.");
    console.log("GitHub Actions will build and deploy to https://drmanager.github.io/");
    console.log();

    // Calculate expected URL from slug
    const slugMatch = content.match(/slug:\s*"([^"]*)"/);
    const dateMatch = content.match(/date:\s*"(\d{4})-(\d{2})-(\d{2})/);
    if (slugMatch && dateMatch) {
      const [, year, month, day] = dateMatch;
      const slug = slugMatch[1];
      console.log(
        `Expected URL: https://drmanager.github.io/${year}/${month}/${day}/${slug}/`
      );
    }
  } catch (err) {
    console.error("Git operation failed:");
    console.error(err.message);
    process.exit(1);
  }
}

function cmdStatus() {
  console.log("Repository: DRManager.github.io");
  console.log(`Path: ${REPO_ROOT}`);
  console.log();

  try {
    const branch = git("branch --show-current");
    console.log(`Branch: ${branch}`);

    const status = git("status --short");
    if (status) {
      console.log("\nUncommitted changes:");
      console.log(status);
    } else {
      console.log("Working tree clean.");
    }

    console.log();
    const log = git("log --oneline -5");
    console.log("Recent commits:");
    console.log(log);
  } catch (err) {
    console.error("Git error:", err.message);
  }
}

function cmdPublishAll() {
  // Stage and push all changes in content/post/
  const status = git("status --porcelain");
  const postChanges = status
    .split("\n")
    .filter((line) => line.includes("content/post/"));

  if (postChanges.length === 0) {
    console.log("No post changes to publish.");
    return;
  }

  console.log(`Publishing ${postChanges.length} post change(s):`);
  for (const line of postChanges) {
    console.log(`  ${line.trim()}`);
  }
  console.log();

  git("add content/post/");

  const commitMsg = `Publish ${postChanges.length} post(s)`;
  git(`commit -m "${commitMsg}"`);
  console.log(`Committed: ${commitMsg}`);

  git("push origin sources");
  console.log("Pushed to sources branch. GitHub Actions will deploy.");
}

// --- CLI ---

function printUsage() {
  console.log(`
GitHub Pages Blog Workflow for DRManager.github.io

Usage:
  node gh-pages-workflow.js draft <template> "<title>"   Create new post from template
  node gh-pages-workflow.js list-drafts                   List all posts
  node gh-pages-workflow.js list-templates                 List available templates
  node gh-pages-workflow.js publish <post-file>            Commit and push a post
  node gh-pages-workflow.js publish-all                    Commit and push all post changes
  node gh-pages-workflow.js status                         Show repo status

Templates: technical_article, company_news, industry_insight
  `.trim());
}

const args = process.argv.slice(2);
const command = args[0];

switch (command) {
  case "draft":
    if (args.length < 3) {
      console.error('Usage: node gh-pages-workflow.js draft <template> "<title>"');
      process.exit(1);
    }
    cmdDraft(args[1], args[2]);
    break;

  case "list-drafts":
    cmdListDrafts();
    break;

  case "list-templates":
    cmdListTemplates();
    break;

  case "publish":
    if (args.length < 2) {
      console.error("Usage: node gh-pages-workflow.js publish <post-file>");
      process.exit(1);
    }
    cmdPublish(args[1]);
    break;

  case "publish-all":
    cmdPublishAll();
    break;

  case "status":
    cmdStatus();
    break;

  default:
    printUsage();
    break;
}
