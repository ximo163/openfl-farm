package module.messages.widgets;

import com.qzone.qui.controls.TextArea;
import com.qzone.utils.StringUtil;
import common.Consts;
import common.Language;
import common.Session;
import common.Settings;
import module.messages.MessageView;
import openfl.display.Shape;
import openfl.display.Sprite;
import openfl.errors.TypeError;
import openfl.events.TextEvent;
import openfl.text.TextField;
import openfl.text.TextFieldAutoSize;
import openfl.text.TextFormat;
import shim.As3;
import shim.QQOutlets;

/**
 * module.messages.widgets.ProfileLog —— ProfileLog.as 逐句对应（issue #19）。
 * 消息页（hydra feeds）：只读 TextArea 拼 HTML 流水（新 feed 版文案 +
 * 「不让他摘」链接），「清空消息记录」链接开确认窗；单条链接（非好友提示）
 * 开 ALERT_TYPE_TEXT 警告窗。
 *
 * PORT-NOTE: `new Date(秒*1000)` → Date.fromTime；RegExp("<b>(.*)</b>")
 * .exec[1] → EReg.match + matched(1)（无匹配时原文 exec 得 null、null[1]
 * 抛 TypeError #1010 中断整页渲染——照译崩溃语义，不加静默守卫）；
 * ExternalInterface.call → QQOutlets.call（qq-outlet 出口）；for-each
 * over null Array（dataList 置 null 清页）在 Haxe 会炸，按 AS3 的零迭代
 * 语义判 null 跳过。
 */
class ProfileLog extends Sprite {
	// ProfileLog.as:16
	private var _log:TextArea;

	// ProfileLog.as:18
	private var _parent:MessageView;

