---
name: uad-fix-loop
description: 测试失败后的自动修复闭环（universal-ai-devops）。在 CI 失败证据、修复失败测试、或被 uad-fix 工作流调用时使用。组合 Superpowers 的 systematic-debugging、test-driven-development、verification-before-completion。
---
# uad-fix-loop

前置：先读仓库根目录 `AGENTS.md`；再用 `uad-classify-change` 判定等级。

## 步骤（每个失败问题单独执行）
1. **证据**：读 `.uad-evidence/failure-summary.json` 与日志；在本地重跑失败测试复现（命令见 `uad.config.yml` 的 `test.related`）。
2. **根因**：调用 Superpowers `systematic-debugging`：读完整错误 → 复现 → 对照正常代码 → 单一假设 → 记录根因。
3. **分级**：A 继续；B/C 停止修改，只写方案。
4. **检查点**：`git add -A && git commit -qm "uad: checkpoint" --allow-empty`；记录 `BASE=$(git rev-parse HEAD)`。
5. **修复（TDD）**：失败测试就是 RED；做最小改动使其变 GREEN；禁止改测试断言（测试脚本 A 级错误除外，且不得降低标准）。
6. **验证**：调用 `verification-before-completion`：运行相关测试并全量运行 A 级测试，贴出命令和结果。
7. **尝试上限**：失败则第 2 次尝试；仍失败 → `git reset --hard $BASE` 回退，记录“已回退到 $BASE”，此问题标记为“无法自动修复”。
8. **输出**：有成功修复 → 草稿 PR（中文说明）；无法修复 / B 级 → issue（标签 needs-approval 或 uad-failed）。
