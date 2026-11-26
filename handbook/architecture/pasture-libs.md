# 牧场私有底座库（Master2 的 LipiUI / 第三方库 / Flex 资产类 / 工具函数 / 事件）

牧场（Master2_v_142）的私有基础设施，#86 翻译。这些类不属于牧场业务
（场景/窗口/数据在后续切片），但被牧场业务类广泛依赖：LipiUI 组件库是
牧场全部窗口的控件底座，Flex 资产类是嵌入资产的类型壳，工具函数/事件
散布全程序。legacy 出处 `decompiled/Master2_v_142/scripts/` 下同包路径
（`spec/modules/pasture.json` 各子系统条目）。

## LipiUI 组件库（`src/com/minutes/`）

22+2 类：ui.core（LipiUIComponent/LipiSkin/LipiContainer/LipiPanel/
Reservoir/UIEvent）、ui.control（JerryNavigation/JerryTabContainer/
JerryTabNavigation/LipiButton/LipiScrollBar/LipiTextArea/NumbericStepper/
ToggleButton + 皮肤类 LipiDefaultSkin/LipiScrollBarSkin/NUmbericStepperSkin）、
ui.collections（SimpleCollection/LipiTile2/LipiBox/LipiCanvas/LipiListChild/
ILipiTileChild）、ui.constant（ScrollBarDirection/ScrollPolicy）、
net（HTTPRequest/FileLoader）。#19 曾立签名面 stub（只保当时消费通道），
#86 全部充真身。

架构要点（读反编译原文核实）：

- **帧驱动脏标记渲染**：LipiUIComponent 在 ADDED_TO_FRAME 后对 stage 挂
  ENTER_FRAME，属性写只置 `_xxxChange=true` + `invalidateDisplayList()`，
  下帧 `onRender` 一次性跑 `updateDisplayList`。布局/皮肤变更**不当帧
  生效**——翻业务类时别用「写完 width 立刻读布局」的假设推时序。
- **LipiContainer 的 addChild/removeChild 重定向**：子件实际进
  `_contentPane`（含滚动裁剪），`contains` **不重定向**（查的还是面板
  自身显示列表）——LipiPanel.set_titleIMG 里 `contains`+`removeChild`
  混用即因此看似矛盾，原版如此，照抄。
- **_setBarSkin 的 barIcon 门缺陷**：LipiContainer.as:117 水平条的
  trackSkin 赋值被 `if(barIcon != null)` 门住（应为 trackSkin 门）——
  原版 bug，逐字保留（见 lessons 同款「原版缺陷照抄」纪律）。
- **LipiScrollBar 五标志恒脏**：updateDisplayList 尾部把五个 change 标志
  全置 true（每次重绘后仍标脏，下帧再跑全部分支）；scrollPosition 的
  `this.scrollPosition = this.scrollPosition` 自赋值靠 setter 派发副作用
  拖滚动内容。都是原版写法，不是翻译错误。
- **NumbericStepper 的混合类型通道**：`get_num` 属性类型在 AS3 是 `*`
  （setter 收 Number 比较、写文本却是 String；NumbericStepper.as:139 的
  `numText.height = bg.width` 高取宽也是原文）。Haxe 属性单一类型
  Dynamic，比较走类内 compareNumber（AS3 Number() 转换语义：""→0、
  非数值→NaN——eval 的 Dynamic `<` 比较不做数值转换，直接翻会掉空串
  clamp 分支，#86 单测实证）。
- **多类同文件**：AS3 的文件尾无修饰类（LipiContainer.as 的
  ScrollBarSkin、LipiScrollBar.as 的 ThumbBar）按仓内先例放同文件模块
  子类型，**不加 private**（private 锁死模块内可见，LoadManager.hx 的
  LoadItem 先例）。
- **皮肤类是纯 Class 表**：LipiDefaultSkin/LipiScrollBarSkin/
  NUmbericStepperSkin/LipiSkin 的成员是 `static var XxxSkin:Class`——
  运行期由 RSL/素材库注入或留 null（部署包资产缺口时 null 后 NPE 与
  原版一致，deviations 候选口径同 assets.md 的缺符号节）。
