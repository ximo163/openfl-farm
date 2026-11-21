package module.friend;

import com.qzone.allianceActivity.AllianceActivityManager;
import com.qzone.allianceActivity.interfaces.IAllianceActivityContext;
import com.qzone.farm.api.interfaces.IPluginProxy;
import com.qzone.qfa.events.CommandEvent;
import com.qzone.qui.makers.ButtonMaker;
import com.qzone.qui.makers.TipInputMaker;
import common.CommonData;
import common.Consts;
import common.FeartureManager;
import common.Session;
import common.Settings;
import common.misc.Cookies;
import common.misc.QzoneJSAPI;
import common.misc.Utils;
import common.view.DataLoading;
import entities.Friend;
import events.CommonEvent;
import events.ViewEvent;
import openfl.display.MovieClip;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.FocusEvent;
import openfl.events.MouseEvent;
import openfl.events.TextEvent;
import openfl.text.TextField;
import openfl.utils.Timer;
import framework.api.PluginManager;
import framework.api.beast.BeastAPI;
import framework.net.CommandDefs;
import framework.net.NetHelper;
import report.ClickReportManager;
import report.UserActionRecorder;
import shim.As3;
import shim.ClipProps;
// PORT-NOTE(qq-outlet)：flash.external.ExternalInterface → shim.QQOutlets
//（deviations qqoutlets-shim/no-qzone-jsapi；ShortcutBar/LevelUpWindow 同款）
import shim.QQOutlets;

/**
 * module.friend.FriendsView —— FriendsView.as（1057 loc）逐句对应。
 * 右侧好友列表面板：List_UI 皮肤装配（微博态换 List_Close/Open_WB 皮肤）、
 * 页码/排序/搜索/刷新按钮派发 VIEW_EVENT_*，行渲染走 FriendItemRender 池
 * （_itemCache 先备 10 只），开合动画是 ENTER_FRAME 位移（effHandler）。
 *
 * 事件 data 的 `as int`/`as Boolean` 键读按 BackgroundController 先例：
 * As3.intOf/truthy（派发方全是真实类型，语义一致；缺位 AS3 undefined→NaN/
 * null→false 同被覆盖）。`s_name` 是 FriendItemRender 经 ClipProps 写进状态
 * 角标的动态属性，读取同走 ClipProps（读写同通道，见 CLAUDE.md 动态属性规则）。
 * flash.utils.setTimeout → As3.setTimeout（Haxe 无内建，shim/As3.hx）。
 */
class FriendsView extends Sprite {
	// FriendsView.as:41-57（原版 internal static const → private；
	// FriendsController.initialze/onPageAction 带 @:access 跨类读）
	private static final VIEW_EVENT_RELOAD_FRIENDS:String = "ReloadFriends";

	private static final VIEW_EVENT_REFRESH_STATUS:String = "RefreshStatus";

	private static final VIEW_EVENT_FIRST_PAGE:String = "FirstPage";

	private static final VIEW_EVENT_BACK_PAGE:String = "BackPage";

	private static final VIEW_EVENT_NEXT_PAGE:String = "NextPage";

	private static final VIEW_EVENT_LAST_PAGE:String = "LastPage";

	private static final VIEW_EVENT_SEARCH:String = "Search";

	private static final VIEW_EVENT_SORT:String = "Sort";

	private static final VIEW_EVENT_COLLAPSE:String = "Collapse";

	// FriendsView.as:59-117（原版 private const/var 区，照抄字段序与默认值）
	private final hideRight:Float = 24;

	private var nextButton:MovieClip;

	private var searchTextField:TextField;

	private var sortByGoldButtonA:MovieClip;

	private final showRight:Float = 206;

	private var searchInputer:TipInputMaker;

	private var _controller:FriendsController;

	private var loading:DataLoading;

	private var _currentlyTimer:Timer;

	private var _fid:UInt;

	private var _friendListFilter:Dynamic;

	private var refurbishButton2:MovieClip;

	private var _page:Int = 0;

	private var pageTextShow:TextField;

	private var close_btn:MovieClip;

	private var _uin:UInt;

	private var refurbishButton:MovieClip;

	private var _levelSkin:Array<Dynamic>;

	private var _itemContainer:Sprite;

	private var _itemCache:Array<Dynamic>;

	private var listUI:Sprite;

	private var _filterUserId:Int;

	private var _countPage:Int = 0;

	private var backEndButton:MovieClip;

	private var _offsetValue:Int;

	private var sortByExpButtonA:MovieClip;

	private var open_btn:MovieClip;

	private var backButton:MovieClip;

	private var searchButton:MovieClip;

	private var _friendList:Array<Dynamic> = [];

	// FriendsView.as:119-143。FriendsModel.EVENT_* 原版 internal、移植 private，
	// 构造器跨类读 → @:access
	@:access(module.friend.FriendsModel)
	public function new(param1:FriendsController) {
		var _loc3_:FriendItemRender = null;
		super();
		this._controller = param1;
		this._itemContainer = null;
		this._currentlyTimer = null;
		this._levelSkin = null;
		this._offsetValue = 0;
		this._filterUserId = -1;
		this._itemCache = new Array();
		var _loc2_:Int = 0;
		while(_loc2_ < 10) {
			_loc3_ = this.createItem();
			this._itemCache.push(_loc3_);
			_loc2_++;
		}
		this.createView();
		addEventListener(Event.ADDED_TO_STAGE, this.onAddedToStage);
		this._controller.model.addEventListener(FriendsModel.EVENT_DATA_LOAD_FAILED, this.onDataLoadFailed, false, 0, true);
		this._controller.model.addEventListener(FriendsModel.EVENT_DATA_LOADING, this.onDataLoading, false, 0, true);
		this._controller.model.addEventListener(FriendsModel.EVENT_REFRESH_PAGE, this.onRefreshCurrentPage, false, 0, true);
		this._controller.model.addEventListener(FriendsModel.EVENT_HEAD_PIC_LOADED, this.onHeadPicLoaded, false, 0, true);
	}

