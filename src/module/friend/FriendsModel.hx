package module.friend;

import com.qzone.qfa.events.CommandEvent;
import common.CommonData;
import common.Consts;
import common.FeartureManager;
import common.Language;
import common.Session;
import common.Settings;
import common.misc.Cookies;
import common.misc.QzoneJSAPI;
import entities.Friend;
import entities.Player;
import events.CommonEvent;
import framework.net.CommandDefs;
import framework.net.NetHelper;
import openfl.events.EventDispatcher;
import report.EventRecorder;
import shim.As3;

/**
 * module.friend.FriendsModel —— FriendsModel.as 1489 loc 整类翻译（issue #20）。
 * 好友列表（mod=friend）＋好友状态（cgi_farm_getstatus_filter）＋过滤
 * （mod=friend&act=addFilter/delFilter）的数据源：排序/搜索/分页、状态表
 * （"1"成熟可偷/"2"可除草/"3"可除虫/"4"野牛/"5"召回/"6"鱼塘/"7"精灵）的
 * 装载与本地推进。
 * 数字键 Object 访问（m_friendStatus[uid] 等）→ Reflect.field/setField +
 * Std.string(键)；`!= undefined` 存在性 → As3.hasProp；AS3 for-each/for-in 对
 * null 集合零迭代，Haxe 判空保持同语义（见各 PORT-NOTE）。
 * NetHelper.sendRequest 在 theApp == null 时 no-op（#7 已译）；Cookies 的
 * SharedObject 未初始化时读 null 写丢弃；EventRecorder 已按 deviations
 * （no-qq-telemetry）DISABLED（调用点参数照常求值）；QzoneJSAPI.WB 恒 false
 * （qqoutlets-shim）。依赖的 entities/Friend 方法体已随本模块按 Friend.as 补齐。
 */
class FriendsModel extends EventDispatcher {
	// FriendsModel.as:24
	public static var instance:FriendsModel;

	// FriendsModel.as:26（AS3 internal static const → private，CLAUDE.md 映射）
	private static final EVENT_ALERT_WINDOW:String = "PopAlertWindow";

	// FriendsModel.as:28
	private static final EVENT_DATA_LOADING:String = "FriendDataLoading";

	// FriendsModel.as:30
	private static final EVENT_DATA_LOAD_FAILED:String = "FriendDataFailed";

	// FriendsModel.as:32
	private static final EVENT_FUNCTION_FORBIDDEN:String = "FriendListForbid";

	// FriendsModel.as:34
	private static final EVENT_HEAD_PIC_LOADED:String = "HeadPicLoaded";

	// FriendsModel.as:36
	private static final EVENT_REFRESH_PAGE:String = "RefreshCurrentpage";

	// FriendsModel.as:38
	public static final friendPageNum:Int = 10;

	// FriendsModel.as:40（AS3 Object → Dynamic）
	private var m_friendListFilter:Dynamic;

	// FriendsModel.as:42
	private var m_gotFriendStatus:Bool;

	// FriendsModel.as:44
	private var m_friendListMap:Dynamic;

	// FriendsModel.as:46
	private var m_friendListLocal:Array<Dynamic>;

	// FriendsModel.as:48
	private var m_requestStartTime:Int;

	// FriendsModel.as:50
	private var m_updateFriendCache:Bool;

	// FriendsModel.as:52
	private var m_sortField:String;

	// FriendsModel.as:54
	private var m_friendStatus:Dynamic;

	// FriendsModel.as:56（原版 public var）
	public var _showFriendPage:Int;

	// FriendsModel.as:58
	private var m_showFriendList:Array<Dynamic>;

	// FriendsModel.as:60
	private var m_friendListNet:Array<Dynamic>;

	// FriendsModel.as:62
	private var m_searchFriendValue:String;

	// FriendsModel.as:64
	private var m_friendList:Array<Dynamic>;

	public function new() {
		// FriendsModel.as:66-81
		super();
		this.m_updateFriendCache = false;
		this.m_requestStartTime = 0;
		this.m_friendList = null;
		this.m_friendListNet = null;
		this.m_friendListLocal = null;
		this.m_friendStatus = null;
		this.m_friendListFilter = null;
		this.m_gotFriendStatus = false;
		this._showFriendPage = 1;
		this.m_showFriendList = null;
		this.m_sortField = "exp";
		this.m_searchFriendValue = "";
	}

	// FriendsModel.as:83-90
	public static function getInstance():FriendsModel {
		if (instance == null) {
			instance = new FriendsModel();
		}
		return instance;
	}

	// FriendsModel.as:92-95
	private function onWBProfileLoadedFail(param1:CommandEvent):Void {
		EventRecorder.recordErrorEvent("160855", null, 4);
	}

	// FriendsModel.as:97-108
	public function removeFairyStatus(param1:UInt):Void {
		if (this.m_friendStatus == null) {
			return;
		}
		var _loc2_:Dynamic = Reflect.field(this.m_friendStatus, Std.string(param1));
		if (_loc2_ != null) {
			Reflect.deleteField(_loc2_, "7");
		}
	}

	// FriendsModel.as:110-147
	private function updateHeadList():Void {
		var _loc1_:Array<Dynamic> = null;
		var _loc2_:Friend = null;
		var _loc3_:Array<Dynamic> = null;
		var _loc4_:Friend = null;
		if (QzoneJSAPI.WB == true) {
			_loc1_ = [];
			// PORT-NOTE: AS3 for-each 对 null 数组零迭代，Haxe 会抛，判空保持同语义
			if (this.m_showFriendList != null) {
				for (_e in this.m_showFriendList) {
					_loc2_ = _e;
					if (_loc2_._headPic == "" || _loc2_._headPic == null) {
						_loc1_.push(_loc2_._uId);
					}
				}
			}
			if (_loc1_.length > 0) {
				NetHelper.sendRequest(CommandDefs.CMD_WB_PROFILE, {"uids": _loc1_.join(",")}, this.onWBProfileLoadedSuccess, this.onWBProfileLoadedFail);
			}
			return;
		}
		if (Settings.getInstance().mode == "qzone") {
			_loc3_ = [];
			if (this.m_showFriendList != null) {
				for (_e in this.m_showFriendList) {
					_loc4_ = _e;
					if (_loc4_._headPic == "" || _loc4_._headPic == null) {
						_loc3_.push(_loc4_._uin);
					}
				}
			}
			if (_loc3_.length > 0) {
				QzoneJSAPI.getHeadList(_loc3_, 25, this.setHeadList);
			}
		}
	}

