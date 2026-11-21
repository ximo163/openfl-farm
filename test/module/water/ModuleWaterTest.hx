package module.water;

import common.Consts;
import events.CommonEvent;
import module.FarmApplication;
import utest.Assert;

/**
 * ModuleWater 模块壳纯逻辑（issue #29）：壳语义 + onModuleLoadSuccess 反射
 * 失败分支 + onZoom 空事件/空 data/空控制器三防护。
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
 *
 * onZoom 防护分支用直调收听器的方式钉（ctor 的 addEventListener 是显示
 * 事件面，由 web-smoke 覆盖；本测试不依赖 ctor 挂线）。反射失败分支同
 * ModuleShopTest：openfl 下 getClass 恒 null（probe 验证）。
 * stub 阶段失败点：_reportID 未置；onZoom 为 throw stub（任一调用即失败）。
 */
@:access(framework.base.Module)
@:access(module.water.ModuleWater)
class ModuleWaterTest {
	public function new() {}

	public function test_shell_name_report_id_and_reflection_null_branch() {
		var app = new FarmApplication();
		var water = new ModuleWater(app);
		// ModuleWater.as name override（= Consts.hx:58 "Water Pool Module"）
		Assert.equals(Consts.MODULE_WATER, water.name);
		// ModuleWater.as:24（ctor :20-26 落 "160619"）
		Assert.equals("160619", water._reportID);
		// onModuleLoadSuccess：getClass("module.water.WaterController")
		// 在 openfl 下必 null → 失败分支 ctrl 保持 null；
		// `Cookies.Get("bigmode")=="1"` 在 ctrl 非空分支内 → 失败分支不触
		water.onModuleLoadSuccess();
		Assert.isNull(water._waterCtrl);
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