	// FriendsView.as:145-171
	private function onMouseOver(param1:MouseEvent):Void {
		if(param1 == null || param1.target == null) {
			return;
		}
		if(param1.target == this.backButton) {
			this._controller.showTip(Consts.TIP_NAME_MOUSE, "上一页");
		} else if(param1.target == this.nextButton) {
			this._controller.showTip(Consts.TIP_NAME_MOUSE, "下一页");
		} else if(param1.target == this.refurbishButton) {
			this._controller.showTip(Consts.TIP_NAME_MOUSE, "刷新好友列表");
		} else if(param1.target == this.refurbishButton2) {
			this._controller.showTip(Consts.TIP_NAME_MOUSE,
				"点击即可快速显示好友列表中所有好友\n农田的可摘、可除草、可除虫状态。");
		} else if(param1.target == this.searchButton) {
			this._controller.showTip(Consts.TIP_NAME_MOUSE, "查找");
		}
	}

	// FriendsView.as:173-190（清行：条目回 clear()，容器按序摘除）
	private function del():Void {
		if(this._currentlyTimer != null) {
			this._currentlyTimer.stop();
		}
		var _loc1_:Int = this._itemContainer.numChildren;
		var _loc2_:Int = 0;
		while(_loc2_ < _loc1_) {
			if(Std.isOfType(this._itemContainer.getChildAt(0), FriendItemRender)) {
				cast(this._itemContainer.getChildAt(0), FriendItemRender).clear();
			}
			this._itemContainer.removeChildAt(0);
			_loc2_++;
		}
	}

	// FriendsView.as:192-201
	private function onRefreshCurrentPage(param1:CommonEvent):Void {
		if(param1 == null || param1.data == null) {
			return;
		}
		var _loc2_:Int = As3.intOf(Reflect.field(param1.data, "index"));
		var _loc3_:Int = As3.intOf(Reflect.field(param1.data, "total"));
		this.buildPage(Reflect.field(param1.data, "friends"), _loc2_, _loc3_);
	}

	// FriendsView.as:203-208
	private function onSearchBtnClicked(param1:Event):Void {
		param1.stopImmediatePropagation();
		dispatchEvent(new Event(VIEW_EVENT_SEARCH));
		UserActionRecorder.recordAction(UserActionRecorder.HF_FRIENDLIST_SEARCH);
	}

	// FriendsView.as:210-223
	private function onItemMouseOut(param1:MouseEvent):Void {
		if(param1 == null || param1.currentTarget == null) {
			return;
		}
		var _loc2_:FriendItemRender = cast(param1.currentTarget, FriendItemRender);
		if(_loc2_ == null) {
			return;
		}
		_loc2_.backBg();
		this._controller.hideTip();
	}

	// FriendsView.as:225-259（重建当前页：先备满 10 行，再按页数据 add）
	private function buildPage(param1:Array<Dynamic>, param2:Int, param3:Int):Void {
		var _loc5_:Int = 0;
		this.page = param2;
		this.countPage = param3;
		this._friendListFilter = this._controller.model.friendListFilter;
		this.del();
		this._friendList = [];
		if(param1 != null) {
			_loc5_ = 0;
			while(_loc5_ < param1.length) {
				this._friendList.push(param1[_loc5_]);
				_loc5_++;
			}
		}
		if(this._currentlyTimer != null) {
			this._currentlyTimer.stop();
			this._currentlyTimer = null;
		}
		var _loc4_:Int = 10;
		if(this._friendList.length < 10) {
			_loc4_ = this._friendList.length;
		}
		_loc5_ = 0;
		while(_loc5_ < _loc4_) {
			this.add();
			_loc5_++;
		}
		this.resetSeleted(Session.getInstance().currentUser._uId);
	}

	// FriendsView.as:261-268（set page；get 在 :668）
	public var page(get, set):Int;

	private function set_page(param1:Int):Int {
		this._page = param1;
		this.pageTextShow.text = this._page + " / " + this._countPage;
		var _loc2_:Bool = this._page == 1 ? false : true;
		this.backEndButton.visible = _loc2_;
		ButtonMaker.setEnabled(this.backButton, _loc2_);
		return param1;
	}

	// FriendsView.as:270-290
	private function onSortBtnClicked(param1:Event):Void {
		if(param1 == null || param1.target == null) {
			return;
		}
		if(param1.target == this.sortByExpButtonA) {
			ButtonMaker.setSelected(this.sortByGoldButtonA, false);
			ButtonMaker.setSelected(this.sortByExpButtonA, true);
			dispatchEvent(new CommonEvent(VIEW_EVENT_SORT, "exp"));
			UserActionRecorder.recordAction(UserActionRecorder.HF_FRIENDLIST_SORT_EXP);
		} else if(param1.target == this.sortByGoldButtonA) {
			ButtonMaker.setSelected(this.sortByGoldButtonA, true);
			ButtonMaker.setSelected(this.sortByExpButtonA, false);
			dispatchEvent(new CommonEvent(VIEW_EVENT_SORT, "money"));
			UserActionRecorder.recordAction(UserActionRecorder.HF_FRIENDLIST_SORT_GOLD);
		}
	}

