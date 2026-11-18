package entities;

/**
 * entities.StartupData —— write-tests stub（issue #7）：字段签名与
 * legacy/decompiled/main3_v_221/scripts/entities/StartupData.as 一致，构造体
 * `throw new Error("not implemented")`，实现在翻译阶段完成。
 *
 * 原版：public class StartupData，静态 serverTime :8，字段 :12-32，
 * 构造默认值 :34-45。
 */
class StartupData {
	// StartupData.as:8
	public static var serverTime:Int;

	// StartupData.as:12-32 字段（public var 原样；_dog/_user/_task/_weather
	// 指向闭包 stub 实体，翻译阶段保持同名类型）
	public var _beast:Dynamic;
	public var _welcome:Bool;
	public var _task:Task;
	public var _decors:Dynamic;
	public var _unread:Dynamic;
	public var _serverTime:Int;
	public var _user:Player;
	public var upGoldLandTime:Int;
	public var _weather:Weather;
	public var _landStatus:Array<Dynamic>;
	public var _dog:Dog;

	public function new() {
		throw new openfl.errors.Error("not implemented");
	}
}
