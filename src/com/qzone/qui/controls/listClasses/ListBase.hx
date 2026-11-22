package com.qzone.qui.controls.listClasses;

import com.qzone.qui.controls.scrollClasses.ScrollBarMode;
import com.qzone.qui.controls.scrollClasses.ScrollBase;
import com.qzone.qui.core.Direction;
import com.qzone.qui.events.ScrollEvent;
import openfl.display.DisplayObject;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.MouseEvent;
import shim.As3;

/**
 * com.qzone.qui.controls.listClasses.ListBase —— ListBase.as 逐句对应
 * （issue #36 功能 swf 翻译：仓库）。列表基类：按 direction 横/纵 rebuild
 * 出 itemRenderer 瓦片行（LINE 滚动条以条目为页单位）、_dataMap 勾选表。
 *
 * PORT-NOTE: ① AS3 for-in/for-each 遍历稠密数组 → 索引循环（MyBagModel
 * 先例；_dataMap 只经 push/splice/arrPut 变稠密，for-in 只访已存键等价），
 * getSelectedIndices 在 AS3 推入的是字符串键，这里推 Int——所有消费点都
 * 经 int() 强制（scrollToSelected/selectedIndex），数值等价；② 渲染器上的
 * 动态键写 `_loc4_[dataField]`/`_loc4_["selected"]`/`_loc4_["labelField"]`
 * → ListItemRenderer 真属性直写（CLAUDE.md 动态写三选一；itemRenderer 在
 * 模块内恒为 ListItemRenderer 子类，dataField 全程保持默认 "data"）；
 * ③ `new this.itemRenderer(i)` → Type.createInstance；④ `_dataMap[i]`
 * 的越界读 undefined/越界写扩洞 → As3.arrAt/arrPut；⑤ `int(数式)` 截断 →
 * Std.int；⑥ `...rest` → rest 参数数组；⑦ AS3 splice(pos,0,item) 零删插入
 * → insert、splice(pos,1,item) 替换 → splice+insert（TileBase 先例）；
 * removeItemAt 返回的是 splice 的数组而非元素（原版 quirk，调用方只当真值
 * 用，照抄）。
 */
class ListBase extends ScrollBase {
	// ListBase.as:15（AS3 protected → Haxe private，子类可见）
	private var direction:String = "vertical";

	// ListBase.as:17
	private var _data:Array<Dynamic>;

	// ListBase.as:19
	private var _selectedItemRenderer:Array<Dynamic>;

	// ListBase.as:21
	public var allowMultipleSelection:Bool;

	// ListBase.as:23
	private var _dataMap:Array<Dynamic>;

	// ListBase.as:25
	public var rowHeight:Int;

	// ListBase.as:27
	private var _selectedItem:Dynamic;

	// ListBase.as:29
	private var changed:Bool;

	// ListBase.as:31
	private var _selectedIndices:Array<Dynamic>;

	// ListBase.as:33
	public var rowCount:Int;

	// ListBase.as:35
	private var _selectedItems:Array<Dynamic>;

	// ListBase.as:37
	public var labelField:String = "label";

	// ListBase.as:39
	public var dataField:String = "data";

	// ListBase.as:41
	private var _selectedIndex:Int = -1;

	// ListBase.as:43
	public var itemRenderer:Class<Dynamic>;

	// ListBase.as:45-56
	public function new() {
		super();
		this.rowHeight = 18;
		this.vScrollMode = ScrollBarMode.LINE;
		this.hScrollMode = ScrollBarMode.LINE;
		this._dataMap = [];
		this._selectedIndices = [];
		this._selectedItems = [];
		this._selectedItemRenderer = [];
		this._content = new Sprite();
	}

	// ListBase.as:58-71
	public function removeAll():Void {
		var _loc2_:DisplayObject = null;
		var _loc1_:Int = this._content.numChildren - 1;
		while (_loc1_ >= 0) {
			_loc2_ = this._content.removeChildAt(_loc1_);
			if (_loc2_ != null) {
				this.removeItemEvent(_loc2_);
			}
			_loc1_--;
		}
	}

