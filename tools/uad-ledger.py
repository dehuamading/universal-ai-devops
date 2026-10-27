#!/usr/bin/env python3
"""UAD 费用账本：根据 token 数与调用时间（UTC）按 DeepSeek 官方价计算人民币费用。
用法：uad-ledger.py <ledger.csv>；CSV 列：run_url,utc_time,input_miss,input_hit,output
价格（USD / 1M tokens，deepseek-flash）：输入 0.15，缓存命中 0.003，输出 0.60；
高峰（UTC 周一至周五 01-04、06-10 点）×2。汇率默认 7.2，可用 UAD_FX 覆盖。"""
import csv, os, sys, datetime as dt
FX = float(os.environ.get("UAD_FX", "7.2"))
P = {"miss": 0.15, "hit": 0.003, "out": 0.60}
def peak(t):
    return t.weekday() < 5 and (1 <= t.hour < 4 or 6 <= t.hour < 10)
tot = 0.0
for r in csv.DictReader(open(sys.argv[1])):
    t = dt.datetime.fromisoformat(r["utc_time"].replace("Z", "+00:00"))
    m = 2 if peak(t) else 1
    usd = m * (int(r["input_miss"]) * P["miss"] + int(r["input_hit"]) * P["hit"] + int(r["output"]) * P["out"]) / 1e6
    tot += usd * FX
    print(f'{r["run_url"]}\t{"高峰" if m == 2 else "平峰"}\t¥{usd * FX:.4f}')
print(f"合计 ¥{tot:.4f}")
