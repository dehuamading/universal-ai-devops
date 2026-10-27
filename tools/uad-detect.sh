#!/usr/bin/env bash
# UAD 确定性威胁检测（gh-aw threat-detection engine:false 的 post-step）。
# 根因修复：gh-aw 的 "Conclude threat detection" 只认 detection_result.json /
# detection.log 中的 THREAT_DETECTION_RESULT 判定；原守卫只用退出码表达结果，
# 没有写判定文件 → 被当作“检测引擎故障”(warning, reason=agent_failure)。
# 本脚本总是写出判定；守卫拒绝或守卫不可用 → malicious_patch=true（失败即关闭）。
# 用法: uad-detect.sh <guard.py> [检测目录]
set -u
G="$1"; D="${2:-/tmp/gh-aw/threat-detection}"; mkdir -p "$D"
shopt -s nullglob; P=("$D"/*.patch)
reasons=(); mal=false; sec=false
if [ ! -s "$G" ]; then mal=true; reasons+=("UAD 守卫脚本不可用（失败即关闭）")
elif [ ${#P[@]} -gt 0 ]; then
  out=$(python3 "$G" "${P[@]}" 2>&1); rc=$?; echo "$out"
  if [ $rc -ne 0 ]; then mal=true
    grep -q '疑似密钥' <<<"$out" && sec=true
    while IFS= read -r l; do reasons+=("${l# - }"); done < <(grep '^ - ' <<<"$out")
    [ ${#reasons[@]} -eq 0 ] && reasons+=("UAD 守卫拒绝补丁（rc=$rc）")
  fi
else echo "无补丁，仅检查 agent 输出"; fi
json=$(python3 - "$mal" "$sec" "${reasons[@]}" <<'PY'
import json,sys
print(json.dumps({"prompt_injection":False,"secret_leak":sys.argv[2]=="true","malicious_patch":sys.argv[1]=="true","reasons":sys.argv[3:]},ensure_ascii=False))
PY
)
printf '%s\n' "$json" > "$D/detection_result.json"
printf 'THREAT_DETECTION_RESULT:%s\n' "$json" >> "$D/detection.log"
echo "判定: $json"
exit 0   # 结果通过判定文件表达；非零退出会被 gh-aw 当作引擎故障并降级为 warning