	// ListBase.as:73-87（Object 形参运行期即渲染器实例 → 取真属性；
	// 下标含 Float 滚动位 → Std.int 截断，LINE 模式恒整）
	private function updateItemRenderAt(param1:Int):Void {
		var _loc2_:ListItemRenderer = cast this._content.getChildAt(param1);
		if (As3.truthy(_loc2_)) {
			if (this.direction == Direction.HORIZONTAL) {
				_loc2_.selected = As3.truthy(As3.arrAt(this._dataMap, Std.int(param1 + this._scrollPositionH)));
			} else {
				_loc2_.selected = As3.truthy(As3.arrAt(this._dataMap, Std.int(param1 + this._scrollPositionV)));
			}
		}
	}

	// ListBase.as:89-112
	public function scrollToIndex(param1:Int):Void {
		if (this.direction == Direction.HORIZONTAL) {
			if (param1 >= this._scrollPositionH + this._pageSizeH - 1) {
				this._scrollPositionH = param1 + 2 - this._pageSizeH;
				if (this.hScrollBar != null) {
					this.hScrollBar.setScrollProperties(this._pageSizeH, this._scrollPositionH, this._maxScrollPositionH);
				}
				this.delayCall(this.rebuild);
			}
		} else if (param1 >= this._scrollPositionV + this._pageSizeV - 1) {
			this._scrollPositionV = param1 + 2 - this._pageSizeV;
			if (this.vScrollBar != null) {
				this.vScrollBar.setScrollProperties(this._pageSizeV, this._scrollPositionV, this._maxScrollPositionV);
			}
			this.delayCall(this.rebuild);
		}
	}

	// ListBase.as:114-121（for-in 稠密数组 → 索引循环，见类头 ①）
	private function deSelectAll():Void {
		var _loc1_:Int = 0;
		while (_loc1_ < this._dataMap.length) {
			this._dataMap[_loc1_] = false;
			_loc1_++;
		}
	}

	// ListBase.as:123-126（get）与 :139-143（set）合成一对
	public var selectedIndices(get, set):Array<Dynamic>;

	private function get_selectedIndices():Array<Dynamic> {
		return this.getSelectedIndices();
	}

	private function set_selectedIndices(param1:Array<Dynamic>):Array<Dynamic> {
		this._selectedIndices = param1;
		this.setSelectedIndices();
		return param1;
	}

	// ListBase.as:128-131（AS3 protected → private）
	private function onRebuildComplete():Void {
		this.dispatchEvent(new Event(Event.COMPLETE));
	}

	// ListBase.as:133-137
	override private function init():Void {
		super.init();
		this.addChild(this._content);
	}

	// ListBase.as:145-203
	private function rebuild():Void {
		var _loc1_:Int = 0;
		var _loc2_:Int = 0;
		var _loc3_:Int = 0;
		var _loc4_:ListItemRenderer = null;
		this.removeAll();
		if (As3.truthy(this._data) && As3.truthy(this._content)) {
			if (this.direction == Direction.HORIZONTAL) {
				_loc1_ = Std.int(this._pageSizeH);
				if (this._scrollPositionH + this._pageSizeH > this._data.length) {
					_loc1_ = Std.int(this._data.length - this._scrollPositionH);
				}
				_loc2_ = 0;
				while (_loc2_ < _loc1_) {
					_loc3_ = Std.int(_loc2_ + this._scrollPositionH);
					_loc4_ = cast Type.createInstance(this.itemRenderer, [_loc3_]);
					_loc4_.x = this.rowHeight * _loc2_ + this.borderSizeH + this.paddingH;
					_loc4_.y = this.borderSizeV + this.paddingV;
					_loc4_.width = this.rowHeight;
					_loc4_.height = this._height - this.borderSizeV * 2 - this.paddingV * 2;
					_loc4_.data = As3.arrAt(this._data, _loc3_);
					_loc4_.selected = As3.truthy(As3.arrAt(this._dataMap, _loc3_));
					this.addItemEvent(_loc4_);
					this._content.addChild(_loc4_);
					_loc2_++;
				}
			} else {
				_loc1_ = Std.int(this._pageSizeV);
				if (this._scrollPositionV + this._pageSizeV > this._data.length) {
					_loc1_ = Std.int(this._data.length - this._scrollPositionV);
				}
				_loc2_ = 0;
				while (_loc2_ < _loc1_) {
					_loc3_ = Std.int(_loc2_ + this._scrollPositionV);
					_loc4_ = cast Type.createInstance(this.itemRenderer, [_loc3_]);
					_loc4_.y = this.rowHeight * _loc2_ + this.borderSizeV + this.paddingV;
					_loc4_.x = this.borderSizeH + this.paddingH;
					_loc4_.width = this._width - this.borderSizeH * 2 - this.paddingH * 2;
					_loc4_.height = this.rowHeight;
					_loc4_.labelField = this.labelField;
					_loc4_.data = As3.arrAt(this._data, _loc3_);
					_loc4_.selected = As3.truthy(As3.arrAt(this._dataMap, _loc3_));
					this.addItemEvent(_loc4_);
					this._content.addChild(_loc4_);
					_loc2_++;
				}
			}
		}
		this.onRebuildComplete();
	}

