package mc.control;

import openfl.errors.Error;
import openfl.events.EventDispatcher;
import openfl.events.IEventDispatcher;

/**
 * mc.control.ModuleManager —— ModuleManager.as 的签名面 stub（原类
 * 159 loc 含文件内 MoudeLoader 助手类，牧场命令片真身待译——issue #88
 * write-tests 按测试引用面补落）。签名逐字取自
 * legacy/decompiled/Master2_v_142/scripts/mc/control/ModuleManager.as。
 */
@:keep
class ModuleManager extends EventDispatcher {
	// ModuleManager.as:15-17（私有静态——_xml 是 INI data 的一次性缓存，
	// 测试经 @:access 复位）
	private static var _npcList:Dynamic;

	private static var _xml:Dynamic;

	// ModuleManager.as:19-23（ctor(param1:IEventDispatcher = null)）
	public function new(param1:IEventDispatcher = null) {
		super(param1);
	}

	// ModuleManager.as:25（checkSubModule()——**静态**）
	public static function checkSubModule():Void {
		throw new Error("not implemented");
	}
}
