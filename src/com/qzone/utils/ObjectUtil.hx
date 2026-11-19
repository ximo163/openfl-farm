package com.qzone.utils;

/**
 * com.qzone.utils.ObjectUtil —— V3b 顺手翻（issue #8 闭包，ObjectUtil.as
 * 22 loc ≤ 100；Player.clone :157 与 BackgroundModel.changeDecor 用 clone 深拷贝）。
 * legacy/decompiled/main3_v_221/scripts/com/qzone/utils/ObjectUtil.as 逐句对应。
 */
@:keep
class ObjectUtil {
	public function new() {}

	// ObjectUtil.as:13-19
	// PORT-NOTE(clone)：原版走 ByteArray.writeObject/readObject 的 AMF 往返深
	// 拷贝，openfl 的 ByteArray 无 AMF 实现，改反射递归复制。AMF3 对未注册
	// registerClassAlias 的类实例往返后退化成匿名对象——全库只给 TextFormat
	// 注册过别名（TextFormatUtil.as:17），HealthMode 没有——所以类型化实例也
	// 克隆成匿名结构，两侧 `as HealthMode` 同样得 null（Player.clone 依赖这
	// 一点，Player.as:157）。装饰槽匿名结构、数组、Date（AMF 有专门类型）原
	// 样深拷。显示对象（AMF 里本就抛错）不在克隆面内。
	public static function clone(param1:Dynamic):Dynamic {
		return cloneValue(param1);
	}

	// AMF 往返的等价递归体（见上 PORT-NOTE）
	private static function cloneValue(v:Dynamic):Dynamic {
		if (v == null) {
			return null;
		}
		if (Std.isOfType(v, Bool) || Std.isOfType(v, Int) || Std.isOfType(v, Float) || Std.isOfType(v, String)) {
			return v;
		}
		if (Std.isOfType(v, Array)) {
			var arr:Array<Dynamic> = [];
			for (item in (cast(v, Array<Dynamic>))) {
				arr.push(cloneValue(item));
			}
			return arr;
		}
		if (Std.isOfType(v, Date)) {
			return Date.fromTime(v.getTime());
		}
		if (Reflect.isObject(v)) {
			// 类实例与匿名结构同途：AMF 对未注册别名的实例一律退化成匿名
			// 对象（见上 PORT-NOTE），不做类型重建
			var o:Dynamic = {};
			for (f in Reflect.fields(v)) {
				Reflect.setField(o, f, cloneValue(Reflect.field(v, f)));
			}
			return o;
		}
		return v;
	}
}
