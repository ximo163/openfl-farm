package module.water;

import common.Consts;
import common.misc.Cookies;
import common.misc.Utils;
import events.CommonEvent;
import framework.base.BaseLayer;
import framework.base.Controller;
import framework.base.Module;
import module.FarmApplication;
import openfl.display.MovieClip;
import shim.As3;

/**
 * module.water.ModuleWater —— ModuleWater.as 逐句对应（issue #29 替换闭包
 * stub）。鱼塘模块壳：onModuleLoadSuccess 反射外部功能 swf（pool_v_13）里的
 * WaterController 并装配（bigmode 下 switchMode(true)）；控制器未装时
 * onGameLoop 在场景层放 FarmLoading 占位（装好后移除）。
 * legacy/decompiled/main3_v_221/scripts/module/water/ModuleWater.as。
 */
@:keep
class ModuleWater extends Module {
	// ModuleWater.as:16
	private var _waterCtrl:Controller;

	// ModuleWater.as:18（未装控制器时的加载占位，onModuleLoadSuccess 移除）。
	// PORT-NOTE(shadow): 原文声明 `_loading:MovieClip`，基类 Module 的
	// `_loading:Boolean`（AS3 private）同名异型——AS3 private 不进子类
	// 作用域、两个槽互不相干（本类从未碰基类那份，基类下载流程也没读这份），
	// Haxe 同名异型重定义直接红 → 改名拆槽（lessons #21 同款）
	private var m_loading:MovieClip;

	// ModuleWater.as:20-26
	public function new(param1:FarmApplication) {
		super(param1);
		this._reportID = "160619";
		param1.addEventListener(Consts.MSG_ZOOM, this.onZoom, false, 0, true);
	}

	// ModuleWater.as:28-62（每帧：控制器在位则转发（`["onGameLoop"] !=
	// undefined && != null` 双判（lessons #8），鸭式调用 → Reflect）；不在位
	// 则按需建占位 FarmLoading（web-smoke 里 500ms MSG_LOAD_WATER 派发前、
	// _waterCtrl null 的窗口即走此支）
	override public function onGameLoop(param1:Float):Void {
		if (this._waterCtrl != null) {
			if (Reflect.hasField(this._waterCtrl, "onGameLoop") && Reflect.field(this._waterCtrl, "onGameLoop") != null) {
				Reflect.callMethod(this._waterCtrl, Reflect.field(this._waterCtrl, "onGameLoop"), [param1]);
			}
		} else {
			if (this.m_container == null) {
				this.m_container = app.farmView.getLayerByName(Consts.LAYER_SCENE_CONTENT);
			}
			if (this.m_loading == null) {
				this.m_loading = new FarmLoading();
				this.m_loading.x = 700 + 46;
				this.m_loading.y = 300 + 320;
				this.m_loading.mouseEnabled = false;
				this.m_loading.mouseChildren = false;
				if (Cookies.Get("bigmode") == "1") {
					this.m_loading.x = 1.3 * (700 + 46);
					this.m_loading.y = 1.3 * (300 + 320);
				}
				if (this.m_container != null) {
					this.m_container.addChild(this.m_loading);
				}
			}
		}
	}

	// ModuleWater.as:64-66（空覆写：不调 super.load，_loaded 保持 false）
	override public function load(param1:BaseLayer):Void {}

	// ModuleWater.as:68-74（unload 不调 super：_loaded 不复位）
	override public function unload():Void {
		if (this._waterCtrl != null) {
			this._waterCtrl.finalize();
			this._waterCtrl = null;
		}
	}

	// ModuleWater.as:76-96
	override private function onModuleLoadSuccess():Void {
		var _loc1_:Class<Dynamic> = Utils.getClass("module.water.WaterController");
		if (_loc1_ != null) {
			// PORT-NOTE: 同 ModuleShop——外部 swf（pool_v_13）的 AS3 在
			// openfl 下不执行，getClass 恒 null → _waterCtrl 保持 null（反射
			// 失败即移植终态），「功能 swf 翻译」批次的接入点
			this._waterCtrl = Type.createInstance(_loc1_, []);
			this._waterCtrl.module = this;
			this._waterCtrl.initialze();
			if (Cookies.Get("bigmode") == "1") {
				Reflect.callMethod(this._waterCtrl, Reflect.field(this._waterCtrl, "switchMode"), [true]);
			}
		}
		if (this.m_container != null && this.m_loading != null && this.m_container.contains(this.m_loading) == true) {
			this.m_container.removeChild(this.m_loading);
		}
	}

	// 原版 override get name
	override private function get_name():String {
		return Consts.MODULE_WATER;
	}

	// ModuleWater.as:103-117（MSG_ZOOM 收听器：空事件/空 data 早退，
	// `param1.data as Boolean` 是 AS3 真值转换 → As3.truthy）
	private function onZoom(param1:CommonEvent):Void {
		if (param1 == null || param1.data == null) {
			return;
		}
		var _loc2_:Bool = As3.truthy(param1.data);
		if (this._waterCtrl != null) {
			Reflect.callMethod(this._waterCtrl, Reflect.field(this._waterCtrl, "switchMode"), [_loc2_]);
		}
	}

	// ModuleWater.as:119-127（停网复位：同 ModuleShop 的双判 + 鸭式调用）
	override public function onNetRequestStopped():Void {
		if (this._waterCtrl != null) {
			if (Reflect.hasField(this._waterCtrl, "model") && Reflect.field(this._waterCtrl, "model") != null) {
				var _locm_:Dynamic = Reflect.field(this._waterCtrl, "model");
				Reflect.callMethod(_locm_, Reflect.field(_locm_, "resetLoadingFlags"), []);
			}
		}
	}
}
