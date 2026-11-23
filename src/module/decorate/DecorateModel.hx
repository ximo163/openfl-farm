package module.decorate;

import com.qzone.qfa.events.CommandEvent;
import common.Consts;
import common.Language;
import common.Session;
import common.Settings;
import entities.DecorateItem;
import events.CommonEvent;
import framework.net.CommandDefs;
import framework.net.NetHelper;
import openfl.events.EventDispatcher;
import openfl.events.IEventDispatcher;
import openfl.utils.Dictionary;
import report.EventRecorder;
import shim.As3;

/**
 * module.decorate.DecorateModel —— DecorateModel.as 逐句对应（issue #38
 * 功能 swf 翻译：DIY 装饰）。装饰/告示牌两页签的数据状态：装载（mod=
 * item&act=getUserItems，CMD_GET_DIY_ITEMS 38，DecorateItemsParser 把
 * current 拆组 0、items 拆组 1）、启用/停用（item.activeItem/deactiveItem，
 * CMD_ACTIVE_DECORATE 86 / CMD_DEACTIVE_DECORATE 87，按 status 分流）、
 * 告示牌列表（Settings.getBillBoardData 的 boards 配置倒序）、
 * myBoardID/myDogID 槽位回填（setMyDecorate 读 Session.sceneDecorates，
 * 狗 id = DECOR_DOG_BASE_ID 80000 + itemId）。
 *
 * PORT-NOTE: ① 回包 `code == "1"` 是 AS3 松等（协议 code 为 int）→
 * As3.eqString；`as int` → As3.intOf。② for-in/for-each 遍历可能为 null 的
 * Dictionary/组表时 AS3 零圈静默 → Haxe 判空跳过（可观察行为同：零迭代）。
 * ③ EventRecorder 已按 deviations（no-qq-telemetry）DISABLED，调用点照抄。
 * AS3 internal static const → private（CLAUDE.md 映射）；同包消费方
 * DecorateController/DecorateView 按 FriendsController 先例用 @:access 取。
 */
class DecorateModel extends EventDispatcher {
	// DecorateModel.as:20（AS3 internal static const → private，CLAUDE.md 映射）
	private static final EVENT_DATA_LOADING:String = "WarehouseDataLoading";

	// DecorateModel.as:22
	private static final EVENT_DATA_LOADED:String = "WarehouseDataLoaded";

	// DecorateModel.as:24
	private static final EVENT_DATA_FAILED:String = "WarehouseDataFailed";

	// DecorateModel.as:26
	private static final EVENT_DATA_CHANGED:String = "DataChanged";

	// DecorateModel.as:28
	private static final EVENT_DATA_STATUS_CHANGED:String = "DataStatusChanged";

	// DecorateModel.as:30
	private static final EVENT_OPERATE_FAILED:String = "OperateFailed";

	// DecorateModel.as:32
	private static final NOTIFY_REFRESH_MAINSCENE:String = "RefreshMainScene";

	// DecorateModel.as:34
	private var m_requesting:Bool;

	// DecorateModel.as:36
	private var m_dirty:Bool;

	// DecorateModel.as:38
	private var m_myDogID:Int;

	// DecorateModel.as:40
	private var m_myBoardID:Int;

	// DecorateModel.as:42
	private var m_boardArray:Array<Dynamic>;

	// DecorateModel.as:44
	private var m_loading:Bool;

	// DecorateModel.as:46（AS3 Dictionary → openfl.utils.Dictionary，
	// 键 0=当前装备组、1=拥有物组，见 DecorateItemsParser）
	private var m_decorGroup:Dictionary<Int, Array<Dynamic>>;

	// DecorateModel.as:48-59（ctor 尾 setMyDecorate 读 sceneDecorates 回填）
	public function new(param1:IEventDispatcher = null) {
		super(param1);
		this.m_decorGroup = null;
		this.m_dirty = true;
		this.m_boardArray = null;
		this.m_myBoardID = -1;
		this.m_myDogID = -1;
		this.m_loading = false;
		this.m_requesting = false;
		this.setMyDecorate(Session.getInstance().sceneDecorates);
	}

