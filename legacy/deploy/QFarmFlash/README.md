# QFarmFlash — QQ农场/牧场 7.0 Final 部署源仓库

phpYe.QFarm **7.0 Final Build 20120905.1700** 的纯文件存档，已重组为部署友好的目录结构。
本仓库只收录原安装包内的文件，未混入包外文件；代码内容未做任何改动，**唯一处理是文本编码统一（UTF-8 无 BOM）**，以保证在 GitHub 上正常展示中文。

- 上游来源：`phpYe.QFarm7.0_Final_20120905.1700.zip`（phpYe.Team，2012-09-05）
- 部署目标模式：**UCHome 插件模式**（`source/4uchome/` 适配器，宿主为 UCenter 1.5 + UCHome 1.5 整合环境）
- 资源包来源：`module20120905.7z`（官方配套 SWF 资源，对应版本 20120905，已解压收录）
- **UTF-8 编码转换（2026-11-10）**：共 255 个 GBK/GB18030 文本文件转为 UTF-8（农场包 27 + 宿主包 228）、12 个文件去除 BOM（10 + 2）。仅改编码、不改任何代码逻辑（转换前经 GB18030 严格往返校验；5 个含二进制载荷的文件安全跳过）。完整转换记录见**第八节**

---

## 一、目录结构与职责

```
QFarmFlash/
├── host/            ← 宿主系统整合包 ★部署必需（UCenter 1.5 服务端 + UCHome 1.5 + Discuz 7 + 安装向导）
├── source/          ← 后端源码（完整保留原包 source/，未裁剪）
│   ├── core/            农场后端核心 ★部署必需
│   │   └── module/          前端 SWF/JPG/PNG 资源 ★（126MB / 10155 文件，已就位）
│   ├── 4uchome/         UCHome 适配层 ★本部署使用
│   ├── 4ucenter/        UCenter 独立模式适配层（备用）
│   ├── 4discuz/         Discuz 7.x 适配层（备用）
│   ├── 4discuzx/        Discuz!X 适配层（备用）
│   └── 4phpwind/        PHPWind 适配层（备用）
├── install/         ← 全新安装器 ★部署必需（2 个文件）
├── patches/         ← 农场运行补丁 ×2（build.sh 第 5 步自动应用）
├── build.sh         ← 部署组装脚本：host/ + source/ → www/（CMD 工具的 Linux 等效实现）
├── docker-compose.yml ← Docker 编排（mysql:5.5 / php:5.6-fpm / nginx:1.24-alpine）
├── php/Dockerfile   ← PHP 镜像构建（mysql_* 扩展、short_open_tag=On、root worker）
├── nginx/default.conf ← nginx 站点配置
├── env.example      ← 环境变量模板（复制为 .env：数据库密码/端口/绑定地址）
├── docs/            ← 原包说明文档（4 个）
├── tools/           ← 构建工具与老库升级脚本
└── README.md
```

### 各目录明细

