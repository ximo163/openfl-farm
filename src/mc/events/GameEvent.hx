package mc.events;

import openfl.events.Event;

/**
 * mc.events.GameEvent —— GameEvent.as 逐句对应（issue #86 牧场库底座，
 * 事件片）。金币/经验增量事件。
 * legacy/decompiled/Master2_v_142/scripts/mc/events/GameEvent.as。
 *
 * PORT-NOTE（addMoney 的 int/Number 错位，AS3 :11/:27/:32-35）：字段
 * _addMoney 声明 int、setter 形参 Number、getter 返 Number——原版声明
 * 不一致（写 Number 读 Number，存储被 int 截断）。Haxe 属性类型须单一，
 * 按 getter/setter 的 Number 面定为 Float，存储字段随之 Float——int 字段
 * 的截断语义在 setter 里用 As3.intOf 复刻（赋进 int 变量即 ToInt32 截断，
 * 读出再转 Number 同值）。
 */
@:keep
class GameEvent extends Event {
	// GameEvent.as:8-10
	public static final ADD_MONEY:String = "add_Money";
	public static final ADD_EXPERIENCE:String = "add_Experience";

	// :12（int 存储——见类头 PORT-NOTE）
	private var _addMoney:Int;

	// :14
	private var _addExperience:Int;

	// :16-19
	public function new(param1:String, param2:Bool = false, param3:Bool = false) {
		super(param1, param2, param3);
	}

	// :21-24/:26-29
	public var addExperience(get, set):Int;

	private function get_addExperience():Int {
		return this._addExperience;
	}

	private function set_addExperience(param1:Int):Int {
		this._addExperience = param1;
		return param1;
	}

	// :31-39（Number 面 + int 存储截断，见类头 PORT-NOTE）
	public var addMoney(get, set):Float;

	private function get_addMoney():Float {
		return this._addMoney;
	}

	private function set_addMoney(param1:Float):Float {
		this._addMoney = shim.As3.intOf(param1);
		return param1;
	}
}
