package module.friend;

import common.Consts;
import common.Session;
import common.misc.Cookies;
import events.CommonEvent;
import framework.base.Controller;
import interfaces.IModule;
import openfl.events.Event;
import shim.As3;
// PORT-NOTE: openfl 的 getTimer 在 eval 上纪元溢出为负，见 shim/As3.hx（Module 同款）
import shim.As3.getTimer;

/**
 * module.friend.FriendsController —— FriendsController.as（391 loc）逐句对应。
 * 事件装配层：模块消息（召回/鱼塘/野兽/精灵/地块状态）→ FriendsModel 状态
 * 更新 + 对应行角标刷新；视图事件（翻页/搜索/排序/开合）→ 模型动作；限流
 * 防抖（limitedTimes/getFriendListDelay）照抄。
 *
 * 事件 data 里的 `as uint`/`as Number`/`as Boolean` 键读按 BackgroundController
 * 先例：As3.intOf/floatOf/truthy（派发方全是真实类型，语义一致；缺位 AS3
 * undefined→NaN/null→false 同被覆盖）。
 */
class FriendsController extends Controller {
	// FriendsController.as:15-17
	private static final limitedTimes:Int = 3;
	public static final getFriendListDelay:Int = 3000;

	// FriendsController.as:19-23
	private var getFriend:Bool;
	private var getFriendListClick:Int;
	private var getFriendListTime:Int;

	// FriendsController.as:25-31
	public function new(param1:IModule) {
		super(param1);
		this.getFriend = false;
		this.getFriendListTime = 0;
		this.getFriendListClick = 0;
	}

	// FriendsController.as:33-42
	private function onCurrentFarmCanPick(param1:CommonEvent):Void {
		if(param1 == null || param1.data == null) {
			return;
		}
		var _loc2_:UInt = As3.intOf(Reflect.field(param1.data, "uId"));
		var _loc3_:UInt = As3.intOf(Reflect.field(param1.data, "ownerId"));
		this.model.canPick(_loc2_, _loc3_);
	}

	// FriendsController.as:44-127（召回请求应答：leftQuota>=0 正常配额文案，
	// else 落 optime cookie / ecode / direction 分支）
	private function onUpdataBack(param1:CommonEvent):Void {
		var _loc5_:String = null;
		if(param1 == null || param1.data == null) {
			return;
		}
		var _loc2_:UInt = As3.intOf(Reflect.field(param1.data, "uId"));
		var _loc3_:UInt = As3.intOf(Reflect.field(param1.data, "servertime"));
		this.model.updateBackStatus(_loc2_, _loc3_);
		var _loc4_:FriendItemRender = this.view.getRenderItemById(_loc2_);
		if(_loc4_ != null) {
			_loc4_.updateStatusFlag();
		}
		// `["leftQuota"] >= 0`：松散关系比较按 ToNumber——键缺位 AS3
		// undefined→NaN（恒假）、显式 JSON null→ToNumber(null)=0（≥0 成立
		// 走配额分支）。Haxe 里缺位与显式 null 都落 null（floatOf 一律
		// NaN），用 hasProp 把显式 null 区分出来补 0。内层 `== 0` 是宽松
		// 等价（规范里 null==0 为 false），floatOf 的 NaN==0 恰好复刻，不动
		var _loc6_:Float = As3.hasProp(param1.data, "leftQuota") && Reflect.field(param1.data, "leftQuota") == null ? 0 : As3.floatOf(Reflect.field(param1.data, "leftQuota"));
		if(_loc6_ >= 0) {
			if(As3.floatOf(Reflect.field(param1.data, "leftQuota")) == 0) {
				_loc5_ = "金币<font color=\'#ff0000\'>+" + Reflect.field(param1.data, "money")
					+ "</font>，好友<font color=\'#ff0000\'>接受邀请后</font>，可获得稀有海芋种子<font color=\'#ff0000\'>1颗</font>。您今天不能再发送召回邀请信息了！";
				if(As3.hasProp(param1.data, "optime")) {
					Cookies.setObject("setZhaohui_" + Session.getInstance().host._uId,
						{"time": Reflect.field(param1.data, "optime")});
				} else {
					Cookies.setObject("setZhaohui_" + Session.getInstance().host._uId, {"time": _loc3_});
				}
				this.model.reloadThisPage();
			} else {
				_loc5_ = "金币<font color=\'#ff0000\'>+" + Reflect.field(param1.data, "money")
					+ "</font>，好友<font color=\'#ff0000\'>接受邀请后</font>，可获得稀有海芋种子<font color=\'#ff0000\'>1颗</font>。您今天还能发<font color=\'#ff0000\'>"
					+ Reflect.field(param1.data, "leftQuota") + "</font>条邀请！";
			}
			this.openFloat(Consts.FLOAT_TYPE_TEXTTIP, {
				"text": _loc5_,
				"parent": this.view.stage,
				"stoptime": 3000
			});
			this.m_module.app.dispatchEvent(new CommonEvent(Consts.DATA_BAG_RELOAD_FLAG, null));
			Session.getInstance().updateHostAccount(As3.intOf(Reflect.field(param1.data, "money")));
		} else {
			if(As3.hasProp(param1.data, "optime")) {
				Cookies.setObject("setZhaohui_" + Session.getInstance().host._uId,
					{"time": Reflect.field(param1.data, "optime")});
			} else {
				Cookies.setObject("setZhaohui_" + Session.getInstance().host._uId, {"time": _loc3_});
			}
			if(As3.floatOf(Reflect.field(param1.data, "ecode")) == 0) {
				this.openFloat(Consts.FLOAT_TYPE_TEXTTIP, {
					"text": "对不起，您今天不能再发送召回邀请信息了！",
					"parent": this.view.stage
				});
			} else if(As3.hasProp(param1.data, "direction")) {
				this.model.reloadThisPage();
				if(As3.eqString(Reflect.field(param1.data, "direction"), "今天名额已满！")) {
					this.openFloat(Consts.FLOAT_TYPE_TEXTTIP, {
						"text": "对不起，您今天不能再发送召回邀请信息了！",
						"parent": this.view.stage
					});
					return;
				}
				this.openFloat(Consts.FLOAT_TYPE_TEXTTIP, {
					"text": Reflect.field(param1.data, "direction"),
					"parent": this.view.stage
				});
			} else {
				this.openFloat(Consts.FLOAT_TYPE_TEXTTIP, {
					"text": "系统繁忙",
					"parent": this.view.stage
				});
			}
		}
	}

