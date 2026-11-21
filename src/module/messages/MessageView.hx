package module.messages;

import com.qzone.qui.containers.ViewStack;
import com.qzone.qui.controls.TabBar;
import common.Consts;
import common.Language;
import common.Session;
import common.view.DataLoading;
import common.view.window.BaseWindow;
import common.view.window.WindowTabBarMaker;
import events.CommonEvent;
import events.ViewEvent;
import framework.base.BaseTileItem;
import interfaces.IMsgCenter;
import module.messages.widgets.ProfileCost;
import module.messages.widgets.ProfileHead;
import module.messages.widgets.ProfileHistory;
import module.messages.widgets.ProfileLog;
import module.messages.widgets.ProfileMsg;
import module.messages.widgets.ProfileSystemMsg;
import openfl.display.DisplayObject;
import openfl.display.Sprite;
import openfl.events.Event;
import shim.As3;

/**
 * module.messages.MessageView —— MessageView.as 逐句对应（issue #19）。
 * 个人信息窗：ProfileHead 头部 + TabBar 六页签（消息/留言/成果/成鱼/消费/系统）
 * 挂 ViewStack，loading 遮罩盖头/签/栈；按 model 事件的 index 分发各页数据。
 */
class MessageView extends BaseWindow {
	// MessageView.as:21
	private var _selected:Int;

	// MessageView.as:23
	private var _systemMsgPage:ProfileSystemMsg;

	// MessageView.as:25
	private var _historyPage:ProfileHistory;

	// MessageView.as:27
	private var _billPage:ProfileCost;

	// MessageView.as:29
	private var _vs:ViewStack;

	// MessageView.as:31
	private var _fishPage:ProfileHistory;

	// MessageView.as:33
	private var _navbar:TabBar;

	// MessageView.as:35
	private var _logPage:ProfileLog;

	// MessageView.as:37
	private var _messagePage:ProfileMsg;

	// MessageView.as:39
	private var _controller:MessageController;

	// MessageView.as:41
	private var _loading:DataLoading;

	// MessageView.as:43
	private var _head:ProfileHead;

	public function new(param1:MessageController) {
		// `param1.module.app as IMsgCenter`：FarmApplication 静态实现该接口
		super(cast(param1.module.app, IMsgCenter));
		title = Reflect.field(Language.L, "个人信息");
		windowName = Consts.WINDOW_NAME_PROFILE;
		width = 500;
		height = 400;
		mode = true;
		this._selected = 0;
		this._controller = param1;
	}

	// MessageView.as:63-77
	public var selected(get, set):Int;

	private function get_selected():Int {
		return this._selected;
	}

	private function set_selected(param1:Int):Int {
		if (param1 < 0) {
			param1 = 0;
		}
		this._selected = param1;
		if (this._navbar != null) {
			this._navbar.selectedIndex = param1;
		}
		if (this._messagePage != null && this._selected == 1) {
			this._messagePage.reset();
		}
		return param1;
	}

	// MessageView.as:79-82
	private function onHistoryItemOut(param1:ViewEvent):Void {
		this.controller.hideTip();
	}

	// MessageView.as:84-87
	private function onLogCleared(param1:CommonEvent):Void {
		this.controller.model.reloadAll();
	}

	// MessageView.as:89-92
	public var controller(get, never):MessageController;

	private function get_controller():MessageController {
		return this._controller;
	}

	// MessageView.as:94-102
	private function showLoading(param1:Bool):Void {
		if (this._loading.visible == param1) {
			return;
		}
		this._loading.visible = param1;
		this._head.visible = !param1;
		this._navbar.visible = !param1;
		this._vs.visible = !param1;
	}

