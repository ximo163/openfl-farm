package com.qzone.qui.controls;

import com.qzone.qui.controls.listClasses.ListBase;
import com.qzone.qui.controls.listClasses.ListItemRenderer;
import com.qzone.qui.core.Direction;
import com.qzone.qui.skins.ListDefaultSkin;
import com.qzone.qui.styles.Style;
import com.qzone.utils.DisplayUtil;
import openfl.display.DisplayObject;

/**
 * com.qzone.qui.controls.HList —— HList.as 逐句对应（issue #36 功能 swf
 * 翻译：仓库）。横向列表：ListBase 定 direction=HORIZONTAL + 列表皮肤。
 * PORT-NOTE: `new this.defaultSkin()` → Type.createInstance（Class<Dynamic>
 * 反射构造）；`_added && this.setSize()` 短路调用 → 显式 if。
 */
class HList extends ListBase {
	// HList.as:12（AS3 protected → Haxe private，子类可见）
	private var _skin:DisplayObject;

	// HList.as:14
	public var defaultSkin:Class<Dynamic>;

	// HList.as:16-28
	public function new(param1:Float = 100, param2:Float = 100) {
		super();
		this.paddingV = Style.listPaddingV;
		this.paddingH = Style.listPaddingH;
		this.borderSizeV = Style.listBorderSizeV;
		this.borderSizeH = Style.listBorderSizeH;
		this._width = param1;
		this._height = param2;
		this.defaultSkin = ListDefaultSkin.skin;
		this.rowHeight = 22;
		this.itemRenderer = ListItemRenderer;
		this.direction = Direction.HORIZONTAL;
	}

	// HList.as:30-33
	override private function init():Void {
		super.init();
	}

	// HList.as:35-45
	override private function setSize():Void {
		if (this._added) {
			super.setSize();
			if (this._skin != null) {
				this._skin.width = this._width;
				this._skin.height = this._height;
			}
		}
	}

	// HList.as:47-57
	override private function setSkin():Void {
		if (this._skin != null) {
			DisplayUtil.removeChild(this, this._skin);
		}
		if (this.defaultSkin != null) {
			this._skin = Type.createInstance(this.defaultSkin, []);
			this.addChildAt(this._skin, 0);
		}
		// AS3 `_added && this.setSize()` 的短路调用 → 显式 if
		if (this._added) {
			this.setSize();
		}
	}
}
