package module.shop.widgets;

import com.qzone.qui.containers.HBox;
import com.qzone.qui.containers.TileList;
import com.qzone.qui.controls.Button;
import com.qzone.qui.controls.Label;
import com.qzone.qui.controls.scrollClasses.ScrollPolicy;
import com.qzone.qui.core.Align;
import com.qzone.qui.makers.RadioGroup;
import com.qzone.qui.utils.TextFormatUtil;
import common.Consts;
import common.Language;
import common.misc.Utils;
import common.view.window.WindowLabelMaker;
import entities.Item;
import framework.base.BasePage;
import openfl.display.DisplayObjectContainer;
import openfl.display.Shape;
import openfl.events.Event;
import openfl.events.MouseEvent;
import shim.As3;

/**
 * module.shop.widgets.ItemsPage —— ItemsPage.as 逐句对应（issue #35 功能
 * swf 翻译：商店）。道具页：常规/武器两组单选页签（HBox 顶条），groupTools
 * 把道具按武器/有机肥(30..99 与 9104..9106 倒序)/藏獒/其余四组重排进
 * normalCache，武器单独 weaponCache；页签切换换瓦片数据与高度。
 *
 * PORT-NOTE: 原版 groupTools 尾部 `this._normalCache.splice(0,-1)` 的
 * deleteCount 为负、AS3 下不删任何元素（赋值给 _loc4_ 的替换才是实际
 * 生效的重排），照抄保留这一原版无效语句（Haxe splice 同样负数不删）。
 */
class ItemsPage extends BasePage {
	// ItemsPage.as:10（AS3 实例 const → Haxe static final 字面量）
	private static final _tile_top:Int = 23;

	// ItemsPage.as:12
	private var _weaponCache:Array<Dynamic>;

	// ItemsPage.as:14
	private var _filterType:String;

	// ItemsPage.as:16
	private var _label:Label;

	// ItemsPage.as:18
	private static final _tile_height:Int = 275;

	// ItemsPage.as:20
	private var _normalCache:Array<Dynamic>;

	// ItemsPage.as:22-73
	public function new(param1:DisplayObjectContainer, param2:Int, param3:Int) {
		var _loc4_:HBox = null;
		super(param1, param2, param3);
		this._filterType = "normal";
		this._normalCache = null;
		this._weaponCache = null;
		this._label = new Label(Reflect.field(Language.L, "toolTileDirection"));
		this._label.x = 2;
		this._label.width = param2 - 5;
		WindowLabelMaker.addTarget(this._label);
		addChild(this._label);
		_loc4_ = new HBox(param2 - 2, 27);
		_loc4_.verticalScrollPolicy = ScrollPolicy.OFF;
		_loc4_.horizontalScrollPolicy = ScrollPolicy.OFF;
		_loc4_.alignH = Align.LEFT;
		_loc4_.alignV = Align.TOP;
		_loc4_.paddingH = 10;
		_loc4_.paddingV = 0;
		_loc4_.defaultSkin = null;
		_loc4_.backgroundColor = 14219772;
		_loc4_.backgroundAlpha = 1;
		_loc4_.addEventListener(MouseEvent.CLICK, this.onToolTypeClicked);
		this.addChild(_loc4_);
		var _loc5_:Button = new Button("常规道具");
		_loc5_.name = "normal";
		_loc5_.defaultSkin = Shape;
		_loc5_.selectedSkin = Utils.getClass("SeedTypeBtnSelectedSkin");
		_loc5_.useHandCursor = true;
		_loc5_.textSelectedFormat = TextFormatUtil.clone(_loc5_.textSelectedFormat);
		_loc5_.textSelectedFormat.color = 16777215;
		_loc5_.textSelectedFormat.bold = true;
		_loc5_.textDefaultFormat = TextFormatUtil.clone(_loc5_.textDefaultFormat);
		_loc5_.textDefaultFormat.color = 3785720;
		_loc5_.textOverFormat = TextFormatUtil.clone(_loc5_.textOverFormat);
		_loc5_.textOverFormat.color = null;
		_loc5_.toggle = true;
		_loc5_.selected = true;
		_loc5_.useHandCursor = true;
		_loc5_.height = 25;
		var _loc6_:Button = new Button("武器");
		_loc6_.name = "weapon";
		_loc6_.defaultSkin = _loc5_.defaultSkin;
		_loc6_.selectedSkin = _loc5_.selectedSkin;
		_loc6_.textDefaultFormat = _loc5_.textDefaultFormat;
		_loc6_.textSelectedFormat = _loc5_.textSelectedFormat;
		_loc6_.textOverFormat = _loc5_.textOverFormat;
		_loc6_.toggle = true;
		_loc6_.useHandCursor = true;
		_loc6_.height = 25;
		var _loc7_:RadioGroup = new RadioGroup();
		_loc7_.addTarget(_loc5_);
		_loc4_.addElement(_loc5_);
		_loc7_.addTarget(_loc6_);
		_loc4_.addElement(_loc6_);
		this._label.y += _loc4_.height;
	}