	// DecorateModel.as:61-103
	private function onDeSelectDecorateSuccess(param1:CommandEvent):Void {
		var _loc3_:Int = 0;
		var _loc4_:Int = 0;
		var _loc5_:Int = 0;
		var _loc6_:Array<Dynamic> = null;
		var _loc7_:DecorateItem = null;
		var _loc2_:Dynamic = NetHelper.getVOData(param1);
		if (_loc2_ == null) {
			return;
		}
		this.m_requesting = false;
		if (As3.eqString(Reflect.field(_loc2_, "code"), "1")) {
			_loc3_ = As3.intOf(Reflect.field(_loc2_, "id"));
			_loc4_ = As3.intOf(Reflect.field(Reflect.field(param1.body, "__body"), "type"));
			// for-in 遍历 null Dictionary 是 AS3 零圈 → 判空跳过
			if (this.m_decorGroup != null) {
				for (_loc5_ in this.m_decorGroup) {
					_loc6_ = this.m_decorGroup.get(_loc5_);
					// for-each 遍历 null 组是 AS3 零圈 → 判空跳过
					if (_loc6_ != null) {
						var _loc6List:Array<DecorateItem> = cast _loc6_;
						for (_loc7_ in _loc6List) {
							if (_loc7_._id == _loc3_ && _loc7_._type == _loc4_) {
								_loc7_._status = 0;
								break;
							}
						}
					}
				}
			}
			if (_loc4_ == Consts.DECOR_BACKGROUND) {
				this.setDefaultBackground();
			}
			dispatchEvent(new CommonEvent(EVENT_DATA_STATUS_CHANGED, {
				"type": _loc4_,
				"id": _loc3_
			}));
			dispatchEvent(new CommonEvent(NOTIFY_REFRESH_MAINSCENE, {
				"type": _loc4_,
				"id": -1
			}));
		}
	}

	// DecorateModel.as:105-141（set myBoardID；AS3 for-each 循环变量 _loc3_ 是
	// Dynamic → 外层声明 + for-in 值迭代）
	private function set_myBoardID(param1:Int):Int {
		var _loc3_:Dynamic = null;
		if (this.m_myBoardID == param1) {
			return param1;
		}
		var _loc2_:Int = this.m_myBoardID;
		this.m_myBoardID = param1;
		if (this.m_boardArray != null) {
			for (_loc3_ in this.m_boardArray) {
				if (this.m_myBoardID != -1) {
					if (As3.floatOf(Reflect.field(_loc3_, "id")) == this.m_myBoardID) {
						Reflect.setField(_loc3_, "status", 1);
					} else {
						Reflect.setField(_loc3_, "status", 0);
					}
				} else if (As3.floatOf(Reflect.field(_loc3_, "id")) == _loc2_) {
					Reflect.setField(_loc3_, "status", 0);
					break;
				}
			}
			dispatchEvent(new CommonEvent(EVENT_DATA_CHANGED, {
				"index": 1,
				"newItemId": this.m_myBoardID,
				"oldItemId": _loc2_
			}));
		}
		return param1;
	}

	// DecorateModel.as:105/:494-497（get/set myBoardID 声明处）
	public var myBoardID(get, set):Int;

	private function get_myBoardID():Int {
		return this.m_myBoardID;
	}

	// DecorateModel.as:143-146/:206-253（get/set myDogID 声明处）
	public var myDogID(get, set):Int;

	private function get_myDogID():Int {
		return this.m_myDogID;
	}

	// DecorateModel.as:148-169（for-in/for-each 的 null 零圈 → 判空跳过）
	private function setDefaultBackground():Void {
		var _loc1_:Int = 0;
		var _loc2_:DecorateItem = null;
		if (this.m_decorGroup == null) {
			return;
		}
		for (_loc1_ in this.m_decorGroup) {
			var _loc6_:Array<Dynamic> = this.m_decorGroup.get(_loc1_);
			if (_loc6_ == null) {
				continue;
			}
			var _loc6List:Array<DecorateItem> = cast _loc6_;
			for (_loc2_ in _loc6List) {
				if (_loc2_._type == Consts.DECOR_BACKGROUND) {
					if (_loc2_._id == -1) {
						_loc2_._status = 1;
					} else {
						_loc2_._status = 0;
					}
				}
			}
		}
	}

