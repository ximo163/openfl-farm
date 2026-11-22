package module.warehouse.bag;

import com.qzone.qui.controls.listClasses.ListItemRenderer;
import common.Consts;
import common.misc.Utils;
import common.view.MaterialProxy;
import entities.BagItem;
import events.ViewEvent;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.text.TextFormat;
import openfl.text.TextFormatAlign;
import shim.As3;

/**
 * module.warehouse.bag.PackItem —— PackItem.as 逐句对应（issue #36 功能
 * swf 翻译：仓库）。背包瓦片：ItemBg 底 + MaterialProxy 物料 + 右下角数量
 * 角标；CHILD_CLICK/CHILD_OVER/CHILD_OUT 向背包条冒泡。weapon 与「工具且
 * cId==34」不响应点击（&& 优先于 ||，照抄）。
 *
 * PORT-NOTE: `super._data`/`super._label` 的超类字段限定 → this.（Haxe 禁
 * super.field，无遮蔽语义同形）；`x as T` → Std.isOfType 判型；
 * `_type.toString()` → Std.string（Int 串化后与字串常量直比）；空覆写
 * setSize/setSkin 保原版不缩放/不换肤语义。
 */
class PackItem extends ListItemRenderer {
	// PackItem.as:18
	private var m_material:MaterialProxy;

	// PackItem.as:20-27
	public function new(param1:Int) {
		super(param1);
		buttonMode = true;
		useHandCursor = true;
		mouseChildren = false;
		this.m_material = null;
	}

	// PackItem.as:29-33
	override private function addEvent():Void {
		super.addEvent();
		addEventListener(MouseEvent.CLICK, this.onChildClick, false, 0, true);
	}

	// PackItem.as:35-37（空覆写：瓦片不随列表尺寸缩放）
	override private function setSize():Void {}

	// PackItem.as:39-53（AS3 protected → private）
	private function onChildClick(param1:MouseEvent):Void {
		if (this.m_material != null && this.m_material.loaded == false) {
			return;
		}
		var _loc2_:BagItem = Std.isOfType(this._data, BagItem) ? cast(this._data, BagItem) : null;
		// && 优先于 ||（weapon 禁点 || tool 且 cId==34 禁点），照抄
		if (Std.string(_loc2_._type) == Consts.ITEM_TYPE_WEAPON || Std.string(_loc2_._type) == Consts.ITEM_TYPE_TOOL && _loc2_._cId == 34) {
			return;
		}
		var _loc3_:ViewEvent = new ViewEvent(ViewEvent.CHILD_CLICK, true);
		_loc3_.data = this.data;
		dispatchEvent(_loc3_);
	}

	// PackItem.as:55-88
	override private function init():Void {
		var _loc2_:BagItem = null;
		var _loc3_:Bool = false;
		super.init();
		if (this._label != null) {
			this._label.textDefaultFormat = new TextFormat("embedFontA", 12, 3355443, null, null, null, null, null, TextFormatAlign.RIGHT);
			this._label.embedFonts = true;
		}
		var _loc1_:Sprite = Std.isOfType(Utils.getMaterial("ItemBg"), Sprite) ? cast(Utils.getMaterial("ItemBg"), Sprite) : null;
		if (_loc1_ != null) {
			_loc1_.mouseEnabled = false;
			addChildAt(_loc1_, 0);
		}
		if (this.m_material == null) {
			this.m_material = new MaterialProxy();
			this.m_material.showLoading();
			addChildAt(this.m_material, 1);
		}
		if (this._data != null) {
			_loc2_ = Std.isOfType(this._data, BagItem) ? cast(this._data, BagItem) : null;
			_loc3_ = true;
			// && 优先于 ||，照抄
			if (Std.string(_loc2_._type) == Consts.ITEM_TYPE_WEAPON || Std.string(_loc2_._type) == Consts.ITEM_TYPE_TOOL && _loc2_._cId == 34) {
				_loc3_ = false;
			}
			this.m_material.setContent(Std.string(_loc2_._type), _loc2_._cId, _loc3_);
			this.setAmount(_loc2_._amount);
		}
	}

	// PackItem.as:90-95
	override private function onRollOut(param1:Event):Void {
		var _loc2_:ViewEvent = new ViewEvent(ViewEvent.CHILD_OUT, true);
		_loc2_.data = this.data;
		dispatchEvent(_loc2_);
	}

	// PackItem.as:97-111。PORT-NOTE: 原版 override set data(void)，Haxe
	// 覆写须带返回值（回写 _data，机械）；`param1 as BagItem` → 判型
	override private function set_data(param1:Dynamic):Dynamic {
		var _loc2_:BagItem = Std.isOfType(param1, BagItem) ? cast(param1, BagItem) : null;
		this._data = _loc2_;
		var _loc3_:Int = As3.intOf(_loc2_._type);
		var _loc4_:Int = As3.intOf(_loc2_._cId);
		if (this.m_material != null) {
			this.m_material.setContent(Std.string(_loc3_), _loc4_);
		}
		if (_loc2_._amount > 0) {
			this.setAmount(_loc2_._amount);
		}
		return this._data;
	}

	// PackItem.as:113-117
	override private function removeEvent():Void {
		super.removeEvent();
		removeEventListener(MouseEvent.CLICK, this.onChildClick);
	}

	// PackItem.as:119-124
	override private function onRollOver(param1:Event):Void {
		var _loc2_:ViewEvent = new ViewEvent(ViewEvent.CHILD_OVER, true);
		_loc2_.data = this.data;
		dispatchEvent(_loc2_);
	}

	// PackItem.as:126-134
	public function setAmount(param1:Int):Void {
		if (this._label != null) {
			this._label.text = Std.string(param1);
			this._label.x = 60 - this._label.width;
			this._label.y = 63 - this._label.height;
		}
	}

	// PackItem.as:136-138（空覆写：瓦片不换肤）
	override private function setSkin():Void {}
}
