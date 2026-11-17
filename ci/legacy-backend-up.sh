#!/usr/bin/env bash
# H3：在 GitHub CI（ubuntu + docker）拉起旧 PHP 后端，供 V2+ 联调和协议差分用。
# 数据来源是 legacy/snapshot/ 的初始化快照（人从参考部署导出，见该目录 README），
# 不跑安装向导：省掉向导自动化，且每次 CI 的后端状态完全一致（差分标准基线）。
#
# 用法：bash ci/legacy-backend-up.sh [工作目录]（默认 mktemp -d）
# 退出码：0 起好且 xml.php 冒烟通过；3 快照未提供（调用方按「无后端模式」跳过）；1 其他失败。
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SNAP="$ROOT/legacy/snapshot"
PORT=8089

if [ ! -f "$SNAP/initialized.sql" ] || [ ! -f "$SNAP/home-config.php" ] || [ ! -f "$SNAP/ucenter-config.inc.php" ]; then
  echo "SNAPSHOT-MISSING: legacy/snapshot/ 未齐（需要 initialized.sql / home-config.php / ucenter-config.inc.php，导出方法见 legacy/snapshot/README.md）"
  exit 3
fi

WORK="${1:-$(mktemp -d)}"
echo "[1/6] 复制部署包到工作目录 $WORK（build.sh 会在包目录写 www/、data/，不污染检出）"
cp -a "$ROOT/legacy/deploy/QFarmFlash/." "$WORK/"
cd "$WORK"

echo "[2/6] compose 参数：仅本机绑定 + 固定口令（CI 不外露，符合「不裸暴露公网」）"
cat > .env <<EOF
MYSQL_ROOT_PASSWORD=farm_ci_only
PORT=$PORT
BIND_IP=127.0.0.1
EOF

echo "[3/6] 组装 www/：宿主基线 + 农场叠加 + 补丁 001/002（全新副本，不会触发 build.sh 的防误删交互）"
bash ./build.sh   # 显式 bash：脚本文件在仓库里可能没带可执行位（Windows 提交丢 +x）

echo "[4/6] 覆盖宿主配置为快照版（数据库指向服务名 db；UC_KEY 与快照库配套）"
# 部署包 .gitignore 的 data/ 没锚定，host/ucenter/data、host/home/data 等运行时
# 目录没入库（git 检出缺目录；farm 的 core/data 例外，cache.func.php 会自建）。
# 老代码不会全部自建，这里按安装向导 step1 的可写清单补齐。
mkdir -p www/ucenter/data/cache www/ucenter/data/view www/ucenter/data/avatar \
         www/ucenter/data/logs www/ucenter/data/backup www/ucenter/data/tmp \
         www/home/data www/home/uc_client/data
cp "$SNAP/home-config.php" www/home/config.php
cp "$SNAP/ucenter-config.inc.php" www/ucenter/data/config.inc.php
# 开农场：默认 closefarm=1 是哀悼公告页
sed -i "s/\['closefarm'\] = 1;/['closefarm'] = 0;/" www/home/qqfarm/core/config/_qsc.php
# 数据库口令换成 CI 专用值（快照配置里带的是参考部署的口令；dbuser 一并规整成
# root，参考部署按部署包 README 装的本来也是 root，这几行 sed 是幂等保险）。
# 注意模板里键和 = 之间是 tab，模式要容忍任意空白。
sed -i "s/^\$_SC\['dbuser'\][[:space:]]*=.*/\$_SC['dbuser'] = 'root';/" www/home/config.php
sed -i "s/^\$_SC\['dbpw'\][[:space:]]*=.*/\$_SC['dbpw'] = 'farm_ci_only';/" www/home/config.php
sed -i "s/^define[[:space:]]*([[:space:]]*'UC_DBUSER',[[:space:]].*/define('UC_DBUSER', 'root');/" www/ucenter/data/config.inc.php
sed -i "s/^define[[:space:]]*([[:space:]]*'UC_DBPW',[[:space:]].*/define('UC_DBPW', 'farm_ci_only');/" www/ucenter/data/config.inc.php

echo "[5/6] 建库改用快照（含 uchome_qqfarm_* 的 uid=1 数据），替换 qfarm.sql 挂载——两个都挂会因重复建表中断 initdb"
sed -i "s#- \./install/qfarm\.sql:#- $SNAP/initialized.sql:#" docker-compose.yml

echo "[6/6] docker compose up（php 镜像首次构建约 2-3 分钟）"
docker compose up -d --build

# 等 nginx 就绪：首页走 PHP+db，能 200 就说明 db/initdb/配置全通了
ok=""
for i in $(seq 1 90); do
  if curl -sf -o /dev/null "http://127.0.0.1:$PORT/"; then ok=1; break; fi
  sleep 2
done
if [ -z "$ok" ]; then
  echo "FAIL: http://127.0.0.1:$PORT/ 180 秒内没就绪，容器状态："
  docker compose ps
  docker compose logs --tail=30 web php db >&2 || true
  exit 1
fi

# 冒烟：xml.php 出 config（V2 预加载器要的端点；002 补丁 uid=1 免登录）
cfg="$(curl -sf "http://127.0.0.1:$PORT/home/qqfarm/core/xml.php?mod=nc_main")" || {
  echo "FAIL: xml.php?mod=nc_main 请求失败（curl 退出码 $?）"; exit 1; }
echo "$cfg" | grep -q "main3_v_221.swf" || {
  echo "FAIL: xml.php?mod=nc_main 内容异常（应有主程序模块地址），前 300 字节："; echo "$cfg" | head -c 300; exit 1; }

data="$(curl -sf "http://127.0.0.1:$PORT/home/qqfarm/core/xml.php?mod=nc_data")" || {
  echo "FAIL: xml.php?mod=nc_data 请求失败（curl 退出码 $?）"; exit 1; }
echo "$data" | head -c 100 | grep -q "<?xml" || {
  echo "FAIL: xml.php?mod=nc_data 不是 XML，前 300 字节："; echo "$data" | head -c 300; exit 1; }

echo "legacy-backend: ok（http://127.0.0.1:$PORT ，xml.php nc_main/nc_data 均出 config）"
