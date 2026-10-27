#!/usr/bin/env python3
"""UAD 补丁守卫（确定性，不调用 AI）。替代 gh-aw 默认的 Copilot 威胁检测。
检查 AI 生成的补丁：禁止修改 CI/权限文件、禁止删除或弱化测试、禁止出现疑似密钥。
用法: uad-guard.py <patch文件...>   退出码 0=通过 1=拒绝"""
import re, sys
TEST = re.compile(r'(^|/)(tests?|__tests__|spec)/|(_test|\.test|\.spec|test_)[^/]*$')
ASSERT = re.compile(r'\b(assert|expect|assertEqual|assert\.\w+|strictEqual|deepStrictEqual|toBe|toEqual)\b')
WEAKEN = re.compile(r'(\.skip\(|\.only\(|\btest\.todo|pytest\.mark\.(skip|xfail)|@unittest\.skip|\bxit\(|\bxdescribe\(|--no-verify)')
SECRET = re.compile(r'(sk-[A-Za-z0-9]{20,}|github_pat_[A-Za-z0-9_]{20,}|ghp_[A-Za-z0-9]{20,}|-----BEGIN [A-Z ]*PRIVATE KEY)')
PROTECTED = re.compile(r'^(\.github/|AGENTS\.md$|CLAUDE\.md$|uad\.config\.yml$|docs/business-rules\.md$|package-lock\.json$|\.gitleaks)')
def main(paths):
    errs=[]; f=None; stats={}
    for p in paths:
        for line in open(p, encoding='utf-8', errors='replace'):
            if line.startswith('diff --git'):
                f=line.split(' b/',1)[-1].strip(); stats.setdefault(f,[0,0])
                if PROTECTED.search(f): errs.append(f'修改了受保护文件: {f}')
            elif line.startswith('deleted file mode') and f and TEST.search(f): errs.append(f'删除了测试文件: {f}')
            elif line.startswith('+') and not line.startswith('+++'):
                if SECRET.search(line): errs.append(f'疑似密钥: {f}')
                if f and TEST.search(f) and WEAKEN.search(line): errs.append(f'弱化测试（skip/only/xfail）: {f}: {line.strip()[:80]}')
                if f and TEST.search(f) and ASSERT.search(line): stats[f][0]+=1
            elif line.startswith('-') and not line.startswith('---'):
                if f and TEST.search(f) and ASSERT.search(line): stats[f][1]+=1
    for f,(a,d) in stats.items():
        if d>a: errs.append(f'测试断言减少: {f}（删除 {d}，新增 {a}）')
    if errs:
        print('UAD 守卫：拒绝补丁'); [print(' -',e) for e in sorted(set(errs))]; return 1
    print(f'UAD 守卫：通过（检查 {len(stats)} 个文件）'); return 0
if __name__=='__main__': sys.exit(main(sys.argv[1:]) if len(sys.argv)>1 else 0)
