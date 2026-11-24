# 升级弹窗（module/levelup/）

农场升级时弹的分享窗（黄钻开通/黄红黑土地扩建提示 + 新种子陈列）。
#18（farm-basic 收尾）整片翻译。

## 关键类与 legacy 出处

`decompiled main3 module/levelup/`：

- `LevelUpModel`（EventDispatcher）：三张土地等级表（NORMAL/RED/
  BLACK_LAND_UPDATE_INFO，Panel.as 同源数值表）、`loadSeedsInfo`
  （NetHelper CMD_GET_SHOP_SEED，exclude_seeds/isVIP/isMill 过滤）、
  `getPanelURL/getYellowURL/getLevelUpPicURL`、`isYellow`（Session.isMeVIP）。
- `LevelUpWindow`：shareType 五选面板素材（bigPanel/seedsPanel/landPanel/
  nextLandPanel/emptyPanel），分享文案三档（≤27 / ≤69 / 70+，62/64/66/68
  黑土特判），土地/种子行排版走 `AlignUtils`；fusion2 分享 ExternalInterface
  → `QQOutlets`（deviations no-qzone-jsapi）。
- `LandRender`/`SeedItemRender`：面板行素材渲染（Update.landRender /
  Update.seedsRender）。
- `AlignUtils`：无状态布局数学（`int(...)` 截断 → Std.int）。
- `LevelUpModule`：升级触发壳（#7 模块壳 → #43 真身）。ctor 建 LevelUpModel
  并听 `MSG_USER_LEVEL_UP`（Consts.as:418 "userLevelUp"；派发点在
  Session.as:381 账户更新的跨级分支，Session 侧随会话片接入）；
  `__onLevelUp` 从 nowLevel 逐级 `new LevelUpWindow` 补弹到 preLevel+1——
  一次涨多级每级各一扇。

## 面板素材（levelUpUI_v_1.swf）

`Settings.getSecondUrl("levelUpUI")` → `module/mc/levelup/levelUpUI_v_1.swf`
（assets/legacy-assets.txt 与 libraries.xml 同 commit 增删；RSLLoader 兜底
路径 = LevelUpWindow.initUI 反射不到 Update.bigPanel 时才拉）。符号名是
`Update.小写段` 点路径——Haxe 点路径把大写开头段当模块名，声明不了原路径
（deviations monthend-package-lowercase 同因），root 包建 `UpdateBigPanel`
等类、`@:native("Update.bigPanel")` 把运行时注册键改回原符号名，
`Utils.getMaterial` 的反射字符串一字不动；全部进 `shim/SymbolClass.hx`
的 dceAnchor。

**部署包缺符号**（deviations 候选，待人登记）：全 swf 扫描只有
bigPanel/seedsPanel/emptyPanel/seedsRender/denShed 两枚导出，
`Update.landPanel/nextLandPanel/landRender` 无任何 swf 导出——
main3_v_221 代码比部署包素材库新（#9 ButtonSuperMarket 同族）。空壳
MovieClip shim（UpdateLandPanel.hx 头注）保 createPanel 占位可构造；
原版跑本部署包在这几处同样 null 后抛 #1009。

## 约定（动这块前必读）

- 面板符号的具名子件（levelTxt/isYellowBtn/landHoldr…）经
  `As3.childOf` 取、按名写经 `Reflect.setProperty`（js 裸 Dynamic 写
  只落影子字段——uitools.md 约定同条）。
- `_landInfo` 是匿名记录：`this._landInfo.normal` 这类读写走
  Reflect.field/setField，别强类型化。
- 种子 for-each（`for each(_loc3_:Seed in _loc2_)`）：`cast(_loc2_,
  Array<Seed>)` 后 Haxe for-in 值遍历，同 AS3 for-each 语义。
