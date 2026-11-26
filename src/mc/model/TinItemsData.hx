package mc.model;

import openfl.events.EventDispatcher;
import shim.As3;

/**
 * mc.model.TinItemsData —— TinItemsData.as 逐句对应（issue #87「数据」片
 * 充真身）。罐头/工资道具商店数据：addTinItems 把服务端长字段名重映射成
 * 单字母键、setprice/ysetprice 的 "month-money;" 串拆表；allTinItems 按
 * order 数值升序后把末 4 项旋到最前。原类是 final（TinItemsData.as:5），
 * Haxe 侧保持。
 * legacy/decompiled/Master2_v_142/scripts/mc/model/TinItemsData.as。
 */
@:keep
final class TinItemsData extends EventDispatcher {
	// TinItemsData.as:8-12
	public static final LOAD_TINS_ERROR:String = "Load_failed";
	public static final LOAD_TINS_SUCCESS:String = "Load_success";
	public static final LOAD_STATUS_CHANGED:String = "Load_status_changed";

	// TinItemsData.as:14-18
	private var m_shopTinInfoErr:String;
	private var m_tins:Array<Dynamic>;
	private var m_loadingData:Bool;

	// TinItemsData.as:20-26
	public function new() {
		super();
		this.m_tins = [];
		this.m_shopTinInfoErr = "";
		this.m_loadingData = false;
	}

	// TinItemsData.as:28-34（allTinItems：副本 sortOn("o", Array.NUMERIC)
	// 数值升序 + splice(-4,4) 末四项切出拼最前。PORT-NOTE(sortOn)：
	// Array.NUMERIC 按字段值数值序——Haxe 侧按 floatOf 比较复刻；
	// splice(-4,4) 负下标从尾数起，长度<4 时切走全部、旋转不动）
	public var allTinItems(get, never):Array<Dynamic>;

	private function get_allTinItems():Array<Dynamic> {
		// AS3 `concat()` 无参调用是防御性拷贝 → Haxe copy()（WelcomeModel 先例）
		var _loc1_:Array<Dynamic> = this.m_tins.copy();
		_loc1_.sort(function(a:Dynamic, b:Dynamic):Int {
			var va:Float = As3.floatOf(Reflect.field(a, "o"));
			var vb:Float = As3.floatOf(Reflect.field(b, "o"));
			if (va < vb) {
				return -1;
			}
			if (va > vb) {
				return 1;
			}
			return 0;
		});
		// splice(-4,4)：Haxe 的负起点同为从尾数起、钳到下标 0（eval 实测
		// 与 AS3 逐点同果：6 项切 [3,4,5,6]、不足四项切走全部）——照抄
		var _loc2_:Array<Dynamic> = _loc1_.splice(-4, 4);
		return _loc2_.concat(_loc1_);
	}

	// TinItemsData.as:36-45（loadingData 存取——setter 派发
	// LOAD_STATUS_CHANGED）
	public var loadingData(get, set):Bool;

	private function get_loadingData():Bool {
		return this.m_loadingData;
	}

	private function set_loadingData(param1:Bool):Bool {
		this.m_loadingData = param1;
		dispatchEvent(new ModelEvent(LOAD_STATUS_CHANGED));
		return param1;
	}

	// TinItemsData.as:47-51/:132-135（shopTinInfoErr 存取——setter 派发
	// LOAD_TINS_ERROR）
	public var shopTinInfoErr(get, set):String;

	private function get_shopTinInfoErr():String {
		return this.m_shopTinInfoErr;
	}

	private function set_shopTinInfoErr(param1:String):String {
		this.m_shopTinInfoErr = param1;
		dispatchEvent(new ModelEvent(LOAD_TINS_ERROR));
		return param1;
	}

