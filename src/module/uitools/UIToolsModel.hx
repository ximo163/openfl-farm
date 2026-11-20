package module.uitools;

import common.CommonData;
import common.Consts;
import common.Language;
import common.Session;
import common.Settings;
import com.qzone.qfa.events.CommandEvent;
import entities.Player;
import events.CommonEvent;
import framework.net.CommandDefs;
import framework.net.NetHelper;
import framework.net.vo.ServiceResultVO;
import module.uitools.vo.OfflineData;
import module.uitools.vo.ProfileData;
import openfl.events.Event;
import openfl.events.EventDispatcher;
import openfl.net.URLVariables;
import report.EventRecorder;
import shim.As3;

/**
 * module.uitools.UIToolsModel —— UIToolsModel.as 逐句对应（issue #9）。
 * 工具区数据：host 账户 diff → 事件（PersonInfo 的数据源）、离线计数 diff、
 * 每日礼包/VIP 回礼/公告/升级礼包的网络装载与回调。事件名常量取值照抄
 * （:24-46，AS3 public static const）。
 */
class UIToolsModel extends EventDispatcher {
	// UIToolsModel.as:24-46
	public static final EVENT_PLAYER_BASEINFO_CHANGED:String = "PlayerBaseInfoChanged";
	public static final EVENT_PLAYER_ACCOUNT_CHANGED:String = "PlayerAccountChanged";
	public static final EVENT_OFFLINE_DATA_CHANGED:String = "OfflineDataChanged";
	public static final EVENT_SYSTEM_POST_LOADED:String = "SystemPostMsgLoaded";
	public static final EVENT_EVERYDAY_GIFT_LOADED:String = "EverydayGiftLoaded";
	public static final EVENT_EVERYDAY_GIFT_ACCEPTED:String = "EverydayGiftAccepted";
	public static final EVENT_OFFLINE_DATA_MSG:String = "OfflineDataMessage";
	public static final EVENT_LEVELUP_CHANGED:String = "LevelupDataChanged";
	public static final EVENT_LEVELUP_GIFTS:String = "LevelUpGiftLoaded";
	public static final GET_VIPRETURN_GIFT:String = "getVipReturnGift";
	public static final GET_FREE_GIFT:String = "getFreeGift";
	public static final EVENT_SHOW_WARNMSG:String = "showWarnMsg";

	// UIToolsModel.as:48-70
	private var m_host:Player;
	private var m_freeData:Dynamic;
	private var m_myProfile:ProfileData;
	private var m_giftData:Dynamic;
	private var m_postMsgLoading:Bool;
	private var m_giftDataLoading:Bool;
	private var m_freeDataLoading:Bool;
	private var m_offlineData:OfflineData;
	private var m_controller:UIController;
	private var m_postMsg:Dynamic;
	private var m_levelupGifts:Array<Dynamic>;
	private var m_levelupGiftPending:Bool;

	// UIToolsModel.as:72-87
	public function new(param1:UIController) {
		super();
		this.m_myProfile = new ProfileData();
		this.m_offlineData = new OfflineData();
		this.m_postMsg = null;
		this.m_postMsgLoading = false;
		this.m_giftData = null;
		this.m_giftDataLoading = false;
		this.m_freeData = null;
		this.m_freeDataLoading = false;
		this.m_levelupGifts = null;
		this.m_levelupGiftPending = false;
		this.m_host = Session.getInstance().host;
		this.m_controller = param1;
	}

	// UIToolsModel.as:89-92
	public var freeGift(get, never):Dynamic;

	private function get_freeGift():Dynamic {
		return this.m_freeData;
	}

	// UIToolsModel.as:94-124（b/c/d/e diff → OfflineData，变化才派发）。比较侧
	// 照原文裸比（int vs param1["b"]，缺键是 undefined：0 != undefined 成立，
	// 算变化），仅赋值侧 `as int` 收敛——先收敛会吞掉缺键差异
	public function updateOfflineStatus(param1:Dynamic):Void {
		var _loc2_:Bool = false;
		if (param1 != null) {
			if (this.m_offlineData.m_postNum != Reflect.field(param1, "b")) {
				this.m_offlineData.m_postNum = As3.intOf(Reflect.field(param1, "b"));
				_loc2_ = true;
			}
			if (this.m_offlineData.m_msgNum != Reflect.field(param1, "c")) {
				this.m_offlineData.m_msgNum = As3.intOf(Reflect.field(param1, "c"));
				_loc2_ = true;
			}
			if (this.m_offlineData.m_giftNum != Reflect.field(param1, "d")) {
				this.m_offlineData.m_giftNum = As3.intOf(Reflect.field(param1, "d"));
				_loc2_ = true;
			}
			if (this.m_offlineData.m_flowerNum != Reflect.field(param1, "e")) {
				this.m_offlineData.m_flowerNum = As3.intOf(Reflect.field(param1, "e"));
				_loc2_ = true;
			}
		}
		if (_loc2_ == true) {
			dispatchEvent(new CommonEvent(EVENT_OFFLINE_DATA_CHANGED, this.m_offlineData));
		}
	}

