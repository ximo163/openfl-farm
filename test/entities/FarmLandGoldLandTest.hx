package entities;

import common.CommonData;
import common.Settings;
import shim.As3;
import utest.Assert;

/**
 * FarmLand._goldLand 计算属性（issue #7 implement 追加，钉原版语义）。
 *
 * 出处：
 * - legacy/decompiled/main3_v_221/scripts/entities/FarmLand.as:224-245 ——
 *   get _goldLand 读 Settings 的 jinPaiLand（"起-止"日期串），serverTime 落在
 *   窗口内且原始 goldLand==1 才返回 1，否则 0；:47 `private var goldLand:int`
 *   是 setter（:247-250）写入的原始值，读永远走窗口计算；
 * - legacy/deploy/QFarmFlash/source/core/source/xml/mod/nc_addon.php:113 ——
 *   真实配置 `<jinPaiLand>7/10/2012-11/12/2012 23:59:59</jinPaiLand>`（美式
 *   m/d/Y[ H:M:S]，AS3 `new Date(字符串)` 解析 → As3.dateOf）；
 * - Settings.as:360-374 —— getStringAttribute 从 m_params（页面参数池）取，
 *   未配置返回 ""（if("") 为假 → 窗口不成立 → 恒 0）。
 *
 * 与 FarmLandModelTest 里把 `_goldLand` 当原始存储读的 5 条断言（isAllGoldLand
 * 的 1/3 两态、updateLandData 的 3 条回读）互斥：那些期望值在未配置 jinPaiLand
 * 的测试环境下与 FarmLand.as:224-245 推出的行为相悖（恒 0），按流程走
 * NEEDS-TESTS，本文件钉住原版行为供测试修正轮参考。
 */
@:access(common.Settings.m_params)
class FarmLandGoldLandTest {
	public function new() {}

	// 临时钉住 Settings 页面参数与服务器时间，结束后（含异常路径）还原，
	// 不污染后续用例共享的单例
	static function withEnv(params:Dynamic, serverTime:Float, body:Void->Void):Void {
		var settings = Settings.getInstance();
		var savedParams:Dynamic = settings.m_params;
		var savedTime:Float = CommonData.serverTime;
		settings.m_params = params;
		CommonData.serverTime = serverTime;
		var done = false;
		try {
			body();
			done = true;
		} catch (e:Dynamic) {
			settings.m_params = savedParams;
			CommonData.serverTime = savedTime;
			throw e;
		}
		if (done) {
			settings.m_params = savedParams;
			CommonData.serverTime = savedTime;
		}
	}

	// 未配置 jinPaiLand：getter 恒 0（:226-227 if("") 假 → :245 return 0），
	// 即使 setter 已把原始值写成 1
	public function test_goldLand_getter_returns_zero_when_settings_unset() {
		withEnv(null, CommonData.serverTime, function():Void {
			var land = new FarmLand({});
			land._goldLand = 1; // setter 写原始 goldLand=1（:247-250）
			Assert.equals(0, land._goldLand); // 读走窗口（:224-245）→ 未配置恒 0
		});
	}

	// 真实配置窗口 + serverTime 落在窗内：raw 1 → 1、raw 0 → 0（:233-244）
	public function test_goldLand_getter_gated_by_jinPaiLand_activity_window() {
		withEnv({"jinPaiLand": "7/10/2012-11/12/2012 23:59:59"}, 1343798400, function():Void {
			var gold = new FarmLand({});
			gold._goldLand = 1;
			Assert.equals(1, gold._goldLand); // 窗内 + raw==1（nc_addon.php:113 窗口）

			var normal = new FarmLand({});
			normal._goldLand = 0;
			Assert.equals(0, normal._goldLand);
		});
	}

	// 窗口配置了但 serverTime 在窗外（:239 两个比较任一不成立）→ 0
	public function test_goldLand_getter_zero_outside_window() {
		withEnv({"jinPaiLand": "7/10/2012-11/12/2012 23:59:59"}, 1000000000, function():Void {
			var land = new FarmLand({});
			land._goldLand = 1;
			Assert.equals(0, land._goldLand); // 2001-09-09 在 2012 窗口外
		});
	}

	// As3.dateOf（shim/As3.hx）：AS3 `new Date(串)` 解析失败 → Invalid Date
	//（time=NaN，比较恒 false）；shim 契约为 null，调用方跳过窗口
	public function test_as3_dateOf_rejects_non_date_strings() {
		Assert.equals(null, As3.dateOf("garbage"));
		Assert.equals(null, As3.dateOf("7/10"));
		Assert.equals(null, As3.dateOf(null));
	}
}
