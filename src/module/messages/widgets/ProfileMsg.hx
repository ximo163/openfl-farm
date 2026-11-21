package module.messages.widgets;

import com.qzone.qui.controls.Button;
import com.qzone.qui.controls.TextArea;
import com.qzone.utils.StringUtil;
import common.Consts;
import common.Language;
import common.Session;
import common.Settings;
import common.misc.Utils;
import module.messages.MessageView;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.KeyboardEvent;
import openfl.events.MouseEvent;
import openfl.events.TextEvent;
import openfl.text.TextField;
import openfl.text.TextFieldAutoSize;
import openfl.text.TextFieldType;
import openfl.text.TextFormat;
import shim.As3;

/**
 * module.messages.widgets.ProfileMsg —— ProfileMsg.as 逐句对应（issue #19）。
 * 留言页：只读 TextArea 留言流（回复链接）、50 字输入框（回车/按钮发送）、
 * 「清空留言记录」确认窗；isReply 区分留言/回复两种行文。
 *
 * PORT-NOTE: `param1["isAdmin"] == true` / `param1["isReply"] == false` 的
 * Object == Boolean 宽松等按两边转数值复刻（"0"==true 为假、"0"==false 为
 * 真）；`new Date(秒*1000)` → Date.fromTime；unescape → As3.unescape
 * （Haxe urlDecode 会把 + 换空格）；replace("\r"," ") 只换第一处 →
 * As3.replaceFirst。
 */
class ProfileMsg extends Sprite {
	// ProfileMsg.as:24
	private var _parent:MessageView;

	// ProfileMsg.as:26
	private var chatInput:TextField;

	// ProfileMsg.as:28
	private var _tName:String;

	// ProfileMsg.as:30
	private var _fName:String;

	// ProfileMsg.as:32
	private var replyLabel:TextField;

	// ProfileMsg.as:34
	private var chatLipiList:TextArea;

	// ProfileMsg.as:36
	private var delChatLabel:TextField;

	// ProfileMsg.as:38
	private var _me:Bool;

	// ProfileMsg.as:40
	private var _sendToId:String;

	public function new(param1:MessageView) {
		super();
		this._parent = param1;
		this._sendToId = "0";
		this._me = false;
		this.createView();
	}

	// ProfileMsg.as:50-130
	private function createView():Void {
		this.chatLipiList = new TextArea();
		this.chatLipiList.addEventListener(TextEvent.LINK, this.onReply);
		this.chatLipiList.defaultSkin = null;
		this.chatLipiList.selectedSkin = null;
		this.chatLipiList.readOnly = true;
		this.chatLipiList.width = 470;
		this.chatLipiList.height = 150;
		this.chatLipiList.x = 20;
		this.chatLipiList.y = 2;
		addChild(this.chatLipiList);
		this.chatInput = new TextField();
		this.chatInput.defaultTextFormat = new TextFormat("Verdana");
		this.chatInput.maxChars = 50;
		this.chatInput.wordWrap = true;
		this.chatInput.addEventListener(KeyboardEvent.KEY_DOWN, this.onChatInputKeyDown);
		this.chatInput.type = TextFieldType.INPUT;
		this.chatInput.background = true;
		this.chatInput.backgroundColor = 16777215;
		this.chatInput.border = true;
		this.chatInput.borderColor = 39423;
		this.chatInput.htmlText = "";
		this.chatInput.width = 450;
		this.chatInput.height = 35;
		this.chatInput.x = 20;
		this.chatInput.y = 160;
		addChild(this.chatInput);
		var _loc1_:TextField = new TextField();
		_loc1_.autoSize = TextFieldAutoSize.LEFT;
		_loc1_.selectable = false;
		_loc1_.defaultTextFormat = new TextFormat("Verdana", null, 6710886);
		_loc1_.text = Reflect.field(Language.L, "(每条最多 50 字)");
		_loc1_.y = 200;
		_loc1_.x = 410 - _loc1_.width;
		addChild(_loc1_);
		var _loc2_:Button = new Button();
		_loc2_.width = 43;
		_loc2_.height = 23;
		_loc2_.defaultSkin = Utils.getClass("ButtonGreen");
		_loc2_.addEventListener(MouseEvent.CLICK, this.sendMsg);
		_loc2_.y = 198;
		_loc2_.x = 420;
		_loc2_.text = Reflect.field(Language.L, "发送留言");
		addChild(_loc2_);
		this.delChatLabel = new TextField();
		this.delChatLabel.autoSize = TextFieldAutoSize.LEFT;
		this.delChatLabel.selectable = false;
		this.delChatLabel.defaultTextFormat = new TextFormat("Verdana", null, 39423);
		this.delChatLabel.htmlText = "<a href=\'event:del\'>" + Reflect.field(Language.L, "清空留言记录") + "</a>";
		this.delChatLabel.addEventListener(TextEvent.LINK, this.delChat);
		this.delChatLabel.y = 200;
		this.delChatLabel.x = 20;
		addChild(this.delChatLabel);
		this.replyLabel = new TextField();
		this.replyLabel.selectable = false;
		this.replyLabel.autoSize = TextFieldAutoSize.LEFT;
		this.replyLabel.background = true;
		this.replyLabel.backgroundColor = 16777215;
		this.replyLabel.defaultTextFormat = new TextFormat("Verdana", null, 39168, true);
		this.replyLabel.text = "";
		this.replyLabel.height = 22;
		this.replyLabel.y = 140;
		this.replyLabel.x = 20;
		addChild(this.replyLabel);
	}

