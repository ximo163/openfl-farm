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
- `FarmLandsView`（← FarmLandsView.as 960 行）：24 格地块排布与状态渲染。
  **地块实例名是交互路由键**：`__FarmlandItem__<行>.<列>`（额外第 4 行是
  `.3` 后缀）、荒地 `__reclaim__`、飞机 `__plane__`、遮罩 `__mask__`——
  `onMouseEvent`/`onLandClicked` 全靠 `name` 分流，**实例名一个字符都不能改**。
  `SCALE=0.75`，`ITEM_WIDTH/HEIGHT = 204/102 * SCALE`，静态量先 `SCALE`
  再派生（Haxe 静态初始化按声明序）。悬停高亮走 ColorMatrixFilter（数组
  逐字照抄，`m_overFilters`）。
- `OperationQueue`（← OperationQueue.as 293 行）：撒种/除草/虫/药四槽合批
  （`ADD_WEED 0 / CLEAR_WEED 1 / ADD_BUG 2 / CLEAR_BUG 3`）。请求侧 place
  串接（`"1,2,5"`），回包按 `cmdID` 分槽、按 `farmlandIndex`+方向合并
  （ADD 类取大、CLEAR 类取小，money/exp 累加、levelUp 只升不降），
  展示侧 400ms Timer 逐条派发 `EVENT_OPERATE_SUCCES`。常量原版是
  `internal`，Haxe 转成 public（同包 FarmLandModel 也要用）。
- widgets/：`LandItemRender`（单地块渲染编排：setGrowStep→createCrop/
  createByproduct→updateLandStatus）、`LandTile`（地块底图，来自
  farmui_full_v_40 库）、`Crop`（作物 swf 影片，`Crop_<cId>_<step>.swf`
  库）、`Byproduct`（草/虫摆件，`getInsectPosition` 决定坐标）、
  `LandPickIcon`（可摘手势图标）、`LandTalkTip`（NPC 对话气泡）、
  `Wasteland`（荒地块）。

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
  `loader.unloadAndStop` 的 `hasOwnProperty` 鸭子判在 openfl 上恒 false——
  远程 swf 已本地化，该释放路径不可达，PORT-NOTE 在位。
- `BackgroundController`（← BackgroundController.as 172 行）：StartupData
  装饰下发进模型；`MSG_ENTER_PREVIEW`→`changeDecor` 快照 + PreviewDiyWindow；
  `finalize` **只清 m_model 不调 super**（基类那份会连 m_view/m_module 一起
  清，语义不同，照原文覆写）。
- `PreviewDiyWindow`（← PreviewDiyWindow.as 42 行，闭包顺手翻）：取消预览
  窗。super 链的标题栏/关闭行为落在 qui 窗口片 stub 上（见下）。

## qui 窗口 stub 链（窗口片 agent 注意）

`BaseWindow`→`TitleWindow`（stub）→`Panel`（stub）→`Sprite`，
`com.qzone.qui.controls.Button`（stub，原版继承 Label）。这些是 >100 行的
闭包 stub：**只保类形态让链编译**，`title` 只存值不渲染、`close/onClose/
addButton` 是 no-op。做窗口片（V3c）时把它们替换成真翻译，stub 头注释写明
了原版行为（TitleWindow.as 89-102 / AddButtonWindow.as 56-62 / Panel.as
101-121）。`BaseWindow.m_msgCenter` 是原版真成员（BaseWindow.as:15），
不要当 stub 产物删掉。

## 测试口径

`test/module/mainScene/`：只测纯逻辑（OperationQueue 合批/合并、
BackgroundModel 槽位、FarmLandsView 的 m_items 排布计数、LandItemRender
字段态）。`FarmLandsViewTest.test_createLandTiles` 读 openfl 自家
`name/x/y`（get/set 无物理字段）经 Dynamic 得 null——机制问题不是值错，
见 [lessons/index.md](../lessons/index.md) 对应条目。
