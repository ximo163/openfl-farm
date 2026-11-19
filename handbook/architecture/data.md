# 数据层

会话与全局数据。#7（V3a）翻译时核实。

- `Session`（`src/common/Session.hx` ← `common/Session.as`）：会话状态。
  成员多经 `m_app.model.getData/setData` 存取（如 `myFairy` =
  `getData(Consts.MY_FAIRY_OBJECT)`，Session.as:94-96，写入侧是
  Main/FarmApplication 的 `model.setData`）；`expFullToday` 带 Cookies
  持久化（Session.as:171-178 setter 值变更写 cookie、:455-471 getter 为
  false 时回读）。
- `Model` + `Consts`：全局键值仓，启动数据与跨模块状态都走这里。
- `FarmLandModel`（`src/module/mainScene/farmLand/`，1744 行）：农田数据层
  ——地块状态、作物生长。V3a 完成数据层；渲染视图（FarmLandsView、
  LandTile 等）是 V3b（issue #8）的活。
- 数据来源：启动时 PHP 下发（user_run / nc_main 等）。真后端载荷样例在
  `legacy/snapshot/`；`test/fixtures/uid1_user_run.json` 是抽出来的真实
  样例。
