package;

import common.Settings;
import utest.Assert;

/**
 * 预加载器加载链路的纯逻辑状态门（issue #3）：useflag 引导开关、_bootData/_mainXML
 * 双条件门。
 *
 * 出处：
 * - legacy/decompiled/happyfarm3_v_149/scripts/FarmLite.as:448-453 openByFlashVar
 * - legacy/decompiled/happyfarm3_v_149/scripts/FarmLite.as:380-387 checkStart
 * - legacy/deploy/QFarmFlash/source/core/view/qf_default/nc.htm:87 useflag="11111111"
 *
 * FarmLite 是 Sprite 子类，构造器要 stage/loaderInfo（FarmLite.as:62-78），
 * 单测用 Type.createEmptyInstance 绕过构造器、只驱动纯逻辑方法——不碰显示对象、
 * 不联网。_mainXML 的赋值走 Reflect.setField：原版类型是 AS3 E4H XML，Haxe 侧
 * 映射未定（openfl 无 openfl.xml），checkStart 只判非空，不绑死具体类型。
 */
@:access(FarmLite)
class FarmLiteTest {
	public function new() {}

	// FarmLite.as:448-453：openByFlashVar = !(parseInt(useflag)/1000%10)——
	// useflag 千位（10^3，左起第 5 位）数字为 0、或整个串解析为 NaN 时返回 true；
	// boot()（FarmLite.as:337-341）随即显示 index_tips 并 return，不进加载链路。
	public function test_open_by_flashvar_blocks_boot_when_useflag_thousands_digit_is_zero() {
		var cases:Array<{vars:Dynamic, expected:Bool}> = [
			{vars: {"useflag": "11111111"}, expected: false}, // nc.htm:87 的线上值：千位 1，放行
			{vars: {}, expected: true}, // 缺项 → ""（Settings.as:366-371）→ parseInt NaN → 0
			{vars: {"useflag": ""}, expected: true}, // 同上，空串也是 NaN
			{vars: {"useflag": "abc"}, expected: true}, // 非数字同样 NaN → 0
			{vars: {"useflag": "11110111"}, expected: true}, // 千位 0：拦截
			{vars: {"useflag": "11112111"}, expected: false} // 千位 2：放行
		];
		for (c in cases) {
			Settings.getInstance().loadLocalSettings(c.vars);
			var lite = Type.createEmptyInstance(FarmLite);
			Assert.equals(c.expected, lite.openByFlashVar(), 'vars=${c.vars}');
		}
	}

	// FarmLite.as:380-387 checkStart：_bootData（onIndexPageSuccess:89 解析的 CGI
	// 数据，:108 回调触发）与 _mainXML（onFilesLoadCompleted:177 解析的主配置，
	// :187 回调触发）都到位才 startLiteUI（:384）；只到一步不启动。
	public function test_check_start_starts_only_when_both_bootdata_and_mainxml_present() {
		var cases:Array<{boot:Bool, xml:Bool, expected:Bool}> = [
			{boot: false, xml: false, expected: false},
			{boot: true, xml: false, expected: false}, // CGI 先回来
			{boot: false, xml: true, expected: false}, // 主配置先解析完
			{boot: true, xml: true, expected: true}
		];
		for (c in cases) {
			var probe = Type.createEmptyInstance(FarmLiteCheckStartProbe);
			probe.started = false; // createEmptyInstance 不跑字段初始化器，先归位
			if (c.boot) {
				probe._bootData = {}; // farmJson 的占位：门只判 != null
			}
			if (c.xml) {
				Reflect.setField(probe, "_mainXML", Xml.parse("<moduleList/>"));
			}
			probe.checkStart();
			Assert.equals(c.expected, probe.started, 'boot=${c.boot} xml=${c.xml}');
		}
	}
}

// 只记录 checkStart 是否放行到 startLiteUI（FarmLite.as:384）。
// startLiteUI 本体是显示+加载（removeChild/FarmLiteModel/CmdLoadFile，
// FarmLite.as:127-152），单测里用 override 记录调用、不跑原实现。
class FarmLiteCheckStartProbe extends FarmLite {
	public var started:Bool;

	override private function startLiteUI():Void {
		started = true;
	}
}
