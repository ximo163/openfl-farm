package module.mainScene.background;

import common.Consts;
import common.view.window.BaseWindow;
import entities.DIYDecor;
import entities.Player;
import entities.StartupData;
import events.CommonEvent;
import framework.base.Controller;
import interfaces.IModule;
import interfaces.IMsgCenter;
import openfl.events.Event;
import shim.As3;

/**
 * module.mainScene.background.BackgroundController —— V3b 翻译（issue #8）。
 * 背景控制器（StartupData 装饰下发 → 模型五槽；装饰刷新/预览退回；背景屏
 * 装载与牧场导航）。BackgroundController.as 172 loc 逐句对应。
 * PORT-NOTE(动态取键)：`data["type"]` → As3.intOf(Reflect.field(…))（AS3
 * int() 显式截断）；`m_oldDecorItem["id"] == undefined` → hasField && != null。
 * legacy/decompiled/main3_v_221/scripts/module/mainScene/background/BackgroundController.as
 */
@:keep
class BackgroundController extends Controller {
	// BackgroundController.as:17-21
	private var m_oldDecorItem:Dynamic;

	private var m_previewWindow:BaseWindow;

	private var m_openWarehouse:Bool;

	// BackgroundController.as:23-28
	public function new(param1:IModule) {
		super(param1);
		this.m_oldDecorItem = null;
		this.m_openWarehouse = false;
	}

	// BackgroundController.as:30-37
	private function onGameDataReloaded(param1:CommonEvent):Void {
		this.onStartupData(param1);
		if (this.m_openWarehouse == true) {
			module.app.dispatchEvent(new CommonEvent(Consts.MSG_SHOW_DIY, null));
			this.m_openWarehouse = false;
		}
	}

	// BackgroundController.as:40-43
	public var view(get, never):BackgroundScreen;

	private function get_view():BackgroundScreen {
		if (Std.isOfType(this.m_view, BackgroundScreen)) {
			return cast this.m_view;
		}
		return null;
	}

	// BackgroundController.as:45-57
	private function onStartupData(param1:CommonEvent):Void {
		if (param1 == null || param1.data == null) {
			return;
		}
		var _loc2d:Dynamic = param1.data;
		var _loc2_:StartupData = Std.isOfType(_loc2d, StartupData) ? cast _loc2d : null;
		if (_loc2_ != null) {
			this.model.setDecors(_loc2_._decors);
			this.view.updatePastureBoard();
		}
	}

	// BackgroundController.as:59-68
	private function onRefreshDecorate(param1:CommonEvent):Void {
		if (param1 == null || param1.data == null) {
			return;
		}
		var _loc2_:Int = As3.intOf(Reflect.field(param1.data, "type"));
		var _loc3_:Int = As3.intOf(Reflect.field(param1.data, "id"));
		this.model.changeDecor(_loc3_, _loc2_);
	}

	// BackgroundController.as:70-78
	private function onExitPreview(param1:CommonEvent):Void {
		if (this.m_oldDecorItem == null || !(Reflect.hasField(this.m_oldDecorItem, "id") && Reflect.field(this.m_oldDecorItem,
			"id") != null) || !(Reflect.hasField(this.m_oldDecorItem, "type") && Reflect.field(this.m_oldDecorItem, "type") != null)) {
			return;
		}
		// AS3 把 Object 字段隐式转 int 传参
		this.model.changeDecor(As3.intOf(Reflect.field(this.m_oldDecorItem, "id")), As3.intOf(Reflect.field(this.m_oldDecorItem, "type")));
		this.m_oldDecorItem = null;
	}

	// BackgroundController.as:80-105
	override public function initialze():Void {
		if (this.m_model == null) {
			this.m_model = new BackgroundModel();
		}
		var _loc1d:Dynamic = m_module.app;
		var _loc1_:IMsgCenter = Std.isOfType(_loc1d, IMsgCenter) ? cast _loc1d : null;
		if (_loc1_ != null) {
			_loc1_.addEventListener(Consts.MSG_STARTUP_DATA, this.onStartupData, false, 0, true);
			_loc1_.addEventListener(Consts.MSG_RELOAD_GAME_RESULT, this.onGameDataReloaded, false, 0, true);
			_loc1_.addEventListener(Consts.MSG_CURRENT_USER_CHANGED, this.onCurrentUserChanged, false, 0, true);
			_loc1_.addEventListener(Consts.MSG_ENTER_PREVIEW, this.onEnterPreview, false, 0, true);
			_loc1_.addEventListener(Consts.MSG_EXIT_PREVIEW, this.onExitPreview, false, 0, true);
			_loc1_.addEventListener(Consts.MSG_REFRESH_SCENE, this.onRefreshDecorate, false, 0, true);
			_loc1_.addEventListener(Consts.MSG_OPEN_WAREHOUSE_AFTER_BACK, this.onOpenWarehouseAfterBack, false, 0, true);
		}
		if (this.m_view == null) {
			this.m_view = new BackgroundScreen(this);
			if (this.m_module != null && this.m_module.container != null) {
				this.m_module.container.addChild(this.m_view);
			}
		}
	}

	// BackgroundController.as:107-109
	private function onOpenWarehouseAfterBack(param1:Event):Void {
		this.m_openWarehouse = true;
	}

	// BackgroundController.as:112-129
	private function onEnterPreview(param1:CommonEvent):Void {
		if (param1 == null || param1.data == null) {
			return;
		}
		var _loc2d:Dynamic = param1.data;
		var _loc2_:DIYDecor = Std.isOfType(_loc2d, DIYDecor) ? cast _loc2d : null;
		if (_loc2_ == null) {
			return;
		}
		this.m_oldDecorItem = this.model.changeDecor(_loc2_._id, _loc2_._type);
		if (this.m_previewWindow == null) {
			// 原版 `module.app as IMsgCenter`：类型不符得 null（本文件其余 as 同式）
			this.m_previewWindow = new PreviewDiyWindow(Std.isOfType(module.app, IMsgCenter) ? cast(module.app, IMsgCenter) : null);
		}
		module.app.farmView.winCtrl.open(this.m_previewWindow);
	}

	// BackgroundController.as:131-138
	private function onCurrentUserChanged(param1:CommonEvent):Void {
		this.view.updatePastureBoard();
		var _loc2d:Dynamic = param1.data;
		var _loc2_:Player = Std.isOfType(_loc2d, Player) ? cast _loc2d : null;
		if (_loc2_ != null) {
			this.view.enableBillboard(_loc2_.me == true ? true : false);
		}
	}

	// BackgroundController.as:141-151
	public function switchMode(param1:Bool):Void {
		if (param1 == true) {
			// AS3 连锁赋值 scaleX = scaleY = 1.3 → 拆开
			this.view.scaleX = 1.3;
			this.view.scaleY = 1.3;
		} else {
			this.view.scaleX = 1;
			this.view.scaleY = 1;
		}
	}

	// BackgroundController.as:153-156
	public var model(get, never):BackgroundModel;

	private function get_model():BackgroundModel {
		if (Std.isOfType(this.m_model, BackgroundModel)) {
			return cast this.m_model;
		}
		return null;
	}

	// BackgroundController.as:158-161
	public function openDiyWindow():Void {
		m_module.app.dispatchEvent(new CommonEvent(Consts.MSG_SHOW_DIY, {"openBillBoard": true}));
	}

	// BackgroundController.as:163-169（原版覆写只清 m_model，不调 super——
	// 基类那份会把 m_view/m_module 也清掉，语义不同，照原文不复写）
	override public function finalize():Void {
		if (this.m_model != null) {
			this.m_model = null;
		}
	}
}
