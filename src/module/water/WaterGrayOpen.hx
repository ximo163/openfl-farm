package module.water;

import common.Consts;
import common.Session;
import common.Settings;
import common.misc.Utils;
import common.view.window.PostWindow;
import events.CommonEvent;
import framework.base.Controller;
import module.GameGuide;
import openfl.display.DisplayObjectContainer;
import openfl.display.Loader;
import openfl.display.MovieClip;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.net.URLRequest;
import shim.LocalSwfLoader;
import shim.NavigateToURL;

/**
 * module.water.WaterGrayOpen —— WaterGrayOpen.as 逐句对应（issue #37 功能
 * swf 翻译：鱼塘 pool_v_13 未开通引导）。flag=true 挂 WaterOpenBoard 开通板
 * （ROLL_OVER/ROLL_OUT 提示按 interaction-map 已有映射照译监听，触摸合成
 * 归 shim 输入适配层）；flag=false 挂 fishNPC swf 的引导 NPC；开通成功
 * （EVENT_WATER_OPENED）弹教程 PostWindow、派 MSG_POOL_OPEN、拆板。
 * navigateToURL → shim（openfl 支持不完整，CLAUDE.md 映射）。
 * PORT-NOTE(load-swf)：fishNPC 的 `new Loader()` → LocalSwfLoader。
 * AS3 internal static const（WaterModel.EVENT_*）→ private，本类 @:access 取。
 */
@:access(module.water.WaterModel)
class WaterGrayOpen {
	// WaterGrayOpen.as:22
	private var _container:DisplayObjectContainer;

	// WaterGrayOpen.as:24
	private var _board:MovieClip;

	// WaterGrayOpen.as:26
	private var _loader:Loader;

	// WaterGrayOpen.as:28
	private var _controller:Controller;

	// WaterGrayOpen.as:30
	private var _tutorial:PostWindow;

	// WaterGrayOpen.as:32-37
	public function new(param1:Controller, param2:DisplayObjectContainer) {
		this._controller = param1;
		this._container = param2;
	}

	// WaterGrayOpen.as:39-42
	private function onNPCRollOver(param1:MouseEvent):Void {
		this._controller.useSystemCursor(true);
	}

	// WaterGrayOpen.as:44-87
	private function onWaterOpened(param1:CommonEvent):Void {
		var _loc2_:String = null;
		var _loc3_:String = null;
		var _loc4_:Dynamic = null;
		param1.target.removeEventListener(WaterModel.EVENT_WATER_OPENED, this.onWaterOpened);
		if (param1.data == null) {
			_loc2_ = Settings.getInstance().getStringAttribute("fishTutorial");
			if (_loc2_ != null && _loc2_ != "") {
				_loc2_ = Settings.getInstance().replaceAppImg(_loc2_);
				if (this._tutorial == null) {
					this._tutorial = new PostWindow(null, "", null, true);
					this._tutorial.title = "池塘成功开启";
					this._tutorial.fixSize = false;
					this._tutorial.imgUrl = _loc2_;
					this._tutorial.closeFn = this.onTutorialClosed;
				}
				this._controller.module.app.farmView.winCtrl.open(this._tutorial);
			}
			Session.getInstance().m_waterPoolOpen = true;
			this._controller.module.app.dispatchEvent(new CommonEvent(Consts.MSG_POOL_OPEN, true));
			if (this._board != null && this._board.parent != null) {
				this._board.parent.removeChild(this._board);
				this._board = null;
			}
		} else {
			_loc3_ = cast(param1.data, String);
			if (_loc3_ == null || _loc3_ == "") {
				_loc3_ = "对不起，服务器返回失败，请稍后再试。";
			}
			_loc4_ = {
				"type": Consts.ALERT_TYPE_ERROR,
				"text": _loc3_
			};
			this._controller.module.app.openWindowByName(Consts.WINDOW_NAME_ALERT, _loc4_);
		}
	}

	// WaterGrayOpen.as:89-99
	public var myHome(never, set):Bool;

	private function set_myHome(param1:Bool):Bool {
		if (this._board != null) {
			this._board.visible = param1;
		}
		if (this._loader != null) {
			this._loader.visible = param1;
		}
		return param1;
	}

	// WaterGrayOpen.as:101-106
	private function onTutorialClosed(param1:Event):Void {
		GameGuide.toggle_water = true;
		GameGuide.instance().showStep(GameGuide.WATER_SHOP_ICON);
		GameGuide.instance().autoHide(8);
	}

	// WaterGrayOpen.as:108-111
	private function onNPCRollOut(param1:MouseEvent):Void {
		this._controller.useSystemCursor(false);
	}

	// WaterGrayOpen.as:113-117
	private function onClickOpen(param1:MouseEvent):Void {
		cast(this._controller, WaterController).model.openWater();
		cast(this._controller, WaterController).model.addEventListener(WaterModel.EVENT_WATER_OPENED, this.onWaterOpened);
	}

	// WaterGrayOpen.as:119-170。:142 `this._loader.removeChild(this._loader)`
	// 原版笔误（把「从容器拆 loader」写成「loader 拆自己」）照抄（PORT-NOTE）
	public var flag(never, set):Bool;

	private function set_flag(param1:Bool):Bool {
		var img:String = null;
		var w:Bool = param1;
		if (this._container == null) {
			return param1;
		}
		if (w == true) {
			if (this._board == null) {
				this._board = cast(Utils.getMaterial("WaterOpenBoard"), MovieClip);
			}
			this._board.x = 214;
			this._board.y = 80;
			this._board.buttonMode = true;
			this._container.addChild(this._board);
			this._board.addEventListener(MouseEvent.CLICK, this.onClickOpen, false, 0, true);
			this._board.addEventListener(MouseEvent.ROLL_OVER, this.onNPCRollOver, false, 0, true);
			this._board.addEventListener(MouseEvent.ROLL_OUT, this.onNPCRollOut, false, 0, true);
			if (this._loader != null && this._container.contains(this._loader) == true) {
				this._loader.removeChild(this._loader);
			}
		} else {
			if (this._loader != null) {
				this._loader.visible = true;
				this._container.addChild(this._loader);
				return param1;
			}
			img = Settings.getInstance().getSecondUrl("fishNPC");
			if (img == null || img == "") {
				return param1;
			}
			this._loader = new LocalSwfLoader();
			this._loader.x = 260;
			this._loader.y = -114;
			this._container.addChild(this._loader);
			this._loader.load(new URLRequest(img));
			this._loader.contentLoaderInfo.addEventListener(Event.COMPLETE, function(param1:Event):Void {
				_loader.addEventListener(MouseEvent.CLICK, onClickNPC, false, 0, true);
				_loader.addEventListener(MouseEvent.ROLL_OVER, onNPCRollOver, false, 0, true);
				_loader.addEventListener(MouseEvent.ROLL_OUT, onNPCRollOut, false, 0, true);
			});
		}
		return param1;
	}

	// WaterGrayOpen.as:172-180
	private function onClickNPC(param1:MouseEvent):Void {
		var _loc2_:String = Settings.getInstance().getStringAttribute("fishNPC");
		if (_loc2_ == null || _loc2_ == "") {
			return;
		}
		NavigateToURL.navigateToURL(new URLRequest(_loc2_), "_blank");
	}
}
