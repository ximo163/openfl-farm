package module.warehouse.bag;

import com.qzone.qfa.debug.Debugger;
import com.qzone.qfa.events.CommandEvent;
import common.Consts;
import common.Settings;
import common.misc.QzoneJSAPI;
import entities.BagItem;
import events.CommonEvent;
import framework.net.CommandDefs;
import framework.net.NetHelper;
import framework.net.vo.ServiceResultVO;
import openfl.events.EventDispatcher;
import report.EventRecorder;
import shim.As3;

/**
 * module.warehouse.bag.MyBagModel —— MyBagModel.as 逐句对应（issue #36 功能
 * swf 翻译：仓库）。背包（道具/种子两栏）数据源：repertory getUserSeed
 * （CMD_GET_BAG_DATA 32）——种子/农场工具/鱼食/牧场工具/鱼苗五类混表
 * （repertory_getuserseed.php:9-56 的 package→tools→fish_tools→牧场 tools→
 * fish_package 拼接序），onGetMyBagData 按类型分栏（type==1 种子栏 sortOn
 * _cId 数值降序前置，其余按 crops_sort 配 _sort 升序）、鱼苗条目从 Settings
 * fish_info 补名称/成熟期。fillterType 三栏过滤（normal/fish/tool，tool 栏
 * 鱼食插到首个武器条目前）。
 *
 * PORT-NOTE: `_type == Consts.ITEM_TYPE_*`（Int 对字面量 String）的 AS3 松等
 * → As3.eqString（WelcomeModel/ShopModel 先例）；`_type.toString() == 字面量`
 * → Std.string 直比；sortOn("_cId", NUMERIC|DESCENDING) 无 Haxe 等价 →
 * As3.sortOnNumericDesc；`splice(idx,0,item)` 的零删插入 → Array.insert
 * （LoadManager 先例）。NetHelper.sendRequest 在 theApp == null 时 no-op
 * （#7 已译，测试进程不跑 Main、theApp 恒 null）——reload 的请求侧不可观测；
 * EventRecorder 已按 deviations（no-qq-telemetry）DISABLED，
 * recordResp 类调用只保不抛；QzoneJSAPI.reportError 在 eval 上安全
 * （QQOutlets.available 恒 false）。
 * AS3 internal static const → private（CLAUDE.md 映射）；dirty 的 get/set
 * （声明点 :51/:165 分散）合成一个 Haxe property；同包消费方
 * MyBagController/MyBagView 按 FriendsController 先例用 @:access 取。
 */
class MyBagModel extends EventDispatcher {
	// MyBagModel.as:19（AS3 internal static const → private；INITIALZED 原版拼写）
	private static final EVENT_INITIALZED:String = "DataInitialized";

	// MyBagModel.as:21
	private static final EVENT_LOAD_FAILED:String = "LoadFailed";

	// MyBagModel.as:23
	private static final EVENT_LOADING:String = "LoadingProcess";

	// MyBagModel.as:25
	private static final EVENT_UPDATED:String = "DataUpdated";

	// MyBagModel.as:27
	private var m_bDirty:Bool;

	// MyBagModel.as:29
	private var m_items:Array<Dynamic>;

	// MyBagModel.as:31-36
	public function new() {
		super();
		this.m_items = null;
		this.m_bDirty = true;
	}

	// MyBagModel.as:38-49（for each 对 null 零次迭代，Haxe 迭代 null 抛
	// Null Access，需显式判空——FarmLandModel 先例）
	public function getItem(param1:Int, param2:Int):BagItem {
		var _loc3_:BagItem = null;
		if (this.m_items != null) {
			for (_loc3_ in this.m_items) {
				if (_loc3_._cId == param1 && _loc3_._type == param2) {
					return _loc3_;
				}
			}
		}
		return null;
	}

	// MyBagModel.as:51-54（set）与 :165-168（get）合成一对
	public var dirty(get, set):Bool;

	private function get_dirty():Bool {
		return this.m_bDirty;
	}

	private function set_dirty(param1:Bool):Bool {
		this.m_bDirty = param1;
		return param1;
	}

	// MyBagModel.as:56-67
	private function onGetMyBagDataFailed(param1:CommandEvent):Void {
		dispatchEvent(new CommonEvent(EVENT_LOADING, false));
		dispatchEvent(new CommonEvent(EVENT_LOAD_FAILED, null));
		var _loc2_:ServiceResultVO = Std.isOfType(param1.result, ServiceResultVO) ? cast(param1.result, ServiceResultVO) : null;
		if (_loc2_ != null && _loc2_.m_message != "") {
			Debugger.log("[MyBag] get data failed: " + _loc2_.m_message);
		}
		QzoneJSAPI.reportError("背包物品加载失败", 2);
		EventRecorder.recordErrorEvent(EventRecorder.HF_GET_BAG_DATA, null, EventRecorder.FAULT_ERROR, "cgi_farm_getuserseed");
	}

	// MyBagModel.as:69-76
	public var empty(get, never):Bool;

	private function get_empty():Bool {
		if (this.m_items == null || this.m_items.length == 0) {
			return true;
		}
		return false;
	}

	// MyBagModel.as:78-85
	private function cropSort(param1:BagItem, param2:BagItem):Int {
		if (param1._sort < param2._sort) {
			return -1;
		}
		return 1;
	}

