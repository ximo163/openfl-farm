package module.decorate.widgets;

import com.qzone.qui.styles.Style;
import com.qzone.utils.GraphicsUtil;
import common.Consts;
import common.GetCropID;
import framework.base.BaseTileItem;
import openfl.geom.Rectangle;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.text.TextFormatAlign;
import shim.As3;

/**
 * module.decorate.widgets.BoardRenderItem —— BoardRenderItem.as 逐句对应
 * （issue #38 功能 swf 翻译：DIY 装饰）。告示牌格：ItemBg 底（100×100，
 * 白 0 alpha 框 100×120）、「已装饰」角标（Verdana 12 / 13369344 / 居中 +
 * 辉光，y=(高-20)*0.5）；素材走 DECOR_BILLBOARD 通道（loadBillBoard）。
 * 视觉参数逐字照抄。
 *
 * PORT-NOTE: `super.data["status"] == 1`/`["id"]` 是对配置行动态键的
 * AS3 松等 → floatOf/intOf；`idToBoardUrl(原版收 *)` 移植签名收 String →
 * Std.string（BackgroundModel 先例）。
 */
class BoardRenderItem extends BaseTileItem {
	// BoardRenderItem.as:16
	private var _setText:TextField;

	// BoardRenderItem.as:18-24
	public function new() {
		super();
		createBackground("ItemBg", 100, 100);
		this._setText = null;
		GraphicsUtil.draw(this, 16777215, 0, new Rectangle(0, 0, 100, 120));
	}

	// BoardRenderItem.as:26-58
	public function toggleDecorated():Void {
		if (As3.floatOf(Reflect.field(super.get_data(), "status")) == 1) {
			if (this._setText == null) {
				this._setText = new TextField();
				this._setText.width = 100;
				this._setText.height = 20;
				this._setText.selectable = false;
				this._setText.mouseEnabled = false;
				this._setText.defaultTextFormat = new TextFormat("Verdana", 12, 13369344, null, null, null, null, null, TextFormatAlign.CENTER);
				this._setText.filters = cast Style.getTextGlowFilter();
				this._setText.text = "已装饰";
				addChild(this._setText);
				this._setText.x = 0;
				this._setText.y = (this.height - this._setText.height) * 0.5;
			} else {
				this._setText.visible = true;
			}
			_material.setContent(Std.string(Consts.DECOR_BILLBOARD), As3.intOf(Reflect.field(super.get_data(), "id")), false);
		} else {
			if (this._setText != null) {
				this._setText.visible = false;
			}
			_material.setContent(Std.string(Consts.DECOR_BILLBOARD), As3.intOf(Reflect.field(super.get_data(), "id")), true);
		}
	}

	// BoardRenderItem.as:60-80（先 super 落 _item 再查 id/loadBillBoard）
	override private function set_data(param1:Dynamic):Dynamic {
		if (param1 == null || param1 == this._item) {
			return param1;
		}
		super.set_data(param1);
		if (As3.hasProp(param1, "id") == false) {
			return param1;
		}
		var _loc2_:String = GetCropID.idToBoardUrl(Std.string(Reflect.field(param1, "id")));
		if (_loc2_ == "") {
			return param1;
		}
		_material.loadBillBoard(_loc2_);
		_material.showLoading();
		this.toggleDecorated();
		registerListeners();
		return param1;
	}
}
