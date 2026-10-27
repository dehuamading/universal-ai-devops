# 安全模型（universal-ai-devops）

| 防线 | 机制 | 是否已实测 |
|---|---|---|
| AI 不能写 main | 规则集 `uad-protect-main`：必须 PR + 1 个审批 + `test / run` 通过；禁止强推、删除；**无绕过者**（管理员也不例外） | 是：GITHUB_TOKEN(contents:write) 与管理员令牌直推/强推/删除均被 GH013 拒绝 |
| AI 作业只读 | gh-aw agent 作业权限 `contents: read`，写操作只能经 safe-outputs（草稿 PR / issue / 评论 / 白名单标签） | 是（lock 文件） |
| 不自动合并 | safe-outputs 无 merge 能力；PR 强制 draft；需人工审批 | 是 |
| 补丁守卫 | `tools/uad-guard.py` 在 threat-detection 阶段与回归阶段两次检查：禁止改 `.github/`、规则文件、业务规则文档、删测试、加 skip/xfail、减少断言、写入密钥 | 本地单测通过 |
| 网络隔离 | AWF 防火墙：仅 defaults/node/python/api.deepseek.com | 是（lock 文件） |
| 费用 | 预调用门禁：DeepSeek 账户真实余额 vs 起点，达到停止线即拒绝；每日次数上限；同一签名只 1 次 AI 运行；运行内 max-turns/max-tool-calls/maxRuns=20 请求上限；总开关 `UAD_AI_ENABLED` | 是 |
| 密钥 | DeepSeek 密钥只在 Actions Secrets；日志自动打码；gitleaks 每次推送前扫描 | 是 |

注意：Secret 不是费用控制；余额门禁是“调用前”检查，单次运行内的最坏花费由 maxRuns=20 限定，所以停止线低于总预算并留出余量。
