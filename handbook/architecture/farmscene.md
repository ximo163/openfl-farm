# 农田场景渲染（V3b）

mainScene 的画面层：农田地块、背景装饰、NPC。#8（V3b）翻译时核实。数据层
（FarmLandModel、Session）见 [data.md](data.md)；资产本地化见 [assets.md](assets.md)。

## farmLand（`src/module/mainScene/farmLand/`）

legacy 出处：`decompiled main3 module/mainScene/farmLand/`。

- `FarmLandController`（← FarmLandController.as 1074 行）：场景控制器。
  光标状态机（cursor 名就是 `Consts.CURSOR_*` 字符串，`clickOnLand`
  按 cursor 名分流 `m_model.operate_*`）、开垦确认、红土地升级动画
  （`LocalSwfLoader` 拉红土地 swf，`onPlayUpgradeRedLandAnimatin`）、
  飞机送信（PlaneWindow）、一键偷菜时间窗（`isOneClickMode`，
  `batchStealHour` 的 from/to 是**字符串**，经 `As3.floatOf` 数值比较）。
  10s 农田刷新节拍 `m_updateFreq`（`common.misc.time.CountDown`，顺手翻
  39 行）：`onGameLoop` 每帧问 `isReady()`——**调用即自减**，归零侧才回
  true，命中才跑 `model.growLoop()` 并 `reset(Consts.FARM_LAND_COUNTDOWN=10)`；
  `reset(0)` 抛 ArgumentError（0 是非法节拍，别拿它当「禁用节拍」用）。
- `FarmLandsView`（← FarmLandsView.as 960 行）：24 格地块排布与状态渲染。
  **地块实例名是交互路由键**：`__FarmlandItem__<行>.<列>`（额外第 4 行是
  `.3` 后缀）、荒地 `__reclaim__`、飞机 `__plane__`、遮罩 `__mask__`——
  `onMouseEvent`/`onLandClicked` 全靠 `name` 分流，**实例名一个字符都不能改**。
  `e.target`/`e.currentTarget` 静态是 openfl 的 Object（=Dynamic），name 经
  Dynamic 裸读在 js 恒 undefined——路由键的读法必须
  `(e.target : DisplayObject).name` 强类型（机制与修法见 lessons for-each
  条目，#8 attempt 2 修的 7 处之一）。
  `SCALE=0.75`，`ITEM_WIDTH/HEIGHT = 204/102 * SCALE`，静态量先 `SCALE`
  再派生（Haxe 静态初始化按声明序）。悬停高亮走 ColorMatrixFilter（数组
  逐字照抄，`m_overFilters`）。
- `OperationQueue`（← OperationQueue.as 293 行）：撒种/除草/虫/药四槽合批
  （`ADD_WEED 0 / CLEAR_WEED 1 / ADD_BUG 2 / CLEAR_BUG 3`）。请求侧 place
  串接（`"1,2,5"`），回包按 `cmdID` 分槽、按 `farmlandIndex`+方向合并
  （ADD 类取大、CLEAR 类取小，money/exp 累加、levelUp 只升不降），
  展示侧 400ms Timer 逐条派发 `EVENT_OPERATE_SUCCES`。槽常量与
  `EVENT_OPERATE_SUCCES` 原版 `internal`、同包 FarmLandModel 引用 → Haxe
  public；`EVENT_OPERATE_ERROR`/`QUEUE_LEN` 原版 internal 且全库无外部引用
  → private。
