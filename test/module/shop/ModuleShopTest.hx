package module.shop;

import common.Consts;
import module.FarmApplication;
import utest.Assert;

/**
 * ModuleShop 模块壳纯逻辑（issue #29）：壳语义 + onModuleLoadSuccess 反射
 * 失败分支。
 *
 * 出处：
 * - legacy/decompiled/main3_v_221/scripts/module/shop/ModuleShop.as
 *   （:13 _shopCtrl、:15-19 ctor 置 _reportID="160591"、:21-30
 *   onNetRequestStopped、:32-34 空 load、:36-43 unload 不调 super、
 *   :45-54 onModuleLoadSuccess 反射 "module.shop.ShopController"、:56-58
 *   name "Shop Module"）
 * - name 与 nc_main.php:17-23 moduleList 的键一致（Shop Module→shop_v_7）。
 *
 * 反射失败分支：onModuleLoadSuccess 经 Utils.getClass("module.shop.
 * ShopController") 找功能 swf 里的控制器类——openfl 不执行外部 swf 的
 * AS3（probe 验证 eval 上 hasDefinition 恒 false → getClass null），
 * 照译解析失败分支即 _shopCtrl 保持 null。这是后续「功能 swf 翻译」
 * 批次的接入点，本测试把该分支钉死（ctrl null 不崩、字段保持 null）。
 * stub 阶段失败点：_reportID 未置（null ≠ "160591"）。
 */
@:access(framework.base.Module)
@:access(module.shop.ModuleShop)
class ModuleShopTest {
	public function new() {}

	public function test_shell_name_report_id_and_reflection_null_branch() {
		var app = new FarmApplication();
		var shop = new ModuleShop(app);
		// ModuleShop.as:56-58（= Consts.hx:54 "Shop Module"）
		Assert.equals(Consts.MODULE_SHOP, shop.name);
		// ModuleShop.as:17（ctor :15-19 落 "160591"）
		Assert.equals("160591", shop._reportID);
		// ModuleShop.as:45-54：getClass("module.shop.ShopController") 在
		// openfl 下必 null（外部 swf AS3 不执行）→ 失败分支 ctrl 保持 null
		shop.onModuleLoadSuccess();
		Assert.isNull(shop._shopCtrl);
	}

	public function test_load_is_empty_override_and_unload_keeps_loaded() {
		var app = new FarmApplication();
		var shop = new ModuleShop(app);
		// ModuleShop.as:32-34 空 load 覆写：不落基类 Module.as:175-181 的
		// _loaded=true → load 后仍 false
		shop.load(null);
		Assert.isFalse(shop.loaded);
		// ModuleShop.as:36-43 unload 覆写不调 super：基类 Module.as:187-189
		// 的 _loaded=false 不执行 → 保持 true
		shop._loaded = true;
		shop.unload();
		Assert.isTrue(shop.loaded);
		// ModuleShop.as:21-30（null 控制器下的防护分支，不崩即可）
		shop.onNetRequestStopped();
	}
}
