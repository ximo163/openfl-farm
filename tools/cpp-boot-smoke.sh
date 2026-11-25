#!/usr/bin/env bash
# cpp linux 启动冒烟（issue #64）：把启动期 Reflect 写崩拦在 PR 阶段
# （#62 同族的运行期机器门）。
#
# 为什么需要：m_view.x = …（Dynamic 裸写 openfl get/set 属性）这类错编译全绿、
# cpp typer 扫描不报（类型层合法）、web/eval 容忍、android CI 编得过——唯一
# 现形场是真机运行（2026-11-24 真机栈实锤 WaterController.hx:366 闪退，
# PR #62 修复）。本脚本在 CI 里跑 hxcpp linux 二进制的启动冒烟：对着旧后端
# 把启动链走到场景装配，断言进程存活、无 Invalid field。#62 这种启动期崩
# 从此在 PR 阶段被机器拦下，不再烧真机轮次。
#
# 用法（仓库根）：bash tools/cpp-boot-smoke.sh
# 退出码：0＝三断言全过（冒烟绿）；1＝红（任一断言失败，tail 80 行进控制台）；
# 2＝用法/环境错（依赖缺失、构建失败一类——基建问题不是 app 红）。
#
# 流程（对齐 .github/workflows/web.yml 的 web-smoke 写法：后端拉起、探活、
# 断言、失败输出）：
#   1. 拉起旧后端（ci/legacy-backend-up.sh，快照在才起；退出码 3＝快照未提供
#      按「后端没起」处理——见下方断言 a 的归账语义）；
#   2. 后端探活（curl 健康口；探活失败输出明确的「后端没起」而不是让 app 红
#      背锅——// issue #64 断言 a/验收节）；
#   3. 构建 hxcpp linux 二进制（haxelib run openfl build linux -debug——必须
#      -debug：HXCPP_STACK_TRACE 异常栈采集只在 debug 配置，android.yml
#      2026-11-24 同款切换，先例 579f64d9；release 下闪退只有一行消息没有
#      Called from 栈）；
#   4. xvfb-run -a 起二进制（lime linux 要 SDL 窗口，无显示必挂——GitHub
#      托管 runner 标准做法），QFARM_BASE_URL 指到后端、stdout+stderr 合并
#      落盘、timeout 20s 兜底、后台起 + sleep 15 探活（启动链 ~1-2 秒到场景
#      装配，真机实证；15 秒足够覆盖进农场后的稳态）；
#   5. 三断言（// issue #64「断言（三条全过才绿）」节；判定本体在
#      tools/tools/BootSmokeVerdict.hx，契约由 test/tools/BootSmokeVerdictTest.hx
#      钉死，`haxe test.hxml` 跑）：
#      a. 后端探活先行（后端没起要输出明确的「后端没起」）；
#      b. 15 秒后进程仍活着（kill -0 探活）；
#      c. 运行日志无 Invalid field / Uncaught exception / Called from
#         （有栈即红，主断言）。
#   6. 失败输出：tail 最后 80 行日志进 CI 控制台（// issue #64 失败输出节）。
#
# 回归样例法验收（// issue #64 验收节）：对 WaterController.hx:366-367 临时
# revert 回 m_view.x = … 的修复前形态，冒烟必须红且日志带 Invalid field:x +
# Called from WaterController::initialze；恢复后必须绿。人为不拉后端时输出
# 「后端没起」且不冒充 app 红。

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$REPO_ROOT" || exit 2

# ---- 环境依赖（用法/环境错退 2——基建问题不是 app 红） ----
for dep in curl xvfb-run haxelib haxe timeout docker g++; do
    if ! command -v "$dep" >/dev/null 2>&1; then
        echo "cpp-boot-smoke: 缺依赖 $dep（linux 目标的 apt 依赖以 openfl/lime" >&2
        echo "  文档为准：xvfb 是 SDL 窗口的显示兜底、curl 探活后端、docker 是" >&2
        echo "  ci/legacy-backend-up.sh 的 compose 宿主、g++ 编 hxcpp）" >&2
        exit 2
    fi
done
# hxcpp 编译器库（libhxcpp 是 hxcpp 的继任者，android.yml 同款；openfl build
# linux 的 C++ 编译经它）。缺了 openfl build linux 必败——提前报明白
if ! haxelib list 2>/dev/null | grep -q "^libhxcpp:"; then
    echo "cpp-boot-smoke: 缺 haxelib 库 libhxcpp（android.yml 锁 6.0.0-rc.2——" >&2
    echo "  haxelib install libhxcpp 6.0.0-rc.2 && haxelib run libhxcpp setup）" >&2
    exit 2
fi

