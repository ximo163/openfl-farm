package mc.view.main.window.profile;

import com.minutes.ui.control.LipiTextArea;
import common.INI;
import common.LocalData;
import openfl.display.Sprite;
import openfl.errors.TypeError;
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
 * mc.view.main.window.profile.ProfileLog —— ProfileLog.as 逐句对应
 * （issue #19）。牧场个人信息窗「消息」页：动态流 + 清空 + 单向好友提示。
 * 原文件
 * legacy/decompiled/Master2_v_142/scripts/mc/view/main/window/profile/ProfileLog.as。
 *
 * PORT-NOTE: genMsg 的 `RegExp("<b>(.*)</b>").exec[1]` 无匹配时原文抛
 * TypeError #1010 中断整页渲染——照译崩溃语义（openfl.errors.TypeError），
 * 不加静默守卫。
 */
@:keep
class ProfileLog extends Sprite {
	private var aLipiList:LipiTextArea;

	private var delLogLabel:TextField;

	public function new() {
		super();
		this.aLipiList = new LipiTextArea();
		this.aLipiList.bgAlpha = 0;
		this.aLipiList.vLipiScrollBar.visible = false;
		this.aLipiList.width = 465;
		this.aLipiList.height = 190;
		this.aLipiList.x = 20;
		this.aLipiList.y = 2;
		this.aLipiList.type = TextFieldType.DYNAMIC;
		this.aLipiList.addEventListener(TextEvent.LINK, this.addFilterHandle);
		addChild(this.aLipiList);
		this.delLogLabel = new TextField();
		this.delLogLabel.autoSize = TextFieldAutoSize.LEFT;
		this.delLogLabel.selectable = false;
		this.delLogLabel.defaultTextFormat = new TextFormat("Verdana", null, 8999699);
		this.delLogLabel.htmlText = "<a href='event:del'>清空消息记录</a>";
		this.delLogLabel.addEventListener(TextEvent.LINK, this.delLog);
		this.delLogLabel.x = 30;
		this.delLogLabel.y = 180 + 18;
		addChild(this.delLogLabel);
		Command.getInstance().mainCommand.getFriendList();
	}

	// ProfileLog.as:49-62
	private function getFriendFlag(param1:Array<Dynamic>, param2:String):Bool {
		var _loc4_:Dynamic = null;
		var _loc3_:Bool = false;
		for (_loc4_ in param1) {
			if (As3.eqString(Reflect.field(_loc4_, "uin"), param2)) {
				_loc3_ = true;
				break;
			}
		}
		return _loc3_;
	}

	// ProfileLog.as:64-84
	private function addFilterHandle(param1:TextEvent):Void {
		var _loc2_:String = param1.text.split(",")[0];
		var _loc3_:String = param1.text.split(",")[1];
		var _loc4_:String = "";
		_loc4_ = _loc4_ + "<p align='left'><font color='#009900'><b>";
		if (As3.truthy(_loc3_)) {
			_loc3_ = StringTools.replace(_loc3_, "<", "&lt;");
			_loc3_ = StringTools.replace(_loc3_, ">", "&gt;");
			_loc4_ += _loc3_;
		}
		if (As3.truthy(_loc2_)) {
			_loc4_ += "(QQ:" + _loc2_ + ")";
		}
		var _loc5_:String = "http://blog.qq.com/qzone/1006666002/1300264199.htm";
		// PORT-NOTE(E4X)：原版 `INI.getInstance().data.logic.urlFriend.@url`
		// 读 XML 配置属性；INI 为 mcloader stub、data 恒 null，链式取值落
		// null，`|| ""` 兜底与生产（配置缺该属性）一致。
		var _loc6_:String = As3.or(Reflect.field(Reflect.field(Reflect.field(INI.getInstance().data, "logic"), "urlFriend"), "url"), "");
		_loc4_ += "</b></font> 可能不是您的好友，您可以进入“我的QQ中心”删除单向好友，防止对方进入您的农/牧场摘取等操作。<br/>或者 <font color='#0000FF'><u><b><a href='event:"
			+ _loc6_ + "' target='_blank'>前往管理您的单向好友</a></b></u>。</font></p>"
			+ "<p align='right'><font color='#0000FF'><u><a href='event:" + _loc5_ + "' target='_blank'>详细</a></u></font></p>";
		Command.getInstance().mainCommand.alertWindow("tip", _loc4_, true);
	}

	// ProfileLog.as:86-89
	private function delLogConfirm():Void {
		Command.getInstance().mainCommand.clearLog();
	}

	// ProfileLog.as:91-109（AS3 for-each over null 零次迭代，Haxe 会抛，
	// 加 null 守卫等价）
	public var dataList(never, set):Array<Dynamic>;

	private function set_dataList(param1:Array<Dynamic>):Array<Dynamic> {
		var _loc3_:Dynamic = null;
		this.delLogLabel.visible = MData.getInstance().mainData.me;
		var _loc2_:String = "";
		if (param1 != null) {
			for (_loc3_ in param1) {
				_loc2_ += this.genMsg(_loc3_);
			}
		}
		this.aLipiList.htmlText = "<textformat leading='8'><font face='Verdana'>" + _loc2_ + "</font></textformat>";
		if (this.aLipiList.textField.numLines > 9) {
			this.aLipiList.vLipiScrollBar.visible = true;
		} else {
			this.aLipiList.vLipiScrollBar.visible = false;
		}
		return param1;
	}