	// ProfileMsg.as:132-140
	private function delChat(param1:TextEvent):Void {
		var _loc2_:Dynamic = {
			"title": Reflect.field(Language.L, "清空记录"),
			"text": Reflect.field(Language.L, "确认删除您的留言记录？"),
			"confirmFn": this.delLogConfirm
		};
		this._parent.controller.openWindow(Consts.WINDOW_NAME_CONFIRM, _loc2_);
	}

	// ProfileMsg.as:142-145
	private function delLogConfirm():Void {
		this._parent.controller.model.clearChat();
	}

	// ProfileMsg.as:147-153
	public function hideReply():Void {
		if (this.replyLabel != null) {
			this.replyLabel.visible = false;
		}
		this._sendToId = "0";
	}

	// ProfileMsg.as:155-163
	private function onReply(param1:TextEvent):Void {
		var _loc2_:Array<Dynamic> = param1.text.split(",");
		this.replyLabel.text = Reflect.field(Language.L, "回复") + _loc2_[1] + ": ";
		this._tName = _loc2_[1];
		this.replyLabel.visible = true;
		this._sendToId = _loc2_[0];
		stage.focus = this.chatInput;
	}

	// ProfileMsg.as:165-171
	public function reset():Void {
		if (this.chatInput != null) {
			this.chatInput.text = "";
		}
	}

	// ProfileMsg.as:173-183（AS3 public set dataList）
	public var dataList(never, set):Array<Dynamic>;

	private function set_dataList(param1:Array<Dynamic>):Array<Dynamic> {
		var _loc3_:Dynamic = null;
		this.delChatLabel.visible = Session.getInstance().me ? true : false;
		var _loc2_:String = "";
		// PORT-NOTE: AS3 for-each over null 零迭代不抛，Haxe 判 null 复刻
		if (param1 != null) {
			for (_loc3_ in (param1:Array<Dynamic>)) {
				_loc2_ += this.genMsg(_loc3_);
			}
		}
		this.chatLipiList.htmlText = "<textformat leading=\'8\'><font face=\'Verdana\'>" + _loc2_ + "</font></textformat>";
		return param1;
	}

