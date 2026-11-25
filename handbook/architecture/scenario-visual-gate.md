# 场景视觉对拍门禁（T1）

给下一个 agent / 接线的人：issue #59 的场景视觉门禁怎么跑、通道为什么还是
#57 的软画布、**确定性协议为什么要那几层**（这是本页的核心——不照协议跑，
两次运行连自回归都对不上）、判定语义、自检与换源口在哪。它管**整场景在
操作驱动下的画面**（进场、种植、浇水、收获连拍），单资产的静态对拍归
[T2](render-gate.md)，时间轴行为序列归 [T3](timeline-gate.md)；请求/状态
对拍的操作步骤原语与它共用
[scenario-runner.md](scenario-runner.md) 的执行器。

## 职责与组成

现状是**自回归基线**（基线＝openfl 首跑记录，证明「没变」不证明「和原版
一致」）——参考库换源口见下节。场景范围：`tools/scenarios/*.json`（当前
plant 一个：进场→种→浇→收）。

| 文件 | 内容 |
|---|---|
| `tools/scenario.mjs` | 编排 CLI（在 T-something 运行器上扩出视觉检查点）：`run`（跑场景出记录、对基线判红）、`run --self-check` / `--self-check`（注入自检）、`diff`（两份记录离线复验）。视觉部分：引导协议（本页「确定性协议」）、检查点采集（screenshot/burst）、能量曲线、基线对比整份判红 |
| `tools/ScenarioVisual.hx` | 视觉侧探针（nodeboot 起进程时先于游戏 bundle 编译加载）：软画布/解码钩子安装、**虚拟钟与虚拟定时器接管**、`pump/settle/shot/hash/burst/frozenBurst/recordMatches/specOf/framesForMs/probeHash/pumpProbe/stats` API 挂 `globalThis.__openflFarmVisual` |
| `tools/nodeboot/nodeboot.mjs` | node 起动器：虚拟 XHR 服务器 + **FIFO 释放队列**（见「确定性协议」）+ 真实 `Date.now` 引用透传给驱动 |
| `tools/scenarios/plant.json` | 场景声明 = 判定输入：steps + `checkpoint.visual`（`screenshot` 单张 / `burst {intervalMs, count}` 连拍） |
| `tools/scenarios/plant.record.json` | 基线记录 = 判定输出，**入库**：请求序列 + 每步视觉节（帧哈希数组 + 能量曲线）+ 视觉环境指纹。重建 `run --update-record`，序列化两侧同构（离线 `diff` 复验同语义） |
| `tools/tools/SceneShotPlan.hx`、`SceneShotDiff.hx`、`MotionEnergy.hx` | 纯逻辑契约（test/tools 契约测试钉死）：拍法解析、逐帧/曲线对拍、相邻帧像素变化计数 |
| `test/tools/*Test.hx` | 契约门（write-tests 钉死，只读） |

截图通道直接复用 #57 结论（node 里唯一的本地图通道 = SoftCanvas 软画布，
`BitmapData.draw → CanvasRenderer → 软画布`），不另起炉灶；文本字形是
确定性实心盒、JPEG 取尺寸黑像素兜底，都是 T2 已有语义在整场景上的复用。

## 用法

```sh
node tools/scenario.mjs run tools/scenarios/plant.json            # 对基线判红（CI 形态）
node tools/scenario.mjs run tools/scenarios/plant.json --update-record   # 重建基线（全绿才落盘）
node tools/scenario.mjs --self-check tools/scenarios/plant.json   # 冻住连拍注入，必须红
node tools/scenario.mjs diff a.record.json b.record.json          # 两份记录离线复验
```

排障钩子（都 env 门控，平时零开销）：`SCENARIO_DUMP_SHOTS=<目录>` 逐拍存
原始 RGBA；`SCENARIO_DUMP_TREE[=_ALL]` 打印与指定区域相交的显示树；方差
攻关专用：`SCENARIO_PROBE=on` 引导期逐泵打 `BPROBE` 行（区域指纹 + 定时器/
随机/网络计数），`SCENARIO_PROBE_FRAMES=<n>` 引导后逐帧探 `PROBE` 序列
（**别写 `SCENARIO_PROBE=1`**——该值会被当探针帧数用，只探 1 帧），
`SCENARIO_PROBE_DUMP=<目录>` 逐泵落方差区像素。

## 确定性协议（本页核心，动前必读）

「两次运行字节相同」不是 node 的默认行为，是下面五层叠出来的。每层都有
实测证据链，拆任何一层前先想清楚那层挡的是什么：

1. **虚拟钟（冻结 + 泵进）**：游戏可见时刻 = 基点 + 已泵帧时长
   （`ScenarioVisual.freezeClockAndWrapTimers`），`Date.now`/`performance.now`/
   全部 `setTimeout`/rAF 都接虚拟钟，真实等待只发生在驱动的 `await sleep`
   里，游戏无感。**基点钉死为常量**（`getTimer` 归零、Date 定 2026-01-01）：
   实测当前画面没有读绝对时刻的渲染路径（同配置 16 次跨小时全同指纹），但
   基点取真实时刻时它是一个待引爆的类，关死不亏。
