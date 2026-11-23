package module.decorate;

import common.Consts;
import common.misc.Utils;
import framework.base.BaseLayer;
import framework.base.Controller;
import framework.base.Module;
import module.FarmApplication;

/**
 * module.decorate.ModuleDecorate —— ModuleDecorate.as 逐句对应（issue #29
 * 替换闭包 stub）。装饰模块壳：onModuleLoadSuccess 反射外部功能 swf
 * （decorate_v_0）里的 DecorateController 并装配。
 * legacy/decompiled/main3_v_221/scripts/module/decorate/ModuleDecorate.as。
 */
@:keep
class ModuleDecorate extends Module {
	// ModuleDecorate.as:13
	private var _diyCtrl:Controller;

	// ModuleDecorate.as:15-19
	public function new(param1:FarmApplication) {
		super(param1);
		this._reportID = "160593";
	}

	// ModuleDecorate.as:21-30（停网复位：原文只有 `["model"] != null` 单判
	//（AS3 缺 trait 读得 undefined，loose 下 == null 同关），照单判翻译；
	// `["model"]["resetLoadingFlags"]()` 鸭式双下标调用 → Reflect.callMethod）
	override public function onNetRequestStopped():Void {
		if (this._diyCtrl != null) {
			if (Reflect.field(this._diyCtrl, "model") != null) {
				var _locm_:Dynamic = Reflect.field(this._diyCtrl, "model");
				Reflect.callMethod(_locm_, Reflect.field(_locm_, "resetLoadingFlags"), []);
			}
		}
	}

	// ModuleDecorate.as:32-34（空覆写：不调 super.load，_loaded 保持 false）
	override public function load(param1:BaseLayer):Void {}

	// ModuleDecorate.as:36-43（unload 不调 super：_loaded 不复位）
	override public function unload():Void {
		if (this._diyCtrl != null) {
			this._diyCtrl.finalize();
			this._diyCtrl = null;
		}
	}

	// ModuleDecorate.as:45-54
	override private function onModuleLoadSuccess():Void {
		var _loc1_:Class<Dynamic> = Utils.getClass("module.decorate.DecorateController");
		if (_loc1_ != null) {
			// PORT-NOTE: 原版经反射装配外部 swf（decorate_v_0）里的控制器。
			// #38 翻译后控制器已编进本工程（SymbolClass.dceAnchor 锚住防
			// 裁剪），非 eval 目标 resolve 成功、装配链走通；eval（test.hxml
			// 无 -lib swf）保持恒 null——单测以 getClass 失败为前提。
			this._diyCtrl = Type.createInstance(_loc1_, []);
			this._diyCtrl.module = this;
			this._diyCtrl.initialze();
		}
	}

	// 原版 override get name
	override private function get_name():String {
		return Consts.MODULE_DIY;
	}
}
