#!/usr/bin/env bash
# QFarmFlash 部署组装脚本：host/ + source/ → www/（UCHome 插件模式）
# 等效于原包 QFarm自动构建工具V2.0.CMD 的 :Uchome 分支，并叠加两处宿主部署补丁。
# 组装产物 www/ 已被 .gitignore 忽略，可随时删除重跑。
# 用法：./build.sh
set -euo pipefail
cd "$(dirname "$0")"

# ── 防误删检测 ──────────────────────────────────────────────
# www/ 已是向导安装过的状态时，重建会删掉安装痕迹，与数据库旧安装脱节
if [ -f www/install/install.lock ] || [ -f www/home/data/install.lock ] || [ -s www/ucenter/data/config.inc.php ]; then
    echo "!! 检测到 www/ 处于已安装状态（install.lock / UCenter 配置存在）。"
    echo "   重新组装会删除这些文件，之后必须重跑安装向导（或恢复备份）。"
    read -r -p "   确认删除并重建？输入 yes 继续，其他任意输入退出: " REPLY
    [ "${REPLY}" = "yes" ] || { echo "已退出，未做任何改动。"; exit 1; }
fi
# data/mysql 有历史数据时给出清理指引（绝不自动删库）
if [ -d data/mysql ] && [ -n "$(ls -A data/mysql 2>/dev/null)" ]; then
    echo "提示：data/mysql 非空（存在历史数据库，initdb 不会重跑）。"
    echo "      彻底重来请先执行："
    echo "        docker compose down"
    echo "        docker run --rm -v \"$(pwd)/data/mysql:/d\" alpine sh -c 'rm -rf /d/*'"
    echo "      然后再运行本脚本，并 docker compose up -d --build"
fi

# .env 不存在则从模板生成（注意：MySQL 密码在首次 up 初始化时固化，
# 要改密码必须在 docker compose up 之前编辑 .env）
if [ ! -f .env ]; then
    cp env.example .env
    echo "[0/5] 未发现 .env，已从 env.example 生成（密码为默认值 change_me）"
    echo "      → 如需修改密码，请现在编辑 .env 再继续"
fi

echo "[1/5] 宿主基线 host/ → www/"
rm -rf www || { echo "删除 www/ 失败：里面有容器 root 写入的文件。用："; echo "  docker run --rm -v \"$(pwd)/www:/d\" alpine sh -c 'rm -rf /d/*'"; exit 1; }
rsync -a host/ www/

echo "[2/5] 叠加农场 7.0（4uchome 适配层 + core 核心，含前端资源 module/）"
rsync -a source/4uchome/qqfarm/ www/home/qqfarm/
rsync -a source/core/ www/home/qqfarm/core/
cp source/4uchome/qqfarm.php www/home/qqfarm.php
# 7z 解压遗留的 700 目录权限会让 nginx 进不去（素材 200 但回落成门户 HTML，
# SWF 报"第1步素材加载失败"→ 农场弹"加载农场游戏数据失败(-6)"）
find www/home/qqfarm/core/module -type d -exec chmod 755 {} \;
find www/home/qqfarm/core/module -type f -exec chmod 644 {} \;

echo "[3/5] 修宿主安装 SQL 老语法 TYPE=MyISAM → ENGINE=MyISAM"
sed -i 's/TYPE=MyISAM/ENGINE=MyISAM/g' www/bbs/install/discuz.sql www/ucenter/install/uc.sql

echo "[4/5] Patch UCHome 安装器 ucapi（容器内 localhost 连不到 nginx，改走服务名 web）"
python3 - <<'PY'
p = 'www/home/install/index.php'
data = open(p, 'rb').read()  # 二进制模式读写，避免破坏 CRLF
old = b"$ucapi = preg_replace(\"/\\/$/\", '', trim($_POST['ucapi']));"
ins = b"\n$ucapi = preg_replace('#^(http://)(localhost|127\\.0\\.0\\.1)(:\\d+)?#', '$1web', $ucapi);"
if ins in data:
    print('  已存在，跳过')
elif old in data:
    open(p, 'wb').write(data.replace(old, old + ins))
    print('  已插入 ucapi 替换')
else:
    raise SystemExit('  未找到 ucapi 行，宿主包可能已变化，请人工核对 www/home/install/index.php')
PY

echo "[5/5] 应用农场运行补丁（Flash cookie 隔离 + UC_API 常量修复）"
patch -N -p1 -d www < patches/001-uchome-config-always-load-UC_API.patch
patch -N -p1 -d www < patches/002-qfcheckauth-flash-cookie-uid1-fallback.patch

PORT_VAL=$(grep -E '^PORT=' .env | head -1 | cut -d= -f2 | tr -d '[:space:]'); PORT_VAL=${PORT_VAL:-8089}
echo "组装完成。后续步骤："
echo "  1. docker compose up -d --build   （首次启动前可先编辑 .env 改数据库密码）"
echo "  2. 浏览器 http://localhost:${PORT_VAL}/install/ 走向导"
echo "     （数据库服务器填 db、dbname=qqfarm、dbuser=root、密码同 .env —— 字段对照详见 README 第四节）"
echo "  3. 向导完成后开农场：www/home/qqfarm/core/config/_qsc.php 里 closefarm 改 0"
echo "  4. UCHome 导航加入口并进农场：README 第四节步骤 5-6"
