# test 树卫生机器门（issue #70）

两个 CI 机器门，管「仓库自身的卫生」而不是移植行为（原版没有对应物，出处
issue #70）。动 test/、tools/ 下的 .hx 文件，或被这两个门拦下时先读本页。

## 为什么存在

- **门一（test/ 禁 throw-stub）**：#56 事故的机器化。write-tests 曾把 stub
  放进 test/，implement 被 test/** append-only 驳回，被迫发明 import.hx
  类路径遮蔽绕开（烧掉 $11），留下两个永不编译的僵尸 stub（
  test/tools/TimelineSpec.hx / TimelineDiff.hx）。规则已落地（「stub 放它
  完工后所属的树」，write-tests 提示词 + test.hxml 的 -cp tools 注释），
  本门把规则变成差集报警：错放的 stub 在 write-tests 的 verify 当场红，
  而不是靠记忆。
- **门二（跨树重复模块路径）**：-cp tools 之后 test/、tools/、src/ 三棵树
  共享包空间，Haxe 对同名模块**静默按 -cp 顺序取先者**、不报错——
  import.hx 事件证明这种遮蔽能同时骗过 agent、review 和 verify。同一个
  机制也能吞掉真正的同名冲突（谁生效取决于各编译的 classpath 顺序），
  所以模块路径重复必须枚举报警。

## 交付形态：判式单源的三层

| 层 | 文件 | 职责 |
|---|---|---|
| 判式（纯逻辑） | `tools/tools/TestStubScan.hx`、`tools/tools/ModulePathScan.hx` | 行集→命中 / 枚举→冲突组；契约由 `test/tools/TestStubScanTest.hx`、`ModulePathScanTest.hx` 钉死（`haxe test.hxml`） |
| 脚本侧胶水 | `tools/tools/TestStubScanRun.hx`、`tools/tools/ModulePathScanRun.hx` | 走目录、读文件、拼报告、exit 0/1（DynWriteScanRun 先例） |
| 入口壳 | `tools/scan_test_stubs.py`、`tools/scan_module_paths.py` | 锚定仓库根、`haxe -cp tools --run tools.XxxRun` 拉起、透传输出与退出码 |

**改判式只能改 Haxe 半边**：python 壳零逻辑。这是有意的选型——#63 的
DynWriteScan/scan_dyn_writes 双实现要「两侧同步改、diff 非空即漂移」地
养着；#70 起机器门不再留第二份拷贝。

## 门一：test/ 禁 throw-stub

- 扫描面：`test/**` 全部 .hx（含 test/fixtures/ 快照件）。命中判式四条件
  在 TestStubScan 类头（字符串遮罩→剔 `//` 注释→语句位 throw 惯用语族→
  遮罩前逐字短语），行为由测试钉死，此处不展开。
- 已知误报边界（不修，启发式收窄的代价，review round 1 知悉即可）：needle
  出现在同行更早的字符串里、同行又另有无关业务 throw 的病态行（如
  `var a = "not implemented"; throw new Error(b);`）条件 4 会命中——当前
  全树零此形态，真出现时再收窄判式。
- 豁免（迁移期，写死在 `TestStubScan.exemptions()`，每条注明出处）：
  #56 的两个僵尸 stub 文件。按**文件路径逐字**豁免；清单不引入通用白名单
  机制。
- **失锚即红**：豁免文件零命中（僵尸被清/被填）→ 豁免条目失锚 → 门退 1。
  这是「清理僵尸后豁免清单清空」的强制执行面——清理 PR 必须同步删豁免
  条目并改 TestStubScanTest 的豁免断言（测试同样钉死两条，见
  `test_exemptions_exactly_the_two_zombies_with_reasons`）。
- 报告行格式 `path:line 摘录`（`TestStubScan.reportLine`）；说明行一律
  `scan_test_stubs: ` 起手——机读分拣靠 `TestStubScan.isReportLine`，
  说明行里别引入「ASCII 冒号+数字+空格」序列（豁免出处行用全角冒号）。

## 门二：跨树重复模块路径

- 模块路径 = **包声明 + 文件名**，与目录无关（`tools/xx.hx` 与
  `tools/tools/xx.hx` 都产出 `tools.xx`——三棵树「包路径 ≠ 文件路径」是
  常态，冲突检测必须以包声明为准）。
- 树内重复同罪（同一 classpath 内 Haxe 也按搜索序静默取先者）。
- 已确认的**非冲突**先例（别当豁免申请）：t3.TimelineSpec（实现）与
  tools.TimelineSpec（僵尸 stub）模块路径不同、靠 import.hx 遮蔽是两个
  模块的协作；test/import.hx（根包 → import）与 test/tools/import.hx
  （包 tools → tools.import）同理不撞。
- 扫描面：test/、tools/、src/ 三棵树全部 .hx。当前基线零重复（千余件，
  件数随树增长、以门自身输出为准），无豁免机制——本门没有存量豁免面，
  别开先例。

## 接线现状（已落地，人接的）

两道门**已在 write-tests/implement 的 verify 里生效**（2026-11-26，人直接
进 main，commit `f830e635`）：`.orchestrator/pipeline.yaml` 的 `suites:` 有
`test-stub-scan` / `module-path-scan` 两条（命令 `python3 tools/scan_*.py`，
timeout 1m），write-tests 与 implement 两个 stage 的 verify 列表都挂了它们。
agent 收工自检可直接跑 `python3 tools/scan_test_stubs.py` /
`python3 tools/scan_module_paths.py`——和 verify 里跑的是同一份。

**接线为什么是人接的**（两层保护，issue #70 的「checks 行 agent 可写」断言
只核实了配置层）：

- 配置层：四份流水线 yaml（pipeline/chore/plan/spec）的 `protected:` 清单
  都不含 `.orchestrator/`（review round 1 核实过，属实）。
- 合同层：编排器运行时组装进每个 agent 阶段提示词的 Rules 节**另硬编码
  保护 `.orchestrator/`、`.claude/`、`.mcp.json`**（三家都不在任何 yaml
  里），并声明「违反的 attempt 在一切开始前被拒」——implement 阶段合同
  的保护清单里 `.orchestrator/` 排第一个。

两层冲突以合同层为准：#70 的接线交付物在 agent 侧以 BLOCKED 收场，所有者
裁决后人自己落了 `f830e635`（pipeline.yaml 的 suites 注释里也写了这段裁决）。
命令用 `python3` 是硬约束——agent 容器没有 `python` 别名（只有
`/usr/bin/python3`），照 `python` 接线 verify 直接 127（review round 1
驳回点之一）。

## 坑

- **判式顺序**：字符串遮罩必须**先于**剔 `//` 注释，且遮罩与原文等长
  （转义对占两格）——URL 字面量里的 `//` 才不会截掉后续真代码（漏报），
  截断位才能换算回原文用。测试 `test_hit_url_in_string_before_throw_
  not_comment_cut` 钉死。
- **throw 语句位边界是白名单**（行首/空白/;{}()=），不含反引号：doc 注释
  里 `` `throw "not implemented"` `` 的引用形态靠它排除。「任何非标识符
  字符」的宽判式会误伤一切 Markdown 反引号引用（TestStubScanTest 的
  `test_no_hit_idiom_quoted_in_doc_comment` 是锚点）。
- **haxe 侧编译失败＝门退非零**（不区分「命中红」与「判式半边编不过
  红」）——失败方向一致：门跑不起来就是不放行。排查时先看输出里有没有
  `scan_test_stubs:`/`scan_module_paths:` 的说明行。
