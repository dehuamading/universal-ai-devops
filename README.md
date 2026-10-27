# universal-ai-devops

通用 AI 自动开发 / 测试 / 修复框架。**不重复造轮子**：
- 开发方法：[obra/superpowers](https://github.com/obra/superpowers)（固定 v7.0.1）
- Actions 中运行智能体：[github/gh-aw](https://github.com/github/gh-aw)（已验证 v0.93.5，Pi 引擎 + DeepSeek V4.1 Flash）
- 本仓库只提供薄胶水：统一规则 `AGENTS.md`、3 个技能、可复用工作流、测试适配器、策略与模板。

## 闭环
```
push → ci（uad-test：适配器 A 级测试，零 AI）
  ├─ 通过 → 结束（不调用 AI）
  ├─ 环境问题 → uad-gate 开 issue 报告（不调用 AI，不改代码）
  └─ 测试失败 → uad-gate（总开关 → DeepSeek 实际余额预算 → 每日上限 → 同一问题上限）
        → uad-fix（gh-aw + Pi + Superpowers，只读沙箱）
            ├─ A 级：检查点 → 修复（≤2 次）→ 测试 → 草稿 PR
            ├─ 失败：git reset 回检查点 → issue 报告
            └─ B/C 级：只写方案 + needs-approval
        → uad-guard 补丁守卫（替代 Copilot 威胁检测）→ safe-outputs 写入
  → uad-after-fix → uad-regression：在 PR 上回归 + 写必需状态 "test / run"
  → 人工审查批准 → 人工合并（规则集：main 必须 PR + 1 个批准 + 状态检查，禁止强推/删除）
```

## 目录
| 目录 | 内容 |
|---|---|
| `AGENTS.md` | 所有智能体共用的规则与 A/B/C 权限 |
| `skills/` | uad-fix-loop、uad-classify-change、uad-report-zh（其余直接用 Superpowers） |
| `.github/workflows/` | 可复用：uad-test、uad-gate、uad-regression |
| `templates/` | 项目接入模板：ci.yml、uad-intake.yml、uad-after-fix.yml、uad-fix.md（gh-aw）、规则集、配置 |
| `adapters/` | node、python（已验证）；android（设计）；web、wechat-miniprogram（未验证） |
| `policies/` | levels.yml、budgets.yml |
| `tools/` | uad-guard.py（补丁守卫）、uad-ledger.py（费用台账） |
| `docs/` | 接入教程、安全说明、Pi/Codex/Claude Code 用法 |
| `examples/` | 两个沙箱：uad-sandbox-node、uad-sandbox-python |

许可证：MIT。
