package module.messages;

import com.qzone.qfa.events.CommandEvent;
import common.Language;
import common.Session;
import common.Settings;
import entities.Player;
import events.CommonEvent;
import framework.net.CommandDefs;
import framework.net.NetHelper;
import openfl.events.EventDispatcher;
import report.EventRecorder;
import shim.As3;

/**
 * module.messages.MessageModel —— MessageModel.as 逐句对应（issue #19）。
 * 个人信息窗六页签（消息/留言/成果/成鱼/消费/系统）的数据源：chat&
 * act=getAllInfo 按旗标取页、hydra feeds 日志、sysmsg 系统公告、双源消费
 * 流水合并、留言收发与清空。
 *
 * PORT-NOTE: for-in over Object → Reflect.fields；m_data["k"] →
 * Reflect.field/setField；`["k"] != undefined` 门按 lessons 配
 * hasField+非 null 双查；sortOn 无 Haxe 等价 → As3.sortOnDesc。
 */
class MessageModel extends EventDispatcher {
	// MessageModel.as:17
	public static final EVENT_DATA_CHANGED:String = "DataChanged";

	// MessageModel.as:19
	public static final EVENT_DATA_LOADING:String = "DataLoading";

	// MessageModel.as:21
	public static final EVENT_DATA_FAILED:String = "DataFailed";

	// MessageModel.as:23（常量声明后本类从未派发它——照抄不修）
	public static final EVENT_LOG_CLEARED:String = "LogCleared";

	// MessageModel.as:25
	private var m_flags:Array<Dynamic> = [2, 4, 8];

	// MessageModel.as:27
	private var m_costNM:Bool;

	// MessageModel.as:29
	private var m_me:Bool;

	// MessageModel.as:31
	private var m_costWS:Bool;

	// MessageModel.as:33
	private var m_data:Dynamic;

	public function new() {
		super();
		this.m_data = {};
		this.m_me = true;
		this.m_costNM = false;
		this.m_costWS = false;
	}

	// MessageModel.as:44-56
	public function sendChat(param1:String, param2:String, param3:Int, param4:String, param5:String = ""):Void {
		var _loc6_:String = Session.getInstance().host._userName;
		var _loc7_:Dynamic = {
			"toId": param1,
			"msg": param4,
			"showId": param2,
			"isReply": param3,
			"tName": param5,
			"fName": _loc6_
		};
		NetHelper.sendRequest(CommandDefs.CMD_SEND_CHAT, _loc7_, this.onChatMsgSent, this.onChatMsgSentFail);
	}

	// MessageModel.as:58-61
	public function clearChat():Void {
		NetHelper.sendRequest(CommandDefs.CMD_CLEAR_ALL_CHAT, null, this.onChatCleared, this.onChatClearedFail);
	}

	// MessageModel.as:63-71
	private function onLogCleared(param1:CommandEvent):Void {
		Reflect.setField(this.m_data, "log", []);
		dispatchEvent(new CommonEvent(EVENT_DATA_CHANGED, {
			"index": "log",
			"data": this.m_data
		}));
		EventRecorder.recordSueecssEvent("160875", null);
	}

	// MessageModel.as:73-80
	public function reloadAll():Void {
		var _loc1_:Dynamic = {"uId": Session.getInstance().hostId};
		Reflect.setField(_loc1_, "ownerId", Reflect.field(_loc1_, "uId"));
		Reflect.setField(_loc1_, "flag", 16);
		dispatchEvent(new CommonEvent(EVENT_DATA_LOADING, true));
		NetHelper.sendRequest(CommandDefs.CMD_GET_PROFILE_ALL_INFO, _loc1_, this.onDataLoaded, this.onNetError);
	}

	// MessageModel.as:82-85
	private function onLogClearedFail(param1:CommandEvent):Void {
		EventRecorder.recordErrorEvent("160875", null, 4);
	}

