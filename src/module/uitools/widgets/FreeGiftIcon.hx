package module.uitools.widgets;

import common.Settings;
import common.misc.Utils;
import openfl.display.MovieClip;
import shim.As3;

/**
 * module.uitools.widgets.FreeGiftIcon —— FreeGiftIcon.as 逐句对应（issue #9）。
 * 免费礼物入口图标：Freegift 素材 + 未读角标；showAnimation 顶一层 FreeGiftAni
 * 3 秒自清。
 */
class FreeGiftIcon extends MovieClip {
	// FreeGiftIcon.as:12
	public var Name:String;

	// FreeGiftIcon.as:14
	private var ani:MovieClip;

	// FreeGiftIcon.as:16-24
	public function new() {
		var _loc1_:MovieClip = null;
		super();
		_loc1_ = cast(Utils.getMaterial("Freegift"), MovieClip);
		_loc1_.name = "_freegift_";
		this.addChild(_loc1_);
		this.mouseChildren = false;
	}

	// FreeGiftIcon.as:26-48（init：未读数角标；>50 显 "50+"）
	public function init(param1:Dynamic):Void {
		var _loc4_:String = null;
		var _loc2_:MovieClip = cast(this.getChildByName("_freegift_"), MovieClip);
		var _loc3_:Dynamic = Settings.getInstance().getFreeGift(Reflect.field(param1, "gift"));
		if (As3.intOf(Reflect.field(param1, "unread")) > 50) {
			_loc4_ = "50+";
		} else {
			_loc4_ = Reflect.field(param1, "unread");
		}
		// numBox.num_txt 文本链 → Reflect（swf 动态子件）
		cast(Reflect.field(Reflect.field(_loc2_, "numBox"), "num_txt"), openfl.text.TextField).text = _loc4_;
		if (_loc4_ == "0") {
			cast(Reflect.field(_loc2_, "numBox"), openfl.display.DisplayObject).visible = false;
		} else {
			cast(Reflect.field(_loc2_, "numBox"), openfl.display.DisplayObject).visible = true;
		}
	}

	// FreeGiftIcon.as:50-61
	public function showAnimation():Void {
		var _loc1_:Int = 0;
		if (this.numChildren == 1) {
			this.ani = cast(Utils.getMaterial("FreeGiftAni"), MovieClip);
			this.parent.parent.addChild(this.ani);
			this.ani.y = this.y + this.parent.y;
			this.ani.x = 45;
			// As3.setTimeout 只收无参闭包，调用点包一层把句柄送进 clear
			// （原版 `setTimeout(this.clear,3000,_loc1_)`，NPCView 同款）
			_loc1_ = As3.setTimeout(this.clear.bind(_loc1_), 3000);
		}
	}

	// FreeGiftIcon.as:63-68
	private function clear(param1:Int):Void {
		As3.clearTimeout(param1);
		this.parent.parent.removeChild(this.ani);
		this.ani = null;
	}
}
