package mx.core;

import openfl.display.DisplayObject;
import openfl.display.DisplayObjectContainer;
import openfl.display.IBitmapDrawable;
import openfl.display.LoaderInfo;
import openfl.display.Stage;
import openfl.events.IEventDispatcher;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import openfl.geom.Transform;

// mx.core.IFlexDisplayObject —— IFlexDisplayObject.as 逐句对应（issue #86 牧场
// 库底座，Flex 核心片）。Flex 显示对象接口（BitmapAsset/MovieClipAsset 实现）。
// Haxe 接口属性行转 get_/set_ 访问器签名（ITip 先例）。
// PORT-NOTE: openfl 没有 flash.accessibility.AccessibilityProperties（整个
// accessibility 包未移植，openfl DisplayObject 的同名属性行是注释），
// accessibilityProperties 两个访问器签名落 Dynamic。
interface IFlexDisplayObject extends IBitmapDrawable extends IEventDispatcher {
	// IFlexDisplayObject.as:17
	function get_visible():Bool;

	// IFlexDisplayObject.as:19
	function get_rotation():Float;

	// IFlexDisplayObject.as:21
	function localToGlobal(param1:Point):Point;

	// IFlexDisplayObject.as:23
	function get_name():String;

	// IFlexDisplayObject.as:25
	function set_width(param1:Float):Void;

	// IFlexDisplayObject.as:27
	function get_measuredHeight():Float;

	// IFlexDisplayObject.as:29
	function get_blendMode():String;

	// IFlexDisplayObject.as:31
	function get_scale9Grid():Rectangle;

	// IFlexDisplayObject.as:33
	function set_name(param1:String):Void;

	// IFlexDisplayObject.as:35
	function set_scaleX(param1:Float):Void;

	// IFlexDisplayObject.as:37
	function set_scaleY(param1:Float):Void;

	// IFlexDisplayObject.as:39
	function get_measuredWidth():Float;

	// IFlexDisplayObject.as:41（PORT-NOTE 见头注：AccessibilityProperties → Dynamic）
	function get_accessibilityProperties():Dynamic;

	// IFlexDisplayObject.as:43
	function set_scrollRect(param1:Rectangle):Void;

	// IFlexDisplayObject.as:45
	function get_cacheAsBitmap():Bool;

	// IFlexDisplayObject.as:47
	function globalToLocal(param1:Point):Point;

	// IFlexDisplayObject.as:49
	function get_height():Float;

	// IFlexDisplayObject.as:51
	function set_blendMode(param1:String):Void;

	// IFlexDisplayObject.as:53
	function get_parent():DisplayObjectContainer;

	// IFlexDisplayObject.as:55
	function getBounds(param1:DisplayObject):Rectangle;

	// IFlexDisplayObject.as:57
	function get_opaqueBackground():Dynamic;

	// IFlexDisplayObject.as:59
	function set_scale9Grid(param1:Rectangle):Void;

	// IFlexDisplayObject.as:61
	function setActualSize(param1:Float, param2:Float):Void;

	// IFlexDisplayObject.as:63
	function set_alpha(param1:Float):Void;

	// IFlexDisplayObject.as:65（PORT-NOTE 见头注）
	function set_accessibilityProperties(param1:Dynamic):Void;

	// IFlexDisplayObject.as:67
	function get_width():Float;

	// IFlexDisplayObject.as:69
	function hitTestPoint(param1:Float, param2:Float, param3:Bool = false):Bool;

	// IFlexDisplayObject.as:71
	function set_cacheAsBitmap(param1:Bool):Void;

	// IFlexDisplayObject.as:73
	function get_scaleX():Float;

	// IFlexDisplayObject.as:75
	function get_scaleY():Float;

	// IFlexDisplayObject.as:77
	function get_scrollRect():Rectangle;

	// IFlexDisplayObject.as:79
	function get_mouseX():Float;

	// IFlexDisplayObject.as:81
	function get_mouseY():Float;

	// IFlexDisplayObject.as:83
	function set_height(param1:Float):Void;

	// IFlexDisplayObject.as:85
	function set_mask(param1:DisplayObject):Void;

	// IFlexDisplayObject.as:87
	function getRect(param1:DisplayObject):Rectangle;

	// IFlexDisplayObject.as:89
	function get_alpha():Float;

	// IFlexDisplayObject.as:91
	function set_transform(param1:Transform):Void;

	// IFlexDisplayObject.as:93
	function move(param1:Float, param2:Float):Void;

	// IFlexDisplayObject.as:95
	function get_loaderInfo():LoaderInfo;

	// IFlexDisplayObject.as:97
	function get_root():DisplayObject;

	// IFlexDisplayObject.as:99
	function hitTestObject(param1:DisplayObject):Bool;

	// IFlexDisplayObject.as:101
	function set_opaqueBackground(param1:Dynamic):Void;

	// IFlexDisplayObject.as:103
	function set_visible(param1:Bool):Void;

	// IFlexDisplayObject.as:105
	function get_mask():DisplayObject;

	// IFlexDisplayObject.as:107
	function set_x(param1:Float):Void;

	// IFlexDisplayObject.as:109
	function set_y(param1:Float):Void;

	// IFlexDisplayObject.as:111
	function get_transform():Transform;

	// IFlexDisplayObject.as:113
	function set_filters(param1:Array<Dynamic>):Void;

	// IFlexDisplayObject.as:115
	function get_x():Float;

	// IFlexDisplayObject.as:117
	function get_y():Float;

	// IFlexDisplayObject.as:119
	function get_filters():Array<Dynamic>;

	// IFlexDisplayObject.as:121
	function set_rotation(param1:Float):Void;

	// IFlexDisplayObject.as:123
	function get_stage():Stage;
}
