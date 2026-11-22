# 仓库/背包（warehouse_v_23 功能 swf：module.warehouse）

仓库主窗（六页签）+ 底部背包条 + 全部卖出/赠送窗。#36 整片翻译，
`decompiled warehouse_v_23/scripts/`，29 类见 `spec/modules/inventory-ui.json`
；模块壳 ModuleWarehouse 是 main3 侧翻译（issue #29），反射接入点在
`ModuleWarehouse.onModuleLoadSuccess`。

## 拉起链与 DCE 锚

`ModuleWarehouse.onModuleLoadSuccess` → `Utils.getClass` 反射**两个**控制器
（`module.warehouse.bag.MyBagController` + `module.warehouse.house.
WarehouseController`，字符串一字不差）→ `Type.createInstance` + `.module
= this` + `.initialze()`。两类编译期零引用，靠 `SymbolClass.dceAnchor`
的 #36 段锚住（零引用类不进产物，LandTile/ShopController 先例）；锚整体
`#if !eval`——eval 单测以 getClass 恒 null 为前提（#29 lessons 钉板），
接入后别把锚弄进 eval。`MSG_SHOW_WAREHOUSE` 四入口：裸数据开窗停在
当前页、`{openWithSeeds/openWithFlower/openWithCrystal}` → switchTab
4/3/5（种子/收到的花束/材料）；背包走 `MSG_SHOW_PACK`。

## 类与职责

- `WarehouseController`：四入口开窗 + 卖出八事件回填（金币 updateHost
  Account、飘字 openFloat、dirty 标记 + 0.5s TweenLite.delayedCall 重载）
  + DATA_CHANGED 差异路由。`showWarehouseSellEx` 的 EVENT_DATA_CHANGED
  等待闭包（arguments.callee 自摘除 → 捕获局部 fn）。WarehouseModel 的
  EVENT_* 原文 internal（静态常量）→ 跨类读配 `@:access`。
- `WarehouseView`：BaseWindow 主窗。TabBar 六页签（蔬果/鲜花/成鱼/
  收到的花束/种子/材料），瓦片点击懒开三卖出窗（winCtrl.open + .data）；
  `onTabSwitched` 的 QPLUS/WB 模式下页签 3/4 各 +1 的 quirk（成鱼/收到
  的花束在户外模式下有插入页）照抄；FlowerCard/SendFlowerWindow 注册进
  winCtrl。锁定刷新经 `refreshItemLockStatus/refreshFishLockStatus` 下沉
  到页。
- `WarehouseModel`：六数据源（crops/fishs/seeds/crystal/myFlowers +
  dirty 标记族）+ sell 八族（sellPlant/sellCrystal/sellFish/sellSeed/
  sellAll/sellAllSeeds/sellAllFish + lock 更新）+ sendFlower/
  removeMyFlower/collectNotLockedIDs。mod 走 CommandDefs 中央映射。
- bag 侧（`module/warehouse/bag/`）：`MyBagController`（MSG_SHOW_PACK
  开关、DATA_BAG_* 标脏、EVENT_INITIALZED 回填）、`MyBagView`（底部
  背包条，PackageTab 页签 + PackClose 关闭钮）、`MyBagModel`、`PackItem`。
- 六页（`module/warehouse/house/widgets/`，BasePage/TileList 形态）：
  `PlantsPage`（蔬果/鲜花两视图切换 + 赠送花束 + 合计的财神爷/仙皇加成
  ——FAIRY_MONEY=92003 是 #36 补进 Consts 的，Consts.as:586）、
  `WarehouseSeedsPage`、`WarehouseFishPage`、`CardsPage`（材料）、
  `RecvFlowersPage`（收到的花束，花束卡片/预览入口）。瓦件
  `PlantRenderItem/FishRenderItem/FlowerRenderItem`（BaseTileItem 族，
  SellLockIcon 锁/VipSeedIcon/等级标签）。
- 卖出窗三族（WarehouseForm 版式 + MaterialProxyBig 大图 + StepperMaker
  数量 + lock_mc 锁开关）：`SellPlantWindow`（`_isMaterial` 双形态，CARD
  类型半缩 0.5/52/70）、`SellFishWindow`、`SellToolWindow`（种子，
  id==28 带 unescape 广告行）。**init/addedToLayer 覆写按原文各自不调
  super**（SellFish/SellTool 覆写 init、SellPlant/SendFlower/FlowerCard
  覆写 addedToLayer，均原版如此）——别「补」super 调用，窗口底板本来
  就不走基类初始化段。
- 花束族：`SendFlowerWindow`（包装赠送：qzone 模式手输 uin/其余模式
  QzoneJSAPI.selectFriend，50 字留言，canMake 门控三控件）、`FlowerCard`
  （卡片：CMD_GET_FLOWER_WORDS 拉赠言、CMD_DEL_MYFLOWER 删除）、
  `FlowerPlayer`（全屏预览，2s setTimeout 关闭 + TweenLite 淡出）。
- qui 补件（warehouse 片带进来的子集，`com/qzone/qui/`）：`HList`、
  `listClasses/ListBase`（removeItemAt 返回删除段**数组**而非元素——
  原版 quirk，调用方只当真值用）、`ListItem{Default,Over,Selected}Skin`。