	// FriendsView.as:292-313（召回请求失败：direction 在则转 MSG_BACK_UPDATE_STATUS
	// 给 FriendsController.onUpdataBack 走 cookie/ecode 分支，否则浮「系统繁忙」）
	private function onAppRequestFail(param1:CommandEvent):Void {
		if(As3.hasProp(param1.result.m_extra, "direction")) {
			this._controller.module.app.dispatchEvent(new CommonEvent(Consts.MSG_BACK_UPDATE_STATUS, {
				"ecode": (Reflect.field(param1.result.m_extra, "ecode") == null ? 0 : Reflect.field(param1.result.m_extra, "ecode")),
				"direction": (Reflect.field(param1.result.m_extra, "direction") == null ? "" : Reflect.field(param1.result.m_extra, "direction")),
				"t": 0,
				"uId": this._uin,
				"money": Reflect.field(param1.result.m_extra, "money"),
				"leftQuota": Reflect.field(param1.result.m_extra, "left_quota"),
				"servertime": (Reflect.field(param1.result.m_extra, "optime") == null ? CommonData.serverTime : Reflect.field(param1.result.m_extra, "optime"))
			}));
		} else {
			this._controller.openFloat(Consts.FLOAT_TYPE_TEXTTIP, {
				"text": "系统繁忙",
				"parent": this.stage
			});
		}
	}

	// FriendsView.as:315-333（无 null 守卫：容器里只会有 FriendItemRender）
	public function getRenderItemById(param1:UInt):FriendItemRender {
		if(this._itemContainer == null) {
			return null;
		}
		var _loc2_:FriendItemRender = null;
		var _loc3_:Int = 0;
		while(_loc3_ < this._itemContainer.numChildren) {
			_loc2_ = cast(this._itemContainer.getChildAt(_loc3_), FriendItemRender);
			if(_loc2_.fiendData._uId == param1 || _loc2_.fiendData._uin == param1) {
				return _loc2_;
			}
			_loc3_++;
		}
		return null;
	}

	// FriendsView.as:335-476（行点击分流：VIP 图鉴 / Status_z 召回 / mc_btn 牧场跳
	// 转 / 过滤提示 / 野兽 / 精灵 / 默认进农场；FFDec 把 currentTarget.fiendData
	// 显示成无类型点读，运行期对象就是 FriendItemRender，cast 后类型读等价）
	private function onItemClicked(param1:MouseEvent):Void {
		var _loc4_:IAllianceActivityContext = null;
		var _loc5_:UInt = 0;
		var _loc6_:String = null;
		var _loc7_:String = null;
		var _loc8_:Int = 0;
		var _loc9_:Int = 0;
		var _loc10_:String = null;
		var _loc11_:String = null;
		var _loc12_:Dynamic = null;
		var _loc13_:IPluginProxy = null;
		if(Session.getInstance().harvestAnimationPlaying == true) {
			return;
		}
		param1.stopImmediatePropagation();
		var _loc2_:String = "";
		var _loc3_:FriendItemRender = null;
		if(param1 != null && param1.target != null) {
			_loc2_ = param1.target.name;
		}
		if(_loc2_ == "vip_mc") {
			QQOutlets.call("window.open", "tools.php?mod=vip");
			return;
		}
		if(_loc2_ == "tujian") {
			ClickReportManager.reportClick("FRIENDLIST_TUJIAN");
			_loc4_ = AllianceActivityManager.getInstance().getActivityContext("collecting");
			if(_loc4_ != null) {
				_loc3_ = cast(param1.target.parent, FriendItemRender);
				if(_loc3_ == null) {
					return;
				}
				_loc5_ = 0;
				if(Settings.getInstance().mode == "") {
					_loc5_ = _loc3_.fiendData._uId;
				} else {
					_loc5_ = _loc3_.fiendData._uin;
				}
				_loc4_.execute("10002", _loc5_);
			}
			return;
		}
		if(ClipProps.get(param1.target, "s_name") == "Status_z") {
			if(this.backTimeIsToday() == false) {
				this._fid = cast(param1.currentTarget, FriendItemRender).fiendData._uId;
				if(Settings.getInstance().mode == "") {
					this._uin = cast(param1.currentTarget, FriendItemRender).fiendData._uId;
				} else {
					this._uin = cast(param1.currentTarget, FriendItemRender).fiendData._uin;
					if(Settings.getInstance().getStringAttribute("sendRequest") == "1") {
						_loc6_ = "亲爱的" + cast(param1.currentTarget, FriendItemRender).fiendData._userName
							+ "，你不在摘菜都没动力了！快来吧，还有惊喜等着你！";
						_loc7_ = "module/ui/happyfarmGiftIcon50.jpg";
						QzoneJSAPI.sendGameRequest(this._uin, _loc7_, "接受", null, null, "", _loc6_);
					}
				}
				NetHelper.sendRequest(CommandDefs.CMD_REQUEST_ZHAO, {"fuid": this._fid}, this.onGetRequestSuccess, this.onRequestFail);
			} else {
				if(Cookies.getObject("setZhaohui_" + Session.getInstance().host._uId) == null) {
					Cookies.setObject("setZhaohui_" + Session.getInstance().host._uId, {"time": CommonData.serverTime});
				}
				this._controller.openFloat(Consts.FLOAT_TYPE_TEXTTIP, {
					"text": "对不起，您今天不能再发送召回邀请信息了！",
					"parent": this.stage
				});
			}
			return;
		}
		_loc3_ = cast(param1.currentTarget, FriendItemRender);
		if(_loc3_ == null || _loc3_.fiendData == null) {
			return;
		}
		if(_loc2_ == "mc_btn") {
			if(Session.getInstance().host._pf > 0) {
				this._controller.module.app.setExpressUser(_loc3_.fiendData.exportObject(), 2);
			} else {
				this._controller.module.app.dispatchEvent(new CommonEvent(Consts.MSG_ENTER_MC, 2));
			}
		} else {
			_loc8_ = _loc3_.fiendData._uin;
			// hasOwnProperty(int) 按十进制串键查（FriendsModel :667 同款）
			if(this._friendListFilter != null && As3.hasProp(this._friendListFilter, Std.string(_loc8_)) == true) {
				_loc9_ = _loc3_.fiendData._uId;
				// `||`：空串/null 落右边（As3.or 的 AS3 动态真值）
				_loc10_ = cast(As3.or(Utils.getNameById(_loc9_), Std.string(_loc8_)), String);
				_loc11_ = "<font color=\'#009900\'><b>" + _loc10_
					+ "</b></font> 说您不是他的好友，不允许进入其农场。确认对方加您为好友后，即可点击<font color=\'#0000FF\'><a href=\'event:del\'>申请进入</a></font>农场。";
				_loc12_ = {
					"type": Consts.ALERT_TYPE_TIP,
					"title": "温馨提示",
					"width": 380,
					"height": 220,
					"text": _loc11_,
					"textLinkHandle": this.confirmRemoveFilter
				};
				this._filterUserId = _loc8_;
				this._controller.openWindow(Consts.WINDOW_NAME_ALERT, _loc12_);
				return;
			}
			if(ClipProps.get(param1.target, "s_name") == "Status_u") {
				BeastAPI.getInstance().showWildStage();
			} else if(ClipProps.get(param1.target, "s_name") == "Status_7") {
				_loc13_ = PluginManager.getInstance().getPluginByID(2);
				if(_loc13_ != null) {
					_loc13_.executeCommand(2100, _loc3_.fiendData._uId);
				}
			} else {
				BeastAPI.getInstance().showFarmStage();
			}
			this._controller.module.app.dispatchEvent(new CommonEvent(Consts.MSG_SWITCH_USER, _loc3_.fiendData));
		}
		this._controller.module.app.dispatchEvent(new CommonEvent(Consts.DELEVE_NEW_ICON, null));
	}

