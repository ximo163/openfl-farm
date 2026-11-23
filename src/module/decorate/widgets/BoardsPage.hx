package module.decorate.widgets;

import com.qzone.qui.controls.Label;
import com.qzone.qui.controls.scrollClasses.ScrollPolicy;
import common.view.window.WindowLabelMaker;
import framework.base.BasePage;
import module.uitools.widgets.profile.PropertyText;
import openfl.display.DisplayObjectContainer;
import shim.As3;

/**
 * module.decorate.widgets.BoardsPage —— BoardsPage.as 逐句对应（issue
 * #38 功能 swf 翻译：DIY 装饰）。告示牌页：顶部说明 Label（x=2 宽
 * param2-5），TileList（100×100 格、paddingH 8、x=25 y=21、宽
 * _preferedWidth-30 高 _preferedHeight-85、无默认皮肤、横向滚动关）；
 * changeBoard 换牌时对新旧 id 各 toggleDecorated。
 *
 * PORT-NOTE: `_sumPrice` 声明后从未赋值（从仓库页复制的死字段，原版如此，
 * 照抄）；changeBoard 遇首个非 BoardRenderItem 条目是 `break` 不是
 * continue（原文如此）；`data["id"] == int` 松等 → floatOf。
 */
class BoardsPage extends BasePage {
	// BoardsPage.as:13（死字段：从未赋值，原版如此）
	private var _sumPrice:PropertyText;

	// BoardsPage.as:15-24
	public function new(param1:DisplayObjectContainer, param2:Int, param3:Int) {
		super(param1, param2, param3);
		var _loc4_:Label = new Label();
		_loc4_.text = "特别说明：点击“已装饰”标签的告示牌即可隐藏告示牌。";
		_loc4_.x = 2;
		_loc4_.width = param2 - 5;
		WindowLabelMaker.addTarget(_loc4_);
		addChild(_loc4_);
	}

	// BoardsPage.as:26-41（AS3 protected → private 覆写）
	override private function onCreateTile():Void {
		if (_tile != null) {
			_tile.tileWidth = 100;
			_tile.tileHeight = 100;
			_tile.paddingH = 8;
			_tile.itemRenderer = BoardRenderItem;
			_tile.x = 25;
			_tile.y = 21;
			_tile.width = _preferedWidth - 30;
			_tile.height = _preferedHeight - 85;
			_tile.defaultSkin = null;
			_tile.horizontalScrollPolicy = ScrollPolicy.OFF;
		}
	}

	// BoardsPage.as:43-73
	public function changeBoard(param1:Int, param2:Int):Void {
		var _loc4In:Dynamic = null;
		var _loc4_:BoardRenderItem = null;
		if (_tile == null) {
			return;
		}
		var _loc3_:Array<Dynamic> = _tile.items;
		if (_loc3_ == null || _loc3_.length == 0) {
			return;
		}
		for (_loc4In in _loc3_) {
			if (Std.isOfType(_loc4In, BoardRenderItem) == false) {
				break;
			}
			_loc4_ = cast(_loc4In, BoardRenderItem);
			if (_loc4_.data != null) {
				if (As3.floatOf(Reflect.field(_loc4_.data, "id")) == param1) {
					_loc4_.toggleDecorated();
				} else if (As3.floatOf(Reflect.field(_loc4_.data, "id")) == param2) {
					_loc4_.toggleDecorated();
				}
			}
		}
	}
}
