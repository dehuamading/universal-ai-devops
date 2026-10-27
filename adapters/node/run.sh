#!/usr/bin/env bash
# Node.js 适配器。用法: run.sh <A|B|C>
# 退出码: 0=通过 10=测试失败 20=环境失败
set -u
TIER="${1:-A}"; OUT="${UAD_OUT:-.uad-out}"; mkdir -p "$OUT"
log(){ echo "[uad-node] $*"; }
if [ -f package-lock.json ]; then npm ci --no-audit --no-fund >"$OUT/install.log" 2>&1 || { log "依赖安装失败 → 环境问题"; exit 20; }
elif grep -q '"dependencies"\|"devDependencies"' package.json 2>/dev/null; then npm install --no-audit --no-fund >"$OUT/install.log" 2>&1 || { log "依赖安装失败 → 环境问题"; exit 20; }; fi
# A 级：静态检查（语法）+ 单元测试
for f in $(git ls-files '*.js' '*.mjs' '*.cjs'); do node --check "$f" >>"$OUT/static.log" 2>&1 || { log "语法检查失败: $f"; cat "$OUT/static.log"; exit 10; }; done
case "$TIER" in
  A) PATTERN="${UAD_NODE_UNIT:-test/unit}";;
  B) PATTERN="${UAD_NODE_CORE:-test}";;
  C) PATTERN="${UAD_NODE_FULL:-test}";;
esac
FILES=$(find $PATTERN -name '*.test.*js' 2>/dev/null | sort)
[ -z "$FILES" ] && FILES=$(find test -name '*.test.*js' | sort)
node --test --test-reporter=tap $FILES >"$OUT/test.tap" 2>&1; rc=$?
cat "$OUT/test.tap"
[ $rc -eq 0 ] && exit 0 || exit 10