	// FriendsView.as:478-485
	private function createItem():FriendItemRender {
		var _loc1_:FriendItemRender = new FriendItemRender();
		_loc1_.addEventListener(MouseEvent.MOUSE_OVER, this.onItemMouseOver, false, 0, true);
		_loc1_.addEventListener(MouseEvent.MOUSE_OUT, this.onItemMouseOut, false, 0, true);
		_loc1_.addEventListener(MouseEvent.CLICK, this.onItemClicked, false, 0, true);
		return _loc1_;
	}

	// FriendsView.as:487-490
	public var seachText(get, never):String;

	private function get_seachText():String {
		return this.searchInputer.text;
	}

	// FriendsView.as:492-512（今天是否已召回过：cookie 里的 optime 与服务器
	// 时间比年月日；缺 "time" 键时 NaN 比较恒 false，与 AS3 Invalid Date 一致）
	private function backTimeIsToday():Bool {
		var _loc1_:Bool = false;
		if(Cookies.getObject("setZhaohui_" + Session.getInstance().host._uId) == null) {
			return false;
		}
		var _loc2_:Date = Date.fromTime(CommonData.serverTime * 1000);
		var _loc3_:Date = Date.fromTime(As3.floatOf(Reflect.field(Cookies.getObject("setZhaohui_" + Session.getInstance().host._uId), "time")) * 1000);
		if(_loc2_.getFullYear() == _loc3_.getFullYear()) {
			if(_loc2_.getMonth() == _loc3_.getMonth()) {
				if(_loc2_.getDate() == _loc3_.getDate()) {
					_loc1_ = true;
				}
			}
		}
		return _loc1_;
	}

	// FriendsView.as:514-525（召回成功：与 onAppRequestFail 同款转发，只少
	// direction 判——FriendsController.onUpdataBack 走正常配额文案）
	private function onGetRequestSuccess(param1:CommandEvent):Void {
		this._controller.module.app.dispatchEvent(new CommonEvent(Consts.MSG_BACK_UPDATE_STATUS, {
			"ecode": (Reflect.field(param1.result.m_extra, "ecode") == null ? 0 : Reflect.field(param1.result.m_extra, "ecode")),
			"direction": (Reflect.field(param1.result.m_extra, "direction") == null ? "" : Reflect.field(param1.result.m_extra, "direction")),
			"t": 0,
			"uId": this._uin,
			"money": Reflect.field(param1.result.m_extra, "money"),
			"leftQuota": Reflect.field(param1.result.m_extra, "left_quota"),
			"servertime": (Reflect.field(param1.result.m_extra, "optime") == null ? CommonData.serverTime : Reflect.field(param1.result.m_extra, "optime"))
		}));
	}

