#!/usr/bin/env bash
# spec/ 下的规格文件都是 JSON，必须能解析，且顶层带 "version"。
set -u
status=0
shopt -s nullglob globstar
for f in spec/**/*.json; do
  node -e '
    const f = process.argv[1];
    let d;
    try { d = JSON.parse(require("fs").readFileSync(f, "utf8")); }
    catch (e) { console.log(f + ": 不是合法的 JSON：" + e.message); process.exit(1); }
    if (typeof d !== "object" || d === null || !("version" in d)) {
      console.log(f + ": 顶层必须是对象并带 \"version\" 字段"); process.exit(1);
    }' "$f" || status=1
done
[ $status -eq 0 ] && echo "spec: ok"
exit $status
