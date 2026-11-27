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

	// —— issue #88 write-tests 增补签名面（体随牧场命令片充真身）——

	// MainCommand.as:316（buySeed(param1:int, param2:int, param3:Boolean)）
	public function buySeed(param1:Int, param2:Int, param3:Bool):Void {
		throw new openfl.errors.Error("not implemented");
	}

	// MainCommand.as:615（taskComp(param1:String):Boolean）
	public function taskComp(param1:String):Bool {
		throw new openfl.errors.Error("not implemented");
	}

	// MainCommand.as:601（getUserCub()）
	public function getUserCub():Void {
		throw new openfl.errors.Error("not implemented");
	}

	// MainCommand.as:694（buyDiy 8 参——skinBool/msgBool 是 String）
	public function buyDiy(param1:Int, param2:String, param3:String, param4:Bool = false, param5:Int = 0, param6:String = "", param7:Int = 0,
			param8:Bool = false):Void {
		throw new openfl.errors.Error("not implemented");
	}

	// MainCommand.as:842（sale(param1:int, param2:int, param3:Function = null)）
	public function sale(param1:Int, param2:Int, param3:Dynamic = null):Void {
		throw new openfl.errors.Error("not implemented");
	}

	// MainCommand.as:909（diyRenew(param1:int)）
	public function diyRenew(param1:Int):Void {
		throw new openfl.errors.Error("not implemented");
	}

	// MainCommand.as:915（lockCrop(param1:String, param2:String)）
	public function lockCrop(param1:String, param2:String):Void {
		throw new openfl.errors.Error("not implemented");
	}

	// MainCommand.as:1669（getCropStatus(param1:String = "0", param2:Boolean = true)）
	public function getCropStatus(param1:String = "0", param2:Bool = true):Void {
		throw new openfl.errors.Error("not implemented");
	}

	// MainCommand.as:1760（addMoney(param1:Object)）
	public function addMoney(param1:Dynamic):Void {
		throw new openfl.errors.Error("not implemented");
	}

	// MainCommand.as:1769（getCdKey(param1:Object)——参数作请求体原样发）
	public function getCdKey(param1:Dynamic):Void {
		throw new openfl.errors.Error("not implemented");
	}

	// MainCommand.as:2285（friendNextPage(param1:String = "")）
	public function friendNextPage(param1:String = ""):Void {
		throw new openfl.errors.Error("not implemented");
	}

	// MainCommand.as:2720（saleAllMaterial(param1:Array)）
	public function saleAllMaterial(param1:Array<Dynamic>):Void {
		throw new openfl.errors.Error("not implemented");
	}

	// MainCommand.as:2790（addFB(param1:Object)）
	public function addFB(param1:Dynamic):Void {
		throw new openfl.errors.Error("not implemented");
	}

	// MainCommand.as:2809（checkErrorReturn(param1:Object):Boolean）
	public function checkErrorReturn(param1:Dynamic):Bool {
		throw new openfl.errors.Error("not implemented");
	}

	// MainCommand.as:2911（addReward(param1:Array)）
	public function addReward(param1:Array<Dynamic>):Void {
		throw new openfl.errors.Error("not implemented");
	}

	// MainCommand.as:2944（buyTool 7 参）
	public function buyTool(param1:Int, param2:Int, param3:Int, param4:Bool = false, param5:String = "", param6:Int = 0, param7:Bool = false):Void {
		throw new openfl.errors.Error("not implemented");
	}

	// MainCommand.as:3344（setParade()——无参同步，读 mainData.userFarmData）
	public function setParade():Void {
		throw new openfl.errors.Error("not implemented");
	}

	// MainCommand.as:3496（floatWindow(param1:String, param2:String = "info")）
	public function floatWindow(param1:String, param2:String = "info"):Void {
		throw new openfl.errors.Error("not implemented");
	}

	// MainCommand.as:3570（buyThingByCFT(param1:int, param2:String, param3:int, param4:int = 1)）
	public function buyThingByCFT(param1:Int, param2:String, param3:Int, param4:Int = 1):Void {
		throw new openfl.errors.Error("not implemented");
	}

	// MainCommand.as:3585（checkParade(param1:Object):Boolean——入参合成
	// 对象 {animal,parade}）
	public function checkParade(param1:Dynamic):Bool {
		throw new openfl.errors.Error("not implemented");
	}

	// MainCommand.as:3950（addExp(param1:Object)）
	public function addExp(param1:Dynamic):Void {
		throw new openfl.errors.Error("not implemented");
	}

	// MainCommand.as:4274（saleAll()）
	public function saleAll():Void {
		throw new openfl.errors.Error("not implemented");
	}

	// MainCommand.as:4280（buyFoodFn(param1:Object)——**public** 原文如此）
	public function buyFoodFn(param1:Dynamic):Void {
		throw new openfl.errors.Error("not implemented");
	}

	// MainCommand.as:4308（updateTask()）
	public function updateTask():Void {
		throw new openfl.errors.Error("not implemented");
	}

	// MainCommand.as:3163（checkAndReportSteal(param1:Object)——private，
	// 测试经 @:access 钉早退语义）
	private function checkAndReportSteal(param1:Dynamic):Void {
		throw new openfl.errors.Error("not implemented");
	}

	// MainCommand.as:3318（friendSort——private 比较器）
	private function friendSort(param1:Dynamic, param2:Dynamic):Float {
		throw new openfl.errors.Error("not implemented");
	}

	// MainCommand.as:3556（cropSortBycId——private 比较器）
	private function cropSortBycId(param1:Dynamic, param2:Dynamic):Int {
		throw new openfl.errors.Error("not implemented");
	}

	// MainCommand.as:3680（cropSortBylv——private 比较器）
	private function cropSortBylv(param1:Dynamic, param2:Dynamic):Int {
		throw new openfl.errors.Error("not implemented");
	}

	// MainCommand.as:2834（logFn——private，驱动链深埋 getAllInfoFn）
	private function logFn(param1:Dynamic):Void {
		throw new openfl.errors.Error("not implemented");
	}
}