	// FriendsView.as:527-530（set 在 :591）
	public var countPage(get, set):Int;

	private function get_countPage():Int {
		return this._countPage;
	}

	// FriendsView.as:532-535
	private function onResized(param1:Event):Void {
		this.x = stage.stageWidth - this.hideRight;
	}

	// FriendsView.as:537-544
	private function onMouseOut(param1:MouseEvent):Void {
		if(param1 == null || param1.target == null) {
			return;
		}
		this._controller.hideTip();
	}

	// FriendsView.as:546-575（首次展开弹公告位提示：friendListMod 回 false 或
	// 空配置不弹。`!= false` 是 AS3 松散比较按 Number 化——false（→0）与空/
	// 纯空白串（Number("")==0）都判等，提示文本 NaN 不等才弹；floatOf 对空串
	// 落 NaN（parseFloat 味），补 trim 空判收全空白形态）
	private function onCollapseView(param1:Event):Void {
		var _loc2_:Dynamic = null;
		if(param1.target == this.open_btn) {
			this.open_btn.visible = false;
			this.close_btn.visible = true;
			this._offsetValue = -1;
			addEventListener(Event.ENTER_FRAME, this.effHandler, false, 0, true);
			_loc2_ = FeartureManager.friendListMod();
			if(As3.floatOf(_loc2_) != 0 && StringTools.trim(Std.string(_loc2_)) != "") {
				this._controller.openWindow(Consts.WINDOW_NAME_ALERT, {
					"type": Consts.ALERT_TYPE_TIP,
					"text": _loc2_
				});
				return;
			}
			UserActionRecorder.recordAction(UserActionRecorder.HF_FRIENDLIST_OPEN);
			ClickReportManager.reportClick("right.banner.icon_qq_friend.click");
		} else {
			this.open_btn.visible = true;
			this.close_btn.visible = false;
			this._offsetValue = 1;
			addEventListener(Event.ENTER_FRAME, this.effHandler, false, 0, true);
			UserActionRecorder.recordAction(UserActionRecorder.HF_FRIENDLIST_CLOSE);
		}
	}

	// FriendsView.as:577-584
	private function backEnd(param1:Event):Void {
		if(this._page == 1) {
			return;
		}
		dispatchEvent(new Event(VIEW_EVENT_FIRST_PAGE));
	}

	// FriendsView.as:586-589
	private function delayConfirmRemoveFilter():Void {
		this._controller.model.removeFriendListFilter(this._filterUserId);
	}

	// FriendsView.as:591-597
	private function set_countPage(param1:Int):Int {
		this._countPage = param1;
		this.pageTextShow.text = this._page + " / " + this._countPage;
		var _loc2_:Bool = this._page == this._countPage ? false : true;
		ButtonMaker.setEnabled(this.nextButton, _loc2_);
		return param1;
	}

	// FriendsView.as:599-610
	private function onRefreshClicked(param1:Event):Void {
		if(param1.target.name == "refresh_btn") {
			dispatchEvent(new Event(VIEW_EVENT_RELOAD_FRIENDS));
		} else if(param1.target.name == "refresh2_btn") {
			dispatchEvent(new Event(VIEW_EVENT_REFRESH_STATUS));
			UserActionRecorder.recordAction(UserActionRecorder.HF_FRIENDLIST_REFRESH_STATUS);
		}
	}

	// FriendsView.as:612-618
	private function onLinkClick(param1:ViewEvent):Void {
		if(param1.data == "reload") {
			dispatchEvent(new Event(VIEW_EVENT_RELOAD_FRIENDS));
		}
	}

	// FriendsView.as:620-638
	private function onHeadPicLoaded(param1:CommonEvent):Void {
		var _loc2_:Bool = As3.truthy(QzoneJSAPI.WB);
		var _loc3_:FriendItemRender = null;
		var _loc4_:Int = 0;
		while(_loc4_ < this._itemContainer.numChildren) {
			_loc3_ = cast(this._itemContainer.getChildAt(_loc4_), FriendItemRender);
			if(_loc3_ != null) {
				_loc3_.updateIcon();
				if(_loc2_ == true) {
					_loc3_.updateName();
				}
			}
			_loc4_++;
		}
	}

	// FriendsView.as:640-666（当前用户行高亮；fiendData 无守卫与原版一致——
	// 容器里的行都在 add() 里设过 fiendData）
	public function updateCurrentSelect():Void {
		if(this._itemContainer == null) {
			return;
		}
		var _loc1_:UInt = Session.getInstance().currentUser._uId;
		var _loc2_:FriendItemRender = null;
		var _loc3_:Int = 0;
		while(_loc3_ < this._itemContainer.numChildren) {
			_loc2_ = cast(this._itemContainer.getChildAt(_loc3_), FriendItemRender);
			if(_loc2_.isSelected() == true && _loc2_.fiendData._uId == _loc1_) {
				return;
			}
			if(_loc2_.fiendData._uId == _loc1_) {
				_loc2_.selected = _loc1_;
			} else {
				_loc2_.selected = 0;
			}
			_loc3_++;
		}
	}

	// FriendsView.as:668-671
	private function get_page():Int {
		return this._page;
	}

