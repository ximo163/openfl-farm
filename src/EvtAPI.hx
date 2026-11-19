package;

import openfl.events.Event;

// EvtAPI —— EvtAPI.as 逐句对应（BeastAPI/牧场事件的顶层包事件类，FarmStage
// 监听 SHOW_WILD_STAGE/SHOW_FARM_STAGE）。
class EvtAPI extends Event {
	// EvtAPI.as:9-27
	public static final SHOW_BEAST_PACK:String = "show_Beast_Pack";
	public static final HIDE_BEAST_PACK:String = "hide_Beast_Pack";
	public static final BEAST_DATA_CHANGE:String = "animals_Change";
	public static final SHOW_WILD_STAGE:String = "show_wild_stage";
	public static final SHOW_FARM_STAGE:String = "show_farm_stage";
	public static final REWARD_CHANGE:String = "reward_change";
	public static final HUNTER_CHANGE:String = "hunter_change";
	public static final HOST_CHANGE:String = "host_Change";
	public static final CURRENT_USER_CHANGE:String = "current_user_change";
	public static final REFRESH_CRYSTAL:String = "refreshCrystal";

	// EvtAPI.as:29
	private var _data:Dynamic;

	// EvtAPI.as:31-34
	public function new(param1:String) {
		super(param1);
	}

	// EvtAPI.as:36-44
	public var data(get, set):Dynamic;

	private function get_data():Dynamic {
		return this._data;
	}

	private function set_data(param1:Dynamic):Dynamic {
		this._data = param1;
		return param1;
	}
}