	// UIToolsModel.as:126-141（VIP 回礼链替换载荷再派发；礼物计数清零）
	private function onEverydayGiftAccepted(param1:CommandEvent):Void {
		var _loc2_:Dynamic = NetHelper.getVOData(param1);
		if (Session.getInstance().isVipReturn) {
			_loc2_ = this.loadVipReturnGift();
			dispatchEvent(new CommonEvent(EVENT_EVERYDAY_GIFT_ACCEPTED, _loc2_));
		} else {
			dispatchEvent(new CommonEvent(EVENT_EVERYDAY_GIFT_ACCEPTED, _loc2_));
		}
		this.m_offlineData.m_giftNum = 0;
		Session.getInstance().isVipReturn = false;
		EventRecorder.recordSueecssEvent("160860", null);
	}

	// UIToolsModel.as:143-170（feeds/sysmsg/warnmsg 三类新消息分派）
	private function onPostMsgLoaded(param1:CommandEvent):Void {
		var _loc2_:Dynamic = NetHelper.getVOData(param1);
		if (_loc2_ == null) {
			return;
		}
		this.m_postMsgLoading = false;
		this.m_postMsg = _loc2_;
		dispatchEvent(new CommonEvent(EVENT_SYSTEM_POST_LOADED, _loc2_));
		if (Reflect.field(_loc2_, "have_new_feeds") == true) {
			this.m_offlineData.m_infoNum = 1;
			dispatchEvent(new CommonEvent(EVENT_OFFLINE_DATA_CHANGED, this.m_offlineData));
			this.m_controller.module.app.dispatchEvent(new CommonEvent(Consts.MSG_FEEDS_NPC_NEW_FEEDS_FLAG, null));
		}
		if (Reflect.field(_loc2_, "have_new_sysmsg") == true) {
			this.m_offlineData.m_msgNum = 1;
			dispatchEvent(new CommonEvent(EVENT_OFFLINE_DATA_CHANGED, this.m_offlineData));
			dispatchEvent(new CommonEvent(EVENT_OFFLINE_DATA_MSG, 4));
		}
		if (Reflect.field(_loc2_, "have_new_warnmsg") == true) {
			dispatchEvent(new CommonEvent(EVENT_SHOW_WARNMSG, _loc2_));
		}
		EventRecorder.recordSueecssEvent("160861", null);
	}

	// UIToolsModel.as:172-218（礼包数据：移除已领等级档；direction 缺省按
	// 物品拼文案并去尾字符；vipText 补默认；LEVELUP_GIFTS 载荷）
	private function onLevelUpGiftData(param1:CommandEvent):Void {
		var _loc3_:Int = 0;
		var _loc4_:Int = 0;
		var _loc5_:Dynamic = null;
		var _loc2_:Dynamic = NetHelper.getVOData(param1);
		if (_loc2_ == null) {
			return;
		}
		this.m_levelupGiftPending = false;
		if (Reflect.hasField(_loc2_, "lv")) {
			_loc3_ = As3.intOf(Reflect.field(_loc2_, "lv"));
			if (this.m_levelupGifts != null) {
				_loc4_ = this.m_levelupGifts.indexOf(_loc3_);
				while (_loc4_ != -1) {
					this.m_levelupGifts.splice(_loc4_, 1);
					_loc4_ = this.m_levelupGifts.indexOf(_loc3_);
				}
				dispatchEvent(new CommonEvent(EVENT_LEVELUP_CHANGED, this.m_levelupGifts));
			}
		}
		if (!Reflect.hasField(_loc2_, "direction")) {
			Reflect.setField(_loc2_, "direction", "恭喜您升到" + _loc3_ + "级，赠送您 ");
			var items:Dynamic = Reflect.field(_loc2_, "item");
			// AS3 for-each over undefined/null 是零次迭代（不抛），显式判空等价
			if (items != null) {
				for (_loc5_ in (items : Array<Dynamic>)) {
					if (As3.floatOf(Reflect.field(_loc5_, "num")) > 0 && Reflect.field(_loc5_, "name") != null
						&& Reflect.field(_loc5_, "name") != "") {
						Reflect.setField(_loc2_, "direction",
							Reflect.field(_loc2_, "direction") + Std.string(Reflect.field(_loc5_, "num")) + "个"
							+ Std.string(Reflect.field(_loc5_, "name")) + "，");
					}
				}
			}
			var direction:String = Reflect.field(_loc2_, "direction");
			Reflect.setField(_loc2_, "direction", direction.substring(0, direction.length - 1));
		}
		if (Reflect.hasField(_loc2_, "vipItem") && !Reflect.hasField(_loc2_, "vipText")) {
			Reflect.setField(_loc2_, "vipText", "您是尊贵的VIP，还可额外获得以下奖励：");
		}
		Reflect.setField(_loc2_, "levelup", true);
		Reflect.setField(_loc2_, "big", true);
		Reflect.setField(_loc2_, "title", "查看礼包");
		dispatchEvent(new CommonEvent(EVENT_LEVELUP_GIFTS, _loc2_));
		EventRecorder.recordSueecssEvent("160864", null);
	}