	// FriendsModel.as:149-210
	private function specialProcessStatus():Void {
		var _loc4_:String = null;
		var _loc5_:Friend = null;
		var _loc6_:Float = Math.NaN;
		var _loc7_:Float = Math.NaN;
		var _loc1_:Bool = Settings.isQZoneUinMode;
		var _loc2_:UInt = 0;
		var _loc3_:Array<Dynamic> = null;
		if (this.m_friendListNet != null) {
			_loc3_ = this.m_friendListNet;
		} else if (this.m_friendList != null) {
			_loc3_ = this.m_friendList;
		} else if (this.m_friendListLocal != null) {
			_loc3_ = this.m_friendListLocal;
		}
		// PORT-NOTE: AS3 for-in 对 null Object 零迭代（onRefreshStatusSuccess
		// 无 status 键时表可为 null），Haxe Reflect.fields(null) 会抛，判空保持
		// 同语义；Reflect.fields 是键快照，循环内 delete 当前键与 AS3 一致
		if (this.m_friendStatus != null) {
			for (_k in Reflect.fields(this.m_friendStatus)) {
				_loc4_ = _k;
				if (Reflect.field(this.m_friendStatus, _loc4_) == null) {
					Reflect.deleteField(this.m_friendStatus, _loc4_);
				} else {
					if (Std.isOfType(Reflect.field(this.m_friendStatus, _loc4_), String)) {
						Reflect.setField(this.m_friendStatus, _loc4_, {});
					}
					// String→{} 之后原版逐次重读表项，这里读一次（值此后不再换）
					var _loc8_:Dynamic = Reflect.field(this.m_friendStatus, _loc4_);
					_loc2_ = 0;
					// PORT-NOTE: AS3 for-each 对 null 零迭代，判空保持同语义
					if (_loc3_ != null) {
						for (_e in _loc3_) {
							_loc5_ = _e;
							if (Std.string(_loc5_._uin) == _loc4_) {
								_loc2_ = _loc5_._uId;
								if (_loc1_ == true) {
									_loc2_ = _loc5_._uin;
								}
								break;
							}
						}
					}
					// PORT-NOTE: 原版 parseFloat 先隐式转串再解析；As3.floatOf 对
					// Bool 走 Number() 语义（true→1，AS3 是 NaN）——"6" 的 Bool 值
					// 只来自 updatePoolStatus 的 true/false 写入，置 true 幂等、
					// f_ cookie 全部署无写入方，差异不可观测；Int/String 值两助
					// 手等价
					if (As3.hasProp(_loc8_, "6")) {
						_loc6_ = As3.floatOf(Reflect.field(_loc8_, "6"));
						if (Math.isNaN(_loc6_) == false && _loc6_ > 0) {
							Reflect.setField(_loc8_, "6", true);
							_loc7_ = As3.floatOf(Cookies.getObject("f_" + _loc2_));
							if (Math.isNaN(_loc7_) == false && _loc7_ > 0 && _loc6_ < _loc7_) {
								Reflect.setField(_loc8_, "6", false);
							}
						}
					}
				}
			}
		}
	}

	// FriendsModel.as:212-215
	public function reloadThisPage():Void {
		this.pageHandler();
	}

	// FriendsModel.as:217-237
	public function canPick(param1:UInt, param2:UInt):Void {
		var _loc3_:Int = 0;
		if (param1 == 0) {
			return;
		}
		if (this.m_gotFriendStatus == false) {
			return;
		}
		// 原版 `!= undefined && != null` 两次取值，此处一次读进门
		var _loc2_:Dynamic = Reflect.field(this.m_friendStatus, Std.string(param1));
		if (As3.hasProp(this.m_friendStatus, Std.string(param1)) && _loc2_ != null && Std.isOfType(Reflect.field(_loc2_, "1"), Int)) {
			_loc3_ = As3.intOf(Reflect.field(_loc2_, "1"));
			if (_loc3_ > CommonData.serverTime) {
				Reflect.setField(_loc2_, "1", true);
				NetHelper.sendRequest(CommandDefs.CMD_OPERATE_CHECKSTATUS, {"ownerId": param2}, null, null);
			}
		}
	}

	// FriendsModel.as:239-263
	public function sortBy(param1:String):Void {
		var _loc2_:Int = 0;
		var _loc3_:Friend = null;
		var _loc4_:Int = 0;
		if (param1 == this.m_sortField) {
			return;
		}
		this.m_sortField = param1;
		if (this.m_friendList != null) {
			// PORT-NOTE: AS3 Array.sort 直传返回 Number 的比较器；Haxe 的
			// Array.sort 只收 Int，friendSort 只产 -1/0/1（:1152-1167），包
			// Std.int 等价
			this.m_friendList.sort(function(_a:Dynamic, _b:Dynamic):Int {
				return Std.int(this.friendSort(_a, _b));
			});
			_loc2_ = this.m_friendList.length;
			_loc3_ = null;
			_loc4_ = 0;
			while (_loc4_ < _loc2_) {
				_loc3_ = this.m_friendList[_loc4_];
				_loc3_.sort = _loc4_ + 1;
				_loc4_++;
			}
			this.pageHandler();
		}
	}

	// FriendsModel.as:265-268
	public function removeFriendListFilter(param1:Int):Void {
		NetHelper.sendRequest(CommandDefs.CMD_REMOVE_FRIEND_FILTER, {"uin": param1}, this.onRemoveFriendFilterSuccess, this.onFriendFilterOpError);
	}

	// FriendsModel.as:270-324
	public function loadFriendsData(param1:Bool = false, param2:Bool = false):Void {
		if (this.checkServerDown() == true) {
			return;
		}
		if (this.forbidden() == true) {
			return;
		}
		if (this.openByFlashVar() == true) {
			return;
		}
		dispatchEvent(new CommonEvent(EVENT_DATA_LOADING, {"show": true}));
		if (param1 == true) {
			this.m_updateFriendCache = true;
			this.m_requestStartTime = As3.getTimer();
			NetHelper.sendRequest(CommandDefs.CMD_GET_FRIENDLIST, null, this.onFriendsDataLoaded, this.onFriendsDataFailed);
			return;
		}
		var _loc3_:Settings = Settings.getInstance();
		var _loc4_:String = Session.getInstance().hostId;
		var _loc5_:Array<Dynamic> = null;
		if (QzoneJSAPI.WB == false) {
			_loc5_ = Cookies.getObject(_loc3_.mode + _loc4_, CommonData.serverTime);
		}
		if (_loc5_ != null && _loc5_.length > 0) {
			if (_loc3_.getStringAttribute("updateFriendCache") != "" && _loc3_.mode == "qzone" && As3.hasProp(_loc5_[0], "_uin") == false) {
				this.m_updateFriendCache = true;
				NetHelper.sendRequest(CommandDefs.CMD_GET_FRIENDLIST, {
					"refresh": param1,
					"user": param2
				}, this.onFriendsDataLoaded, this.onFriendsDataFailed);
			} else {
				this.loadFriendsDataFromCache(_loc5_);
				this.loadFriendStatus(this.m_friendListLocal, param1);
			}
		} else {
			this.m_updateFriendCache = true;
			this.m_requestStartTime = As3.getTimer();
			NetHelper.sendRequest(CommandDefs.CMD_GET_FRIENDLIST, {
				"refresh": param1,
				"user": param2
			}, this.onFriendsDataLoaded, this.onFriendsDataFailed);
		}
	}

