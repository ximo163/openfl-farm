# 工具区（uitools）与通用视图

工具条/导航/档案区模块，加上支撑它的 qui 控件子集和飘字/光标/提示通用视图。
#9（farm-basic 的 uitools 片）翻译时核实。窗口 stub 链的约定在
[farmscene.md](farmscene.md) 的「qui 窗口 stub 链」节；会话/数据层见
[data.md](data.md)；NetHelper 请求见 [net.md](net.md)。

## module/uitools（`src/module/uitools/`）

legacy 出处：`decompiled main3 module/uitools/`。

- `ModuleUITools`（← ModuleUITools.as 51 行）：模块壳。load 建 UIController
  并 initialze，unload finalize，网络停摆（EVENT_NET_CLIENT_ERROR）时
  resetLoadingFlags 复位 model 的加载位。
- `UIController`（← UIController.as 652 行）：全模块装配与路由。app 级
  监听 17 条（MSG_STARTUP_DATA/RELOAD/HOST_CHANGED/CURRENT_USER_CHANGED/
  HEALTH_MODE/ACCEPT_NEW_GIFT/TRUNK_SYSTEM_TOOLBAR/CHECK_LEVELUP/LEVELUP/
  DELEVE_NEW_ICON/POOL_OPEN/REFRESH_POOLINFO/ADD_COLLECTING_ICON 等），model
  级 2 条（EVERYDAY_GIFT_ACCEPTED/LEVELUP_GIFTS）。产出：m_toolbar、
  m_navbar、m_personInfo、m_leftSideToolBar、shortcutBar、m_poolInfo 角标
  （FISH_MAX_SIZE 分母）、飞机入口、狗粮到期提示（onGetDogValidTime 走
  CommonData.addCallBackProxy）。
- `UIToolsModel`（← UIToolsModel.as 562 行）：数据层。updateHostInfo 是
  baseinfo（用户名/头像）→account（金币/经验/fb/道德）两段 diff 派发；
  updateOfflineStatus 是 b/c/d/e 四键 diff（**比较侧裸比、赋值侧 as int 收敛
  ——缺键算变化**，详见 lessons #9 条目）；升级礼物 addLevelUp 合并去重；
  loadEveryDayGift/drawLevelUpGift/acceptGifts 走 NetHelper（theApp null
  直接 return，单测口径同 FarmLandModelTest）。
- vo/：`OfflineData`、`ProfileData` —— 纯字段 VO，默认值照抄。
- widgets/：
  - `ToolBar`（← ToolBar.as）：13 项 TOOLS 符号名表（下标即 TOOLS_TIP
    提示文案表），点击/快捷键（KEY_UP，R=收获/T=一键摘取）调 setCursor。
    setCursor 是光标状态机的**第二入口**（CursorControl 是第一入口）；
    TOOL_UPRED 红地升级按钮、Tool_Wild（activities 片）走闭包 stub。
    `MODULE_EVENT_CLICK_PACK/CLICK_TOOLBOX` 是自有派发名。**工具按钮的
    素材 tag 是 DefineButton2（按钮符号）**，同名类是 SimpleButton 垫片
    （`SymbolClass.bindButton`；规则与撞坑见 [assets.md](assets.md)）：
    TOOLS 表的 ToolHand/ToolHoe 等 + 工具箱/水池角标的 ToolHook/
    ToolPesticide/ToolWater/CameraButton/ToolZoomIn/ToolZoomOut/PoolInfoBtn
    （water_ui_v_0 的 ToolFishNet/All 同理）。
  - `NavigationBar`（← NavigationBar.as）：ButtonMaker 建按钮组，按
    Settings/Session 判点亮（未点亮提示窗 ALERT_TYPE_TEXT），跳转目标
    分流 QzoneJSAPI/navigateToURL shim。**BUTTONS 表的
    ButtonSuperMarket/ButtonMill1 与平移箭头 NavigationLeftArrow/
    NavigationRightArrow 在全部部署 swf 均不导出**——main3 的代码比
    部署包里的 farmui_full 新一个版本位；空 MovieClip 保启动（原版跑
    这份部署包同样 null 后 NPE），箭头/超市按钮不渲染是 deviations
    候选。
  - `LeftSideToolBar`（← LeftSideToolBar.as）：左侧活动图标列（VBox），
    邮件图标 openPostWindow（PostWindow 闭包 stub + Reflect.hasField 门）。
  - `PersonInfo`（← PersonInfo.as）：头像/名字/金币/经验面板，数字滚动
    NumAnimation，点击档案区开 LevelAndExperience 窗（profile/ 5 类）。
    **头像加载出口并 `QQOutlets.loadImage`（不发送）**：headPic 是宿主
    环境数据（mync user_run 下发，user_run.php:276 用快照 UC_API 前缀拼
    出、指向参考部署的局域网地址 legacy/snapshot/home-config.php:45），
    照发在任何部署外环境挂死并记一条资源错——#9 前两轮 web-smoke 同点
    红的根因（见 lessons）。空头像框与原版跑本部署包一致（IOError 被
    onPhotoLoadError 吞掉），deviations 候选。
  - `ShortcutBar`（← ShortcutBar.as 846 行）：600×62 顶条，含 __gift__/
    __flower__/__levelup__/__monthEnd__/__security__/__alarmClock__/__KFC__/
    _teBu_ 九分支 onClicked。月末弹窗（MonthEndWin 闭包 stub）Cookies 记
    忆位 monthend_\<uId\>；teBu 位走 PluginManager.amountPlugins(
    PLUGIN_AMOUNT_SHORTCUT=5) + mod=cgi_farm_get_bit?bit=7 的 16001 查询；
    `content.getChildByName("__post__")` 等实例名是路由键（同 farmscene 的
    地块实例名规则，一字不能改）。
  - `ToolBase`/`ToolBoxBar`/`FreeGiftIcon`：按钮基类（置灰走
    Style.getDisableFilter）、工具箱条、免费礼物图标。