	// MessageModel.as:87-209
	private function onDataLoaded(param1:CommandEvent):Void {
		var _loc4_:Dynamic;
		var _loc5_:String;
		var _loc6_:String;
		var _loc7_:Dynamic;
		var _loc8_:String;
		var _loc2_:Dynamic = NetHelper.getVOData(param1);
		if (_loc2_ == null) {
			return;
		}
		var _loc3_:Int = As3.intOf(Reflect.field(param1.body, "cmdID"));
		if (_loc3_ == CommandDefs.CMD_GET_BILL_DATA) {
			this.m_costNM = true;
			_loc4_ = {"uin": Session.getInstance().host._uinLogin};
			NetHelper.sendRequest(CommandDefs.CMD_GET_BILL_WS_DATA, _loc4_, this.onDataLoaded, this.onNetError);
			Reflect.setField(this.m_data, "cost", Reflect.field(_loc2_, "cost"));
			EventRecorder.recordSueecssEvent(EventRecorder.HF_GET_BILL_DATA, null, "cgi_farm_exchange");
		} else if (_loc3_ == CommandDefs.CMD_GET_BILL_WS_DATA) {
			this.m_costWS = true;
			if (!Reflect.hasField(this.m_data, "cost") || Reflect.field(this.m_data, "cost") == null) {
				Reflect.setField(this.m_data, "cost", Reflect.field(_loc2_, "cost"));
			} else if (Std.isOfType(Reflect.field(_loc2_, "cost"), Array)) {
				Reflect.setField(this.m_data, "cost", (Reflect.field(this.m_data, "cost"):Array<Dynamic>)
					.concat(Reflect.field(_loc2_, "cost")));
			}
			if (this.m_costNM == true && this.m_costWS == true) {
				if (Std.isOfType(Reflect.field(this.m_data, "cost"), Array)) {
					As3.sortOnDesc(Reflect.field(this.m_data, "cost"), "time");
				}
				dispatchEvent(new CommonEvent(EVENT_DATA_CHANGED, {
					"index": "cost",
					"data": this.m_data
				}));
			}
			EventRecorder.recordSueecssEvent("160878", null);
		} else if (_loc3_ == CommandDefs.CMD_GET_SYSTEM_MSG) {
			if (Reflect.field(_loc2_, "ret") == 0) {
				Reflect.setField(this.m_data, "systemMsg", Reflect.field(_loc2_, "data"));
			}
			dispatchEvent(new CommonEvent(EVENT_DATA_CHANGED, {
				"index": "systemMsg",
				"data": this.m_data
			}));
			EventRecorder.recordSueecssEvent(EventRecorder.HF_GET_SYSTEM_MSG, null, "sysmsg_select");
		} else if (_loc3_ == CommandDefs.CMD_GET_PROFILE_ALL_INFO
			&& As3.intOf(Reflect.field(Reflect.field(param1.body, "__body"), "flag")) == 3) {
			for (_loc5_ in Reflect.fields(_loc2_)) {
				if (_loc5_ != "log") {
					Reflect.setField(this.m_data, _loc5_, Reflect.field(_loc2_, _loc5_));
					if (_loc5_ == "user" && As3.hasProp(Reflect.field(_loc2_, _loc5_), "xystr")
						&& Settings.getInstance().mode == "") {
						Session.getInstance().currentUser.xystr = Reflect.field(Reflect.field(_loc2_, "user"), "xystr");
					}
				}
			}
			this.loadFeeds();
		} else if (_loc3_ == CommandDefs.CMD_GET_PROFILE_ALL_INFO
			&& As3.intOf(Reflect.field(Reflect.field(param1.body, "__body"), "flag")) == 1) {
			for (_loc6_ in Reflect.fields(_loc2_)) {
				Reflect.setField(this.m_data, _loc6_, Reflect.field(_loc2_, _loc6_));
				dispatchEvent(new CommonEvent(EVENT_DATA_CHANGED, {
					"index": _loc6_,
					"data": this.m_data
				}));
			}
			if (Reflect.hasField(this.m_data, "systemMsg") && Reflect.field(this.m_data, "systemMsg") != null) {
				return;
			}
			dispatchEvent(new CommonEvent(EVENT_DATA_LOADING, true));
			_loc7_ = {
				"uin": Session.getInstance().hostUin,
				"opuin": Session.getInstance().hostUin
			};
			Reflect.setField(_loc7_, "appid", "353");
			Reflect.setField(_loc7_, "msgnum", "300");
			NetHelper.sendRequest(CommandDefs.CMD_GET_SYSTEM_MSG, _loc7_, this.onDataLoaded, this.onNetError);
		} else if (_loc3_ == CommandDefs.CMD_GET_FISH_ALL) {
			if (Std.isOfType(Reflect.field(_loc2_, "repertory"), Array)) {
				Reflect.setField(this.m_data, "fish", Reflect.field(_loc2_, "repertory"));
			}
			dispatchEvent(new CommonEvent(EVENT_DATA_CHANGED, {
				"index": "fish",
				"data": this.m_data
			}));
			EventRecorder.recordSueecssEvent("160874", null);
		} else {
			for (_loc8_ in Reflect.fields(_loc2_)) {
				Reflect.setField(this.m_data, _loc8_, Reflect.field(_loc2_, _loc8_));
				if (_loc8_ == "user" && As3.hasProp(Reflect.field(_loc2_, _loc8_), "xystr")
					&& Settings.getInstance().mode == "") {
					Session.getInstance().currentUser.xystr = Reflect.field(Reflect.field(_loc2_, "user"), "xystr");
				}
				dispatchEvent(new CommonEvent(EVENT_DATA_CHANGED, {
					"index": _loc8_,
					"data": this.m_data
				}));
			}
		}
	}

