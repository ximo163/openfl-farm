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

`node tools/nodeboot/nodeboot.mjs [--timeout 45] [--settle 3]`：node 里垫
DOM/Canvas/XHR 拉起 `export/html5/bin`，`render_xml.php` 仿 xml.php、
`fixtures/mync-user-run.json` 仿 mync 用户数据，等 `__openflFarmReady`
（**与 CI `harness/smoke.mjs` 同一就绪标记**）。就绪后**不立即退**，再跑
`--settle` 秒（模拟 CI 的 500ms 渲染等待 + 尾部异步回调）才收尾。退出码 1
的三种来源：就绪超时、未捕获异常、**缺失资源**——服务器 404 与 Image src
文件不存在都计数（CI web-smoke 挂在 console.error，本地与之对齐；就绪
前 404 走的是库加载 onError 分支，就绪标记照样置位，不看缺失资源就会
漏报，#8 两轮 CI 即如此）。CI web-smoke 红了先在本地跑它看完整 trace，
别盲猜。干净基线：8 次 `[CmdLoadFile]`、无 `SymbolClass:` 留痕、无报错、
零 `[nodeboot] 404/image 404`；字体 WARNING（Arial/微软雅黑）是 openfl
嵌字缺失、只影响动态文本度量，就绪标记不受影响。
`/N?数字` 形态的 404 **是未声明库**：`Assets.loadLibrary("<id>")` 对不在
libraries.xml 里的 id 落到 AssetManifest 兜底加载 `/<id>?<random>`（id 即
LocalSwfLoader 按 URL 尾段映射出的库名）——见到它先按 #8 的数据链
（decorative → idToDiyUrl2 → module/ui/farm/diy/N.swf）找出该 id 的 URL
和出处，入库修掉，不是可以忽略的统计信标（attempt 2 曾误判为 QQ 统计
信标而漏掉，attempt 3 用 XHR 栈实锤是 AssetManifest.loadFromFile）。
