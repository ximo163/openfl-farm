package module.water;

import common.Consts;
import common.misc.Utils;
import events.CommonEvent;
import module.FarmApplication;
import utest.Assert;

/**
 * ModuleWater 模块壳纯逻辑（issue #29）：壳语义 + 反射接入点 + onZoom
 * 空事件/空 data/空控制器三防护。
 *
 * 出处：
 * - legacy/decompiled/main3_v_221/scripts/module/water/ModuleWater.as
 *   （:16 _waterCtrl、ctor :20-26 置 _reportID="160619" 并收听
 *   Consts.MSG_ZOOM（addEventListener(…, onZoom, false, 0, true)）、
 *   :103-117 onZoom `if(param1==null||param1.data==null)return;` +
 *   仅控制器非空才 switchMode、onModuleLoadSuccess 反射
 *   "module.water.WaterController" 且 `Cookies.Get("bigmode")=="1"`
 *   只在控制器非空分支内、name "Water Pool Module"）
 * - name 与 nc_main.php:17-23 moduleList 的键一致
 *   （Water Pool Module→pool_v_13）。
 * - issue #37：pool_v_13 真身化后 "module.water.WaterController" 反射
 *   解析到真身类（onModuleLoadSuccess 的装配串）。
 *
 * onZoom 防护分支用直调收听器的方式钉（ctor 的 addEventListener 是显示
 * 事件面，由 web-smoke 覆盖；本测试不依赖 ctor 挂线）。
 * changed for #37: 原第三测断言「onModuleLoadSuccess 后 _waterCtrl 仍
 * null」，前提是 #29 时外部 swf 的 AS3 在 openfl 不执行、getClass 恒
 * null（ModuleShopTest 的前提）。#37 真身化后 getClass 解析成功，
 * onModuleLoadSuccess 会真装配（createInstance → initialze →
 * onInitialized(null)（WaterController.as:396 原文如此）→ loadFishes），
 * 那条链要 Session/网络/farmView 运行环境，纯逻辑单测承载不了；legacy
 * 真行为是装配成功（onModuleLoadSuccess 以 RSL 加载成功为前提），由
 * web-smoke 覆盖。这里改为钉反射串一字不差地解析到真身类。
 */
@:access(framework.base.Module)
@:access(module.water.ModuleWater)
class ModuleWaterTest {
	public function new() {}

	// changed for #37: 原名 …_reflection_null_branch，断言 onModuleLoadSuccess
	// 后 _waterCtrl 仍 null（前提已死，见文件头）。现钉 #37 接入点：
	// ModuleWater.as:83 的反射串一字不差地解析到真身类。直接引用类型作
	// 编译锚：eval 上 dceAnchor 是 #if !eval，类经 FishMover→WaterPool 链
	// 才进类型表，锚在测试里本断言才不依赖其它测试文件的存在
	public function test_shell_name_report_id_and_reflection_resolves_controller() {
		var app = new FarmApplication();
		var water = new ModuleWater(app);
		// ModuleWater.as name override（= Consts.hx:58 "Water Pool Module"）
		Assert.equals(Consts.MODULE_WATER, water.name);
		// ModuleWater.as:24（ctor :20-26 落 "160619"）
		Assert.equals("160619", water._reportID);
		// ModuleWater.as:83 反射串 ↔ 真身类（#37 翻译的 pool_v_13）
		var expected:Class<Dynamic> = module.water.WaterController;
		Assert.equals(expected, Utils.getClass("module.water.WaterController"));
	}

	public function test_load_is_empty_override_and_unload_keeps_loaded() {
		var app = new FarmApplication();
		var water = new ModuleWater(app);
		// 空 load 覆写：不落基类 Module.as:175-181 的 _loaded=true
		water.load(null);
		Assert.isFalse(water.loaded);
		// unload 覆写不调 super：基类 Module.as:187-189 的复位不执行
		water._loaded = true;
		water.unload();
		Assert.isTrue(water.loaded);
		// onNetRequestStopped（null 控制器下的防护分支，不崩即可）
		water.onNetRequestStopped();
	}

	// ModuleWater.as:103-117：`if(param1==null||param1.data==null)return;`
	// 三种「不该动」的形态——空事件、非空事件但 data null、data 非空但
	// 控制器 null（反射失败分支下 MSG_ZOOM 到达时正如此）——都只早退不崩。
	// 真正的 switchMode 只在 ctrl 非空时走（swf 翻译批次接入后另测）。
	public function test_onZoom_null_guards_do_nothing_without_controller() {
		var app = new FarmApplication();
		var water = new ModuleWater(app);
		// 空事件早退
		water.onZoom(null);
		// data null 早退（Consts.hx:77 MSG_ZOOM "ZoomInOut"）
		water.onZoom(new CommonEvent(Consts.MSG_ZOOM, null));
		// data 非空但 _waterCtrl null（反射失败分支形态）→ 只是不进
		// switchMode，不崩
		water.onZoom(new CommonEvent(Consts.MSG_ZOOM, true));
		Assert.isNull(water._waterCtrl); // 早退路径不该把 null 洗成别的
		Assert.isTrue(true); // 到这里即三分支都不崩
	}
}
