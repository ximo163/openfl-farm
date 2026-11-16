#!/usr/bin/env bash
# 按 assets/legacy-assets.txt 把原版资产从 legacy/deploy/QFarmFlash/ 拷到
# assets/legacy/（保持相对路径）。流水线在每次 agent 运行后自动执行；agent 只改
# 清单文件，不手拷。
# --check：只校验 assets/legacy/ 和清单一致（不拷贝），不一致退出 1。
set -euo pipefail
root=legacy/deploy/QFarmFlash
list=assets/legacy-assets.txt
dest=assets/legacy

[ -f "$list" ] || { echo "缺 $list"; exit 1; }

check_only=false
[ "${1:-}" = "--check" ] && check_only=true

mapfile -t entries < <(grep -v '^[[:space:]]*#' "$list" | grep -v '^[[:space:]]*$' || true)
[ "${#entries[@]}" -gt 0 ] || { echo "$list 里没有条目（全是注释或空）"; exit 0; }

status=0
for rel in "${entries[@]}"; do
  src_path="$root/$rel"
  if [ ! -e "$src_path" ]; then
    echo "清单里的路径不存在：$rel"
    status=1
    continue
  fi
  dst_path="$dest/$rel"
  if $check_only; then
    if [ ! -e "$dst_path" ]; then
      echo "未同步：$rel（运行 bash scripts/sync-legacy-assets.sh）"
      status=1
    fi
  else
    mkdir -p "$(dirname "$dst_path")"
    if [ -d "$src_path" ]; then
      rm -rf "$dst_path"
      cp -r "$src_path" "$dst_path"
    else
      cp -p "$src_path" "$dst_path"
    fi
  fi
done

if $check_only; then
  # 反向：assets/legacy 下不应有清单外的文件
  while IFS= read -r -d '' f; do
    rel=${f#"$dest"/}
    grep -qxF "$rel" "$list" || { echo "assets/legacy 里有多余文件（不在清单）：$rel"; status=1; }
  done < <(find "$dest" -type f -print0 2>/dev/null || true)
fi

[ $status -eq 0 ] && echo "legacy-assets: ok（${#entries[@]} 个条目）"
exit $status
