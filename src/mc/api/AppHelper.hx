package mc.api;

import mc.control.Command;
import mc.control.MainCommand;
import mc.control.ViewControl;
import mc.fBridge.EventRecorder;
import mc.fBridge.FRequest;
import mc.view.main.tip.TipControl;
import openfl.display.DisplayObject;
import openfl.display.DisplayObjectContainer;
import openfl.events.IEventDispatcher;
import openfl.filters.ColorMatrixFilter;
import openfl.utils.Dictionary;
import shim.As3;

/**
 * mc.api.AppHelper —— AppHelper.as 逐句对应（issue #87「API」片）。IAPIHelper
 * 实现：弹窗经 ViewControl.windowsLayer 挂/摘 + centerPopUp 居中，鼠标提示
 * 走 TipControl，alert 转 mainCommand.alertWindow，sendRequest 按 _cmds
 * 注册的命令串走 FRequest.postRequest，getDisableFilter 懒建灰度
 * ColorMatrixFilter。
 * legacy/decompiled/Master2_v_142/scripts/mc/api/AppHelper.as。
 *
 * PORT-NOTE(跨片依赖)：mc.fBridge.EventRecorder.recordMultiValueInCode
 * （mcloader 外部依赖，spec pasture.json notes 外部依赖清单）在本片开工时
 * stub 无签名面——按原样直引，所属片充真身后编译链闭合（本轮并行片既定
 * 做法）。
 */
@:keep
class AppHelper implements IAPIHelper {
	// AppHelper.as:18-24（_mainCommand/_fr 原文即字段初始化器直取单例。
	// PORT-NOTE：AS3 protected → private，DecorRenderItem.hx 同款先例）
	private var _disableFilter:Array<Dynamic>;
	private var _mainCommand:MainCommand = Command.getInstance().mainCommand;
	private var _fr:FRequest = FRequest.getInstance();
	private var _cmds:Dictionary<UInt, String> = new Dictionary<UInt, String>();

	// AppHelper.as:26-29
	public function new() {}

	// AppHelper.as:31-41（舞台宽高减弹窗宽高取半，y 负归零；int 截断照
	// 原文——width/height 是 Number，int 局部隐式截断走 As3.intOf）
	private static function centerPopUp(param1:DisplayObject, param2:DisplayObjectContainer):Void {
		var _loc3_:Int = As3.intOf(param2.stage.stageWidth / 2 - param1.width / 2);
		var _loc4_:Int = As3.intOf(param2.stage.stageHeight / 2 - param1.height / 2);
		if (_loc4_ < 0) {
			_loc4_ = 0;
		}
		param1.x = _loc3_;
		param1.y = _loc4_;
	}

	// AppHelper.as:43-50（懒建单例灰度矩阵，逐字 20 元）
	public function getDisableFilter():Array<Dynamic> {
		if (this._disableFilter == null) {
			this._disableFilter = [
				new ColorMatrixFilter([
					0.3, 0.6, 0.082, 0, 0, 0.3, 0.6, 0.082, 0, 0, 0.3, 0.6, 0.082, 0, 0, 0, 0, 0, 1, 0
				])
			];
		}
		return this._disableFilter;
	}

	// AppHelper.as:52-59
	public function showPopUp(param1:DisplayObjectContainer):Void {
		if (As3.truthy(param1)) {
			ViewControl.getInstance().windowsLayer.addChild(param1);
			centerPopUp(param1, ViewControl.getInstance().windowsLayer);
		}
	}

	// AppHelper.as:61-64
	public function hideMouseTip():Void {
		TipControl.hide();
	}

	// AppHelper.as:66-69
	public function reportReturnCode(param1:String, param2:String):Void {
		EventRecorder.recordMultiValueInCode(param1, param2);
	}

	// AppHelper.as:71-74
	public function alert(param1:String, param2:String):Void {
		this._mainCommand.alertWindow(param1, param2);
	}

	// AppHelper.as:76-80（恒返 true——postRequest 内部网络失败不归本方法管；
	// _cmds 键缺失时 url 为 null 照返 true）
	public function sendRequest(param1:UInt, param2:Dynamic, param3:Dynamic):Bool {
		this._fr.postRequest(this._cmds[param1], param2, param3);
		return true;
	}

	// AppHelper.as:82-91
	public function hidePopUp(param1:DisplayObjectContainer):Void {
		if (As3.truthy(param1)) {
			if (As3.truthy(param1.parent)) {
				param1.parent.removeChild(param1);
			}
		}
	}

	// AppHelper.as:93-96
	public function registerNetCommand(param1:UInt, param2:String):Void {
		this._cmds[param1] = param2;
	}

	// AppHelper.as:98-101
	public var messageCenter(get, never):IEventDispatcher;

	private function get_messageCenter():IEventDispatcher {
		return ViewControl.getInstance();
	}

	// AppHelper.as:103-106
	public function popMouseTip(param1:String):Void {
		TipControl.show("MouseTip", param1);
	}
}
