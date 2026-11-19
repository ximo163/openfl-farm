package common.view.cursor;

import interfaces.IMsgCenter;

/**
 * common.view.cursor.CursorControl —— V3b/V3c 模块翻译，闭包 stub（issue #7）。
 * 光标控件（注册表 + setCursor/useSystem 切换）属于通用视图的光标片；
 * 这里只保公共 API 形态（CursorControl.as:20-88 的签名）让启动链编译：
 * FarmStage 注册 17 个光标类、FarmLayer/FarmStage/FarmApplication 走
 * name/setCursor/useSystem，原版行为（换光标位图）随光标片接入。
 */
@:keep
class CursorControl {
	// CursorControl.as:15
	private var m_libs:Dynamic;

	// CursorControl.as:17
	private var m_name:String = "";

	// CursorControl.as:20-25
	public function new(param1:IMsgCenter) {
		this.m_libs = {};
	}

	// CursorControl.as:27-30
	public function getMsgCenter():IMsgCenter {
		return this.m_msgCenter;
	}

	private var m_msgCenter:IMsgCenter;

	// CursorControl.as:32-43（getClass：注册表查类）
	public function getClass(param1:String):Class<Dynamic> {
		return Reflect.field(this.m_libs, param1);
	}

	// CursorControl.as:45-52（register：光标名 → 类）
	public function register(param1:String, param2:Class<Dynamic>):Void {
		Reflect.setField(this.m_libs, param1, param2);
	}

	// CursorControl.as:59-67
	public var name(get, set):String;

	private function get_name():String {
		return this.m_name;
	}

	private function set_name(param1:String):String {
		this.m_name = param1;
		return param1;
	}

	// CursorControl.as:54-57/:69-72
	public var cursorArgument(get, set):String;

	private var m_cursorArgument:String = "";

	private function get_cursorArgument():String {
		return this.m_cursorArgument;
	}

	private function set_cursorArgument(param1:String):String {
		this.m_cursorArgument = param1;
		return param1;
	}

	// CursorControl.as:74-86（useSystem：系统光标开关，光标片翻译）
	public function useSystem(param1:Bool = true):Void {}

	// CursorControl.as:88-（setCursor：换光标，光标片翻译；这里只记名）
	public function setCursor(param1:String, param2:String = ""):Void {
		this.m_name = param1;
		this.m_cursorArgument = param2;
	}
}
