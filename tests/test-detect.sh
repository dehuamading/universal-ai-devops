#!/usr/bin/env bash
# 威胁检测判定回归测试：确保总是写出 gh-aw 可解析的判定文件
set -u; cd "$(dirname "$0")/.."; pass=0; fail=0; T=$(mktemp -d)
ok(){ if eval "$1"; then pass=$((pass+1)); echo "✅ $2"; else fail=$((fail+1)); echo "❌ $2"; fi; }
v(){ python3 -c "import json,sys;print(json.load(open('$1/detection_result.json'))['$2'])"; }
mkdir $T/a; printf 'diff --git a/src/cart.js b/src/cart.js\n--- a/src/cart.js\n+++ b/src/cart.js\n-  x\n+  y\n' > $T/a/x.patch
bash tools/uad-detect.sh tools/uad-guard.py $T/a >/dev/null
ok '[ "$(v $T/a malicious_patch)" = False ] && grep -q "^THREAT_DETECTION_RESULT:{" $T/a/detection.log' "正常补丁 → 判定文件存在且 clean"
mkdir $T/b; printf 'diff --git a/.github/workflows/ci.yml b/.github/workflows/ci.yml\n+++ b/.github/workflows/ci.yml\n+ permissions: write-all\n' > $T/b/x.patch
bash tools/uad-detect.sh tools/uad-guard.py $T/b >/dev/null
ok '[ "$(v $T/b malicious_patch)" = True ]' "改 CI 文件 → malicious_patch=true"
mkdir $T/c; printf 'diff --git a/src/a.js b/src/a.js\n+++ b/src/a.js\n+const k="ghp_%s"\n' "$(printf 'A%.0s' {1..30})" > $T/c/x.patch
bash tools/uad-detect.sh tools/uad-guard.py $T/c >/dev/null
ok '[ "$(v $T/c secret_leak)" = True ]' "疑似密钥 → secret_leak=true"
mkdir $T/d; cp $T/a/x.patch $T/d/; bash tools/uad-detect.sh /nonexistent $T/d >/dev/null; rc=$?
ok '[ $rc -eq 0 ] && [ "$(v $T/d malicious_patch)" = True ]' "守卫不可用 → 失败即关闭（malicious_patch=true）"
mkdir $T/e; bash tools/uad-detect.sh tools/uad-guard.py $T/e >/dev/null
ok '[ -s $T/e/detection_result.json ]' "无补丁 → 仍写出判定"
for L in ${UAD_LOCKS:-}; do
  ok 'grep -q "uad-detect.sh" "$L" && grep -q "id: detection_agentic_execution" "$L"' "编译断言: $L 的 detection 作业包含 uad-detect.sh 判定步骤"
done
echo "通过 $pass，失败 $fail"; [ $fail -eq 0 ]
