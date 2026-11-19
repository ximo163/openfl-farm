package entities;

import common.misc.Utils;

/**
 * entities.HealthMode —— V3b 顺手翻（issue #8 闭包，HealthMode.as 47 loc
 * ≤ 100；Player.importObject 实体化 healthMode）。原版 final class。
 * legacy/decompiled/main3_v_221/scripts/entities/HealthMode.as 逐句对应。
 */
final class HealthMode {
	// HealthMode.as:9-23（eval/js 上未赋值基元是 null 而非 AS3 VM 默认值，
	// int 逐字段显式落 0；String 默认 null，两边一致不写）
	public var _set:Int = 0;
	public var _canClose:Int = 0;
	public var _endTime:Int = 0;
	public var _time:String;
	public var _date:String;
	public var _serverTime:Int = 0;
	public var _beginTime:Int = 0;
	public var _valid:Int = 0;

	// HealthMode.as:25-29
	public function new(param1:Dynamic) {
		this.importObject(param1);
	}

	// HealthMode.as:31-47
	public function importObject(param1:Dynamic):Void {
		if (param1 == null) {
			return;
		}
		this._beginTime = Std.int(Utils.getIntAttribute(param1, "beginTime"));
		this._canClose = Std.int(Utils.getIntAttribute(param1, "canClose"));
		this._endTime = Std.int(Utils.getIntAttribute(param1, "endTime"));
		this._serverTime = Std.int(Utils.getIntAttribute(param1, "serverTime"));
		this._set = Std.int(Utils.getIntAttribute(param1, "set"));
		this._time = Utils.getStrAttribute(param1, "time");
		this._date = Utils.getStrAttribute(param1, "date");
		this._valid = Std.int(Utils.getIntAttribute(param1, "valid"));
	}
}