| 目录 | 来源（原包路径） | 职责 |
|---|---|---|
| `host/` | `farm-ucenter1.5_lanzou/upload/` | 宿主系统基线 ★：UCenter 1.5 服务端 + UCHome 1.5（UTF-8 版，农场宿主）+ Discuz 7（bbs）+ 整合安装向导（`install/`）。农场以 UCHome 插件形式接入，登录/注册/好友/头像全依赖宿主。**已剔除将被 7.0 替代的三处老农场 4.0 文件**：`home/qqfarm/`、`home/qqfarm.php`、根部 `qqfarm.sql`（2713 文件 / 23MB） |
| `source/core/` | `source/core/` | 农场后端全部：入口 `index.php`、公共加载 `common.php`、农场逻辑 `source/nc/`（149 个 CGI 模块）、牧场逻辑 `source/mc/`（109 个 CGI 模块）、管理后台 `admin.php` + `source/admin/`、页面模板 `view/`、数值配置 `config/nc\|mc/`（作物/动物/鱼/道具数据）、运行时可写目录 `data/`、SWF 配置输出 `xml.php`。**注意：core 单独不完整，缺 `_qsc.php` 与 `config/api/*.php`，由适配层覆盖提供** |
| `source/4uchome/` | `source/4uchome/` | UCHome 插件接入层：入口 `qqfarm.php`、插件体 `qqfarm/`（qqfarm.inc.php、static、template）、**覆盖层** `qqfarm/core/config/_qsc.php` + `qqfarm/core/config/api/uchome.php` + `qqfarm/core/api/uchome/`（合并时叠加进 core） |
| `source/4ucenter/` | `source/4ucenter/` | UCenter 1.5 独立模式：自带登录页、`uc_client/` 客户端库、独立的 `config.php`（UC + 数据库参数模板）。本部署不用，保留备用 |
| `source/4discuz/`、`4discuzx/`、`4phpwind/` | 同名 | 其他三种宿主的适配层，本部署不用，保留备用 |
| `source/core/module/` | `module20120905/module/` | 前端全部资源：主程序 `happyfarm3_v_149.swf`（农场）/ `mcloader_v_53.swf`（牧场）+ `ui/`（6000+ 素材引用）、`mc/`（牧场动物/装饰/音效）、`collect/`、`plugin/`、`wildAdv/`、`labor/` 等。SWF 由 Flash 客户端动态加载，**整个目录不可裁剪**。已按官方要求就位于 `core/module/`，部署合并 core 时自动带上 |
| `install/` | `安装&升级/全新安装/install/` | 全新建库器：`index.php`（放 `core/install/` 浏览器执行）+ `qfarm.sql`（建 7 张表：nc/user/mc/nclogs/mclogs/market/message，已核对与代码所需完全一致，且已含 7.0 新增的 `mc.research` 字段）。**注意：本仓库的 qfarm.sql 已把表前缀预先改为 `uchome_qqfarm_`**，适配直灌数据库场景与本项目 UCHome 部署 |
| `docs/` | 包根目录 4 个说明文件 | 安装教程、更新日志、module 下载地址（编码已统一为 UTF-8，见第八节） |
| `tools/QFarm自动构建工具V2.0.CMD` | 包根目录 | Windows 批处理构建器，是**合并布局的权威文档**（见下节），Linux 下按其 xcopy 逻辑用 cp 等效执行 |
| `patches/` | 从已验证部署提取的 unified diff | 两处农场运行必需补丁，`build.sh` 第 5 步自动 `patch` 到组装产物：① `uchome.php` 无条件加载 UCHome `config.php`，修复缓存命中时 `UC_API` 常量未 define → `uc_client` exit "Access denied"（**现象即"加载农场游戏数据失败(-6)"**）；② `qf_checkauth()` 无 cookie 兜底 `uid=1`（Flash/Ruffle 独立 cookie 存储，SWF 内部请求不带登录态）——**安全警告：兜底后任何能访问端口者均以 admin 身份操作，仅限可信内网** |
| `tools/63Fto70F.php` | 包根目录 | 6.3F 老库 → 7.0F 数据库升级脚本（仅加 `mc.research` 一列）。**全新安装用不到**，仅日后从 6.3 老站导数据时使用 |
| `build.sh` + `docker-compose.yml` + `php/Dockerfile` + `nginx/default.conf` + `env.example` | 本仓库新增 | Docker 部署设施：`build.sh` 把 `host/`+`source/` 组装为 `www/`（等效 CMD 工具 `:Uchome` 分支，内置 TYPE=MyISAM 语法修复与 ucapi 补丁两处宿主侧改动，只改组装产物不动仓库基线）；compose 三容器与参考环境**同款镜像**（mysql:5.5 / php:5.6-fpm / nginx:1.24-alpine），initdb 直接挂载 `install/qfarm.sql` 建农场 7 张表 |

### 原包中未收录（本仓库明确不要）的内容

| 原包路径 | 不收录理由 |
|---|---|
| `module20120905.7z`（102MB） | 原始压缩包，内容已完整解压收录到 `module/` |
| `安装&升级/数据库升级文件/`（全部） | 4.1F→6.3F 历代老库升级脚本，全新安装一步到位用不到 |
| `安装&升级/农场更新日志/`（全部） | 2.8~6.3 版历史日志，纯文档 |

---

