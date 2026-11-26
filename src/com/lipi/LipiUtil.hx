package com.lipi;

import com.qzone.utils.ObjectUtil;
import openfl.text.TextField;
import openfl.text.TextFieldAutoSize;
import openfl.text.TextFormat;
import openfl.utils.ByteArray;

/**
 * com.lipi.LipiUtil —— LipiUtil.as 逐句对应（issue #19 Master2 闭包顺手译）。
 */
@:keep
class LipiUtil {
	public function new() {}

	// LipiUtil.as:16-19
	public static function randRange(param1:Float, param2:Float):Float {
		return Math.floor(Math.random() * (param2 - param1 + 1)) + param1;
	}

	// LipiUtil.as:21-26
	public static function getStringLength(param1:String):Int {
		var _loc2_:ByteArray = new ByteArray();
		_loc2_.writeUTFBytes(param1);
		return _loc2_.length;
	}

	// LipiUtil.as:28-34
	// PORT-NOTE(clone)：原版走 ByteArray.writeObject/readObject 的 AMF 往返深
	// 拷贝，openfl ByteArray 无 AMF 实现；main3 侧同款已建反射递归等价物
	// （src/com/qzone/utils/ObjectUtil.hx），直接复用。
	public static function clone(param1:Dynamic):Dynamic {
		return ObjectUtil.clone(param1);
	}

	// LipiUtil.as:36-47（方法名 Langth 拼写原版如此）
	public static function getTextLangth(param1:String, param2:TextFormat = null):Float {
		var _loc3_:Float = 0;
		var _loc4_:TextField = new TextField();
		if (param2 != null) {
			_loc4_.defaultTextFormat = param2;
		}
		_loc4_.autoSize = TextFieldAutoSize.LEFT;
		_loc4_.text = param1;
		return _loc4_.width;
	}
}
