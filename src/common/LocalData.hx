package common;

import openfl.display.Sprite;

/**
 * common.LocalData —— LocalData.as（mcloader_v_53/scripts，预加载器与
 * Master2 同应用域共享，Master2 反编译里无此文件）的签名面 stub（原类
 * 255 loc，mcloader 片真身待译——后续模块；issue #19 只保 profile 窗族
 * 读到的 isMe/mode/rollCollection 三个静态位，issue #87 补 mc.FBridge
 * 网栈与 GetCropID 读到的 parameters/xymode/lastRequest 四件/appImgPrefix
 * 通道位）。行号对应 mcloader 反编译。纯静态字段本身无逻辑可 throw，
 * setObject/getObject/flush 的 SharedObject 读写随 mcloader 片充真身。
 */
@:keep
class LocalData {
	// LocalData.as:15
	private static var _parameters:Dynamic;

	// LocalData.as:27/29/45/55（FRequest 的 lastRequest 四件，
	// FRequest.as:56-59/:139-142）
	public static var lastRequestHandle:Dynamic;
	public static var lastRequestUrl:String;
	public static var lastRequestFn:Dynamic;
	public static var lastRequestValue:Dynamic;

	// LocalData.as:57
	public static var isMe:Bool;

	// LocalData.as:67
	public static var rollCollection:Sprite;

	// LocalData.as:85
	public static var mode:String = "";

	// LocalData.as:95
	public static var xymode:String = "";

	// LocalData.as:121-127/141-143（parameters 读写——读方向在 mode==qzone
	// 或 xymode=="" 时有加工（LocalData.as:129），stub 直通存取，加工逻辑
	// 随 mcloader 片充真身）
	public static var parameters(get, set):Dynamic;

	private static function get_parameters():Dynamic {
		return _parameters;
	}

	private static function set_parameters(param1:Dynamic):Dynamic {
		_parameters = param1;
		return param1;
	}

	// LocalData.as:112-118（getInstance(param1 = "FarmWorld")——实例方法
	// setObject/getObject 的 SharedObject 通道 stub 抛 not implemented，
	// 真身随 mcloader 片；issue #87 的 RequestManager 测试会触到 setObject
	// ——addUin/addAction/resetUin 的内存 mutation 先于该调用发生，测试以
	// try/catch 容忍 stub 掷错后只断言内存态，implement/mcloader 补全后
	// 容忍分支不再触发）
	public function new() {}

	public static var instance:LocalData;

	public static function getInstance(param1:String = "FarmWorld"):LocalData {
		if (instance == null) {
			instance = new LocalData();
		}
		return instance;
	}

	// LocalData.as:146-168
	public function setObject(param1:String, param2:Dynamic, param3:Float = 0, param4:Bool = false):Bool {
		throw new openfl.errors.Error("not implemented");
	}

	// LocalData.as:194-216
	public function getObject(param1:String, param2:Float = 0):Dynamic {
		throw new openfl.errors.Error("not implemented");
	}
}
