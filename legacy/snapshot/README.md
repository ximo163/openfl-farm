# 旧后端初始化快照（H3）

CI 拉起旧 PHP 后端不用安装向导，用这里的人导出快照：**省掉向导自动化，且每次
CI 的后端状态完全一致**（协议差分的标准基线）。三个文件都由人从参考部署
（qqfarm-7.0 工作区，与本仓库 `legacy/deploy/QFarmFlash` 同一套 compose）导出：

| 文件 | 是什么 |
|---|---|
| `initialized.sql` | `qqfarm` 库全量 dump（含 `uc_*`、`uchome_*`、`uchome_qqfarm_*` 的 uid=1 初始化数据） |
| `home-config.php` | 参考部署的 `www/home/config.php`（数据库指向 compose 服务名 `db`，UC_KEY 与库配套） |
| `ucenter-config.inc.php` | 参考部署的 `www/ucenter/data/config.inc.php` |

## 导出步骤（在参考部署的 compose 目录里跑）

0. 前置：部署已按部署包 README 第四节装好，并且**已进过一次农场**（打补丁的
   客户端或直接 curl 都行）——这样 `uchome_qqfarm_*` 里已有 uid=1 的初始化数据。
   导出前自检，这条通了再导：

   ```bash
   curl -s "http://127.0.0.1:8089/home/qqfarm/core/xml.php?mod=nc_main" | grep main3_v_221.swf
   ```

1. 数据库在容器内导出再拷出（避免 Windows 重定向动字节）：

   ```bash
   docker compose exec db sh -c 'mysqldump -uroot -p"$MYSQL_ROOT_PASSWORD" --default-character-set=utf8 qqfarm > /tmp/initialized.sql'
   docker compose cp db:/tmp/initialized.sql <本目录>/initialized.sql
   ```

   可选瘦身（Discuz 的 `cdb_*` 表农场用不到）：

   ```bash
   docker compose exec db sh -c 'mysql -uroot -p"$MYSQL_ROOT_PASSWORD" -N -e "SHOW TABLES FROM qqfarm" | grep -v "^cdb_" | tr "\n" " " > /tmp/t'
   docker compose exec db sh -c 'mysqldump -uroot -p"$MYSQL_ROOT_PASSWORD" --default-character-set=utf8 qqfarm $(cat /tmp/t) > /tmp/initialized.sql'
   ```

2. 宿主配置两份（UC_KEY 和库是一对，别单独改其中一边）：

   ```bash
   cp www/home/config.php <本目录>/home-config.php
   cp www/ucenter/data/config.inc.php <本目录>/ucenter-config.inc.php
   ```

## 注意

- 快照里含参考部署的口令/密钥（UC_KEY、创始人密码哈希等）。它们只在本仓库
  私有环境里配套使用；介意的话换新值必须连库一起换（`uc_applications` 的
  authkey 与 `home-config.php` 的 UC_KEY 同源），不能只改文件。
- 导出后跑一次 `bash ci/legacy-backend-up.sh`（或有该 workflow 的 CI）验证。
- 农场 7 张表也在快照里（带 uid=1 数据），CI 里用本快照**替换**
  `install/qfarm.sql` 的 initdb 挂载——两个都挂会因重复建表中断初始化。
