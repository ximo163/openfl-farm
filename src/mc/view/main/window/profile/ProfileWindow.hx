package mc.view.main.window.profile;

import com.lipi.LipiUtil;
import com.minutes.ui.control.JerryTabNavigation;
import com.minutes.ui.core.UIEvent;
import common.LocalData;
import common.MaterialLib;
import openfl.events.Event;
import openfl.filters.GlowFilter;
import mc.control.Command;
import mc.model.MData;
import mc.model.MainData;
import mc.model.ModelEvent;
import mc.view.ViewEvent;
import mc.view.common.BaseWindow;
import mc.view.common.DataLoading;
import shim.As3;

/**
 * mc.view.main.window.profile.ProfileWindow —— ProfileWindow.as 逐句对应
 * （issue #19）。牧场个人信息窗：头卡 + 五页签（消息/留言/成果/消费/系统）
 * + 加载/错误层。原文件
 * legacy/decompiled/Master2_v_142/scripts/mc/view/main/window/profile/ProfileWindow.as。
 */
@:keep
class ProfileWindow extends BaseWindow {
	private var _selected:Int = 0;

	private var mainData:MainData;

	private var profileCost:ProfileCost;

	private var profileMsg:ProfileMsg;

	private var profileLog:ProfileLog;

	private var profileSystemMsg:ProfileSystemMsg;

	private var profileHistory:ProfileHistory;

	private var profileHead:ProfileHead;

	private var dataLoading:DataLoading;

	private var profileNav:JerryTabNavigation;

	private var _me:Bool = false;

	public function new() {
		super();
		titleIMG = MaterialLib.getInstance().getClass("ProfileWindowTitle");
		windowName = "profile";
		width = 512;
		height = 420;
		mode = true;
	}

	// ProfileWindow.as:53-75
	private function profileChange(param1:ModelEvent):Void {
		if (As3.hasProp(this.mainData.profile, "user")) {
			this.profileHead.data = Reflect.field(this.mainData.profile, "user");
		}
		if (As3.hasProp(this.mainData.profile, "log")) {
			this.profileLog.dataList = Reflect.field(this.mainData.profile, "log");
		}
		if (As3.hasProp(this.mainData.profile, "chat")) {
			this.profileMsg.dataList = Reflect.field(this.mainData.profile, "chat");
		}
		if (As3.hasProp(this.mainData.profile, "repertory")) {
			this.profileHistory.dataList = Reflect.field(this.mainData.profile, "repertory");
		}
		if (As3.hasProp(this.mainData.profile, "info")) {
			// 原版门查 "info"、读 "data"（ProfileWindow.as:71-74）——键不一致，
			// 照抄不修；deviations 候选待人裁决
			this.profileSystemMsg.dataList = Reflect.field(this.mainData.profile, "data");
		}
	}

	// ProfileWindow.as:77-96
	public var selected(get, set):Int;

	private function set_selected(param1:Int):Int {
		if (param1 < 0) {
			this.me = true;
		} else {
			this.me = false;
		}
		if (this.profileNav != null) {
			this.profileNav.selectedIndex = param1;
		}
		this._selected = param1;
		if (this.profileMsg != null && this._selected == 1) {
			this.profileMsg.chatInput.text = "";
		}
		return param1;
	}

	// ProfileWindow.as:98-106
	public var me(get, set):Bool;

	private function set_me(param1:Bool):Bool {
		this._me = param1;
		if (this.profileMsg != null) {
			this.profileMsg.me = param1;
		}
		ProfileHistory.me = param1;
		return param1;
	}

	private function get_me():Bool {
		return this._me;
	}

	private function get_selected():Int {
		return this._selected;
	}