- **LipiPanel.init 的 AS3-private 静态绑定语义（#86 实踩，牧场窗口
  框架片必读）**：AS3 private 不进继承虚表，故 mc.view.common.BaseWindow
  族能另立同名零参 public init()（WindowLayer 首开钩子）而不构成覆写。
  Haxe 的 private **不豁免 override 检查、私有方法也虚拟派发**（eval
  实证：父类构造器 this.init() 会落进子类覆写——PostWindow.init 会在
  width/windowName 赋值前的构造期误跑、首开再跑一遍，双重建子件）。
  #86 的等价方案：init 本体搬进私有助手 `initPanel`（无原版成员同名、
  永不覆写 = 静态绑定语义），构造器改调 initPanel；实例 init 委托
  initPanel，mc 窗口族覆写签名统一带 `param1:Rectangle = null`（调用方
  全零参，形参不可见）。cpp typer 扫描的 `Field init overrides parent
  class with different or incomplete type` 即此碰撞的现形。**未来翻译
  牧场窗口框架片（BaseWindow/WindowLayer 真身）时别拆这个通道**——
  细节在 LipiPanel.init 行 PORT-NOTE。
- **mc.FBridge → mc.fBridge**：原包段 FBridge 首字母大写，Haxe 包段
  必须小写开头，落 fBridge（windowControl 同款先例，deviations 候选）。

## 第三方库

- **com.adobe.crypto.SHA1**（`src/com/adobe/crypto/SHA1.hx`）：MVO 校验
  签名链用。两个平台坑都已处理：ByteArray  endian 显式钉
  BIG_ENDIAN（AS3 默认大端，openfl 非 flash 目标随系统——x86/eval 是
  小端，不钉哈希全错）；int 字面量 2400959708/3395469782/4023233417 等
  超 positive-int 域的写成负值等价（Int32 环绕，仓内 MD5.hx 同款先例）。
  稀疏数组空洞读法（undefined→0）走 readWord/normalize  helpers。
- **com.adobe.images.JPGEncoder/BitString**：JPEG 编码器（快照上传链路
  用），逐字翻译。BitString 是定长位串 VO。
- **com.adobe.utils.IntUtil/StringUtil**：main3 同名文件**逐字节相同**
  （diff 验证），#86 直接复用既有翻译，无 Master2 变体差异。
- **com.cbmland.ui.RightMenu**：右键菜单。openfl 完全没有
  flash.ui.ContextMenu/ContextMenuItem/NativeMenu（InteractiveObject
  .contextMenu 属性行都是注释）——#86 新立 `src/shim/ContextMenu.hx` +
  `ContextMenuItem.hx` 等价物（仓内首例；永不显示，与 main3 RightMenu
  的 stub 决策同源），菜单构造逻辑保真，`param1.contextMenu` 读写走
  ClipProps 侧表（Dynamic 裸写禁令）。若人对右键菜单载体另有裁决
  （interaction-map 切片统一处理），换载体只需改 shim 内部。
- **cn.snowkit.containers.Pane / utils.ObjectCopy**：snowkit 滚动窗格
  （与 LipiUI 并立的另一套）与 AMF 深拷贝 helpers。ObjectCopy 与
  common.Utils.objectCopy 同走 com.qzone.utils.ObjectUtil.clone 等价物
  （AMF 退化语义见该处注释）。
- **com.lipi.LipiUtil**：LipiUI 配套工具（clone/rgb 插值等）。

## Flex 资产类（`src/mx/`）

mx.core 12 类（BitmapAsset/ByteArrayAsset/EdgeMetrics/FlexBitmap/
FlexMovieClip/FontAsset/IBorder/IFlexAsset/IFlexDisplayObject/
IRepeaterClient/MovieClipAsset/mx_internal）+ mx.utils.Base64Encoder/
NameUtil。Flex SDK 3.2 的嵌入资产壳：