- widgets/：`LandItemRender`（单地块渲染编排：setGrowStep→createCrop/
  createByproduct→updateLandStatus）、`LandTile`（地块底图，来自
  farmui_full_v_40 库）、`Crop`（作物 swf 影片，`Crop_<cId>_<step>.swf`
  库；step 3/4/5 同用 `Crop_*_3` 单帧符号、靠 step1/2/3 子件显隐分段——
  库**首次**拉起是异步窗口，`new` 完就写子件显隐会被吞，onCropLoaded 的
  三笔显隐经 `SymbolClass.afterAttach` 登记、attach 后重放，见
  [assets.md](assets.md) 的 SymbolClass 条目。**farmlandstatus 字母协议：
  a=作物号、b=cropStatus**（farmlandstatus_getoutput.php:62 `"cId":$a`
  可证；visit 4 attempt 1 前把 b 误当作物号，库收错过 cId=1/6 十档）。
  类名构造只出 0/1/2/3/6 档（Crop.as:93-99 把 3/4/5 折叠 3，**4 档类名
  不可达**）；无 m0/m4 的作物（如快照的白萝卜 cId=2）0/6 档走公共分支：
  类名 `publicCropPrefix+档` = Crop_1_0/Crop_1_6（Crop_1_6 的素材在
  Crop_1_4.swf 里，URL 折叠 6→4、符号名带未折叠档位））、`Byproduct`
  （草/虫摆件，`getInsectPosition` 决定坐标）、`LandPickIcon`（可摘手势
  图标）、`LandTalkTip`（NPC 对话气泡）、`Wasteland`（荒地块）。

## background（`src/module/mainScene/background/`）

legacy 出处：同目录 background/。装饰槽位模型 + 场景背景屏。

- `BackgroundModel`（← BackgroundModel.as 220 行）：五槽固定序
  BG/HOUSE/FENCE/DOGHOUSE/BOARD（`INDEX_TO_TYPE_MAP`/`TYPE_TO_INDEX_MAP`
  互逆，`DECOR_DOG` **不是槽**——那是 NPC）。`changeDecor(-1)` 是「先取
  快照再移除」；BG 的 removeDecor 有 url 空守卫（无资产配置时槽不动）。
  变更经 `Session.sceneDecorates` 回写（BILLBOARD 走 `idToBoardUrl`，其余
  `idToDiyUrl2`，两者 no-config 都回 `""`）。
- `BackgroundScreen`（← BackgroundScreen.as 500 行）：五装饰 holder（坐标
  逐字：fence 380/186、dogHouse 464/231、house 571/242、ad 48/240，BG 全屏
  + 1024×810 遮罩 16711680）+ `RSLLoader` 组装载（`completeFn=onLoaded` 按
  `LoaderInfo.url` 对槽）+ 牧场导航 `Navigate`（60/480）。原版
  `loader.unloadAndStop` 的 `hasOwnProperty` 鸭子判在 openfl 上恒 false
  （`Reflect.hasField` 只见物理字段不见方法，openfl Loader 其实有该方法）——
  远程 swf 已本地化，该释放路径不可达，PORT-NOTE 在位。
- **装饰 swf 是数据驱动入库项**：uid=1 的 decorative（快照
  initialized.sql:5718）逐槽 `idToDiyUrl2(itemId)` 成
  `module/ui/farm/diy/{1,2,3,4}.swf` 再组装载——四个库都要在
  libraries.xml/legacy-assets.txt 里（#8 attempt 1/2 漏了 2/3/4，CI 三条
  404）。见 [assets.md](assets.md) 的逐项入库义务。
- **看板槽（9）不在 decorative 列里**：user_run.php:206 按 activeItem
  （快照 90001）补发 items 槽 9 → boards 90001（nc_data.php:5977）→
  asset 1719（:2260）`module/ui/farm/diy/board/1.swf`，BackgroundModel 的
  DECOR_BILLBOARD 分支走 `idToBoardUrl`。board/1.swf 与 diy/1.swf 文件名
  相同，库名消歧为 `board_1`（LocalSwfLoader 的 diy/board/ 特判——撞库
  不 404、看板槽装错背景图，CI 冒烟不拦，由
  test/CropLifecycleLibrariesTest 钉住）。注意 SceneDecorLibrariesTest
  类头注释的「billboard=9 不在 uid=1 数据里」不成立：decorative 列确实
  没有 9，但 user_run 是按 activeItem 补发槽 9 的（该测试文件
  append-only，纠正落在 CropLifecycleLibrariesTest 类头和这里）。