	// ProfileWindow.as:108-168
	override public function init(param1:openfl.geom.Rectangle = null):Void {
		this.mainData = MData.getInstance().mainData;
		this.profileHead = new ProfileHead();
		this.profileHead.visible = !this.mainData.profileLoading;
		this.profileHead.x = 0;
		this.profileHead.y = 25;
		addChild(this.profileHead);
		if (this.mainData.profile != null) {
			this.profileHead.data = Reflect.field(this.mainData.profile, "user");
		}
		this.profileNav = new JerryTabNavigation();
		this.profileNav.visible = !this.mainData.profileLoading;
		this.profileNav.selectedFontStyle(12, 16777215, "", false);
		this.profileNav.defaultFontStyle(12, 16777215);
		this.profileNav.menuLeftDistance = 16;
		this.profileNav.menuSpaceDistance = 3;
		this.profileNav.menuDefaultButtonWidth = 55;
		this.profileNav.menuDefaultButtonHeight = 22;
		this.profileNav.menuHeight = 27;
		this.profileNav.topHeight = 2;
		this.profileNav.x = 9;
		this.profileNav.y = 150;
		this.profileNav.width = this.width - 8;
		this.profileNav.menuBgClass = MaterialLib.getInstance().getClass("TabBg");
		this.profileNav.menuDefaultSkin = MaterialLib.getInstance().getClass("TabDefault");
		this.profileNav.menuSelectedSkin = MaterialLib.getInstance().getClass("TabSelected");
		this.profileNav.addEventListener(JerryTabNavigation.TAB_SELECT, this.tabSelect);
		addChild(this.profileNav);
		var _loc1_:GlowFilter = new GlowFilter(8541973, 1, 2, 2, 3, 1);
		this.profileLog = new ProfileLog();
		var _loc2_:String = "消息";
		var _loc3_:Int = Std.int(this.getStringWidth(_loc2_));
		this.profileNav.addItem(_loc2_, this.profileLog, _loc3_, 22, [_loc1_]);
		this.profileMsg = new ProfileMsg();
		_loc2_ = "留言";
		_loc3_ = Std.int(this.getStringWidth(_loc2_));
		this.profileNav.addItem(_loc2_, this.profileMsg, _loc3_, 22, [_loc1_]);
		this.profileHistory = new ProfileHistory();
		_loc2_ = "成果";
		_loc3_ = Std.int(this.getStringWidth(_loc2_));
		this.profileNav.addItem(_loc2_, this.profileHistory, _loc3_, 22, [_loc1_]);
		this.profileCost = new ProfileCost();
		_loc2_ = "消费";
		_loc3_ = Std.int(this.getStringWidth(_loc2_));
		this.profileNav.addItem(_loc2_, this.profileCost, _loc3_, 22);
		this.profileSystemMsg = new ProfileSystemMsg();
		_loc2_ = "系统";
		_loc3_ = Std.int(this.getStringWidth(_loc2_));
		this.profileNav.addItem(_loc2_, this.profileSystemMsg, _loc3_, 22);
		this.dataLoading = new DataLoading();
		this.dataLoading.addEventListener(ViewEvent.LINK_CLICK, this.linkClick);
		this.dataLoading.visible = this.mainData.profileLoading;
		this.dataLoading.x = width / 2;
		this.dataLoading.y = height / 2;
		addChild(this.dataLoading);
		this.mainData.addEventListener(MainData.PROFILE, this.profileChange, false, 0, true);
		this.mainData.addEventListener(MainData.PROFILE_LOADING, this.profileLoading, false, 0, true);
		this.mainData.addEventListener(MainData.PROFILE_ERR, this.profileErr, false, 0, true);
	}

	// ProfileWindow.as:170-174
	private function profileLoading(param1:Event):Void {
		this.dataLoading.visible = this.mainData.profileLoading;
		var _loc2_:Bool = !this.mainData.profileLoading;
		this.profileNav.visible = _loc2_;
		this.profileHead.visible = _loc2_;
	}

	// ProfileWindow.as:186-192
	private function linkClick(param1:ViewEvent):Void {
		if (As3.eqString(param1.data, "reload")) {
			Command.getInstance().mainCommand.getAllInfo(this.me, this.selected);
		}
	}

	// ProfileWindow.as:194-208
	private function tabSelect(param1:UIEvent = null):Void {
		if (As3.floatOf(param1.data) == 0) {
			Command.getInstance().mainCommand.getAllInfo(this.me, 0);
		} else if (As3.floatOf(param1.data) == 1) {
			Command.getInstance().mainCommand.getAllInfo(this.me, 1);
		} else if (As3.floatOf(param1.data) == 4) {
			Command.getInstance().mainCommand.getAllInfo(this.me, 4);
		}
	}

	// ProfileWindow.as:210-230
	override public function addedToLayer():Void {
		super.addedToLayer();
		this.profileNav.selectedIndex = this.selected;
		var _loc1_:Int = 0;
		if (this.selected > 0) {
			_loc1_ = 1;
		}
		Command.getInstance().mainCommand.getAllInfo(this.me, _loc1_);
		if (this.profileMsg != null) {
			this.profileMsg.hideReply();
		}
		if (this.profileCost != null) {
			this.profileCost.requireReload = true;
		}
		this.profileNav.menu.getItem(3).visible = this.mainData.me || LocalData.isMe;
		this.profileNav.menu.getItem(4).visible = this.mainData.me || LocalData.isMe;
	}

	// ProfileWindow.as:232-239
	override private function closeHandler():Void {
		super.closeHandler();
		this.profileNav.selectedIndex = 0;
		MainData.loadedProfile = false;
		MainData.loadedMsg = false;
		MainData.loadedSystemMsg = false;
	}

	// ProfileWindow.as:241-244
	private function profileErr(param1:Event):Void {
		this.dataLoading.errorText = this.mainData.profileErr;
	}

	// ProfileWindow.as:246-255
	private function getStringWidth(param1:String, param2:Int = 55, param3:Int = 10):Float {
		var _loc4_:Float = LipiUtil.getTextLangth(param1);
		_loc4_ = _loc4_ + param3 * 2;
		if (_loc4_ < param2) {
			_loc4_ = param2;
		}
		return _loc4_;
	}
}
