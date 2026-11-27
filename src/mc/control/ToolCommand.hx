package mc.control;

import openfl.errors.Error;
import openfl.events.EventDispatcher;

/**
 * mc.control.ToolCommand —— ToolCommand.as 的签名面 stub（原类 424 loc，
 * 牧场命令片真身待译——issue #88；issue #19 仅作为 Command.toolCommand 的
 * 返回类型被引用，#88 write-tests 按测试引用面补齐签名）。方法签名逐字取自
 * legacy/decompiled/Master2_v_142/scripts/mc/control/ToolCommand.as。
 */
@:keep
class ToolCommand extends EventDispatcher {
	public function new() {
		super();
	}

	// ToolCommand.as:122（setWhistle(param1:Object)——param1 原样转发）
	public function setWhistle(param1:Dynamic):Void {
		throw new Error("not implemented");
	}

	// ToolCommand.as:127（setUpUrl(param1:String)）
	public function setUpUrl(param1:String):Void {
		throw new Error("not implemented");
	}

	// ToolCommand.as:182（getWhistle()）
	public function getWhistle():Void {
		throw new Error("not implemented");
	}

	// ToolCommand.as:243（checkSameDay(param1:Date, param2:Date):Boolean）
	public function checkSameDay(param1:Date, param2:Date):Bool {
		throw new Error("not implemented");
	}
}
