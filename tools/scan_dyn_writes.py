# -*- coding: utf-8 -*-
"""src/ 里「Dynamic 接收者的字段写」静态扫描（#10 真机 Invalid field 系列坑）。

背景：AS3 在素材剪辑/匿名对象上随手挂属性或写真属性，翻译后接收者是
Dynamic——cpp（android）上 Dynamic 字段裸写按类字段表查找：openfl 没有
该属性（tipText/enabled 类）直接抛 "Invalid field" 进程死亡；openfl 有的
真属性（x/text 类）也不保证走 setter（js/eval 落影子字段，#8 教训）。
html5/eval 单测全绿拦不住，只有真机现形。

正确写法三选一（见 CLAUDE.md 语言差异节）：
  1. openfl 真属性 → cast 回真类型写（cast(x, TextField).text = ...）
  2. 原版动态属性 → shim.ClipProps 侧表（读写同通道）
  3. 时间轴具名子件 → As3.childOf 取出再按 1/2 处理

本扫描是启发式（源码级、无类型信息）：跟踪 Dynamic 声明 + 动态生产者
（Utils.getMaterial/Reflect.field/As3.childOf/...）赋值的变量，列出它们
上面的字段写。有误报（cast 过的、上游类型其实确定的），清单供人/agent
triage，不作硬门禁。

用法：python tools/scan_dyn_writes.py [src 目录，默认 ./src]
输出：file:line	变量	属性	代码行
"""
import os
import re
import sys

sys.stdout.reconfigure(encoding="utf-8")

SRC = sys.argv[1] if len(sys.argv) > 1 else os.path.join(
    os.path.dirname(os.path.abspath(__file__)), "..", "src")

IDENT = r"[A-Za-z_][A-Za-z0-9_]*"

# 返回 Dynamic 的生产者（接收者上的一切字段写都算动态）
PRODUCER = re.compile(
    r"(Utils\.getMaterial|Reflect\.field|Reflect\.getProperty|"
    r"As3\.childOf|As3\.getProperty)\s*\(")

# var x:Dynamic / private var x:Dynamic（局部与类字段都收）
DECL_DYN = re.compile(r"\bvar\s+(" + IDENT + r")\s*:\s*Dynamic\b")
DECL_ARR_DYN = re.compile(r"\bvar\s+(" + IDENT + r")\s*:\s*Array<Dynamic>")

# x = <producer>(...)（含 var x = ...）：本行起视为动态
ASSIGN_PRODUCER = re.compile(
    r"\b(?:var\s+)?(" + IDENT + r")\s*=\s*[^;=\n]*" + PRODUCER.pattern)

# 字段写：x.prop = / x[i].prop = / x["k"].prop =（==、>= 等由 =[^=>] 排除）
FIELD_WRITE = re.compile(
    r"(" + IDENT + r")((?:\[[^\]]*\])*)\.(" + IDENT + r")\s*=(?![=>])")

# 同一行之前被 cast 过的变量（cast(x, T).p = 形态本来就匹配不到 ident 开头；
# x = cast(...) 之后的写按类型安全跳过——简化为行内记录）
SKIP_MARK = "scan_dyn_writes:skip"


def scan_file(path):
    with open(path, "r", encoding="utf-8") as f:
        lines = f.readlines()
    dyn_vars = set()
    hits = []
    for i, line in enumerate(lines, 1):
        stripped = line.strip()
        if stripped.startswith("//") or stripped.startswith("*"):
            continue
        for m in DECL_DYN.finditer(line):
            dyn_vars.add(m.group(1))
        for m in DECL_ARR_DYN.finditer(line):
            dyn_vars.add(m.group(1))
        for m in ASSIGN_PRODUCER.finditer(line):
            dyn_vars.add(m.group(1))
        for m in FIELD_WRITE.finditer(line):
            var = m.group(1)
            prop = m.group(3)
            if var in dyn_vars:
                hits.append((path, i, var, prop, stripped))
    return hits


def main():
    total = 0
    for root, _dirs, files in os.walk(SRC):
        for name in sorted(files):
            if not name.endswith(".hx"):
                continue
            for path, i, var, prop, code in scan_file(os.path.join(root, name)):
                rel = os.path.relpath(path, os.path.dirname(SRC))
                print(f"{rel}:{i}\t{var}\t.{prop}\t{code}")
                total += 1
    print(f"-- {total} dynamic field writes")


if __name__ == "__main__":
    main()
