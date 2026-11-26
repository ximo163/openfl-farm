# 资产渲染对拍门禁（T2）

给下一个 agent / 接线的人：issue #57 的 T2 门禁怎么跑、通道为什么是软画布、
判定语义是什么、盲区和换源口在哪。画面比对的「静态帧 + 播放抽帧」半边归它
管（另一边 T3 管播放头行为序列，[timeline-gate.md](timeline-gate.md)）；它
**比像素**（逐拍点软光栅化截图 → 哈希对拍），不管帧序列。

## 职责与组成

现状是**自回归基线**（基线＝首跑 openfl 截图，证明「没变」不证明「和原版
一致」）——真 Flash 参考采集是人的 TODO，采集就位后走换源口同管道重建（见
「换源口」节）。资产范围 = `assets/legacy-assets.txt` 全清单。

| 文件 | 内容 |
|---|---|
| `tools/RenderGate.mjs` | 编排 CLI：编探针 → 读清单/libraries.xml → 逐资产起 node 进程 → 聚合大报告（stdout + `export/render-gate/report.txt`）。`--only <子串>` 调试、`--update-baseline` 重建、`--source self\|references` 换源口、`--self-check` 注入自检 |
| `tools/RenderProbe.hx` | 实拍侧探针（编译到 `export/render-gate/render-probe.js`，单行 JSON）。装库 → 逐记录目标拍静态/播放拍点 → 软画布截图 → 哈希/比对（`--update` 吐基线条目、`--baseline` 对拍）。推进语义逐字复用 T3（stopTree/stepTree/根 `(currentFrame % totalFrames) + 1`） |
| `tools/SoftCanvas.hx`/`SoftCanvasElement.hx`/`SoftCanvasContext.hx`/`SoftPath2D.hx`/`SoftDOMMatrix.hx`/`SoftGradient.hx`/`SoftPattern.hx`/`SoftImageData.hx`/`SoftTypes.hx` | 自研软画布（node 无浏览器）：`installNode()` 换掉 `document.createElement('canvas')` 并注册 Path2D/DOMMatrix/HTMLCanvasElement 全局，BitmapData.draw(clip) → openfl CanvasRenderer → CanvasGraphics → 软画布 context 着色（fill/stroke/gradient/pattern/drawImage/clip/arc）。光栅在纯 Haxe，逐字节可复算 |
| `tools/DecodingImage.hx` | 位图解码钩子：顶替 `globalThis.Image`（原型上定义 `src` 访问器接住 lime 的裸 js 赋值）+ `URL.createObjectURL → null` 逼 lime 走 data URI 分支，PNG 真解码（format.png）、JPEG 取尺寸黑像素兜底（format 3.7.0 无解码器），计数进报告 |
| `tools/tools/BaselineFile.hx`、`RenderDiff.hx`、`RenderPlan.hx`、`RenderHash.hx`、`PixelDiff.hx`、`RenderTypes.hx` | 纯逻辑契约（test/tools 五个契约测试钉死）：基线序列化（键升序/紧凑/字段序 hash-width-height）、拍点计划、MD5 哈希、容差像素差 |
| `tools/render-baseline.json` | 基线（**入库**，先例 swf-code-baseline.json）：70 资产 7224 拍点 ~887KB。重建 `--update-baseline`（`--only` 子集替换），序列化两侧（Haxe/js）逐字节同构。2026-11-24 首跑 69 资产 6251 拍点；RedUp.swf 是 #58 后加清单的资产，2026-11-26 `--update-baseline --only RedUp.swf` 补采 973 拍点（增量纯加：旧键零变更零删除，脚本核过） |
| `test/tools/*Test.hx`（5 个） | 契约门（write-tests 钉死，只读） |

探针编译线（RenderGate.mjs 里）：`haxe -cp tools -cp test -lib format -lib
swf -lib openfl -lib lime -js render-probe.js -main RenderProbe`。

## 用法

```sh
haxelib run openfl build html5        # 前置：产出 export/html5/bin/lib/*.zip
node tools/RenderGate.mjs             # 全量 69 对拍：报告 + 退出码（红/错=1）
node tools/RenderGate.mjs --self-check           # 注入自检（完成标准 2）
node tools/RenderGate.mjs --update-baseline     # 重建基线（--only 子集替换）
node tools/RenderGate.mjs --only fish_01        # 调试单资产
bash tools/ci-gates.sh                # CI 接线一条命令：双闸 + 注入自检 + 豁免判定
                                      # （issue #94，见「CI 接线与裁决流」节）
```

退出码：0 全过；1 有红或有错；2 基建（探针编译失败/缺基线/重建有资产错——
**不写残缺基线**，失败资产的拍点会从门禁里悄悄消失）。

## 通道（探路结论，2026-11-24 容器内实测）