	// TinItemsData.as:53-130（缺 id/type 的条目整条跳过；长键重映射；
	// setprice/ysetprice 按 ";" 切段、空段跳过、"-" 拆 {month,money}。
	// PORT-NOTE(undefined)：`_loc3_["id"] == undefined` 是键缺位/显式
	// undefined 判定——Haxe 两侧都落 null，按 hasProp 半守卫等价（值显式
	// null 时 AS3 是 null != undefined 不跳过、Haxe 也放行——双null 合一
	// 无分歧路径，罐头下发从不写显式 null）。hasOwnProperty("setprice")
	// 用 As3.hasProp 等价 trait 查询）
	public function addTinItems(param1:Array<Dynamic>):Void {
		var _loc4_:Array<Dynamic> = null;
		var _loc5_:Int = 0;
		var _loc6_:Array<String> = null;
		var _loc7_:Array<String> = null;
		if (param1 == null || param1.length == 0) {
			this.m_tins = [];
			dispatchEvent(new ModelEvent(LOAD_TINS_SUCCESS));
			return;
		}
		this.m_tins = [];
		var _loc2_:Dynamic = null;
		for (_loc3_ in param1) {
			if (!(Reflect.field(_loc3_, "id") == null || Reflect.field(_loc3_, "type") == null)) {
				_loc2_ = {};
				Reflect.setField(_loc2_, "id", Reflect.field(_loc3_, "id"));
				Reflect.setField(_loc2_, "d", Reflect.field(_loc3_, "description"));
				Reflect.setField(_loc2_, "t", Reflect.field(_loc3_, "type"));
				Reflect.setField(_loc2_, "e", Reflect.field(_loc3_, "effect"));
				Reflect.setField(_loc2_, "n", Reflect.field(_loc3_, "name"));
				Reflect.setField(_loc2_, "l", Reflect.field(_loc3_, "left"));
				Reflect.setField(_loc2_, "p", Reflect.field(_loc3_, "price"));
				Reflect.setField(_loc2_, "qd", Reflect.field(_loc3_, "qdprice"));
				Reflect.setField(_loc2_, "y", Reflect.field(_loc3_, "yqdprice"));
				Reflect.setField(_loc2_, "o", Reflect.field(_loc3_, "order"));
				Reflect.setField(_loc2_, "lt", Reflect.field(_loc3_, "limittips"));
				Reflect.setField(_loc2_, "tips", Reflect.field(_loc3_, "tips"));
				Reflect.setField(_loc2_, "appid", Reflect.field(_loc3_, "appid"));
				Reflect.setField(_loc2_, "shortage", Reflect.field(_loc3_, "shortage"));
				_loc4_ = [];
				if (As3.hasProp(_loc3_, "setprice")) {
					_loc6_ = Std.string(Reflect.field(_loc3_, "setprice")).split(";");
					_loc5_ = 0;
					while (_loc5_ < _loc6_.length) {
						if (_loc6_[_loc5_] != "") {
							_loc7_ = _loc6_[_loc5_].split("-");
							_loc4_.push({
								"month": _loc7_[0],
								"money": _loc7_[1]
							});
						}
						_loc5_++;
					}
					Reflect.setField(_loc2_, "setprice", _loc4_);
				}
				if (As3.hasProp(_loc3_, "ysetprice")) {
					_loc4_ = [];
					_loc6_ = [];
					_loc6_ = Std.string(Reflect.field(_loc3_, "ysetprice")).split(";");
					_loc5_ = 0;
					while (_loc5_ < _loc6_.length) {
						if (_loc6_[_loc5_] != "") {
							_loc7_ = _loc6_[_loc5_].split("-");
							_loc4_.push({
								"month": _loc7_[0],
								"money": _loc7_[1]
							});
						}
						_loc5_++;
					}
					Reflect.setField(_loc2_, "ysetprice", _loc4_);
				}
				this.m_tins.push(_loc2_);
			}
		}
		dispatchEvent(new ModelEvent(LOAD_TINS_SUCCESS));
	}
}