	// ListBase.as:205-213
	public function getItemAt(param1:UInt):Dynamic {
		var _loc2_:Dynamic = null;
		if (param1 < this._data.length && param1 > -1) {
			_loc2_ = this._data[param1];
		}
		return _loc2_;
	}

	// ListBase.as:215-219（set）与 :414-417（get）合成一对
	public var selectedItem(get, set):Dynamic;

	private function set_selectedItem(param1:Dynamic):Dynamic {
		this._selectedItem = param1;
		this.setSelectedItem();
		return param1;
	}

	private function get_selectedItem():Dynamic {
		return this._selectedItem;
	}

	// ListBase.as:221-236（`...rest` → rest 参数数组，见类头 ⑥）
	public function addItemAt(param1:Int, rest:Array<Dynamic> = null):Void {
		var _loc3_:Int = 0;
		if (param1 < this._data.length && param1 > -1) {
			_loc3_ = rest.length - 1;
			while (_loc3_ >= 0) {
				// AS3 splice(idx,0,item) 的零删插入 → insert
				this._data.insert(param1, rest[_loc3_]);
				this._dataMap.insert(param1, false);
				_loc3_--;
			}
			this.updateScrollProperties();
			this.delayCall(this.rebuild);
		}
	}

	// ListBase.as:238-243
	private function onItemSelect(param1:Event):Void {
		var _loc2_:DisplayObject = cast param1.currentTarget;
		this.setItemRenderSelected(cast _loc2_);
		this.dispatchEvent(new Event(Event.CHANGE));
	}

	// ListBase.as:245-257（for-in 稠密数组 → 索引循环，见类头 ①）
	private function getSelectedItems():Array<Dynamic> {
		this._selectedItems = [];
		var _loc1_:Int = 0;
		while (_loc1_ < this._dataMap.length) {
			if (As3.truthy(this._dataMap[_loc1_])) {
				this._selectedItems.push(As3.arrAt(this._data, _loc1_));
			}
			_loc1_++;
		}
		return this._selectedItems;
	}

	// ListBase.as:259-262
	private function removeItemEvent(param1:DisplayObject):Void {
		param1.removeEventListener(MouseEvent.CLICK, this.onItemSelect);
	}

	// ListBase.as:264-276（for-in 稠密数组 → 索引循环；命中后 break 前的
	// 参数回写保持原变量名）
	public function removeItem(param1:Dynamic):Dynamic {
		var _loc2_:Int = 0;
		while (_loc2_ < this._data.length) {
			if (this._data[_loc2_] == param1) {
				param1 = this.removeItemAt(_loc2_);
				break;
			}
			_loc2_++;
		}
		return param1;
	}

	// ListBase.as:278-286
	private function updateItemRender():Void {
		var _loc1_:Int = this._content.numChildren - 1;
		while (_loc1_ >= 0) {
			this.updateItemRenderAt(_loc1_);
			_loc1_--;
		}
	}