	// MyBagModel.as:87-163
	private function onGetMyBagData(param1:CommandEvent):Void {
		var _loc5_:Int = 0;
		var _loc9_:Int = 0;
		var _loc10_:Array<Dynamic> = null;
		var _loc2_:Dynamic = NetHelper.getVOData(param1);
		if (_loc2_ == null) {
			return;
		}
		if (this.m_items == null) {
			this.m_items = new Array<Dynamic>();
		} else {
			// AS3 splice(0) 清表 → splice(0, length)（ShopModel 先例）
			this.m_items.splice(0, this.m_items.length);
		}
		var _loc3_:Array<Dynamic> = [];
		var _loc4_:Array<Dynamic> = [];
		if (Std.isOfType(_loc2_, Array)) {
			var _loc2a_:Array<Dynamic> = cast _loc2_;
			_loc5_ = _loc2a_.length;
			_loc9_ = 0;
			while (_loc9_ < _loc5_) {
				var _loc7_:BagItem = _loc2a_[_loc9_];
				if (_loc7_._type == 1) {
					_loc3_.push(_loc2a_[_loc9_]);
				} else {
					_loc4_.push(_loc2a_[_loc9_]);
				}
				_loc9_++;
			}
		}
		this.m_items = this.m_items.concat(_loc4_);
		var _loc6_:String = Settings.getInstance().getStringAttribute("crops_sort");
		var _loc7_:BagItem = null;
		if (_loc6_ != "") {
			_loc10_ = _loc6_.split(",");
			for (_loc7_ in this.m_items) {
				if (_loc7_._cId != 0) {
					_loc7_._sort = _loc10_.indexOf(Std.string(_loc7_._cId));
				} else {
					_loc7_._sort = 99;
				}
			}
			this.m_items.sort(this.cropSort);
		}
		As3.sortOnNumericDesc(_loc3_, "_cId");
		this.m_items = _loc3_.concat(this.m_items);
		_loc3_ = null;
		_loc4_ = null;
		var _loc8_:Dynamic = null;
		for (_loc7_ in this.m_items) {
			if (Std.string(_loc7_._type) == Consts.ITEM_TYPE_FISH) {
				_loc8_ = Settings.getInstance().getFishByID(Std.string(_loc7_._cId));
				if (_loc8_ != null) {
					_loc7_._name = Reflect.field(_loc8_, "crop_name");
					_loc7_._lifeCycle = As3.intOf(Reflect.field(_loc8_, "mature"));
				}
			}
		}
		this.dirty = false;
		dispatchEvent(new CommonEvent(EVENT_INITIALZED, this.m_items));
		EventRecorder.recordSueecssEvent(EventRecorder.HF_GET_BAG_DATA, null, "cgi_farm_getuserseed");
	}

	// MyBagModel.as:170-177
	private function fishFoodSort(param1:BagItem, param2:BagItem):Int {
		if (Std.string(param1._type) == Consts.ITEM_TYPE_FISHFEED) {
			return param1._cId < param2._cId ? -1 : 1;
		}
		return 1;
	}

	// MyBagModel.as:179-239（fillterType 原版拼写如此）
	public function fillterType(param1:String = "normal"):Array<Dynamic> {
		var _loc5_:Dynamic = null;
		var _loc6_:Int = 0;
		var _loc7_:Bool = false;
		var _loc8_:BagItem = null;
		var _loc2_:Array<Dynamic> = [];
		if (this.empty) {
			return _loc2_;
		}
		var _loc3_:Array<Dynamic> = [];
		var _loc4_:Float = 0;
		while (As3.truthy(As3.arrAt(this.m_items, Std.int(_loc4_)))) {
			_loc5_ = this.m_items[Std.int(_loc4_)];
			if (param1 == "normal" && As3.eqString(_loc5_._type, Consts.ITEM_TYPE_SEED)) {
				_loc2_.push(_loc5_);
			} else if (param1 == "fish" && As3.eqString(_loc5_._type, Consts.ITEM_TYPE_FISH)) {
				_loc2_.push(_loc5_);
			} else if (param1 == "tool" && !As3.eqString(_loc5_._type, Consts.ITEM_TYPE_SEED) && !As3.eqString(_loc5_._type,
				Consts.ITEM_TYPE_FISH)) {
				if (As3.eqString(_loc5_._type, Consts.ITEM_TYPE_FISHFEED)) {
					_loc3_.push(_loc5_);
				} else {
					_loc2_.push(_loc5_);
				}
			}
			_loc4_++;
		}
		if (param1 == "tool" && _loc3_.length > 0) {
			_loc6_ = 0;
			_loc7_ = false;
			for (_loc8_ in _loc2_) {
				if (Std.string(_loc8_._type) == Consts.ITEM_TYPE_WEAPON) {
					while (_loc3_.length > 0) {
						// AS3 splice(idx,0,pop) 的零删插入 → insert
						_loc2_.insert(_loc6_, _loc3_.pop());
					}
					_loc7_ = true;
					break;
				}
				_loc6_++;
			}
			if (_loc7_ == false) {
				_loc2_ = _loc2_.concat(_loc3_);
			}
		}
		return _loc2_;
	}

	// MyBagModel.as:241-249
	public function reload():Void {
		if (this.m_items != null && this.m_bDirty == false) {
			return;
		}
		NetHelper.sendRequest(CommandDefs.CMD_GET_BAG_DATA, null, this.onGetMyBagData, this.onGetMyBagDataFailed);
		dispatchEvent(new CommonEvent(EVENT_LOADING, true));
	}

	// MyBagModel.as:251-264（for each 对 null 零次迭代，同 getItem 判空）
	public function deleteItem(param1:Int, param2:Int):Void {
		var _loc3_:BagItem = null;
		var _loc4_:Int = 0;
		if (this.m_items == null) {
			return;
		}
		for (_loc3_ in this.m_items) {
			if (_loc3_._cId == param1 && _loc3_._type == param2) {
				_loc4_ = this.m_items.indexOf(_loc3_);
				this.m_items.splice(_loc4_, 1);
				return;
			}
		}
	}
}
