package module.shop;

import common.Consts;
import common.misc.Utils;
import framework.base.BaseLayer;
import framework.base.Controller;
import framework.base.Module;
import module.FarmApplication;

/**
 * module.shop.ModuleShop —— ModuleShop.as 逐句对应（issue #29 替换闭包 stub）。
 * 商店模块壳：onModuleLoadSuccess 反射外部功能 swf（shop_v_7）里的
 * ShopController 并装配；load 空覆写（触发事件到达时由 FarmApplication
 * loadLater 拉起，见 startup :941-942）。
 * legacy/decompiled/main3_v_221/scripts/module/shop/ModuleShop.as。
 */
@:keep
class ModuleShop extends Module {
	// ModuleShop.as:13
	private var _shopCtrl:Controller;

	// ModuleShop.as:15-19
	public function new(param1:FarmApplication) {
		super(param1);
		this._reportID = "160591";
	}

	// ModuleShop.as:21-30（停网复位：`["model"] != undefined && != null`
	// 双判（lessons #8）；`["model"]["resetLoadingFlags"]()` 鸭式双下标
	// 调用 → Reflect.callMethod）
	override public function onNetRequestStopped():Void {
		if (this._shopCtrl != null) {
			if (Reflect.hasField(this._shopCtrl, "model") && Reflect.field(this._shopCtrl, "model") != null) {
				var _locm_:Dynamic = Reflect.field(this._shopCtrl, "model");
				Reflect.callMethod(_locm_, Reflect.field(_locm_, "resetLoadingFlags"), []);
			}
		}
	}

	// ModuleShop.as:32-34（空覆写：不调 super.load，_loaded 保持 false）
	override public function load(param1:BaseLayer):Void {}

	// ModuleShop.as:36-43（unload 不调 super：_loaded 不复位）
	override public function unload():Void {
		if (this._shopCtrl != null) {
			this._shopCtrl.finalize();
			this._shopCtrl = null;
		}
	}

	// ModuleShop.as:45-54
	override private function onModuleLoadSuccess():Void {
		var _loc1_:Class<Dynamic> = Utils.getClass("module.shop.ShopController");
		if (_loc1_ != null) {
			// PORT-NOTE: 原版经 Loader 装载 shop_v_7.swf 后该类定义进
			// ApplicationDomain；openfl 不执行外部 swf 的 AS3，getClass 恒
			// null → 分支不进、_shopCtrl 保持 null——反射失败即移植终态
			//（无发明兜底），「功能 swf 翻译」批次的接入点
			this._shopCtrl = Type.createInstance(_loc1_, []);
			this._shopCtrl.module = this;
			this._shopCtrl.initialze();
		}
	}

	// 原版 override get name
	override private function get_name():String {
		return Consts.MODULE_SHOP;
	}
}