	// ItemsPage.as:75-95
	override private function onCreateTile():Void {
		if (this._tile != null) {
			this._tile.paddingH = 23;
			this._tile.paddingV = 10;
			this._tile.gapH = 0;
			this._tile.gapV = 0;
			this._tile.tileWidth = 90;
			this._tile.tileHeight = 98;
			this._tile.defaultSkin = null;
			this._tile.horizontalScrollPolicy = ScrollPolicy.OFF;
			this._tile.itemRenderer = ToolItem;
			this._tile.y = _tile_top + this._label.height + 3;
			this._tile.width = this._preferedWidth - 5;
			this._tile.height = _tile_height;
		}
	}

	// ItemsPage.as:97-135（for-each 实体列表 → typed cast 迭代，
	// FarmLandModel:1288 先例）
	private function groupTools(param1:Array<Dynamic>):Void {
		var _loc3_:Array<Dynamic> = null;
		var _loc4_:Array<Dynamic> = null;
		var _loc5_:Array<Dynamic> = null;
		this._normalCache = [];
		this._weaponCache = [];
		var _loc2_:Item = null;
		var typedParam:Array<Item> = cast param1;
		for (_loc2_ in typedParam) {
			if (Std.string(_loc2_._type) == Consts.ITEM_TYPE_WEAPON) {
				this._weaponCache.push(_loc2_);
			} else {
				this._normalCache.push(_loc2_);
			}
		}
		_loc3_ = [];
		_loc4_ = [];
		_loc5_ = [];
		var typedNormal:Array<Item> = cast this._normalCache;
		for (_loc2_ in typedNormal) {
			if (_loc2_._id >= Consts.ORGANIC_FERTILIZER_ID && _loc2_._id < 100 || _loc2_._id >= 9104 && _loc2_._id <= 9106) {
				_loc3_.push(_loc2_);
			} else if (_loc2_._isQDDog) {
				_loc5_.push(_loc2_);
			} else {
				_loc4_.push(_loc2_);
			}
		}
		As3.sortOnDesc(_loc3_, "_id");
		var typedQd:Array<Item> = cast _loc5_;
		for (_loc2_ in typedQd) {
			_loc4_.unshift(_loc2_);
		}
		var typedOrganic:Array<Item> = cast _loc3_;
		for (_loc2_ in typedOrganic) {
			_loc4_.unshift(_loc2_);
		}
		// 原版无效语句（deleteCount 为负），见类头 PORT-NOTE
		this._normalCache.splice(0, -1);
		this._normalCache = _loc4_;
	}

	// ItemsPage.as:137-152
	override private function set_dataList(param1:Array<Dynamic>):Array<Dynamic> {
		if (this._tile == null) {
			this._tile = new TileList();
			this.onCreateTile();
			addChild(this._tile);
		}
		this.groupTools(param1);
		if (this._filterType == "normal") {
			this._tile.dataProvider = this._normalCache;
		} else if (this._filterType == "weapon") {
			this._tile.dataProvider = this._weaponCache;
		}
		return param1;
	}

	// ItemsPage.as:154-187
	private function onToolTypeClicked(param1:Event):Void {
		if (param1 == null) {
			return;
		}
		var _loc2_:Button = Std.isOfType(param1.target, Button) ? cast(param1.target, Button) : null;
		if (_loc2_ != null && this._filterType != _loc2_.name) {
			this._filterType = _loc2_.name;
			if (this._tile == null) {
				return;
			}
			if (this._filterType == "normal") {
				this._tile.y = _tile_top + this._label.height + 3;
				this._label.visible = true;
				this._tile.itemRenderer = ToolItem;
				this._tile.dataProvider = this._normalCache;
				this._tile.height = _tile_height;
				this._tile.scrollVerticalReset();
			} else if (this._filterType == "weapon") {
				this._tile.y = _tile_top;
				this._label.visible = false;
				this._tile.itemRenderer = ToolItem;
				this._tile.dataProvider = this._weaponCache;
				this._tile.height = _tile_height - this._label.height - 3;
				this._tile.scrollVerticalReset();
			}
		}
	}
}
