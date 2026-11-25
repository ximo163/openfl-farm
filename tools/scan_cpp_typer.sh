#!/usr/bin/env bash
# cpp typer 全量 include 扫描（issue #61 固化；收工/审查的机械自检，
# CLAUDE.md「收工与审查的机械自检」条列为本脚本）。
#
# 为什么需要：静态目标（android/cpp）上 null 不能当 Int、Dynamic 字符串键
# 下标、Float→Int 这类错在 eval/html5/单测全绿，容器里又编不了 android，
# 唯一的全量编译检查就是本扫描——typer 错误在 hxcpp 后端生成**之前**全量
# 出，hxcpp 未装也能查。recipe 此前只是 handbook/lessons 的 prose（#18 首创、
# #19/#29 补配置坑），执行靠 agent 自觉：#37 没跑，WaterModel.hx:310 的
# Int==null 漏上 main，android CI 连红 8 次、APK 断 2.5 天才由 #60 手工修掉
# （#44 曾用扫描逮住它但只记了 lesson，归属 issue 已关、无人承接——教训：
# 教训日志不是工单池）。本脚本把 recipe 变成一条命令。
#
# recipe（lessons #18/#29/#44 已验证，固化时别偏离）：
#   - 起点：export/html5/haxe/debug.hxml（不在先 haxelib run openfl build
#     html5 生成）的 classpath 与**前三个** --macro
#     （ExtraParams/DefineMacro/AssetsMacro，#18）。
#   - 去掉 html5 专属 -D（lime-webgl/lime-dom/howlerjs/lime-html5/
#     no-compilation——#18/#29；2026-11-25 容器实测补齐 html5/web/
#     openfl-html5/lime-howlerjs/lime-canvas：留任一都会把 js 包 import 拉进
#     cpp 目标报 "You cannot access the js package while targeting cpp"，形似
#     代码错实为配置错）与 -main ApplicationMain。
#   - 加 -cpp <tmp> + --macro include('', true, ['mx.core.mx_internal'],
#     ['src'])——classPaths 必须限 ['src']（#18：不限会把 swf 库 classpath 根的
#     SWFTimelineContainer 扫进来报无关错）；exclude 表用全限定名
#     mx.core.mx_internal（#29：小写模块名解析器拒载，传 'mx_internal' 照红）。
#   - 通过判据：输出末尾只剩 `Error: Library hxcpp is not installed`（Build
#     failed）＝ typer 已过、类型层干净；出现在它之前的任何 error 都是命中。
#     hxcpp 未装没关系——typer 错误在后端生成之前全量出。haxe 退出码不判
#     （判据绿时 haxe 同样退 1；#29：留 -D no-compilation 则 0 错 0 输出退 0，
#     同样不是判据形态——尾巴必须在场）。
#
# 行变换与判据本体在 tools/tools/CppTyperPlan.hx / CppTyperVerdict.hx（纯
# 逻辑，契约由 test/tools/CppTyperPlanTest.hx / CppTyperVerdictTest.hx 钉死，
# `haxe test.hxml` 跑）；本脚本经 tools/tools/CppTyperScan.hx（脚本侧胶水）
# 拉起它们。
#
# 用法（仓库任意位置）：bash tools/scan_cpp_typer.sh
# 退出码：0＝类型层干净；1＝命中/形状外失败（命中行打全，file:line 不截断）；
# 2＝用法/环境错。命中后先 stash 对比分清「本片新引入」还是「main 既有」
# （#44）；main 既有只报告、不顺手修，但必须当场开 issue 跟踪（#37/#44/#60）。

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$REPO_ROOT" || exit 2

DEBUG_HXML="export/html5/haxe/debug.hxml"

# 1) 起点：debug.hxml 不在先跑一次 html5 构建生成（新容器/CI 里 export/ 不存在；
#    assets/legacy 未同步时构建只 warn 缺库文件、debug.hxml 照样产出——两种形状
#    的 classpath 都能扫，write-tests 的 fixture 即无资产形状）
if [ ! -f "$DEBUG_HXML" ]; then
    echo "scan_cpp_typer: $DEBUG_HXML 不在，先 haxelib run openfl build html5 生成" >&2
    if ! haxelib run openfl build html5 >&2; then
        echo "scan_cpp_typer: openfl build html5 失败，没有 debug.hxml 可扫" >&2
        exit 2
    fi
fi

# 2) 临时件（单个工作目录收口，trap 一次清干净）：-cpp 输出目录（hxcpp 未装、
#    不会真写进去）、扫描 hxml（haxe 只认 .hxml 后缀的配置文件，无后缀报
#    "Could not process argument"）、输出捕获
WORK="$(mktemp -d /tmp/cppscan.XXXXXX)" || exit 2
SCAN_HXML="$WORK/scan.hxml"
OUT_TXT="$WORK/out.txt"
CPP_OUT="$WORK/cpp"
mkdir -p "$CPP_OUT" || exit 2
trap 'rm -rf "$WORK"' EXIT

# 3) 按 recipe 变换 debug.hxml → 临时扫描 hxml（行集变换在 CppTyperPlan）
if ! haxe -cp tools --run tools.CppTyperScan plan "$DEBUG_HXML" "$CPP_OUT" "$SCAN_HXML" >&2; then
    echo "scan_cpp_typer: 扫描 hxml 生成失败" >&2
    exit 2
fi

# 4) 全量 include 扫描。2>&1 合并捕获（typer 错误与尾巴走 stderr、Build.xml
#    回显走 stdout）；退出码不判（见头注），文本判据归 CppTyperVerdict
haxe "$SCAN_HXML" >"$OUT_TXT" 2>&1

# 5) 判据收尾：打报告并 exit 0/1
haxe -cp tools --run tools.CppTyperScan judge "$OUT_TXT"
exit $?
