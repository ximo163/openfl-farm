package mc.view.main.window.profile;

import com.adobe.utils.StringUtil;
import com.minutes.ui.control.LipiButton;
import com.minutes.ui.control.LipiTextArea;
import com.minutes.ui.core.LipiSkin;
import common.CommonData;
import common.LocalData;
import common.MaterialLib;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.KeyboardEvent;
import openfl.events.MouseEvent;
import openfl.events.TextEvent;
import openfl.text.TextField;
import openfl.text.TextFieldAutoSize;
import openfl.text.TextFieldType;
import openfl.text.TextFormat;
import mc.control.Command;
import mc.model.MData;
import mc.view.common.ConfirmWindow;
import mc.view.main.windowControl.WControl;
import shim.As3;

/**
 * mc.view.main.window.profile.ProfileMsg —— ProfileMsg.as 逐句对应
 * （issue #19）。牧场个人信息窗「留言」页：留言流（htmlText）+ 50 字输入框
 * + 回复/清空。原文件
 * legacy/decompiled/Master2_v_142/scripts/mc/view/main/window/profile/ProfileMsg.as。
 */
@:keep
class ProfileMsg extends Sprite {
	private var fName:String;

	public var chatInput:TextField;

	private var sendToId:String = "0";

	private var tName:String;

	private var replyLabel:TextField;

	private var chatLipiList:LipiTextArea;

	private var delChatLabel:TextField;

	private var _me:Bool = false;

