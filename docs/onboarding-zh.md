# 新项目接入教程（约 10 分钟）

前提：仓库在 GitHub；若是私有仓库且为免费账号，规则集/分支保护不可用（见 security-zh.md）。

1. 复制模板：
   - `templates/workflows/ci.yml`、`uad-intake.yml`、`uad-after-fix.yml` → `.github/workflows/`，把 `__STACK__` 改成 `node` / `python`。
   - `templates/gh-aw/uad-fix.md` → `.github/workflows/uad-fix.md`，替换 `__BASH_ALLOW__`（允许的命令）、`__SETUP__`（安装依赖）、`__TEST_CMD__`（复现命令）。参考 examples 中两个沙箱。
   - `AGENTS.md`（可在末尾追加项目业务规则）、`templates/uad.config.yml` → 根目录；`docs/business-rules.md` 写核心业务规则（B 级保护）。
2. 编译 gh-aw：`gh extension install github/gh-aw && gh aw compile --approve`（会生成 `uad-fix.lock.yml`，提交它）。
3. 设置 Secret：`DEEPSEEK_API_KEY`（只放在 Actions Secrets）。
4. 设置 Variables：`UAD_AI_ENABLED=true`、`UAD_BALANCE_START=<当前余额>`（先运行 uad-balance 工作流查看）、`UAD_BUDGET_STOP_CNY`、`UAD_MAX_AI_RUNS_PER_DAY`。
5. 规则集：`gh api -X POST repos/<owner>/<repo>/rulesets --input templates/ruleset-main.json`。
6. 验证：运行 `uad-push-probe`（应显示三种写 main 操作均被拒绝）。
7. 之后：推送 → 失败自动进入修复闭环；需求 issue 加 `uad-request` 标签 → AI 分级，B 级只出方案。
