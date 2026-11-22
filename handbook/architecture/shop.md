# 商店（shop_v_7 功能 swf：module.shop）

商店主窗与全部买入窗。#35 整片翻译，`decompiled shop_v_7/scripts/`，
25 类见 `spec/modules/farm-shop-ui.json`；模块壳 ModuleShop 是 main3 侧
翻译（issue #29），反射接入点在 `ModuleShop.onModuleLoadSuccess`。

## 拉起链与 DCE 锚

`ModuleShop.onModuleLoadSuccess` → `Utils.getClass("module.shop.ShopController")`
→ `Type.createInstance` + `.module = this` + `.initialze()`（反射字符串
一字不差）。`module.shop.ShopController` 编译期零引用——**必须**靠
`SymbolClass.dceAnchor` 的 #35 段锚住（零引用类不进产物，@:keep 也救不了，
LandTile 先例）；锚住后 html5 的 `ApplicationDomain.hasDefinition` 即真，
装配链走通。eval 无锚（表本身 `#if !eval`）：`ModuleShopTest:41` 以
getClass 恒 null 为前提，别把锚弄进 eval。`MSG_SHOW_SHOP`（可带
`{tabIndex}`）开窗并按页签懒加载；`MSG_SHOW_BUY_DOG_FOOD`/
`MSG_SHOW_BUY_SEED` 直开对应买入窗。

## 类与职责

- `ShopController`：app 三入口 + model 十事件装配。`view`/`model` 访问器
  自持（base Controller 的 m_view/m_model 是 Dynamic）；成功回包的
  `updateHostAccount`/`DATA_BUY_ITEM_ADD`/飘字提示全在这层。
- `ShopView`：BaseWindow 主窗。TabBar 五/六页签（种子/鱼苗/道具/装饰/
  广告（按 `host.level >= snsAdAllowLvl` 门控）/合作专区（按
  `adSeedTabOpen=="1"` 门控）），`EVENT_SHOP_DATA_LOADED/FAILED/LOADING`
  按 data.index 路由到页；瓦片点击按 target 类型分派到六个买入窗。
  鱼苗页素材由 `loadFishUIRes` 经 `CommonData.rslManager.requestFile`
  （`getSecondUrl("water_ui")`）按需拉。
- `ShopModel`：六页数据源 + 六个买（seed/fish/tool/diy/inGame/unlockFish）
  + `__buyType`/`__exp` 装配。mod 走 CommandDefs 中央映射。
- 六页（`module/shop/widgets/`）：`ShopSeedsPage/FishPage/ItemsPage/DiyPage/
  AdvertisementPage/AdSeedsPage`（BasePage/TileList 形态）+ 瓦件
  `CropItem/CropItemVip/ToolItem/DiyItem/FishItem/AdvertisementItem`。
- 六买入窗：`BuySeedWindow/BuyAdSeedWindow/BuyFishWindow/BuyItemWindow/
  BuyDiyWindow/UnlockFishWindow`——共享超类 BaseWindow（ADDED_TO_STAGE →
  `init → createView → addedToLayer` 序）。
- `common/view/MaterialProxyBig`：买入窗左侧大图代理
  （MaterialProxy BIG 形态，issue #35 补）。

## 符号与素材（无新库声明）

全走 SymbolClass 垫片（根包 shim 类 + `dceAnchor` #35 段）：
`ShopSeedForm/ShopToolForm/ShopDiyForm`（买入窗右侧说明面板，**farmui_
full_v_40**）、`ItemBg/ItemBgRed/ItemBgBlack`（瓦片底板）、`ButtonOrange/
ButtonBlue`、`SeedTypeBtnSelectedSkin/SeedTypeVipBtnSelectedSkin`、
`VipSeedIcon/ShopNewMarkIcon`、`ShopFoodMarkIcon/RestaurantMarkIcon/
ShopSuperMarketIcon/ActivityMarkIcon`、`SteperSkin`（原版拼写就少一个 p）、
`ShopTabNewIcon`；鱼苗角标 `FishUnlock/FishLocked/FishUnlockBg` 在
**water_ui_v_0**。`BuyItemWindow` 对 `SteperSkin` 是直 new（其余窗经
getMaterial 反射）——两者都已锚。

## AS3 松散语义译法（本片最密的坑）

- **`__buyType == 0`（Dynamic，"0" 字串与 Int 混写——原版即如此）**：AS3
  宽松等值 `"0" == 0` 为 true；静态目标直 `==` 因类型先行判不等会漏分支。
  统一 `As3.floatOf(x) == n`（toNumber 强转后比）。`x > 0` 的 Dynamic
  比较同理用 floatOf。
