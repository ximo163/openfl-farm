package module.decorate.widgets;

import com.qzone.qui.styles.Style;
import common.Consts;
import entities.DecorateItem;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.text.TextFormatAlign;

/**
 * module.decorate.widgets.DecorHeadRenderItem —— DecorHeadRenderItem.as
 * 逐句对应（issue #38 功能 swf 翻译：DIY 装饰）。「当前装饰」区的头饰格：
 * 角标文案是「点击装饰」且可见性与基类相反（未装备才亮），setContent 的
 * 反灰参也相反——原文即如此（复用 DecorRenderItem 反着用），照抄。
 *
 * PORT-NOTE: set data 的同对象分支比对 `(param1 as DecorateItem)._status`
 * 与旧值 _status，不等才 toggleDecorated（原版重进页签时靠这刷角标）。
 */
class DecorHeadRenderItem extends DecorRenderItem {
	// DecorHeadRenderItem.as:13-16
	public function new() {
		super();
	}

	// DecorHeadRenderItem.as:18-71
	override public function toggleDecorated():Void {
		var _loc1_:DecorateItem = null;
		_loc1_ = Std.isOfType(super.get_data(), DecorateItem) ? cast(super.get_data(), DecorateItem) : null;
		if (_loc1_ == null) {
			return;
		}
		if (_loc1_._status == 1) {
			if (_setText == null) {
				_setText = new TextField();
				_setText.width = 60;
				_setText.height = 20;
				_setText.selectable = false;
				_setText.mouseEnabled = false;
				_setText.defaultTextFormat = new TextFormat("Verdana", 12, 13369344, null, null, null, null, null, TextFormatAlign.CENTER);
				_setText.filters = cast Style.getTextGlowFilter();
				_setText.text = "点击装饰";
				_setText.visible = false;
				addChild(_setText);
				_setText.x = 0;
				_setText.y = (60 - _setText.height) * 0.5;
			} else {
				_setText.visible = false;
			}
			if (_loc1_._type == Consts.DECOR_DOG) {
				_material.setContent(Consts.ITEM_TYPE_DOG, _loc1_._itemId - 80000, true);
			} else {
				_material.setContent(Consts.ITEM_TYPE_DECORATE, _loc1_._itemId, true);
			}
		} else {
			if (_setText != null) {
				_setText.visible = true;
			}
			if (_loc1_._type == Consts.DECOR_DOG) {
				_material.setContent(Consts.ITEM_TYPE_DOG, _loc1_._itemId - 80000, false);
			} else {
				_material.setContent(Consts.ITEM_TYPE_DECORATE, _loc1_._itemId, false);
			}
		}
	}

	// DecorHeadRenderItem.as:73-91
	override private function set_data(param1:Dynamic):Dynamic {
		if (param1 == null) {
			return param1;
		}
		if (param1 == this._item) {
			if (cast(param1, DecorateItem)._status != cast(this._item, DecorateItem)._status) {
				this.toggleDecorated();
			}
			return param1;
		}
		super.set_data(param1);
		this.toggleDecorated();
		createMask("ItemBorder", 60, 60);
		registerListeners();
		return param1;
	}
}
