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
  表驱动测试 `test/common/GetCropIDTest.hx`（注册行已由 write-tests 阶段落进 TestMain.hx；implement 阶段不能动
  TestMain，见 lessons 对应条目）。
- `FarmLandModel`（`src/module/mainScene/farmLand/`，1744 行）：农田数据层
  ——地块状态、作物生长。V3a 完成数据层；渲染视图（FarmLandsView、
  LandTile 等）V3b（#8）已完成，见 [farmscene.md](farmscene.md)。
- `Player`（`src/entities/Player.hx` ← `entities/Player.as` 169 行）：用户
  实体。V3a 落字段与 fid/exportObject，V3b（#8）补齐
  ctor/importObject/level/clone。`importObject` 逐键映射 user 下发块
  （数值走 `Utils.getIntAttribute`、money 原版裸 parseFloat → `As3.floatOf`；
  `!= undefined` 一律 `hasField`+非 null 双守卫）；`level =
  expToGrade(exp)`（`sqrt((exp+25)/100)-0.5`，返回处隐式 Number→int
  截断用 `Std.int` 复刻）；`fid` 按宿主 `Settings.mode`（qzone/qplus 取
  uin，否则 _uId）——animalAttack/checkWildDataStatus 跨牧场用；`clone`
  不带 _levelup/_fb/_rawData，_healthMode 经 ObjectUtil.clone 的 AMF 往返
  恒 null（原版行为如此，lessons 有条目，照抄别修）。类头逐字段显式落
  AS3 默认值是 eval/js 未赋值基元为 null 的补偿，别「顺手删」。
  测试 `test/entities/PlayerTest.hx`。
- `PoolFish`（`src/entities/PoolFish.hx` ← `entities/PoolFish.as` 272 行，
  #29 整类翻译）：鱼塘格位鱼实体。importObject 逐键映射 cgi_fish_index
  状态（i/fid/l/o/p 数值走 `Utils.getIntAttribute`，`s as Array` 单调进
  局部过类型门、同引用不拷贝），ctor 末尾清 _st/_cycles 复刻原版
  「构造时懒查、留 null」的时序。等级/剩余时间按 fish_info 行的 `cycle`
  逗号段推导：`level` = elapsed 落第几段（越界 = 段数 = FISH_MAX_LEVEL=3、
  elapsed<0 = -1），`canHarvest = level >= FISH_MAX_LEVEL`——**uint 常量
  比较 Haxe 是无符号域**（-1 恒真），比较点 `(Consts.FISH_MAX_LEVEL:Int)`
  显式回 Int 复刻 AS3 Number 域（lessons #29 条目）。`min = ceil(output*0.6)`
  （缺 output 回查配置行）。`leftTime` 返回 `[剩余, 段长]` 双元素数组
  （首段段长取段原值、其余取相邻差）。测试
  `test/entities/PoolFishTest.hx`（FakeConfigModel 注入 fish_info 行）。
- 数据来源：启动时 PHP 下发（user_run / nc_main 等）。真后端载荷样例在
  `legacy/snapshot/`；`test/fixtures/uid1_user_run.json` 是抽出来的真实
  样例。