	// FriendsModel.as:326-357
	private function onFriendStatusLoaded(param1:CommandEvent):Void {
		var _loc2_:Dynamic = null;
		this.m_gotFriendStatus = true;
		dispatchEvent(new CommonEvent(EVENT_DATA_LOADING, {"show": false}));
		if (param1 != null) {
			_loc2_ = NetHelper.getVOData(param1);
			if (_loc2_ != null && As3.hasProp(_loc2_, "status") == true) {
				this.m_friendStatus = Reflect.field(_loc2_, "status");
			}
			if (_loc2_ != null && As3.hasProp(_loc2_, "filter") == true) {
				this.m_friendListFilter = Reflect.field(_loc2_, "filter");
			}
			this.specialProcessStatus();
		}
		if (this.m_friendListNet != null) {
			this.processFriendList(this.m_friendListNet);
		} else if (this.m_friendList != null) {
			this.processFriendList(this.m_friendList);
		} else if (this.m_friendListLocal != null) {
			this.processFriendList(this.m_friendListLocal);
		}
		EventRecorder.recordSueecssEvent(EventRecorder.HF_GET_FRIENDLIST_STATUS, null, "cgi_farm_getstatus_filter");
	}

	// FriendsModel.as:359-377
	public function goBackPage(param1:String = ""):Void {
		if (param1 != "") {
			this.m_searchFriendValue = param1;
			if (this._showFriendPage - 1 > this.showFriendSum) {
				this._showFriendPage = 1;
				this.pageHandler();
				return;
			}
		}
		if (this._showFriendPage - 1 > 0) {
			this.m_searchFriendValue = param1;
			--this._showFriendPage;
			this.pageHandler();
		}
	}

	// FriendsModel.as:379-406
	private function onWBProfileLoadedSuccess(param1:CommandEvent):Void {
		var _loc2_:Dynamic = NetHelper.getVOData(param1);
		if (_loc2_ == null || As3.hasProp(_loc2_, "data") == false) {
			return;
		}
		var _loc3_:Dynamic = Reflect.field(_loc2_, "data");
		var _loc4_:Array<Dynamic> = this.m_friendList;
		var _loc5_:String = "";
		var _loc6_:Int = 0;
		while (_loc6_ < _loc4_.length) {
			_loc5_ = Std.string(_loc4_[_loc6_]._uId);
			if (As3.hasProp(_loc3_, _loc5_) && Reflect.field(_loc3_, _loc5_) != null) {
				// 元素是真 Friend，收进类型局部再写字段（CLAUDE.md 动态接收者禁令）
				var _loc7_:Friend = _loc4_[_loc6_];
				_loc7_._headPic = Reflect.field(Reflect.field(_loc3_, _loc5_), "img");
				_loc7_._userName = Reflect.field(Reflect.field(_loc3_, _loc5_), "nick");
				if (_loc7_._headPic == "") {
					_loc7_._headPic = null;
				}
			}
			_loc6_++;
		}
		dispatchEvent(new CommonEvent(EVENT_HEAD_PIC_LOADED, _loc4_));
		EventRecorder.recordSueecssEvent("160855", null);
	}

	// FriendsModel.as:408-449
	private function setHeadList(param1:Dynamic):Void {
		if (param1 == null) {
			return;
		}
		var _loc2_:Array<Dynamic> = this.m_friendList;
		var _loc3_:String = "";
		var _loc4_:Int = 0;
		while (_loc4_ < _loc2_.length) {
			_loc3_ = Std.string(_loc2_[_loc4_]._uin);
			if (As3.hasProp(param1, _loc3_) && Reflect.field(param1, _loc3_) != null) {
				var _loc9_:Friend = _loc2_[_loc4_];
				if (Std.isOfType(Reflect.field(param1, _loc3_), String)) {
					_loc9_._headPic = Reflect.field(param1, _loc3_);
				} else {
					// PORT-NOTE: `param1[key][0]` 数字串键下标 → As3.arrayIndex
					_loc9_._headPic = As3.arrayIndex(Reflect.field(param1, _loc3_), "0");
				}
			}
			_loc4_++;
		}
		var _loc5_:String = Session.getInstance().hostId;
		var _loc6_:Float = CommonData.serverTime + 86400 * 3;
		var _loc7_:String = Settings.getInstance().mode;
		Cookies.setObject(_loc7_ + _loc5_, _loc2_, _loc6_);
		for (_k in Reflect.fields(param1)) {
			_loc3_ = _k;
			var _loc10_:Friend = Reflect.field(this.m_friendListMap, _loc3_);
			if (Std.isOfType(Reflect.field(param1, _loc3_), String)) {
				_loc10_._headPic = Reflect.field(param1, _loc3_);
			} else {
				_loc10_._headPic = As3.arrayIndex(Reflect.field(param1, _loc3_), "0");
			}
		}
		dispatchEvent(new CommonEvent(EVENT_HEAD_PIC_LOADED, param1));
	}

	// FriendsModel.as:451-491
	public function refreshFriendStatus(param1:Bool):Void {
		var _loc4_:Friend = null;
		var _loc5_:CommandEvent = null;
		if (this.m_friendList == null) {
			return;
		}
		if (Session.getInstance().healthModeValid == true) {
			this.onFriendStatusLoaded(null);
			return;
		}
		if (this.forbidden() == true) {
			return;
		}
		if (param1 == false && this.m_friendStatus != null) {
			_loc5_ = new CommandEvent(CommandEvent.COMPLETE);
			_loc5_.result = this.m_friendStatus;
			this.onFriendStatusLoaded(_loc5_);
			return;
		}
		var _loc2_:Array<Dynamic> = [];
		var _loc3_:Array<Dynamic> = [];
		for (_e in this.m_friendList) {
			_loc4_ = _e;
			if (Settings.getInstance().mode == "qzone") {
				_loc3_.push(_loc4_._uin);
			}
			// `_uId || _userId`：AS3 数字 0 为假，As3.or 复刻
			_loc2_.push(As3.or(_loc4_._uId, _loc4_._userId));
		}
		dispatchEvent(new CommonEvent(EVENT_DATA_LOADING, {"show": true}));
		NetHelper.sendRequest(CommandDefs.CMD_GET_FRIENDLIST_STATUS, {
			"cmd": 1,
			"friend_uids": _loc2_.join(","),
			"friend_uins": _loc3_.join(",")
		}, this.onRefreshStatusSuccess, this.onRefreshStatusFailed);
	}

