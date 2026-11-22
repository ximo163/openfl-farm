# 鱼塘（pool_v_13 功能 swf：module.water + common.cache）

鱼塘全片：放鱼/捞鱼/喂鱼/偷鱼/卖鱼协议、鱼群游动状态机、水池渲染与
可捞旗、池塘详情窗、开池引导。#37 整片翻译，`decompiled pool_v_13/
scripts/`，14 类见 `spec/modules/water-ui.json`；模块壳 ModuleWater 是
main3 侧翻译（issue #29），反射接入点在 `ModuleWater.onModuleLoadSuccess`。

## 拉起链与 DCE 锚

`FarmApplication.startup` 500ms 定时派 `MSG_LOAD_WATER` → ModuleWater
load → `onModuleLoadSuccess` → `Utils.getClass("module.water.
WaterController")`（字符串一字不差）→ `Type.createInstance` +
`.module = this` + `.initialze()`。WaterController 编译期零引用（WaterPool
只有它的字段/参数签名），靠 `SymbolClass.dceAnchor` #37 段锚住；锚整体
`#if !eval`。装配后 `initialze` 直接调 `onInitialized(null)`（原文如此，
:396）→ `Session.me` 真值分流 checkWhiteList/loadFishes →
`WaterPool.loadRes` 拉 `module/ui/water_v_5.swf`（`getSecondUrl("water")`，
LocalSwfLoader 按文件名映射库名）→ `onCheckLoaded` ENTER_FRAME 里经
**`CommonData.applicationDomain`**（不是 currentDomain）hasDefinition/
getDefinition 反射 WaterLand3/StoneFrame1 建池。

**boot 胶水（PORT-NOTE(boot)）**：原版 `CommonData.applicationDomain`
由外层文档类赋值（mcloader FarmWorld.as:81 / 预加载器 FarmLite.as:424，
值均为 currentDomain）；移植以 Main 为根、外层片不翻，#37 在
`Main.init` 补上两行赋值（CommonData.applicationDomain + APP_DOMAIN）。
之前没有解引用点所以一直缺位——动 CommonData.applicationDomain 相关
加载链时先看它是不是 null。

## 类与职责

- `WaterController`：MSG_SHOW_POOLINFO（PoolInfoWindow）/MSG_SHOW_
  GUIDE_ARROW（showGuideArrow 按四角 anchor 偏移放箭头 + 3s 自动收）/
  MSG_FISH_GUIDE/MSG_SHOW_WATER_CURSOR（Reflect.setField 往 result 补
  "fish"）/MSG_RELOAD_GAME_RESULT 等 8 个 msgCenter 监听 + WaterModel
  10 事件；FISHNET/FISHNET_ALL 光标注册（Utils.getClass 反射 CursorFishNet
  /CursorFishNetAll，#9 锚已在）；onGameLoop 每 WATER_POOL_COUNTDOWN=12s
  （Consts.as:42）切池 + 700ms 批处理窗口 + FishAnimationMgr.onGameLoop。
  initialze 里 `x = 46 + 6*ITEM_WIDTH/2, y = 320 + 4*ITEM_HEIGHT/2`
  （ITEM_WIDTH=153/ITEM_HEIGHT=76.5，实例 const → static final）。
- `WaterPool`（extends PoolMap）：主视图。成熟旗 `_matureFlag` 的
  `_matureFlag["fish"]` 动态属性走 ClipProps 侧表；onEnterFrame 逐帧驱动
  FishMover（moveFrame→think 状态机）+ 悬停 50ms Timer 出 FishInfoTip；
  `showWaterFlower` 反射 `FishWave_<n>`（0-3）放浪花；`onMouseOver` 的
  `split(",", 2)` Haxe 无限参形态 → `split(",")`（只读 [0]，行为同）；
  `reset` 的 `splice(0)` → `splice(0, length)`。
- `WaterModel`：EVENT_* 11 个 internal 静态常量（跨类读配 `@:access`，
  FriendsController 先例）+ 捞/放/喂/偷/开池全协议（CMD_GET_FISHES/
  PLANT_FISH/HARVEST_FISH/HARVEST_ALL_FISH/FEED_FISH/STEAL_FISH/
  WATER_OPEN/FISH_OUTPUT）；`growLoop` 的 `_requestOutputRecord`
  （Dictionary<Int,Int>，@:multiType 必须显式类型参）记到 2 封顶；
  `onNetError` 按 `body["cmdID"]` 七路派发错误文案。
- `FishMover`：鱼群状态机（SWIM/IDLE/ADJUST/CENTER/JUMP 五态 × FAST/
  NORMAL 两档）。`formatFishName` 的 `"F"+池号+"_"+两位 type+"_"+等级
  +"_"+方向` 是鱼动画符号命名约定（FishAnimationMgr.createFishMC 的键）。
  实例 const（FAST_SPEED 等 12 个）→ static final，类内 `this.FAST`
  形态要去掉 this.（Haxe 禁实例收静态）。
- `PoolMap`：池底素材壳（PoolMap 符号 + holder/_limit/anchor a1-a4 具名
  子件经 As3.childOf）+ 出生圈 c4/c7/c10/c13/c16/c19（SPAWN_CIRCLE_NUM=24）
  + 与池边界的碰撞（cdWithPoolLimit）。protected 成员照 Haxe private
  （WaterPool 子类可读）。
- `FishAnimationMgr`：单例。FishMCPoolObjectMgr（对象池）+ LoadManager
  （maxThreadCount=3，按 animationUrl 拉鱼动画 swf）+ CountDown
  （FISH_POOL_GC_COUNTDOWN=300s，Consts.as:46）到点 gc。
- `FishMCPoolObjectMgr`：`Dictionary<String,Class>`（linkage 名→类）+
  `Dictionary<Class,ObjectPool>`（类→池）；register 经 ApplicationDomain
  currentDomain hasDefinition/getDefinition；POOL_GROW_SIZE=2。
- `FishInfoTip`：悬停详情（MCFishTip 符号）。鱼苗期/幼鱼期/成熟期三段
  文案 + `growBar` 宽 `120*(1-t/T)` 夹 0..120；`(已捞取)` 贼标记；非满级
  1000ms Timer 刷 leftTime。
- `PoolInfoWindow`（extends BaseWindow）：池塘详情。groupFishes 按 type
  分组（`++num` → Reflect.setField），item0-5 行填 名称/条数/占用，鱼图标
  经 RSLManager.requestClass("Fish_<type>") 异步装配；1-4 帧四档行数 →
  高度 244+45*n。ctor 参是 IMsgCenter（BaseWindow 同签名）。
- `WaterGrayOpen`：未开池灰盖（WaterOpenBoard @ 214,80）+ 开池流（教程
  PostWindow → MSG_POOL_OPEN → model.openWater）+ fishNPC 教程位。
- `WaterWrapper`：swf 文档类空壳（[SWF] 元数据不移植）。
- `common.cache` 三件（pool_v_13 特有，main3/Master2 均无此包）：
  `ObjectPool`（环形 ObjNode 链：allocate 预建/borrow 借尽抛「object pool
  exhausted.」/grow=true 借满翻一档 initSize/purge 裁回）、
  `SimpleFactory`、`IObjectPoolFactory`。

## 符号与素材

两库都在 libraries.xml + assets/legacy-assets.txt（同 commit 行）：
- **water_ui_v_0**（#3 就有）：PoolMap(#67)、MCFishTip(#75)、
  HarvestFishFlag(#49)、WaterOpenBoard(#46)、PoolInfoContent(#95)、
  FishWave_0-3(#51/55/53/57)——全部根包 @:keep shim + dceAnchor #37 段。
- **water_v_5**（#37 新增，不 preload）：WaterLand3(#27，26 帧池水)、
  StoneFrame1(#30)——经 `CommonData.applicationDomain` 反射构造的同名
  shim 类（宿主库经 LocalSwfLoader 的 URL→库名映射拉起）。

**已知缺口（按原版「swf 未加载」终态，非 BLOCKED）**：17 个鱼动画
fish_XX.swf（`source/core/module/ui/farm/fish/`，各导出 FS_*/FJ_* 七八枚）
没建 shim——FishMCPoolObjectMgr.register 查不到定义返 null、鱼不可见
（= 原版动画 swf 未加载时的状态）；FishFoodEffect 符号（FishMover.
playFeedEffect）同缺；fishNPC1.swf 在 nc_addon.php 有引用但**部署包
无此文件**（只有 fish_tutorial.jpg），LocalSwfLoader 报错即原版 404。
冒烟场景无鱼，三者都不拦门禁；要补时逐符号加 shim + dceAnchor。

## AS3 松散语义译法（本片坑）

- **for-each 循环变量被影子化成 Dynamic**：`for (x in arr)` 里
  `Array<Dynamic>` 的元素型就是 Dynamic——**外层 `var x:PoolFish` 管不
  到循环变量**（新绑定遮蔽），元素上的属性 getter（poolSize/
  animationUrl/fish）动态取 eval 返 null、js 落 undefined（js 上静默
  NaN，比 eval 崩更险）。防：`var typed:Array<T> = cast arr; for (x in
  typed)`（ShopModel「typed 收窄」/FarmLandModel:1288 先例）。本片
  7 处（WaterModel×3/FishAnimationMgr/WaterPool.reset/PoolInfoWindow）。
- **实例 const → static final 后类内 `this.CONST` 要去 this.**：AS3 实例
  常量经 this 取合法，Haxe 静态经实例取编不过（FishMover 12 个、
  WaterController 2 个）。
- **`new Dictionary()` 必须带类型参**：openfl Dictionary 是 @:multiType，
  空 infer 不出底层 map（`Dictionary<Dynamic,Dynamic>` 直接编红）——键值
  实型写全（WaterModel 的 `<Int,Int>`；函数键要对象型，见 UIComponent:24）。
- **AS3 VM 零值默认要显式落**：int/uint→`= 0`、Number→`= Math.NaN`、
  Boolean→`= false`（eval 未赋值是 null、js 是 undefined；HealthMode:11
  先例）。本片 ObjectPool 三计数、FishMover 七 int、WaterPool/
  WaterController/PoolMap/FishInfoTip 各若干。
- **`super.data` → `super.get_data()`**：`(get,set)` 属性经 super 读走
  基类 getter（#36 lessons 证实普通字段形态才被禁），PoolInfoWindow.
  setData 的 `super.data` 照此。
- **`parseFloat(x) as uint`** → `As3.intOf(As3.floatOf(x))`（FishInfoTip
  的 hostId）；AS3 Number 隐式 ToString 落 text → `Std.string(乘积)`。

## 原版死路/怪癖（照抄不修）

- `FishMover.move()`：`Math.sqrt(x*x + **x***x)`（.x 写两遍，y 没进模长）
  —— FishMover.as 原文如此，照抄 + PORT-NOTE。
- `WaterModel.processStealFish`：守卫 `_loc3_ != null` 判空后又在外层
  读 `_loc3_._output`（null 时 NPE 路径照抄）。
- `FishMCPoolObjectMgr.unregister`：`_map[param1]` 拿 **String** 键查
  **Class** 键的 Dictionary（恒 undefined）→ 译 `_loc3_ = null`（可观察
  行为同：双表删完返 null）+ PORT-NOTE。
- `WaterGrayOpen.flag` setter 的 `_loader.removeChild(this._loader)`
  （把自己从自己身上移除，原版怪癖）。
- `WaterPool.findNearPos` 先读 `_pool.numChildren` 后判 `_pool` null。
- `PoolInfoWindow` 的 `onLoaded` 先 `this.graphics.clear()` 再把图标塞
  进**行容器**（清的是窗口自己的 graphics，怪但无害）——照抄。

## 测试前提冲突（#37 implement 报 NEEDS-TESTS 的两条）

- `ModuleWaterTest.test_shell_name_report_id_and_reflection_null_branch`
  断言 `onModuleLoadSuccess` 后 `_waterCtrl` 仍 null——前提是 getClass
  在 eval 恒 null。实现后 **FishMover 的 `_waterPool:WaterPool` 签名**把
  WaterPool→WaterController 拖进 eval 类型表（FishMoverTest 引 FishMover），
  getClass 变真、构造链进 initialze→loadFishes，在无 Session 用户的测试
  环境 NPE。legacy 真行为是装配成功（onModuleLoadSuccess 本就以 RSL 加载
  成功为前提）；shop/warehouse 同款测试当时过，纯因它们的测试集不引用
  能拖到控制器的类。
- `ObjectPoolTest.test_destroy_then_allocate_rebuilds:194` 期望
  destroy+allocate 后 usageCount 归零——ObjectPool.as 的
  destroy(:199-211)/allocate(:213-239) **都不复位 _usageCount**（原版借出
  后 destroy+allocate 计数保留 1；purge 才重置）。