- `BackgroundController`（← BackgroundController.as 172 行）：StartupData
  装饰下发进模型；`MSG_ENTER_PREVIEW`→`changeDecor` 快照 + PreviewDiyWindow；
  `finalize` **只清 m_model 不调 super**（基类那份会连 m_view/m_module 一起
  清，语义不同，照原文覆写）。
- `PreviewDiyWindow`（← PreviewDiyWindow.as 42 行，闭包顺手翻）：取消预览
  窗。super 链的标题栏/关闭行为落在 qui 窗口片 stub 上（见下）。

## npc（`src/module/mainScene/npc/`）

legacy 出处：同目录 npc/。看门狗（数据 + 渲染 + 狗粮盆）、活动 NPC、
361 广告位。狗走 `DECOR_DOG` 消息键，但数据在 NPCModel、不在
BackgroundModel 的五槽里（与 background 节的「DECOR_DOG 不是槽」互指）。

- `NPCController`（← NPCController.as 133 行）：经 IMsgCenter 订阅五消息——
  `MSG_STARTUP_DATA`/`MSG_RELOAD_GAME_RESULT`（StartupData._dog 进模型，
  后者再多一步 `switchNPC`）、`DATA_DOG_CHANGED`（Dog 实体进模型）、
  `MSG_REFRESH_SCENE`（**只认 `type == DECOR_DOG`**，其余装饰刷新与 NPC
  无关，不匹配直接 return）、`MSG_INSTALL_NPC`（数据直通 view.installNPC）。
  finalize 只置空 m_model（与 BackgroundController 同口径）。
- `NPCModel`（← NPCModel.as 140 行）：狗状态。两事件
  `EVENT_DOG_LOADED`/`EVENT_DOG_FOOD_LOADED`；`setDogData` 首只存引用、
  后续在**存量对象**上合并（_dogId ≠ -1 才写、_isHungry 每次覆盖）；无狗
  `dogID` 回 -1；`changeDog` 回写 `Session.sceneDecorates` 的 DECOR_DOG 键。
  狗粮回包 `hours <= 0` 把存量狗标饿：必须 `As3.parseInt`（前缀整数段
  截断，"0.5"→0；`floatOf` 会得 0.5，比较就翻车）。
- `NPCView`（← NPCView.as 341 行）：NPC 层视图。自身实例名 =
  `Consts.SCENE_ZINDEX_FOREGROUND` 挂模块容器；狗件挂
  `SCENE_ZINDEX_MIDDLE` 层——`onDogInitialized` 把 DogRender 插在 dogBowl
  **上一层**（getChildIndex(dogBowl)+1，所以 dogBowl 必须先于狗存在）、
  `updateFood` 按 dogID/dogHungry 摆/收盆。a361 广告时段窗：两界日期经
  `As3.dateOf` **先判 null 再比较**（解析失败原版是 Invalid Date、NaN 比较
  恒 false 不加载，裸读 null.getTime() 直接抛——lessons 有条目），
  `serverTime*1000.0` 的 Int 回绕见类内 PORT-NOTE。361 点击走
  `QQOutlets.call`（no-qq-telemetry deviation）。installNPC 的气泡
  MaoPaoFlag 帧脚本在本地化库处理时被丢弃——气泡文本缺失是既知视觉偏差
  （deviations 候选，动态赋值 talkInfo 照抄保留）。
- `DogRender`（← DogRender.as 90 行，顺手翻 ≤100）：狗矢量件。
  `CommonData.rslManager.requestClass("FDog<id>")` 拉素材、到位换
  `RSLManager.getMaterial` 构造的 MovieClip（x=251、y=200）；300ms 未到位
  先摆 FarmLoading（x=260、y=240）。dogID > `DECOR_DOG_BASE_ID` 先减基址；
  换狗 = 移除旧件整件重 new（view 按 `id` 字符串不等判）。
