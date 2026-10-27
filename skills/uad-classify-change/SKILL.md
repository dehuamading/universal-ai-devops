---
name: uad-classify-change
description: 判定一项修改属于 A（可自动修复）/B（需批准）/C（受保护）级。任何修改代码之前使用。
---
# uad-classify-change
依据 `AGENTS.md` 第二节与项目 `uad.config.yml` 的 `policy.b_paths`、`docs/business-rules.md`。
判定规则（命中任一即升级）：
- 需要改变业务规则文档中的数值/规则 → B
- 两个测试互相矛盾、或只有修改测试断言才能通过 → B（无法自动修复）
- 新增/删除功能、公共 API 签名、模型或架构变化、跨多个核心模块 → B
- 合并/推送 main、发布、部署、删数据、强推、改密钥/权限、新增付费 → C
- 其余：单个函数内的明确错误、测试已覆盖 → A
输出一行：`等级: A|B|C；理由: ...`，写入报告。
