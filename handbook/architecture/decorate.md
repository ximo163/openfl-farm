# 装饰/DIY（decorate_v_0 功能 swf：module.decorate）

DIY 装饰编辑窗（我的装饰：激活/取消、告示牌、插件页签位）。#38 整片翻译，
`decompiled decorate_v_0/scripts/`，9 类见 `spec/modules/farm-decorate-ui.json`；
模块壳 ModuleDecorate 是 main3 侧翻译（issue #29），反射接入点在
`ModuleDecorate.onModuleLoadSuccess`。

## 拉起链与 DCE 锚

ModuleDecorate 经 `loadLater([Consts.MSG_SHOW_DIY], null)` 延迟装载 →
Module.onLoadModuleFile → RSLManager.requestFile（nc_main.php:17 moduleList
"Decorate Module" → `module/ui/decorate_v_0.swf`，LocalSwfLoader 按文件名
映射库名 `decorate_v_0`）→ onModuleLoadSuccess →
`Utils.getClass("module.decorate.DecorateController")` → `Type.createInstance`
+ `.module = this` + `.initialze()`（反射字符串一字不差）。

- `module.decorate.DecorateController` 编译期零引用——`SymbolClass.dceAnchor`
  的 #38 段锚住（LandTile 先例）；View/Model/widgets 经控制器可达，不入表。
  eval 无锚（表 `#if !eval`）：ModuleDecorateTest 以 getClass 恒 null 为前提。
- swf 本体无视觉符号（SymbolClass 只有 frame0 文档类 DecorateWrapper，
  9 类全是 scripts）：库声明是「原 swf 随包保留 + 加载链对账」，无符号 shim。
- app 三入口（MSG_SHOW_DIY 的 data）：null → 开窗 + loadItems；
  `openBillBoard == true` → 开窗 + loadBoards + switchTab(1)；`plugin_tab`
  存在 → 开窗 + switchTabByName（按页签文字找 Button）。
- `module/ui/main/decorate_v_0.swf` 是同文件另一份拷贝（md5 相同），moduleList
  引的是**非 main** 那份（spec notes），入库也只入后者。

## 类与职责

- `DecorateController`：装配 + `NOTIFY_REFRESH_MAINSCENE` →
  `MSG_REFRESH_SCENE` 转发（刷主场景背景）+ `DATA_DECORATE_RELOAD_FLAG`
  置脏。view/model 访问器自持（base Controller 的 m_view/m_model 是
  Dynamic）。
- `DecorateModel`：协议状态机（见下）。EVENT_*/NOTIFY_* 原文 internal 译
  private，同包消费方（Controller/View）类级 `@:access`。
- `DecorateView`：BaseWindow 400×420，TabBar 两页签（装饰/告示牌，高 24，
  y=30，宽 WIDTH-2）+ PluginManager 第三页签挂点（页签 2 时窗高 -100、
  `PluginManager.onTabSwitched`——#38 补的 no-op stub）。条目点击分流：
  狗（id > 80000 且已装备且狗未饿）先弹「隐藏狗」确认框（380×270）；默认
  背景（id == -1）已装备时点击直接吞掉；其余 selectDecorate。
- `widgets/DecorsPage`：两 Canvas 分区（当前装饰 y=65 h=80 装
  DecorHeadRenderItem / 已购买 y=188 h=160 装 DecorRenderItem；宽 param2-4、
  滚动全关）。**不用 TileList**——onCreateTile 只把基类懒建的 _tile 摘掉。
  arrangeItems 按类型分列（x=20/90/160/230/300，y 起 12 步进 60+15），尾上
  无条件 `validateNow()`（两次 arrange 各一记，含当前区那次——原文如此）。
  initCurrentDivChildCache 的换装缓存有「_loc5_（下标）> _loc7_（子件数）
  比大小」的怪逻辑，照抄。
- `widgets/BoardsPage`：TileList（100×100 格、paddingH 8、x=25 y=21、宽
  -30 高 -85、横向滚动关）。`_sumPrice:PropertyText` 是从仓库页复制的死
  字段（声明后从未赋值，原版如此）。changeBoard 遇首个非 BoardRenderItem
  条目是 `break` 不是 continue（原文如此）。
