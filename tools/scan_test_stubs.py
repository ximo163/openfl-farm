# -*- coding: utf-8 -*-
"""test/ 禁 throw-stub 机器门（issue #70 交付物 1）的 python 壳。

为什么这门存在：#56 事故（write-tests 把 stub 放进 test/，implement 被
test/** append-only 驳回、被迫发明 import.hx 遮蔽，$11 教训）的规则收口
已落地（test.hxml 加 -cp tools + write-tests「stub 归树」规矩，commit
f047e273），本门是它的机器化——标准不变量：test/ 是定稿区。错放的 stub
在 write-tests 的 verify 当场拦截，而不是烧完 implement 才撞 append-only
墙。

判式单源：命中判式（字符串遮罩→剔 // 注释→语句位 throw 惯用语族→遮罩前
逐字短语）、豁免清单（#56 两僵尸，迁移期，清理后清空）都在
tools/tools/TestStubScan.hx——契约由 test/tools/TestStubScanTest.hx 钉死
（`haxe test.hxml` 跑）；走目录/拼报告/exit 码在 tools/tools/
TestStubScanRun.hx（脚本侧胶水，DynWriteScanRun 先例）。本壳只锚定仓库
根、拉起 haxe、透传输出与退出码——判式不在 python 半边留第二份拷贝
（#63 教训：双实现改判式必须两侧同步改，diff 非空即漂移）。

用法（仓库任意 cwd）：python tools/scan_test_stubs.py
（容器里无 `python` 别名时用 `python3`；CI 接线命令见 issue #70）
退出码：0 = 净命中 0 且无失锚豁免；1 = 有净命中/失锚豁免（判式半边编译
失败时 haxe 同样退非零——门跑不起来＝不放行，失败方向一致）；2 = 环境
错（haxe 不在、test/ 缺失）。
"""
import os
import subprocess
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


def main():
    # --run 的参数原样传给 Sys.args()（scan_cpp_typer.sh 同款形态）；
    # 绝对根让 runner 与 cwd 无关，豁免条目的逐字匹配不依赖调用位置
    cmd = ["haxe", "-cp", "tools", "--run", "tools.TestStubScanRun", ROOT]
    try:
        proc = subprocess.run(cmd, cwd=ROOT)
    except FileNotFoundError:
        sys.stderr.write(
            "scan_test_stubs: 找不到 haxe——判式在 Haxe 半边"
            "（tools/tools/TestStubScan.hx），haxe 不在没法跑\n")
        return 2
    return proc.returncode


if __name__ == "__main__":
    sys.exit(main())
