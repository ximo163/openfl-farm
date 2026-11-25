# -*- coding: utf-8 -*-
"""跨树重复模块路径机器门（issue #70 交付物 2）的 python 壳。

为什么这门存在：-cp tools 之后（test.hxml）test/、tools/、src/ 三棵树共享
包空间，Haxe 对跨 classpath 的同名模块**静默按 -cp 顺序取先者**——不报错
（#56 的 import.hx 事件证明这种遮蔽能同时骗过 agent、review 和 verify；
69 资产门禁的 test/tools/import.hx 靠它活着，反过来它也能吞掉真正的同名
冲突）。模块路径重复（包声明 + 文件名，与目录无关）是这个机制的触发条件，
枚举报警，不靠记忆。

判式单源：包声明解析/模块路径拼装/查重/渲染在 tools/tools/
ModulePathScan.hx——契约由 test/tools/ModulePathScanTest.hx 钉死
（`haxe test.hxml` 跑）；走三棵树/拼报告/exit 码在 tools/tools/
ModulePathScanRun.hx（脚本侧胶水，DynWriteScanRun 先例）。本壳只锚定仓库
根、拉起 haxe、透传输出与退出码——判式不在 python 半边留第二份拷贝
（#63 教训：双实现改判式必须两侧同步改，diff 非空即漂移）。

用法（仓库任意 cwd）：python tools/scan_module_paths.py
（容器里无 `python` 别名时用 `python3`；接线片段见
handbook/architecture/test-tree-gates.md）
退出码：0 = 三棵树模块路径零重复；1 = 有冲突组（判式半边编译失败时 haxe
同样退非零——门跑不起来＝不放行）；2 = 环境错（haxe 不在、缺树）。
"""
import os
import subprocess
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


def main():
    # --run 的参数原样传给 Sys.args()（scan_cpp_typer.sh 同款形态）；
    # 绝对根让 runner 与 cwd 无关
    cmd = ["haxe", "-cp", "tools", "--run", "tools.ModulePathScanRun", ROOT]
    try:
        proc = subprocess.run(cmd, cwd=ROOT)
    except FileNotFoundError:
        sys.stderr.write(
            "scan_module_paths: 找不到 haxe——判式在 Haxe 半边"
            "（tools/tools/ModulePathScan.hx），haxe 不在没法跑\n")
        return 2
    return proc.returncode


if __name__ == "__main__":
    sys.exit(main())
