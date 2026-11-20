package module.uitools.widgets;

import com.qzone.qfa.events.CommandEvent;
import com.qzone.qui.containers.VBox;
import com.qzone.qui.core.Align;
import common.CommonData;
import common.Consts;
import common.Language;
import common.Settings;
import common.misc.Cookies;
import common.misc.Utils;
import common.view.window.PostWindow;
import entities.Player;
import events.CommonEvent;
import framework.net.CommandDefs;
import framework.net.NetHelper;
import module.uitools.UIController;
import module.uitools.UIToolsModel;
import module.uitools.vo.OfflineData;
import openfl.display.DisplayObjectContainer;
import openfl.display.MovieClip;
import openfl.events.Event;
import openfl.events.EventDispatcher;
import openfl.events.MouseEvent;
import report.ClickReportManager;
import report.EventRecorder;
import report.UserActionRecorder;
import shim.As3;

/**
 * module.uitools.widgets.LeftSideToolBar —— LeftSideToolBar.as 逐句对应
 * （issue #9 uitools 片）。左侧竖排工具条：消息（__info__）、公告（__post__）、
 * 签到（__cards__）、免费礼物（__freegift__）四图标，OfflineData/系统公告/
 * 卡片活动/礼物数据事件驱动增删与播放。MOUSE_OVER/OUT 监听照抄——悬停合成
 * 在 spec/interaction-map.json 落地前不做（见 BLOCKED 项）。
 * 私有只写属性（post/cardsGame/information，AS3 private set 无 get）按
 * Haxe 同为 private 的只写属性对应，外部不可见。
 */
class LeftSideToolBar extends VBox {
	private var m_postWindow:PostWindow;
	private var m_controller:UIController;

	public function new(param1:UIController, param2:Float = 200, param3:Float = 200) {
		this.m_controller = param1;
		super(param2, param3);
		this.backgroundAlpha = 0;
		this.defaultSkin = null;
		this.enableValidate = false;
		this.alignH = Align.LEFT;
		this.alignV = Align.TOP;
		this.mouseEnabled = false;
		this.mouseChildren = true;
		this.addListener();
		this.creatIcon();
	}

	// LeftSideToolBar.as:51-71（private set post，无 get）
	private var post(never, set):Bool;

	private function set_post(param1:Bool):Bool {
		var _loc2_:MovieClip = cast(this.content.getChildByName("__post__"), MovieClip);
		if (param1 == true) {
			if (_loc2_ == null) {
				_loc2_ = cast(Utils.getMaterial("PostIcon"), MovieClip);
				_loc2_.name = "__post__";
				_loc2_.gotoAndStop(1);
				_loc2_.mouseChildren = false;
				_loc2_.buttonMode = true;
				this.addElement(_loc2_);
			}
			this.m_controller.model.loadPostData();
		} else if (_loc2_ != null) {
			this.removeElement(_loc2_);
		}
		return param1;
	}

	// LeftSideToolBar.as:73-101（Boolean(param1) 的对象真值 → 判 null）
	private function onMouseOver(param1:MouseEvent):Void {
		var _loc2_:String = null;
		if (param1 != null && param1.target != null) {
			_loc2_ = param1.target.name;
			switch (_loc2_) {
				case "__info__":
					this.m_controller.showTip(Consts.TIP_NAME_MOUSE, "消息");
				case "__post__":
					this.m_controller.showTip(Consts.TIP_NAME_MOUSE, "公告");
				case "__cards__":
					this.m_controller.showTip(Consts.TIP_NAME_MOUSE, "点击签到赢奖励");
				case "__freegift__":
					if (CommonData.freeGift.unread == 0) {
						this.m_controller.showTip(Consts.TIP_NAME_MOUSE, "免费送礼");
					} else {
						this.m_controller.showTip(Consts.TIP_NAME_MOUSE, "您有新的礼物！");
					}
			}
		}
	}

	// LeftSideToolBar.as:103-115
	private function creatIcon():Void {
		var _loc1_:MovieClip = null;
		_loc1_ = cast(Utils.getMaterial("InformationIcon"), MovieClip);
		if (_loc1_ != null) {
			_loc1_.name = "__info__";
			_loc1_.buttonMode = true;
			_loc1_.stop();
			this.addElement(_loc1_);
		}
		this.validateNow();
	}

	// LeftSideToolBar.as:117-124
	private function onRemoveIcon(param1:CommonEvent):Void {
		var _loc2_:DisplayObjectContainer = cast(param1.data, DisplayObjectContainer);
		if (_loc2_ != null && _loc2_.parent == this.content) {
			this.removeElement(_loc2_);
		}
	}

