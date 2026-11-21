# 场景运行器（对拍工具链）

给下一个 agent / 接线的人：issue #17 T1 的场景运行器怎么用、判定语义是什么、
人工配套（Ruffle 侧执行器 + CI 接线）要对接哪几个点。

## 职责与组成

新版（openfl html5）侧的端到端行为对拍：声明式场景（操作步骤 + 每步检查点）
在构建产物上真跑一遍，录检查点请求序列与界面状态，输出自录基线记录；diff
模式对比两份记录、指出第一处不一致。**不做**渲染比对（那是逐资产/场景比对
门禁的事），也**不含**原版（Ruffle）侧执行器——那在受保护的 `harness/`，
由人配套（见文末）。

| 文件 | 内容 |
|---|---|
| `tools/scenario.mjs` | 运行器本体：`run`（驱动+判定+落盘）与 `diff` 两个子命令；同时作为 nodeboot `--drive` 的驱动模块（文件头注有完整格式契约与判定语义） |
| `tools/scenarios/plant.json` | 种植场景（V3 fixture：进农场→种→浇→收），检查点期望值的 legacy 出处逐条写在 `desc` 字段 |
| `tools/scenarios/plant.record.json` | 自录基线（请求序列快照 + 每步判定与实测状态），diff 模式的基线格式样板 |
| `tools/nodeboot/nodeboot.mjs` | 承载执行器的无头环境；mync 应答按 `fixtures/mync-<mod>-<act>[-<place>].json` 分档（见下） |
| `test/ScenarioRunnerContractTest.hx` | 数据契约门：三份交付物的交叉复验（判定语义的 utest 侧表述，期望值出处逐条在断言消息里） |

## 用法

```sh
node tools/scenario.mjs run tools/scenarios/plant.json     # 跑场景 → plant.record.json，全绿退 0
node tools/scenario.mjs diff a.record.json b.record.json   # 两份记录对比，第一处不一致，同退 0
```

`run` 内部拉起 `node tools/nodeboot/nodeboot.mjs --drive tools/scenario.mjs`：
驱动模块与游戏同进程，从 `shim.Harness` 挂的 `__openflFarmDrive` 句柄拿
stage 与 MouseEvent/KeyboardEvent（构建产物把 Haxe 类关进 lime 的 IIFE，
node 侧只有这个口）。交互派发语义沿用 #9 的 `tools/nodeboot/drive-chain9.mjs`
（地块点击发到底图子节点——捕获监听；工具按钮直点本体；浇水走 keyUp Q），
别改回直点 LandItemRender（lessons #9 的坑）。

**前置**：`export/html5/bin` 得是新鲜产物，且 `assets/legacy/` 已同步
（`bash scripts/sync-legacy-assets.sh`——不入库，新克隆/新容器里没有它，
nodeboot 会 404 到永远不就绪）。

## 判定语义（run 的通过条件）

判定语义两侧同构：驱动内实时判 + run 收尾对落盘记录离线复验
（`judgeRecord`），`test/ScenarioRunnerContractTest.hx` 用同一套语义对交付物
交叉复验。改语义三处一起动。

- 每步期望请求在记录里**按步序出现**（子序列，游标只进不退；步间夹杂的
  启动期请求 user/getNotice、farmlandstatus/getoutput 不影响）；期望参数
  逐键字面相等，body 的公共参数（uIdx/tName/fName）是额外键、不判红。
- 每步期望状态 ⊆ 检查点时刻实测状态（`FarmLandModel.m_farmlandData[place]`
  的 `_cId/_cropStatus/_humidity`，逐字段数值相等）。
- farmlandstatus 操作 act 整份记录恰好场景声明的次数；记录里的 farmlandstatus
  act 只容场景操作 + 启动期 getoutput——出现 scarify 之类 = 运行器多驱动了
  一步，判红。

## 基线格式与两个非显然的约定

格式契约全文在 `tools/scenario.mjs` 文件头注（场景声明 = 判定输入，记录 =
判定输出，键名路径被 ScenarioRunnerContractTest 钉死）。两个约定：

1. **`farmKey`/`farmTime` 不进记录**。farmTime = `CommonData.serverTime` 随
   墙钟走（`CommonData.hx:144-148`；实测 user_run 恒 0、操作请求随引导后
   秒数漂移），farmKey = MD5(farmTime+盐)（`Main.hx:230-236`）。同一次行为
   两次运行必然不同；它们是传输层校验材料不是行为语义。已实测：剥掉后两次
   独立运行字节级一致。**Ruffle 侧导出基线时必须剥同样的两个键**，否则
   跨侧 diff 永远先红在 requests[0].farmTime 上。
2. **mync 应答按 place 分档**（`tools/nodeboot/nodeboot.mjs` 的 mync 分支）：
   真实 PHP 把请求的 place 回显进应答的 farmlandIndex
   （farmlandstatus_planting.php:79、water :65、harvest :94-95），客户端按
   **应答的** farmlandIndex 落地（onOperateSuccessPlant 等）——不分 place 的
   应答会把「种 4 号地」落到 0 号地（实测踩中：land0._step 被重置、后续
   harvest 全灭）。查找序：`mync-<mod>-<act>-<place>.json` →
   `mync-<mod>-<act>.json` → user_run 整包。新场景操作不同地块时补对应
   `-<place>.json` fixture（形状抄同 mod PHP 的 echo 行）。

## 人工配套清单（harness 受保护，不归 agent）

- **Ruffle 侧执行器 + 基线导出**（H4 的一部分）：在原版 swf 上驱动同一份
  场景 JSON，导出同格式 record（requests 的 mod/act/params、steps 的
  name/pass/state；params 剥 farmKey/farmTime；state 侧从原版
  `FarmLandModel.m_farmlandData` 取同名字段）。之后
  `node tools/scenario.mjs diff 新版.record.json 原版.record.json` 即跨侧对拍。
- **CI 接线**：web-smoke 或独立 workflow 里挂 `scenario.mjs run`
  （先 build html5 + sync-legacy-assets，再跑 run，非零退出即红）。
  容器/CI 的 node 均可跑（只用 node 内置模块）。

## 场景编写

加场景 = 新增 `tools/scenarios/<name>.json`（action 词表：`waitForReady`、
`clickLand`+前置 `setCursor`/`keyUp`/`clickTool`，见 scenario.mjs 头注）+
跑 `run` 自录基线。数值期望的出处规则不变（snapshot uid=1 / PHP echo 行 /
spec/protocol.json），`test/ScenarioRunnerContractTest.hx` 只钉 plant 场景，
新场景的门禁按需在 write-tests 阶段补。
