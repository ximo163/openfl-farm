package common.view.floating;

import common.view.MaterialProxy;
import interfaces.IMsgCenter;
import openfl.display.Sprite;
import openfl.errors.Error;
import openfl.text.TextField;

/**
 * common.view.floating.HarvestAnimationPlus —— issue #9 write-tests 签名
 * stub（HarvestAnimationPlus.as 150+ loc，V3c 飘字片整类翻译）。收获加成
 * 飘字：自己农场用 HarvestPlusB 素材，好友侧双列对半。#7 的闭包壳只保类
 * 形态，本阶段补齐成员签名；方法体 throw not implemented。字段名照抄供
 * @:access 测试断言。
 */
@:keep
class HarvestAnimationPlus extends FloatingBase {
	// HarvestAnimationPlus.as:10-32
	private var _isEven:Bool;
	private var _materialProxy:MaterialProxy;
	private var _lock:Bool;
	private final easingY:Float = 0.2;
	private var _currentValue:Float;
	private var _numText1:TextField;
	private var _numText2:TextField;
	private var _numText:TextField;
	private var _materialProxy1:MaterialProxy;
	private var _mc:Sprite;

	// HarvestAnimationPlus.as:34-74（Session.me 分支：自己取 HarvestPlusB
	// 素材，好友侧两个 TextField + MaterialProxy1）
	public function new(param1:IMsgCenter) {
		super(param1);
	}

	// HarvestAnimationPlus.as:76-112（好友侧：偶数对半 "+N"/"+N"、奇数原样）
	public var text(never, set):String;

	private function set_text(param1:String):String {
		throw new Error("not implemented");
	}

	// HarvestAnimationPlus.as:114+（end：摘监听置空）
	override public function end():Void {
		throw new Error("not implemented");
	}
}