	// ProfileLog.as:111-195
	private function genMsg(param1:Dynamic):String {
		var _loc7_:String = null;
		var _loc11_:String = null;
		var _loc14_:Int = 0;
		var _loc2_:String = "";
		var _loc3_:String = Std.string(Reflect.field(param1, "msg"));
		var _loc4_:String = new EReg("(.*?)\\|(.*?)\\|(.*)", "").replace(_loc3_, "$2");
		var _loc5_:Array<Dynamic> = MData.getInstance().mainData.friendList;
		var _loc6_:String = "";
		var _loc8_:String = "";
		var _loc9_:Array<Dynamic> = ["", "空间", "校友", "空间"];
		if (LocalData.mode == "qzone") {
			_loc9_[1] = "";
			_loc9_[3] = "";
		} else {
			_loc9_[2] = "";
		}
		if (As3.hasProp(param1, "domain")) {
			_loc8_ = As3.arrayIndex(_loc9_, Std.string(Reflect.field(param1, "domain")));
		}
		if (_loc4_.length < 12) {
			if (_loc5_ != null) {
				_loc14_ = 0;
				while (_loc14_ < _loc5_.length) {
					if (Std.string(Reflect.field(_loc5_[_loc14_], "uId")) == _loc4_) {
						_loc6_ = Reflect.field(_loc5_[_loc14_], "userName");
						break;
					}
					_loc14_++;
				}
			} else {
				_loc6_ = _loc4_;
			}
			_loc7_ = _loc8_ + new EReg("(.*?)\\|(.*?)\\|(.*?)", "").replace(_loc3_,
				"$1<a href='event:" + _loc4_ + "'><font color='#009900'><b>" + _loc6_ + "</b></font></a>$3");
		} else {
			_loc7_ = _loc8_ + _loc3_;
		}
		var _loc10_:Date = Date.fromTime(As3.floatOf(Reflect.field(param1, "time")) * 1000);
		var _loc12_:String = this.twoData(_loc10_.getHours());
		var _loc13_:String = this.twoData(_loc10_.getMinutes());
		if (this.compareDate(_loc10_, Date.now()) == 0) {
			_loc11_ = "    " + "今天" + _loc12_ + ":" + _loc13_;
		} else if (this.compareDate(_loc10_, Date.now()) == 1) {
			_loc11_ = "    " + "昨天" + _loc12_ + ":" + _loc13_;
		} else if (this.compareDate(_loc10_, Date.now()) == 2) {
			_loc11_ = "    " + "前天" + _loc12_ + ":" + _loc13_;
		} else {
			_loc11_ = this.twoData(_loc10_.getMonth() + 1) + "-" + this.twoData(_loc10_.getDate()) + " " + _loc12_ + ":" + _loc13_;
		}
		if (LocalData.mode == "qzone" && MData.getInstance().mainData.me) {
			if (As3.floatOf(Reflect.field(param1, "domain")) == 1 && As3.truthy(Reflect.field(param1, "qq")) && _loc3_.indexOf("来牧场收获,收走了") > 0) {
				if (_loc5_ != null && !this.getFriendFlag(_loc5_, Std.string(Reflect.field(param1, "qq")))) {
					var _loc15_:EReg = new EReg("<b>(.*)</b>", "");
					var _loc16_:String = null;
					// 原文 :189 `_loc16_ = _loc15_.exec(_loc3_)[1]`：exec
					// 无匹配得 null、null[1] 抛 TypeError #1010，从 genMsg 一路
					// 中断整页 dataList 渲染——照译崩溃语义，不加静默守卫
					if (!_loc15_.match(_loc3_)) {
						// openfl 的 TypeError 构造器只收 message（无 id 形参，
					// flash.errors.TypeError 的第二个参数 1010 并进消息文本）
					throw new TypeError("Error #1010: A term is undefined and has no properties.");
					}
					_loc16_ = _loc15_.matched(1);
					_loc7_ += "\t<a href='event:" + Reflect.field(param1, "qq") + "," + _loc16_
						+ "'><font color='#FF6600'><b><u>不让他收</u></b></font></a>";
				}
			}
		}
		return "<b>" + _loc11_ + "</b>  " + _loc7_ + "<br>";
	}

	// ProfileLog.as:197-203
	private function compareDate(param1:Date, param2:Date):Int {
		param1 = new Date(param1.getFullYear(), param1.getMonth(), param1.getDate(), 0, 0, 0);
		param2 = new Date(param2.getFullYear(), param2.getMonth(), param2.getDate(), 0, 0, 0);
		// 原文 `var _loc3_:int = Math.abs(...)`：|Δms| 过 2^31（≈24.9 天）
		// 按 int32 回绕——约 49.7-52.6 天的流水回绕成 0/1/2、被错标成
		// 今天/昨天/前天（24.9-49.7 天回绕成负数、仍走真实日期支），原版
		// bug 照抄（js/eval 的 Int 不回绕，走 As3.int32）
		var _loc3_:Int = As3.int32(Math.abs(param2.getTime() - param1.getTime()));
		return Std.int(_loc3_ / 3600 / 24 / 1000);
	}

	// ProfileLog.as:205-211
	private function delLog(param1:TextEvent):Void {
		var _loc2_:ConfirmWindow = new ConfirmWindow();
		_loc2_.data = {"text": "确认清空消息记录？"};
		_loc2_.confirmFn = this.delLogConfirm;
		WControl.open(_loc2_);
	}

	// ProfileLog.as:213-220
	private function twoData(param1:Int):String {
		if (param1 < 10) {
			return "0" + Std.string(param1);
		}
		return Std.string(param1);
	}
}