- `widgets/DecorRenderItem/DecorHeadRenderItem`：60×60（ItemBorder 底 +
  遮罩），「已装饰」/「点击装饰」角标（Verdana 12 / 13369344 / 居中 +
  辉光）。Head 版角标可见性与 setContent 反灰参**与基类相反**（原文复用
  反着用）；狗类 itemId 走 `- 80000` 硬编码（原文如此，不是
  DECOR_DOG_BASE_ID 常量）。
- `widgets/BoardRenderItem`：100×100（ItemBg 底），DECOR_BILLBOARD.toString()
  通道 + loadBillBoard/showLoading。

## 协议与数据

- 装载：`CMD_GET_DIY_ITEMS 38`（mod=item act=getUserItems）→
  DecorateItemsParser 把 current 拆组 0、items 拆组 1
  （`Dictionary<Int, Array<DecorateItem>>`）。空回包清空全表置 null。
- 激活/取消：`CMD_ACTIVE_DECORATE 86` / `CMD_DEACTIVE_DECORATE 87`
  （item.activeItem/deactiveItem），selectDecorate 按 `_status` 分流、
  selectBoard 按 `myBoardID` 分流（type=1）；`m_requesting` 单飞闩，
  resetLoadingFlags 由 ModuleDecorate.onNetRequestStopped 复位。
- 告示牌：loadBoards 读 `Settings.getBillBoardData()`（boards 配置）
  **原地 reverse——会改配置数组本身，原版如此**，再按 myBoardID 标
  status。
- 回填：ctor 尾 `setMyDecorate(Session.sceneDecorates)`：槽 "9" →
  myBoardID、槽 "8" → myDogID = 80000 + itemId（DECOR_DOG_BASE_ID）。
- 时序怪癖（DecorateModelTest pin 过）：onDataLoadSuccess 里 myDogID
  setter 在组表重灌**前**触发——旧表每键一记 DataChanged{index:0} 先出、
  再 LOADING{show:false}/LOADED{index:0}；重载（旧表非空）因此多两记
  DataChanged，首次装载没有（表空零圈）。

## 语义坑（本片）

- `code == "1"`（协议 code 是 int）→ As3.eqString；`as int` → intOf；
  `data == "reload"` → eqString；`openBillBoard == true` → floatOf == 1。
- for-in/for-each 遍历 null Dictionary/组 → AS3 零圈，判空跳过（本片五处：
  onDeSelectDecorateSuccess/setDefaultBackground/set_myDogID/
  onDataLoadSuccess/onSelectDecorateSuccess）。
- openfl Dictionary（9.5.2）无 keys()：`for (k in dict)` 即键遍历
  （FishMCPoolObjectMgr 先例）。
- instance const WIDTH/HEIGHT → static final，访问去掉 this.。
- `super.data` 读 → `super.get_data()`（water 先例）；`_loc9_.data = _loc4_`
  这类 typed 接收者的 (get,set) 属性写不是 Dynamic 裸写，照写。
- `TextField.filters = Style.getTextGlowFilter()`（Array<Dynamic>）要
  `cast`（ToolItem 先例）。
- 语言表把「农场装饰」映射成「装饰」：标题照 `Reflect.field(Language.L,
  "农场装饰")` 取（取到什么显示什么，原版即如此）。
- WindowControl.open 仍是窗口片 stub：onShowDecorate 的 openBillBoard 路径
  `switchTab(1)` 假定开窗即 init（原版同样假设）——窗未初始化时 m_tabNav
  为 null 会崩，与原版等价，不是要修的 bug（窗口片接手时自然消解）。
- scan_dyn_writes 报的 DecorateModel 四条 `_status` 写：typed 接收者
  （`Array<DecorateItem>` 循环变量直接字段写），cast 生产链让扫描器把组表
  当 Array<Dynamic>——误报，无需分流（`-dce full` codegen 核实是直接
  赋值，不走反射）。

## 测试

- `test/module/decorate/DecorateModelTest.hx`（write-tests 已批）：协议
  状态机全 pin（ctor 默认、setMyDecorate 槽位映射、装载门闩、上文时序
  怪癖、boardArray 重标、selectBoard/selectDecorate 单飞与成败回包事件）。
- `test/module/decorate/ModuleDecorateTest.hx`：壳行为 + eval getClass
  恒 null 前提。