	// FriendsModel.as:493-559
	private function onFriendsDataLoaded(param1:CommandEvent):Void {
		var _loc3_:Friend = null;
		var _loc4_:Int = 0;
		var _loc5_:Player = null;
		var _loc6_:Friend = null;
		var _loc7_:Int = 0;
		var _loc8_:Int = 0;
		var _loc9_:String = null;
		var _loc10_:Float = Math.NaN;
		var _loc11_:String = null;
		var _loc2_:Dynamic = NetHelper.getVOData(param1);
		if (_loc2_ == null) {
			return;
		}
		dispatchEvent(new CommonEvent(EVENT_DATA_LOADING, {"show": false}));
		if (this.checkServerDown() == true) {
			return;
		}
		if (this.hasMe(_loc2_) == false) {
			_loc3_ = new Friend(null);
			_loc3_.importFromPlayer(Session.getInstance().host);
			_loc3_._headPic = "";
			(_loc2_ : Array<Dynamic>).push(_loc3_);
		} else {
			_loc4_ = (_loc2_ : Array<Dynamic>).length;
			_loc5_ = Session.getInstance().host;
			_loc6_ = null;
			_loc7_ = 0;
			while (_loc7_ < _loc4_) {
				_loc6_ = (_loc2_ : Array<Dynamic>)[_loc7_];
				if (_loc6_ != null && _loc6_._uId == _loc5_._uId) {
					_loc6_._exp = _loc5_._exp;
					_loc6_._money = _loc5_._money;
					break;
				}
				_loc7_++;
			}
		}
		if (this.m_updateFriendCache == true && QzoneJSAPI.WB == false) {
			_loc8_ = As3.getTimer() - this.m_requestStartTime;
			EventRecorder.recordSueecssEvent("18169", _loc8_, "mod=friend");
			_loc9_ = Session.getInstance().hostId;
			_loc10_ = CommonData.serverTime + 86400 * 3;
			_loc11_ = Settings.getInstance().mode;
			Cookies.setObject(_loc11_ + _loc9_, _loc2_, _loc10_, true);
			this.m_updateFriendCache = false;
		}
		this.m_friendListNet = _loc2_;
		if (Session.getInstance().healthModeValid == true) {
			this.processFriendList(_loc2_);
		} else {
			this.loadFriendStatus(_loc2_);
		}
		EventRecorder.recordSueecssEvent(EventRecorder.HF_GET_FRIENDLIST, null, "mod=friend");
	}

	// FriendsModel.as:561-570
	private function checkServerDown():Bool {
		var _loc1_:String = Settings.getInstance().getStringAttribute("xb");
		if (_loc1_ != "") {
			dispatchEvent(new CommonEvent(EVENT_DATA_LOAD_FAILED, {"error": _loc1_}));
			return true;
		}
		return false;
	}

	// FriendsModel.as:572-584
	public function goNextPage(param1:String = ""):Void {
		this.m_searchFriendValue = param1;
		if (this._showFriendPage + 1 <= this.showFriendSum) {
			this._showFriendPage += 1;
		} else {
			this._showFriendPage = 1;
		}
		this.pageHandler();
	}

	// FriendsModel.as:586-627
	public function loadFriendStatus(param1:Array<Dynamic>, param2:Bool = false):Void {
		var _loc6_:Friend = null;
		var _loc7_:CommandEvent = null;
		if (Session.getInstance().healthModeValid == true) {
			this.onFriendStatusLoaded(null);
			return;
		}
		if (this.checkServerDown() == true) {
			return;
		}
		if (this.m_friendListLocal == null) {
			this.m_friendListLocal = param1;
		}
		if (param2 == false && this.m_friendStatus != null) {
			_loc7_ = new CommandEvent(CommandEvent.COMPLETE);
			_loc7_.result = this.m_friendStatus;
			this.onFriendStatusLoaded(_loc7_);
			return;
		}
		var _loc3_:Array<Dynamic> = [];
		var _loc4_:Array<Dynamic> = [];
		var _loc5_:String = Settings.getInstance().mode;
		// PORT-NOTE: AS3 for-each 对 null 零迭代，判空保持同语义
		if (param1 != null) {
			for (_e in param1) {
				_loc6_ = _e;
				if (_loc5_ == "qzone") {
					_loc4_.push(_loc6_._uin);
				}
				_loc3_.push(As3.or(_loc6_._uId, _loc6_._userId));
			}
		}
		dispatchEvent(new CommonEvent(EVENT_DATA_LOADING, {"show": true}));
		NetHelper.sendRequest(CommandDefs.CMD_GET_FRIENDLIST_STATUS, {
			"cmd": 3,
			"friend_uids": _loc3_.join(","),
			"friend_uins": _loc4_.join(",")
		}, this.onFriendStatusLoaded, this.onFriendStatusFailed);
	}

	// FriendsModel.as:629-645
	private function onRefreshStatusSuccess(param1:CommandEvent):Void {
		var _loc2_:Dynamic = NetHelper.getVOData(param1);
		if (_loc2_ == null) {
			return;
		}
		if (As3.hasProp(_loc2_, "status") == true) {
			this.m_friendStatus = Reflect.field(_loc2_, "status");
		}
		this.specialProcessStatus();
		this.copyStatus();
		dispatchEvent(new CommonEvent(EVENT_DATA_LOADING, {"show": false}));
		EventRecorder.recordSueecssEvent("160854", null);
		this.pageHandler();
	}

	// FriendsModel.as:647-656
	private function onFriendFilterOpError(param1:CommandEvent):Void {
		var _loc2_:Dynamic = NetHelper.getVOData(param1);
		if (_loc2_ == null) {
			return;
		}
		this.alertWindow("error", Reflect.field(_loc2_, "direction"));
		EventRecorder.recordErrorEvent("160853", null, 4);
	}

	// FriendsModel.as:658-689
	private function pageHandler():Void {
		if (this.m_friendList == null) {
			return;
		}
		var _loc1_:Int = friendPageNum;
		var _loc2_:Int = (this._showFriendPage - 1) * _loc1_;
		var _loc3_:Int = this._showFriendPage * _loc1_;
		if (_loc3_ > this.m_friendList.length) {
			_loc3_ = this.m_friendList.length;
		}
		if (this.m_searchFriendValue != "") {
			this.m_showFriendList = this.filterFriendList.slice(_loc2_, _loc3_);
		} else {
			this.m_showFriendList = this.m_friendList.slice(_loc2_, _loc3_);
		}
		if (this.backTimeIsToday()) {
			this.cleanUserRecall(this.m_showFriendList);
		}
		dispatchEvent(new CommonEvent(EVENT_REFRESH_PAGE, {
			"index": this._showFriendPage,
			"total": this.showFriendSum,
			"friends": this.m_showFriendList
		}));
		this.updateHeadList();
	}

	// FriendsModel.as:691-708。极性是「表内保留」（闭包字节码已核对，
	// tools/DumpAbcMethod.hx；勿按直觉改）
	private function filterOut(param1:Array<Dynamic>):Array<Dynamic> {
		var filterFn:Friend->Bool = function(param1:Friend):Bool {
			// AS3 闭包签名 (item, index, array)，Haxe Array.filter 只传 item；
			// 后两个未用
			return As3.hasProp(this.m_friendListFilter, Std.string(param1._uin));
		};
		var data:Array<Dynamic> = param1;
		if (data == null || data.length == 0) {
			return data;
		}
		if (this.m_friendListFilter == null) {
			return data;
		}
		return data.filter(filterFn);
	}

