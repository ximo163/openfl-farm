package mc.model;

import common.CommonData;
import openfl.errors.Error;
import openfl.events.EventDispatcher;

/**
 * mc.model.MData —— MData.as 逐句对应（issue #19 Master2 闭包顺手译）。
 * 模型单例聚合：各数据类惰性建（MainData/FarmData/TinItemsData 为牧场片
 * stub，真身待译——#pasture）。
 */
@:keep
class MData extends EventDispatcher {
	// MData.as:9
	private static var instance:MData;

	// MData.as:11-19
	private var _tooldata:ToolData;
	private var _mainData:MainData;
	private var _tinData:TinItemsData = null;
	private var _productData:ProductData;
	private var _farmData:FarmData;

	public function new() {
		// PORT-NOTE(cpp)：同 ViewControl——super() 前移到守卫外，等价
		super();
		if (instance == null) {
			return;
		}
		throw new Error("实例化单例类出错-LifeData");
	}

	// MData.as:31-38
	public static function getInstance():MData {
		if (instance == null) {
			instance = new MData();
		}
		return instance;
	}

	// MData.as:40-47
	public var farmData(get, never):FarmData;

	private function get_farmData():FarmData {
		if (this._farmData == null) {
			this._farmData = new FarmData();
		}
		return this._farmData;
	}

	// MData.as:49-56
	public var mainData(get, never):MainData;

	private function get_mainData():MainData {
		if (this._mainData == null) {
			this._mainData = new MainData();
		}
		return this._mainData;
	}

	// MData.as:58-64（_loc1_/_loc2_ 为原版未用局部，略）
	public function showYellowPackageTest():String {
		var _loc3_:MainData = MData.getInstance().mainData;
		return "uIdx=" + _loc3_.getHostId;
	}

	// MData.as:66-74
	public var tinData(get, never):TinItemsData;

	private function get_tinData():TinItemsData {
		if (this._tinData != null) {
			return this._tinData;
		}
		this._tinData = new TinItemsData();
		return this._tinData;
	}

	// MData.as:76-83
	public var toolData(get, never):ToolData;

	private function get_toolData():ToolData {
		if (this._tooldata == null) {
			this._tooldata = new ToolData();
		}
		return this._tooldata;
	}

	// MData.as:85-92
	public var productData(get, never):ProductData;

	private function get_productData():ProductData {
		if (this._productData == null) {
			this._productData = new ProductData();
		}
		return this._productData;
	}
}
