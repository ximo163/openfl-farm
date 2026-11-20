package common.view;

import openfl.display.DisplayObject;
import openfl.display.Sprite;
import openfl.errors.Error;

/**
 * common.view.MaterialProxy —— issue #9 write-tests 签名 stub
 * （MaterialProxy.as 536 loc，V3c 片按飘字/头像消费面整类翻译：类型串 →
 * 素材位图）。尺寸常量取值照抄；字段名照抄供 @:access 测试断言
 * （childObjcet 是原版拼写， :40）；方法签名照抄、体 throw not implemented。
 */
@:keep
class MaterialProxy extends Sprite {
	// MaterialProxy.as:16-20
	public static final BIG:String = "big";
	public static final SMALL:String = "small";
	public static final CARDSGAME:String = "CardsGame";

	// MaterialProxy.as:27-43
	private var currentType:String;
	private var _size:String;
	private var _enable:Bool;
	private var _loaded:Bool;
	private var itemLoading:Sprite;
	private var _h:Int;
	private var currentId:Int = 0;
	private var _w:Int;
	private var childObjcet:DisplayObject;

	// MaterialProxy.as:45-66（small→60、CardsGame→80、其余 120）
	public function new(param1:String = "small") {
		super();
	}

	// MaterialProxy.as:101-104
	public var loaded(get, never):Bool;

	private function get_loaded():Bool {
		throw new Error("not implemented");
	}

	// MaterialProxy.as:106-220（同 (type,id,enable) 早退；"6" 金币 /
	// "7" 经验内置位图，"5" 只记不载）
	public function setContent(param1:String, param2:Int, param3:Bool = true):Void {
		throw new Error("not implemented");
	}

	// MaterialProxy.as:240-243
	public var size(get, never):String;

	private function get_size():String {
		throw new Error("not implemented");
	}
}