	// FriendsController.as:129-151（鱼塘状态位：remove 置假后转发）
	private function onUpdateFishFlag(param1:CommonEvent):Void {
		if(param1 == null || param1.data == null || !As3.hasProp(param1.data, "uId")) {
			return;
		}
		var _loc2_:Bool = As3.truthy(Reflect.field(param1.data, "hasFish"));
		var _loc3_:Bool = As3.truthy(Reflect.field(param1.data, "remove"));
		var _loc4_:UInt = As3.intOf(Reflect.field(param1.data, "ownerId"));
		var _loc5_:Bool = As3.truthy(Reflect.field(param1.data, "check"));
		var _loc6_:Bool = _loc2_;
		if(_loc3_ == true) {
			_loc6_ = false;
		}
		var _loc7_:UInt = As3.intOf(Reflect.field(param1.data, "uId"));
		this.model.updatePoolStatus(_loc7_, _loc4_, _loc6_, _loc5_);
		var _loc8_:FriendItemRender = this.view.getRenderItemById(_loc7_);
		if(_loc8_ != null) {
			_loc8_.updateStatusFlag();
		}
	}

	// FriendsController.as:153-160
	private function onAlertWindow(param1:CommonEvent):Void {
		if(param1 == null || param1.data == null) {
			return;
		}
		openWindow(Consts.WINDOW_NAME_ALERT, param1.data);
	}

	// FriendsController.as:162-183（限流：3 秒窗口内最多 3 次，超了重置计时）
	@:access(module.friend.FriendsModel)
	private function onRefreshStatus(param1:Event):Void {
		if(this.getFriendListTime + getFriendListDelay < getTimer()) {
			if(this.getFriendListClick < limitedTimes) {
				this.model._showFriendPage = 1;
				this.model.refreshFriendStatus(true);
				++this.getFriendListClick;
			} else {
				this.getFriendListTime = getTimer();
				this.getFriendListClick = 0;
			}
		} else {
			this.model._showFriendPage = 1;
			this.model.refreshFriendStatus(false);
		}
	}

