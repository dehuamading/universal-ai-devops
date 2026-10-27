# 各编程智能体使用方法

## Pi Agent（已验证：本地与 GitHub Actions）
- 本地：`pi install git:github.com/obra/superpowers`，`pi install git:github.com/dehuamading/universal-ai-devops`；在项目目录运行 `pi`，Pi 自动读取 `AGENTS.md`，技能 `uad-fix-loop` 等可直接使用。
- Actions：gh-aw `engine: pi`，通过 `engine.extensions` 安装上述两个包（见 templates/gh-aw/uad-fix.md）。模型固定 `deepseek/deepseek-flash`，经 `OPENAI_BASE_URL=https://api.deepseek.com/v1`。

## Codex CLI（未验证：本机未安装，需要 ChatGPT 账号或 OpenAI API，未获批准）
- 规则：Codex 原生读取仓库根目录 `AGENTS.md`，无需额外配置。
- 技能：Codex `/plugins` 中安装 Superpowers；本仓库 `skills/` 可复制到 `~/.codex/skills/` 或项目 `.agents/skills/`（以 Codex 当前文档为准）。
- 非交互：`codex exec "按 AGENTS.md 和 uad-fix-loop 修复失败测试，不要推送"`。
- Actions：gh-aw `engine: codex` 需 `OPENAI_API_KEY`（付费，需批准）；理论上可设 `OPENAI_BASE_URL` 指向 DeepSeek，**未验证**。

## Claude Code（未验证：需要 Anthropic 账号/API，未获批准）
- 规则：`CLAUDE.md` 指向 `AGENTS.md`。
- 技能：`/plugin install superpowers@claude-plugins-official`；本仓库 skills 复制到 `.claude/skills/`。
- Actions：gh-aw `engine: claude` 需 `ANTHROPIC_API_KEY`；DeepSeek 提供 Anthropic 兼容端点 `https://api.deepseek.com/anthropic`（`ANTHROPIC_BASE_URL`），**未验证**。
