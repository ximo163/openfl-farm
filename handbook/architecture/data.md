# 数据层

会话与全局数据。#7（V3a）翻译时核实。

- `Session`（`src/common/Session.hx` ← `common/Session.as`）：会话状态。
  成员多经 `m_app.model.getData/setData` 存取（如 `myFairy` =
  `getData(Consts.MY_FAIRY_OBJECT)`，Session.as:94-96，写入侧是
  Main/FarmApplication 的 `model.setData`）；`expFullToday` 带 Cookies
  持久化（Session.as:171-178 setter 值变更写 cookie、:455-471 getter 为
  false 时回读）。
- `Model` + `Consts`：全局键值仓，启动数据与跨模块状态都走这里。
- `GetCropID.idState/timeToMature`（`src/common/GetCropID.hx`，#8 review
  round 1 补齐；整类 772 loc 仍按闭包规则只翻本片用到的成员）：作物生长
  档的唯一运行时来源——FarmLand 导入时算 `_step`、growLoop 推进、
  countNoneMatureLands 的剩余小时全走它。档位表 = crops 配置的 `cropGrow`
  逗号串（与 `legacy/deploy/.../nc/cropstime.php` 同值），从高往低首个
  `elapsed >= 档` 命中档 +1；红土地（bitmap 2）非红作物档位 *0.8、末两档
  再削 %600 余数，`isRed` 有数值/字符串双形态（松等一律 `As3.eqString`）；
  收获过（harvestTimes>0）的低于 3 档显示抬 3。时钟双源：
  `CommonData.serverTime`（真值判定，0 视为未设）回退 `StartupData.serverTime`。
  **getCropByID 有 `theApp == null` 补判**（原版该状态 NPE、生产不可达——
  Main 启动先设置 theApp；单测进程不跑 Main，已过测试的期望就是「无 app
  数据 → null/-1」），属 deviations 候选，见 lessons #8 对应条目。纯逻辑
  表驱动测试 `test/common/GetCropIDTest.hx`（**尚未注册**，同
  SceneDecorLibrariesTest 的 append-only 情形，注册行留给 write-tests）。
- `FarmLandModel`（`src/module/mainScene/farmLand/`，1744 行）：农田数据层
  ——地块状态、作物生长。V3a 完成数据层；渲染视图（FarmLandsView、
  LandTile 等）V3b（#8）已完成，见 [farmscene.md](farmscene.md)。
- 数据来源：启动时 PHP 下发（user_run / nc_main 等）。真后端载荷样例在
  `legacy/snapshot/`；`test/fixtures/uid1_user_run.json` 是抽出来的真实
  样例。
