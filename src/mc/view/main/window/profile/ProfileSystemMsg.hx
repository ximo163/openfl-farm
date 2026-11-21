package mc.view.main.window.profile;

import com.minutes.ui.control.LipiTextArea;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.text.TextFieldType;
import mc.control.ViewControl;
import mc.view.common.DataLoading;
import shim.As3;

/**
 * mc.view.main.window.profile.ProfileSystemMsg —— ProfileSystemMsg.as 逐句
 * 对应（issue #19）。牧场个人信息窗「系统」页：系统公告流。原文件
 * legacy/decompiled/Master2_v_142/scripts/mc/view/main/window/profile/ProfileSystemMsg.as。
 */
@:keep
class ProfileSystemMsg extends Sprite {
	private var dataLoading:DataLoading;

	private var _log:LipiTextArea;

	public function new() {
		super();
		this._log = new LipiTextArea();
		this._log.bgAlpha = 0;
		this._log.width = 465;
		this._log.height = 190;
		this._log.x = 20;
		this._log.y = 2;
		this._log.type = TextFieldType.DYNAMIC;
		this._log.vLipiScrollBar.visible = false;
		addChild(this._log);
		this.dataLoading = new DataLoading();
		this.dataLoading.x = this._log.width / 2;
		this.dataLoading.y = this._log.height / 2;
		addChild(this.dataLoading);
		ViewControl.getInstance().addEventListener("SystemMsgLoadFailed", this.onLoadedFailed);
	}

	// ProfileSystemMsg.as:39-42
	private function onLoadedFailed(param1:Event):Void {
		this.dataLoading.errorText = "请求超时，" + "<a href='event:reload'><u><font color='#ff6600'>点击重试</font></u></a>";
	}

	// ProfileSystemMsg.as:44-61（AS3 for-each over null 零次迭代，加 null 守卫）
	public var dataList(never, set):Array<Dynamic>;

	private function set_dataList(param1:Array<Dynamic>):Array<Dynamic> {
		var _loc3_:Dynamic = null;
		var _loc2_:String = "";
		if (param1 != null) {
			for (_loc3_ in param1) {
				_loc2_ += this.genMsg(_loc3_);
			}
		}
		this._log.htmlText = "<textformat leading='8'><font face='Verdana'>" + _loc2_ + "</font></textformat>";
		if (this._log.textField.numLines > 9) {
			this._log.vLipiScrollBar.visible = true;
		} else {
			this._log.vLipiScrollBar.visible = false;
		}
		return param1;
	}

	// ProfileSystemMsg.as:63-97
	private function genMsg(param1:Dynamic):String {
		var _loc9_:String = null;
		var _loc2_:String = "";
		// AS3 `as String`：非字符串得 null
		var _loc3_:String = Std.isOfType(Reflect.field(param1, "words"), String) ? Reflect.field(param1, "words") : null;
		var _loc4_:String = "";
		var _loc5_:String = "";
		var _loc6_:String = "";
		var _loc7_:String = As3.or(Reflect.field(param1, "color"), "#DD0000");
		if (As3.hasProp(param1, "opnick") && Std.string(Reflect.field(param1, "opnick")) != "") {
			_loc6_ = "<font color='" + _loc7_ + "'><b>" + Reflect.field(param1, "opnick") + "</b></font>：";
		}
		_loc5_ = _loc6_ + _loc3_;
		var _loc8_:Date = Date.fromTime(As3.floatOf(Reflect.field(param1, "time")) * 1000);
		var _loc10_:String = this.twoData(_loc8_.getHours());
		var _loc11_:String = this.twoData(_loc8_.getMinutes());
		if (this.compareDate(_loc8_, Date.now()) == 0) {
			_loc9_ = "    " + "今天" + _loc10_ + ":" + _loc11_;
		} else if (this.compareDate(_loc8_, Date.now()) == 1) {
			_loc9_ = "    " + "昨天" + _loc10_ + ":" + _loc11_;
		} else if (this.compareDate(_loc8_, Date.now()) == 2) {
			_loc9_ = "    " + "前天" + _loc10_ + ":" + _loc11_;
		} else {
			_loc9_ = this.twoData(_loc8_.getMonth() + 1) + "-" + this.twoData(_loc8_.getDate()) + " " + _loc10_ + ":" + _loc11_;
		}
		return "<b>" + _loc9_ + "</b>  " + _loc5_ + "<br>";
	}

	// ProfileSystemMsg.as:99-105
	private function compareDate(param1:Date, param2:Date):Int {
		param1 = new Date(param1.getFullYear(), param1.getMonth(), param1.getDate(), 0, 0, 0);
		param2 = new Date(param2.getFullYear(), param2.getMonth(), param2.getDate(), 0, 0, 0);
		var _loc3_:Float = Math.abs(param2.getTime() - param1.getTime());
		return Std.int(_loc3_ / 86400000);
	}

	// ProfileSystemMsg.as:107-114
	private function twoData(param1:Int):String {
		if (param1 < 10) {
			return "0" + Std.string(param1);
		}
		return Std.string(param1);
	}
}
