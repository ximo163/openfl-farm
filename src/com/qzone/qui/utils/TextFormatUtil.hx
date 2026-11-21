package com.qzone.qui.utils;

import openfl.text.TextFormat;

/**
 * com.qzone.qui.utils.TextFormatUtil —— TextFormatUtil.as 逐句对应（issue #18
 * qui 收尾：工具片）。TextFormat 深拷贝。
 * PORT-NOTE(clone)：原版 registerClassAlias("flash.text.TextFormat") +
 * ByteArray.writeObject/readObject 的 AMF 往返——全库唯一注册过的别名，正为
 * 这里保 TextFormat 类型（ObjectUtil.clone 的无别名往返会退化匿名对象）。
 * openfl 侧改等价反射逐字段复制进 new TextFormat()：类型保留、字段值逐项
 * 相等，TextFormat 是纯数据类无嵌套引用，深浅拷同义。
 */
class TextFormatUtil {
	public function new() {}

	// TextFormatUtil.as:11-21
	public static function clone(param1:TextFormat):TextFormat {
		var _loc2_:TextFormat = new TextFormat();
		for (_loc3_ in Reflect.fields(param1)) {
			Reflect.setField(_loc2_, _loc3_, Reflect.field(param1, _loc3_));
		}
		return _loc2_;
	}
}