	// MessageView.as:104-166
	override private function init():Void {
		this._head = new ProfileHead();
		this._head.x = 0;
		this._head.y = 25;
		this._head.visible = false;
		addChild(this._head);
		this._vs = new ViewStack();
		this._vs.width = width - 2;
		this._navbar = new TabBar();
		WindowTabBarMaker.addTarget(this._navbar);
		this._navbar.x = 0;
		this._navbar.y = 150;
		this._navbar.width = width - 2;
		this._navbar.viewStack = this._vs;
		this._vs.y = this._navbar.y + this._navbar.height;
		this._vs.height = height - this._vs.y;
		this._logPage = new ProfileLog(this);
		this._navbar.addTab(Reflect.field(Language.L, "消息"), Math.NaN, 24);
		this._vs.addView(this._logPage);
		this._messagePage = new ProfileMsg(this);
		this._navbar.addTab(Reflect.field(Language.L, "留言"), Math.NaN, 24);
		this._vs.addView(this._messagePage);
		this._historyPage = new ProfileHistory();
		this._navbar.addTab(Reflect.field(Language.L, "成果"), Math.NaN, 24);
		this._vs.addView(this._historyPage);
		this._historyPage.addEventListener(BaseTileItem.CHILD_OVER, this.onHistoryItemOver, false, 0, true);
		this._historyPage.addEventListener(BaseTileItem.CHILD_OUT, this.onHistoryItemOut, false, 0, true);
		this._fishPage = new ProfileHistory();
		this._navbar.addTab("成鱼", Math.NaN, 24);
		this._vs.addView(this._fishPage);
		this._fishPage.addEventListener(BaseTileItem.CHILD_OVER, this.onHistoryItemOver, false, 0, true);
		this._fishPage.addEventListener(BaseTileItem.CHILD_OUT, this.onHistoryItemOut, false, 0, true);
		this._billPage = new ProfileCost(this);
		this._navbar.addTab("消费", Math.NaN, 24);
		this._vs.addView(this._billPage);
		this._systemMsgPage = new ProfileSystemMsg(this);
		this._navbar.addTab("系统", Math.NaN, 24);
		this._vs.addView(this._systemMsgPage);
		this._loading = new DataLoading();
		this._loading.addEventListener(ViewEvent.LINK_CLICK, this.onLinkClicked);
		this._loading.visible = false;
		this._loading.x = width / 2;
		this._loading.y = height / 2 + 20;
		addChild(this._loading);
		this.controller.model.addEventListener(MessageModel.EVENT_DATA_CHANGED, this.onDataChanged, false, 0, true);
		this.controller.model.addEventListener(MessageModel.EVENT_DATA_FAILED, this.onDataError, false, 0, true);
		this.controller.model.addEventListener(MessageModel.EVENT_DATA_LOADING, this.onDataLoading, false, 0, true);
		this.controller.model.addEventListener(MessageModel.EVENT_LOG_CLEARED, this.onLogCleared, false, 0, true);
		this._navbar.visible = false;
		this._vs.visible = false;
		addChild(this._vs);
		addChild(this._navbar);
		this._navbar.addEventListener(Event.CHANGE, this.onTabSwitched);
	}

	// MessageView.as:168-241
	private function onDataChanged(param1:CommonEvent):Void {
		if (param1 == null || param1.data == null) {
			return;
		}
		this.showLoading(false);
		var _loc2_:String = Reflect.field(param1.data, "index");
		var _loc3_:Dynamic = Reflect.field(param1.data, "data");
		if (_loc2_ == "user") {
			this._head.data = Reflect.field(_loc3_, "user");
		} else if (_loc2_ == "log") {
			if (Std.isOfType(Reflect.field(_loc3_, "log"), Array)) {
				this._logPage.dataList = Reflect.field(_loc3_, "log");
			} else {
				this._logPage.dataList = null;
			}
		} else if (_loc2_ == "chat") {
			if (Std.isOfType(Reflect.field(_loc3_, "chat"), Array)) {
				this._messagePage.dataList = Reflect.field(_loc3_, "chat");
			} else {
				this._messagePage.dataList = null;
			}
		} else if (_loc2_ == "repertory") {
			if (Std.isOfType(Reflect.field(_loc3_, "repertory"), Array)) {
				this._historyPage.dataList = Reflect.field(_loc3_, "repertory");
			} else {
				this._historyPage.dataList = null;
			}
		} else if (_loc2_ == "cost") {
			if (Std.isOfType(Reflect.field(_loc3_, "cost"), Array)) {
				this._billPage.dataList = Reflect.field(_loc3_, "cost");
			} else {
				this._billPage.dataList = null;
			}
		} else if (_loc2_ == "systemMsg") {
			if (Std.isOfType(Reflect.field(_loc3_, "systemMsg"), Array)) {
				this._systemMsgPage.dataList = Reflect.field(_loc3_, "systemMsg");
			} else {
				this._systemMsgPage.dataList = null;
			}
		} else if (_loc2_ == "fish") {
			if (Std.isOfType(Reflect.field(_loc3_, "fish"), Array)) {
				this._fishPage.dataList = Reflect.field(_loc3_, "fish");
			} else {
				this._fishPage.dataList = null;
			}
		}
	}

