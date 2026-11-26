#!/usr/bin/env bash
# T2/T3 门禁 CI 接线（issue #94）——双闸 + 注入自检 + 裁决豁免的一条命令，
# web.yml 接线步的实体（A 案：红＝web-build 红，不加新 check 名）。
#
# 为什么存在：两闸机器件（tools/TimelineGate.mjs、tools/RenderGate.mjs）并入
# main 后零调用，渲染/时间轴跑偏的 PR 照常自动合并。本脚本一次跑三件：
#
#   1. 两闸 --self-check 注入自检——门禁有牙齿的证明（注入一处播放头跑偏/
#      一处渲染改坏，闸必须精确红在那步那项/那笔拍点键上）；
#   2. 两闸全量对拍（69 清单资产；**不短路**——`&&` 会把先红那闸的基建错
#      埋掉，两闸探针编译线各自独立，// issue #94 要什么 1 尾）；
#   3. 判定（tools/tools/CiGatesVerdict.judge，契约由 test/tools/
#      CiGatesVerdictTest.hx 钉死；机读胶水 tools/tools/CiGatesScan.hx）：
#      退出码分流（0 绿 / 1 红·错 / 2 及未声明非零＝基建坏——也判 CI 红，
#      行里标注「gate 基建问题非渲染回归」，先修基建别查渲染回归）、定位行
#      进 step 日志（哪笔拍点键/哪步哪项）、已裁决候选按 tools.GateExemptions
#      登记豁免（豁免照进步日志带裁决理由，不静默放行；错误行不可豁免）。
#
# 用法（仓库根，web.yml web-build 的构建+单测之后接一步）：
#
#   haxelib install format
#   bash tools/ci-gates.sh
#
# 前置：haxelib run openfl build html5 已跑（探针装库要 export/html5/bin/lib/
# *.zip）；haxelib 有 format（探针编译线 -lib format——web-build 本来只装
# lime/openfl/swf/utest）。
# 退出码：0＝双闸对拍全绿（已裁决候选豁免后）；1＝CI 红——红/错/基建坏/
# 自检红都算（CI 只认红绿，基建坏靠标注说清）。
set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$REPO_ROOT" || exit 1

T3_REPORT="export/timeline-gate/report.txt"
T2_REPORT="export/render-gate/report.txt"
T3_SELFCHECK="export/timeline-gate/self-check.txt"
T2_SELFCHECK="export/render-gate/self-check.txt"

infra_fail() {
    # 基建坏收口：CI 照红，但标注把「先修基建」和「查渲染回归」分流
    echo "ci-gates: gate 基建问题非渲染回归 —— $1" >&2
    echo "  （先修门禁基建；渲染/时间轴是否跑偏，本步骤没给出结论）" >&2
    exit 1
}

# ---- 0. 环境前置（缺位＝基建坏，标注后红） ----
for dep in node haxe haxelib; do
    command -v "$dep" >/dev/null 2>&1 \
        || infra_fail "缺依赖 $dep（两闸探针线 node+haxe 都要）"
done
haxelib list 2>/dev/null | grep -q "^format:" \
    || infra_fail "缺 haxelib 库 format（探针编译线 -lib format；web-build 只装 lime/openfl/swf/utest，接线步先 haxelib install format）"
ls export/html5/bin/lib/*.zip >/dev/null 2>&1 \
    || infra_fail "缺 export/html5/bin/lib/*.zip（探针装库要它；先 haxelib run openfl build html5）"

# ---- 1/3 注入自检（// issue #94 完成标准：注入红过闸的 CI 同跑） ----
# T3 自检目标用 fish_01.swf（多帧剪辑、注入必红——handbook/architecture/
# timeline-gate.md「用法」节的原例）；T2 用缺省 assets[0]（Crop_1056_3——注入
# 目标选「首个有可见画面的」，主轴 0×0 也能选到符号，render-gate.md 先例）。
# 自检报告 --out 分流到 self-check.txt：两闸的 --out 缺省就是全量报告路径，
# 不分流的话自检文本会覆盖全量报告（judge 半边读的是全量报告）。
echo "[1/3] 注入自检（两闸 --self-check——门禁有牙齿的证明）"
echo "---- T3 --self-check（--only fish_01.swf；报告 $T3_SELFCHECK）----"
node tools/TimelineGate.mjs --self-check --only fish_01.swf --out "$T3_SELFCHECK"
T3_SC_RC=$?
echo "---- T2 --self-check（报告 $T2_SELFCHECK）----"
node tools/RenderGate.mjs --self-check --out "$T2_SELFCHECK"
T2_SC_RC=$?
SC_FAIL=0
if [ "$T3_SC_RC" -ne 0 ] || [ "$T2_SC_RC" -ne 0 ]; then
    SC_FAIL=1
    echo "ci-gates: 注入自检红（T3 rc=$T3_SC_RC，T2 rc=$T2_SC_RC）——三种可能："
    echo "  ① 自检目标资产正常跑红＝真回归信号（全量对拍会给正式定位行）；"
    echo "  ② 注入不红＝门禁失牙，gate 基建问题非渲染回归（先修门禁）；"
    echo "  ③ 自检前置缺基线一类，同属 gate 基建问题非渲染回归"
fi

# ---- 2/3 全量对拍（不短路：一闸红/基建坏不埋另一闸） ----
# 闸 stdout 是全量报告原文（report.txt 里已有同一份），转 /dev/null 免得
# step 日志变成大报告转储；stderr 放行（探针编译错/「报告已落」在那）。
echo "[2/3] 全量对拍（T3 在前——接线跑序；两闸探针编译线各自独立）"
node tools/TimelineGate.mjs >/dev/null
T3_RC=$?
node tools/RenderGate.mjs >/dev/null
T2_RC=$?

# ---- 3/3 判定 + step 日志块 ----
echo "[3/3] 判定（CiGatesVerdict.judge：退出码分流 + 定位行 + 豁免登记）"
JUDGE="$(haxe -cp tools --run tools.CiGatesScan judge "$T3_RC" "$T3_REPORT" "$T2_RC" "$T2_REPORT" 2>&1)"
JUDGE_RC=$?
if [ "$JUDGE_RC" -ne 0 ] || [ -z "$JUDGE" ]; then
    printf '%s\n' "$JUDGE" >&2
    infra_fail "判定胶水（tools.CiGatesScan）跑不起来（exit=$JUDGE_RC）——判定半边编译错/环境错"
fi
PASS="$(printf '%s\n' "$JUDGE" | sed -n 's/^pass=//p' | head -1)"
printf '%s\n' "$JUDGE" | sed -n 's/^line=//p'

if [ "$PASS" != "true" ]; then
    echo ""
    echo "ci-gates: FAIL —— 双闸对拍有未豁免的红/错（定位行见上：哪笔拍点键/哪步哪项）"
    echo "  聚合报告：$T3_REPORT、$T2_REPORT；裁决流见 handbook/architecture/render-gate.md「CI 接线与裁决流」节"
    exit 1
fi
if [ "$SC_FAIL" -ne 0 ]; then
    echo ""
    echo "ci-gates: FAIL —— 全量对拍豁免后绿，但注入自检红（见 [1/3] 输出：正常跑红＝真回归信号，或门禁失牙/缺基线＝gate 基建问题非渲染回归）"
    exit 1
fi
echo "ci-gates: PASS —— T3/T2 双闸全量对拍出绿（已裁决候选按 tools.GateExemptions 登记豁免、照进步日志）"
exit 0