- **web-smoke 浏览器截图通道 CI-only**（容器无浏览器）——本地不可用。
- **node 侧唯一可行 = 软光栅化**：openfl 在 js 上的渲染出口是
  CanvasRenderer → CanvasGraphics → ctx 调用（arc/drawImage/fillText…），
  把 canvas 元素换成软画布，整条既有着色路径原样落进自研栅格化器——不重
  写 openfl、不碰翻译侧。四个环境钩子（`SoftCanvas.installNode` +
  `DecodingImage.install`）：① createElement('canvas') 替换；②
  globalThis.HTMLCanvasElement 注册（lime `ImageBuffer.set_src` 的
  instanceof 分流）；③ globalThis.Image + 原型 `src` 访问器（lime 生成的
  js 是裸赋值 `image.src = uri`，不走 Haxe set_src 方法）；④
  `URL.createObjectURL → null`（node 的 URL 没这函数，逼 lime 走 data URI
  分支进钩子③）。四个钩子缺一，圆/位图/缓存画布三族就静默消失或崩。

## 拍点与判定语义（改语义要连契约测试一起看）

- **拍点**（RenderPlan 契约）：静态 = 起点帧 + 各标签帧（gotoAndStop）；播
  放 = 0 基步号 {0 起点、中间、回绕、k 网格}，域 [0, steps]，推进语义与
  T3 一字不差。单帧符号也拍（T2 与 T3 的差别——「逐资产」覆盖单帧）。
- **记录目标** = 主时间轴（键 `""`，含单帧）+ 每个 sprite 符号实例化（含
  单帧）+ 非 MovieClip 的容器符号。位图/形状/文本/按钮是叶子，不单独实例
  化——由引用者截图间接覆盖，census 计数进报告。主轴符号本体跳过（T3 同
  款防 clipExtra 假红）。
- **比对单元** = 拍点键 `<asset>|<symbol>|<shotId>` 的截图哈希（MD5 over
  像素）。基线缺失 = missing 红（基线有键没实拍 = extra 红）——改拍点计划/
  记录目标面会大面积 missing/extra，属「改了覆盖面」信号，不是渲染跑偏。
- **确定性**：探针装库前把 `Math.random` 换成定种子 mulberry32——69 个
  bundle 的 scriptSource 全量扫描只有 farmui1 一处非确定源（a_151 第 1 帧
  `this.gotoAndPlay(Math.floor(Math.random()*100))`，原版本意就是随机相位；
  T3 步进从第 2 帧起恰不进第 1 帧而躲过，T2 的 f1 拍点进第 1 帧必须钉住）。
  脚本照原样执行、行为语义不动，只是每次取同值——自回归基线才可比。

## 换源口（真 Flash 参考就位后）

`--source references` + `--update-baseline`：基线 JSON 顶上有 `source`
字段（`"self"|"references"`）记录来源，比对逻辑**不按它分支**——换源就是
同一管道重建一遍（真 Flash 侧采集的截图按同拍点键入库）。现状
source=self，报告头会提示这一立场。

## 全清单现状（2026-11-24 首跑；2026-11-26 #94 接线复核）

69/69 通过、双跑逐字节一致；注入自检红在注入目标的拍点键上。覆盖数：PNG
解码 112、JPEG 黑兜底 104、动态文本字形盒 fillText 877、位图兜底采样 0、
实例化失败符号 3（levelUpUI 的 #13/#26/Update.bigPanel——`frames: []` 空
帧表符号，AnimateTimeline.init 读 `frames[0].objects` 必炸，T3 的
`< 2 帧`门从未实例化过它们；如实计数不判红，修法归人裁决）。

#94 接线复核（2026-11-26）：清单已长到 70（#58 加了 RedUp.swf），首跑基线
没有它的条目——双闸全量跑如实红在 973 笔缺基线上（门禁把「基线落后于
清单」这种基建缺口也拦下了），按 `--update-baseline --only RedUp.swf`
补采后 70/70 双闸全绿（见 `CI 接线与裁决流` 节）。**清单加了资产要记得
跑基线子集重建**，否则接线 CI 会红在缺基线。

## 非显然约定

- **探针 stdout = 单行 JSON**，且 `println` 走 `fs.writeSync(1, …)` 不走
  `process.stdout.write`（管道上异步，紧随的 process.exit 截掉大 JSON 尾巴
  ——farmui2 的 280KB 实测丢 60KB）。
- **每资产一个独立 node 进程**，DisplayObject/软画布静态表不跨资产串。
- **`run-openfl-node.js` 传探针绝对路径**（相对路径 require 解析失败）。
- **js 上 `Bytes.get` 被内联进 `.b[i]`**：像素读出来要静态定型
  `var px:haxe.io.Bytes` 再 `px.get()`——Dynamic 接收者找不到运行时方法
  （DCE 不发射）。
- **注入目标选「首个有可见画面的」**：空渲染目标（Crop_1056_3 主轴 0×0）
  缩放后仍空，注入不红造成自检假阴——`getBounds` 先筛。
- 基线两侧序列化（probe 的 BaselineFile.stringify / gate 的 writeBaseline）
  必须逐字节同构，否则二次重建自产生假 diff。

## CI 接线与裁决流（issue #94）

两闸机器件并入 main 后零调用、渲染/时间轴跑偏的 PR 照常合并的问题由
`tools/ci-gates.sh` 收口：**A 案**（web-build 内加一步，红＝web-build 红，
不加新 check 名）。本页是这条接线的语义权威（T3 的豁免登记也归这里——
`GateExemptions.hx` 头注释的路由）。

