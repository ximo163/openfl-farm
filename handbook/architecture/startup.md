# 启动链

从 nmc.php 页面到主程序模块加载的完整链路。V2（issue #3）、V3a（issue #7）
翻译时逐步核实。

## 链路

1. `nmc.php` 页面 → 预加载器 `happyfarm3_v_149.swf`（已翻：FarmLite 的
   `boot` → `startLiteUI`，按 `xml.php` config 的 moduleList 拉 main3 与
   主界面三件：lite_ui_v_0 / main3_v_221 / farmui_full_v_40 / farmui2_v_58 /
   water_ui_v_0）。
2. main3 主程序入口 `module.Main`（#7 替换了原 stub）→ 
   `FarmApplication.startup`。
3. `FarmApplication.startup` 的 500/1400ms setTimeout 自动派发
   MSG_LOAD_WATER / CARDSGAME / FREEGIFT / QUICKSHOOT →
   `Module.onLoadModuleFile` → `RSLManager.requestFile`（nc_main
   moduleList 的 url）→ pool_v_13 / quickshoot_v_0 / cards_v_1 /
   gifts_v_11 四个库。
4. WildShellNc（野兽外壳）：`nc_addon.php:81` 的 beastLoaderUrl；
   `Main.as:188-190` 无条件 `loadWildShell`（不受 `_beast` 门控），
   `FarmApplication.as:766-771` 同——启动窗口必发。

## 约定

- 启动窗口请求的库必须同 commit 进 `libraries.xml` 和
  `assets/legacy-assets.txt`；门禁测试 `test/StartupModuleLibrariesTest.hx`
  拦漏报。
- 远端 swf 的 URL 加载只许在加载器类里换成 `src/shim/LocalSwfLoader.hx`
  （按 URL 尾段映射库名），其余代码保持原 `Loader.load` 调用形态——这是
  CLAUDE.md「API 映射只写在加载器类里」规则的实例（#7 的
  `Main.loadWildShell` / `FarmApplication.loadWildShell` 两处）。
- `FarmStage.getLayerByName` / `FarmApplication.getModuleByName` 按 name 查
  层/模块，调用方（NPCView 等）拿到 null 直接崩——循环变量的
  Dynamic 裸读陷阱和修法见 [lessons/index.md](../lessons/index.md) 的
  for-each 条目（#8 CI 红的根因，改动这两处时别把强类型读退化回去）。
- 资产入库与声明的机制见 [assets.md](assets.md)。

## 本地无浏览器验证启动链（nodeboot）

`node tools/nodeboot/nodeboot.mjs [--timeout 45]`：node 里垫 DOM/Canvas/XHR
拉起 `export/html5/bin`，`render_xml.php` 仿 xml.php、
`fixtures/mync-user-run.json` 仿 mync 用户数据，等 `__openflFarmReady`
（**与 CI `harness/smoke.mjs` 同一就绪标记**）后退出 0。CI web-smoke 红了
先在本地跑它看完整 trace，别盲猜。干净基线：8 次 `[CmdLoadFile]`、无
`SymbolClass:` 留痕、无报错；`/N?数字` 的 404 是原版 QQ 统计信标（游戏自己
容忍），字体 WARNING（Arial/微软雅黑）是 openfl 嵌字缺失、只影响动态文本
度量，就绪标记不受影响。