	// FriendsView.as:673-686
	private function resetSeleted(param1:UInt):Void {
		if(this._itemContainer == null) {
			return;
		}
		var _loc2_:Int = this._itemContainer.numChildren;
		var _loc3_:Int = 0;
		while(_loc3_ < _loc2_) {
			cast(this._itemContainer.getChildAt(_loc3_), FriendItemRender).selected = param1;
			_loc3_++;
		}
	}

	// FriendsView.as:688-745（行入列：缓存池取/建，好友出队（splice 原地语义），
	// 等级底图按 sort 档，过滤名单命中置灰）
	private function add():Void {
		var _loc1_:FriendItemRender = null;
		if(this._itemCache.length > 0) {
			_loc1_ = cast(this._itemCache.pop(), FriendItemRender);
		} else {
			_loc1_ = this.createItem();
		}
		var _loc2_:Friend = this._friendList[0];
		this._friendList = this._friendList.splice(1, this._friendList.length - 1);
		if(_loc2_ == null) {
			return;
		}
		if(_loc2_.me == true && Settings.getInstance().mode == "qzone") {
			var _loc3_:Dynamic = Cookies.getObject("OwnerHead");
			if(_loc3_ != null) {
				// `as String`：AS3 不合类型得 null 而不抛（FarmLite :103 同款）
				_loc2_._headPic = Std.isOfType(_loc3_, String) ? cast(_loc3_, String) : null;
			}
		}
		_loc1_.fiendData = _loc2_;
		if(_loc2_.me == false) {
			if(_loc2_.sort == 1) {
				_loc1_.levelBg = this._levelSkin[1];
			} else if(_loc2_.sort == 2) {
				_loc1_.levelBg = this._levelSkin[2];
			} else if(_loc2_.sort == 3) {
				_loc1_.levelBg = this._levelSkin[3];
			} else {
				_loc1_.levelBg = this._levelSkin[0];
			}
		} else {
			_loc1_.levelBg = this._levelSkin[4];
		}
		if(this._friendListFilter != null && As3.hasProp(this._friendListFilter, Std.string(_loc2_._uin))) {
			_loc1_.setGray();
		}
		_loc1_.selected = Session.getInstance().currentUserIdByUinMode;
		_loc1_.x = 0;
		_loc1_.y = this._itemContainer.numChildren * 32;
		this._itemContainer.addChildAt(_loc1_, 0);
		this.resetSeleted(0);
	}

	// FriendsView.as:747-766（开合动画：每帧走剩余距离的 0.4，floor 到 0 即完成）
	private function effHandler(param1:Event):Void {
		var _loc2_:Float = 0.4;
		var _loc3_:Float = 0;
		if(this._offsetValue > 0) {
			_loc3_ = this.stage.stageWidth - this.hideRight;
		} else {
			_loc3_ = this.stage.stageWidth - this.showRight;
		}
		var _loc4_:Float = Math.floor((_loc3_ - this.x) * _loc2_);
		this.x += _loc4_;
		if(_loc4_ == 0) {
			removeEventListener(Event.ENTER_FRAME, this.effHandler);
			dispatchEvent(new Event(VIEW_EVENT_COLLAPSE));
		}
	}

	// FriendsView.as:768-841（行悬停提示：VIP/牧场/图鉴/状态角标；preMode 时
	// 状态提示改写为成熟倒计时分钟）
	private function onItemMouseOver(param1:MouseEvent):Void {
		var _loc4_:Int = 0;
		var _loc5_:IAllianceActivityContext = null;
		var _loc6_:String = null;
		var _loc7_:String = null;
		var _loc8_:Float = Math.NaN;
		if(param1 == null || param1.target == null || param1.currentTarget == null) {
			return;
		}
		var _loc2_:FriendItemRender = cast(param1.currentTarget, FriendItemRender);
		if(_loc2_ == null) {
			return;
		}
		_loc2_.changBg();
		var _loc3_:String = param1.target.name;
		if(_loc3_ == "vip_mc") {
			this._controller.showTip(Consts.TIP_NAME_MOUSE, "点击查看VIP特权详情");
		} else if(_loc3_ == "mc_btn") {
			this._controller.showTip(Consts.TIP_NAME_MOUSE, "该用户已开通牧场");
		} else if(_loc3_ == "tujian") {
			_loc4_ = _loc2_.tujian;
			if(_loc4_ > 0) {
				_loc5_ = AllianceActivityManager.getInstance().getActivityContext("collecting");
				if(_loc5_ == null) {
					return;
				}
				var _loc5r_:Dynamic = _loc5_.execute("10003", _loc4_);
				// `as String`：AS3 不合类型得 null（串接落 "null"），FarmLite :103 同款
				_loc6_ = Std.isOfType(_loc5r_, String) ? cast(_loc5r_, String) : null;
				this._controller.showTip(Consts.TIP_NAME_MOUSE, "该用户集齐了" + _loc6_ + "系列");
			}
		} else if(_loc3_ == "status_mc") {
			_loc7_ = "";
			if(ClipProps.get(param1.target, "s_name") == "Status_u") {
				_loc7_ = "驱赶野生动物";
			} else if(ClipProps.get(param1.target, "s_name") == "Status_z") {
				_loc7_ = "点击召回好友，获得超值奖励";
			} else if(ClipProps.get(param1.target, "s_name") == "Status_6") {
				_loc7_ = "该用户池塘可以操作";
			} else if(ClipProps.get(param1.target, "s_name") == "Status_7") {
				_loc7_ = "该用户小仙可以供奉";
			} else {
				_loc7_ = "该用户田地可以操作";
			}
			if(_loc2_.preMode == true) {
				_loc8_ = Math.ceil((_loc2_.preTime - CommonData.serverTime) / 60);
				if(_loc8_ > 0) {
					_loc7_ = "该用户有作物" + _loc8_ + "分钟内成熟";
				}
			}
			this._controller.showTip(Consts.TIP_NAME_MOUSE, _loc7_);
		}
	}