	// FriendsModel.as:710-731
	private function backTimeIsToday():Bool {
		var _loc1_:Bool = false;
		// 原版遗留的调试 trace，照抄
		trace(Session.getInstance().host._uId);
		if (Cookies.getObject("setZhaohui_" + Session.getInstance().host._uId) == null) {
			return false;
		}
		var _loc2_:Date = Date.fromTime(CommonData.serverTime * 1000);
		// `cookie["time"] * 1000`：AS3 数字乘（缺位 NaN → Invalid Date，比较恒假），
		// As3.floatOf 复刻
		var _loc3_:Date = Date.fromTime(As3.floatOf(Reflect.field(Cookies.getObject("setZhaohui_" + Session.getInstance().host._uId), "time")) * 1000);
		if (_loc2_.getFullYear() == _loc3_.getFullYear()) {
			if (_loc2_.getMonth() == _loc3_.getMonth()) {
				if (_loc2_.getDate() == _loc3_.getDate()) {
					_loc1_ = true;
				}
			}
		}
		return _loc1_;
	}

	// FriendsModel.as:733-779
	private function copyStatus():Void {
		if (this.m_friendStatus == null) {
			return;
		}
		var _loc1_:Array<Dynamic> = null;
		if (this.m_friendListNet != null) {
			_loc1_ = this.m_friendListNet;
		} else if (this.m_friendList != null) {
			_loc1_ = this.m_friendList;
		} else if (this.m_friendListLocal != null) {
			_loc1_ = this.m_friendListLocal;
		}
		var _loc2_:Int = _loc1_.length;
		var _loc3_:Settings = Settings.getInstance();
		var _loc4_:Bool = Settings.isQZoneUinMode;
		var _loc5_:Friend = null;
		var _loc6_:UInt = 0;
		var _loc7_:Int = 0;
		while (_loc7_ < _loc2_) {
			_loc5_ = _loc1_[_loc7_];
			if (_loc5_ != null) {
				_loc6_ = _loc5_._uId;
				if (_loc4_ == true) {
					_loc6_ = _loc5_._uin;
				}
				if (Reflect.hasField(this.m_friendStatus, Std.string(_loc6_))) {
					_loc5_.status = Reflect.field(this.m_friendStatus, Std.string(_loc6_));
				} else {
					_loc5_.status = null;
				}
			}
			_loc7_++;
		}
	}

	// FriendsModel.as:781-804
	private function onFriendStatusFailed(param1:CommandEvent):Void {
		var _loc2_:Dynamic = NetHelper.getVOData(param1);
		if (_loc2_ == null) {
			return;
		}
		this.m_gotFriendStatus = false;
		var _loc3_:String = Reflect.field(_loc2_, "direction") + "<br/><a href=\'event:reload\'><u><font color=\'#ff6600\'>" + Reflect.field(Language.L, "点击重试") + "</font></u></a>";
		dispatchEvent(new CommonEvent(EVENT_DATA_LOAD_FAILED, {"error": _loc3_}));
		if (this.m_friendListNet != null) {
			this.processFriendList(this.m_friendListNet);
		} else if (this.m_friendList != null) {
			this.processFriendList(this.m_friendList);
		} else if (this.m_friendListLocal != null) {
			this.processFriendList(this.m_friendListLocal);
		}
		EventRecorder.recordErrorEvent(EventRecorder.HF_GET_FRIENDLIST_STATUS, null, EventRecorder.FAULT_ERROR, "cgi_farm_getstatus_filter");
	}

	// FriendsModel.as:806-811
	public function goLastPage(param1:String = ""):Void {
		this.m_searchFriendValue = param1;
		this._showFriendPage = this.showFriendSum;
		this.pageHandler();
	}

	// FriendsModel.as:813-828
	public var showFriendSum(get, never):Int;

	private function get_showFriendSum():Int {
		var _loc1_:Int = 1;
		if (this.m_friendList != null) {
			if (this.m_searchFriendValue == "") {
				_loc1_ = Math.ceil(this.m_friendList.length / friendPageNum);
			} else {
				_loc1_ = Math.ceil(this.filterFriendList.length / friendPageNum);
			}
		}
		return _loc1_ == 0 ? 1 : _loc1_;
	}

	// FriendsModel.as:830-842
	private function onFriendsFilterSuccess(param1:CommandEvent):Void {
		var _loc2_:Dynamic = NetHelper.getVOData(param1);
		if (_loc2_ == null) {
			return;
		}
		var _loc3_:Float = CommonData.serverTime + 5 * 60;
		var _loc4_:String = Session.getInstance().hostId;
		var _loc5_:String = Settings.getInstance().mode;
		Cookies.setObject(_loc5_ + _loc4_ + "Filter", _loc2_, _loc3_, true);
		this.m_friendListFilter = _loc2_;
	}

	// FriendsModel.as:844-862
	public function getFriendByFiD(param1:UInt):Friend {
		var _loc2_:Friend = null;
		// PORT-NOTE: AS3 for-each 对 null 零迭代，判空保持同语义
		if (this.m_friendList != null) {
			for (_e in this.m_friendList) {
				_loc2_ = _e;
				if (param1 == _loc2_._fid) {
					return _loc2_;
				}
			}
		}
		if (this.m_friendListLocal != null) {
			for (_e2 in this.m_friendListLocal) {
				_loc2_ = _e2;
				if (param1 == _loc2_._fid) {
					return _loc2_;
				}
			}
		}
		return null;
	}

	// FriendsModel.as:864-908
	public function updatePoolStatus(param1:UInt, param2:UInt, param3:Bool, param4:Bool):Void {
		var _loc6_:Dynamic = null;
		if (this.m_friendStatus == null) {
			return;
		}
		var _loc5_:Bool = false;
		var _loc7_:String = Std.string(param1);
		if (this.m_gotFriendStatus == false) {
			_loc5_ = true;
			if (As3.hasProp(this.m_friendStatus, _loc7_) == false || Reflect.field(this.m_friendStatus, _loc7_) == null) {
				Reflect.setField(this.m_friendStatus, _loc7_, {"6": param3});
			} else {
				Reflect.setField(Reflect.field(this.m_friendStatus, _loc7_), "6", param3);
			}
		} else {
			_loc6_ = Reflect.field(this.m_friendStatus, _loc7_);
			if (_loc6_ != null) {
				// PORT-NOTE: 原版 `!=` 宽松比较（"6" 的 int 1 与参数 true 判等），
				// Haxe Dynamic != 是严格比较，floatOf 复刻 AS3 的 Number 化比较
				if (As3.floatOf(Reflect.field(_loc6_, "6")) != As3.floatOf(param3)) {
					_loc5_ = true;
				}
				Reflect.setField(_loc6_, "6", param3);
			} else {
				_loc5_ = true;
				Reflect.setField(this.m_friendStatus, _loc7_, {"6": param3});
			}
		}
		if (param4 == true && _loc5_ == true) {
			NetHelper.sendRequest(CommandDefs.CMD_OPERATE_CHECKSTATUS, {
				"ownerId": param2,
				"fish": 1
			}, null, null);
		}
	}

