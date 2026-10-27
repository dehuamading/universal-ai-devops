#!/usr/bin/env bash
# 从测试日志提取失败用例列表并计算签名。用法：uad-signature.sh <out_dir>
# 输出：<out_dir>/failing.txt；stdout 打印 12 位签名。
# 规则：只保留“失败用例名”，去掉序号、耗时、断言值、错误信息，保证
#   同一组失败 → 同一签名；不同失败用例 → 不同签名。
set -u
out="${1:-.uad-out}"
shopt -s nullglob
files=("$out"/*.log "$out"/*.tap)
{
  for f in "${files[@]}"; do cat "$f"; done
} | grep -E '^\s*not ok [0-9]+ |^(FAILED|ERROR) ' \
  | sed -E 's/^\s+//; s/^not ok [0-9]+ - /not ok /; s/ # .*$//; s/^((FAILED|ERROR) [^ ]+) - .*/\1/' \
  | grep -vE '^not ok .*\.(js|mjs|cjs|ts)$' \
  | sort -u > "$out/failing.txt"
sha256sum "$out/failing.txt" | cut -c1-12
