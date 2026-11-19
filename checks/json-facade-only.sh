#!/usr/bin/env bash
# src/ 里的 JSON 解析只许走 as3corelib 门面（src/com/adobe/serialization/
# json/JSON.hx 的 JSON.decode）。原版所有 JSON 解析都过 as3corelib 的宽松
# 解析器：串内裸控制字符原样进值（JSONTokenizer.as:277-307），真实后端
# 数据（xml.php 配置里的多行文案）就带这些字符。直连 haxe.Json.parse 在
# html5 目标即 V8 的 JSON.parse，按 RFC 8259 拒绝——本地单测的自编 fixture
# 是干净 JSON 查不出来，红在 CI 的 web-smoke（issue #7 两轮：空白串、
# 控制字符）。见 docs/pipeline 的环境边界说明。
set -euo pipefail
cd "$(dirname "$0")/.."
bad=$(grep -rn --include="*.hx" -E "Json\.parse[[:space:]]*\(" src/ \
  | grep -v "^src/com/adobe/serialization/json/JSON.hx" || true)
if [ -n "$bad" ]; then
  echo "FAIL: JSON 解析绕过了 as3corelib 门面："
  echo "$bad"
  echo
  echo "原版走 com.adobe.serialization.json.JSON.decode（宽松解析 + 串内控制"
  echo "字符消毒）。把上面的调用改成 JSON.decode（import "
  echo "com.adobe.serialization.json.JSON）。"
  exit 1
fi
echo "ok: src/ 里没有绕过 as3corelib 门面的 JSON 解析"
