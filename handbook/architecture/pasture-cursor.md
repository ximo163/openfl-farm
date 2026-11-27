# 牧场光标系统（mc/view/main/cursor，Master2）

牧场（Master2_v_142）的自定义鼠标光标层，issue #87「光标」片翻译（17 类）。
legacy 出处 `decompiled/Master2_v_142/scripts/mc/view/main/cursor/`。注意
**别与 main3 农田侧的光标混**——main3 是 `common/view/cursor/CursorControl`
+ `framework/layers/CursorLayer` + `events.CursorEvent`（SET_CURSOR/
SWITCH_CURSOR 两事件、光标类是反射素材 MovieClip）；牧场是另一套：
`mc.view.main.cursor.*` + `mc.events.CursorEvent`（CURSOR/API/USE_TYPE
三事件、光标类是 src 里的翻译类、有 click/down/up 三态钩子）。两边类名
撞车（CursorLayer/CursorEvent/Cursor 族），import 时认准包。

## 结构

- **Cursor（静态调度面）**：业务代码切光标的唯一入口。useSystem 派
  USE_TYPE（"system"/"customize"）、setCursor 派 CURSOR 并按
  cursorArgument.type=="7"（Dynamic 松等）补派 animalStop/animalMov
  普通事件、setCursorForAPI/setAPICurosr（原文拼写错误别名，逐字照译）
  派 API、delaySetCursor 经 setTimeout 80ms 转 setCursor。静态位
  name/preName/cursorArgument/system/currentCursor 公共。
  **原版 bug 照抄**：`preName == name;` 是比较语句不是赋值（两份反编译
  diff 一致），preName 永远不更新。
- **CursorLayer（显示层）**：挂进显示树后监听 ViewControl 的三路
  CursorEvent + stage 四鼠标事件。CURSOR 事件按 cursorName 查
  CursorClassLib 反射构造光标实例；API 事件按 materialName 直接建
  CursorAPI（素材皮光标）；USE_TYPE 在系统/自定义光标间切换
  （Mouse.show/hide）。鼠标移动逐帧把 currentCursor 挪到 stageX/stageY
  并 updateAfterEvent。`cursorArgument != ""` 的门是 Dynamic 松不等
  （空串唯一跳过形态——delaySetCursor 的第二参是 String）。
- **CursorClassLib（注册表）**：cursorName → Class 静态映射，内置 11 键
  （原文对象字面量 "CursorArrow" 写两遍——重复键去重，两值相同无差异）；
  register 可覆盖/扩展。
- **BaseCursor/IBaseCursor**：光标基类（Sprite），click/down/up 空钩子
  + cursorArgument 存取 + setCursorFilter（GlowFilter(13434624,1,10,10)
  + 1.1 亮度矩阵，视觉参数逐字）/cancelCursorFilter。
- **9 个工具光标（Cursor_*)**：构造器各取固定素材名挂树（名字逐字：
  CursorArrow→"CursorArrow"、Cursor_ShengChan→"CursorPesticide"（名字
  错位但原文如此）、Cursor_ShouHuo→"CursorHand"、Cursor_Theft→"CursorHoe"、
  Cursor_Fly→"CursorFly"、Cursor_Flapper→"CursorFlapper"、
  Cursor_ClearBB→"CursorClearBB"、Cursor_ShouHuoAll→"CursorShouHuoAll"、
  Cursor_Donate→"CursorDonate"、Cursor_Tanabata 特殊——getClass
  ("cusor_tanabata")（少个 r 的原文拼写）反射构造）。down/up/click 播
  gotoAndPlay(2) 或 gotoAndStop(3)/(1) 各按原文。
- **CursorTool（工具光标）**：唯一的参数化光标——type!=9 按
  "CursorTool_"+type+"_"+tId 取素材；type==9（动物）new MovieClip 装
  "Animal_"+id+"_1" 素材的**第一子件**（getChildAt(0) 摘出），id 取 cId
  优先、tId 兜底，`Number()` 强转走 As3.floatOf。素材名推导是测试钉死
  的行为面（CursorToolTest 假域注入）。

## 约定与坑

- 光标素材经 `common.MaterialLib`（mcloader 那份，#19 已译）按名取——
  牧场素材库尚未入库时 getMaterial 得 null、下行 cacheAsBitmap 即抛，
  与原版素材缺失行为一致；测试用 support/MaterialFakes 假域注入。
- `as MovieClip`/`as BaseCursor` 的失配落 null 语义无消费方（下行必抛），
  按仓内先例直 cast。
- 鼠标三态（down/up/click）由 stage 转发——光标实例本身 mouseEnabled/
  mouseChildren 均为 false（onAddedToStage 里关），不吃事件。
- eval 上 `"Animal_" + Float(1001.0)` 拼串不带小数点（与 AS3 Number
  toString 一致，probe 实证）——素材名推导不需要额外格式化。