	// FriendsView.as:843-852
	private function onAddedToStage(param1:Event):Void {
		removeEventListener(Event.ADDED_TO_STAGE, this.onAddedToStage);
		if(this.stage != null) {
			this.stage.addEventListener(Event.RESIZE, this.onResized, false, 0, true);
		}
		this.x = stage.stageWidth - this.hideRight;
		this.y = 80;
	}

	// FriendsView.as:854-873（皮肤：qzone 态开关帧 2；VipL1-7 预热
	// getCachedBitmapData 缓存；Sort0-3/SortMe 等级底图五档）
	private function initSkin():Void {
		if(Settings.getInstance().mode == "qzone") {
			this.close_btn.gotoAndStop(2);
			this.open_btn.gotoAndStop(2);
		}
		var _loc1_:Int = 1;
		while(_loc1_ < 8) {
			Utils.getCachedBitmapData("VipL" + _loc1_, 16, 13);
			_loc1_++;
		}
		// AS3 `new Array(5)` 只是预置长度，五档随即全赋值，空数组等价
		this._levelSkin = new Array<Dynamic>();
		this._levelSkin[0] = Utils.getCachedBitmapData("Sort0", 24, 24);
		this._levelSkin[1] = Utils.getCachedBitmapData("Sort1", 24, 24);
		this._levelSkin[2] = Utils.getCachedBitmapData("Sort2", 24, 24);
		this._levelSkin[3] = Utils.getCachedBitmapData("Sort3", 24, 24);
		this._levelSkin[4] = Utils.getCachedBitmapData("SortMe", 24, 24);
	}

	// FriendsView.as:875-973（面板装配：List_UI 符号 + 子件接线；微博态换
	// List_Close/Open_WB 皮肤；xb 空串档才挂翻页/搜索/排序监听）
	private function createView():Void {
		var _loc1_:MovieClip = null;
		this._itemContainer = new Sprite();
		this.listUI = cast(Utils.getMaterial("List_UI"), Sprite);
		this.close_btn = cast(this.listUI.getChildByName("close_btn"), MovieClip);
		this.open_btn = cast(this.listUI.getChildByName("open_btn"), MovieClip);
		this.backButton = cast(this.listUI.getChildByName("prev_btn"), MovieClip);
		this.nextButton = cast(this.listUI.getChildByName("next_btn"), MovieClip);
		this.backEndButton = cast(this.listUI.getChildByName("prev_end_btn"), MovieClip);
		this.backEndButton.visible = false;
		this.searchTextField = cast(this.listUI.getChildByName("search_txt"), TextField);
		this.pageTextShow = cast(this.listUI.getChildByName("page_txt"), TextField);
		this.sortByExpButtonA = cast(this.listUI.getChildByName("sortA_btn"), MovieClip);
		this.sortByGoldButtonA = cast(this.listUI.getChildByName("sortB_btn"), MovieClip);
		this.refurbishButton = cast(this.listUI.getChildByName("refresh_btn"), MovieClip);
		this.refurbishButton2 = cast(this.listUI.getChildByName("refresh2_btn"), MovieClip);
		this.searchButton = cast(this.listUI.getChildByName("search_btn"), MovieClip);
		ButtonMaker.addTarget(this.sortByExpButtonA, true, true);
		ButtonMaker.addTarget(this.sortByGoldButtonA);
		if(QzoneJSAPI.WB == true) {
			_loc1_ = cast(Utils.getMaterial("List_Close_WB"), MovieClip);
			if(_loc1_ != null) {
				_loc1_.x = this.close_btn.x;
				_loc1_.y = this.close_btn.y;
				this.listUI.removeChild(this.close_btn);
				this.listUI.addChild(_loc1_);
				this.close_btn = _loc1_;
			}
			_loc1_ = cast(Utils.getMaterial("List_Open_WB"), MovieClip);
			if(_loc1_ != null) {
				_loc1_.x = this.open_btn.x;
				_loc1_.y = this.open_btn.y;
				this.listUI.removeChild(this.open_btn);
				this.listUI.addChild(_loc1_);
				this.open_btn = _loc1_;
			}
		}
		ButtonMaker.addTarget(this.close_btn);
		ButtonMaker.addTarget(this.open_btn);
		ButtonMaker.addTarget(this.refurbishButton);
		ButtonMaker.addTarget(this.refurbishButton2);
		ButtonMaker.addTarget(this.searchButton);
		ButtonMaker.addTarget(this.backButton);
		ButtonMaker.addTarget(this.nextButton);
		ButtonMaker.addTarget(this.backEndButton);
		this.searchInputer = new TipInputMaker();
		if(QzoneJSAPI.WB == true) {
			this.searchInputer.tipText = "按微博昵称查找";
		} else if(Settings.getInstance().mode == "qzone") {
			this.searchInputer.tipText = "按昵称或号码查找";
		} else {
			this.searchInputer.tipText = "按好友名字查找";
		}
		this.searchInputer.target = this.searchTextField;
		this.searchTextField.maxChars = 10;
		this.searchTextField.dispatchEvent(new FocusEvent(FocusEvent.FOCUS_OUT));
		this.close_btn.visible = false;
		this.close_btn.addEventListener("mouseDown", this.onCollapseView);
		this.open_btn.addEventListener("mouseDown", this.onCollapseView);
		this.searchButton.addEventListener(MouseEvent.ROLL_OVER, this.onMouseOver);
		this.searchButton.addEventListener(MouseEvent.ROLL_OUT, this.onMouseOut);
		this.refurbishButton.addEventListener(MouseEvent.ROLL_OVER, this.onMouseOver);
		this.refurbishButton.addEventListener(MouseEvent.ROLL_OUT, this.onMouseOut);
		this.refurbishButton2.addEventListener(MouseEvent.ROLL_OVER, this.onMouseOver);
		this.refurbishButton2.addEventListener(MouseEvent.ROLL_OUT, this.onMouseOut);
		addChild(this.listUI);
		if(Settings.getInstance().getStringAttribute("xb") == "") {
			this.searchTextField.addEventListener("change", this.onSearchBtnClicked);
			this.searchButton.addEventListener("mouseDown", this.onSearchBtnClicked);
			this.sortByGoldButtonA.addEventListener(MouseEvent.MOUSE_UP, this.onSortBtnClicked);
			this.sortByExpButtonA.addEventListener(MouseEvent.MOUSE_UP, this.onSortBtnClicked);
			this.backButton.addEventListener(MouseEvent.CLICK, this.back);
			this.backEndButton.addEventListener(MouseEvent.CLICK, this.backEnd);
			this.nextButton.addEventListener(MouseEvent.CLICK, this.next);
			this.refurbishButton.addEventListener("mouseDown", this.onRefreshClicked);
			this.refurbishButton2.addEventListener("mouseDown", this.onRefreshClicked);
		}
		this._itemContainer.x = 30;
		this._itemContainer.y = 55;
		addChild(this._itemContainer);
		this.pageTextShow.text = "0 / 0";
		this.loading = new DataLoading();
		this.loading.x = 110;
		this.loading.y = 200;
		this.loading.addEventListener(ViewEvent.LINK_CLICK, this.onLinkClick);
		this.loading.visible = true;
		addChild(this.loading);
		this.initSkin();
	}

