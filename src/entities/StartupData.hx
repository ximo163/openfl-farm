package entities;

// entities.StartupData —— StartupData.as 逐句对应。
class StartupData {
	// StartupData.as:8
	public static var serverTime:Int;

	// StartupData.as:12-32 字段（public var 原样）
	public var _beast:Dynamic;
	public var _welcome:Bool;
	public var _task:Task;
	public var _decors:Dynamic;
	public var _unread:Dynamic;
	public var _serverTime:Int;
	public var _user:Player;
	public var upGoldLandTime:Int = 0; // AS3 int 默认值（原版构造器不置）
	public var _weather:Weather;
	public var _landStatus:Array<Dynamic>;
	public var _dog:Dog;

	// StartupData.as:34-45
	public function new() {
		_dog = null;
		_task = null;
		_user = null;
		_weather = null;
		_serverTime = 0;
		_decors = null;
		_landStatus = null;
		_welcome = false;
		_unread = null;
	}
}