	// UIToolsModel.as:220-232
	private function onEverydayGiftLoaded(param1:CommandEvent):Void {
		this.m_giftDataLoading = false;
		var _loc2_:Dynamic = NetHelper.getVOData(param1);
		if (_loc2_ == null) {
			return;
		}
		this.m_giftData = _loc2_;
		Reflect.setField(_loc2_, "everyDayGift", true);
		dispatchEvent(new CommonEvent(EVENT_EVERYDAY_GIFT_LOADED, _loc2_));
		EventRecorder.recordSueecssEvent("160863", null);
	}

	// UIToolsModel.as:234-246
	private function onLevelUpResponse(param1:CommandEvent):Void {
		var _loc2_:Dynamic = NetHelper.getVOData(param1);
		if (_loc2_ == null) {
			return;
		}
		if (Reflect.field(_loc2_, "hasgift") == null || Reflect.field(_loc2_, "hasgift") == false) {
			return;
		}
		this.addLevelUp(_loc2_);
	}

	// UIToolsModel.as:248-251
	public var myProfile(get, never):ProfileData;

	private function get_myProfile():ProfileData {
		return this.m_myProfile;
	}

	// UIToolsModel.as:253-300（先 baseinfo 后 account 的两段 diff 派发）
	public function updateHostInfo():Void {
		var _loc1_:Player = Session.getInstance().host;
		if (_loc1_ == null) {
			return;
		}
		var _loc2_:Bool = false;
		if (this.m_myProfile.m_userName != _loc1_._userName) {
			this.m_myProfile.m_userName = _loc1_._userName;
			_loc2_ = true;
		}
		if (this.m_myProfile.m_photoUrl != _loc1_._headPic) {
			this.m_myProfile.m_photoUrl = _loc1_._headPic;
			_loc2_ = true;
		}
		if (_loc2_ == true) {
			dispatchEvent(new Event(EVENT_PLAYER_BASEINFO_CHANGED));
		}
		_loc2_ = false;
		if (this.m_myProfile.m_gold != _loc1_._money) {
			this.m_myProfile.m_gold = _loc1_._money;
			_loc2_ = true;
		}
		if (this.m_myProfile.m_exp != _loc1_._exp) {
			this.m_myProfile.m_exp = _loc1_._exp;
			_loc2_ = true;
		}
		if (this.m_myProfile.m_fb != _loc1_._fb) {
			this.m_myProfile.m_fb = _loc1_._fb;
			_loc2_ = true;
		}
		if (this.m_myProfile.m_moral != _loc1_._moralExp) {
			this.m_myProfile.m_moral = _loc1_._moralExp;
			_loc2_ = true;
		}
		if (_loc2_ == true) {
			dispatchEvent(new Event(EVENT_PLAYER_ACCOUNT_CHANGED));
		}
	}

	// UIToolsModel.as:302-319（在途的装载位复位并丢弃半成品数据）
	public function resetLoadingFlags():Void {
		if (this.m_postMsgLoading == true) {
			this.m_postMsgLoading = false;
			this.m_postMsg = null;
		}
		if (this.m_giftDataLoading == true) {
			this.m_giftDataLoading = false;
			this.m_giftData = null;
		}
		if (this.m_freeDataLoading == true) {
			this.m_freeDataLoading = false;
			this.m_freeData = null;
		}
	}

