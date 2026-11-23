# 补间引擎（com.greensock：TweenLite + core 三类）

GreenSock TweenLite v11.101 全量：插值补间 + ENTER_FRAME 帧驱动推进。
#7 先立「终态直写」stub（立即写 vars 目标值，真机看「没有动画」），
#28 翻 core 三类（TweenCore/SimpleTimeline/PropTween）与构造链静态，
#39 换掉 stub 补完本体（renderTime 插值渲染、init 的 PropTween 链构造、
updateAll 帧推进、kill/invalidate 链）。legacy 出处
`decompiled/main3_v_221/scripts/com/greensock/`（506+337+94+43 loc，
`spec/modules/farm-basic.json` 四条目）；**Master2_v_142 里的副本逐字
相同**（diff 验证），#22 牧场直接复用本实现即可。

## 心跳：脱显示列表的 ENTER_FRAME

原版 `_shape`（`new Shape()`，静态）**不进显示列表**，纯靠 AVM2 对所有
DisplayObject（含脱列的）广播 ENTER_FRAME 驱动 `updateAll`。openfl 9
等价语义成立（源码核实）：`DisplayObject.addEventListener` 对
ENTER_FRAME/EXIT_FRAME/FRAME_CONSTRUCTED/RENDER/ACTIVATE/DEACTIVATE 六种
走 `DisplayObject.__broadcastEvents` 注册表，`Stage.__broadcastEvent` 对
`stage == null` 的注册派发器照发——照译 `addEventListener` 即得心跳，
**不要**把 _shape addChild 到什么东西上去。eval 单测没有 stage 循环，
updateAll 永不触发，所以单测直接调 `renderTime(t)` 采样（t 是补间本地
时刻，绕过时间轴），帧驱动的时序对拍归 CI 时间轴比对。

## 双时间轴与推进

`initClass()`（首个 TweenCore 构造触发，重入靠 `rootFrame` NaN 门挡）建
`rootTimeline`（秒轴，`As3.getTimer()*0.001`）与 `rootFramesTimeline`
（帧轴，`rootFrame` 计数）；rootFramesTimeline 是 rootTimeline 的
**child**（构造链自然形成），渲染 root 会级联。`updateAll` 每帧先秒轴后
帧轴，`rootFrame % 60 == 0` 时清扫 masterList 里已 gc 的补间桶。
`delayedCall` 是 duration=0 + delay + onComplete 的 TweenLite，target 是
回调函数本身（AS3 原文如此）。

## 不能破坏的约定

- **Dictionary 型参必须写 `{}`**（masterList/fastEaseLookup）——落
  ObjectMap 身份键；`new Dictionary()` 裸 infer 编不过（#37 教训），
  型参写 Dynamic 会静默落 StringMap。delayedCall 的键是**函数**，eval/js
  的 ObjectMap 实测可用。
- **`target[property]` 的动态读写走本类的 `getTargetNumber`/`setTargetProp`**
  （renderTime 写、init 读起点）：openfl 9 的 x/y/scaleX/scaleY/alpha/
  rotation 是 get/set 属性，Reflect 直写在静态目标不走 setter、js/eval 落
  影子字段（#8/#10/#18 教训），按 CLAUDE.md 三选一的「cast 真类型」分流；
  其余键（匿名对象目标、插件的 changeFactor）走 Reflect。**调用方补间上面
  六个之外的显示属性时要往两个 switch 里加键**，否则 js 冒烟绿、真机
  （cpp）属性不动。
- **`typeof v == "number"` 译成 `Std.isOfType(v, Int) || Std.isOfType(v,
  Float)`**：Haxe 对象字面量里 `{"x": 0}` 的 0 是 Int，只查 Float 会把
  change 算成终值而非增量（补间不动）。js 上两者同型无感，eval 上致命。
- **eval Bool 零默认的两处垫片**：`_evalClassInittedNormalize`（静态，
  #39 测试轮加）与 `setEnabled` 开头的 gc 归一——TweenCore 的
  `param1 == this.gc` 守卫在 eval 上读 null 恒假、禁用路径整段跳过。
  若将来给 TweenCore.hx 的 `_classInitted` 等显式 `= false`（更合适的家，
  deviations 候选），两处垫片可删。
- 本作**插件支是死代码**：`plugins` 恒 `{}`（swf 里 com.greensock.plugins
  只有包名引用、无类），`overwriteManager` 恒 `{mode:1, enabled:false}`
  → `_overwrite` 只会 0/1，`manageOverwrites`/`onPluginEvent` 不可达——
  但都照译了，别删：Master2 侧若有人注册插件即活。

## 调用方（src 已有）

FarmStage 场景滑动（0.5s x）、FarmLandsView 飞机演出（from scale 3→1 +
to 飞出）、LandPickIcon 可收 icon 弹出/淡出、FlowerPlayer 边框淡出、
FarmLandController（狗提示）/WarehouseController（0.5s 重载）的
delayedCall。后续：#22 牧场（Master2 4 文件）、warehouse 已并（2 文件）。
