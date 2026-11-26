package common;

import openfl.events.TimerEvent;
import openfl.utils.Timer;

/**
 * common.Utils —— Utils.as 逐句对应（issue #86 牧场库底座，工具函数片）。
 * legacy/decompiled/Master2_v_142/scripts/common/Utils.as。
 *
 * PORT-NOTE(setTimeout)：原版闭包用 `arguments.callee` 自摘监听（AS3 的
 * arguments 对象）——Haxe 无 arguments/函数自引用，闭包先赋局部变量再在
 * 体内引用自身（语义等价）。`param1.target` 是 Timer 实例（Event.target
 * 静态 Object——强类型化取 removeEventListener）。
 * PORT-NOTE(objectCopy)：原版走 ByteArray.writeObject/readObject 的 AMF
 * 往返深拷贝，openfl ByteArray 无 AMF 实现；本仓既定等价物是
 * com.qzone.utils.ObjectUtil.clone（反射递归，AMF 退化语义见彼处注释），
 * 复用同通道（LipiUtil.clone 同款先例）。
 */
@:keep
class Utils {
	// Utils.as:9-11
	public function new() {}

	// :13-21（param1 = null 的赋值对外无效应——原版如此，照抄）
	public static function clearTimeout(param1:Timer):Void {
		if (param1 != null) {
			if (param1.running) {
				param1.stop();
			}
			param1 = null;
		}
	}

	// :23-29（AMF 等价物复用，见类头 PORT-NOTE）
	public static function objectCopy(param1:Dynamic):Dynamic {
		return com.qzone.utils.ObjectUtil.clone(param1);
	}

	// :31-46
	public static function setTimeout(param1:Int, param2:Dynamic):Timer {
		var delay:Int = param1;
		var fn:Dynamic = param2;
		var timer:Timer = new Timer(delay, 1);
		var cb:TimerEvent->Void = null;
		cb = function(param1:TimerEvent):Void {
			fn();
			(param1.target : Timer).removeEventListener(TimerEvent.TIMER, cb);
		};
		timer.addEventListener(TimerEvent.TIMER, cb);
		timer.start();
		return timer;
	}
}
