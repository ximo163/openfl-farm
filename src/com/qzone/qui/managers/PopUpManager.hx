package com.qzone.qui.managers;

import com.qzone.qui.containers.TitleWindow;
import com.qzone.utils.AlignUtil;
import openfl.display.DisplayObject;
import openfl.display.DisplayObjectContainer;
import openfl.errors.Error;
import openfl.events.EventDispatcher;

/**
 * com.qzone.qui.managers.PopUpManager —— PopUpManager.as 逐句对应（issue #18
 * qui 收尾：管理器片整类翻译，替换 #7 的静态形态 stub）。弹窗管理器单例：
 * 持全局 _stage 与唯一 PopUpLayer 实例，createPopUp/addPopUp/removePopUp/
 * hidePopUp/showPopUp/centerPopUp/bringToFront 静态门面，模态弹窗期间关
 * root 的 tabChildren。
 * PORT-NOTE:
 * - `_stage["root"].tabChildren` → cast(_stage.root, DisplayObjectContainer)
 *   后直写（root 静态类型是 DisplayObject）。
 * - items 记录是 {popUp, modal} 匿名对象：`["modal"] != undefined` 按
 *   AS3 null==undefined 宽松等译成 hasField && 非 null（Player.hx 先例）。
 */
@:keep
class PopUpManager extends EventDispatcher {
	// PopUpManager.as:12-14
	private static var _stage:DisplayObjectContainer;

	private static var instance:PopUpLayer;

	// :16-23
	public function new() {
		super();
		if (instance != null) {
			throw new Error("实例化单例类出错 - PopUpManager");
		}
	}

	// :25-28
	public static var items(get, never):Array<Dynamic>;

	private static function get_items():Array<Dynamic> {
		return instance.items;
	}

	// :30-40
	public static function removePopUp(param1:DisplayObjectContainer):DisplayObject {
		var _loc2_:TitleWindow = null;
		if (Std.isOfType(param1, TitleWindow)) {
			_loc2_ = cast param1;
			DragManager.removeTarget(_loc2_, _loc2_.headArea);
		}
		getInstance().removePopUp(param1);
		return param1;
	}

	// :42-66
	public static function hidePopUp(param1:DisplayObject):Void {
		var _loc3_:Dynamic = null;
		if (instance == null) {
			return;
		}
		if (param1 == null || instance.contains(param1) == false) {
			return;
		}
		param1.visible = false;
		var _loc2_:Array<Dynamic> = PopUpManager.items;
		// AS3 for-each：按值遍历
		for (_loc3_ in _loc2_) {
			if (Reflect.field(_loc3_, "popUp") == param1) {
				if (Reflect.hasField(_loc3_, "modal") && Reflect.field(_loc3_, "modal") != null) {
					Reflect.setProperty(Reflect.field(_loc3_, "modal"), "visible", false);
				}
				break;
			}
		}
	}

	// :68-76
	public static function getInstance():PopUpLayer {
		if (instance == null) {
			instance = new PopUpLayer();
			_stage.addChild(instance);
		}
		return instance;
	}

	// :78-102
	public static function showPopUp(param1:DisplayObject):Void {
		var _loc3_:Dynamic = null;
		if (instance == null) {
			return;
		}
		if (param1 == null || instance.contains(param1) == false) {
			return;
		}
		param1.visible = true;
		var _loc2_:Array<Dynamic> = PopUpManager.items;
		// AS3 for-each：按值遍历
		for (_loc3_ in _loc2_) {
			if (Reflect.field(_loc3_, "popUp") == param1) {
				if (Reflect.hasField(_loc3_, "modal") && Reflect.field(_loc3_, "modal") != null) {
					Reflect.setProperty(Reflect.field(_loc3_, "modal"), "visible", true);
				}
				break;
			}
		}
	}

	// :104-113（`new param1()` → Type.createInstance）
	public static function createPopUp(param1:Class<Dynamic>, param2:Bool = false, param3:Bool = true,
			param4:DisplayObjectContainer = null):DisplayObject {
		if (param4 != null) {
			_stage = param4;
		}
		var _loc5_:DisplayObjectContainer = Type.createInstance(param1, []);
		addPopUp(_loc5_, param2, param3, param4);
		return _loc5_;
	}

	// :115-145
	public static function addPopUp(param1:DisplayObject, param2:Bool = false, param3:Bool = true,
			param4:DisplayObjectContainer = null):DisplayObject {
		var _loc5_:TitleWindow = null;
		if (param4 != null) {
			_stage = param4;
			if (param4.contains(param1) == true) {
				return param1;
			}
		}
		if (param3) {
			centerPopUp(param1);
		}
		if (getInstance().contains(param1) == true) {
			return param1;
		}
		getInstance().addPopUp(param1, param4, param2);
		if (param2) {
			cast(_stage.root, DisplayObjectContainer).tabChildren = false;
		}
		if (Std.isOfType(param1, TitleWindow)) {
			_loc5_ = cast param1;
			DragManager.addTarget(_loc5_, null, _loc5_.headArea);
		}
		return param1;
	}

	// :147-157
	public static function centerPopUp(param1:DisplayObject):Void {
		var _loc2_:Int = Std.int(AlignUtil.middle(_stage.stage.stageWidth, param1.width));
		var _loc3_:Int = Std.int(AlignUtil.middle(_stage.stage.stageHeight, param1.height));
		if (_loc3_ < 0) {
			_loc3_ = 0;
		}
		param1.x = _loc2_;
		param1.y = _loc3_;
	}

	// :159-165
	public static function bringToFront(param1:DisplayObjectContainer):Void {
		if (instance.numChildren > 0) {
			instance.setChildIndex(param1, instance.numChildren - 1);
		}
	}

	// :167-172（`_stage = param1.stage`：Stage 即 DisplayObjectContainer）
	public static function init(param1:DisplayObjectContainer):Void {
		_stage = param1.stage;
		getInstance();
	}
}