	// DecorateModel.as:171-174/:416-419（get/set dirty 声明处）
	public var dirty(get, set):Bool;

	private function get_dirty():Bool {
		return this.m_dirty;
	}

	private function set_dirty(param1:Bool):Bool {
		this.m_dirty = param1;
		return param1;
	}

	// DecorateModel.as:176-204
	public function loadBoards():Void {
		var _loc4_:Dynamic = null;
		if (this.m_boardArray != null) {
			return;
		}
		this.m_boardArray = Settings.getInstance().getBillBoardData();
		// AS3 Array.reverse() 返回自身，Haxe 返回 Void → 原地翻转即可（语义同）
		this.m_boardArray.reverse();
		var _loc1_:Dynamic = null;
		var _loc2_:Int = 0;
		var _loc3_:Int = 0;
		for (_loc4_ in this.m_boardArray) {
			if (As3.floatOf(Reflect.field(_loc4_, "id")) == this.m_myBoardID) {
				Reflect.setField(_loc4_, "status", 1);
			} else {
				Reflect.setField(_loc4_, "status", 0);
			}
			_loc2_++;
		}
		dispatchEvent(new CommonEvent(EVENT_DATA_LOADED, {
			"index": 1,
			"data": this.m_boardArray
		}));
	}

	// DecorateModel.as:206-253（set myDogID；dispatchEvent 在 for-in 键循环体内
	// ——两组表即两记，原文如此）
	private function set_myDogID(param1:Int):Int {
		var _loc3_:Int = 0;
		var _loc4_:Array<Dynamic> = null;
		var _loc5_:DecorateItem = null;
		if (this.m_myDogID == param1) {
			return param1;
		}
		var _loc2_:Int = this.m_myDogID;
		this.m_myDogID = param1;
		if (this.m_decorGroup != null) {
			for (_loc3_ in this.m_decorGroup) {
				_loc4_ = this.m_decorGroup.get(_loc3_);
				if (_loc4_ != null) {
					var _loc4List:Array<DecorateItem> = cast _loc4_;
					if (this.m_myDogID != -1) {
						for (_loc5_ in _loc4List) {
							if (_loc5_._type == Consts.DECOR_DOG) {
								if (_loc5_._id == this.m_myDogID) {
									_loc5_._status = 1;
								} else {
									_loc5_._status = 0;
								}
							}
						}
					} else {
						for (_loc5_ in _loc4List) {
							if (_loc5_._type == Consts.DECOR_DOG && _loc5_._id == _loc2_) {
								_loc5_._status = 0;
								break;
							}
						}
					}
				}
				dispatchEvent(new CommonEvent(EVENT_DATA_CHANGED, {
					"index": 0,
					"data": this.m_decorGroup
				}));
			}
		}
		return param1;
	}

	// DecorateModel.as:255-281
	public function selectBoard(param1:Int):Void {
		if (this.m_requesting == true) {
			return;
		}
		if (param1 < 0) {
			return;
		}
		if (this.m_myBoardID == param1) {
			this.m_requesting = true;
			NetHelper.sendRequest(CommandDefs.CMD_DEACTIVE_DECORATE, {
				"id": param1,
				"type": 1
			}, this.onDeSelectBoardSuccess, this.onDeSelectFailed);
		} else {
			this.m_requesting = true;
			NetHelper.sendRequest(CommandDefs.CMD_ACTIVE_DECORATE, {
				"id": param1,
				"type": 1
			}, this.onSelectBoardSuccess, this.onSelectFailed);
		}
	}

	// DecorateModel.as:283-293
	public function resetLoadingFlags():Void {
		if (this.m_loading == true) {
			this.m_loading = false;
		}
		if (this.m_requesting == true) {
			this.m_requesting = false;
		}
	}

