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
	// 拷贝，openfl 的 ByteArray 无 AMF 实现，改反射递归复制。两个克隆场景只碰
	// 匿名结构（背景装饰槽 {id,type,url}）、数组和实体实例（HealthMode——字段
	// 全是基元），语义等价；AMF 对未注册类别名的实例本就退化为匿名结构，这里
	// 保留类名重建，比原版更保真。显示对象（AMF 里本就抛错）不在克隆面内。
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
			var cls = Type.getClass(v);
			if (cls != null) {
				// 类型化实例：空构造实例 + 字段逐一深拷（HealthMode 形态）
				var inst = Type.createEmptyInstance(cls);
				for (f in Reflect.fields(v)) {
					Reflect.setField(inst, f, cloneValue(Reflect.field(v, f)));
				}
				return inst;
			}
			// 匿名结构（装饰槽 {id,type,url} 形态）
			var o:Dynamic = {};
			for (f in Reflect.fields(v)) {
				Reflect.setField(o, f, cloneValue(Reflect.field(v, f)));
			}
			return o;
		}
		return v;
	}
}