	// ListBase.as:288-291（get）与 :500-508（set）合成一对
	public var dataProvider(get, set):Array<Dynamic>;

	private function get_dataProvider():Array<Dynamic> {
		return this._data;
	}

	private function set_dataProvider(param1:Array<Dynamic>):Array<Dynamic> {
		this._data = param1;
		this.deSelectAll();
		this._scrollPositionV = 0;
		this._scrollPositionH = 0;
		this.updateScrollProperties();
		this.rebuild();
		return param1;
	}

	// ListBase.as:293-301
	private function setSelectedIndex():Void {
		if (!this.allowMultipleSelection) {
			this.deSelectAll();
		}
		As3.arrPut(this._dataMap, this._selectedIndex, true);
		this.updateItemRender();
	}

	// ListBase.as:303-306
	private function addItemEvent(param1:DisplayObject):Void {
		param1.addEventListener(MouseEvent.CLICK, this.onItemSelect, false, 0, true);
	}

	// ListBase.as:308-329（双重 for-in → 双重索引循环，见类头 ①）
	private function setSelectedItems():Void {
		var _loc1_:Array<Dynamic> = null;
		var _loc2_:Int = 0;
		var _loc3_:Int = 0;
		if (this.allowMultipleSelection) {
			_loc1_ = [];
			_loc2_ = 0;
			while (_loc2_ < this._selectedItems.length) {
				_loc3_ = 0;
				while (_loc3_ < this._data.length) {
					if (this._data[_loc3_] == this._selectedItems[_loc2_]) {
						_loc1_.push(_loc3_);
						break;
					}
					_loc3_++;
				}
				_loc2_++;
			}
			this.selectedIndices = _loc1_;
		}
	}

	// ListBase.as:331-348。PORT-NOTE: AS3 Object 形参改标 ListItemRenderer
	// （运行期恒为 itemRenderer 实例），index/data 取真属性；`!map[i]` 的
	// undefined 取反经 arrAt+truthy 显式化
	private function setItemRenderSelected(param1:ListItemRenderer):Void {
		var _loc2_:Int = As3.intOf(param1.index);
		var _loc3_:Dynamic = param1.data;
		this._selectedIndex = _loc2_;
		this._selectedItem = _loc3_;
		this._selectedItemRenderer.push(param1);
		if (this.allowMultipleSelection) {
			As3.arrPut(this._dataMap, this._selectedIndex, !As3.truthy(As3.arrAt(this._dataMap, this._selectedIndex)));
		} else {
			this.deSelectAll();
			As3.arrPut(this._dataMap, this._selectedIndex, true);
		}
		this.updateItemRender();
	}

	// ListBase.as:350-399
	private function updateScrollProperties():Void {
		var _loc1_:Int = 0;
		var _loc2_:Int = 0;
		var _loc3_:Int = 0;
		if (this.direction == Direction.HORIZONTAL) {
			_loc1_ = As3.truthy(this._data) ? this._data.length : 0;
			_loc2_ = _loc1_;
			if (this.rowCount > 0) {
				this._width = this.rowHeight * this.rowCount + this.borderSizeH * 2;
				_loc2_ = _loc1_;
				this._pageSizeH = this.rowCount;
			} else {
				_loc2_ = _loc1_ - this.rowCount + 1;
				this._pageSizeH = Math.ceil(this._width / this.rowHeight);
			}
			if (_loc2_ > 1) {
				this._maxScrollPositionH = _loc2_;
			} else {
				this._maxScrollPositionH = 1;
			}
		} else {
			if (this.rowCount > 0) {
				this._height = this.rowHeight * this.rowCount + this.borderSizeV * 2;
			}
			this._pageSizeV = Math.ceil(this._height / this.rowHeight);
			_loc1_ = As3.truthy(this._data) ? this._data.length : 0;
			_loc3_ = _loc1_ - this.rowCount + 1;
			if (_loc3_ > 1) {
				this._maxScrollPositionV = _loc3_;
			} else {
				this._maxScrollPositionV = 1;
			}
		}
		this.updateScrollBar();
		this.setSize();
	}