	// DecorateModel.as:295-376
	private function onDataLoadSuccess(param1:CommandEvent):Void {
		var _loc4_:Int = 0;
		var _loc5_:Array<Dynamic> = null;
		var _loc6_:Array<Dynamic> = null;
		var _loc7_:Array<Dynamic> = null;
		var _loc8_:Int = 0;
		var _loc9_:DecorateItem = null;
		var _loc10_:DecorateItem = null;
		var _loc2_:Dynamic = NetHelper.getVOData(param1);
		if (_loc2_ == null) {
			return;
		}
		this.m_loading = false;
		this.m_dirty = false;
		var _loc3_:Array<Dynamic> = Std.isOfType(_loc2_, Array) ? cast(_loc2_, Array<Dynamic>) : null;
		if (_loc3_ == null || _loc3_.length == 0) {
			if (this.m_decorGroup != null) {
				for (_loc4_ in this.m_decorGroup) {
					this.m_decorGroup.remove(_loc4_);
				}
				this.m_decorGroup = null;
			}
			dispatchEvent(new CommonEvent(EVENT_DATA_LOADING, {"show": false}));
			dispatchEvent(new CommonEvent(EVENT_DATA_LOADED, {
				"index": 0,
				"data": this.m_decorGroup
			}));
			return;
		}
		if (this.m_decorGroup == null) {
			this.m_decorGroup = new Dictionary<Int, Array<Dynamic>>();
		}
		_loc5_ = null;
		_loc6_ = null;
		_loc7_ = null;
		for (_loc8_ in this.m_decorGroup) {
			_loc5_ = this.m_decorGroup.get(_loc8_);
			if (_loc5_ != null && _loc5_.length > 0) {
				_loc5_.splice(0, _loc5_.length);
			}
		}
		// for-each 遍历 null 组（组缺位）是 AS3 零圈 → 判空跳过
		var _loc3Group0:Array<DecorateItem> = cast _loc3_[0];
		if (_loc3Group0 != null) {
			for (_loc9_ in _loc3Group0) {
				if (_loc6_ == null) {
					_loc6_ = [];
				}
				_loc6_.push(_loc9_);
				if (_loc9_._type == Consts.DECOR_DOG && _loc9_._status == 1) {
					this.myDogID = _loc9_._id;
				}
			}
		}
		var _loc3Group1:Array<DecorateItem> = cast _loc3_[1];
		if (_loc3Group1 != null) {
			for (_loc10_ in _loc3Group1) {
				if (_loc7_ == null) {
					_loc7_ = [];
				}
				_loc7_.push(_loc10_);
				if (_loc10_._type == Consts.DECOR_DOG && _loc10_._status == 1) {
					this.myDogID = _loc10_._id;
				}
			}
		}
		this.m_decorGroup.set(0, _loc6_);
		this.m_decorGroup.set(1, _loc7_);
		dispatchEvent(new CommonEvent(EVENT_DATA_LOADING, {"show": false}));
		dispatchEvent(new CommonEvent(EVENT_DATA_LOADED, {
			"index": 0,
			"data": this.m_decorGroup
		}));
		EventRecorder.recordSueecssEvent(EventRecorder.HF_GET_DIY_ITEMS, null, "cgi_farm_show_useritems");
	}

	// DecorateModel.as:378-396
	private function onSelectBoardSuccess(param1:CommandEvent):Void {
		var _loc3_:Int = 0;
		var _loc2_:Dynamic = NetHelper.getVOData(param1);
		if (_loc2_ == null) {
			return;
		}
		if (As3.eqString(Reflect.field(_loc2_, "code"), "1")) {
			_loc3_ = As3.intOf(Reflect.field(_loc2_, "id"));
			this.myBoardID = _loc3_;
			dispatchEvent(new CommonEvent(NOTIFY_REFRESH_MAINSCENE, {
				"type": Consts.DECOR_BILLBOARD,
				"id": _loc3_
			}));
		}
		this.m_requesting = false;
	}