	// ProfileLog.as:20
	private var _delAll:TextField;

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
		this._log.textField.addEventListener(TextEvent.LINK, this.onLinkClicked);
		addChild(this._log);
		this._delAll = new TextField();
		this._delAll.autoSize = TextFieldAutoSize.LEFT;
		this._delAll.selectable = false;
		this._delAll.defaultTextFormat = new TextFormat("Verdana", null, 39423);
		this._delAll.htmlText = "<a href=\'event:del\'>" + Reflect.field(Language.L, "清空消息记录") + "</a>";
		this._delAll.addEventListener(TextEvent.LINK, this.onDeleteAll);
		this._delAll.x = 30;
		this._delAll.y = 180 + 18;
		addChild(this._delAll);
	}

	// ProfileLog.as:69-76
	private function compareDate(param1:Date, param2:Date):Int {
		param1 = new Date(param1.getFullYear(), param1.getMonth(), param1.getDate(), 0, 0, 0);
		param2 = new Date(param2.getFullYear(), param2.getMonth(), param2.getDate(), 0, 0, 0);
		// 原文 `var _loc3_:int = Math.abs(...)`：|Δms| 过 2^31（≈24.9 天）
		// 按 int32 回绕——约 49.7-74.6 天的流水回绕成 0/1/2、被错标成
		// 今天/昨天/前天，原版 bug 照抄（js/eval 的 Int 不回绕，走 As3.int32）
		var _loc3_:Int = As3.int32(Math.abs(param2.getTime() - param1.getTime()));
		return Std.int(_loc3_ / 86400000);
	}

	// ProfileLog.as:78-81
	private function delLogConfirm():Void {
		this._parent.controller.model.clearAllLog();
	}

	// ProfileLog.as:83-146
	private function genMsgNewFeed(param1:Dynamic):String {
		var _loc6_:String = "";
		var _loc2_:String = ""; // 原文 :76 声明后未用（死局部，照留）
		// 原文 :77 `_loc3_ = param1["cn"] as String`：非 String 得 null
		//（后文 :102 拼串按 "null"、:106/.indexOf 与 :112 exec 在 null 上
		// 抛——照译，不垫 ""）
		var _loc3_:String = null;
		if (Std.isOfType(Reflect.field(param1, "cn"), String)) {
			_loc3_ = Reflect.field(param1, "cn");
		}
		var _loc4_:String = Reflect.field(param1, "opuin");
		var _loc5_:String = Reflect.field(param1, "opuin");
		var _loc7_:String = "";
		var _loc8_:String = "";
		var _loc9_:Array<Dynamic> = ["", "空间", "校友", "微博"];
		var _loc10_:Settings = Settings.getInstance();
		var _loc11_:Session = Session.getInstance();
		if (_loc10_.mode == "qzone") {
			_loc9_[1] = "";
		} else {
			_loc9_[2] = "";
		}
		if (As3.hasProp(param1, "domain") == true) {
			// `param1["domain"] == 6`：Object == int 宽松等按数值比较
			if (As3.floatOf(Reflect.field(param1, "domain")) == 6) {
				Reflect.setField(param1, "domain", 3);
			}
			_loc8_ = _loc9_[As3.intOf(Reflect.field(param1, "domain"))];
		}
		_loc7_ = _loc8_ + _loc3_;
		var _loc12_:Bool = this._parent.controller.model.me;
		if (_loc10_.mode == "qzone" && _loc12_ == true) {
			if (As3.floatOf(Reflect.field(param1, "domain")) == 1 && As3.truthy(_loc4_)
				&& _loc3_.indexOf("来农场摘取，摘走") > 0) {
				_loc11_.initFriendMap();
				if (_loc11_.friendsMap != null && !As3.truthy(Reflect.field(_loc11_.friendsMap, _loc4_))) {
					var _loc17_:EReg = new EReg("<b>(.*)</b>", "");
					// 原文 :112 `_loc6_ = _loc17_.exec(_loc3_)[1]`：exec 无匹配
					// 得 null、null[1] 抛 TypeError #1010，从 genMsgNewFeed 一路
					// 中断整页 dataList 渲染——照译崩溃语义，不加静默守卫
					if (!_loc17_.match(_loc3_)) {
						throw new TypeError("Error #1010: A term is undefined and has no properties.", 1010);
					}
					_loc6_ = _loc17_.matched(1);
					_loc7_ += "\t<a href=\'event:" + _loc5_ + "," + _loc6_ + "\'><font color=\'#0099FF\'>不让他摘</font></a>";
				}
			}
		}
		var _loc13_:Date = Date.fromTime(As3.floatOf(Reflect.field(param1, "t")) * 1000);
		var _loc14_:String = this.twoData(_loc13_.getHours());
		var _loc15_:String = this.twoData(_loc13_.getMinutes());
		var _loc16_:String = "";
		if (Language.lang == Language.CN) {
			var _loc18_:Int = this.compareDate(_loc13_, Date.now());
			if (_loc18_ == 0) {
				_loc16_ = "    " + Reflect.field(Language.L, "今天") + _loc14_ + ":" + _loc15_;
			} else if (_loc18_ == 1) {
				_loc16_ = "    " + Reflect.field(Language.L, "昨天") + _loc14_ + ":" + _loc15_;
			} else if (_loc18_ == 2) {
				_loc16_ = "    " + Reflect.field(Language.L, "前天") + _loc14_ + ":" + _loc15_;
			} else {
				_loc16_ = this.twoData(_loc13_.getMonth() + 1) + "-" + this.twoData(_loc13_.getDate()) + " " + _loc14_ + ":"
					+ _loc15_;
			}
		} else {
			_loc16_ = this.twoData(_loc13_.getMonth() + 1) + "-" + this.twoData(_loc13_.getDate()) + " " + _loc14_ + ":"
				+ _loc15_;
		}
		return "<b>" + _loc16_ + "</b>  " + _loc7_ + "<br>";
	}

	// ProfileLog.as:148-176
	private function onLinkClicked(param1:TextEvent):Void {
		if (param1 == null || param1.text == "") {
			return;
		}
		var _loc2_:Array<Dynamic> = param1.text.split(",");
		// 原文 `var _loc3_:uint = parseInt(...)`：uint 是 ToUint32，QQ 号可越
		// 2^31（cpp 的 Int 会回绕成负）；按 Number 持有，`> 0` 判与字符串
		// 拼接同 uint 语义（parseInt 失败 NaN > 0 恒假，同 uint(NaN)=0）
		var _loc3_:Float = As3.parseInt(_loc2_[0]);
		var _loc4_:String = Std.string(_loc2_[1]);
		var _loc5_:String = "<p align=\'left\'><font color=\'#009900\'><b>";
		if (_loc4_ != null && _loc4_.length > 0) {
			_loc5_ += StringUtil.htmlEscape(_loc4_);
		}
		if (_loc3_ > 0) {
			_loc5_ += "(QQ:" + _loc3_ + ")";
		}
		var _loc6_:String = As3.or(Settings.getInstance().getStringAttribute("filterUrl"),
			"http://blog.qq.com/qzone/1006666002/1300264199.htm");
		var _loc7_:String = As3.or(Settings.getInstance().getStringAttribute("friendUrl"), "");
		_loc5_ += "</b></font> 可能不是您的好友，您可以进入“我的QQ中心”删除单向好友，"
			+ "防止对方进入您的农/牧场进行摘取等操作。<br/>"
			+ "<font color=\'#0000FF\'><u><b><a href=\'event:" + _loc7_ + "\' target=\'_blank\'>前往管理您的单向好友</a></b></u>。</font></p>"
			+ "<p align=\'right\'><font color=\'#0000FF\'><u><a href=\'event:" + _loc6_ + "\' target=\'_blank\'>详细</a></u></font></p>";
		var _loc8_:Dynamic = {
			"textSelectable": true,
			"title": "友情提示",
			"width": 380,
			"height": 240,
			"text": _loc5_,
			"type": Consts.ALERT_TYPE_TEXT,
			"textLinkHandle": this.onAlertNaviagte
		};
		this._parent.controller.openWindow(Consts.WINDOW_NAME_ALERT, _loc8_);
	}

	// ProfileLog.as:178-187（AS3 public set dataList）
	public var dataList(never, set):Array<Dynamic>;

	private function set_dataList(param1:Array<Dynamic>):Array<Dynamic> {
		var _loc3_:Dynamic = null;
		this._delAll.visible = Session.getInstance().me ? true : false;
		var _loc2_:String = "";
		// PORT-NOTE: AS3 for-each over null 零迭代不抛，Haxe 判 null 复刻
		if (param1 != null) {
			for (_loc3_ in (param1:Array<Dynamic>)) {
				_loc2_ += this.genMsgNewFeed(_loc3_);
			}
		}
		this._log.htmlText = "<textformat leading=\'8\'><font face=\'Verdana\'>" + _loc2_ + "</font></textformat>";
		return param1;
	}

	// ProfileLog.as:189-196
	private function twoData(param1:Int):String {
		if (param1 < 10) {
			return "0" + Std.string(param1);
		}
		return Std.string(param1);
	}

	// ProfileLog.as:198-206
	private function onDeleteAll(param1:TextEvent):Void {
		var _loc2_:Dynamic = {
			"title": Reflect.field(Language.L, "清空记录"),
			"text": Reflect.field(Language.L, "确认清空消息记录？"),
			"confirmFn": this.delLogConfirm
		};
		this._parent.controller.openWindow(Consts.WINDOW_NAME_CONFIRM, _loc2_);
	}

	// ProfileLog.as:208-214
	private function onAlertNaviagte(param1:TextEvent):Void {
		if (param1 == null || param1.text == "") {
			return;
		}
		// PORT-NOTE(qq-outlet)：ExternalInterface.call → QQOutlets.call
		QQOutlets.call("window.open(\"" + param1.text + "\")");
	}
}
