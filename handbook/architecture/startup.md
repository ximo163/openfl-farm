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
- 资产入库与声明的机制见 [assets.md](assets.md)。