	// LeftSideToolBar.as:126-137
	private function onCardsGameUpdated(param1:CommonEvent):Void {
		// PORT-NOTE: `param1.data as Boolean` 在 AS3 不做原生强转（非 Boolean
		// 得 null），派发方（UIToolsModel）发的是真 Boolean，truthy 等价
		var _loc2_:Bool = As3.truthy(param1.data);
		if (_loc2_ == true) {
			this.cardsGame = true;
		} else {
			this.cardsGame = false;
		}
	}

	// LeftSideToolBar.as:139-150
	private function openFreeGift():Void {
		if (As3.intOf(CommonData.freeGift.unread) >= 1) {
			this.m_controller.module.app.dispatchEvent(new CommonEvent(Consts.MSG_SHOW_FREEGIFT, {"openIndex": 1}));
		} else {
			this.m_controller.module.app.dispatchEvent(new CommonEvent(Consts.MSG_SHOW_FREEGIFT, {"openIndex": 0}));
		}
		ClickReportManager.reportClick("left.banner.icon_free_gift.click");
	}

	// LeftSideToolBar.as:152-179（private set cardsGame，无 get）
	private var cardsGame(never, set):Bool;

	private function set_cardsGame(param1:Bool):Bool {
		var _loc3_:Bool = false;
		var _loc2_:MovieClip = cast(this.content.getChildByName("__cards__"), MovieClip);
		if (param1 == true) {
			if (_loc2_ == null) {
				_loc3_ = this.m_controller.isCardGameActivity();
				if (_loc3_) {
					_loc2_ = cast(Utils.getMaterial("CardsGameActivityIcon"), MovieClip);
				} else {
					_loc2_ = cast(Utils.getMaterial("CardsGameIcon"), MovieClip);
				}
				_loc2_.name = "__cards__";
				_loc2_.mouseChildren = false;
				_loc2_.buttonMode = true;
				this.addElement(_loc2_);
			}
		} else if (_loc2_ != null) {
			this.removeElement(_loc2_);
		}
		return param1;
	}

	// LeftSideToolBar.as:181-193
	private function onDataChanged(param1:CommonEvent):Void {
		var _loc2_:OfflineData = null;
		if (param1 != null && As3.truthy(param1.data)) {
			_loc2_ = cast(param1.data, OfflineData);
			if (_loc2_ != null) {
				this.information = _loc2_.m_infoNum > 0 ? true : false;
				this.post = _loc2_.m_postNum > 0 ? true : false;
			}
		}
	}

	// LeftSideToolBar.as:195-210
	private function onCurrentUserChanged(param1:CommonEvent):Void {
		var _loc2_:Player = null;
		if (param1 != null && As3.truthy(param1.data)) {
			_loc2_ = cast(param1.data, Player);
			if (_loc2_ != null && _loc2_.me) {
				this.visible = true;
			} else {
				this.visible = false;
			}
		}
	}

	// LeftSideToolBar.as:212-240
	private function onClick(param1:MouseEvent):Void {
		var _loc2_:String = null;
		if (param1 != null && param1.target != null) {
			_loc2_ = param1.target.name;
			switch (_loc2_) {
				case "__info__":
					this.m_controller.model.clearUnReadMsgFlag();
					this.m_controller.module.app.dispatchEvent(new CommonEvent(Consts.MSG_SHOW_PROFILE, {"index": 0}));
					UserActionRecorder.recordAction(UserActionRecorder.HF_SHORTCUTBAR_INFO_CLICKED);
					ClickReportManager.reportClick("left.banner.icon_message.click");
				case "__freegift__":
					this.openFreeGift();
					ClickReportManager.reportClick("left.banner.icon_free_gift.click");
				case "__post__":
					this.openPostWindow();
					UserActionRecorder.recordAction(UserActionRecorder.HF_SHORTCUTBAR_POST_CLICKED);
					ClickReportManager.reportClick("left.banner.icon_announcement.click");
				case "__cards__":
					this.m_controller.module.app.dispatchEvent(new CommonEvent(Consts.MSG_SHOW_CARDSGAMEWINDOW, null));
					UserActionRecorder.recordAction(UserActionRecorder.HF_SHORTCUTBAR_CARDS_CLICKED);
			}
		}
	}

