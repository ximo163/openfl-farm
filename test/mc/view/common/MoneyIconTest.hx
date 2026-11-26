package mc.view.common;

import mc.view.common.MoneyIcon;
import utest.Assert;

/**
 * mc.view.common.MoneyIcon 纯逻辑（issue #87 write-tests，对 stub 失败）：
 * 币种图标的类型门面——常量面值、构造分型（X 直写不装素材）、type
 * setter 的 _type==X 补装门。
 *
 * 期望值出处：legacy/decompiled/Master2_v_142/scripts/mc/view/common/MoneyIcon.as
 * —— 常量 :9-15（GOLD "gold"、FB "fb"、X "unknown"、RP "rp"）；
 * 构造 :19-28（param1 == X 时 _type 直写 param1 并 return——不进
 * setIconType、不装素材；其余走 setIconType）；set type :30-36（仅
 * _type == X 时才调 setIconType(param1)——非 X 型构造后再 set type
 * 是静默无操作）；setIconType :38-57（GOLD 装 "GoldIcon" :44-47、FB 装
 * "QB" :48-51、RP 装 "RPIcon" :52-55，其余型三分支全不落、零装载——
 * 但 _type 无条件覆写 param1 :56）；get type :59-62（backing 直返）。
 *
 * 单测环境约束（重要）：GOLD/FB/RP 三分支的 addChild(MaterialLib…
 * getMaterial()) 在素材表为空时 addChild(null)——openfl eval 抛
 * Error #2007（实测）。原版生产环境素材先行装载、该路径永不 null，
 * 单测环境无法满足此前置——故 gold/fb/rp 构造面不在单测钉（显示层
 * 归 CI 画面比对）。改用未识别型（"diamond"）钉同一代码路径：三分支
 * 全不落 → 零 addChild → 不触素材通道，但 :56 的 _type 无条件覆写、
 * :22/:32 的 X 门判逻辑逐字同源。stub 期 ctor/setter 全 throw
 * not implemented——本测试必然等 implement 充真身才绿。
 */
class MoneyIconTest {
	public function new() {}

	// 常量面值（MoneyIcon.as:9-15）
	public function test_constants() {
		Assert.equals("gold", MoneyIcon.GOLD);
		Assert.equals("fb", MoneyIcon.FB);
		Assert.equals("unknown", MoneyIcon.X);
		Assert.equals("rp", MoneyIcon.RP);
	}

	// 构造 X（:22-25 直写分支）→ type "unknown"；不进 setIconType——
	// 零素材装载（此路径不触 MaterialLib，单测环境可绿）
	public function test_ctor_unknown_type() {
		var icon = new MoneyIcon("unknown");
		Assert.equals("unknown", icon.type);
	}

	// 构造缺省参数是 "gold"（:19 `param1:String = "gold"`）——缺省即
	// 触素材通道，单测环境钉不了实例；参数缺省值本身由源码行备录。
	// （实例面归 CI）

	// 未识别型构造（:38-57 三分支全不落、:56 无条件覆写）：type 原样
	// 回读——"diamond" 非 GOLD/FB/RP/X，setIconType 跑完全程但不装
	// 任何子件，_type 落 "diamond"。此钉同时覆盖 :27 的非 X 构造进
	// setIconType 路径（与 gold 构造同一通路，仅省去素材行）。
	public function test_ctor_unrecognized_type_passes_through() {
		var icon = new MoneyIcon("diamond");
		Assert.equals("diamond", icon.type);
	}

	// type setter 的 X 门正向（:30-36）：X 型构造后 set type 补装——
	// setIconType(param1) 跑、:56 _type 覆写。用未识别型避免素材通道：
	// MoneyIcon(X).type = "diamond" → _type 从 "unknown" 变 "diamond"
	// ——证明 setter 确实进了 setIconType（无操作时 _type 应停 "unknown"）
	public function test_type_setter_reloads_when_unknown() {
		var icon = new MoneyIcon("unknown");
		icon.type = "diamond";
		Assert.equals("diamond", icon.type);
	}

	// X 门反向（:32 条件不成立）：非 X 型构造后 set type 静默无操作——
	// MoneyIcon("diamond").type = "gold" → _type != X → 不进
	// setIconType → type 停 "diamond"（若误进则 :56 会覆写为 "gold"）
	public function test_type_setter_noop_when_already_typed() {
		var icon = new MoneyIcon("diamond");
		icon.type = "gold";
		Assert.equals("diamond", icon.type);
	}

	// X 补装一次性（:30-36 + :56 联合语义）：X → set "diamond" 后
	// _type 已非 X——再 set 即入无操作分支，type 停首装值
	public function test_type_setter_one_shot() {
		var icon = new MoneyIcon("unknown");
		icon.type = "diamond";
		icon.type = "emerald";
		Assert.equals("diamond", icon.type);
	}

	// X 型再 set X（边界）：_type == X 成立 → 进 setIconType("unknown")
	// ——"unknown" 也非 GOLD/FB/RP 三分支 → 零装载但 :56 覆写（值不变）。
	// type 仍 "unknown"。此钉证明 X 门的判据是 _type 值而非「是否装过」
	public function test_type_setter_unknown_to_unknown() {
		var icon = new MoneyIcon("unknown");
		icon.type = "unknown";
		Assert.equals("unknown", icon.type);
	}
}
