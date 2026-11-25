# 帧脚本清查与补偿（#58）

资产 swf 帧脚本（`addFrameScript` 登记的 `frameN` 方法体）在 openfl 侧的
复原机制：原版素材符号类把行为写在帧脚本里（进帧即执行），本地化管线
把这层丢了，本页是查出来、补回去的通路。

## 问题：scriptSource 为什么不生效

原版符号类（如 farmui_full 的 `MaoPaoFlag`）构造器里
`addFrameScript(0, frame1, 23, frame24)`：播放头进帧 1/24 时执行对应
`frameN` 方法体（`infoTxt.text = talkInfo; stop()`）。

openfl 侧（swf 3.4.0 的 AnimateLibraryExporter/AnimateTimeline，容器内
`/usr/local/lib/haxelib/swf/3,4,0` 实测）：

- 只有 **SymbolClass 绑定的符号**才带 `scriptSource`（FrameScriptParser
  把 ABC 转成 JS 源码挂在 AnimateFrame 上）；根时间轴（cid 0）没有。
- 该 JS 只在 **html5** 目标 eval，且在 Haxe 实例上跑不动（引用动态属性
  抛错，异常被 lime Log 吞）；非 js 目标整体丢弃。

结果是一族「静默跑偏」：气泡文本不出现、RedUp 不自报 "end"、光标不停在
帧 1、加载环不回跳 "loop"、水花不自摘、背包页签按钮点不动（整条切换链
死）。这些偏差 CI 冒烟不报错——行为对了没有显式断言，只有画面比对能抓。

## 通路：登记表 + 接线

**登记表 `src/shim/FrameScriptCompensation.hx`**：

- `entriesFor(libraryId, symbolKey)` 查表（symbolKey 空串 = 根时间轴，
  T3 约定）；`FrameScriptAction` 动作原语（`Stop` / `DispatchEvent` /
  `SetText` / `GotoAndPlay` / `GotoAndStop` / `RemoveSelf` /
  `AddClickListener`）——**只列已登记方法体里实际出现的形态**，新形态
  须先扩枚举（带字节码出处）再登记，不得并入近似原语。
- 表内容逐条出自 legacy 字节码，出处分两层：**issue 点名两例**（MaoPaoFlag
  frame24、RedUp 主轴 frame134）的红测门在
  `test/shim/FrameScriptCompensationTest.hx`（删登记/改帧号/改动作必红）；
  **清查批次 2 的 32 条**出处写在登记表行内注释（可指到反编译 `.as` 的写
  行号，swf 未反编译的 farmui2 写 FrameScriptAudit 的 op 流）+ PR 说明的
  清查报告——`test/TestMain.hx` 对 implement 是 append-only，新测试文件
  注册不进 main 永不编译（#56/#58 attempt 各被驳回一次），下一轮
  write-tests 把它们补进红测。**空体不登记**（frame1 只有 return 的类无
  行为可补，FarmInfoPlus 先例）；不虚造（收获动画第三例：`*_movie.swf`
  不在部署包，无字节码）。

**接线 `attach(target, libraryId, symbolKey)`**：查表后按原 0 基实参
`target.addFrameScript(frame - 1, …)` 回挂。调用点只有两处，都在
Timeline 已挂上之后（`addFrameScript` 在无 Timeline 的实例上静默丢弃）：

- `SymbolClass.attach` / `bindRoot`（符号 shim 构造路径）；
- `LocalSwfLoader.attachContent`（`Loader.load` 的根时间轴路径，
  symbolKey 空串）。

**时序坑（为什么必须在 bind 之后）**：openfl `Timeline.__attachMovieClip`
在 `scripts` 数组非空时**重建** `__frameScripts`（html5 上 scriptSource
转出的 scripts 恒非空）——先挂的 addFrameScript 会被整体顶掉；绑完再挂
则 `__addFrameScript` 同帧是 **set**，把跑不动的 scriptSource 残骸顶掉、
不双跑。早退分支（时间轴已挂上）重复登记也幂等。

## 清查器（tools/）

