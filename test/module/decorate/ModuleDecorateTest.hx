package module.decorate;

import common.Consts;
import module.FarmApplication;
import utest.Assert;

/**
 * ModuleDecorate 模块壳纯逻辑（issue #29）：壳语义 + onModuleLoadSuccess
 * 反射失败分支。
 *
 * 出处：
 * - legacy/decompiled/main3_v_221/scripts/module/decorate/ModuleDecorate.as
 *   （:13 _diyCtrl、ctor 置 _reportID="160593"、空 load 覆写、unload 不调
 *   super、onModuleLoadSuccess 反射 "module.decorate.DecorateController"、
 *   name "Decorate Module"）
 * - name 与 nc_main.php:17-23 moduleList 的键一致
 *   （Decorate Module→decorate_v_0）。
 *
 * 反射失败分支同 ModuleShopTest：openfl 不执行外部 swf 的 AS3（probe
 * 验证 getClass("module.decorate.DecorateController") 恒 null），照译解析
 * 失败分支即 _diyCtrl 保持 null（后续「功能 swf 翻译」批次的接入点）。
 * stub 阶段失败点：_reportID 未置（null ≠ "160593"）。
 */
@:access(framework.base.Module)
@:access(module.decorate.ModuleDecorate)
class ModuleDecorateTest {
	public function new() {}

	public function test_shell_name_report_id_and_reflection_null_branch() {
		var app = new FarmApplication();
		var decorate = new ModuleDecorate(app);
		// ModuleDecorate.as name override（= Consts.hx:55 "Decorate Module"）
		Assert.equals(Consts.MODULE_DIY, decorate.name);
		// ModuleDecorate.as ctor 落 "160593"
		Assert.equals("160593", decorate._reportID);
		// onModuleLoadSuccess：getClass("module.decorate.DecorateController")
		// 在 openfl 下必 null → 失败分支 ctrl 保持 null
		decorate.onModuleLoadSuccess();
		Assert.isNull(decorate._diyCtrl);
	}

	public function test_load_is_empty_override_and_unload_keeps_loaded() {
		var app = new FarmApplication();
		var decorate = new ModuleDecorate(app);
		// 空 load 覆写：不落基类 Module.as:175-181 的 _loaded=true
		decorate.load(null);
		Assert.isFalse(decorate.loaded);
		// unload 覆写不调 super：基类 Module.as:187-189 的复位不执行
		decorate._loaded = true;
		decorate.unload();
		Assert.isTrue(decorate.loaded);
		// onNetRequestStopped（null 控制器下的防护分支，不崩即可）
		decorate.onNetRequestStopped();
	}
}