	// MessageModel.as:211-230
	public function loadFeeds():Void {
		var _loc1_:Dynamic = null;
		if (this.m_me == true) {
			_loc1_ = Session.getInstance().host._uinLogin;
		} else {
			_loc1_ = As3.or(Session.getInstance().currentUser.uin, Session.getInstance().currentUser.xystr);
		}
		var _loc2_:Dynamic = {
			"appid": 353,
			"feedsnum": 50,
			"isfeeds": 1,
			"uin": _loc1_,
			"opuin": Session.getInstance().host._uinLogin
		};
		NetHelper.sendRequest(CommandDefs.CMD_GET_FEEDS, _loc2_, this.onLoadFeeds, this.onNetError);
	}

	// MessageModel.as:232-240
	public function clearAllLog():Void {
		var _loc1_:Dynamic = {
			"appid": 353,
			"isfeeds": 1,
			"uin": Session.getInstance().host._uinLogin
		};
		NetHelper.sendRequest(CommandDefs.CMD_CLEAR_ALL_FEEDS, _loc1_, this.onLogCleared, this.onLogClearedFail);
	}

	// MessageModel.as:242-245
	private function onChatClearedFail(param1:CommandEvent):Void {
		EventRecorder.recordErrorEvent("160876", null, 4);
	}

	// MessageModel.as:247-259
	private function onChatCleared(param1:CommandEvent):Void {
		var _loc2_:Dynamic = NetHelper.getVOData(param1);
		if (_loc2_ != null && Reflect.field(_loc2_, "code") == 1) {
			Reflect.setField(this.m_data, "chat", []);
			dispatchEvent(new CommonEvent(EVENT_DATA_CHANGED, {
				"index": "chat",
				"data": this.m_data
			}));
			EventRecorder.recordSueecssEvent("160876", null);
		}
	}

	// MessageModel.as:261-266
	public function reset():Void {
		this.m_data = {};
		this.m_costNM = false;
		this.m_costWS = false;
	}

	// MessageModel.as:268-271
	public var me(get, never):Bool;

	private function get_me():Bool {
		return this.m_me;
	}

	// MessageModel.as:273-276
	private function onChatMsgSentFail(param1:CommandEvent):Void {
		EventRecorder.recordErrorEvent("160877", null, 4);
	}

	// MessageModel.as:278-291
	private function onChatMsgSent(param1:CommandEvent):Void {
		var _loc2_:Dynamic = NetHelper.getVOData(param1);
		if (_loc2_ == null) {
			return;
		}
		Reflect.setField(this.m_data, "chat", Reflect.field(_loc2_, "chat"));
		dispatchEvent(new CommonEvent(EVENT_DATA_CHANGED, {
			"index": "chat",
			"data": this.m_data
		}));
		EventRecorder.recordSueecssEvent("160877", null);
	}

