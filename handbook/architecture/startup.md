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

## 模块壳与外部功能 swf（#29 起四壳全真）

`ModuleShop`/`ModuleWarehouse`/`ModuleDecorate`/`ModuleWater`（issue #29
整类翻译，替换 #7 模块壳 stub）：`startup` 里 loadLater/直接 load 的四条
注册线（shop/warehouse 见 FarmApplication.hx:937-945、water :956-957），
壳本体只做三件事——`_reportID` 上报号（160591/160592/160593/160619）、
空 `load` 覆写（**不调 super**，_loaded 不置真）、`unload` 收控制器。
`onModuleLoadSuccess` 经 `Utils.getClass` 反射功能 swf 里的控制器类
（shop_v_7 的 ShopController、warehouse_v_23 的 bag/house 双控制器、
decorate_v_0 的 DecorateController、pool_v_13 的 WaterController）。
**openfl 不执行外部 swf 的 AS3 → getClass 恒 null → 控制器保持 null，
这是移植终态不是待办**（lessons #29 条目；测试用 isNull 把接入点钉死，
功能 swf 翻译批次接入后断言转红即该改期望）。停网复位
（onNetRequestStopped）的 `["model"]["resetLoadingFlags"]()` 鸭式调用照
Reflect 翻（控制器类型期是基类 Controller，没有 model 公共成员）。
ModuleWater 特有：ctor 收听 MSG_ZOOM；控制器未装时 onGameLoop（主循环对
全部注册模块逐帧调、**不看 _loaded**，FarmApplication.onMainLoop）在
LAYER_SCENE_CONTENT 摆 FarmLoading 占位（x=746/y=620，bigmode 1.3×）、
onModuleLoadSuccess 装好后移除——反射失败终态下占位**常驻**（web-smoke
期间可见；原版装好 swf 才移除，属功能 swf 批次接入前的既知视觉偏差，
deviations 候选）；其 `_loading:MovieClip` 与基类 Module
`_loading:Boolean` 同名异型，改名 `m_loading` 拆槽（lessons #21
同名异型条）。

## 引导与切换遮罩（#43 真身）

- `module.GameGuide`（#7 闭包 stub → #43 真身，2026-11-21 真机「引导不弹」
  的正主就是空体）：鱼塘新手引导箭头。**步骤数据是本类私有静态表
  fishGuideStep（GameGuide.as:42-87 硬编码九步坐标/朝向），没有服务端/xml
  下发**；唯一开关 `toggle_water` 由 WaterGrayOpen.onTutorialClosed
  （#37）置位后同处起步，链路经 ShopView/ShopController/BuyFishWindow/
  MyBagController/WaterPool 推进（#35/#36/#37 调用点）。箭头素材 `Arrow`
  是 farmui2_v_58 的导出符号（char#240，20 帧；spec farm-basic.json 本条
  assets 列了牧场 farmui2_v_44 同名符号，那是 Master2 侧宿主，本仓绑农场
  宿主）——shim `src/Arrow.hx` + dceAnchor（assets.md 三登记义务照走）。
  showStep 四道门（toggle/_stop、箭头在、前进向、表长）+ 大小视图 x 偏移
  档（>820/+60、<720/-50，icon 步特加 ±68/-50）+ (-1,-1) 动态锚 + tip 只在
  WATER_FISH_ITEM 步挂载；autoHide 到点 hide 并 `_stop=true` 封死。
- `module.load.UserChangingBar`（#7 闭包 stub → #43 真身）：切用户遮罩条。
  ADDED_TO_STAGE 建三件（60% 白全屏遮罩、居中 DataLoading、中心左偏 50px
  文案条）听 `MSG_USER_SWITCH_FLAG`：error 缺位/空串按 showLoading 驱动
  遮罩+转圈，非空亮错误文案；`event:` 链接点击重派发 `__reload__` 载荷
  再切一次。FarmStage.initTopLayer 建进 LAYER_TOPMOST。

## 本地无浏览器验证启动链（nodeboot）

`node tools/nodeboot/nodeboot.mjs [--timeout 45] [--settle 3]`：node 里垫
DOM/Canvas/XHR 拉起 `export/html5/bin`，`render_xml.php` 仿 xml.php、
`fixtures/mync-user-run.json` 仿 mync 用户数据，等 `__openflFarmReady`
（**与 CI `harness/smoke.mjs` 同一就绪标记**）。就绪后**不立即退**，再跑
`--settle` 秒（模拟 CI 的 500ms 渲染等待 + 尾部异步回调）才收尾。退出码 1
的三种来源：就绪超时、未捕获异常、**缺失资源**——服务器 404、Image src
文件不存在、**XHR 出网请求**都计数（CI web-smoke 挂在 console.error，
本地与之对齐；就绪前 404 走的是库加载 onError 分支，就绪标记照样置位，
不看缺失资源就会漏报，#8 两轮 CI 即如此）。CI web-smoke 红了先在本地跑
它看完整 trace，别盲猜。干净基线：8 次 `[CmdLoadFile]`、无
`SymbolClass:` 留痕、无报错、零 `[nodeboot] 404/image 404`、**零
`[nodeboot] 出网请求`**——出网＝http/https 且主机非本进程的 XHR：资产已
全部本地化，离开本进程的请求在任何部署外环境都注定失败（#9 前两轮
同点红的 `ERR_NETWORK_CHANGED` 即头像 headPic 指向快照 UC_API 的局域网
地址，浏览器挂死被杀）；nodeboot 不真发（真发会随环境漂移），计缺失
并打调用栈后走 error 事件。**fixture 必须携带真实下发值**才能看见 CI
所见的请求——`fixtures/mync-user-run.json` 的 headPic 就是
user_run.php:276 的原值，别清成空串把检测弄瞎（#9 nodeboot 曾因 fixture
值失真连绿两轮）。字体 WARNING（Arial/微软雅黑）是 openfl
嵌字缺失、只影响动态文本度量，就绪标记不受影响。
`/N?数字` 形态的 404 **是未声明库**：`Assets.loadLibrary("<id>")` 对不在
libraries.xml 里的 id 落到 AssetManifest 兜底加载 `/<id>?<random>`（id 即
LocalSwfLoader 按 URL 尾段映射出的库名）——见到它先按 #8 的数据链
（decorative → idToDiyUrl2 → module/ui/farm/diy/N.swf）找出该 id 的 URL
和出处，入库修掉，不是可以忽略的统计信标（attempt 2 曾误判为 QQ 统计
信标而漏掉，attempt 3 用 XHR 栈实锤是 AssetManifest.loadFromFile）。
