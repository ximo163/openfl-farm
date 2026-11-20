package common.view.floating;

import common.view.MaterialProxy;
import interfaces.IMsgCenter;
import openfl.errors.Error;
import openfl.text.TextField;

/**
 * common.view.floating.HarvestAnimation —— issue #9 write-tests 签名 stub
 * （HarvestAnimation.as 92 loc，V3c 飘字片整类翻译）。收获飘字：数字 +
 * 产物图。#7 的闭包壳只保类形态，本阶段补齐成员签名；方法体 throw
 * not implemented。字段名照抄供 @:access 测试断言。
 */
@:keep
class HarvestAnimation extends FloatingBase {
	// HarvestAnimation.as:10-18
	private var _materialProxy:MaterialProxy;
	private final easingY:Float = 0.2;
	private var _numText:TextField;
	private var _currentValue:Float;

	// HarvestAnimation.as:20-34（MaterialProxy + "+N" 文本框，均无资源依赖）
	public function new(param1:IMsgCenter) {
		super(param1);
	}

	// HarvestAnimation.as:36-53（text/type/cId 载荷 + ENTER_FRAME 上浮）
	override public function start(param1:Dynamic):Void {
		throw new Error("not implemented");
	}

	// HarvestAnimation.as:55-64（current -= (60-current)*easingY，<0 关）
	private function onTimer(param1:Dynamic):Void {
		throw new Error("not implemented");
	}

	// HarvestAnimation.as:66-74（"" 早退；代理 + cacheAsBitmap）
	public function setContent(param1:String, param2:Int):Void {
		throw new Error("not implemented");
	}

	// HarvestAnimation.as:76-86（裸数字补 "+ " 前缀；文本列固定 x=65）
	public var text(never, set):String;

	private function set_text(param1:String):String {
		throw new Error("not implemented");
	}

	// HarvestAnimation.as:87-92
	override public function end():Void {
		throw new Error("not implemented");
	}
}