	// MessageModel.as:293-398
	public function loadData(param1:Int):Void {
		var _loc2_:Dynamic = null;
		if (param1 >= 0 && param1 < 3) {
			if (param1 == 0 && Reflect.hasField(this.m_data, "log") && Reflect.field(this.m_data, "log") != null) {
				return;
			}
			if (param1 == 1 && Reflect.hasField(this.m_data, "chat") && Reflect.field(this.m_data, "chat") != null) {
				return;
			}
			if (param1 == 2 && Reflect.hasField(this.m_data, "repertory")
				&& Reflect.field(this.m_data, "repertory") != null) {
				return;
			}
			if (this.m_me == true) {
				_loc2_ = {"uId": Session.getInstance().hostId};
			} else {
				_loc2_ = {"uId": Session.getInstance().currentUser._uId};
			}
			Reflect.setField(_loc2_, "ownerId", Reflect.field(_loc2_, "uId"));
			if (Reflect.hasField(this.m_data, "user") && Reflect.field(this.m_data, "user") != null) {
				Reflect.setField(_loc2_, "flag", this.m_flags[param1]);
			} else {
				Reflect.setField(_loc2_, "flag", this.m_flags[param1] + 1);
			}
			dispatchEvent(new CommonEvent(EVENT_DATA_LOADING, true));
			if (Reflect.field(_loc2_, "flag") == 2) {
				this.loadFeeds();
			} else {
				NetHelper.sendRequest(CommandDefs.CMD_GET_PROFILE_ALL_INFO, _loc2_, this.onDataLoaded, this.onNetError);
			}
		} else if (param1 == 3) {
			if (Reflect.hasField(this.m_data, "fish") && Reflect.field(this.m_data, "fish") != null) {
				return;
			}
			if (this.m_me == true) {
				_loc2_ = {"uId": Session.getInstance().hostId};
			} else {
				_loc2_ = {"uId": Session.getInstance().currentUser._uId};
			}
			Reflect.setField(_loc2_, "ownerId", Reflect.field(_loc2_, "uId"));
			dispatchEvent(new CommonEvent(EVENT_DATA_LOADING, true));
			NetHelper.sendRequest(CommandDefs.CMD_GET_FISH_ALL, _loc2_, this.onDataLoaded, this.onNetError);
		} else if (param1 == 4) {
			if (Reflect.hasField(this.m_data, "cost") && Reflect.field(this.m_data, "cost") != null) {
				return;
			}
			dispatchEvent(new CommonEvent(EVENT_DATA_LOADING, true));
			this.m_costNM = false;
			this.m_costWS = false;
			NetHelper.sendRequest(CommandDefs.CMD_GET_BILL_DATA, _loc2_, this.onDataLoaded, this.onNetError);
		} else if (param1 == 5) {
			if (!(Reflect.hasField(this.m_data, "user") && Reflect.field(this.m_data, "user") != null)) {
				if (this.m_me == true) {
					_loc2_ = {"uId": Session.getInstance().hostId};
				} else {
					_loc2_ = {"uId": Session.getInstance().currentUser._uId};
				}
				Reflect.setField(_loc2_, "ownerId", Reflect.field(_loc2_, "uId"));
				Reflect.setField(_loc2_, "flag", 1);
				NetHelper.sendRequest(CommandDefs.CMD_GET_PROFILE_ALL_INFO, _loc2_, this.onDataLoaded, this.onNetError);
			} else {
				if (Reflect.hasField(this.m_data, "systemMsg")
					&& Reflect.field(this.m_data, "systemMsg") != null) {
					return;
				}
				dispatchEvent(new CommonEvent(EVENT_DATA_LOADING, true));
				_loc2_ = {
					"uin": Session.getInstance().hostUin,
					"opuin": Session.getInstance().hostUin
				};
				Reflect.setField(_loc2_, "appid", "353");
				Reflect.setField(_loc2_, "msgnum", "300");
				NetHelper.sendRequest(CommandDefs.CMD_GET_SYSTEM_MSG, _loc2_, this.onDataLoaded, this.onNetError);
			}
		}
	}

