# 时间轴行为对拍门禁（T3）

给下一个 agent / 接线的人：issue #56 的 T3 门禁怎么跑、判定语义是什么、
盲区和诚实红怎么读。画面比对的「时间轴行为」半边归它管（另一边是场景
连拍）；它**不渲染**、不比像素，只比播放头行为序列。

## 职责与组成

期望序列从 swf **结构**静态提取（帧数/标签表/脚本帧位），实跑序列由探针在
html5 同一套运行时上**固定步长推进**录得，逐项 diff，报告定位到「哪个符号
哪一步哪一项」。全清单 69 资产一条命令跑完。

| 文件 | 内容 |
|---|---|
| `tools/TimelineGate.mjs` | 编排 CLI：编探针 → 读清单/libraries.xml → 逐资产起 node 进程跑探针 → 聚合大报告（stdout + `export/timeline-gate/report.txt`）。`--only <子串>` 调试、`--self-check` 注入自检 |
| `tools/TimelineProbe.hx` | 实跑侧探针（编译到 `export/timeline-gate/timeline-probe.js`，出口单行 JSON；期望侧提取同进程）。步进语义逐字复用 `tools/StepAnimate.hx`（stopTree/stepTree/根 `(currentFrame % totalFrames) + 1`） |
| `tools/tools/TimelineExtract.hx` | 期望侧提取器：swf 字节 → 结构 JSON。format 3.7.0 Reader 主路 + 自带标签走查 fallback（a6291_1） |
| `test/tools/TimelineTypes.hx` | 两侧共用的纯数据形状（typedef） |
| `test/tools/TimelineSpec.hx` | 期望侧派生：多帧剪辑/步数/每步 currentFrame/标签命中/圈数终点（公式钉死，见下） |
| `test/tools/TimelineDiff.hx` | 比对器 + 人读报告渲染；探针与单测复用同一份 |
| `test/tools/TimelineSpecTest.hx`、`test/tools/TimelineDiffTest.hx` | 契约门（write-tests 钉死，只读） |
| `tools/run-openfl-node.js` | node 垫片；本轮补了 `window.Image`（见 lessons） |

## 用法

```sh
haxelib run openfl build html5        # 前置：产出 export/html5/bin/lib/*.zip
node tools/TimelineGate.mjs           # 全量 69：报告 + 退出码（红/错=1）
node tools/TimelineGate.mjs --self-check --only fish_01.swf   # 注入自检
```

退出码：0 全过；1 有红或有错；2 基建（探针编译失败/缺 lib）。报告 artifact
落 `export/timeline-gate/report.txt`（gitignored，贴 issue 评论，不提交）。

## 判定语义（改语义要连契约测试一起看）

- **比对单元**＝多帧剪辑（frames>1；StepAnimate.hx:122 的门同款）。单帧剪辑
  不记录不比对——help 的 `help0316_fla.pageN` 一族全是**单帧带脚本**符号，
  按此契约天然不进比对面。键：主时间轴 `""`、有 SymbolClass 名用名、否则
  `#<charId>`。
- **步进公式**（两侧同一式，与帧率无关）：第 s 步后 currentFrame =
  `(s % frames) + 1`；loops = `floor(steps/frames)`；endFrame =
  `(steps % frames) + 1`；steps = 期望侧多帧剪辑最大帧数（两侧步数不一致
  本身就是资产级红项）。
- **序列项四件**逐项独立判红：currentFrame（逐位，长度不等也红）、
  labelHits（{step,name} 逐位；命中 = 恰落在标签帧上）、loops/endFrame、
  frameEvents。外加对齐项 clipMissing/clipExtra（只报存在性）。
- **盲区降级**（不判红不假绿）：期望侧只推得出脚本在**哪些帧**（scriptFrames），
  推不出脚本**干了什么**（ABC frameN 体是编译后的 AS3，js 目标经
  FrameScriptParser 转 JS 执行、非 js 直接丢）。scriptFrames 非空的剪辑，
  frameEvents 项降级：openfl 侧事件照录进报告、计入 GateReport.downgraded。
  **降级只护 frameEvents 一项**——脚本改播放头造成的 currentFrame/loops/
  endFrame/labelHits 红照红（诚实红，见下）。

## 期望侧提取的两条读法

- format Reader 主路（68/69）；a6291_1.swf 在 Reader 上抛 Eof
  （PlaceObject3 className，Reader.hx:961）→ fallback 自带**长度走查**
  （只解 ShowFrame/FrameLabel/DefineSprite/SymbolClass/DoABC/86，其余按
  长度跳过——这就是它能活过坏标签的原因），`via=raw` 在报告里可见。
- scriptFrames 镜像运行侧三条规则（都从 haxelib swf 3.4.0 源码核实）：
  ① 只扫**最后一枚根级 DoABC(82)**（SWFTimelineContainer.processAS3Tag
  每枚都覆盖 abcData）；② 只认 **SymbolClass(76)** 绑定名（运行侧
  symbolsByClassName 只来自它；ExportAssets(56) 全清单 0 枚且 exporter 不采）；
  ③ 类名匹配镜像 AVM2.findClassByName（拆最后一段为类名、其余为包名，
  namespace 只认 public/internal/private/protected 家族），方法名
  `frame(\d+)` 取 1 基帧号。

## 全清单现状（2026-11-24 首跑）

68/69 通过；唯一红 farmui1_v_42——三个剪辑（GiftIcon、farmui1_fla.Timeline_39、
farmui1_fla.a_151）的帧脚本是 `gotoAndPlay` 族（含 `gotoAndPlay(Math.floor(
Math.random()*100))`），改了播放头，属于**脚本驱动播放头的诚实红**：这不是
移植跑偏，是「期望侧推不出脚本行为」这一盲区的行为面暴露。处置归人裁决
（deviations 候选），门禁照实红。降级剪辑 43 个、分布 8 资产
（FDog100/farmui_full/farmui2/water_ui/farmui1/fish_02/fish_15/Fertilizer）。

## 非显然约定

- **探针 stdout = 单行 JSON**。库侧日志两条路（haxe trace 的缺字体警告、
  lime.utils.Log → console.info 的帧脚本求值错）都被探针拦进 JSON 的
  `scriptLog` 字段（截断 400 条/条 300 字），自己的 println 走
  `process.stdout.write`。给探针加输出时保持这条。
- **每资产一个独立 node 进程**（gate spawnSync），DisplayObject/静态表不跨
  资产串。
- **run-openfl-node.js 的 `require(script)` 相对 tools/ 解析**——探针 js 要
  传**绝对路径**。
- **记录目标 = 库里每个多帧 sprite 符号单独实例化**（`__createObject`），
  外加多帧主轴（键 `""`）：fish_01 一族符号根本没放进主轴，逐个实例化是
  全覆盖的唯一办法；主轴符号本体跳过（避免以文档类名重复记一条 →
  clipExtra 假红）。
