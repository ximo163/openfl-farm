package module.decorate.widgets;

import com.qzone.qui.styles.Style;
import com.qzone.utils.GraphicsUtil;
import common.Consts;
import entities.DecorateItem;
import framework.base.BaseTileItem;
import openfl.geom.Rectangle;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.text.TextFormatAlign;

/**
 * module.decorate.widgets.DecorRenderItem —— DecorRenderItem.as 逐句对应
 * （issue #38 功能 swf 翻译：DIY 装饰）。已购买装饰格：ItemBorder 底 + 遮罩
 * （60×60，白 0 alpha 框 60×80）、「已装饰」角标（Verdana 12 / 13369344 /
 * 居中 + 文字辉光，y=(60-高)*0.5）；狗类走 ITEM_TYPE_DOG 且 itemId-80000
 * （原文硬编码 80000，照抄）。视觉参数逐字照抄。
 *
 * PORT-NOTE: AS3 protected（_setText/_setCropTime、createBackground 等
 * 基类成员）→ Haxe private（子类可见）；`super.data` 读走基类 getter →
 * super.get_data()（handbook water 页先例）。
 */
class DecorRenderItem extends BaseTileItem {
	// DecorRenderItem.as:16（AS3 protected → private，DecorHeadRenderItem 可见）
	private var _setText:TextField;

	// DecorRenderItem.as:18（本类只写 -1，_FishRenderItem 同名先例保留）
	private var _setCropTime:Int;

	// DecorRenderItem.as:20-28
	public function new() {
		super();
		createBackground("ItemBorder", 60, 60);
		_material.y = 1;
		this._setText = null;
		this._setCropTime = -1;
		GraphicsUtil.draw(this, 16777215, 0, new Rectangle(0, 0, 60, 80));
	}

	// DecorRenderItem.as:30-40
	override private function set_data(param1:Dynamic):Dynamic {
		if (param1 == null || param1 == this._item) {
			return param1;
		}
		super.set_data(param1);
		this.toggleDecorated();
		createMask("ItemBorder", 60, 60);
		registerListeners();
		return param1;
	}

	// DecorRenderItem.as:42-93
	public function toggleDecorated():Void {
		var _loc1_:DecorateItem = Std.isOfType(super.get_data(), DecorateItem) ? cast(super.get_data(), DecorateItem) : null;
		if (_loc1_ == null) {
			return;
		}
		if (_loc1_._status == 1) {
			if (this._setText == null) {
				this._setText = new TextField();
				this._setText.width = 60;
				this._setText.height = 20;
				this._setText.selectable = false;
				this._setText.mouseEnabled = false;
				this._setText.defaultTextFormat = new TextFormat("Verdana", 12, 13369344, null, null, null, null, null, TextFormatAlign.CENTER);
				this._setText.filters = cast Style.getTextGlowFilter();
				this._setText.text = "已装饰";
				addChild(this._setText);
				this._setText.x = 0;
				this._setText.y = (60 - this._setText.height) * 0.5;
			} else {
				this._setText.visible = true;
			}
			if (_loc1_._type == Consts.DECOR_DOG) {
				_material.setContent(Consts.ITEM_TYPE_DOG, _loc1_._itemId - 80000, false);
			} else {
				_material.setContent(Consts.ITEM_TYPE_DECORATE, _loc1_._itemId, false);
			}
		} else {
			if (this._setText != null) {
				this._setText.visible = false;
			}
			if (_loc1_._type == Consts.DECOR_DOG) {
				_material.setContent(Consts.ITEM_TYPE_DOG, _loc1_._itemId - 80000, true);
			} else {
				_material.setContent(Consts.ITEM_TYPE_DECORATE, _loc1_._itemId, true);
			}
		}
	}
}