	// LeftSideToolBar.as:242-297（FFDec 把 resetMouseCursor 闭包局部提到头部，
	// 照抄；post 的 `["content"] != undefined` 键缺位判 → Reflect.hasField）
	private function openPostWindow():Void {
		var resetMouseCursor:Void->Void = null;
		var postIcon:MovieClip = null;
		var postText:String = null;
		var url:String = null;
		resetMouseCursor = function():Void {
			m_controller.module.app.useSystemCursor(false);
		};
		var post:Dynamic = this.m_controller.model.loadPostData();
		if (post != null) {
			if (Reflect.hasField(post, "content")) {
				postText = cast(Reflect.field(post, "content"), String);
				if (postText == "" || postText == null) {
					return;
				}
				if (this.m_postWindow == null) {
					this.m_postWindow = new PostWindow(null, Reflect.field(Language.L, "确定"));
					this.m_postWindow.title = "";
					this.m_postWindow.closeFn = resetMouseCursor;
				}
				this.m_postWindow.text = postText;
				this.m_controller.module.app.farmView.winCtrl.open(this.m_postWindow);
				this.m_controller.module.app.useSystemCursor(true);
				Cookies.setObject("postText", postText);
				Cookies.setObject("postClicked", true);
			} else if (Reflect.hasField(post, "imageurl")) {
				url = cast(Reflect.field(post, "imageurl"), String);
				if (url == "" || url == null) {
					return;
				}
				if (this.m_postWindow == null) {
					this.m_postWindow = new PostWindow(null, Reflect.field(Language.L, "确定"));
					this.m_postWindow.title = "";
					this.m_postWindow.closeFn = resetMouseCursor;
				}
				this.m_postWindow.imgUrl = url;
				this.m_controller.module.app.farmView.winCtrl.open(this.m_postWindow);
				this.m_controller.module.app.useSystemCursor(true);
				Cookies.setObject("postImage", url);
				Cookies.setObject("postImageClicked", true);
			}
			EventRecorder.recordSueecssEvent(EventRecorder.HF_POSTVIEW, 0);
			postIcon = cast(this.content.getChildByName("__post__"), MovieClip);
			postIcon.gotoAndStop(1);
		}
	}

	// LeftSideToolBar.as:299-312
	private function addListener():Void {
		this.addEventListener(MouseEvent.MOUSE_OVER, this.onMouseOver);
		this.addEventListener(MouseEvent.MOUSE_OUT, this.onOut);
		this.addEventListener(MouseEvent.CLICK, this.onClick);
		this.m_controller.module.app.addEventListener(Consts.MSG_FREEGIFT_COUNT_OUT, this.freeGiftCountOut, false, 0, true);
		this.m_controller.module.app.addEventListener(Consts.MSG_REFRESH_CARDSGAME, this.onCardsGameUpdated, false, 0, true);
		this.m_controller.module.app.addEventListener(Consts.MSG_REMOVE_SHORTCUT_ICON, this.onRemoveIcon, false, 0, true);
		this.m_controller.module.app.addEventListener(Consts.MSG_CURRENT_USER_CHANGED, this.onCurrentUserChanged, false, 0, true);
		var _loc1_:EventDispatcher = cast(this.m_controller.model, EventDispatcher);
		_loc1_.addEventListener(UIToolsModel.EVENT_OFFLINE_DATA_CHANGED, this.onDataChanged, false, 0, true);
		_loc1_.addEventListener(UIToolsModel.EVENT_SYSTEM_POST_LOADED, this.onSystemPostLoaded, false, 0, true);
		_loc1_.addEventListener(UIToolsModel.GET_FREE_GIFT, this.getFreeGiftHandler, false, 0, true);
	}

	// LeftSideToolBar.as:314-317
	private function onOut(param1:MouseEvent):Void {
		this.m_controller.hideTip();
	}

	// LeftSideToolBar.as:319-336
	private function getFreeGiftHandler(param1:CommonEvent):Void {
		var _loc2_:FreeGiftIcon = null;
		if (Reflect.field(param1.data, "show") == 1) {
			_loc2_ = new FreeGiftIcon();
			if (_loc2_ != null) {
				_loc2_.name = "__freegift__";
				_loc2_.buttonMode = true;
				_loc2_.stop();
				this.addElement(_loc2_);
				_loc2_.init(param1.data);
			}
			CommonData.freeGift = param1.data;
			this.checkFreeGiftAutoPop(_loc2_);
		}
	}

