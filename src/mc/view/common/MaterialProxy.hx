package mc.view.common;

import openfl.display.DisplayObject;
import openfl.display.Sprite;
import openfl.errors.Error;

/**
 * mc.view.common.MaterialProxy —— MaterialProxy.as 的签名面 stub（原类
 * 258 loc，issue #87「通用视图」片充真身）。素材格子：setContent 按类型
 * 串分派到各 setXxx 私有装载（种子/工具/仓库/金币/经验/饲料），禁用态套
 * 灰度 ColorMatrixFilter，素材居中 (w-width)/2。成员签名逐字取自反编译
 * 原文，方法体随 implement 充真身。
 * legacy/decompiled/Master2_v_142/scripts/mc/view/common/MaterialProxy.as。
 */
@:keep
class MaterialProxy extends Sprite {
	// MaterialProxy.as:13-15
	public static final BIG:String = "big";
	public static final SMALL:String = "small";

	// MaterialProxy.as:17-29
	private var currentType:String = "";
	private var _size:String;
	private var _enable:Bool = true;
	private var _h:Int = 60;
	private var currentId:Int = 0;
	private var childObjcet:DisplayObject;
	private var _w:Int = 60;

	// MaterialProxy.as:31-34（ctor 置 _w=_h=61——原文即完整，入 stub 不掷）
	public function new() {
		super();
		this._w = this._h = 61;
	}

	// MaterialProxy.as:36-43
	private function remove():Void {
		throw new Error("not implemented");
	}

	// MaterialProxy.as:45-70
	private function setCrop(param1:Int):Void {
		throw new Error("not implemented");
	}

	// MaterialProxy.as:72-93
	private function setTool2(param1:Int):Void {
		throw new Error("not implemented");
	}

	// MaterialProxy.as:95-120
	private function setTool(param1:Int, param2:String):Void {
		throw new Error("not implemented");
	}

	// MaterialProxy.as:122-125
	private function setExp(param1:Int):Void {
		throw new Error("not implemented");
	}

	// MaterialProxy.as:127-152
	private function setWareHouse(param1:Int):Void {
		throw new Error("not implemented");
	}

	// MaterialProxy.as:154-173
	private function setTool2x(param1:Int):Void {
		throw new Error("not implemented");
	}

	// MaterialProxy.as:175-200
	private function setCrop2(param1:Int):Void {
		throw new Error("not implemented");
	}

	// MaterialProxy.as:202-205
	private function setGold(param1:Int):Void {
		throw new Error("not implemented");
	}

	// MaterialProxy.as:207-226
	private function setChildObject(param1:String):Void {
		throw new Error("not implemented");
	}

	// MaterialProxy.as:228-258（类型串分派："1"/"11"/"4"/"7"/"5"/"6_6"/
	// "7_7"/"25"/"2525"/"5_5"；同 type+id+enable 跳过）
	public function setContent(param1:String, param2:Int, param3:Bool = true):Void {
		throw new Error("not implemented");
	}
}
