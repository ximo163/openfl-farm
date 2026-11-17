#!/usr/bin/env bash
# 由 CI 运行（容器里没有 Java 和 FFDec）：反编译 5 个主代码 swf，全量导出到
# legacy/decompiled/ 下的对应路径，例如
#   legacy/deploy/QFarmFlash/source/core/module/main3_v_221.swf
#     -> legacy/decompiled/main3/          （扁平化：5 个主 swf 名字唯一，不再按原深路径）
#
# 每个主代码 swf 导出：
#   scripts/ images/ shapes/ sounds/ texts/ buttons/ ...  反编译 AS3 和资源
#   sprites/ frames/                                      逐剪辑、主时间轴的逐帧 PNG（退路用）
#   swf.xml                                               全部标签（帧标签、PlaceObject、帧脚本）
#   header.txt                                            swf 版本、帧率、舞台尺寸
#   xfl/                                                  FFDec 重建的 XFL（辅助参考）
#
# 6270 个资产 swf 不在这里反编译（资产走 openfl/swf 库原样消费；清单见
# spec/swf-inventory.json，由 scripts/swf-inventory.py 生成）。
#
# 需要 JPEXS FFDec：https://github.com/jindrapetrik/jpexs-decompiler/releases
# 用法：FFDEC_CMD=/path/to/ffdec/ffdec.sh scripts/decompile-legacy.sh
#   （FFDEC_CMD 也可以是 "java -cp <dir>/ffdec.jar:<dir>/lib/* com.jpexs.decompiler.flash.gui.Main"，
#    ffdec.jar 依赖同目录 lib/ 下的 jar，不能单独 java -jar）
# 参数对照 FFDec 源码的 CommandLineArgumentParser；旧版本可能不支持 xfl、button、
# symbolclass 这几项，它们单独导出，失败只提示、不中断。
set -euo pipefail
: "${FFDEC_CMD:?请设置 FFDEC_CMD=<FFDec 的 ffdec.sh 路径或 java -cp 前缀>}"
ffdec() { $FFDEC_CMD "$@"; }
src=legacy/deploy/QFarmFlash/source/core/module
# 主代码 swf（翻译依据）。新增活动主程序时往这里加。
main_swfs=(
  happyfarm3_v_149.swf
  main3_v_221.swf
  mcloader_v_53.swf
  Master2_v_142.swf
  loading2_v_3.swf
)
count=0
for name in "${main_swfs[@]}"; do
  swf="$src/$name"
  [ -f "$swf" ] || { echo "提示：$swf 不存在，跳过"; continue; }
  out="legacy/decompiled/${name%.*}"
  rm -rf "$out"
  mkdir -p "$out"
  ffdec -format sprite:png,frame:png -export script,image,shape,morphshape,sound,text,binarydata,frame,sprite "$out" "$swf"
  ffdec -swf2xml "$swf" "$out/swf.xml"
  ffdec -header "$swf" > "$out/header.txt" || echo "提示：这个版本的 FFDec 不支持 -header，帧率请从 swf.xml 的顶层属性里看"
  for extra in button symbolclass; do
    ffdec -export "$extra" "$out/$extra" "$swf" || echo "提示：这个版本的 FFDec 不支持导出 $extra，已跳过"
  done
  ffdec -export xfl "$out/xfl" "$swf" || echo "提示：XFL 重建失败或不支持，已跳过（swf.xml 仍然可用）"
  # XFL 的 itemID/lastModified 是导出时刻的时间戳：不抹掉的话每次重跑都全量重写
  # 这两个属性（~3000 文件×2 行），基线没法确定性。它们是创作元数据，翻译用不到。
  # /g 必须有：一行里两个属性（itemID 在前 lastModified 在后），漏 /g 只抹第一个。
  find "$out/xfl" -type f -name '*.xml' -exec sed -i -E 's/ (itemID|lastModified)="[^"]*"//g' {} + 2>/dev/null || true
  echo "$swf -> $out"
  count=$((count + 1))
done
[ "$count" -gt 0 ] || { echo "$src 下没有主代码 swf：先确认 legacy/deploy 已放入"; exit 1; }