	// UIToolsModel.as:321-335（VIP 携 opt=1/isfarm=1；普通走领奖 mod）
	public function acceptGifts(param1:Bool):Void {
		var _loc2_:Dynamic = null;
		if (param1) {
			_loc2_ = {};
			Reflect.setField(_loc2_, "opt", 1);
			Reflect.setField(_loc2_, "isfarm", 1);
			NetHelper.sendRequest(CommandDefs.CMD_GET_VIPRETURN_GIFT, _loc2_, this.onEverydayGiftAccepted, this.onNetError);
		} else {
			NetHelper.sendRequest(CommandDefs.CMD_ACCEPT_EVERYDAY_GIFT, null, this.onEverydayGiftAccepted, this.onNetError);
		}
	}

	// UIToolsModel.as:337-340
	public var postMsg(get, never):Dynamic;

	private function get_postMsg():Dynamic {
		return this.m_postMsg;
	}

	// UIToolsModel.as:342-377（hasgift+lvup 合并去重 / Array 载荷直接替换，
	// 总派发 LEVELUP_CHANGED）
	public function addLevelUp(param1:Dynamic):Void {
		var _loc2_:Array<Dynamic> = null;
		var _loc3_:Int = 0;
		if (param1 == null) {
			return;
		}
		if (Reflect.hasField(param1, "hasgift") == true && As3.truthy(Reflect.field(param1, "hasgift")) == true) {
			_loc2_ = cast Reflect.field(param1, "lvup");
			if (_loc2_ == null) {
				return;
			}
			if (this.m_levelupGifts == null) {
				this.m_levelupGifts = _loc2_;
			} else {
				for (_loc3_ in (_loc2_ : Array<Dynamic>)) {
					if (this.m_levelupGifts.indexOf(_loc3_) == -1) {
						this.m_levelupGifts.push(_loc3_);
					}
				}
			}
		}
		if (Std.isOfType(param1, Array) && (param1 : Array<Dynamic>).length > 0) {
			this.m_levelupGifts = cast param1;
		}
		dispatchEvent(new CommonEvent(EVENT_LEVELUP_CHANGED, this.m_levelupGifts));
	}

	// UIToolsModel.as:379-392（缓存命中直回；在途回 null；否则发请求）
	public function loadEveryDayGift():Dynamic {
		if (this.m_giftData != null) {
			return this.m_giftData;
		}
		if (this.m_giftDataLoading == true) {
			return null;
		}
		this.m_giftDataLoading = true;
		NetHelper.sendRequest(CommandDefs.CMD_GET_EVERYDAY_GIFT, null, this.onEverydayGiftLoaded, this.onNetError);
		return null;
	}

	// UIToolsModel.as:394-406（免费请求数据落 CommonData.freeGift）
	private function onFreeGiftLoaded(param1:CommandEvent):Void {
		var _loc2_:Dynamic = NetHelper.getVOData(param1);
		if (_loc2_ == null) {
			return;
		}
		this.m_freeDataLoading = false;
		this.m_freeData = _loc2_;
		CommonData.freeGift = this.m_freeData;
		dispatchEvent(new CommonEvent(GET_FREE_GIFT, this.m_freeData));
		EventRecorder.recordSueecssEvent("160862", null);
	}

	// UIToolsModel.as:408-452（按 cmdID 复位对应加载位/在途位并上报错误）
	private function onNetError(param1:CommandEvent):Void {
		if (param1 == null || param1.body == null) {
			return;
		}
		var _loc2_:Int = As3.intOf(Reflect.field(param1.body, "cmdID"));
		var _loc3_:ServiceResultVO = cast param1.result;
		var _loc4_:String = "";
		if (_loc3_ == null || _loc3_.m_message == "") {
			_loc4_ = Reflect.field(Language.L, "请求超时，稍后再试");
		} else {
			_loc4_ = _loc3_.m_message;
		}
		if (_loc2_ == CommandDefs.CMD_GET_SYSTEM_POST_MSG) {
			this.m_postMsgLoading = false;
			EventRecorder.recordErrorEvent("160861", null, 4);
		} else if (_loc2_ == CommandDefs.CMD_GET_EVERYDAY_GIFT) {
			this.m_giftDataLoading = false;
			EventRecorder.recordErrorEvent("160863", null, 4);
		} else if (_loc2_ == CommandDefs.CMD_FREE_COUNT) {
			this.m_freeDataLoading = false;
			EventRecorder.recordErrorEvent("160862", null, 4);
		} else if (_loc2_ == CommandDefs.CMD_LEVEL_UP) {
			if (As3.floatOf(Reflect.field(Reflect.field(param1.body, "__body"), "op")) == 1) {
				this.m_levelupGiftPending = false;
			}
			EventRecorder.recordErrorEvent("160864", null, 4);
		} else if (_loc2_ == CommandDefs.CMD_GET_VIPRETURN_GIFT || _loc2_ == CommandDefs.CMD_ACCEPT_EVERYDAY_GIFT) {
			EventRecorder.recordErrorEvent("160860", null, 4);
		}
	}

