package mx.utils;

import mx.core.IRepeaterClient;
import openfl.display.DisplayObject;

// mx.utils.NameUtil —— NameUtil.as 逐句对应（issue #86 牧场库底座，Flex 核心片）。
// 显示对象命名工具：createUniqueName 给嵌入资产实例起唯一名，displayObjectToString
// 拼 parent 链路径（toString 用）。
// 原版 VERSION 带 mx_internal namespace 修饰（包内可见），平铺成 public。
// PORT-NOTE: flash.utils.getQualifiedClassName 返回 "包::类名" 形式；Haxe 的
// Type.getClassName 返回 "包.类名"（点形式）——这里把最后一个点改回 "::" 拼出
// AS3 同款限定名，下游 indexOf("::")/substr 逻辑逐字保留。
@:keep
class NameUtil {
	// NameUtil.as:13（mx_internal static const）
	public static final VERSION:String = "3.2.0.3958";

	// NameUtil.as:15
	private static var counter:Int = 0;

	// NameUtil.as:17-20
	public function new() {}

	// NameUtil.as:22-55
	public static function displayObjectToString(param1:DisplayObject):String {
		var result:String = null;
		var o:DisplayObject = null;
		var s:String = null;
		var indices:Array<Dynamic> = null;
		var displayObject:DisplayObject = param1;
		try {
			o = displayObject;
			while (o != null) {
				if (o.parent != null && o.stage != null && o.parent == o.stage) {
					break;
				}
				s = o.name;
				if (Std.isOfType(o, IRepeaterClient)) {
					indices = cast(o, IRepeaterClient).get_instanceIndices();
					if (indices != null) {
						s += "[" + indices.join("][") + "]";
					}
				}
				result = result == null ? s : s + "." + result;
				o = o.parent;
			}
		} catch (e:Dynamic) {
			// NameUtil.as:51-53：catch(e:SecurityError)——openfl 无 SecurityError
			// 类型层级，Dynamic 捕获等价（原版只吞 SecurityError，其余异常
			// 同样不该漏出 toString 链；PORT-NOTE: 捕获面变宽）
		}
		return result;
	}

	// NameUtil.as:57-75
	public static function createUniqueName(param1:Dynamic):String {
		if (param1 == null) {
			return null;
		}
		var _loc2_:String = qualifiedClassName(param1);
		var _loc3_:Int = _loc2_.indexOf("::");
		if (_loc3_ != -1) {
			_loc2_ = _loc2_.substr(_loc3_ + 2);
		}
		var _loc4_:Int = _loc2_.charCodeAt(_loc2_.length - 1);
		if (_loc4_ >= 48 && _loc4_ <= 57) {
			_loc2_ += "_";
		}
		return _loc2_ + counter++;
	}

	// PORT-NOTE: flash.utils.getQualifiedClassName 的等价物（见头注）——
	// "包.类名" 的最末点改 "::"；无包类（字符串/内置类型）原样。
	private static function qualifiedClassName(param1:Dynamic):String {
		var cls = Type.getClass(param1);
		if (cls == null) {
			// AS3 getQualifiedClassName 对非类实例（int/Number/String）返回
			// 内置类型名；Type.getClass 对它们返回 null，退化到值类型名
			if (Std.isOfType(param1, String)) {
				return "String";
			}
			if (Std.isOfType(param1, Int) || Std.isOfType(param1, Float)) {
				return "Number";
			}
			if (Std.isOfType(param1, Bool)) {
				return "Boolean";
			}
			return "Object";
		}
		var name:String = Type.getClassName(cls);
		var dot:Int = name.lastIndexOf(".");
		if (dot != -1) {
			name = name.substr(0, dot) + "::" + name.substr(dot + 1);
		}
		return name;
	}
}
