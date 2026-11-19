package common.view.window;

import common.view.window.BaseWindow;
import interfaces.IMsgCenter;

/**
 * common.view.window.WindowControl —— V3b/V3c 模块翻译，闭包 stub（issue #7）。
 * 窗口控件（注册表 + open/close 派发 WindowEvent）属于通用视图的窗口片；
 * 这里只保公共 API 形态（WindowControl.as:13-81 的签名）让启动链编译，
 * 原版行为（弹窗/模态）随窗口片接入。
 */
@:keep
class WindowControl {
	// WindowControl.as:8
	private var m_libs:Dynamic;

	// WindowControl.as:13-17
	public function new(param1:IMsgCenter) {
		this.m_libs = {};
		this.m_msgCenter = param1;
	}

	private var m_msgCenter:IMsgCenter;

	// WindowControl.as:19-22
	public function getMsgCenter():IMsgCenter {
		return this.m_msgCenter;
	}

	// WindowControl.as:24-33（open：弹已建好的窗，窗口片翻译）
	public function open(param1:BaseWindow):Void {}

	// WindowControl.as:35-42（getClass：注册表查类）
	public function getClass(param1:String):Class<Dynamic> {
		return Reflect.field(this.m_libs, param1);
	}

	// WindowControl.as:44-54（openForName：按名建窗并弹，窗口片翻译）
	public function openForName(param1:String, param2:Dynamic = null):Void {}

	// WindowControl.as:56-63（register：窗口名 → 类）
	public function register(param1:String, param2:Class<Dynamic>):Void {
		Reflect.setField(this.m_libs, param1, param2);
	}

	// WindowControl.as:65-74（closeForName：按名关窗，窗口片翻译）
	public function closeForName(param1:String):Void {}

	// WindowControl.as:76-81（close：关窗，窗口片翻译）
	public function close(param1:BaseWindow):Void {}
}