	// ProfileMsg.as:185-257
	private function genMsg(param1:Dynamic):String {
		var _loc16_:Int = 0;
		var _loc2_:String = "";
		var _loc3_:String = "0";
		if (Session.getInstance().me == true) {
			_loc3_ = Std.string(Session.getInstance().currentUser._uId);
		}
		var _loc4_:String = "";
		var _loc5_:String = As3.or(Reflect.field(param1, "fromName"), "");
		_loc5_ = StringUtil.htmlEscape(_loc5_);
		var _loc6_:String = As3.or(Reflect.field(param1, "toName"), "");
		_loc6_ = StringUtil.htmlEscape(_loc6_);
		// `_loc3_ == param1["fromId"]`：String == Object 宽松等（类头 PORT-NOTE）
		if (_loc3_ == "0" || As3.eqString(Reflect.field(param1, "fromId"), _loc3_)
			|| As3.floatOf(Reflect.field(param1, "isAdmin")) == 1) {
			_loc4_ = "";
		} else {
			_loc4_ = "<a href=\'event:" + Reflect.field(param1, "fromId") + "," + _loc5_ + "\'><font color=\'#0099FF\'>"
				+ Reflect.field(Language.L, "回复") + "</font></a>";
		}
		var _loc7_:String = As3.unescape(Reflect.field(param1, "msg"));
		var _loc8_:String = "";
		_loc7_ = StringUtil.htmlEscape(_loc7_);
		var _loc9_:String = "";
		var _loc10_:Array<Dynamic> = ["", "空间", "校友", "微博"];
		if (Settings.getInstance().mode == "qzone") {
			_loc10_[1] = "";
		} else {
			_loc10_[2] = "";
		}
		if (As3.hasProp(param1, "domain") == true) {
			// `param1["domain"] == 6`：Object == int 宽松等按数值比较
			if (As3.floatOf(Reflect.field(param1, "domain")) == 6) {
				Reflect.setField(param1, "domain", 3);
			}
			_loc9_ = _loc10_[As3.intOf(Reflect.field(param1, "domain"))];
		}
		var _loc11_:String = As3.or(Reflect.field(param1, "color"), "#009900");
		// `param1["isReply"] == false`：Boolean 化宽松等（类头 PORT-NOTE）
		if (As3.hasProp(param1, "isReply") == false || As3.floatOf(Reflect.field(param1, "isReply")) == 0) {
			_loc8_ = _loc9_ + "<font color=\'" + _loc11_ + "\'><b>" + _loc5_ + "</b></font>：" + _loc7_;
		} else {
			_loc8_ = _loc9_ + "<font color=\'" + _loc11_ + "\'><b>" + _loc5_ + "</b></font> 回复 <font color=\'#009900\'><b>"
				+ _loc6_ + "</b></font>：" + _loc7_;
		}
		var _loc12_:Date = Date.fromTime(As3.floatOf(Reflect.field(param1, "time")) * 1000);
		var _loc13_:String = this.twoData(_loc12_.getHours());
		var _loc14_:String = this.twoData(_loc12_.getMinutes());
		var _loc15_:String = "";
		if (Language.lang == Language.CN) {
			_loc16_ = this.compareNow(_loc12_);
			if (_loc16_ == 0) {
				_loc15_ = "   " + Reflect.field(Language.L, "今天") + _loc13_ + ":" + _loc14_;
			} else if (_loc16_ == 1) {
				_loc15_ = "    " + Reflect.field(Language.L, "昨天") + _loc13_ + ":" + _loc14_;
			} else if (_loc16_ == 2) {
				_loc15_ = "    " + Reflect.field(Language.L, "前天") + _loc13_ + ":" + _loc14_;
			} else {
				_loc15_ = this.twoData(_loc12_.getMonth() + 1) + "-" + this.twoData(_loc12_.getDate()) + " " + _loc13_ + ":"
					+ _loc14_;
			}
		} else {
			_loc15_ = this.twoData(_loc12_.getMonth() + 1) + "-" + this.twoData(_loc12_.getDate()) + " " + _loc13_ + ":"
				+ _loc14_;
		}
		return "<b>" + _loc15_ + "</b>  " + _loc8_ + "  " + _loc4_ + "<br>";
	}

	// ProfileMsg.as:259-266
	private function twoData(param1:Int):String {
		if (param1 < 10) {
			return "0" + Std.string(param1);
		}
		return Std.string(param1);
	}

	// ProfileMsg.as:268-297
	private function sendMsg(param1:Event = null):Void {
		if (StringUtil.trim(this.chatInput.text) == "") {
			this.chatInput.text = "";
			return;
		}
		var _loc2_:Int = 0;
		var _loc3_:String = "0";
		var _loc4_:String = "0";
		if (this._parent.me == true) {
			_loc4_ = Session.getInstance().hostId;
		} else {
			_loc4_ = Std.string(Session.getInstance().currentUser._uId);
		}
		if (this._sendToId != "0") {
			_loc3_ = this._sendToId;
			_loc2_ = 1;
		} else {
			_loc3_ = _loc4_;
		}
		var _loc5_:String = this.chatInput.text;
		// AS3 String.replace(串,串) 只替换第一处
		_loc5_ = As3.replaceFirst(_loc5_, "\r", " ");
		this._parent.controller.model.sendChat(_loc3_, _loc4_, _loc2_, _loc5_, this._tName);
		this.chatInput.text = "";
		this.replyLabel.visible = false;
		this._sendToId = "0";
	}

	// ProfileMsg.as:299-306
	private function onChatInputKeyDown(param1:KeyboardEvent):Void {
		param1.stopPropagation();
		if (param1.keyCode == 13) {
			this.sendMsg();
		}
	}

	// ProfileMsg.as:308-313
	private function compareNow(param1:Date):Int {
		param1 = new Date(param1.getFullYear(), param1.getMonth(), param1.getDate(), 0, 0, 0);
		var _loc2_:Date = Date.now();
		var _loc3_:Float = _loc2_.getTime() - param1.getTime();
		return Std.int(_loc3_ / 86400000);
	}
}