	// FriendsController.as:185-203（地块可摘/虫/草状态位转发）
	private function onRefreshLandStatus(param1:CommonEvent):Void {
		if(param1 == null || param1.data == null) {
			return;
		}
		var _loc2_:UInt = As3.intOf(Reflect.field(param1.data, "uId"));
		var _loc3_:UInt = As3.intOf(Reflect.field(param1.data, "ownerId"));
		var _loc4_:Bool = As3.truthy(Reflect.field(param1.data, "havest"));
		var _loc5_:Bool = As3.truthy(Reflect.field(param1.data, "bug"));
		var _loc6_:Bool = As3.truthy(Reflect.field(param1.data, "weed"));
		var _loc7_:Bool = As3.truthy(Reflect.field(param1.data, "check"));
		this.model.updateLandsStatus(_loc2_, _loc3_, _loc6_, _loc5_, _loc4_, _loc7_);
		var _loc8_:FriendItemRender = this.view.getRenderItemById(_loc2_);
		if(_loc8_ != null) {
			_loc8_.updateStatusFlag();
		}
	}

	// FriendsController.as:205-212
	private function onForbidden(param1:CommonEvent):Void {
		if(param1 == null || param1.data == null) {
			return;
		}
		openWindow(Consts.WINDOW_NAME_ALERT, param1.data);
	}

	// FriendsController.as:214-221
	private function onSortFriend(param1:CommonEvent):Void {
		if(param1 == null || param1.data == null) {
			return;
		}
		this.model.sortBy(param1.data);
	}

	// FriendsController.as:223-237。FriendsModel.EVENT_* 原版 internal、移植
	// private，registerListeners 跨类读 → @:access
	@:access(module.friend.FriendsModel)
	private function registerListeners():Void {
		this.m_module.app.addEventListener(Consts.MSG_LAND_CAN_PICK, this.onCurrentFarmCanPick, false, 0, true);
		this.m_module.app.addEventListener(Consts.MSG_REFRESH_FRIEND_STATUS, this.onRefreshLandStatus, false, 0, true);
		this.m_module.app.addEventListener(Consts.MSG_CURRENT_USER_CHANGED, this.onCurrentUserChanged, false, 0, true);
		this.m_module.app.addEventListener(Consts.MSG_WILD_UPDATE_STATUS, this.onUpdateWild, false, 0, true);
		this.m_module.app.addEventListener(Consts.MSG_BACK_UPDATE_STATUS, this.onUpdataBack, false, 0, true);
		this.m_module.app.addEventListener(Consts.MSG_REFRESH_FISH_FRIENDLIST, this.onUpdateFishFlag, false, 0, true);
		this.m_module.app.addEventListener(Consts.MSG_FAIRY_DONATED, this.onUpdateFairyFlag, false, 0, true);
		if(this.m_model != null) {
			this.m_model.addEventListener(FriendsModel.EVENT_ALERT_WINDOW, this.onAlertWindow, false, 0, true);
			this.m_model.addEventListener(FriendsModel.EVENT_FUNCTION_FORBIDDEN, this.onForbidden, false, 0, true);
		}
	}

	// FriendsController.as:239-260（onRefreshStatus 同款限流）
	@:access(module.friend.FriendsModel)
	private function onReloadFriends(param1:Event):Void {
		if(this.getFriendListTime + getFriendListDelay < getTimer()) {
			if(this.getFriendListClick < limitedTimes) {
				this.model._showFriendPage = 1;
				this.model.loadFriendsData(true, true);
				++this.getFriendListClick;
			} else {
				this.getFriendListTime = getTimer();
				this.getFriendListClick = 0;
			}
		} else {
			this.model._showFriendPage = 1;
			this.model.loadFriendsData(false, true);
		}
	}

	// FriendsController.as:262-265
	override public function finalize():Void {
		super.finalize();
	}

	// FriendsController.as:267-290。FriendsView.VIEW_EVENT_* 原版 internal、
	// 移植 private，onPageAction 跨类读 → @:access
	@:access(module.friend.FriendsView)
	private function onPageAction(param1:Event):Void {
		if(param1 == null) {
			return;
		}
		var _loc2_:String = this.view.seachText;
		if(param1.type == FriendsView.VIEW_EVENT_FIRST_PAGE) {
			this.model.goFirstPage(_loc2_);
		} else if(param1.type == FriendsView.VIEW_EVENT_BACK_PAGE) {
			this.model.goBackPage(_loc2_);
		} else if(param1.type == FriendsView.VIEW_EVENT_NEXT_PAGE) {
			this.model.goNextPage(_loc2_);
		} else if(param1.type == FriendsView.VIEW_EVENT_LAST_PAGE) {
			this.model.goLastPage(_loc2_);
		}
	}

