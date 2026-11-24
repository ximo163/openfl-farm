package framework.layers;

import com.qzone.qui.managers.PopUpManager;
import common.Consts;
import common.misc.Utils;
import common.view.window.BaseWindow;
import common.view.window.WindowControl;
import events.CommonEvent;
import events.CursorEvent;
import events.WindowEvent;
import framework.base.BaseLayer;
import openfl.errors.ArgumentError;
import openfl.events.MouseEvent;

/**
 * framework.layers.WindowLayer —— WindowLayer.as 逐句对应（issue #41 替换
 * #7 的闭包 stub）。窗口层：监听 WindowEvent OPEN/CLOSE 与 DIY 预览进出，
 * 经 WindowControl 的注册表反射建窗、PopUpManager 挂载；shop/warehouse/
 * profile 三个模块窗不在此建（模块片自管），onWindowOpen 直抛。
 */
@:keep
class WindowLayer extends BaseLayer {
	// WindowLayer.as:18
	private var m_windowCtrl:WindowControl;

	// WindowLayer.as:20（AS3 Dictionary 弱键，此处字符串键对象等价）
	private var m_winInstances:Dynamic;

	// WindowLayer.as:22-33
	public function new(param1:WindowControl) {
		if (param1 != null) {
			super(param1.getMsgCenter());
			this.m_windowCtrl = param1;
			this.m_winInstances = {};
			this.name = Consts.LAYER_WINDOW;
			return;
		}
		throw new ArgumentError("Null parameter");
	}

	// WindowLayer.as:35-57
	private function openWindowForName(param1:String, param2:Dynamic):Void {
		if (param1 == "") {
			return;
		}
		var _loc3_:BaseWindow = Reflect.field(this.m_winInstances, param1);
		if (_loc3_ == null) {
			_loc3_ = this.createWindow(param1);
			if (_loc3_ == null) {
				return;
			}
			this.openWindow(_loc3_);
			_loc3_.data = param2;
		} else {
			_loc3_.data = param2;
			this.openWindow(_loc3_);
		}
	}

	// WindowLayer.as:59-65
	private function onEnterPreviewDIY(param1:CommonEvent):Void {
		var _loc2_:BaseWindow = Std.isOfType(Reflect.field(this.m_winInstances, Consts.WINDOW_NAME_BUYDIY),
			BaseWindow) ? cast(Reflect.field(this.m_winInstances, Consts.WINDOW_NAME_BUYDIY), BaseWindow) : null;
		PopUpManager.hidePopUp(_loc2_);
		_loc2_ = Std.isOfType(Reflect.field(this.m_winInstances, Consts.WINDOW_NAME_SHOP),
			BaseWindow) ? cast(Reflect.field(this.m_winInstances, Consts.WINDOW_NAME_SHOP), BaseWindow) : null;
		PopUpManager.hidePopUp(_loc2_);
	}

	// WindowLayer.as:67-78
	private function onWindowClose(param1:WindowEvent):Void {
		var _loc2_:BaseWindow = param1.window;
		if (_loc2_ == null && param1.windowName != null && param1.windowName != "") {
			_loc2_ = Std.isOfType(Reflect.field(this.m_winInstances, param1.windowName),
				BaseWindow) ? cast(Reflect.field(this.m_winInstances, param1.windowName), BaseWindow) : null;
		}
		if (_loc2_ != null) {
			PopUpManager.removePopUp(_loc2_);
		}
	}

	// WindowLayer.as:80-97。`new _loc3_(m_msgCenter) as BaseWindow` →
	// Type.createInstance + as 检查（RSLManager/Utils 同款）
	private function createWindow(param1:String):BaseWindow {
		if (param1 == "") {
			return null;
		}
		if (this.m_windowCtrl == null) {
			return null;
		}
		var _loc2_:BaseWindow = null;
		var _loc3_:Class<Dynamic> = this.m_windowCtrl.getClass(param1);
		if (_loc3_ == null) {
			return null;
		}
		var _loc4_:Dynamic = Type.createInstance(_loc3_, [m_msgCenter]);
		return Std.isOfType(_loc4_, BaseWindow) ? cast(_loc4_, BaseWindow) : null;
	}

	// WindowLayer.as:99-110
	override private function init():Void {
		super.init();
		if (Utils.isSafariOnMac() == true) {
			addEventListener(MouseEvent.ROLL_OVER, this.onRollOver, false, 0, true);
		}
		m_msgCenter.addEventListener(WindowEvent.OPEN, this.onWindowOpen, false, 0, true);
		m_msgCenter.addEventListener(WindowEvent.CLOSE, this.onWindowClose, false, 0, true);
		m_msgCenter.addEventListener(Consts.MSG_ENTER_PREVIEW, this.onEnterPreviewDIY, false, 0, true);
		m_msgCenter.addEventListener(Consts.MSG_EXIT_PREVIEW, this.onExitPreviewDIY, false, 0, true);
	}

	// WindowLayer.as:112-128
	private function openWindow(param1:BaseWindow):Void {
		if (param1 == null) {
			return;
		}
		PopUpManager.addPopUp(param1, param1.mode);
		if (param1.windowName == Consts.WINDOW_NAME_ALERT || param1.windowName == Consts.WINDOW_NAME_CONFIRM) {
			return;
		}
		if (param1.windowName == null || param1.windowName == "") {
			return;
		}
		Reflect.setField(this.m_winInstances, param1.windowName, param1);
	}

	// WindowLayer.as:130-135
	private function onRollOver(param1:MouseEvent):Void {
		var _loc2_:CursorEvent = new CursorEvent(CursorEvent.SWITCH_CURSOR);
		_loc2_.cursorName = Consts.CURSOR_SYSTEM;
		m_msgCenter.dispatchEvent(_loc2_);
	}

	// WindowLayer.as:137-143
	private function onExitPreviewDIY(param1:CommonEvent):Void {
		var _loc2_:BaseWindow = Std.isOfType(Reflect.field(this.m_winInstances, Consts.WINDOW_NAME_SHOP),
			BaseWindow) ? cast(Reflect.field(this.m_winInstances, Consts.WINDOW_NAME_SHOP), BaseWindow) : null;
		PopUpManager.showPopUp(_loc2_);
		_loc2_ = Std.isOfType(Reflect.field(this.m_winInstances, Consts.WINDOW_NAME_BUYDIY),
			BaseWindow) ? cast(Reflect.field(this.m_winInstances, Consts.WINDOW_NAME_BUYDIY), BaseWindow) : null;
		PopUpManager.showPopUp(_loc2_);
	}

	// WindowLayer.as:145-161。`param1["windowName"] as String` /
	// `param1["window"] != undefined`：属性 getter 取值，undefined 门即 null 门
	private function onWindowOpen(param1:WindowEvent):Void {
		var _loc2_:String = param1.windowName;
		var _loc3_:Dynamic = param1.windowArgument;
		if (_loc2_ == Consts.WINDOW_NAME_SHOP || _loc2_ == Consts.WINDOW_NAME_WAREHOUSE || _loc2_ == Consts.WINDOW_NAME_PROFILE) {
			throw new ArgumentError("Window can not be initialized.");
		}
		if (param1.window != null) {
			this.openWindow(param1.window);
		} else {
			this.openWindowForName(_loc2_, _loc3_);
		}
	}
}