- **Int 字段判 `== true`/`!= true`**（`_isFood` 等默认 -1）：As3.truthy 会
  把 -1 当真——AS3 `-1 == true` 是 false，**照 `== 1`/`!= 1` 译**。
- **`x as int`**（服务端回包字段）：`As3.intOf`；`parseInt(x)` 是
  Float，落 Int 参数包 Std.int。
- **super 当值传**（`addButton(…, super.close)`、`addEventListener(CLICK,
  super.onClose)`）：Haxe 传不了 super 调用 → 具名私有包装方法 + PORT-NOTE
  （BuyDiyWindow.onSuperCloseClick、BuyItemWindow.onCancelClick）。
- **`setTimeout(f, ms, rest…)` + 零参处理器读 `arguments[0]`**：闭包在
  setTimeout 调用点捕获实参，转发进具名参量方法（ShopView.
  onSendToURLTimeout）。
- **`arguments.callee` 自摘除监听**：具名局部闭包自引用
  （ShopController.showBuySeedEx 的 onLoadedOnce）。
- **`cropTime(id)` 是 stub 返回 ""**（GetCropID）：split 后越界下标必须
  `As3.arrAt` + `As3.intSub`（null→NaN→0，等于 AS3 undefined 语义），
  别裸读 `_loc4_[4]`。
- **原版的 null 解引用路径也是行为**：ShopController.onUnlockFishSuccess
  的水晶分支（`xml.crystal.info.(@id==…).@name`）与 UnlockFishWindow.
  onMaterialCrystalOver 的同一查询——E4X 按仓库先例（FarmLite/
  FarmApplication/Settings/ConfigMerger）等价遍历 haxe.Xml。两处**不是
  死代码**：cgi_fish_unlock.php:35 成功回包恒含 crystal_id/crystal_num
  （分支每次解锁成功都进），fishtype.php 有 10 条 show=1 且水晶需求为正
  的鱼苗（悬停即进查询），而 BeastAPI.iniData 全 main3 无赋值点（仅
  IGameAPI 声明 + 自身 setter）恒 null——原版两处都在 `xml.crystal`
  抛 TypeError：悬停水晶无提示、解锁成功无飘字/引导/刷新。移植不加
  null 守卫、在 null 上同点抛错（ShopController/UnlockFishWindow 类头
  + BeastAPI.hx 三处 PORT-NOTE）。
- **openfl 派发器对监听器异常的路由与 Flash 不同（平台级）**：Flash 里
  监听器抛错沿用户栈解退，ShopModel.as:135 派发后的 loadFishInfo(true)
  被跳过；openfl html5（uncaught-error 默认开）在 EventDispatcher 内
  catch → `stage.__handleError`（日志）后正常返回，loadFishInfo 照跑。
  影响一切监听器异常，不属本片可补偿的翻译差异（编译 define 在
  Project.xml，受保护）——已列 deviations 候选待人工裁决。

## 已知偏差/待裁决

- **[deviations 候选] openfl 派发器吞监听器异常**（ShopController.
  onUnlockFishSuccess 水晶分支触发）：原版 Flash 里监听器抛错沿用户栈
  解退，ShopModel.as:135 派发后的 `loadFishInfo(true)` 被跳过；openfl
  html5 在 EventDispatcher 内 catch → `stage.__handleError`（仅日志），
  loadFishInfo 照跑、鱼苗页会刷新。监听器内部行为（抛错点、飘字/引导
  不执行）已照译一致；差异仅在派发器边界，编译 define 在受保护的
  Project.xml，本片无法消除——待人工裁决是否入 deviations.json。
- `AddButtonWindow.init/toCenterPositon` 是 #35 补译段（BuyDiyWindow 的
  `super.init()` 直落）；`addButton`（winButton）本体仍属 qui 窗口片 stub
  恒返 null——BuyDiyWindow 的 `_btnConfirm.enabled` 是**休眠 NPE**
  （setData 只在 `_yellowlevel<4 && _fb==0 && 金币不足` 组合才摸它），
  后续模块依赖。
- ExternalInterface/sendToURL → shim.QQOutlets（available 恒 false，
  deviations qqoutlets-shim 族）。
- approved 测试 `ShopModelTest.test_onTransactionError_dispatch_table`
  曾自相矛盾（:1169/:1170 期望 1，:1128-1147 循环又钉 2）——已按 NEEDS-TESTS
  报告在 write-tests 轮把期望改为 2（ShopModel.as:905/:910 对
  CMD_BUY_FISHS||CMD_UNLOCK_SHOP_FISH、CMD_BUY_TOOLS||CMD_BUY_TOOLS_VIP
  各两分支派发同一事件，未知 cmdID 不派发），现已一致。
