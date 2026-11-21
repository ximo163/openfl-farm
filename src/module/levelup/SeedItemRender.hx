package module.levelup;

import common.Consts;
import common.misc.Utils;
import common.view.MaterialProxy;
import entities.Seed;
import openfl.display.Sprite;
import shim.As3;

/**
 * module.levelup.SeedItemRender —— SeedItemRender.as 逐句对应（issue #18
 * 升级模块片）。升级面板的种子项：Update.seedsRender 素材 + 名称文本 +
 * MaterialProxy 种子图挂到 holder 位置。
 * PORT-NOTE: `this._ui["nameTxt"]`（swf 符号具名子件）→ As3.childOf；
 * `.text =` 按名写走 Reflect.setProperty（js 裸 Dynamic 写只落影子字段）。
 */
@:keep
class SeedItemRender extends Sprite {
	// SeedItemRender.as:12-18
	public static final ROW_GAP:Int = 72;

	public static final COLUMN_GAP:Int = 86;

	private var _data:Seed;

	private var _ui:Sprite;

	// :20-26
	public function new(param1:Seed) {
		super();
		this._data = param1;
		this._ui = Std.isOfType(Utils.getMaterial("Update.seedsRender"), Sprite)
			? cast(Utils.getMaterial("Update.seedsRender"), Sprite) : null;
		this.setData();
	}

	// :28-41
	private function setData():Void {
		var _loc1_:MaterialProxy = null;
		Reflect.setProperty(As3.childOf(this._ui, "nameTxt"), "text", this._data._name);
		_loc1_ = new MaterialProxy();
		_loc1_.mouseEnabled = false;
		_loc1_.setContent(Consts.ITEM_TYPE_SEED, this._data._id);
		var _loc2_:Sprite = cast As3.childOf(this._ui, "holder");
		_loc1_.x = _loc2_.x;
		_loc1_.y = _loc2_.y;
		this._ui.addChild(_loc1_);
		addChild(this._ui);
	}
}