	public function new() {
		var _loc1_:TextField = null;
		super();
		this.chatLipiList = new LipiTextArea();
		this.chatLipiList.addEventListener(TextEvent.LINK, this.replyClickHandler);
		this.chatLipiList.bgAlpha = 0;
		this.chatLipiList.type = TextFieldType.DYNAMIC;
		this.chatLipiList.width = 465;
		this.chatLipiList.height = 150;
		this.chatLipiList.x = 20;
		this.chatLipiList.y = 2;
		this.chatLipiList.vLipiScrollBar.visible = false;
		addChild(this.chatLipiList);
		this.chatInput = new TextField();
		this.chatInput.defaultTextFormat = new TextFormat("Verdana");
		this.chatInput.maxChars = 50;
		this.chatInput.wordWrap = true;
		this.chatInput.addEventListener(KeyboardEvent.KEY_DOWN, this.chatInputKeyDown);
		this.chatInput.type = TextFieldType.INPUT;
		this.chatInput.background = true;
		this.chatInput.backgroundColor = 16777215;
		this.chatInput.border = true;
		this.chatInput.borderColor = 10982267;
		this.chatInput.htmlText = "";
		this.chatInput.width = 450;
		this.chatInput.height = 35;
		this.chatInput.x = 20;
		this.chatInput.y = 160;
		addChild(this.chatInput);
		_loc1_ = new TextField();
		_loc1_.autoSize = TextFieldAutoSize.LEFT;
		_loc1_.selectable = false;
		_loc1_.defaultTextFormat = new TextFormat("Verdana", null, 8355198);
		_loc1_.text = "(每条最多 50 字)";
		_loc1_.y = 200;
		_loc1_.x = 410 - _loc1_.width;
		addChild(_loc1_);
		var _loc2_:LipiButton = new LipiButton();
		_loc2_.width = 43;
		_loc2_.height = 23;
		_loc2_.bgAlpha = 0;
		_loc2_.bgSkin = new LipiSkin(MaterialLib.getInstance().getClass("ButtonGreen"));
		_loc2_.addEventListener(MouseEvent.CLICK, this.sendMsg);
		_loc2_.y = 198;
		_loc2_.x = 420;
		_loc2_.label = "留言";
		_loc2_.textColor = 16777215;
		addChild(_loc2_);
		this.delChatLabel = new TextField();
		this.delChatLabel.autoSize = TextFieldAutoSize.LEFT;
		this.delChatLabel.selectable = false;
		this.delChatLabel.defaultTextFormat = new TextFormat("Verdana", null, 8999699);
		this.delChatLabel.htmlText = "<a href='event:del'>清空留言记录</a>";
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

	// ProfileMsg.as:114-124
	private function delChat(param1:TextEvent):Void {
		var cw:ConfirmWindow = new ConfirmWindow();
		cw.data = {"text": "确认删除您的留言记录？"};
		cw.confirmFn = function():Void {
			Command.getInstance().mainCommand.clearChat();
		};
		WControl.open(cw);
	}

	// ProfileMsg.as:126-133
	public function hideReply():Void {
		if (this.replyLabel != null) {
			this.replyLabel.visible = false;
		}
		this.sendToId = "0";
	}

	// ProfileMsg.as:135-172
	public var dataList(never, set):Array<Dynamic>;

	private function set_dataList(param1:Array<Dynamic>):Array<Dynamic> {
		var _loc3_:Dynamic = null;
		var _loc2_:String = "";
		if (!As3.truthy(param1)) {
			return param1;
		}
		for (_loc3_ in param1) {
			_loc2_ += this.genMsg(_loc3_);
		}
		if (param1.length == 0) {
			this.delChatLabel.removeEventListener(TextEvent.LINK, this.delChat);
		} else {
			this.delChatLabel.addEventListener(TextEvent.LINK, this.delChat);
		}
		this.chatLipiList.htmlText = "<textformat leading='8'><font face='Verdana'>" + _loc2_ + "</font></textformat>";
		if (MData.getInstance().mainData.me) {
			this.delChatLabel.visible = true;
		} else {
			this.delChatLabel.visible = false;
		}
		if (this.chatLipiList.textField.numLines > 8) {
			this.chatLipiList.vLipiScrollBar.visible = true;
		} else {
			this.chatLipiList.vLipiScrollBar.visible = false;
		}
		return param1;
	}

	// ProfileMsg.as:174-181
	private function twoData(param1:Int):String {
		if (param1 < 10) {
			return "0" + Std.string(param1);
		}
		return Std.string(param1);
	}

	// ProfileMsg.as:183-216
	private function sendMsg(param1:Event = null):Void {
		if (StringUtil.trim(this.chatInput.text) == "") {
			this.chatInput.text = "";
			return;
		}
		var _loc2_:Int = 0;
		var _loc3_:String = "0";
		var _loc4_:String = "0";
		if (this.me) {
			_loc4_ = Reflect.field(MData.getInstance().mainData.host, "uId");
		} else {
			_loc4_ = MData.getInstance().mainData.currentUserId;
		}
		if (this.sendToId != "0") {
			_loc3_ = this.sendToId;
			_loc2_ = 1;
		} else {
			_loc3_ = _loc4_;
		}
		var _loc5_:String = this.chatInput.text;
		_loc5_ = As3.replaceFirst(_loc5_, "\r", " ");
		Command.getInstance().mainCommand.sendChat(_loc3_, _loc4_, _loc2_, _loc5_, this.tName);
		this.chatInput.text = "";
		this.replyLabel.visible = false;
		this.sendToId = "0";
	}

	// ProfileMsg.as:218-302（_loc11_:friendList 原版取了未用，略）
	private function genMsg(param1:Dynamic):String {
		var _loc6_:String = null;
		var _loc13_:String = null;
		var _loc2_:String = "";
		var _loc3_:String = As3.or(Reflect.field(param1, "fromName"), "");
		if (_loc3_ != "null") {
			_loc3_ = StringTools.replace(_loc3_, "&", "&amp;");
			_loc3_ = StringTools.replace(_loc3_, "<", "&lt;");
			_loc3_ = StringTools.replace(_loc3_, ">", "&gt;");
		}
		var _loc4_:String = As3.or(Reflect.field(param1, "toName"), "");
		if (_loc4_ != "null") {
			_loc4_ = StringTools.replace(_loc4_, "&", "&amp;");
			_loc4_ = StringTools.replace(_loc4_, "<", "&lt;");
			_loc4_ = StringTools.replace(_loc4_, ">", "&gt;");
		}
		if (As3.truthy(Reflect.field(param1, "color"))) {
			_loc3_ = "<font color='" + Reflect.field(param1, "color") + "'>" + _loc3_ + "</font>";
		}
		var _loc5_:String = "0";
		if (MData.getInstance().mainData.me) {
			_loc5_ = MData.getInstance().mainData.currentUserId;
		}
		if (_loc5_ == "0" || As3.eqString(Reflect.field(param1, "fromId"), _loc5_)) {
			_loc6_ = "";
		} else {
			_loc6_ = "<a href='event:" + Reflect.field(param1, "fromId") + "," + _loc3_ + "'><font color='#0099FF'>回复</font></a>";
		}
		var _loc7_:String = As3.unescape(Std.string(Reflect.field(param1, "msg")));
		var _loc8_:String = "";
		_loc7_ = StringTools.replace(_loc7_, "&", "&amp;");
		_loc7_ = StringTools.replace(_loc7_, "<", "&lt;");
		_loc7_ = StringTools.replace(_loc7_, ">", "&gt;");
		var _loc9_:String = "";
		var _loc10_:Array<Dynamic> = ["", "空间", "校友"];
		if (LocalData.mode == "qzone") {
			_loc10_[1] = "";
		} else {
			_loc10_[2] = "";
		}
		if (As3.hasProp(param1, "domain")) {
			_loc9_ = As3.arrayIndex(_loc10_, Std.string(Reflect.field(param1, "domain")));
		}
		if (!As3.hasProp(param1, "isReply") || As3.floatOf(Reflect.field(param1, "isReply")) == 0) {
			_loc8_ = _loc9_ + "<font color='#009900'><b>" + _loc3_ + ":</b></font> " + _loc7_;
		} else {
			_loc8_ = _loc9_ + "<font color='#009900'><b>" + _loc3_ + "</b></font> 回复 <font color='#009900'><b>" + _loc4_ + ":</b></font> " + _loc7_;
		}
		var _loc12_:Date = Date.fromTime(As3.floatOf(Reflect.field(param1, "time")) * 1000);
		var _loc14_:String = this.twoData(_loc12_.getHours());
		var _loc15_:String = this.twoData(_loc12_.getMinutes());
		if (this.compareDate(_loc12_, Date.fromTime(CommonData.serverTime * 1000)) == 0) {
			_loc13_ = "    " + "今天" + _loc14_ + ":" + _loc15_;
		} else if (this.compareDate(_loc12_, Date.fromTime(CommonData.serverTime * 1000)) == 1) {
			_loc13_ = "    " + "昨天" + _loc14_ + ":" + _loc15_;
		} else if (this.compareDate(_loc12_, Date.fromTime(CommonData.serverTime * 1000)) == 2) {
			_loc13_ = "    " + "前天" + _loc14_ + ":" + _loc15_;
		} else {
			_loc13_ = this.twoData(_loc12_.getMonth() + 1) + "-" + this.twoData(_loc12_.getDate()) + " " + _loc14_ + ":" + _loc15_;
		}
		return "<b>" + _loc13_ + "</b>  " + _loc8_ + "  " + _loc6_ + "<br>";
	}

	// ProfileMsg.as:304-307
	public var me(get, set):Bool;

	private function get_me():Bool {
		return this._me;
	}

	private function set_me(param1:Bool):Bool {
		this._me = param1;
		return param1;
	}

	// ProfileMsg.as:309-316
	private function chatInputKeyDown(param1:KeyboardEvent):Void {
		param1.stopPropagation();
		if (param1.keyCode == 13) {
			this.sendMsg();
		}
	}

	// ProfileMsg.as:323-329
	private function compareDate(param1:Date, param2:Date):Int {
		param1 = new Date(param1.getFullYear(), param1.getMonth(), param1.getDate(), 0, 0, 0);
		param2 = new Date(param2.getFullYear(), param2.getMonth(), param2.getDate(), 0, 0, 0);
		var _loc3_:Float = param2.getTime() - param1.getTime();
		return Std.int(_loc3_ / 3600 / 24 / 1000);
	}

	// ProfileMsg.as:331-339
	private function replyClickHandler(param1:TextEvent):Void {
		var _loc2_:Array<Dynamic> = param1.text.split(",");
		this.replyLabel.text = "回复" + _loc2_[1] + ": ";
		this.tName = _loc2_[1];
		this.replyLabel.visible = true;
		this.sendToId = _loc2_[0];
		stage.focus = this.chatInput;
	}
}