- **IFlexDisplayObject 落不了 implements**：它的成员签名（
  blendMode:String、filters:Array、opaqueBackground:Object…）与 openfl
  DisplayObject 的属性类型结构性不合（BlendMode 枚举抽象、
  Array<BitmapFilter>、Null<Int>），接口满足检查直接红。Master2 全脚本
  零以 IFlexDisplayObject 静态类型取用，省略 implements 无行为差——
  各资产类的类头 PORT-NOTE 有记录。
- **mx_internal namespace 平铺成 public**：原版 `mx_internal static
  const VERSION` 是包内可见，Haxe 无 namespace 概念，全仓先例平铺。
- **Base64Encoder 的怪癖照抄**：encodeBytes 的窗口索引是**绝对坐标**
  （`while(_loc5_ < param3)`，param3≤param2 时整段空输出——与 encode()
  的 offset+length 语义不一致，原版缺陷）；76 字符折行、32767 缓冲
  滚动、drain 清缓冲不清计数，逐字保留。字节读取经 ByteArray 下标
  （openfl eval 实测支持）。

## 工具函数（`src/com/qzone/utils/` + comm.S9bmp + common.Utils）

- **Master2/main3 变体差异**（diff 实证，合并口径写进各类头）：
  DateTimeUtils.getDate 的零填充条件 Master2 是 `> 0`（日期**不**零填
  ——main3 是 `> 9`，两者都非全填充，原版变种不一致照抄 Master2）；
  StringUtil.getFloatNumber Master2 用 `toFixed(param2)`（main3 写死 2
  位忽略参数）；Master2 独有 tirmCallBack（剥 `_callback(` 前缀）/
  getFixedLengthString（左补零）。农场侧既有消费不破坏：formatSecondCount/
  isSameDay 等 main3 成员保留。
- **逐字节相同无变体**：AlignUtil/DisplayUtil/GraphicsUtil 直接复用。
- **CookieUtil 的 ExternalInterface 走 shim.QQOutlets**（no-qzone-jsapi
  决策族：独立部署无宿主 JS，一律不发、取值回 null——getCookie 恒
  null，与原版在非 QZone 页面的兜底一致）。注入 JS 函数字符串常量
  逐字保留（无消费也不改写）。
- **common.Utils.setTimeout**：原版闭包用 `arguments.callee` 自摘监听
  （Haxe 无 arguments——闭包先赋局部变量再自引用，语义等价，类头
  PORT-NOTE）。objectCopy 走 ObjectUtil.clone（同上 AMF 等价物）。
- **comm.S9bmp**：九宫格位图（scale9Grid 切片缩放），LipiSkin 的
  皮肤绘制依赖它。

## 事件（`src/mc/events/`）

6 类：CommonEvent/CursorEvent/FloatingEvent/GameEvent/TipEvent/
WindowEvent（后两类 #19 已译，Master2 变体核对一致）。**GameEvent 的
int/Number 错位**：`_addMoney` 字段声明 int、setter/getter 却是 Number
 ——Haxe 属性面按 Number(Float)，setter 里 As3.intOf 复刻 int 存储的
ToInt32 截断（类头 PORT-NOTE）。

## 编译 stub（范围外依赖，后续模块充真身）

- `src/mc/FBridge/DataURLLoader.hx`：HTTPRequest 的依赖，属「网络」
  子系统（spec pasture.json 网络 4 类），本切片只立成员面 stub。
- `src/mc/view/main/floating/FloatingBase.hx`：FloatingEvent 的类型
  形参需要；原文仅 30 行（fid 存取 + 空 start()），stub 成员面抄全
  即与真身等价。「飘字」子系统归后续切片。

## 音效（时间轴 StartSound 缺位不阻塞牧场）

#86 R12 探针结论（三链缺位 + 牧场零依赖 + DefineSound 管线缺口）写在
[assets.md](assets.md) 的音效节——#89/#91 音效播放落地前必读。
