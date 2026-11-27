# swf-inventory 手写增补保留与接线（issue #83 判式 / #95 接线与对账门）

仓库自建的归并纯逻辑（原版没有对应物，出处 issue #83 决策点 a）。动
`tools/tools/SwfInventoryMerge.hx`、或要写/改「在 spec/swf-inventory.json 里
手写增补键（code/triage/…）」的工作时先读本页。

## 为什么存在

- `scripts/swf-inventory.py`（人管）用 `json.dump` **从零全量重写**
  `spec/swf-inventory.json`，自身没有任何合并/保留逻辑；CI
  `legacy-decompile.yml` 由 `legacy/deploy/recompile-trigger` 的 push 触发
  再生成（该文件历史上改一次重生成一次）。
- 后果：pipeline:spec 交付进这个文件的手写内容**活不过下一次再生成**。
  #30 给 shop_v_7/warehouse_v_23/pool_v_13/decorate_v_0 手写的 `code` 块
  （五键形态，出处 commit `84c203bb`）被 `399a5faa` 的 CI 再生成整体抹掉、
  因无测试钉住无人察觉。#66（cards_v_1/quickshoot_v_0/WildShellNc_v_5）同
  形态交付也会落地即死。
- 修复方向（issue 决策点 a，所有者裁决）：**重写前读旧文件，同 path 条
  目保留手写键；机器面（bytes/category/fps/…、条目增删、path 排序、顶层
  version/source/count）永远以新生成为准**。

## 结构：判式单源、脚本侧归人

| 层 | 文件 | 职责 |
|---|---|---|
| merge 判式（纯逻辑） | `tools/tools/SwfInventoryMerge.hx` | JSON 文本进 → JSON 文本出；契约由 `test/tools/SwfInventoryMergeTest.hx` 钉死（`haxe test.hxml`） |
| 对账判式（纯逻辑，#95） | `tools/tools/SwfInventoryReconcile.hx` | 再生成前后手写键集合对账（missing_entry/missing_key/altered）、单文件自检（duplicate_path/null 值）、生成器接线静态对账（wiring_missing）；契约由 `test/tools/SwfInventoryReconcileTest.hx` 钉死 |
| runner（进程面胶水，#95） | `tools/tools/SwfInventoryMergeRun.hx` | 三文件位参（旧清单/生成产物/写回路径）→ 调 merge → 落盘；`keep <path> <键>` 行进 stdout；退出码 0/1/2（TestStubScanRun 先例） |
| 脚本侧（人管） | `scripts/swf-inventory.py`（或其后置步骤） | 生成产物先写临时文件 → 调 runner → 写回 spec 路径——**不在 agent 边界内**，接线由所有者落地 |
| CI 侧（人管） | `.github/workflows/legacy-decompile.yml` | 补装 haxe + merge 运行步——**不在 agent 边界内** |

**改判式只能改 Haxe 半边**，且必须与测试同改（#63 判式单源教训）。机器键
闭集 `MACHINE_KEYS`（path/bytes/category/fps/frames/stage/unparsed）写死在
merge 类里，对账判式**引用**它的 `isHandwrittenKey` 不复制闭集（判式单源
只有一份）。

### 接线证据判式（#95，agent 可写侧已交付的部分）

人管两侧的接线没落地前，`SwfInventoryReconcile.workflowKeepsHandwritten` 喂
仓内真实两份文本必红（`wiring_missing`）——这是有意的活体锚点：判式查两份
文本里有没有 `tools.SwfInventoryMergeRun` 的调用痕迹（写死的锚串，接线形态
变了同改判式与测试）。**人管接线落地后该断言翻绿**，不需要改测试。脚本侧
裸奔面（`json.dump` 直写 spec 路径）与工作流侧裸奔面（没装 haxe 步）各算
一条缺口——半接线等于没接线。

## 核心语义（判式一句话版）

- **手写键 = 条目键集减机器键闭集**（逐字、大小写不折叠）——不是 code 白
  名单，未来新形态手写键不需要改判式。
- **配对键是 path**（清单内唯一）；新清单里同 path 条目还在 → 手写键值
  逐字搬入；条目消失 → 手写块随条目消失，**不跨 path 搬迁**。
- **机器面永远以新生成为准**（bytes 漂移、条目增删、排序、顶层三键），
  手写面只进条目不进顶层。
- 输出逐字节对齐 `json.dump(indent=1, ensure_ascii=False)` 形态（6290 条
  实文件零 diff 验证过），两次连续 merge 幂等。
- 异常语义：`generatedText` 形状不符**抛异常**（生成器坏了不得静默产出
  绿文件）；`oldText` 形状不符按空手写面处理（首次生成/损坏不阻塞）。

## 实现的关键坑（为什么不能直接用 haxe.Json）

- **parse 丢数字字面形态**：haxe 的 `Json.parse` 把 `25.0` 归一成 25，
  round-trip 无法还原字面。「手写块逐字搬运」的契约过不了 parse。所以
  本类用**位置扫描器**（模块内的 `PosScanner`）：parse 只做形状校验，值
  子串一律从原文按位置截取——手写键值从 oldText 截、机器键值从
  generatedText 截，缩进/键序由本类拼。这是逐字与幂等的同时成立的唯一
  途径。
- **typedef 不能写在类体里**（`Expected }` 编译错）——模块内私有类型
  提到顶层、`private typedef`。
- 顶层 `swfs` 之外的键（生成器未来加的）按原插入序透传，尾随逗号只在
  有余键时出现——空数组形态 `"swfs": []` 与 python 同形。

## 机器门面（再生成前后对账，#95）

issue 完成标准要求「死了无人察觉」不再可能。#95 落地后现状：

- merge 判式已被 `test/tools/SwfInventoryMergeTest.hx` 钉死（含在库事实
  锁——七条手写 code 块的内容逐字对账）。
- **runner 已交付**（`tools/tools/SwfInventoryMergeRun.hx`，进程面契约由
  `test/tools/SwfInventoryMergeRunTest.hx` 钉死）：三文件位参、keep 行、
  退出码三态——#83「判式交付、接线悬空」的 tools/ 侧缺口已收口。
- **对账判式已交付**（`tools/tools/SwfInventoryReconcile.hx`）：三个面
  （再生成前后对账/单文件自检/接线静态对账）都是纯逻辑，进程面壳
  （走 exit 码进 checks/）与脚本/工作流接线 edit 都归人管路径。
- **scripts/、checks/、.github/ 的人管接线仍待所有者落地**——在落地前，
  `test_workflow_wiring_absent_on_current_main` 保持红转绿的活体锚点语义
  （见上节）；#95 完成标准「触发一次再生成七条全存活」只能在那之后验证。
