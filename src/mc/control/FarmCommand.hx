package mc.control;

import openfl.errors.Error;
import openfl.events.EventDispatcher;

/**
 * mc.control.FarmCommand —— FarmCommand.as 的签名面 stub（原类 1469 loc，
 * 牧场命令片真身待译——issue #88；issue #19 仅作为 Command.farmCommand 的
 * 返回类型被引用，#88 write-tests 按测试引用面补齐签名）。方法签名逐字取自
 * legacy/decompiled/Master2_v_142/scripts/mc/control/FarmCommand.as。
 */
@:keep
class FarmCommand extends EventDispatcher {
	// FarmCommand.as:45（isShouhuo 公共字段——getCropStatus 复位面）
	public var isShouhuo:Bool = false;

	// FarmCommand.as（requestTime 私有计费表——requestNum 的累积状态，
	// 测试经 @:access 复位钉字面量 "type" 键 bug 的两态）
	private var requestTime:Dynamic;

	public function new() {
		super();
	}

	// FarmCommand.as:173（playShouHuoAnimation 只读 getter）
	public var playShouHuoAnimation(get, never):Bool;

	private function get_playShouHuoAnimation():Bool {
		throw new Error("not implemented");
	}

	// FarmCommand.as:178（addFly(param1:Number)）
	public function addFly(param1:Float):Void {
		throw new Error("not implemented");
	}

	// FarmCommand.as:189（useTools(param1:Number, param2:Object)）
	public function useTools(param1:Float, param2:Dynamic):Void {
		throw new Error("not implemented");
	}

	// FarmCommand.as:278（reclaim(param1:Object)）
	public function reclaim(param1:Dynamic):Void {
		throw new Error("not implemented");
	}

	// FarmCommand.as:535（addFood(param1:int, param2:Number = 0)）
	public function addFood(param1:Int, param2:Float = 0):Void {
		throw new Error("not implemented");
	}

	// FarmCommand.as:640（killFly(param1:Number, param2:Number = 1)）
	public function killFly(param1:Float, param2:Float = 1):Void {
		throw new Error("not implemented");
	}

	// FarmCommand.as:661（ShengChan(param1:int)）
	public function ShengChan(param1:Int):Void {
		throw new Error("not implemented");
	}

	// FarmCommand.as:707（addExp(param1:Object)）
	public function addExp(param1:Dynamic):Void {
		throw new Error("not implemented");
	}

	// FarmCommand.as:720（getActivityItems()）
	public function getActivityItems():Void {
		throw new Error("not implemented");
	}

	// FarmCommand.as:945（getUserSeed(param1:Boolean = false)）
	public function getUserSeed(param1:Bool = false):Void {
		throw new Error("not implemented");
	}

	// FarmCommand.as:965（clearBB(param1:Number, param2:Number = 1)）
	public function clearBB(param1:Float, param2:Float = 1):Void {
		throw new Error("not implemented");
	}

	// FarmCommand.as:1017（Theft(param1:int, param2:Boolean = false)）
	public function Theft(param1:Int, param2:Bool = false):Void {
		throw new Error("not implemented");
	}

	// FarmCommand.as:1153（ShouHuo(param1:int, param2:int, param3:Boolean = false)）
	public function ShouHuo(param1:Int, param2:Int, param3:Bool = false):Void {
		throw new Error("not implemented");
	}

	// FarmCommand.as:1463（reclaimPay(param1:Object, param2:Function)）
	public function reclaimPay(param1:Dynamic, param2:Dynamic):Void {
		throw new Error("not implemented");
	}

	// FarmCommand.as:1440（requestNum(param1:String, param2:int):Boolean——
	// private，测试经 @:access 钉「键名恒字面量 type」的原版 bug）
	private function requestNum(param1:String, param2:Int):Bool {
		throw new Error("not implemented");
	}
}