# ---- 临时件（单工作目录收口，trap 一次清干净；scan_cpp_typer.sh 同款） ----
WORK="$(mktemp -d /tmp/cppboot.XXXXXX)" || exit 2
LOG="$WORK/app.log"         # stdout+stderr 合并落盘（断言 c 的输入）
trap 'rm -rf "$WORK"' EXIT

# ---- [1/5] 拉起旧后端（ci/legacy-backend-up.sh 快照在才起，约 3-5 分钟） ----
# web.yml web-smoke 的同款写法：退出码 3＝快照未提供按无后端模式跑（此处即
# 「后端没起」的红——冒烟**必须**对着后端，没有快照就没有可冒烟的启动链），
# 其他非零＝基建失败原样退（exit code 透传，不冒充 app 红）。
echo "[1/5] 拉起旧后端（ci/legacy-backend-up.sh）"
BACKEND_UP=false
set +e
bash ci/legacy-backend-up.sh "$WORK/backend"
rc=$?
set -e
if [ "$rc" -eq 0 ]; then
    BACKEND_UP=true
    echo "  后端起好（http://127.0.0.1:8089）"
elif [ "$rc" -eq 3 ]; then
    echo "  legacy/snapshot 快照未提供——按「后端没起」跑（app 无数据可拉必死，红样例归账见下方断言 a）"
else
    echo "cpp-boot-smoke: 旧后端拉起失败（exit $rc）——基建/后端问题，非 app 红" >&2
    exit 2
fi

# ---- [2/5] 构建 hxcpp linux 二进制（-debug：HXCPP_STACK_TRACE 只在 debug） ----
# 资产同步先行（assets/legacy/ 不入库，构建时由脚本同步；web.yml 同款）。
# openfl build linux 需要 g++ 工具链——CI runner 自带（GitHub ubuntu-latest
# 预装 build-essential），缺了按环境错退 2。
echo "[2/5] 构建 hxcpp linux 二进制（haxelib run openfl build linux -debug）"
if ! bash scripts/sync-legacy-assets.sh >&2; then
    echo "cpp-boot-smoke: 资产同步失败——基建问题，非 app 红" >&2
    exit 2
fi
if ! haxelib run openfl build linux -debug >&2; then
    echo "cpp-boot-smoke: openfl build linux 失败——编译错/工具链问题，非 app 红" >&2
    echo "  （编译红在 CI 日志里直接可见，不是冒烟断言的失败形态）" >&2
    exit 2
fi

# 找二进制：openfl linux 产物在 export/linux/bin/ 下（ lime 的目录布局）
BIN="$(find export/linux -maxdepth 3 -type f -executable ! -name '*.so' ! -name '*.so.*' 2>/dev/null | head -1)"
if [ -z "$BIN" ]; then
    echo "cpp-boot-smoke: 找不到 linux 二进制（export/linux/bin/ 下没有可执行文件）" >&2
    echo "  openfl 产出的目录可能不同——调整本脚本的查找路径" >&2
    exit 2
fi
echo "  二进制：$BIN"

# ---- [3/5] 后端探活（断言 a 先行：后端没起要输出明确的「后端没起」） ----
# 后端刚起好时也再探一次（legacy-backend-up.sh 内部已等就绪，双探是幂等保险；
# 快照缺失时这里必失败——归账 backendDown）
echo "[3/5] 后端探活（curl 健康口）"
PROBE_OK=false
if [ "$BACKEND_UP" = true ]; then
    if curl -sf -o /dev/null "http://127.0.0.1:8089/home/qqfarm/core/xml.php?mod=nc_main"; then
        PROBE_OK=true
        echo "  后端探活通过（xml.php?mod=nc_main 200）"
    else
        echo "  后端探活失败（xml.php?mod=nc_main 非 200）"
    fi
fi
if [ "$PROBE_OK" = false ]; then
    # // issue #64 验收节：「人为不拉后端时输出『后端没起』且不冒充 app 红」
    # ——此处直接判红收尾，不起二进制（起了也必死，白等 15 秒），报告文案
    # 是明确的「后端没起」（环境失败），不记 app 崩
    echo ""
    echo "cpp-boot-smoke: FAIL —— 后端没起（环境失败，不是 app 红）"
    echo "  后端探活未通过：要么 legacy/snapshot 快照未提供，要么 127.0.0.1:8089 上的 xml.php 没回 200。修复后端/快照后重跑；本红与 app 代码无关。"
    exit 1
fi

