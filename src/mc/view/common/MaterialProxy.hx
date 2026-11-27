package mc.view.common;

import common.MaterialLib;
import mc.view.farm.GetCropID;
import openfl.display.DisplayObject;
import openfl.display.Sprite;
import openfl.filters.ColorMatrixFilter;

/**
 * mc.view.common.MaterialProxy —— MaterialProxy.as 逐句对应（issue #87
 * 牧场「通用视图」片；#19 签名面 stub 充真身）。素材格子：setContent
 * 按类型串分派到各 setXxx 私有装载（种子/工具/仓库/金币/经验/饲料），
 * 禁用态套灰度 ColorMatrixFilter，素材居中 (w-width)/2。注意与 main3
 * 侧 common.view.MaterialProxy 是两个类。
 * legacy/decompiled/Master2_v_142/scripts/mc/view/common/MaterialProxy.as。
 *
 * PORT-NOTE（`getMaterial(...) as DisplayObject`，各 setXxx）：as 失配
 * -null 语义走 isOfType 门 + 直取（lessons #7）。原版各分支的 null
 * 守卫不对称（setCrop/setCrop2/setWareHouse/setTool/setChildObject 有
 * 判空 return、setTool2/setTool2x 无——缺失即 NPE），逐字保留。
 * PORT-NOTE（`"Seed" + param1.toString()` 等拼串）：AS3 int.toString()
 * → Std.string（lessons——js 偶然可用、cpp typer 红）。`"Food" + param1`
 * 的 int 直接拼接在 AS3/Haxe 都是字符串拼接语义，直翻。
 * PORT-NOTE（setContent 的反括号结构，:247）：`else if(param1 != "2")`
 * 包裹 5/6_6/7/7_7/25/2525/5_5 七个分支——"2" 落穿无操作但
 * currentType/currentId 照样记录（:256-257 在分派外）。结构逐字保留。
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

	// MaterialProxy.as:31-34
	public function new() {
		super();
		this._w = this._h = 61;
	}

	// MaterialProxy.as:36-43
	private function remove():Void {
		if (this.childObjcet != null) {
			removeChild(this.childObjcet);
			this.childObjcet = null;
		}
	}

	// MaterialProxy.as:45-70
	private function setCrop(param1:Int):Void {
		var _loc2_:String = "Seed" + Std.string(param1);
		this.remove();
		if (_loc2_ == "") {
			return;
		}
		var _loc3_:MaterialLib = MaterialLib.getInstance();
		this.childObjcet = asDisplayObject(_loc3_.getMaterial(_loc2_));
		if (this.childObjcet == null) {
			return;
		}
		this.childObjcet.x = (this._w - this.childObjcet.width) / 2;
		this.childObjcet.y = (this._h - this.childObjcet.height) / 2;
		if (this._enable) {
			this.childObjcet.filters = [];
		} else {
			this.childObjcet.filters = [
				new ColorMatrixFilter([0.3086, 0.6094, 0.082, 0, 0, 0.3086, 0.6094, 0.082, 0, 0, 0.3086, 0.6094, 0.082, 0, 0, 0, 0, 0, 1, 0])
			];
		}
		addChild(this.childObjcet);
	}

	// MaterialProxy.as:72-93
	private function setTool2(param1:Int):Void {
		var _loc2_:String = "Food" + param1;
		this.remove();
		if (_loc2_ == "") {
			return;
		}
		var _loc3_:MaterialLib = MaterialLib.getInstance();
		this.childObjcet = asDisplayObject(_loc3_.getMaterial(_loc2_));
		this.childObjcet.x = (this._w - this.childObjcet.width) / 2;
		this.childObjcet.y = (this._h - this.childObjcet.height) / 2;
		if (this._enable) {
			this.childObjcet.filters = [];
		} else {
			this.childObjcet.filters = [
				new ColorMatrixFilter([0.3086, 0.6094, 0.082, 0, 0, 0.3086, 0.6094, 0.082, 0, 0, 0.3086, 0.6094, 0.082, 0, 0, 0, 0, 0, 1, 0])
			];
		}
		addChild(this.childObjcet);
	}

	// MaterialProxy.as:95-120
	private function setTool(param1:Int, param2:String):Void {
		var _loc3_:String = GetCropID.idToToolName(Std.string(param1), param2);
		this.remove();
		if (_loc3_ == "") {
			return;
		}
		var _loc4_:MaterialLib = MaterialLib.getInstance();
		this.childObjcet = asDisplayObject(_loc4_.getMaterial(_loc3_));
		if (this.childObjcet == null) {
			return;
		}
		this.childObjcet.x = (this._w - this.childObjcet.width) / 2;
		this.childObjcet.y = (this._h - this.childObjcet.height) / 2;
		if (this._enable) {
			this.childObjcet.filters = [];
		} else {
			this.childObjcet.filters = [
				new ColorMatrixFilter([0.3086, 0.6094, 0.082, 0, 0, 0.3086, 0.6094, 0.082, 0, 0, 0.3086, 0.6094, 0.082, 0, 0, 0, 0, 0, 1, 0])
			];
		}
		addChild(this.childObjcet);
	}

	// MaterialProxy.as:122-125
	private function setExp(param1:Int):Void {
		this.setChildObject("ExpIcon");
	}

	// MaterialProxy.as:127-152
	private function setWareHouse(param1:Int):Void {
		var _loc2_:String = GetCropID.idToWareName(Std.string(param1));
		this.remove();
		if (_loc2_ == "") {
			return;
		}
		var _loc3_:MaterialLib = MaterialLib.getInstance();
		this.childObjcet = asDisplayObject(_loc3_.getMaterial(_loc2_));
		if (this.childObjcet == null) {
			return;
		}
		this.childObjcet.x = (this._w - this.childObjcet.width) / 2;
		this.childObjcet.y = (this._h - this.childObjcet.height) / 2;
		if (this._enable) {
			this.childObjcet.filters = [];
		} else {
			this.childObjcet.filters = [
				new ColorMatrixFilter([0.3086, 0.6094, 0.082, 0, 0, 0.3086, 0.6094, 0.082, 0, 0, 0.3086, 0.6094, 0.082, 0, 0, 0, 0, 0, 1, 0])
			];
		}
		addChild(this.childObjcet);
	}

	// MaterialProxy.as:154-173
	private function setTool2x(param1:Int):Void {
		var _loc2_:String = "Food" + param1 + "Big";
		this.remove();
		if (_loc2_ == "") {
			return;
		}
		var _loc3_:MaterialLib = MaterialLib.getInstance();
		this.childObjcet = asDisplayObject(_loc3_.getMaterial(_loc2_));
		if (this._enable) {
			this.childObjcet.filters = [];
		} else {
			this.childObjcet.filters = [
				new ColorMatrixFilter([0.3086, 0.6094, 0.082, 0, 0, 0.3086, 0.6094, 0.082, 0, 0, 0.3086, 0.6094, 0.082, 0, 0, 0, 0, 0, 1, 0])
			];
		}
		addChild(this.childObjcet);
	}

	// MaterialProxy.as:175-200
	private function setCrop2(param1:Int):Void {
		var _loc2_:String = "Seed" + Std.string(param1) + "Big";
		this.remove();
		if (_loc2_ == "") {
			return;
		}
		var _loc3_:MaterialLib = MaterialLib.getInstance();
		this.childObjcet = asDisplayObject(_loc3_.getMaterial(_loc2_));
		if (this.childObjcet == null) {
			return;
		}
		this.childObjcet.x = (this._w - this.childObjcet.width) / 2;
		this.childObjcet.y = (this._h - this.childObjcet.height) / 2;
		if (this._enable) {
			this.childObjcet.filters = [];
		} else {
			this.childObjcet.filters = [
				new ColorMatrixFilter([0.3086, 0.6094, 0.082, 0, 0, 0.3086, 0.6094, 0.082, 0, 0, 0.3086, 0.6094, 0.082, 0, 0, 0, 0, 0, 1, 0])
			];
		}
		addChild(this.childObjcet);
	}

	// MaterialProxy.as:202-205
	private function setGold(param1:Int):Void {
		this.setChildObject("GoldBigIcon");
	}

	// MaterialProxy.as:207-226
	private function setChildObject(param1:String):Void {
		this.remove();
		this.childObjcet = asDisplayObject(MaterialLib.getInstance().getMaterial(param1));
		if (this.childObjcet == null) {
			return;
		}
		this.childObjcet.x = (this._w - this.childObjcet.width) / 2;
		this.childObjcet.y = (this._h - this.childObjcet.height) / 2;
		if (this._enable) {
			this.childObjcet.filters = [];
		} else {
			this.childObjcet.filters = [
				new ColorMatrixFilter([0.3086, 0.6094, 0.082, 0, 0, 0.3086, 0.6094, 0.082, 0, 0, 0.3086, 0.6094, 0.082, 0, 0, 0, 0, 0, 1, 0])
			];
		}
		addChild(this.childObjcet);
	}

	// MaterialProxy.as:228-258（同 type+id+enable 跳过——currentType/
	// currentId 在分派后更新，跳过语义依赖滞后值）
	public function setContent(param1:String, param2:Int, param3:Bool = true):Void {
		if (this.currentType == param1 && this.currentId == param2 && param3 == this._enable) {
			return;
		}
		this._enable = param3;
		if (param1 == "1") {
			this.setCrop(param2);
		} else if (param1 == "11") {
			this.setCrop2(param2);
		} else if (param1 == "4") {
			this.setTool(param2, param1);
		} else if (param1 != "2") {
			if (param1 == "5") {
				this.setWareHouse(param2);
			} else if (param1 == "6_6") {
				this.setGold(param2);
			} else if (param1 == "7") {
				this.setTool(param2, param1);
			} else if (param1 == "7_7") {
				this.setExp(param2);
			} else if (param1 == "25") {
				this.setTool2(param2);
			} else if (param1 == "2525") {
				this.setTool2x(param2);
			} else if (param1 == "5_5") {
				this.setTool(param2, "5");
			}
		}
		this.currentType = param1;
		this.currentId = param2;
	}

	// `x as DisplayObject`（isOfType ? cast : null，本文件素材通道共用）
	private static function asDisplayObject(param1:Dynamic):DisplayObject {
		return Std.isOfType(param1, DisplayObject) ? cast(param1, DisplayObject) : null;
	}

}
