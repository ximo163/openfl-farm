package mc.view.main.windowControl;

/**
 * mc.view.main.windowControl.WindowClassLib —— WindowClassLib.as 逐句对应
 * （issue #87「窗口框架」片）。窗类名→Class 的懒注册表：register/getClass
 * 静态通道，_lib 首次 register 时才建；getClass 键缺失时下标返
 * undefined→null。
 * legacy/decompiled/Master2_v_142/scripts/mc/view/main/WindowControl/WindowClassLib.as。
 * PORT-NOTE(命名)：原包 `mc.view.main.WindowControl` 首字母大写，Haxe 包段
 * 必须小写开头，落 `windowControl`（WControl 同款先例，deviations 候选）。
 */
@:keep
class WindowClassLib {
	// WindowClassLib.as:6
	private static var _lib:Dynamic;

	// WindowClassLib.as:8-11
	public function new() {}

	// WindowClassLib.as:13-20
	public static function getClass(param1:String):Class<Dynamic> {
		if (_lib == null) {
			return null;
		}
		return Reflect.field(_lib, param1);
	}

	// WindowClassLib.as:22-25
	public static function register(param1:String, param2:Class<Dynamic>):Void {
		if (_lib == null) {
			_lib = {};
		}
		Reflect.setField(_lib, param1, param2);
	}
}