# ---- [4/5] xvfb 起二进制，15 秒探活 ----
# xvfb-run -a（GitHub 托管 runner 标准做法）：lime linux 要 SDL 窗口，无显示
# 必挂。timeout 20s 兜底（二进制卡住不死时强杀——kill -0 探活判的是 15 秒
# 时点，timeout 只防「脚本本身挂住」）。QFARM_BASE_URL 指到后端（cpp 二进制
# 没有「源」，环境变量是唯一的基址入口——// issue #64 A.2）。
echo "[4/5] xvfb 起二进制，15 秒探活（QFARM_BASE_URL=http://127.0.0.1:8089）"
QFARM_BASE_URL="http://127.0.0.1:8089" \
    xvfb-run -a timeout 20s "$BIN" >"$LOG" 2>&1 &
APP_PID=$!
echo "  pid=$APP_PID，日志落盘 $LOG"
sleep 15

# 断言 b：15 秒后进程仍活着（kill -0 探活）。timeout 20s 还没到（15<20），
# kill -0 失败即「启动链没走到稳态」。
PROCESS_ALIVE=false
if kill -0 "$APP_PID" 2>/dev/null; then
    PROCESS_ALIVE=true
    echo "  15 秒后进程仍活着（pid $APP_PID）"
else
    echo "  15 秒内进程已死（pid $APP_PID 不存在）"
fi
# 收尾：还活着就杀掉（冒烟只覆盖启动链，稳态后没有继续跑的价值；kill 失败
# 不判——进程可能已经自己退了）
if [ "$PROCESS_ALIVE" = true ]; then
    kill "$APP_PID" 2>/dev/null || true
    wait "$APP_PID" 2>/dev/null || true
fi

# ---- [5/5] 三断言判定（判定本体在 tools/tools/BootSmokeVerdict.hx） ----
# bash 侧采集的三件（backendUp/processAlive/log 文本）以纯数据喂给被测类——
# 判定规则（三标记逐字子串、归账语义、tail 80 行边界）全在 eval 单测里钉死，
# bash 只剩进程编排。
echo "[5/5] 三断言判定"

# 判定结果经 haxe --run 输出机读行（judge 的胶水在 tools/tools/BootSmokeScan.hx，
# 与 CppTyperScan 同款分层）；解析键值行收尾。
JUDGE_OUT="$(haxe -cp tools --run tools.BootSmokeScan judge "$BACKEND_UP" "$PROCESS_ALIVE" "$LOG" 2>/dev/null || true)"
# 判定胶水本身失败（编译错等）按环境错退 2——基建问题不是 app 红
if [ -z "$JUDGE_OUT" ]; then
    echo "cpp-boot-smoke: 判定胶水（tools.BootSmokeScan）无输出——编译错/环境错" >&2
    exit 2
fi

VERDICT_PASS="$(echo "$JUDGE_OUT" | sed -n 's/^pass=//p' | head -1)"
VERDICT_BACKEND_DOWN="$(echo "$JUDGE_OUT" | sed -n 's/^backendDown=//p' | head -1)"
VERDICT_PROCESS_DIED="$(echo "$JUDGE_OUT" | sed -n 's/^processDied=//p' | head -1)"
CRASHED_COUNT="$(echo "$JUDGE_OUT" | sed -n 's/^crashedCount=//p' | head -1)"

# 报告（红时 tail 最后 80 行进 CI 控制台——// issue #64 失败输出节）
if [ "$VERDICT_PASS" = "true" ]; then
    echo "cpp-boot-smoke: PASS —— 三断言全过（后端探活通过、15 秒进程存活、日志无 Invalid field/Uncaught exception/Called from），启动链走到场景装配"
    exit 0
fi

echo ""
echo "cpp-boot-smoke: FAIL —— 启动冒烟红（#62 同族的启动期 Reflect 写崩拦在 PR 阶段）"
if [ "$VERDICT_BACKEND_DOWN" = "true" ]; then
    echo "  归账：后端没起（环境失败，不是 app 红）——本不该走到这（断言 a 先行"
    echo "  已拦），若见此行说明判定胶水的归账与 bash 前置探活不一致，查工具"
fi
if [ "$VERDICT_PROCESS_DIED" = "true" ]; then
    echo "  归账：15 秒内进程已死（启动链没走到稳态）"
fi
if [ "${CRASHED_COUNT:-0}" != "0" ]; then
    echo "  归账：日志含崩溃标记 ${CRASHED_COUNT} 行（Invalid field/Uncaught exception/Called from——有栈即红，主断言）："
    echo "$JUDGE_OUT" | sed -n 's/^crash=//p' | sed 's/^/    /'
fi
echo ""
echo "---- tail 最后 80 行日志（// issue #64 失败输出节） ----"
tail -80 "$LOG" 2>/dev/null || echo "（日志文件不存在或为空）"
echo "---- tail 结束 ----"
exit 1
