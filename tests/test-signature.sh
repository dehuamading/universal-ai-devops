#!/usr/bin/env bash
# 签名提取回归测试（不需要网络、不调用 AI）
set -u; cd "$(dirname "$0")/.."; S=tools/uad-signature.sh; pass=0; fail=0; T=$(mktemp -d)
sig(){ d=$T/$1; mkdir -p $d; printf '%b' "$2" > $d/$3; bash $S $d; }
chk(){ if [ "$2" "$1" "$3" ]; then pass=$((pass+1)); echo "✅ $4"; else fail=$((fail+1)); echo "❌ $4 ($2 vs $3)"; fi; }
E0=$(printf '' | sha256sum | cut -c1-12)
a=$(sig n1 'TAP version 13\nnot ok 1 - subtotal 按数量累加\n  ---\n  duration_ms: 1.2\nok 2 - x\n' test.tap)
b=$(sig n2 'TAP version 13\nok 1 - subtotal 按数量累加\nnot ok 2 - 合同条款：所有订单一律收 8 元运费\n' test.tap)
c=$(sig n3 'TAP version 13\nok 9 - y\nnot ok 4 - subtotal 按数量累加 # time=3ms\n' test.tap)
d=$(sig n4 '    not ok 1 - subtotal 按数量累加\nnot ok 1 - test/unit/cart.test.js\n' test.tap)
chk = "$a" "$c" "Node：同一失败（序号/耗时不同）→ 同一签名"
chk = "$a" "$d" "Node：子测试缩进与文件级汇总行不影响签名"
chk != "$a" "$b" "Node：不同失败 → 不同签名"
chk != "$a" "$E0" "Node：失败时签名不是空文件哈希"
p=$(sig p1 'FAILED tests/test_inventory.py::test_low_stock_boundary - assert False is True\n1 failed\n' test.log)
q=$(sig p2 'FAILED tests/test_inventory.py::test_low_stock_boundary - assert 7 == 3\n' test.log)
r=$(sig p3 'FAILED tests/test_contract.py::test_contract_tax_8_percent - assert 10600 == 10800\n' test.log)
s=$(sig p4 'FAILED tests/test_contract.py::test_contract_tax_8_percent - assert 10600 == 10800\nFAILED tests/test_inventory.py::test_low_stock_boundary - x\n' test.log)
mkdir -p $T/p5; printf 'FAILED tests/test_contract.py::test_contract_tax_8_percent - a\n' > $T/p5/console.log; printf 'FAILED tests/test_contract.py::test_contract_tax_8_percent - a\n' > $T/p5/test.log; u=$(bash $S $T/p5)
chk = "$p" "$q" "Python：同一用例、断言值不同 → 同一签名"
chk != "$p" "$r" "Python：不同用例 → 不同签名"
chk != "$s" "$r" "Python：多一个失败用例 → 不同签名"
chk = "$u" "$r" "Python：console.log 与 test.log 重复行去重"
mkdir -p $T/e; v=$(bash $S $T/e); chk = "$v" "$E0" "无日志 → 空签名（只在 env/pass 出现，门禁不会调用 AI）"
echo "通过 $pass，失败 $fail"; [ $fail -eq 0 ]