- `tools/FrameScriptSurvey.hx`：纯逻辑（test.hxml 可编译，无 format 依赖）——
  `ctorBindings`（构造器 op 流 → addFrameScript 登记表：多对单调用、
  FindPropStrict+GetProp / OGetLex / OThis+GetProp 三型方法取法、0 基实参
  → 1 基帧号）与 `isBodyEmpty`（剥 OThis/OScope/调试 op 后无行为 op 即
  空体；未映射 op 按实义不猜）。`FrameScriptOp` 是 format OpCode 的镜像
  枚举（测试 fixtures 逐字抄字节码）。
- `tools/FrameScriptAudit.hx`：一次性 CLI（**容器内跑，报告贴 PR 说明/
  issue 评论、不提交文件**——报告类产物不入库）：
  `haxe -cp tools -lib format -main tools.FrameScriptAudit --interp`。
  扫 `assets/legacy-assets.txt` 全部 swf 的根级 DoABC（72/82 全收——清查
  要「原版有什么」，#56 只认最后一枚是「openfl 运行侧看得到什么」），
  逐类解构造器与 frameN 方法体，按 空体/实义 分流打印 op 流；SymbolClass
  的 cid 0 = 主时间轴文档类；format Reader 读不动的走 a6291_1 同款长度
  走查 fallback。

## 登记纪律（新符号/新库开工时照办）

1. **先跑审计**：`FrameScriptAudit`（或 CI swf-audit 同款差集）看该库有
   无帧脚本族；带交互代码的 swf 先过 `tools/swf_code_audit.py`（LEAK =
   不是素材，见 CLAUDE.md 资产节）。
2. **逐条出处**：能指到反编译 `.as` 的写行号；swf 未反编译的（farmui2）
   写 ABC 清查 op 流；两边都没有的不登记（BLOCKED 级）。
3. **补偿随符号接线**：符号 shim 建到哪条、消费点（getMaterial/new/
   getClass 反射）在哪，登记表就收到哪条。未接线的实义帧脚本（farmui1
   全族、farmui2 wild 系与 farmui2_fla 内部件、farmui_full 的
   AddAnimation/lock_mc_46、Fertilizer CursorTool2x、help.swf——牧场批次）
   不预登记，登记了也没人查表；符号立项时随符号补。
4. **登记表钉死**：红测门（删表行必红）目前只有 issue 点名两例
   （FrameScriptCompensationTest）；批次 2 靠行内注释 + 清查报告钉出处。
   后续 write-tests 轮动到本表时，把行内注释的出处逐条升格为期望值
   断言（出处写在期望值上方注释，CLAUDE.md 测试规则）。implement 阶段
   别试往 `test/TestMain.hx` 加注册行——append-only 门直接整单驳回
   （#58 attempt-1，2026-11-25）。

## 分工（别踩别人的田）

- **#56（T3 时间轴门禁）**：只推得出「脚本在哪些帧」（scriptFrames
  镜像），不管方法体内容与 src 补偿。
- **#57（T2 渲染对拍）**：逐资产截图与播放抽帧，管画面跑偏的发现侧。
- **本页（#58）**：方法体提取（ABC 字节码）+ src 补偿登记表 + 接线。

## 关键行为细节（补偿写法前先核对）

- `gotoAndStop(N)` / `gotoAndPlay(标签)` 在帧脚本或其闭包里跳帧后，
  openfl `Timeline.__goto` 会评估目标帧**自己的**帧脚本（含再挂监听）
  ——与 Flash 进帧即跑帧脚本同序。PackageTab 的页签帧脚本每进帧重挂按钮
  CLICK（闭包每次重建、监听器累积）是**原版行为**，补偿照抄不「优化」。
- 帧标签（"loop"/"GiftMove"）在 swf 的 FrameLabel tag，`dump_swf.php` 可
  证；`gotoAndPlay(标签)` 标签不存在时 openfl 抛 ArgumentError——登记
  前先 dump 一下。
- 帧脚本执行时该帧的子件已实例化（`__evaluateFrameScripts` 先
  `__updateSymbol` 再跑脚本），`As3.childOf` 取得到 PlaceObject 命名的
  具名子件（infoTxt/btnTool）。