	// FriendsModel.as:910-1008
	private function processFriendList(param1:Array<Dynamic>):Void {
		var _loc11_:String = null;
		if (param1 == null) {
			return;
		}
		dispatchEvent(new CommonEvent(EVENT_DATA_LOADING, {"show": false}));
		// PORT-NOTE: 同 sortBy 的 Std.int 包装（friendSort 返回 Number）
		param1.sort(function(_a:Dynamic, _b:Dynamic):Int {
			return Std.int(this.friendSort(_a, _b));
		});
		param1 = this.filterOut(param1);
		var _loc2_:Bool = false;
		var _loc3_:Dynamic = Cookies.getObject("nameMap", 1);
		if (_loc3_ == null) {
			_loc3_ = {};
			_loc2_ = true;
		}
		if (this.m_friendListMap == null) {
			this.m_friendListMap = {};
		}
		var _loc4_:Int = param1.length;
		var _loc5_:Player = Session.getInstance().host;
		var _loc6_:Settings = Settings.getInstance();
		var _loc7_:Bool = Settings.isQZoneUinMode;
		var _loc8_:Friend = null;
		var _loc9_:UInt = 0;
		var _loc10_:Int = 0;
		while (_loc10_ < _loc4_) {
			_loc8_ = param1[_loc10_];
			_loc8_.sort = _loc10_ + 1;
			_loc9_ = _loc8_._uId;
			if (_loc7_ == true) {
				_loc9_ = _loc8_._uin;
			}
			if (this.m_friendStatus != null) {
				if (Reflect.hasField(this.m_friendStatus, Std.string(_loc9_))) {
					_loc8_.status = Reflect.field(this.m_friendStatus, Std.string(_loc9_));
				} else {
					_loc8_.status = null;
				}
			}
			if (_loc8_._uId == _loc5_._uId) {
				_loc8_.me = true;
				_loc8_._exp = _loc5_._exp;
				_loc8_._money = _loc5_._money;
			} else {
				_loc8_.me = false;
			}
			_loc11_ = _loc8_._userName;
			if (_loc11_ != "") {
				if (!As3.truthy(Reflect.field(_loc3_, Std.string(_loc9_)))) {
					Reflect.setField(_loc3_, Std.string(_loc9_), {});
				}
				if (_loc6_.mode == "qzone") {
					Reflect.setField(Reflect.field(_loc3_, Std.string(_loc9_)), "qz", _loc11_);
				} else {
					Reflect.setField(Reflect.field(_loc3_, Std.string(_loc9_)), "xy", _loc11_);
				}
			} else if (As3.truthy(Reflect.field(_loc3_, Std.string(_loc9_)))) {
				if (_loc6_.mode == "qzone") {
					_loc11_ = Reflect.field(Reflect.field(_loc3_, Std.string(_loc9_)), "qz");
				} else {
					_loc11_ = Reflect.field(Reflect.field(_loc3_, Std.string(_loc9_)), "xy");
				}
				if (As3.truthy(_loc11_)) {
					_loc8_._userName = _loc11_;
				}
			}
			Reflect.setField(this.m_friendListMap, Std.string(_loc9_), _loc8_);
			_loc10_++;
		}
		this.m_friendList = param1;
		if (_loc2_ == true) {
			Cookies.setObject("nameMap", _loc3_, 1);
		}
		this.pageHandler();
	}

	// FriendsModel.as:1010-1029
	private function onAddFriendFilterSuccess(param1:CommandEvent):Void {
		var _loc3_:Dynamic = null;
		var _loc2_:Dynamic = NetHelper.getVOData(param1);
		if (_loc2_ == null) {
			return;
		}
		// `code == "1"`（字符串字面量）：As3.eqString 复刻宽松 ==
		if (As3.eqString(Reflect.field(_loc2_, "code"), "1")) {
			this.alertWindow("success", Reflect.field(_loc2_, "direction"));
			if (As3.hasProp(_loc2_, "uId") == true) {
				_loc3_ = Reflect.field(_loc2_, "uId");
				// :1024 对过滤表裸写，原版即要求表已存在（null 上 AS3 抛
				// TypeError，真实链路先经 cmd42 装载），照抄不设防
				Reflect.setField(this.m_friendListFilter, Std.string(_loc3_), 1);
				this.processFriendList(this.m_friendList);
			}
		}
		EventRecorder.recordSueecssEvent("160853", null);
	}

	// FriendsModel.as:1031-1059
	private function onFriendsDataFailed(param1:CommandEvent):Void {
		var _loc3_:String = null;
		var _loc4_:Int = 0;
		var _loc5_:String = null;
		var _loc2_:Dynamic = NetHelper.getVOData(param1);
		if (_loc2_ == null) {
			return;
		}
		dispatchEvent(new CommonEvent(EVENT_DATA_LOADING, {"show": false}));
		if (this.loadFriendsDataFromCache(null) == true) {
			this.processFriendList(this.m_friendListLocal);
			return;
		}
		if (As3.hasProp(_loc2_, "errorType") == true) {
			_loc3_ = Reflect.field(_loc2_, "errorType");
			if (_loc3_ == "IOError" || _loc3_ == "httpStatus" || _loc3_ == "timeOut" || _loc3_ == "PHPError") {
				_loc4_ = As3.getTimer() - this.m_requestStartTime;
				EventRecorder.recordErrorEvent("18169", _loc4_, EventRecorder.FAULT_ERROR, "mod=friend");
				_loc5_ = Reflect.field(Language.L, "请求超时，") + "<a href=\'event:reload\'><u><font color=\'#ff6600\'>" + Reflect.field(Language.L, "点击重试") + "</font></u></a>";
				dispatchEvent(new CommonEvent(EVENT_DATA_LOAD_FAILED, {"error": _loc5_}));
			}
		}
		EventRecorder.recordErrorEvent(EventRecorder.HF_GET_FRIENDLIST, null, EventRecorder.FAULT_ERROR, "mod=friend");
	}

	// FriendsModel.as:1061-1065（param1 签名照抄，原版未使用）
	public function goFirstPage(param1:String = ""):Void {
		this._showFriendPage = 1;
		this.pageHandler();
	}

	// FriendsModel.as:1067-1099
	private function loadFriendsDataFromCache(param1:Array<Dynamic>):Bool {
		var _loc4_:Dynamic = null;
		var _loc5_:String = null;
		var _loc6_:String = null;
		if (QzoneJSAPI.WB == true) {
			return false;
		}
		var _loc2_:Array<Dynamic> = param1;
		if (_loc2_ == null) {
			_loc5_ = Session.getInstance().hostId;
			_loc6_ = Settings.getInstance().mode;
			_loc2_ = Cookies.getObject(_loc6_ + _loc5_, CommonData.serverTime);
		}
		if (_loc2_ != null) {
			this.m_friendListLocal = [];
		}
		var _loc3_:Friend = null;
		// PORT-NOTE: AS3 for-each 对 null 零迭代，判空保持同语义
		if (_loc2_ != null) {
			for (_e in _loc2_) {
				_loc4_ = _e;
				_loc3_ = new Friend(null);
				_loc3_.importFromCache(_loc4_);
				if (_loc3_.me == true) {
					_loc3_._userName = Session.getInstance().host._userName;
				}
				this.m_friendListLocal.push(_loc3_);
			}
		}
		return this.m_friendListLocal != null && this.m_friendListLocal.length > 0 ? true : false;
	}