- **stub 边界（狗狗交互片 agent 注意）**：`DogBowl`（108 行）与
  `DogFoodWindow`（149 行）是 >100 行闭包 stub，只保类形态让
  NPCView 的调用链编译。用户可见后果：**狗粮盆无画面**（updateFood 正常
  创建/挂层/收件，但 set food 空实现，DogFood/DogFoodNull 符号不摆）；
  主人侧狗粮状态回包（onFoodLoaded，仅 `Session.me`）经 `winCtrl.open`
  打开的是**空窗口**（无标题 chrome、无 m_leftime 剩余时间）。替换时整类
  翻译（DogBowl.as 的 food setter 在 57-103 行），别在 stub 上只补符号。

## qui 窗口链（#18 已全真，窗口片 agent 续接时读这节）

`BaseWindow`→`TitleWindow`→`Panel`→`UIComponent`（#18 起全部真翻译，
旧 #8/#9 的闭包 stub 已退役）：`Panel` 底板皮肤 + marginT 头部 + 标题
Label + 可选 ControlBar；`TitleWindow` 加 22px 头部热区与右上关闭钮
（close() 派发 Event.CLOSE + closeFn 短路调）；`BaseWindow` 换
WindowBg/CloseButton 符号皮肤、ADDED_TO_STAGE→initalize→addedToLayer
生命周期、data 带 width/height 置 _recenter 等 onEffectEnd 居中。**窗口
两段式初始化别动**（#18 实现返工）：initalize 里是 `super.init()` 非虚
直落父链（Container→UIComponent 的 setSkin/setSize/setEnabled、
_inited=true），和 Event.ADDED 的虚调 `this.init()`（走最派生覆写，
LevelAndExperience.init 不调 super）是两条不同路径——Haxe 方法全虚，
写成 this.init() 基类初始化整段丢失。
`AddButtonWindow`/`AlertWindow` 等仍是 #7/#8 的形态 stub（不在 farm-basic
spec 清单里，做窗口片时按其头注接真）。`Button` 也是真身（Button.as 逐句，
`selected/toggle` 是 get/set 属性，跨类互斥走 Reflect.setProperty，
见 uitools.md 约定）。`BaseWindow.m_msgCenter` 是原版真成员
（BaseWindow.as:15），不要当 stub 产物删掉。

PopUpManager/PopUpLayer（弹窗宿主层、模态遮罩、Enter 派发 keyEnter）与
ToolTipManager/ToolTipLayer（stage MOUSE_OVER 捕获 + flowMouse/钳位）#18
已全真；EffectManager/DragManager 仍是签名 stub，进出场动画/拖拽随后续
模块接（PopUpLayer 头注的 [param] 数组形态就是它们的 rest 参数约定）。

**spec 外的形态 stub 也要逐字保真**（#8 implement 驳回轮的教训）：构造器
签名、默认参数值、成对出现的成员都要照原文——即使本片没有任何调用方也不
省：Panel 构造器默认值是 `"Panel"` 不是 `"Window"`（后者是 TitleWindow
的）、Button 构造器带 `(String="Button", Function=null)`。一句话半的成员
直接真实现并保持成对对称：AllianceActivityManager 的 register/
retriveAppHelper 都真走 `_appHelpersMap`（register 写表、retrive 恒 null
的半真半 stub 写出「注册了却取不回」）。

## 测试口径

`test/module/mainScene/`：只测纯逻辑（OperationQueue 合批/合并、
BackgroundModel 槽位、NPCModel 狗数据、FarmLandsView 的 m_items 排布计数、
LandItemRender 字段态）；实体侧 `test/entities/PlayerTest.hx`（user 下发
解析/level/clone）与 `test/common/GetCropIDTest.hx`（生长档推导）同口径。`FarmLandsViewTest.test_createLandTiles` 的 name/x/y 断言
**强类型读**（`var item:LandItemRender = view.m_items[0]`）：openfl 自家
的 get/set 属性无物理字段，经 `Dynamic` 反射在 eval/js 恒 null——机制坑
见 [lessons/index.md](../lessons/index.md) 对应条目。