| 文件 | 内容 |
|---|---|
| `tools/ci-gates.sh` | CI 步实体：环境前置 → 两闸 `--self-check`（注入红过闸的 CI 同跑）→ 两闸全量对拍（**不短路**，一闸基建错不埋另一闸）→ 判定 + step 日志块 → 退出码 0/1 |
| `tools/tools/CiGatesVerdict.hx` | 判定纯逻辑（契约 `test/tools/CiGatesVerdictTest.hx` 钉死）：退出码分流、定位行提取（T2 拍点键三形/错误行、T3 跑偏两形/错误行）、豁免匹配、step 日志块拼装 |
| `tools/tools/GateExemptions.hx` | 已裁决豁免登记表（「红≠一律修」的机器面，见下） |
| `tools/tools/CiGatesScan.hx` | 机读胶水（BootSmokeScan 同款分层）：bash 侧采退出码与报告路径 → `judge` → `pass=`/`line=` 键值行 |

退出码分流（两闸契约 0/1/2 → CI 红绿）：0 绿；1 红·错 → CI 红；2（探针
编译失败/缺基线）与一切未声明非零（node 崩溃/被信号杀的 137/139——闸没按
契约说话＝闸失灵）→ **也判 CI 红**，但状态行标注「gate 基建问题非渲染
回归」，先修基建别查渲染回归。基建坏的闸**不吐报告红行**（两闸 exit(2)
位点都在落盘之前，盘上只可能是陈旧报告）。exit 1 而报告里提取不出定位行
的照红（看不见的红不当绿）；报告红行压过退出码绿（闸内不一致照红）。
step 日志 = 两闸状态行（闸名+退出码+报告路径）+ 定位行（豁免的照打、带
登记理由）；聚合大报告在 `export/timeline-gate/report.txt`、
`export/render-gate/report.txt`（gitignored）。

### 红≠一律修的裁决流

CI 红了先定性再动手，**豁免不是静默放行**（step 日志照打红行 + 登记理由，
复审可追）：

- **真回归**（渲染面变了/播放头行为变了）→ 开修复 issue，不进登记表。
- **原版差异/工具误差**（T2：盲区兜底一类；T3：脚本驱动播放头、期望侧
  推不出脚本行为）→ 按闸分流：
  - T2 走**换源口**：`--update-baseline`（必要时 `--source references`）
    重采、基线 `source` 字段登记来源；重采后红即消失，不进登记表。
  - T3 登记 `tools/tools/GateExemptions.hx` 条目（`gate: Timeline` + 资产键
    = `assets/legacy-assets.txt` 清单路径整串 + 裁决理由含技术根因与
    状态）——本表只在 T3 侧生效（豁免按闸按资产整串匹配）。
- **执行错误行**（`资产 …：错误——…`，探针没跑成/清单外资产）不可豁免：
  错误是闸的执行失败，要么修基建要么修资产，judge 判式已钉死。
- 登记条目失效自爆：`GateExemptionsTest` 钉了资产键必须在清单里整行存在
  ——资产改名/键写错当天测试就红，不会静默漏豁免。

### 裁决记录（登记表的本账）

| 登记条目 | 闸 | 定性 | 状态 |
|---|---|---|---|
| `source/core/module/mc/main/farmui1_v_42.swf` | T3 | GiftIcon、farmui1_fla.Timeline_39、farmui1_fla.a_151 三剪辑帧脚本是 gotoAndPlay 族（含 `gotoAndPlay(Math.floor(Math.random()*100))`），脚本驱动播放头、期望侧 swf 结构静态提取推不出——非移植跑偏的诚实红（#56 全清单首跑发现，[timeline-gate.md](timeline-gate.md)「全清单现状」节） | 偏差候选待人裁（deviations 候选）；#94 接线（2026-11-26）按裁决流登记豁免，CI 照打红行带理由 |

### 人管线（.github/、.orchestrator/，agent 不改）

A 案接线 = `web.yml` 的 web-build job、单测步之后加一步（haxe/node 已在
job 里就位、html5 产物本地在位；`format` 探针编译线要——web-build 原本
只装 lime/openfl/swf/utest）：

```yaml
      - name: T2/T3 画面门禁（双闸 + 注入自检 + 豁免判定）
        run: |
          haxelib install format
          bash tools/ci-gates.sh
```

注意 web-build 的 `timeout-minutes: 20` 要给双闸全量对拍留余量（一轮
自检+全量+判定实测约 2.5 分钟，2026-11-26 容器实测；资产清单长大会涨），
不够就调。红＝web-build 红，无需新增
check 名；`required_checks` 不动。收口两处注释为事实陈述：
`pipeline.yaml:15`（「T2 后加 visual-diff」的许诺——A 案没有独立
visual-diff check，画面门禁在 web-build 内）与 `:19`（required_checks
行尾注释）。`port-tree` 的 #57 行按实况更新、#59 解锁（在
openfl-farm-docs 仓库，人管）。
