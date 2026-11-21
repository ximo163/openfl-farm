package module.messages.widgets;

import com.qzone.qui.controls.Label;
import com.qzone.qui.controls.TextArea;
import com.qzone.qui.utils.TextFormatUtil;
import common.Language;
import common.Settings;
import common.view.window.WindowLabelMaker;
import module.messages.MessageView;
import openfl.display.Shape;
import openfl.display.Sprite;
import openfl.text.StyleSheet;
import shim.As3;

/**
 * module.messages.widgets.ProfileCost —— ProfileCost.as 逐句对应（issue #19）。
 * 消费页：只读 TextArea 消费流水（cgi_farm_exchange + websight 双源已在
 * model 合并排序），底部带 hover 下划线样式表的 Label（正文原版就置 ""）。
 */
class ProfileCost extends Sprite {
	// ProfileCost.as:14
	private var _aLipiList:TextArea;

	// ProfileCost.as:16
	private var _parent:MessageView;

	public function new(param1:MessageView) {
		super();
		this._parent = param1;
		this._aLipiList = new TextArea();
		this._aLipiList.defaultSkin = null;
		this._aLipiList.selectedSkin = null;
		this._aLipiList.readOnly = true;
		this._aLipiList.width = 470;
		this._aLipiList.height = 190;
		this._aLipiList.x = 20;
		this._aLipiList.y = 20;
		addChild(this._aLipiList);
		var _loc2_:Shape = new Shape();
		_loc2_.graphics.lineStyle(1, 16777215);
		_loc2_.graphics.moveTo(0, 0);
		_loc2_.graphics.lineTo(490, 0);
		_loc2_.y = 195;
		_loc2_.x = 3;
		addChild(_loc2_);
		this.addText();
	}

	// ProfileCost.as:44-54（AS3 public set dataList）
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
		this._aLipiList.htmlText = "<textformat leading=\'8\'><font face=\'Verdana\'>" + _loc2_ + "</font></textformat>";
		return param1;
	}

	// ProfileCost.as:56-110
	private function genMsg(param1:Dynamic):String {
		var _loc16_:Int = 0;
		var _loc2_:String = "";
		// `param1["msg"] as String`
		var _loc3_:String = null;
		if (Std.isOfType(Reflect.field(param1, "msg"), String)) {
			_loc3_ = Reflect.field(param1, "msg");
		}
		var _loc4_:String = Reflect.field(param1, "uid");
		var _loc5_:String = Reflect.field(param1, "uin");
		var _loc6_:Settings = Settings.getInstance();
		var _loc7_:String = "";
		var _loc8_:String = "";
		var _loc9_:String = "";
		var _loc10_:Array<Dynamic> = ["", "空间", "校友"];
		if (_loc6_.mode == "qzone") {
			_loc10_[1] = "";
		} else {
			_loc10_[2] = "";
		}
		if (As3.hasProp(param1, "domain")) {
			_loc9_ = _loc10_[As3.intOf(Reflect.field(param1, "domain"))];
		}
		_loc8_ = _loc9_ + _loc3_;
		var _loc11_:Date = Date.fromTime(As3.floatOf(Reflect.field(param1, "time")) * 1000);
		var _loc12_:String = this.twoData(_loc11_.getHours());
		var _loc13_:String = this.twoData(_loc11_.getMinutes());
		var _loc14_:Date = Date.now();
		var _loc15_:String = "";
		if (Language.lang == Language.CN) {
			_loc16_ = this.compareDate(_loc11_, Date.now());
			if (_loc16_ == 0) {
				_loc15_ = "    " + Reflect.field(Language.L, "今天") + _loc12_ + ":" + _loc13_;
			} else if (_loc16_ == 1) {
				_loc15_ = "    " + Reflect.field(Language.L, "昨天") + _loc12_ + ":" + _loc13_;
			} else if (_loc16_ == 2) {
				_loc15_ = "    " + Reflect.field(Language.L, "前天") + _loc12_ + ":" + _loc13_;
			} else {
				_loc15_ = this.twoData(_loc11_.getMonth() + 1) + "-" + this.twoData(_loc11_.getDate()) + " " + _loc12_ + ":"
					+ _loc13_;
			}
		} else {
			_loc15_ = this.twoData(_loc11_.getMonth() + 1) + "-" + this.twoData(_loc11_.getDate()) + " " + _loc12_ + ":"
				+ _loc13_;
		}
		return "<b>" + _loc15_ + "</b>  " + _loc8_ + "<br>";
	}

	// ProfileCost.as:112-119
	private function compareDate(param1:Date, param2:Date):Int {
		param1 = new Date(param1.getFullYear(), param1.getMonth(), param1.getDate(), 0, 0, 0);
		param2 = new Date(param2.getFullYear(), param2.getMonth(), param2.getDate(), 0, 0, 0);
		var _loc3_:Int = Std.int(Math.abs(param2.getTime() - param1.getTime()));
		return Std.int(_loc3_ / 86400000);
	}

	// ProfileCost.as:121-128
	private function twoData(param1:Int):String {
		if (param1 < 10) {
			return "0" + Std.string(param1);
		}
		return Std.string(param1);
	}

	// ProfileCost.as:130-145
	private function addText():Void {
		var _loc1_:Label = new Label();
		_loc1_.mouseChildren = true;
		_loc1_.width = width + 3;
		WindowLabelMaker.addTarget(_loc1_);
		_loc1_.textDefaultFormat = TextFormatUtil.clone(_loc1_.textDefaultFormat);
		_loc1_.textDefaultFormat.color = 11171584;
		_loc1_.text = "";
		_loc1_.x = 2;
		addChild(_loc1_);
		var _loc2_:StyleSheet = new StyleSheet();
		_loc2_.parseCSS("a:link{} a:hover{text-decoration:underline;}");
		_loc1_.textField.styleSheet = _loc2_;
	}
}