	// MessageModel.as:400-410
	public var currentPlayer(never, set):Player;

	private function set_currentPlayer(param1:Player):Player {
		if (param1 == null || param1.me == true) {
			this.m_me = true;
		} else {
			this.m_me = false;
		}
		return param1;
	}

	// MessageModel.as:412-423
	private function onBillDataLoaded(param1:CommandEvent):Void {
		var _loc2_:Dynamic = NetHelper.getVOData(param1);
		if (_loc2_ != null && Reflect.hasField(_loc2_, "cost") && Reflect.field(_loc2_, "cost") != null) {
			Reflect.setField(this.m_data, "cost", Reflect.field(_loc2_, "cost"));
			dispatchEvent(new CommonEvent(EVENT_DATA_CHANGED, {
				"index": "cost",
				"data": this.m_data
			}));
		}
	}

	// MessageModel.as:425-449
	private function onLoadFeeds(param1:CommandEvent):Void {
		var _loc3_:String;
		var _loc2_:Dynamic = NetHelper.getVOData(param1);
		if (_loc2_ == null) {
			return;
		}
		if (Reflect.field(_loc2_, "ecode") == 0) {
			Reflect.setField(this.m_data, "log", Reflect.field(_loc2_, "data"));
			for (_loc3_ in Reflect.fields(this.m_data)) {
				dispatchEvent(new CommonEvent(EVENT_DATA_CHANGED, {
					"index": _loc3_,
					"data": this.m_data
				}));
			}
			EventRecorder.recordSueecssEvent(EventRecorder.HF_GET_FEEDS, null, "feeds_select");
		} else if (Reflect.hasField(_loc2_, "errmsg") && Reflect.field(_loc2_, "errmsg") != null) {
			dispatchEvent(new CommonEvent(EVENT_DATA_FAILED, {"error": Reflect.field(_loc2_, "errmsg")}));
		}
	}

	// MessageModel.as:451-478
	private function onNetError(param1:CommandEvent):Void {
		var _loc2_:String = Reflect.field(Language.L, "请求超时，") + "<a href=\'event:reload\'><u><font color=\'#ff6600\'>"
			+ Reflect.field(Language.L, "点击重试") + "</font></u></a>";
		dispatchEvent(new CommonEvent(EVENT_DATA_FAILED, {"error": _loc2_}));
		if (param1.body != null && Reflect.hasField(param1.body, "cmdID") && Reflect.field(param1.body, "cmdID") != null) {
			if (As3.intOf(Reflect.field(param1.body, "cmdID")) == CommandDefs.CMD_GET_SYSTEM_MSG) {
				EventRecorder.recordErrorEvent(EventRecorder.HF_GET_SYSTEM_MSG, null, EventRecorder.FAULT_ERROR,
					"sysmsg_select");
			} else if (As3.intOf(Reflect.field(param1.body, "cmdID")) == CommandDefs.CMD_GET_FEEDS) {
				EventRecorder.recordErrorEvent(EventRecorder.HF_GET_FEEDS, null, EventRecorder.FAULT_ERROR,
					"feeds_select");
			} else if (As3.intOf(Reflect.field(param1.body, "cmdID")) == CommandDefs.CMD_GET_BILL_DATA) {
				EventRecorder.recordErrorEvent(EventRecorder.HF_GET_BILL_DATA, null, EventRecorder.FAULT_ERROR,
					"cgi_farm_exchange");
			} else if (As3.intOf(Reflect.field(param1.body, "cmdID")) == CommandDefs.CMD_GET_FISH_ALL) {
				EventRecorder.recordErrorEvent("160874", null, 4);
			} else if (As3.intOf(Reflect.field(param1.body, "cmdID")) == CommandDefs.CMD_GET_BILL_WS_DATA) {
				EventRecorder.recordErrorEvent("160878", null, 4);
			}
		}
	}
}