## 二、部署形态（合并布局）

部署 = **宿主基线 + 农场叠加**：先把 `host/*` 拷入网站根（即部署目录 `www/`），浏览器走 `install/` 向导装好 UCenter/UCHome/Discuz，再按下面布局叠加农场文件——**`./build.sh` 一键完成组装**（含两处宿主侧补丁），对应 `tools/QFarm自动构建工具V2.0.CMD` 的 `:Uchome` 分支（`xcopy source\4uchome → 目标根`，`xcopy source\core → 目标根\qqfarm\core\`）：

```
<UCHome网站根>/
├── qqfarm.php                 ← source/4uchome/qqfarm.php
└── qqfarm/
    ├── qqfarm.inc.php         ← source/4uchome/qqfarm/*（static/ template/ 同级拷入）
    ├── core/                  ← source/core/* 全部内容合并进此目录
    │   ├── config/_qsc.php    ← 来自 4uchome 覆盖层（core 自身没有）
    │   ├── config/api/uchome.php
    │   ├── api/uchome/
    │   └── module/            ← 已就位于仓库 source/core/module/，随 core 合并自动带入（★缺失则白屏）
    └── ...
```

> 待办：本仓库尚无 Linux 构建脚本（`build.sh`），目前需按上表手动 cp 合并。CMD 工具仅 Windows 可用。

## 三、表前缀机制（重要，涉及"表名要不要改"）

1. PHP 代码中全部硬编码 `app_qqfarm_*` 表名；
2. `dbstuff` 在执行 SQL 时做运行时替换（`source/core/source/mysql.class.php:55` + `common.php:82`），`tbPrefix[0]` 为搜索列表、`tbPrefix[1]` 为替换列表，逐元素对应：`app_qqfarm_` → `<tbprefix>qqfarm_`（农场 7 张表）；`pap_tbpre_` → `<tbprefix>`（适配层引用宿主自有表 space/friend/session/feed 的占位符）。已对照实际部署库验证：物理表 `uchome_qqfarm_*` 与 `uchome_*` 与此机制完全吻合；
3. UCHome 模式下 `tbprefix` 取自 UCHome 的 `$_SC['tablepre']`（`source/4uchome/qqfarm/core/config/api/uchome.php:31`），默认 `uchome_`。

**结论：物理表必须叫 `uchome_qqfarm_*`**。是否需要手动改 SQL 取决于安装方式：

| 安装方式 | 是否改 SQL |
|---|---|
| 用 `install/index.php`（PHP 安装器，建表走 dbstuff） | **不用**，自动建出正确前缀 |
| 把 `qfarm.sql` 直接灌库（如 docker-entrypoint-initdb.d，绕过 PHP） | **必须** `sed 's/app_qqfarm_/uchome_qqfarm_/g'`，否则运行时报 1146 表不存在 |

UCHome 模式下农场**无需单独配置数据库**：db 地址/账号/前缀/UC 密钥均自动从 UCHome 的 `config.php` 读取。

## 四、全新安装流程（Docker 快速部署）

```bash
cp env.example .env        # 编辑 MYSQL_ROOT_PASSWORD（必改）
./build.sh                 # 组装 www/：宿主基线 + 农场叠加 + 宿主补丁
docker compose up -d --build
```

1. 等 db healthy（首次启动 initdb 自动建 `qqfarm` 库并导入 `install/qfarm.sql` 的 7 张农场表——**农场无需单独跑安装器**）；
2. 浏览器 `http://localhost:8089/install/` 走整合向导。**step2 的数据库信息按下表填写**——这是依赖关系最容易填错的地方：PHP 跑在容器里，填 `localhost` 指向的是 PHP 容器自己，填宿主机 IP 也绕远了，**必须填 compose 服务名 `db`**（Docker 内部 DNS 直接解析到数据库容器）：

   | 向导字段 | 填什么 | 依赖来源 / 原因 |
   |---|---|---|
   | 数据库服务器 | `db` | `docker-compose.yml` 里 db 服务的服务名，容器间内网 DNS 解析 |
   | 数据库名 | `qqfarm` | compose 环境变量 `MYSQL_DATABASE=qqfarm`，initdb 已自动创建 |
   | 数据库用户名 | `root` | — |
   | 数据库密码 | 与 `.env` 的 `MYSQL_ROOT_PASSWORD` 一致 | MySQL 容器**首次初始化时固化**的 root 密码；build.sh 自动生成的 `.env` 默认值为 `change_me` |
   | 数据库端口（如有） | `3306` | 默认，容器内部端口，无需改 |

   UCenter 相关字段保持向导自动带出的值即可（`build.sh` 的 ucapi 补丁已把容器内部的 `localhost` 通信自动改写为 `web` 服务名，无需手工干预）；UCenter 创始人密码与 admin 密码自定义并**记牢**（之后进 UCenter / Discuz 后台要用）。农场那 7 张表（`uchome_qqfarm_*`）initdb 已建好，向导只装 UCenter/UCHome/Discuz，**不要**再单独跑农场安装器；
3. 向导 step3 自动串装 UCenter → UCHome → Discuz；
4. 向导完成后**开农场**：`www/home/qqfarm/core/config/_qsc.php` 的 `closefarm` 改 **0**（默认 1 = 关闭 + 哀悼公告）；
5. UCHome 导航加入口：`www/home/template/default/header.htm` 搜索"热闹"，其后加 `<li><img src="image/app/farm.gif"><a href="qqfarm.php">农场庄园</a></li>`，再清模板缓存 `rm -f www/home/data/tpl_cache/*.php`；
6. 访问 `http://localhost:8089/home/qqfarm.php`——首次登录自动激活用户并初始化农场/牧场数据，无需种子数据；
7. 端口默认 `8089`、绑定默认 `0.0.0.0`（局域网可直接访问，仅适合可信内网；要仅本机在 `.env` 设 `BIND_IP=127.0.0.1`）。

**重置重来**：`docker compose down` → 清 `data/mysql/`（目录归容器 root，用 `docker run --rm -v "$(pwd)/data/mysql:/d" alpine sh -c 'rm -rf /d/*'` 代删）→ 删 `www/ucenter/data/install.lock`、`www/ucenter/data/config.inc.php`、`www/install/install.lock`、`www/home/data/install.lock`、`www/bbs/forumdata/index.lock` → 重跑 `./build.sh && docker compose up -d --build`。

**非 Docker 环境**：`./build.sh` 产物 `www/` 直接放进任意 PHP 5.6 + MySQL 5.5 环境；此时向导的"数据库服务器"才填 `localhost` 或数据库实际地址（不再存在 `db` 这个服务名）；农场建表需把 `install/` 两个文件放 `www/home/qqfarm/core/install/` 用浏览器执行（dbstuff 会自动把 `app_qqfarm_` 前缀替换为宿主前缀，与已预改前缀的 SQL 殊途同归）。

## 五、环境要求（老代码，强约束）

| 组件 | 要求 | 原因 |
|---|---|---|
| PHP | 5.2 ~ 5.6 | `mysql_*` 扩展、`get_magic_quotes_gpc()`，PHP 7+ 直接不可用 |
| MySQL | 5.5 | `TYPE=MyISAM` 老语法、sql-mode 必须为空（不能有 STRICT_TRANS_TABLES） |
| php.ini | `short_open_tag=On` | 宿主 UCHome 安装器硬要求 |
| 时区 | Asia/Shanghai (+08:00) | 影响收获时间计算 |
| 浏览器 | 需 Flash 替代方案 | SWF 前端，见缺失清单第 3 条 |

## 六、初始配置的已知坑

- `closefarm` 默认 **1（关闭）**，装完不改只能看到哀悼公告 —— 必须改 0；
- **fresh git 检出缺运行时目录**：本仓库 `.gitignore` 的 `data/` 未锚定，`host/ucenter/data`、`host/home/data`、`host/home/uc_client/data`、`source/core/data` 没入库（当初从 zip 解包的机器上有、新克隆没有）。农场自己的 `core/data` 会自建，其余按安装向导 step1 的可写清单 mkdir（CI 侧的清单见 `../../../ci/legacy-backend-up.sh`）；
- `_QSC['adminer'] = array(1)`：UCHome 模式会自动并入 UCHome 创始人，一般无需改；
- 缓存：`core/data/_qsc.php` 是运行时生成的配置缓存，改配置后需删除它才会重读（"请登录"死循环也先删它试试）；
- 模板缓存：改 `.htm` 模板后需清 `core/data/view/`；
- 进农场提示**"加载农场游戏数据失败(-6)"**（或"第1步素材加载失败"）：两个已知成因——① SWF 数据接口被拒：`xml.php` 无 cookie 返回 13 字节 "Access denied"，由 `patches/` 解决；② **素材目录权限**：7z 解压遗留 700 目录，nginx 进不去，`module/ui/*.swf` 被 try_files 静默回落成门户 HTML（200 但 content-type 是 text/html），由 `build.sh` 第 2 步的 chmod 归一化解决。排查：看 nginx 日志有无 `stat() failed (13: Permission denied)`，或 curl 素材 URL 确认 Content-Type 为 `application/x-shockwave-flash`。

## 七、缺失清单 —— 本仓库之外还需要什么（后续补充/改造）

以下内容**都不在上游安装包内**，不补齐则无法从本仓库独立完成可玩的全新部署。按优先级排列：

1. ~~宿主系统整合包~~ ✅ **已补齐（2026-11-10）**：收录为 `host/`（`farm-ucenter1.5_lanzou/upload` 剔除老农场 4.0 三处文件后的纯净基线）。UCenter 服务端、UCHome、Discuz、整合安装向导齐备——本仓库的文件侧已可独立完成全新部署。注意 `host/` 是**未打补丁的原始基线**，部署时的宿主侧改动见第 6 条。
2. ~~两处农场运行补丁~~ ✅ **已补齐（2026-11-10）**：收编为 `patches/001`、`patches/002`，并内置到 `build.sh` 第 5 步自动应用。① `uchome.php` 无条件加载 UCHome `config.php`——修复缓存命中时 `UC_API` 常量未 define、`uc_client` exit "Access denied"（现象即**"加载农场游戏数据失败(-6)"**）；② `qf_checkauth()` 无 cookie 兜底 `uid=1`——Flash/Ruffle 独立 cookie 存储，SWF 内部请求不带登录态。**安全警告：兜底后任何能访问端口的人都以 admin 身份操作，仅限可信内网，严禁公网暴露。** 已实测验证：打补丁后 `xml.php` 返回 1571 字节正常 XML、`mync.php` 返回正常 JSON。
3. **现代浏览器显示层**（Flash EOL 解决方案，全部是"生成物"，不在任何包内）：
   - Ruffle self-host（`www/ruffle/`，npm `@ruffle-rs/ruffle` 下载）；
   - 4 份改了 family name 的中文字体副本（宋体/SimSun/Verdana/Tahoma，fontTools 从 NotoSansCJK 生成，约 64MB）—— SWF 硬编码字体名，Ruffle 不自动 fallback；
   - `header.htm` 的 RufflePlayer.config + swfobject 包装 patch。
   - → 待办：收录生成脚本与产物，或至少收录脚本。
4. ~~Docker 基础设施~~ ✅ **已补齐（2026-11-10）**：`docker-compose.yml` + `php/Dockerfile` + `nginx/default.conf` + `env.example` 入库，镜像与参考部署同款（mysql:5.5 / php:5.6-fpm / nginx:1.24-alpine），initdb 直接挂载 `install/qfarm.sql`；`env.example` 为无点前缀命名（仓库不收录 `.env*` 文件，实际密码只存在于本机 `.env`）。
5. ~~sed 版建库 SQL~~ ✅ **已补齐**：`install/qfarm.sql` 已预先改为 `uchome_qqfarm_` 前缀（commit `1adfa55`），直灌数据库与 PHP 安装器两种方式均可用。
6. **宿主侧改动**：✅ ucapi 补丁与 `TYPE=MyISAM`→`ENGINE=` 修复已内置到 `build.sh`（只改组装产物 `www/`，不动仓库基线）；数据库参数由安装向导表单填写（dbhost=db 等，无需改 config 文件）；向导后手工项（`closefarm` 开启、`header.htm` 导航入口）见第四节步骤 4-5。
7. ~~Linux 构建脚本 `build.sh`~~ ✅ **已补齐（2026-11-10）**：等效 CMD `:Uchome` 分支（host + 4uchome + core/module 组装为 `www/`），已实测跑通（100 处 SQL 语法修复、ucapi 补丁正常插入，产物结构与已验证部署一致）。

## 八、编码说明（已统一为 UTF-8）

本仓库文本文件（php/html/htm/txt/sql/cmd/xml/js/css）已统一为 **UTF-8 无 BOM**：农场包 566 个全部完成；宿主包 `host/` 除 5 个含二进制载荷的文件外全部完成（见下）。原始上游包中存在 GBK 编码文件与带 BOM 文件，入库时已做一次性转换（仅改编码，不改任何代码逻辑与内容）：

**GBK/GB18030 → UTF-8，共 27 个文件**（全部先通过 GB18030 严格往返校验，确认无混合编码后才转换）：

| 类别 | 文件 | 说明 |
|---|---|---|
| 文档 | `docs/` 3 个 txt、`tools/QFarm自动构建工具V2.0.CMD` | 上游即 GBK |
| 核心代码 | `source/core/xml.php`、`source/script/js/config.js`、8 个 nc/mc 的 cgi mod（登录/活动/钓鱼类）、`4ucenter/uc_client/control/user.php` | **上游即以 GBK 发布**；部署在 UTF-8 宿主时这些文件的中文输出本就会乱码，本次转换顺带修正 |
| GBK 宿主专用变体 | `savepic_gbk.php`×3、`qqfarm.gbk.htm`×4、`discuz_plugin_qqfarm_SC_GBK.xml`×2、`info.xml-gbk` | 上游为 GBK 宿主（Discuz/DiscuzX/PHPWind GBK 版）准备的孪生文件 |

**去除 UTF-8 BOM，共 10 个文件**：2 个 Discuz 插件 XML、`view/qf_default/mc.htm`、`config/_hide.php`、4 个 nc/mc mod、`qz_dialog.css`、`module/ui/farm/houseKeeperGift_v_0.xml`。BOM 字节混在 PHP 输出流里可能污染 XML/JSON 响应，去除后无副作用。

**宿主包（`host/`）编码处理（2026-11-10）**：宿主为 UTF-8 版（`$_SC['charset']='utf-8'`、语言包全部 UTF-8），但康盛发布时在 228 个核心代码文件中遗留 GBK 注释/文案（UCHome 的 source/、admin/、uc_client/，UCenter、Discuz、整合安装器），模式与农场包相同，已按同一策略转换（全部通过 GB18030 严格往返校验）。另有 2 个文件去 BOM（`home/template/default/header.htm`、`ucenter/crossdomain.xml`）。**5 个文件安全跳过**：`bbs/api/google.php` 与 `bbs/api/trade/` 下 4 个支付接口文件——`?>` 结束标记后附带二进制载荷，非纯文本、无法验证编码，保持原样（支付/站点地图接口，与农场部署无关）。宿主包与实际部署环境逐字节一致（`home/common.php` md5 相同），本基线即实际部署所用版本。

**注意事项**：
- 带 `_gbk` / `.gbk.` 命名的文件**内容已转为 UTF-8，文件名保留原样**。若将来要部署到 GBK 版宿主，需从上游 zip 恢复原始 GBK 文件（或反向转码）；
- CMD 工具转 UTF-8 后，在中文 Windows cmd.exe（CP936）里运行会显示乱码——本仓库只把它当合并布局文档，实际构建用 Linux cp / `build.sh`；
- `source/core/module/` 内资源（SWF/JPG/PNG/XML）本就是二进制或 UTF-8，编码统一时未做任何改动。
- `module/` 内 `labor/` 目录无 PHP 直接引用，由 Flash 端自行加载（劳动节活动资源），属正常现象，勿删；
- 代码引用的 `module/levelup/levelUpUI_v_1.swf` 实际文件在 `module/mc/levelup/` 下，属上游路径历史遗留，资源以 `mc/levelup/` 为准。