- **QQ 域外联全走 shim**：QZFL.dialog.create/黄钻包/电脑管家/签到跳转都落
  `shim/QQOutlets.hx`（available=false 早退——无宿主环境下的等价分支），
  `navigateToURL` 落 `shim/NavigateToURL.hx`；宿主头像 Loader.load 落
  `QQOutlets.loadImage`（见 PersonInfo 条目）。

## qui 子集（`src/com/qzone/qui/`）

legacy 出处：`decompiled main3 com/qzone/qui/`。#9 全量翻译：
`UIComponent`、`Label`、`Text`、containers 的 `HBox/VBox/Canvas/Container/
boxClasses.Box`、scrollClasses 全套（`ScrollBase/ScrollBar/ScrollThumb/
ScrollBarMode/ScrollPolicy`）、`HScrollBar/VScrollBar`、core 的
`Align/Direction`、`styles.Style`、`makers.ButtonMaker`、
`events.ScrollEvent`、utils 的 `EventUtil/FrameTimer`、skins 的
H/V 滚动条皮肤（ListSkin 例外，见类头）。**仍 stub**：`Panel`、`Button`
（签名 stub，已重定基到真 UIComponent/Label，皮肤装配随后续模块）、
`TitleWindow`（#8 闭包 stub，见 farmscene.md）。

约定（改这些类前必读）：

- **属性声明只在基类一次**：`ScrollBase.content` 在基类就是 `(get,set)`
  （基类 set 为 no-op 垫底），Container 只覆写 `get_content/set_content`
  accessor——Haxe 不允许子类扩 accessor（(get,never)→(get,set) 编译红），
  也不允许子类重声明属性。全仓照这个形态写。
- **Haxe private 子类可见**：原版子类直写父类私有字段（ShortcutBar 写
  Box.direction、ScrollBase._vScrollPolicy）照抄即可，别「补 public」。
- Box 的方向/间距字段（direction/gapH/gapV/alignH）是原版 private，
  容器排布语义别挪到子类。
- `ScrollEvent` ctor 形参序是 (type, **detail**, position, direction,
  delta, bubbles, cancelable)——param2 是 detail，照原文。
- `Math.NaN` 不是合法默认参：NaN 默认参一律 `Null<Float> = null` +
  ctor 归一（ScrollEvent 先例）。

## 通用视图（`src/common/view/`）

- floating/（← common/view/floating/）：`FloatControl` 注册表 + 11 个飘字
  类。收获/加钱/加经验/操作/健康/文字提示逐句翻译；基类 `FloatingBase`
  走 fid 计数 + msgCenter（IMsgCenter）派发。动画全帧驱动
  （ENTER_FRAME/Timer），数字逐字照抄。宿主层 `FloatingLayer`
  （framework/layers，#7 闭包 stub → #9 按其头注接入真身：FLOATING_OPEN/
  CLOSE 监听 + `FloatControl.getClass` 反射实例化 start/addChild）；
  收获链 FarmLandsView.onHarvestData → openFloat(FLOAT_TYPE_HA) →
  HarvestAnimation，苗图库 Crop_2_Seed（nc_data.php:6021 asset_id.s，
  assets 清单 V3c 组）。
- cursor/（← common/view/cursor/）：`CursorControl` 类注册表
  （m_cusrsorLib——**原版拼写如此，别修**）+ setCursor/useSystem 经
  msgCenter 派发 CursorEvent；`CursorTool`/`CursorCropSeed` 携带工具态。
  光标视觉类是 farmui_full_v_40 的 SymbolClass 符号（符号 shim 规则见
  [assets.md](assets.md)）。
- `MaterialProxy`：素材代理，executeCommand(2102) 经
  PluginManager.getPluginByID → IPluginProxy 接口（#9 新翻，src/com/qzone/
  farm/api/interfaces/，IFarmAPI 仍属插件接口片未翻，PluginManager.api
  恒 null 走 Dynamic）。
- ROLL_OVER/MOUSE_OVER 监听**照译**；悬停→长按合成属 shim 输入适配层，
  等 spec/interaction-map.json 落地（#9 挂起，见 lessons）。

## 测试口径

`test/module/uitools/`：UIToolsModelTest（diff 派发/礼物合批/加载位，
Session 单例每用例自钉 host）、UIToolsModel 派生的 widgets 测试
（ToolBarTest 用 Type.createEmptyInstance 驱动纯状态机——忠实 ctor 在
eval 无素材会抛 #2007）。光标状态机在 ToolBarTest 的 onKeyUp 映射断言。
显示装配（皮肤/排布）不进单测，CI web-smoke 兜底。**种收全链的本地
证据**：`node tools/nodeboot/nodeboot.mjs --drive tools/nodeboot/
drive-chain9.mjs`（收→锄→种→浇：真实 mync 请求体/应答落地/飘字挂树
断言，应答 fixture 按 legacy PHP echo 模板；点击派发语义的坑见
lessons——别改回直点 LandItemRender）。