	// MessageView.as:243-250
	private function onDataLoading(param1:CommonEvent):Void {
		if (param1 == null || param1.data == null) {
			return;
		}
		// `param1.data as Boolean`：非 Boolean 载荷按 as 落 null→false，不收 truthy
		this.showLoading(Std.isOfType(param1.data, Bool) ? (param1.data : Bool) : false);
	}

	// MessageView.as:252-255
	public var me(get, never):Bool;

	private function get_me():Bool {
		return this.controller.model.me;
	}

	// MessageView.as:257-284
	override private function onClose(param1:Event):Void {
		this._head.showPhotoPic(false);
		this.controller.model.reset();
		if (this._selected == 0) {
			this._logPage.dataList = null;
		} else if (this._selected == 1) {
			this._messagePage.dataList = null;
		} else if (this._selected == 2) {
			this._historyPage.dataList = null;
		} else if (this._selected == 3) {
			this._billPage.dataList = null;
		} else if (this._selected == 4) {
			this._systemMsgPage.dataList = null;
		}
		super.onClose(param1);
	}

	// MessageView.as:286-292
	private function onDataError(param1:CommonEvent):Void {
		this.showLoading(true);
		if (param1 != null && param1.data != null) {
			this._loading.errorText = Reflect.field(param1.data, "error");
		}
	}

	// MessageView.as:294-313
	public function switchPage(param1:Int, param2:Bool):Void {
		if (this._navbar != null && this._vs != null) {
			if (param1 >= 0 && param1 < 5) {
				this.selected = param1;
			}
		}
		this._head.showPhotoPic(true);
		var _loc3_:DisplayObject = this._navbar.content.getChildAt(4);
		if (_loc3_ != null) {
			_loc3_.visible = param2 ? true : false;
		}
		this._billPage.visible = param2 ? true : false;
		_loc3_ = this._navbar.content.getChildAt(5);
		if (_loc3_ != null) {
			_loc3_.visible = param2 ? true : false;
		}
		this._systemMsgPage.visible = param2 ? true : false;
	}

	// MessageView.as:315-319
	private function onTabSwitched(param1:Event):Void {
		this._selected = this._navbar.selectedIndex;
		this.controller.model.loadData(this._navbar.selectedIndex);
	}

	// MessageView.as:321-324
	private function onHistoryItemOver(param1:ViewEvent):Void {
		this.controller.showTip(Consts.TIP_NAME_PROFILE_HISTORY, param1.data);
	}

	// MessageView.as:326-341
	override private function setData():Void {
		this.graphics.clear();
		if (this._messagePage != null) {
			this._messagePage.hideReply();
		}
		var _loc1_:Sprite = null;
		// `as Sprite`：非 Sprite 落 null
		if (Std.isOfType(this._navbar.content.getChildAt(3), Sprite)) {
			_loc1_ = cast(this._navbar.content.getChildAt(3), Sprite);
		}
		if (_loc1_ != null) {
			_loc1_.visible = Session.getInstance().me;
		}
		if (Std.isOfType(this._navbar.content.getChildAt(4), Sprite)) {
			_loc1_ = cast(this._navbar.content.getChildAt(4), Sprite);
		} else {
			_loc1_ = null;
		}
		if (_loc1_ != null) {
			_loc1_.visible = Session.getInstance().me;
		}
	}

	// MessageView.as:343-348
	private function onLinkClicked(param1:ViewEvent):Void {
		// AS3 宽松 ==：Number 一侧按 Number("reload")=NaN 比较（恒 false）
		if (As3.eqString(param1.data, "reload")) {
			this.controller.model.loadData(this.selected);
		}
	}

	// MessageView.as:350-353
	public var disableAnimation(get, never):Bool;

	private function get_disableAnimation():Bool {
		return true;
	}
}
