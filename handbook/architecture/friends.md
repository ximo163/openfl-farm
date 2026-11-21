# 好友列表栏（module.friend）

屏幕右侧好友面板：页码/排序/搜索/刷新 + 每行头像、等级底图、状态角标；
点击行 → SwitchingUser 进好友农场，偷菜/浇水（scrounge）由此进入。
#20 整片翻译，`decompiled main3_v_221/scripts/module/friend/`。

## 类与职责

- `ModuleFriends`：模块壳（Module 形态，#7 约定）。字段名 `m_firendsCtrl`
  的拼写错误照抄原版。load 建控制器并 initialze，unload finalize。
- `FriendsController`：事件装配层。应用消息（召回应答/鱼塘/野兽/精灵/地块
  状态）→ 模型更新 + 对应行角标刷新；视图事件（翻页/搜索/排序/开合）→
  模型动作。**限流**：`limitedTimes=3`、`getFriendListDelay=3000`ms 窗口内
  最多 3 次、超了重置计时（onRefreshStatus/onReloadFriends 同款）。
- `FriendsModel`（单例，EventDispatcher）：数据源。EVENT_ALERT_WINDOW 等
  六个事件常量原版 internal → private，**跨类读（控制器 registerListeners、
  视图构造器）靠 `@:access(module.friend.FriendsModel)`**。六个 mod
  （friend/addFilter/delFilter/getstatus_filter 等）走 CommandDefs 常量
  中央映射，不自己拼 URL。`friendListFilter` getter 供视图置灰判定。
- `FriendsView`：面板（Sprite）。VIEW_EVENT_* 同为 internal→private + @:access。
  行渲染池 `_itemCache` 构造器先备 10 只；`buildPage` 先 `del()` 清容器再按页
  add。开合动画是 ENTER_FRAME 每帧走剩余距离的 0.4（effHandler，floor 到 0
  即完成并派发 Collapse）。微博态（`QzoneJSAPI.WB`）换 List_Close/Open_WB
  皮肤、搜索提示文案换「按微博昵称查找」。onCollapseView 首次展开先过
  `FeartureManager.friendListMod()` 公告位提示（回 false/空串不弹）。
- `FriendItemRender`：行。`updateStatusFlag`（:236-413）是全模块最密的一段：
  按好友数据键 "1"…"8"/preYellowlevel 挑状态角标类（Utils.getClass 反射），
  键读全是 AS3 松散比较——**每种形态的译法**见类头注释与 `As3.hx`
  （`=== 1||=== true` 的 isOf 形、`== 1||== true` 的 floatOf==1、cookie 与
  Number 的 null→0 三元等）。头像加载走 `QQOutlets.loadImage`（宿主头像
  出口，deviations qqoutlets-shim；取不到 → IOError 吞掉 → 空头像框，
  与原版跑本部署包同视觉）。
- `framework.net.parsers.FriendsDataParser`：17 loc 小解析器。
- `entities.Friend`：本片补齐 me/sort/status/_headPic 等字段与
  importObject/exportObject/importFromCache。

## 状态角标与动态属性

FriendItemRender 把挑好的角标类名挂进 `status_mc["s_name"]`
（ClipProps 侧表，读写同通道）；FriendsView 的点击/悬停分发按
`ClipProps.get(param1.target, "s_name")` 读回（Status_z 召回、Status_u 野兽、
Status_6 鱼塘、Status_7 精灵、else 进农场）。**别把这类读译成
Reflect.field 或 As3.childOf**——写入走侧表，读 Reflection 永远 miss。

## 符号与素材（全在已声明库，无新资产）

MovieClip/精灵符号（`Utils.getMaterial` 反射构造）：List_Item、List_UI、
Status_1/2/3/pre/u/z（farmui_full_v_40），List_Close_WB/List_Open_WB/Status_6
（farmui2_v_58，非 preload，bind 走按需 loadLibrary 窗口）。

**BitmapData 链接符号**（`Utils.getCachedBitmapData` 反射 new）：Sort0-3/
SortMe 等级底图 (24,24)、VipL1-7 黄钻徽标 (16,13)——farmui_full_v_40 的
SymbolClass 绑 flash.display.BitmapData 子类。垫片形态：根包类
`extends BitmapData`，`super(w,h,true,0)`（0 全透明——Flash 对链接位图 new
无视传入宽高、实例即图像自身像素，AS3 BitmapData 默认的 0xFFFFFFFF 白
不能露）+ `SymbolClass.bindBitmap` 从 `Assets.getBitmapData("库:名")`
copyPixels（解析链 AnimateLibrary bitmapClassNames，见 SymbolClass.hx
bindBitmap 头注）。全部进 dceAnchor（#20 段）。

**Status_7 部署包无符号**（小仙供奉角标由精灵插件 swf 运行期供类）——
无垫片，`Utils.getClass("Status_7")` 恒 null 即原版无插件行为，别补类。

## 已知偏差/待裁决

- BeastAPI.showFarmStage/showWildStage 是空 stub（#pasture 牧场片接线）；
  ButtonMaker.addTarget/setSelected/setEnabled 是既有 stub。
- 好友头像、vip_mc 的 `ExternalInterface.call("window.open", …)`、召回
  `QzoneJSAPI.sendGameRequest` 全走 shim.QQOutlets（deviations
  qqoutlets-shim/no-qzone-jsapi 族，PR 列候选）。
- approved 测试 `FriendsModelTest.hx` 三处期望值与原版行为相反（:379 翻页
  回绕、:845 me 追加数、:1149 缓存命中行），**不能改只能 NEEDS-TESTS**；
  纠正版 `FriendsModelFollowupTest.hx` 已 21/21 绿（/tmp 侧 harness 验证），
  注册行留给 write-tests（lessons TestMain append-only 条）。