2. **泵帧只在网络静默时**：应答交付只发生在驱动的 `await` 里（泵是同步 JS，
   单线程不交错），应答处理器恒跑在未前进的虚拟时刻上。引导波实测量化在
   固定泵位（0/13/…，两次运行逐条对齐）。**Main 出生前同样照泵**——
   `__openflFarmDrive` 句柄在主程序第一个 ENTER_FRAME 才挂（shim/Harness
   markMainFirstFrame），等句柄才泵是死循环（句柄要靠泵才出现，实测三次挂
   死两次）。
3. **FIFO 释放**：nodeboot 的虚拟 XHR 完成事件按**发送序**释放
   （`queueRelease`/`drainPending`）。真实完成先到也得等更早的请求先
   release——否则并发的库请求完成顺序一翻，游戏可见的完成序就双峰，画面
   烤出离散两族指纹（攻关期实测 boot 末方差区两族
   `2b77e3c8`/`59d6ed93`，逐泵探针证实计数全同而像素分叉）。
4. **泵前置真实静默窗**（`REAL_IDLE_BEFORE_PUMP_MS=200`）：泵与泵之间的
   真实间隙里还有**不进任何计数**的真实异步收尾在跑——最典型的
   `shim.LocalSwfLoader` → `Assets.loadLibrary().onComplete(...)` 链：素材
   库字节经虚拟 XHR 交付（有计数）之后的解析/挂树/COMPLETE 派发全在真实
   tick 上落地（无计数可观测）。窗不够时它落在第 k 泵前还是后是掷硬币
   （攻关期无窗跑约 25–50% 分族，引导期逐泵加探针开销后 13 次里只 1 次——
   开销把窗拉宽了，碰巧盖住多数落点）。泵前置 200ms 静默后，任何
   ≤200ms 的真实收尾恒落在「触发它的那泵」与「下一泵」之间，泵上的画面
   退化为泵计数的纯函数。代价是引导真实时间多 ~9s，门禁可接受。
5. **引导 settle 判据**：就绪 + `BOOT_IDLE_STREAK` 轮静默后才进场景步骤；
   泵出的新请求自动重置计数，不存在「边等应答边泵」。

改协议常量（`BOOT_POLL_MS`/`BOOT_IDLE_STREAK`/`REAL_IDLE_BEFORE_PUMP_MS`/
`SETTLE_SHOT_FRAMES`/`SETTLE_BURST_PRE`）= 改基线：它们进记录的视觉环境
指纹，两侧同构，漂了会先红在环境指纹而不是画面。

## 判定语义

- 场景声明（plant.json）= 判定输入；基线记录（plant.record.json）= 判定
  输出，**两侧同构**——run 时逐步重放，screenshot 比单帧哈希、burst 比逐帧
  哈希数组 + 能量曲线（相邻帧像素变化计数，`MotionEnergy`），任何一帧或
  一个点分叉整步红；帧数/曲线点数与声明不对齐也红（`recordMatches` 对齐门）。
- 整份判红还包括：请求序列（操作计数/白名单）、视觉环境指纹（协议常量 +
  `stats()` 采集计数：泵帧数、帧时长、PNG/JPEG 解码覆盖、fillText 调用数）。
  解码覆盖计数掉了（比如 JPEG 兜底口径变了）会红在环境指纹，不用等画面猜。
- **自检注入**（完成标准要求的「冻住动画必须红」）：`--self-check` 对首个
  burst 检查点再拍一组冻住版（不泵帧），断言基线曲线有动画能量、注入版曲线
  归零且帧哈希应红——门禁有牙的证明，绿着过视为门禁失牙直接判红。

## 换源口（真 Flash 参考就位后）

记录的视觉节只存哈希与曲线；换真 Flash 参考采集时，`--update-record` 对着
参考跑一遍重建即可（与 T2 同模式）；`diff` 离线复验两份记录同语义。场景
声明不动——声明描述「拍什么」，与画面来源无关。

## 盲区（如实计数进报告/记录）

- 文本字形 = 确定性实心盒（布局真、字形盲区，`fillTextCalls` 计数）；
  JPEG 只取尺寸黑像素（无解码器，`jpg` 计数 + `decodeFail` 列表）。
- 截图含「泵到那一刻为止」的画布累计内容——软画布不清屏语义与真实
  Flash 一致，但意味着「清屏错误」这类 bug 要靠帧序列分叉暴露。
- **修好确定性协议会让「本该录到却从未录到」的原版行为现形，冻结核会
  对它过时**：200ms 静默窗让水模块入场初始化链（`FarmApplication.startup`
  500ms 派 `MSG_LOAD_WATER` → WaterController 装配 → `checkWhiteList→
  loadFishes`）在录制窗内跑通，发 `mync.php?mod=cgi_fish_index`——
  legacy 原样**无 act**（`ServerServices.as:157`、`nc/mod/cgi_fish_index.php`）。
  协议修复前这条真实异步链死在录制收尾前、两代旧基线都没录到；
  `ScenarioRunnerContractTest.hx:503` 的「每条请求有非空 mod/act」是在
  5 请求年代冻结的，现对忠实记录单点红（4860/4861）。**别**用过滤请求/
  合成 act/压掉模块救绿——那是在改原版行为迁就过时前提；处置走 #37 的
  NEEDS-TESTS 先例（water.md「测试前提冲突」）：证据链交测试侧 visit 改
  形状门（如容许 cgi_* 无 act）。