	// ListBase.as:401-412。PORT-NOTE: AS3 把 splice 的返回数组赋给 Object
	// 再 return（调用方仅作真值判），照抄
	public function removeItemAt(param1:Int):Dynamic {
		var _loc2_:Dynamic = null;
		if (param1 < this._data.length && param1 > -1) {
			_loc2_ = this._data.splice(param1, 1);
			this._dataMap.splice(param1, 1);
			this.updateScrollProperties();
			this.delayCall(this.rebuild);
		}
		return _loc2_;
	}

	// ListBase.as:419-430（for-in 稠密数组 → 索引循环，见类头 ①）
	private function setSelectedItem():Void {
		var _loc1_:Int = 0;
		while (_loc1_ < this._data.length) {
			if (this._selectedItem == this._data[_loc1_]) {
				this.selectedIndex = _loc1_;
				break;
			}
			_loc1_++;
		}
	}

	// ListBase.as:432-436（set）与 :489-492（get）合成一对
	public var selectedItems(get, set):Array<Dynamic>;

	private function set_selectedItems(param1:Array<Dynamic>):Array<Dynamic> {
		this._selectedItems = param1;
		this.setSelectedItems();
		return param1;
	}

	private function get_selectedItems():Array<Dynamic> {
		return this.getSelectedItems();
	}

	// ListBase.as:438-448（for-in over rest → 索引循环，见类头 ①⑥）
	public function addItem(rest:Array<Dynamic> = null):Void {
		var _loc2_:Int = 0;
		while (_loc2_ < rest.length) {
			this._data.push(rest[_loc2_]);
			this._dataMap.push(false);
			_loc2_++;
		}
		this.updateScrollProperties();
		this.delayCall(this.rebuild);
	}

	// ListBase.as:450-462（for-in 稠密数组 → 索引循环；推入 Int 而非
	// AS3 的字符串键，消费点全经 int() 强制，见类头 ①）
	private function getSelectedIndices():Array<Dynamic> {
		this._selectedIndices = [];
		var _loc1_:Int = 0;
		while (_loc1_ < this._dataMap.length) {
			if (As3.truthy(this._dataMap[_loc1_])) {
				this._selectedIndices.push(_loc1_);
			}
			_loc1_++;
		}
		return this._selectedIndices;
	}

	// ListBase.as:464-476（for-each → 元素循环，下标值经 intOf 截断）
	private function setSelectedIndices():Void {
		var _loc1_:Dynamic = null;
		if (this.allowMultipleSelection) {
			this.deSelectAll();
			for (_loc1_ in this._selectedIndices) {
				As3.arrPut(this._dataMap, As3.intOf(_loc1_), true);
			}
		}
		this.updateItemRender();
	}

	// ListBase.as:478-481
	override private function onScrollChange(param1:ScrollEvent):Void {
		this.rebuild();
	}

	// ListBase.as:483-487
	public function scrollToSelected():Void {
		var _loc1_:Int = As3.intOf(As3.arrAt(this.selectedIndices, 0));
		this.scrollToIndex(_loc1_);
	}

	// ListBase.as:494-498（set）与 :510-518（get）合成一对
	public var selectedIndex(get, set):Int;

	private function set_selectedIndex(param1:Int):Int {
		this._selectedIndex = param1;
		this.setSelectedIndex();
		return param1;
	}

	private function get_selectedIndex():Int {
		var _loc1_:Array<Dynamic> = this.getSelectedIndices();
		if (_loc1_.length > 0) {
			return As3.intOf(_loc1_[0]);
		}
		return -1;
	}

	// ListBase.as:520-529。PORT-NOTE: splice(idx,1,item) 的替换 = 删 1 再
	// insert 回原位（TileBase 先例）；返回值仍是删除段数组（同 removeItemAt）
	public function replaceItemAt(param1:Dynamic, param2:UInt):Dynamic {
		var _loc3_:Dynamic = null;
		if (param2 < this._data.length && param2 > -1) {
			_loc3_ = this._data.splice(param2, 1);
			this._data.insert(param2, param1);
			this.delayCall(this.rebuild);
		}
		return _loc3_;
	}
}
