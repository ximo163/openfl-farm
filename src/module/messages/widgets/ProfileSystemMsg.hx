package module.messages.widgets;

import com.qzone.qui.controls.TextArea;
import common.Language;
import common.Settings;
import common.Session;
import module.messages.MessageView;
import openfl.display.Shape;
import openfl.display.Sprite;
import shim.As3;

/**
 * module.messages.widgets.ProfileSystemMsg —— ProfileSystemMsg.as 逐句对应
 * （issue #19）。系统公告页：只读 TextArea；opnick 有值时加「昵称：」前缀，
 * color 可自定义（默认 #DD0000）。
 */
class ProfileSystemMsg extends Sprite {
	// ProfileSystemMsg.as:15
	private var _log:TextArea;

	// ProfileSystemMsg.as:17
	private var _parent:MessageView;

	public function new(param1:MessageView) {
		super();
		this._parent = param1;
		var _loc2_:Shape = new Shape();
		_loc2_.graphics.lineStyle(1, 16777215);
		_loc2_.graphics.moveTo(0, 0);
		_loc2_.graphics.lineTo(490, 0);
		_loc2_.y = 195;
		_loc2_.x = 3;
		addChild(_loc2_);
		this._log = new TextArea();
		this._log.width = 470;
		this._log.height = 190;
		this._log.x = 20;
		this._log.y = 2;
		this._log.defaultSkin = null;
		this._log.selectedSkin = null;
		this._log.readOnly = true;
		addChild(this._log);
	}

	// ProfileSystemMsg.as:42-52（AS3 public set dataList）
	public var dataList(never, set):Array<Dynamic>;

	private function set_dataList(param1:Array<Dynamic>):Array<Dynamic> {
		var _loc3_:Dynamic = null;
		var _loc2_:String = "";
		// PORT-NOTE: AS3 for-each over null 零迭代不抛，Haxe 判 null 复刻
		if (param1 != null) {
			for (_loc3_ in (param1:Array<Dynamic>)) {
				_loc2_ += this.genMsg(_loc3_);
			}
		}
		this._log.htmlText = "<textformat leading=\'8\'><font face=\'Verdana\'>" + _loc2_ + "</font></textformat>";
		return param1;
	}

	// ProfileSystemMsg.as:54-101
	private function genMsg(param1:Dynamic):String {
		var _loc13_:Int = 0;
		var _loc2_:String = "";
		// `param1["words"] as String`
		var _loc3_:String = null;
		if (Std.isOfType(Reflect.field(param1, "words"), String)) {
			_loc3_ = Reflect.field(param1, "words");
		}
		var _loc4_:String = "";
		var _loc5_:String = "";
		var _loc6_:Settings = Settings.getInstance();
		var _loc7_:Session = Session.getInstance();
		var _loc8_:String = As3.or(Reflect.field(param1, "color"), "#DD0000");
		if (As3.hasProp(param1, "opnick") && Reflect.field(param1, "opnick") != "") {
			_loc5_ = "<font color=\'" + _loc8_ + "\'><b>" + Reflect.field(param1, "opnick") + "</b></font>：";
		}
		_loc4_ = _loc5_ + _loc3_;
		var _loc9_:Date = Date.fromTime(As3.floatOf(Reflect.field(param1, "time")) * 1000);
		var _loc10_:String = this.twoData(_loc9_.getHours());
		var _loc11_:String = this.twoData(_loc9_.getMinutes());
		var _loc12_:String = "";
		if (Language.lang == Language.CN) {
			_loc13_ = this.compareDate(_loc9_, Date.now());
			if (_loc13_ == 0) {
				_loc12_ = "    " + Reflect.field(Language.L, "今天") + _loc10_ + ":" + _loc11_;
			} else if (_loc13_ == 1) {
				_loc12_ = "    " + Reflect.field(Language.L, "昨天") + _loc10_ + ":" + _loc11_;
			} else if (_loc13_ == 2) {
				_loc12_ = "    " + Reflect.field(Language.L, "前天") + _loc10_ + ":" + _loc11_;
			} else {
				_loc12_ = this.twoData(_loc9_.getMonth() + 1) + "-" + this.twoData(_loc9_.getDate()) + " " + _loc10_ + ":"
					+ _loc11_;
			}
		} else {
			_loc12_ = this.twoData(_loc9_.getMonth() + 1) + "-" + this.twoData(_loc9_.getDate()) + " " + _loc10_ + ":"
				+ _loc11_;
		}
		return "<b>" + _loc12_ + "</b>  " + _loc4_ + "<br>";
	}

	// ProfileSystemMsg.as:103-110
	private function twoData(param1:Int):String {
		if (param1 < 10) {
			return "0" + Std.string(param1);
		}
		return Std.string(param1);
	}

	// ProfileSystemMsg.as:112-119
	private function compareDate(param1:Date, param2:Date):Int {
		param1 = new Date(param1.getFullYear(), param1.getMonth(), param1.getDate(), 0, 0, 0);
		param2 = new Date(param2.getFullYear(), param2.getMonth(), param2.getDate(), 0, 0, 0);
		var _loc3_:Int = Std.int(Math.abs(param2.getTime() - param1.getTime()));
		return Std.int(_loc3_ / 86400000);
	}
}
