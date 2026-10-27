#!/usr/bin/env bash
# Python 适配器（pytest）。用法: run.sh <A|B|C>；退出码 0=通过 10=测试失败 20=环境失败
set -u
TIER="${1:-A}"; OUT="${UAD_OUT:-.uad-out}"; mkdir -p "$OUT"
log(){ echo "[uad-python] $*"; }
python -m pip install -q pytest >"$OUT/install.log" 2>&1 || { log "pytest 安装失败 → 环境问题"; exit 20; }
if [ -f requirements.txt ]; then python -m pip install -q -r requirements.txt >>"$OUT/install.log" 2>&1 || { log "依赖安装失败 → 环境问题"; exit 20; }; fi
# A 级静态检查：编译所有 py 文件
python -m compileall -q $(git ls-files '*.py') >"$OUT/static.log" 2>&1 || { log "语法检查失败"; cat "$OUT/static.log"; exit 10; }
case "$TIER" in A) M="${UAD_PY_MARK_A:-not core and not full}";; B) M="${UAD_PY_MARK_B:-not full}";; C) M="";; esac
if [ -n "$M" ]; then python -m pytest -q -m "$M" -rA --junitxml="$OUT/junit.xml" >"$OUT/test.log" 2>&1; else python -m pytest -q -rA --junitxml="$OUT/junit.xml" >"$OUT/test.log" 2>&1; fi
rc=$?; cat "$OUT/test.log"
case $rc in 0|5) exit 0;; 1) exit 10;; *) log "pytest 内部/用法错误 rc=$rc → 环境问题"; exit 20;; esac