	// FriendsModel.as:1101-1121
	public function updateLandsStatus2(param1:UInt, param2:Float):Void {
		if (param1 == 0 || this.m_friendStatus == null) {
			return;
		}
		var _loc3_:Dynamic = Reflect.field(this.m_friendStatus, Std.string(param1));
		var _loc4_:Bool = false;
		if (_loc3_ != null) {
			if (param2 == 0) {
				Cookies.setObject("u_" + param1, Reflect.field(_loc3_, "4"));
			} else {
				Cookies.setObject("u_" + param1, param2);
			}
			Reflect.deleteField(_loc3_, "4");
		}
	}

	// FriendsModel.as:1123-1150
	public function updateBackStatus(param1:UInt, param2:Float):Void {
		if (param1 == 0 || this.m_friendStatus == null) {
			return;
		}
		var _loc3_:Dynamic = Reflect.field(this.m_friendStatus, Std.string(param1));
		var _loc4_:Bool = false;
		if (_loc3_ != null) {
			if (param2 == 0) {
				Cookies.setObject("z_" + param1, {
					"status": Reflect.field(_loc3_, "5"),
					"time": CommonData.serverTime
				});
			} else {
				Cookies.setObject("z_" + param1, {
					"status": Reflect.field(_loc3_, "5"),
					"time": param2
				});
			}
			// 原版先置 0 再删键，两步都照抄
			Reflect.setField(_loc3_, "5", 0);
			Reflect.deleteField(_loc3_, "5");
		}
	}

	// FriendsModel.as:1152-1167
	private function friendSort(param1:Friend, param2:Friend):Float {
		if (param1 == null || param2 == null) {
			return 0;
		}
		if (this.m_sortField == "exp") {
			return param1._exp > param2._exp ? -1 : 1;
		}
		if (this.m_sortField == "money") {
			return param1._money > param2._money ? -1 : 1;
		}
		return 0;
	}

	// FriendsModel.as:1169-1184。for-in 数组得字符串下标；本表来自 slice 恒稠密，
	// 按 0..length-1 等价；AS3 for-in(null) 零迭代 → 判空
	public function cleanUserRecall(param1:Array<Dynamic>):Void {
		var _loc3_:String = null;
		var _loc2_:Dynamic = null;
		if (param1 == null) {
			return;
		}
		var _loc4_:Int = 0;
		while (_loc4_ < param1.length) {
			_loc3_ = Std.string(_loc4_);
			var _loc5_:Dynamic = param1[_loc4_];
			if (As3.hasProp(_loc5_, "status")) {
				_loc2_ = Reflect.field(_loc5_, "status");
				if (_loc2_ != null) {
					Reflect.deleteField(_loc2_, "5");
				}
			}
			_loc4_++;
		}
	}

	// FriendsModel.as:1186-1200
	public function searchFriend(param1:String = ""):Void {
		if (param1 != "") {
			this.m_searchFriendValue = param1;
			if (this._showFriendPage > this.showFriendSum) {
				this._showFriendPage = 1;
				this.pageHandler();
				return;
			}
		}
		this.m_searchFriendValue = param1;
		this.pageHandler();
	}

	// FriendsModel.as:1202-1214
	private function hasMe(param1:Array<Dynamic>):Bool {
		var _loc3_:Friend = null;
		var _loc2_:UInt = Session.getInstance().host._uId;
		// PORT-NOTE: AS3 for-each 对 null 零迭代，判空保持同语义
		if (param1 != null) {
			for (_e in param1) {
				_loc3_ = _e;
				if (_loc3_._uId == _loc2_ || _loc3_._userId == _loc2_) {
					return true;
				}
			}
		}
		return false;
	}

	// FriendsModel.as:1216-1220
	private function onRefreshStatusFailed(param1:CommandEvent):Void {
		dispatchEvent(new CommonEvent(EVENT_DATA_LOADING, {"show": false}));
		EventRecorder.recordErrorEvent("160854", null, 4);
	}

	// FriendsModel.as:1222-1232
	private function alertWindow(param1:String, param2:String):Void {
		if (param1 == "" || param2 == "") {
			return;
		}
		dispatchEvent(new CommonEvent(EVENT_ALERT_WINDOW, {
			"type": param1,
			"text": param2
		}));
	}

	// FriendsModel.as:1234-1245
	public function getFriendByID(param1:UInt):Friend {
		var _loc2_:Friend = null;
		// PORT-NOTE: AS3 for-each 对 null 零迭代，判空保持同语义
		if (this.m_friendList != null) {
			for (_e in this.m_friendList) {
				_loc2_ = _e;
				if (param1 == _loc2_._uin) {
					return _loc2_;
				}
			}
		}
		return null;
	}

	// FriendsModel.as:1247-1250
	public var friendListLocal(get, never):Array<Dynamic>;

	private function get_friendListLocal():Array<Dynamic> {
		return this.m_friendListLocal;
	}

	// FriendsModel.as:1252-1271
	private function onRemoveFriendFilterSuccess(param1:CommandEvent):Void {
		var _loc3_:Dynamic = null;
		var _loc2_:Dynamic = NetHelper.getVOData(param1);
		if (_loc2_ == null) {
			return;
		}
		// `code == 1`（int 字面量，与 add 的 "1" 字面量不对称，照抄）；
		// eqString 的 Number 化比较两侧等价 AS3 宽松 ==
		if (As3.eqString(Reflect.field(_loc2_, "code"), "1")) {
			this.alertWindow("success", Reflect.field(_loc2_, "direction"));
			if (As3.hasProp(_loc2_, "uId") == true) {
				_loc3_ = Reflect.field(_loc2_, "uId");
				Reflect.deleteField(this.m_friendListFilter, Std.string(_loc3_));
				this.processFriendList(this.m_friendList);
			}
		}
		EventRecorder.recordSueecssEvent("160853", null);
	}