	// FriendsView.as:975-977（原版空函数）
	private function onGetAppRequestSuccess(param1:CommandEvent):Void {
	}

	// FriendsView.as:979-987
	private function onDataLoadFailed(param1:CommonEvent):Void {
		if(param1 == null || param1.data == null) {
			return;
		}
		this.loading.visible = true;
		this.loading.errorText = Reflect.field(param1.data, "error");
	}

	// FriendsView.as:989-996
	private function onDataLoading(param1:CommonEvent):Void {
		if(param1 == null || param1.data == null) {
			return;
		}
		this.loading.visible = As3.truthy(Reflect.field(param1.data, "show"));
	}

	// FriendsView.as:998-1005
	private function nextEnd(param1:Event):Void {
		if(this._page == this._countPage) {
			return;
		}
		dispatchEvent(new Event(VIEW_EVENT_LAST_PAGE));
	}

	// FriendsView.as:1007-1028
	private function onRequestFail(param1:CommandEvent):Void {
		if(As3.hasProp(param1.result.m_extra, "direction")) {
			this._controller.module.app.dispatchEvent(new CommonEvent(Consts.MSG_BACK_UPDATE_STATUS, {
				"ecode": (Reflect.field(param1.result.m_extra, "ecode") == null ? 0 : Reflect.field(param1.result.m_extra, "ecode")),
				"direction": (Reflect.field(param1.result.m_extra, "direction") == null ? "" : Reflect.field(param1.result.m_extra, "direction")),
				"t": 0,
				"uId": this._uin,
				"money": Reflect.field(param1.result.m_extra, "money"),
				"leftQuota": Reflect.field(param1.result.m_extra, "left_quota"),
				"servertime": (Reflect.field(param1.result.m_extra, "optime") == null ? CommonData.serverTime : Reflect.field(param1.result.m_extra, "optime"))
			}));
		} else {
			this._controller.openFloat(Consts.FLOAT_TYPE_TEXTTIP, {
				"text": "系统繁忙",
				"parent": this.stage
			});
		}
	}

	// FriendsView.as:1030-1038
	private function next(param1:Event):Void {
		if(this._page == this._countPage) {
			return;
		}
		dispatchEvent(new Event(VIEW_EVENT_NEXT_PAGE));
		UserActionRecorder.recordAction(UserActionRecorder.HF_FRIENDLIST_NEXT);
	}

	// FriendsView.as:1040-1043
	private function confirmRemoveFilter(param1:TextEvent):Void {
		As3.setTimeout(this.delayConfirmRemoveFilter, 800);
	}

	// FriendsView.as:1045-1053
	private function back(param1:Event):Void {
		if(this._page == 1) {
			return;
		}
		dispatchEvent(new Event(VIEW_EVENT_BACK_PAGE));
		UserActionRecorder.recordAction(UserActionRecorder.HF_FRIENDLIST_BACK);
	}
}