	// DecorateModel.as:398-414（`param1[key] != undefined && [key]["itemId"]
	// != undefined` 双判 → As3.hasProp）
	public function setMyDecorate(param1:Dynamic):Void {
		if (param1 == null) {
			return;
		}
		var _loc2_:String = Std.string(Consts.DECOR_BILLBOARD);
		if (As3.hasProp(param1, _loc2_) && As3.hasProp(Reflect.field(param1, _loc2_), "itemId")) {
			this.myBoardID = As3.intOf(Reflect.field(Reflect.field(param1, _loc2_), "itemId"));
		}
		_loc2_ = Std.string(Consts.DECOR_DOG);
		if (As3.hasProp(param1, _loc2_) && As3.hasProp(Reflect.field(param1, _loc2_), "itemId")) {
			this.myDogID = Consts.DECOR_DOG_BASE_ID + As3.intOf(Reflect.field(Reflect.field(param1, _loc2_), "itemId"));
		}
	}

	// DecorateModel.as:421-430
	private function onDeSelectFailed(param1:CommandEvent):Void {
		var _loc2_:Dynamic = NetHelper.getVOData(param1);
		if (_loc2_ == null) {
			return;
		}
		dispatchEvent(new CommonEvent(EVENT_OPERATE_FAILED, {"error": "取消设置装饰失败"}));
		this.m_requesting = false;
	}

	// DecorateModel.as:432-441
	private function onSelectFailed(param1:CommandEvent):Void {
		var _loc2_:Dynamic = NetHelper.getVOData(param1);
		if (_loc2_ == null) {
			return;
		}
		dispatchEvent(new CommonEvent(EVENT_OPERATE_FAILED, {"error": "设置装饰失败"}));
		this.m_requesting = false;
	}

	// DecorateModel.as:443-466
	public function selectDecorate(param1:DecorateItem):Void {
		if (this.m_requesting == true) {
			return;
		}
		var _loc2_:Bool = param1._status == 1 ? true : false;
		if (_loc2_ == true) {
			this.m_requesting = true;
			NetHelper.sendRequest(CommandDefs.CMD_DEACTIVE_DECORATE, {
				"id": param1._id,
				"type": param1._type
			}, this.onDeSelectDecorateSuccess, this.onDeSelectFailed);
		} else {
			this.m_requesting = true;
			NetHelper.sendRequest(CommandDefs.CMD_ACTIVE_DECORATE, {
				"id": param1._id,
				"type": param1._type
			}, this.onSelectDecorateSuccess, this.onSelectFailed);
		}
	}

	// DecorateModel.as:468-479
	private function onNetError(param1:CommandEvent):Void {
		var _loc2_:Dynamic = NetHelper.getVOData(param1);
		if (_loc2_ == null) {
			return;
		}
		this.m_loading = false;
		var _loc3_:String = Reflect.field(Language.L, "请求超时，") + "<a href=\'event:reload\'><u><font color=\'#ff6600\'>"
			+ Reflect.field(Language.L, "点击重试") + "</font></u></a>";
		dispatchEvent(new CommonEvent(EVENT_DATA_FAILED, {"error": _loc3_}));
		EventRecorder.recordErrorEvent(EventRecorder.HF_GET_DIY_ITEMS, null, EventRecorder.FAULT_ERROR, "cgi_farm_show_useritems");
	}

	// DecorateModel.as:481-492（原文私有成员，本类无调用点——死代码照抄保留）
	private function reportError(param1:Int, param2:String):Void {
		var _loc3_:String = null;
		if (param2 == "IOError" || param2 == "httpStatus" || param2 == "timeOut" || param2 == "PHPError") {
			_loc3_ = Reflect.field(Language.L, "请求超时，") + "<a href=\'event:reload\'><u><font color=\'#ff6600\'>"
				+ Reflect.field(Language.L, "点击重试") + "</font></u></a>";
			dispatchEvent(new CommonEvent(EVENT_DATA_FAILED, {
				"index": param1,
				"error": _loc3_
			}));
		}
	}