- `WarehouseWrapper`：swf 文档类空壳（控制器装配不在它身上）。

## 符号与素材

视觉符号宿主全是既有库，**warehouse_v_23.swf 本体不含 UI 符号**
（swf-inventory：SymbolClass 仅 frame0 文档类）——入库（libraries.xml
id `warehouse_v_23`、assets/legacy-assets.txt 同 commit 行）只为原 swf
随包保留 + 加载链对账，运行期无人取它的符号。垫片（根包 shim 类 +
`dceAnchor` #36 段）：**farmui_full_v_40** 的 WarehouseForm（char#594，
卖出窗右侧表单板，具名子件 cropName/price/sprice/income/lock_mc 经
As3.childOf）、FlowerCardUI（char#606，四具名 TextField）、SellLockIcon
（char#536）、ButtonGreen（char#445）、PackageTab（char#439）、ItemBg/
VipSeedIcon/ButtonOrange/ButtonBlue/SteperSkin；**farmui2_v_58** 的
PackClose（char#179，DefineButton2 → bindButton/SimpleButton）。

## AS3 松散语义译法（本片坑）

- **卖出窗的 `super.onClose` 当值传 addEventListener** → 具名私有包装
  方法（SellPlantWindow.onCancelClick，BuyItemWindow 先例）；`super.close`
  同理直调不受限。
- **Number → Int 收参截断**：`sellPlant/sellCrystal/sellFish/sellSeed
  (int,int)` 收 stepper `.value`（Float）——调用点 `Std.int(...)` +
  PORT-NOTE（#19 的 int 收 Number 一族）；`_sum:int` 的 `*=`/赋值链同。
- **`arguments.callee` 自摘除**（FlowerPlayer/FlowerCard/SendFlower
  Window 的 Loader COMPLETE 闭包、WarehouseController 的等待闭包）→
  捕获局部 `var fn` 闭包自引用。FlowerPlayer 的原文怪癖照抄：COMPLETE
  闭包里摘的是 **IO_ERROR** 监听且用 callee（=COMPLETE 闭包自己）——
  实际 no-op，别「修好」。
- **ctor 字段赋值先于 super()**（SellPlant/SellFish/SellTool 的
  _parentWin/_isMaterial）→ Haxe super() 必须先行，字段赋值移到其后
  （结果同形，PORT-NOTE）。
- **`x == undefined && x != ""`**（花束 pic 守卫）→ `As3.hasProp(x,"pic")
  && field != ""`；`body["cmdID"] == 数` → As3.floatOf。
- **外链花束图**：Loader.load(URLRequest) 保持原调用形态（CLAUDE.md：
  远程 swf → Assets 映射只在 mcloader 加载器类；HarvestAnimationCustom
  先例）。花束 pic 是 PHP 下发的完整 http URL。
- **FrameTimer 是 closure stub**（setTimeout 返 0）：本片 FlowerPlayer
  用 `As3.setTimeout`，真语义归 qui 片——调用点照译即可。

## 原版死路/怪癖（照抄不修，PR 说明列过的疑点）

- `WarehouseModel.onLoadDataError`：`:318` 恒真门 `_loc3_ != 0 ||
  _loc3_ != 1` 使重试文案分支恒不可达；`:313` 的 `body["cmdId"]`（小写
  d）与 buildRequest 写入的 `"cmdID"` 不符 → 花束错误分支恒 miss。两处
  原版字面保留（源码注释同此）。
- `WarehouseView.onLockClicked` 读 `e.data["data"]`，而瓦件派发的是
  `{"item":…,"lock":…}` → 该处理器恒取 null（原版死路；锁定点击实际
  通路在卖出窗 onLock）。`onUpdateLock/onUpdateFishSuccess` 对未开过的
  卖出窗裸调 `updateLock()`（原版 NPE 风险路径照抄）。`onDataLoading`
  的嵌套 else-if 同为死分支。
- `EVENT_SENDFLOWER_SUCCESS` 常量名（SEND）与值（"SellFlowerSuccess"）
  不一致——原名值如此，照抄。
- `WarehouseFishPage.sellAllSeeds`（从种子页复制留下的名字）、
  `SellFishWindow.onNavigateToURL`（无人挂接）——照抄。
- `ListBase.removeItemAt` 返回 splice 数组而非元素——原版 quirk，调用
  方只当真值用（ListBase.hx:29 注）。

## 已知偏差/待裁决

- ExternalInterface → shim.QQOutlets（available 恒 false，deviations
  qqoutlets-shim 族）：SendFlowerWindow 的 selectFriend、卖出窗
  onNavigateToURL 广告链接受影响。
- `tools/scan_dyn_writes.py` 对本片报 42 处，全部为**文件级同名污染**
  误报（同文件别处 `var _locN_:Dynamic` 把名字染黑，写点接收者实为
  WarehouseSeed/WarehouseFish/TextField/Button/Sprite 等真类型）——
  已逐点核对声明类型，无真 Dynamic 裸写；时间轴具名子件全走
  `cast(As3.childOf(...), 真类型)` 分流。