	// FriendsModel.as:1273-1373（"1"偷取时间/"2"除草/"3"除虫的本地推进；
	// :1344-1348/:1364-1368 的 else-if 在主分支删键后不可达，死代码照抄）
	public function updateLandsStatus(param1:UInt, param2:UInt, param3:Bool, param4:Bool, param5:Bool, param6:Bool):Void {
		var _loc9_:Bool = false;
		var _loc10_:Bool = false;
		if (param1 == 0 || this.m_friendStatus == null) {
			return;
		}
		var _loc7_:Dynamic = Reflect.field(this.m_friendStatus, Std.string(param1));
		var _loc8_:Bool = false;
		if (_loc7_ != null) {
			var _loc11_:Dynamic = Reflect.field(_loc7_, "1");
			if (param5 == false) {
				if (Std.isOfType(_loc11_, Int) && _loc11_ <= CommonData.serverTime) {
					_loc8_ = true;
					// `_loc7_["1"] != cookie`：两侧 Dynamic，严格 != 与 AS3 宽松
					// （值形态 int/时间戳）等价
					if (_loc11_ != Cookies.getObject("t_" + param1)) {
						Cookies.setObject("t_" + param1, _loc11_);
					}
					Reflect.deleteField(_loc7_, "1");
				}
			} else {
				if (Std.isOfType(_loc11_, Int) && _loc11_ > CommonData.serverTime) {
					_loc8_ = false;
				}
				Reflect.setField(_loc7_, "1", true);
			}
			// PORT-NOTE: `["2"] == 1 || ["2"] == true` 的宽松析取等价
			// Number(v) == 1（true→1、undefined→NaN 均各归其位），floatOf 复刻
			_loc9_ = As3.floatOf(Reflect.field(_loc7_, "2")) == 1;
			_loc10_ = As3.floatOf(Reflect.field(_loc7_, "3")) == 1;
			if (param3 != _loc9_ || param4 != _loc10_) {
				_loc8_ = true;
			}
			if (param3 == false) {
				Reflect.deleteField(_loc7_, "2");
			} else {
				Reflect.setField(_loc7_, "2", true);
			}
			if (param4 == false) {
				Reflect.deleteField(_loc7_, "3");
			} else {
				Reflect.setField(_loc7_, "3", true);
			}
			EventRecorder.recordSueecssEvent("160845", null);
		}
		if (param3 == true) {
			if (this.m_gotFriendStatus == true && (_loc7_ == null || !As3.truthy(Reflect.field(_loc7_, "2")))) {
				if (As3.truthy(Reflect.field(this.m_friendStatus, Std.string(param1)))) {
					Reflect.setField(Reflect.field(this.m_friendStatus, Std.string(param1)), "2", true);
				} else {
					Reflect.setField(this.m_friendStatus, Std.string(param1), {"2": true});
				}
				_loc8_ = true;
			}
		} else if (this.m_gotFriendStatus == true && _loc7_ != null && As3.floatOf(Reflect.field(_loc7_, "2")) == 1) {
			Reflect.setField(_loc7_, "2", false);
			_loc8_ = true;
		}
		if (param4 == true) {
			if (this.m_gotFriendStatus == true && (_loc7_ == null || !As3.truthy(Reflect.field(_loc7_, "3")))) {
				if (As3.truthy(Reflect.field(this.m_friendStatus, Std.string(param1)))) {
					Reflect.setField(Reflect.field(this.m_friendStatus, Std.string(param1)), "3", true);
				} else {
					Reflect.setField(this.m_friendStatus, Std.string(param1), {"3": true});
				}
				_loc8_ = true;
			}
		} else if (this.m_gotFriendStatus == true && _loc7_ != null && As3.floatOf(Reflect.field(_loc7_, "3")) == 1) {
			Reflect.setField(_loc7_, "3", false);
			_loc8_ = true;
		}
		if (param6 == true && _loc8_ == true) {
			NetHelper.sendRequest(CommandDefs.CMD_OPERATE_CHECKSTATUS, {"ownerId": param2}, null, null);
		}
	}

	// FriendsModel.as:1375-1438
	public var filterFriendList(get, never):Array<Dynamic>;

	private function get_filterFriendList():Array<Dynamic> {
		var arr:Array<Dynamic> = null;
		var arr2:Array<Dynamic> = null;
		var f2:Friend = null;
		var exist:Bool = false;
		var f:Friend = null;
		var showStatusOnly:Void->Array<Dynamic> = function():Array<Dynamic> {
			var _loc2_:String = null;
			var _loc1_:Array<Dynamic> = [];
			// PORT-NOTE: AS3 for-in 对 null 零迭代，判空保持同语义
			if (this.m_friendStatus != null) {
				for (_k in Reflect.fields(this.m_friendStatus)) {
					_loc2_ = _k;
					_loc1_.push(Reflect.field(this.m_friendListMap, _loc2_));
				}
			}
			return _loc1_;
		};
		var friendFilter:Friend->Bool = function(param1:Friend):Bool {
			if (param1 == null) {
				return false;
			}
			// RegExp → EReg；RegExp.test(null) 在 AS3 里是测 "null" 串，
			// Std.string 同型；EReg 的 test 对应方法是 match
			var _loc4_:String = param1._userName;
			return new EReg(".*?" + this.m_searchFriendValue + ".*", "i").match(Std.string(_loc4_));
		};
		var friendFilterByUin:Friend->Bool = function(param1:Friend):Bool {
			if (param1 == null) {
				return false;
			}
			var _loc4_:String = Std.string(param1._uin);
			return new EReg(".*?" + this.m_searchFriendValue + ".*", "i").match(_loc4_);
		};
		if (this.m_searchFriendValue == "45623371" || this.m_searchFriendValue == "82822239") {
			return showStatusOnly();
		}
		arr = this.m_friendList.filter(friendFilter);
		if (Settings.getInstance().mode == "qzone") {
			arr2 = this.m_friendList.filter(friendFilterByUin);
			for (_e in arr2) {
				f2 = _e;
				exist = false;
				for (_e2 in arr) {
					f = _e2;
					if (f2._uin == f._uin) {
						exist = true;
						break;
					}
				}
				if (exist == false) {
					arr.push(f2);
				}
			}
		}
		return arr;
	}

	// FriendsModel.as:1440-1443
	public function addFriendFilter(param1:Int):Void {
		NetHelper.sendRequest(CommandDefs.CMD_ADD_FRIEND_FILTER, {"uId": param1}, this.onAddFriendFilterSuccess, this.onFriendFilterOpError);
	}

	// FriendsModel.as:1445-1466
	private function openByFlashVar():Bool {
		var _loc2_:Float = 0;
		var _loc1_:String = Settings.getInstance().getStringAttribute("useflag");
		if (Settings.getInstance().mode == "qzone") {
			_loc2_ = As3.parseInt(_loc1_) % 10;
		} else {
			_loc2_ = As3.parseInt(_loc1_) / 10 % 10;
		}
		if (!As3.truthy(_loc2_)) {
			dispatchEvent(new CommonEvent(EVENT_FUNCTION_FORBIDDEN, {
				"type": Consts.ALERT_TYPE_TIP,
				"text": Settings.getInstance().getStringAttribute("friend_list_tips_2")
			}));
			return true;
		}
		return false;
	}

	// FriendsModel.as:1468-1480
	private function forbidden():Bool {
		var _loc1_:Dynamic = FeartureManager.friendListMod();
		// PORT-NOTE: 原版 `!= false` 是宽松比较（空串文案按 Number("")==0
		// 与 false 判等、即不禁止），Haxe Dynamic != 严格，floatOf 复刻
		if (As3.floatOf(_loc1_) != 0) {
			dispatchEvent(new CommonEvent(EVENT_FUNCTION_FORBIDDEN, {
				"type": Consts.ALERT_TYPE_TIP,
				"text": _loc1_
			}));
			return true;
		}
		return false;
	}

	// FriendsModel.as:1482-1485
	public var friendListFilter(get, never):Dynamic;

	private function get_friendListFilter():Dynamic {
		return this.m_friendListFilter;
	}
}