	// DecorateModel.as:499-520
	private function onDeSelectBoardSuccess(param1:CommandEvent):Void {
		var _loc3_:Int = 0;
		var _loc2_:Dynamic = NetHelper.getVOData(param1);
		if (_loc2_ == null) {
			return;
		}
		if (As3.eqString(Reflect.field(_loc2_, "code"), "1")) {
			_loc3_ = As3.intOf(Reflect.field(_loc2_, "id"));
			if (this.m_myBoardID == _loc3_) {
				this.myBoardID = -1;
			}
			dispatchEvent(new CommonEvent(NOTIFY_REFRESH_MAINSCENE, {
				"type": Consts.DECOR_BILLBOARD,
				"id": -1
			}));
		}
		this.m_requesting = false;
	}

	// DecorateModel.as:522-535
	public function loadItems():Void {
		if (this.m_dirty == false) {
			return;
		}
		if (this.m_loading == true) {
			return;
		}
		this.m_loading = true;
		NetHelper.sendRequest(CommandDefs.CMD_GET_DIY_ITEMS, null, this.onDataLoadSuccess, this.onNetError);
		dispatchEvent(new CommonEvent(EVENT_DATA_LOADING, {"show": true}));
	}

	// DecorateModel.as:537-630
	private function onSelectDecorateSuccess(param1:CommandEvent):Void {
		var _loc3_:Int = 0;
		var _loc4_:Int = 0;
		var _loc5_:DecorateItem = null;
		var _loc6_:Array<Dynamic> = null;
		var _loc7_:DecorateItem = null;
		var _loc8_:DecorateItem = null;
		var _loc9_:Array<Dynamic> = null;
		var _loc10_:Int = 0;
		var _loc11_:Bool = false;
		var _loc12_:Int = 0;
		var _loc13_:Int = 0;
		var _loc2_:Dynamic = NetHelper.getVOData(param1);
		if (_loc2_ == null) {
			return;
		}
		this.m_requesting = false;
		if (As3.eqString(Reflect.field(_loc2_, "code"), "1")) {
			_loc3_ = As3.intOf(Reflect.field(_loc2_, "id"));
			_loc4_ = As3.intOf(Reflect.field(Reflect.field(param1.body, "__body"), "type"));
			_loc5_ = null;
			_loc6_ = this.m_decorGroup.get(1);
			_loc7_ = null;
			// for-each 遍历 null 组（组 1 缺位）是 AS3 零圈 → 判空跳过
			if (_loc6_ != null) {
				var _loc6List:Array<DecorateItem> = cast _loc6_;
				for (_loc5_ in _loc6List) {
					if (_loc5_._type == _loc4_) {
						if (_loc5_._id == _loc3_) {
							_loc5_._status = 1;
							_loc7_ = _loc5_;
						} else {
							_loc5_._status = 0;
						}
					}
				}
			}
			if (_loc7_ == null) {
				return;
			}
			_loc8_ = null;
			_loc9_ = this.m_decorGroup.get(0);
			_loc10_ = _loc9_.length;
			_loc11_ = false;
			_loc12_ = 0;
			_loc13_ = 0;
			while (_loc13_ < _loc10_) {
				_loc8_ = _loc9_[_loc13_];
				if (_loc8_._type == _loc4_) {
					if (_loc8_._id == _loc3_) {
						_loc12_ = 1;
						cast(_loc9_[_loc13_], DecorateItem)._status = _loc7_._status;
					} else {
						_loc9_[_loc13_] = _loc7_;
					}
					_loc11_ = true;
					break;
				}
				_loc13_++;
			}
			if (_loc11_ == false) {
				_loc9_.push(_loc7_);
			}
			if (_loc12_ == 0) {
				dispatchEvent(new CommonEvent(EVENT_DATA_CHANGED, {
					"index": 0,
					"data": this.m_decorGroup
				}));
			} else {
				dispatchEvent(new CommonEvent(EVENT_DATA_STATUS_CHANGED, {
					"type": _loc4_,
					"id": _loc3_
				}));
			}
			dispatchEvent(new CommonEvent(NOTIFY_REFRESH_MAINSCENE, {
				"type": _loc4_,
				"id": _loc3_
			}));
		}
	}
}
