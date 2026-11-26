package mc.control;

import openfl.events.EventDispatcher;

/**
 * mc.control.MainCommand —— MainCommand.as 的签名面 stub（原类 4461 loc，
 * 牧场片真身待译——#pasture；issue #19 只保 profile 窗族调到的方法，均走
 * 未译的 FBridge 网络栈，体空）。方法签名逐字取自
 * legacy/decompiled/Master2_v_142/scripts/mc/control/MainCommand.as。
 */
@:keep
class MainCommand extends EventDispatcher {
	public function new() {
		super();
	}

	// MainCommand.as:3879（getAllInfo(param1:Boolean, param2:int)）
	public function getAllInfo(param1:Bool, param2:Int):Void {}

	// MainCommand.as:595（getHistoryInfo(param1:Function, param2:String)）
	public function getHistoryInfo(param1:Dynamic, param2:String):Void {}

	// MainCommand.as:3842（getCostInfo(param1:Function, param2:Function)）
	public function getCostInfo(param1:Dynamic, param2:Dynamic):Void {}

	// MainCommand.as:867（getFriendList(param1:Boolean=false, param2:Boolean=false)）
	public function getFriendList(param1:Bool = false, param2:Bool = false):Void {}

	// MainCommand.as:3865
	public function clearLog():Void {}

	// MainCommand.as:3099
	public function clearChat():Void {}

	// MainCommand.as:2482（sendChat 5 参，末参默认 ""）
	public function sendChat(param1:String, param2:String, param3:Int, param4:String, param5:String = ""):Void {}

	// MainCommand.as:1158（alertWindow(param1:String, param2:String, param3:Boolean=false)）
	public function alertWindow(param1:String, param2:String, param3:Bool = false):Void {}

	// MainCommand.as:1373（getMarkListFromJs(param1:Function, param2:String="0")）
	public function getMarkListFromJs(param1:Dynamic, param2:String = "0"):Void {}

	// MainCommand.as:3832-3841（showWin(param1:String="cdkey")——issue #87
	// FRequest 应答闭包的 validateCode 分支编译链需要签名；体随牧场片充真身）
	public function showWin(param1:String = "cdkey"):Void {
		throw new openfl.errors.Error("not implemented");
	}

	// MainCommand.as:1517（run()——issue #87 InitLoading.linkClick 的
	// "reload" 分支编译链需要签名；体随牧场片充真身）
	public function run():Void {
		throw new openfl.errors.Error("not implemented");
	}

	// MainCommand.as:1782（register()——issue #87 InitLoading.linkClick
	// 的 "noreg" 分支编译链需要签名；体随牧场片充真身）
	public function register():Void {
		throw new openfl.errors.Error("not implemented");
	}

	// MainCommand.as:3091（userReload()——issue #87 UserChanging.linkClick
	// 编译链需要签名；体随牧场片充真身）
	public function userReload():Void {
		throw new openfl.errors.Error("not implemented");
	}

	// MainCommand.as:581（validateCode(param1:String)——issue #87
	// ValidateCodeWindow.confirmFn 编译链需要签名；体随牧场片充真身）
	public function validateCode(param1:String):Void {
		throw new openfl.errors.Error("not implemented");
	}
}