	// UIToolsModel.as:454-470（在途门 → false；置 pending 后发 op=1 领取。
	// 原版第二判 `m_levelupGifts == null && length == 0` 是矛盾式：null 时
	// AS3 取 .length 抛 #1009，非 null 时首项已假短路——实际只可能由非空
	// 且空数组外的路径通过，照抄不纠）
	public function drawLevelUpGift():Bool {
		if (this.m_levelupGiftPending == true) {
			return false;
		}
		if (this.m_levelupGifts == null && this.m_levelupGifts.length == 0) {
			return false;
		}
		this.m_levelupGiftPending = true;
		NetHelper.sendRequest(CommandDefs.CMD_LEVEL_UP, {
			"lv": this.m_levelupGifts[0],
			"op": 1
		}, this.onLevelUpGiftData, this.onNetError);
		return true;
	}

	// UIToolsModel.as:472-486（无条件拷档案——不含 _fb——两事件必派发）
	public function initializeMyProfile():Void {
		var _loc1_:Player = Session.getInstance().host;
		if (_loc1_ == null) {
			return;
		}
		this.m_myProfile.m_userName = _loc1_._userName;
		this.m_myProfile.m_photoUrl = _loc1_._headPic;
		dispatchEvent(new Event(EVENT_PLAYER_BASEINFO_CHANGED));
		this.m_myProfile.m_exp = _loc1_._exp;
		this.m_myProfile.m_gold = _loc1_._money;
		this.m_myProfile.m_moral = _loc1_._moralExp;
		dispatchEvent(new Event(EVENT_PLAYER_ACCOUNT_CHANGED));
	}

	// UIToolsModel.as:488-505（appId/serviceId/uin 走 getRequest）
	public function loadPostData():Dynamic {
		if (this.m_postMsg != null) {
			return this.m_postMsg;
		}
		if (this.m_postMsgLoading == true) {
			return null;
		}
		this.m_postMsgLoading = true;
		var _loc1_:URLVariables = new URLVariables();
		Reflect.setField(_loc1_, "appId", 353);
		Reflect.setField(_loc1_, "serviceId", Settings.getInstance().mode == "" ? 2 : 1);
		Reflect.setField(_loc1_, "uin", Session.getInstance().host._uinLogin);
		NetHelper.getRequest(CommandDefs.CMD_GET_SYSTEM_POST_MSG, _loc1_, this.onPostMsgLoaded, this.onNetError);
		return null;
	}

	// UIToolsModel.as:507-512（info/msg 清零 + 派发）
	public function clearUnReadMsgFlag():Void {
		this.m_offlineData.m_infoNum = 0;
		this.m_offlineData.m_msgNum = 0;
		dispatchEvent(new CommonEvent(EVENT_OFFLINE_DATA_CHANGED, this.m_offlineData));
	}

	// UIToolsModel.as:514-521（VIP 回礼直接复用每日礼包缓存）
	public function loadVipReturnGift():Dynamic {
		if (this.m_giftData != null) {
			return this.m_giftData;
		}
		return null;
	}

	// UIToolsModel.as:523-526
	public var everydayGift(get, never):Dynamic;

	private function get_everydayGift():Dynamic {
		return this.m_giftData;
	}

	// UIToolsModel.as:528-541
	public function loadFreeData():Dynamic {
		if (this.m_freeData != null) {
			return this.m_freeData;
		}
		if (this.m_freeDataLoading == true) {
			return null;
		}
		this.m_freeDataLoading = true;
		NetHelper.sendRequest(CommandDefs.CMD_FREE_COUNT, null, this.onFreeGiftLoaded, this.onNetError);
		return null;
	}

	// UIToolsModel.as:543-559（√((exp+25)/100)-0.5 的等级跳变检测 → op=0
	// 打探；错误回调同为 onLevelUpResponse）
	public function checkLevelup(param1:Int):Void {
		if (param1 <= 0) {
			return;
		}
		var _loc2_:Int = Session.getInstance().host._exp;
		var _loc3_:Int = Std.int(Math.sqrt((_loc2_ + 25) / 100) - 0.5);
		var _loc4_:Int = Std.int(Math.sqrt((_loc2_ + param1 + 25) / 100) - 0.5);
		if (_loc4_ > _loc3_) {
			NetHelper.sendRequest(CommandDefs.CMD_LEVEL_UP, {
				"level": _loc4_,
				"op": 0
			}, this.onLevelUpResponse, this.onLevelUpResponse);
		}
	}
}
