package common.view.window;

import com.qzone.qui.controls.Button;
import common.view.window.BaseWindow;
import interfaces.IMsgCenter;
import openfl.display.Sprite;
import openfl.events.MouseEvent;
import openfl.text.TextField;

/**
 * common.view.window.ConfirmWindow —— V3b/V3c 模块翻译，闭包 stub（issue #7）。
 * 确认框（ConfirmWindow.as，300 loc，属 farm-basic 通用窗口片）；FarmStage 建
 * 层时按 Consts 注册进控件表，本片只保类形态（@:keep 防 dce，供 register/
 * Type.resolveClass 拿到类引用）。
 * issue #21（tasks）把 protected 成员面补齐：子类 WelcomeTaskWindow/
 * TaskOverWindow 覆写 init/setSize/setData 时直接读写这些字段、按钮 CLICK
 * 挂 confirmButtonClick/cancelButtonClick；方法体与构造器常量留给所属窗口片
 * （按钮点击行为经 super.close()/_confirmFn() 才生效，缺位时点击为 no-op，
 * 不炸）。RedUpWindow（同族子类）翻译时以 ConfirmWindow.as 为准整类替换。
 */
@:keep
class ConfirmWindow extends BaseWindow {
	// ConfirmWindow.as:16（protected → Haxe private，子类可见）
	private var _confirmButton:Button;

	// ConfirmWindow.as:18
	private var _confirmIcon:Sprite;

	// ConfirmWindow.as:20
	private var _confirmEnable:Bool;

	// ConfirmWindow.as:22
	private var _errorText:TextField;

	// ConfirmWindow.as:24（Function → Dynamic）
	private var _confirmFn:Dynamic;

	// ConfirmWindow.as:26
	private var _alertText:TextField;

	// ConfirmWindow.as:28
	private var _cancelButton:Button;

	// ConfirmWindow.as:30
	private var _hideIcon:Bool;

	public function new(param1:IMsgCenter = null) {
		super(param1);
	}

	// ConfirmWindow.as:184-190（子类按钮 CLICK 监听挂它；体留给窗口片）
	private function confirmButtonClick(param1:MouseEvent = null):Void {}

	// ConfirmWindow.as:202-205（体留给窗口片）
	private function cancelButtonClick(param1:MouseEvent = null):Void {}
}
