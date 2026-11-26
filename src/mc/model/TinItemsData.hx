package mc.model;

import openfl.events.EventDispatcher;

/**
 * mc.model.TinItemsData —— TinItemsData.as 的签名面 stub（原类 138 loc，
 * issue #87「数据」片充真身）。罐头/工资道具商店数据：addTinItems 把
 * 服务端长字段名重映射成单字母键、setprice/ysetprice 的 "month-money;"
 * 串拆表；allTinItems 按 order 数值升序后把末 4 项旋到最前。原类是
 * final（TinItemsData.as:5），Haxe 侧保持。
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

	// TinItemsData.as:28-34（allTinItems：副本 sortOn("o") 数值升序 +
	// splice(-4,4) 末四项旋前）
	public var allTinItems(get, never):Array<Dynamic>;

	private function get_allTinItems():Array<Dynamic> {
		throw new openfl.errors.Error("not implemented");
	}

	// TinItemsData.as:36-45（loadingData 存取——setter 派发
	// LOAD_STATUS_CHANGED）
	public var loadingData(get, set):Bool;

	private function get_loadingData():Bool {
		return this.m_loadingData;
	}

	private function set_loadingData(param1:Bool):Bool {
		throw new openfl.errors.Error("not implemented");
	}

	// TinItemsData.as:47-51/:132-135（shopTinInfoErr 存取——setter 派发
	// LOAD_TINS_ERROR）
	public var shopTinInfoErr(get, set):String;

	private function get_shopTinInfoErr():String {
		return this.m_shopTinInfoErr;
	}

	private function set_shopTinInfoErr(param1:String):String {
		throw new openfl.errors.Error("not implemented");
	}

	// TinItemsData.as:53-130
	public function addTinItems(param1:Array<Dynamic>):Void {
		throw new openfl.errors.Error("not implemented");
	}
}
