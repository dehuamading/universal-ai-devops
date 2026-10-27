# Android 适配器（设计，已在私有项目中运行过同类实现，本仓库不含任何私有代码）
- A 级：Gradle `lint` + 单元测试（`./gradlew testDebugUnitTest`）+ 测试脚本自检；约 3 分钟。
- B 级：构建 APK（可复用工作流）→ Android Emulator（AVD 快照缓存）→ Maestro flows；可按分片并行（matrix）；测试替身/模拟输入代替真实硬件。
- C 级：稳定性/长时测试，仅手动触发；需要真机的项目标记为 C。
- 接入方式：项目保留自己的模拟器工作流，在 `ci.yml` 的 `test` job 用 `workflow_call` 调用它，并输出 `kind`（pass/test/env）与 `signature`，即可接入 uad-gate / uad-fix。
- 状态：通用框架内**未在 Android 项目上验证**。