	// FriendsController.as:292-300
	private function onSearchFriend(param1:Event):Void {
		if(param1 == null) {
			return;
		}
		var _loc2_:String = this.view.seachText;
		this.model.searchFriend(_loc2_);
	}

	// FriendsController.as:302-305（m_model as FriendsModel）
	public var model(get, never):FriendsModel;

	private function get_model():FriendsModel {
		return cast(this.m_model, FriendsModel);
	}

	// FriendsController.as:307-310
	private function onCurrentUserChanged(param1:CommonEvent):Void {
		cast(this.m_view, FriendsView).updateCurrentSelect();
	}

	// FriendsController.as:312-319（首次开合才触发装载）
	private function onCollapseView(param1:Event):Void {
		if(this.getFriend == false) {
			this.model.loadFriendsData(false, false);
			this.getFriend = true;
		}
	}

	// FriendsController.as:321-335（野兽到期时间转发）
	private function onUpdateWild(param1:CommonEvent):Void {
		if(param1 == null || param1.data == null) {
			return;
		}
		var _loc2_:UInt = As3.intOf(Reflect.field(param1.data, "uId"));
		var _loc3_:Float = As3.floatOf(Reflect.field(param1.data, "t"));
		this.model.updateLandsStatus2(_loc2_, _loc3_);
		var _loc4_:FriendItemRender = this.view.getRenderItemById(_loc2_);
		if(_loc4_ != null) {
			_loc4_.updateStatusFlag();
		}
	}

	// FriendsController.as:337-340（m_view as FriendsView）
	public var view(get, never):FriendsView;

	private function get_view():FriendsView {
		return cast(this.m_view, FriendsView);
	}

	// FriendsController.as:342-371（模型/视图惰性建 + 双向监听装配；
	// VIEW_EVENT_* private → @:access）
	@:access(module.friend.FriendsView)
	override public function initialze():Void {
		super.initialze();
		if(this.m_module.container == null) {
			return;
		}
		if(this.m_model == null) {
			this.m_model = FriendsModel.getInstance();
		}
		this.registerListeners();
		if(this.m_view == null) {
			this.m_view = new FriendsView(this);
			if(this.m_module != null && this.m_module.container != null) {
				this.m_module.container.addChild(this.m_view);
			}
			this.m_view.addEventListener(FriendsView.VIEW_EVENT_RELOAD_FRIENDS, this.onReloadFriends, false, 0, true);
			this.m_view.addEventListener(FriendsView.VIEW_EVENT_REFRESH_STATUS, this.onRefreshStatus, false, 0, true);
			this.m_view.addEventListener(FriendsView.VIEW_EVENT_FIRST_PAGE, this.onPageAction, false, 0, true);
			this.m_view.addEventListener(FriendsView.VIEW_EVENT_BACK_PAGE, this.onPageAction, false, 0, true);
			this.m_view.addEventListener(FriendsView.VIEW_EVENT_NEXT_PAGE, this.onPageAction, false, 0, true);
			this.m_view.addEventListener(FriendsView.VIEW_EVENT_LAST_PAGE, this.onPageAction, false, 0, true);
			this.m_view.addEventListener(FriendsView.VIEW_EVENT_SEARCH, this.onSearchFriend, false, 0, true);
			this.m_view.addEventListener(FriendsView.VIEW_EVENT_SORT, this.onSortFriend, false, 0, true);
			this.m_view.addEventListener(FriendsView.VIEW_EVENT_COLLAPSE, this.onCollapseView, false, 0, true);
		}
	}

	// FriendsController.as:373-387（精灵供奉完成：列表去 "7"）
	private function onUpdateFairyFlag(param1:CommonEvent):Void {
		var _loc2_:UInt = 0;
		var _loc3_:FriendItemRender = null;
		if(param1.data != null) {
			_loc2_ = As3.intOf(param1.data);
			this.model.removeFairyStatus(_loc2_);
			_loc3_ = this.view.getRenderItemById(_loc2_);
			if(_loc3_ != null) {
				_loc3_.updateStatusFlag();
			}
		}
	}
}
