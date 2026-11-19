package common.misc;

import com.qzone.utils.RightMenu;
import common.misc.VersionUtil_versionXml;
import openfl.display.Sprite;
import openfl.utils.ByteArray;
import shim.As3;

// common.misc.VersionUtil —— VersionUtil.as 逐句对应（36 loc ≤ 100，闭包规则
// 整类翻译；构建号菜单串进 Session.m_buildVersion）。
// PORT-NOTE: `new versionXml() as ByteArray`——versionXml 是 Class 引用，
// Type.createInstance 后 cast；`new XML(String)` 在 openfl 没有 String 构造，
// 用 Xml.parse 取文档元素（等价 E4X new XML(text)）。
class VersionUtil {
	// VersionUtil.as:10
	public static var versionString:String;

	// VersionUtil.as:12（static const versionXml:Class = VersionUtil_versionXml）
	private static final versionXml:Class<Dynamic> = VersionUtil_versionXml;

	public function new() {}

	// VersionUtil.as:19-34
	public static function setRightMenu(param1:Sprite, param2:String = "Build @build"):Void {
		var _loc3_:ByteArray = cast Type.createInstance(versionXml, []);
		var _loc4_:Xml = Xml.parse(_loc3_.readUTFBytes(_loc3_.length)).firstElement();
		// `_loc4_.build.@time` → build 元素的 time 属性
		var buildNode:Xml = findChild(_loc4_, "build");
		var _loc5_:Array<Dynamic> = Std.string(buildNode.get("time")).split(" ");
		var _loc6_:String = Std.string(_loc5_[0]).split("-").join("");
		var _loc7_:Float = As3.floatOf(buildNode.get("count"));
		var _loc8_:String = toUpperBase36(Std.int(_loc7_));
		// PORT-NOTE: AS3 String.replace(字符串) 只替换首次出现；默认参数
		// "Build @build" 仅含一个 @build，StringTools.replace 全量替换等价。
		param2 = StringTools.replace(param2, "@build", _loc6_ + "." + _loc8_);
		versionString = param2;
		// PORT-NOTE: openfl 没有 flash.ui.ContextMenu/ContextMenuItem，原版
		// 「确保 contextMenu → hideBuiltInItems → push(菜单项, separatorBefore=
		// false, enabled=false)」的等价展开走 RightMenu.addMenuItem（其内部
		// 同序：ensure menu → param7 时 hideBuiltInItems → push）。右键菜单
		// 载体随 qui 片接入再定（RightMenu stub，见 RightMenu.hx）。
		RightMenu.addMenuItem(param1, param2, null, false, false, true, true);
	}

	private static function findChild(param1:Xml, param2:String):Xml {
		for (child in param1.elements()) {
			if (child.nodeName == param2) {
				return child;
			}
		}
		return null;
	}

	// Number(n).toString(36).toLocaleUpperCase()——Haxe 没有内建 36 进制串，
	// 按位展开后大写（toLocaleUpperCase 对 ASCII 等价 toUpperCase）
	private static function toUpperBase36(param1:Int):String {
		var _loc2_:String = "0123456789abcdefghijklmnopqrstuvwxyz";
		if (param1 == 0) {
			return "0";
		}
		var _loc3_:String = "";
		var _loc4_:Int = param1;
		while (_loc4_ > 0) {
			_loc3_ = _loc2_.charAt(_loc4_ % 36) + _loc3_;
			_loc4_ = Std.int(_loc4_ / 36);
		}
		return _loc3_.toUpperCase();
	}
}