	// LeftSideToolBar.as:338-389（`!= undefined` 键缺位判 → Reflect.hasField）
	private function onSystemPostLoaded(param1:CommonEvent):Void {
		var _loc3_:String = null;
		var _loc4_:Bool = false;
		var _loc5_:String = null;
		var _loc6_:Bool = false;
		var _loc7_:MovieClip = null;
		var _loc8_:String = null;
		if (param1 == null || param1.data == null) {
			return;
		}
		var _loc2_:Dynamic = param1.data;
		if (Reflect.hasField(_loc2_, "content") || Reflect.hasField(_loc2_, "imageurl")) {
			_loc3_ = null;
			_loc4_ = false;
			if (Reflect.hasField(_loc2_, "content")) {
				_loc3_ = cast(Reflect.field(_loc2_, "content"), String);
				_loc4_ = true;
			}
			if (Reflect.hasField(_loc2_, "imageurl")) {
				_loc3_ = cast(Reflect.field(_loc2_, "imageurl"), String);
			}
			_loc5_ = cast(Cookies.getObject(_loc4_ ? "postText" : "postImage"), String);
			// PORT-NOTE: `as Boolean` 不做原生强转，Cookie 里 setObject 存的
			// 是真 Boolean，truthy 等价
			_loc6_ = As3.truthy(Cookies.getObject(_loc4_ ? "postClicked" : "postImageClicked"));
			_loc7_ = cast(this.content.getChildByName("__post__"), MovieClip);
			_loc8_ = null;
			if (_loc3_ != null && _loc3_ != "" && _loc5_ != _loc3_) {
				if (_loc7_ != null) {
					_loc7_.play();
				}
				Cookies.setObject(_loc4_ ? "postClicked" : "postImageClicked", false);
				_loc8_ = cast(Reflect.field(_loc2_, "force_flag"), String);
				if (_loc8_ == "1") {
					this.openPostWindow();
				}
			}
			if (!_loc6_ && _loc8_ != "1") {
				if (_loc7_ != null) {
					_loc7_.play();
				}
			}
		}
	}

	// LeftSideToolBar.as:391-395（FreeGiftIcon.init 不在 MovieClip 类型面上，
	// 反射调（LoadManager 动态方法同款））
	private function freeGiftCountOut(param1:Event):Void {
		var _loc2_:MovieClip = cast(this.content.getChildByName("__freegift__"), MovieClip);
		Reflect.callMethod(_loc2_, Reflect.field(_loc2_, "init"), [CommonData.freeGift]);
	}

	// LeftSideToolBar.as:397-432
	private function checkFreeGiftAutoPop(param1:FreeGiftIcon):Void {
		var arr:Array<Dynamic> = null;
		var start:Date = null;
		var end:Date = null;
		var now:Float = Math.NaN;
		var callBack:CommandEvent->Void = null;
		var freeIcon:FreeGiftIcon = param1;
		callBack = function(param1:CommandEvent):Void {
			var _loc2_:Dynamic = NetHelper.getVOData(param1);
			if (_loc2_ == null) {
				return;
			}
			if (_loc2_ != null && Reflect.field(_loc2_, "bit_flag") != null && Reflect.field(_loc2_, "bit_flag") == true) {
				openFreeGift();
			}
		};
		var autopop:String = Settings.getInstance().getStringAttribute("freeGiftAutopop");
		if (autopop == null || autopop == "") {
			return;
		}
		arr = autopop.split("-");
		// nc_addon.php:114 的配置形态 `8/20/2012-9/3/2012 23:59:59`，两段都是
		// 美式 m/d/Y[ H:M:S]
		start = As3.dateOf(arr[0]);
		end = As3.dateOf(arr[1]);
		now = CommonData.serverTime * 1000;
		// PORT-NOTE: AS3 `new Date(无效串)` 得 .time 为 NaN 的 Date（下面两个
		// 比较都 false、不拦截）；As3.dateOf 解析失败回 null，按 NaN 语义代入
		var startTime:Float = start == null ? Math.NaN : start.getTime();
		var endTime:Float = end == null ? Math.NaN : end.getTime();
		if (now < startTime || now > endTime) {
			return;
		}
		freeIcon.showAnimation();
		NetHelper.sendRequest(CommandDefs.AUTO_POP, {"bitpos": 29}, callBack);
	}

	// LeftSideToolBar.as:434-449（private set information，无 get）
	private var information(never, set):Bool;

	private function set_information(param1:Bool):Bool {
		var _loc2_:MovieClip = cast(this.content.getChildByName("__info__"), MovieClip);
		if (_loc2_ == null) {
			return param1;
		}
		if (param1 == true) {
			_loc2_.play();
		} else {
			_loc2_.gotoAndStop(1);
		}
		return param1;
	}
}
