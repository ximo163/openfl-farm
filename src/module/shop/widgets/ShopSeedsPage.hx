package module.shop.widgets;

import com.qzone.corelib.controls.ExtLoader;
import com.qzone.qui.containers.HBox;
import com.qzone.qui.containers.TileList;
import com.qzone.qui.controls.Button;
import com.qzone.qui.controls.Label;
import com.qzone.qui.controls.scrollClasses.ScrollPolicy;
import com.qzone.qui.core.Align;
import com.qzone.qui.makers.RadioGroup;
import com.qzone.qui.utils.TextFormatUtil;
import common.Session;
import common.Settings;
import common.misc.Utils;
import common.view.window.WindowLabelMaker;
import entities.Seed;
import framework.base.BasePage;
import openfl.display.DisplayObjectContainer;
import openfl.display.Shape;
import openfl.display.SimpleButton;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.text.TextFieldAutoSize;
import shim.As3;
import shim.QQOutlets;

/**
 * module.shop.widgets.ShopSeedsPage —— ShopSeedsPage.as 逐句对应
 * （issue #35 功能 swf 翻译：商店）。种子页：有机/普通/红土地/黑土地/
 * VIP专属五组单选页签；前四组 90x98 密排 CropItem，VIP 组 149x170
 * CropItemVip + VipSeedTabBg 背景条 + 「开通VIP」SimpleButton（四态都挂
 * _loader2）。groupSeeds 按 isGreen/isVip/isRed/isBlack 分桶，exclude_seeds
 * 配置过滤。
 */
class ShopSeedsPage extends BasePage {
	// ShopSeedsPage.as:11
	private var _loader2:ExtLoader;

	// ShopSeedsPage.as:13
	private var _advancedCache:Array<Dynamic>;

	// ShopSeedsPage.as:15
	private var _vipCache:Array<Dynamic>;

	// ShopSeedsPage.as:17
	private var _isVip:Bool;

	// ShopSeedsPage.as:19
	private var _btnOpenVIP:SimpleButton;

	// ShopSeedsPage.as:21（AS3 实例 const → Haxe static final 字面量）
	private static final _tile_height:Int = 300;

	// ShopSeedsPage.as:23
	private var _normalCache:Array<Dynamic>;

	// ShopSeedsPage.as:25
	private var _greenCache:Array<Dynamic>;

	// ShopSeedsPage.as:27
	private static final _tile_top:Int = 23;

	// ShopSeedsPage.as:29
	private var _blackCache:Array<Dynamic>;

	// ShopSeedsPage.as:31
	private var _filterType:String;

	// ShopSeedsPage.as:33
	private var _label:Label;

	// ShopSeedsPage.as:35
	private var _loader:ExtLoader;

	// ShopSeedsPage.as:37
	private var _excludes:Array<Dynamic>;

	// ShopSeedsPage.as:39-148
	public function new(param1:DisplayObjectContainer, param2:Int, param3:Int) {
		var _loc4_:HBox = null;
		super(param1, param2, param3);
		this._filterType = "green";
		this._normalCache = null;
		this._advancedCache = null;
		_loc4_ = new HBox(param2 - 2, 27);
		_loc4_.verticalScrollPolicy = ScrollPolicy.OFF;
		_loc4_.horizontalScrollPolicy = ScrollPolicy.OFF;
		_loc4_.alignH = Align.LEFT;
		_loc4_.alignV = Align.TOP;
		_loc4_.paddingH = 3;
		_loc4_.paddingV = 0;
		_loc4_.defaultSkin = null;
		_loc4_.backgroundColor = 14219772;
		_loc4_.backgroundAlpha = 1;
		_loc4_.addEventListener(MouseEvent.CLICK, this.onSeedTypeClicked);
		this.addChild(_loc4_);
		var _loc5_:Button = new Button("有机种子");
		_loc5_.name = "green";
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
		_loc5_.width = 80;
		var _loc6_:Button = new Button("普通种子");
		_loc6_.name = "normal";
		_loc6_.defaultSkin = Shape;
		_loc6_.selectedSkin = Utils.getClass("SeedTypeBtnSelectedSkin");
		_loc6_.useHandCursor = true;
		_loc6_.textSelectedFormat = TextFormatUtil.clone(_loc6_.textSelectedFormat);
		_loc6_.textSelectedFormat.color = 16777215;
		_loc6_.textSelectedFormat.bold = true;
		_loc6_.textDefaultFormat = TextFormatUtil.clone(_loc6_.textDefaultFormat);
		_loc6_.textDefaultFormat.color = 3785720;
		_loc6_.textOverFormat = TextFormatUtil.clone(_loc6_.textOverFormat);
		_loc6_.textOverFormat.color = null;
		_loc6_.toggle = true;
		_loc6_.useHandCursor = true;
		_loc6_.height = 25;
		_loc6_.width = 80;
		var _loc7_:Button = new Button("红土地种子");
		_loc7_.name = "advanced";
		_loc7_.defaultSkin = _loc6_.defaultSkin;
		_loc7_.selectedSkin = _loc6_.selectedSkin;
		_loc7_.textDefaultFormat = _loc6_.textDefaultFormat;
		_loc7_.textSelectedFormat = _loc6_.textSelectedFormat;
		_loc7_.textOverFormat = _loc6_.textOverFormat;
		_loc7_.toggle = true;
		_loc7_.useHandCursor = true;
		_loc7_.height = 25;
		var _loc8_:Button = new Button("黑土地种子");
		_loc8_.name = "black";
		_loc8_.defaultSkin = _loc6_.defaultSkin;
		_loc8_.selectedSkin = _loc6_.selectedSkin;
		_loc8_.textDefaultFormat = _loc6_.textDefaultFormat;
		_loc8_.textSelectedFormat = _loc6_.textSelectedFormat;
		_loc8_.textOverFormat = _loc6_.textOverFormat;
		_loc8_.toggle = true;
		_loc8_.useHandCursor = true;
		_loc8_.height = 25;
		var _loc9_:Button = new Button("VIP专属种子");
		_loc9_.name = "vip";
		_loc9_.defaultSkin = _loc6_.defaultSkin;
		_loc9_.selectedSkin = Utils.getClass("SeedTypeVipBtnSelectedSkin");
		_loc9_.textDefaultFormat = TextFormatUtil.clone(_loc6_.textDefaultFormat);
		_loc9_.textDefaultFormat.color = 16618254;
		_loc9_.textSelectedFormat = TextFormatUtil.clone(_loc6_.textSelectedFormat);
		_loc9_.textSelectedFormat.color = 16618254;
		_loc9_.textOverFormat = _loc6_.textOverFormat;
		_loc9_.toggle = true;
		_loc9_.useHandCursor = true;
		_loc9_.height = 25;
		var _loc10_:RadioGroup = new RadioGroup();
		_loc10_.addTarget(_loc5_);
		_loc4_.addElement(_loc5_);
		_loc10_.addTarget(_loc6_);
		_loc4_.addElement(_loc6_);
		_loc10_.addTarget(_loc7_);
		_loc4_.addElement(_loc7_);
		_loc10_.addTarget(_loc8_);
		_loc4_.addElement(_loc8_);
		_loc10_.addTarget(_loc9_);
		_loc4_.addElement(_loc9_);
		this._label = new Label(null, null, TextFieldAutoSize.LEFT);
		this._label.padingH = 35;
		this._label.padingV = 5;
		this._label.x = 2;
		this._label.width = param2 - 5;
		this._label.y += _loc4_.height;
		this._label.height = 30;
		WindowLabelMaker.addTarget(this._label);
		this._label.visible = false;
		addChild(this._label);
		// Boolean(Int) → As3.truthy（0 假、非 0 真）
		this._isVip = As3.truthy(Session.getInstance().host._yellowstatus);
		var _loc11_:String = Settings.getInstance().getStringAttribute("exclude_seeds");
		if (_loc11_ != null && _loc11_ != "") {
			this._excludes = _loc11_.split(",");
		}
	}

	// ShopSeedsPage.as:150-163
	private function seedSort2(param1:Seed, param2:Seed):Int {
		if (param1 == null || param2 == null) {
			return 0;
		}
		var _loc3_:Int = param1._lvl >= param2._lvl ? 1 : -1;
		if (param1._lvl == param2._lvl && !param1._isRed && As3.truthy(param2._isRed)) {
			_loc3_ = -1;
		}
		return _loc3_;
	}

	// ShopSeedsPage.as:165-185
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
			this._tile.itemRenderer = CropItem;
			this._tile.y = _tile_top;
			this._tile.width = this._preferedWidth - 5;
			this._tile.height = _tile_height;
		}
	}

	// ShopSeedsPage.as:187-214
	override private function set_dataList(param1:Array<Dynamic>):Array<Dynamic> {
		if (this._tile == null) {
			this._tile = new TileList();
			this.onCreateTile();
			addChild(this._tile);
		}
		this.groupSeeds(param1);
		if (this._filterType == "green") {
			this._tile.dataProvider = this._greenCache;
		} else if (this._filterType == "normal") {
			this._tile.dataProvider = this._normalCache;
		} else if (this._filterType == "advanced") {
			this._tile.dataProvider = this._advancedCache;
		} else if (this._filterType == "vip") {
			this._tile.dataProvider = this._vipCache;
		} else if (this._filterType == "black") {
			this._tile.dataProvider = this._blackCache;
		}
		return param1;
	}

	// ShopSeedsPage.as:216-221
	private function onNavigateToURL(param1:MouseEvent):Void {
		var _loc2_:String = Settings.getInstance().getStringAttribute("vipSeedLink");
		// ExternalInterface.call → QQOutlets.call（html5-only 通道，CLAUDE.md
		// shim 规则）
		QQOutlets.call("window.open", _loc2_);
	}

	// ShopSeedsPage.as:223-236
	private function seedSort(param1:Seed, param2:Seed):Int {
		if (param1 == null || param2 == null) {
			return 0;
		}
		var _loc3_:Int = param1._lvl > param2._lvl ? 1 : -1;
		if (param1._lvl == param2._lvl) {
			_loc3_ = param1._id > param2._id ? 1 : -1;
		}
		return _loc3_;
	}

	// ShopSeedsPage.as:238-283（`_isMill != true`：Int 与 Boolean 松散比，
	// true→1，即 `_isMill != 1`；for-each 实体列表 → typed cast 迭代，
	// FarmLandModel:1288 先例）
	private function groupSeeds(param1:Array<Dynamic>):Void {
		var _loc2_:Seed = null;
		this._normalCache = [];
		this._advancedCache = [];
		this._vipCache = [];
		this._blackCache = [];
		this._greenCache = [];
		var typed:Array<Seed> = cast param1;
		for (_loc2_ in typed) {
			if (_loc2_._isMill != 1) {
				if (!(this._excludes != null && this._excludes.indexOf(Std.string(_loc2_._id)) != -1)) {
					if (_loc2_._isGreen == true) {
						this._greenCache.push(_loc2_);
					} else if (_loc2_._isVip == 1) {
						this._vipCache.push(_loc2_);
					} else if (_loc2_._isRed == true) {
						this._advancedCache.push(_loc2_);
					} else if (_loc2_._isBlack == true) {
						this._blackCache.push(_loc2_);
					} else {
						this._normalCache.push(_loc2_);
					}
				}
			}
		}
		this._normalCache.sort(this.seedSort);
		this._advancedCache.sort(this.seedSort);
		this._vipCache.sort(this.seedSort);
	}

	// ShopSeedsPage.as:285-373
	private function onSeedTypeClicked(param1:Event):Void {
		var _loc3_:Array<Dynamic> = null;
		var _loc4_:String = null;
		if (param1 == null) {
			return;
		}
		var _loc2_:Button = Std.isOfType(param1.target, Button) ? cast(param1.target, Button) : null;
		if (_loc2_ != null && this._filterType != _loc2_.name) {
			this._filterType = _loc2_.name;
			if (this._tile == null) {
				return;
			}
			_loc3_ = null;
			if (this._filterType == "green") {
				_loc3_ = this._greenCache;
			} else if (this._filterType == "normal") {
				_loc3_ = this._normalCache;
			} else if (this._filterType == "advanced") {
				_loc3_ = this._advancedCache;
			} else if (this._filterType == "black") {
				_loc3_ = this._blackCache;
			}
			if (this._filterType == "green" || this._filterType == "normal" || this._filterType == "advanced" || this._filterType == "black") {
				this._tile.tileWidth = 90;
				this._tile.tileHeight = 98;
				this._tile.y = _tile_top;
				this._label.visible = false;
				this._tile.itemRenderer = CropItem;
				this._tile.dataProvider = _loc3_;
				this._tile.height = _tile_height;
				if (this._loader != null) {
					this._loader.visible = false;
				}
				if (this._btnOpenVIP != null) {
					this._btnOpenVIP.visible = false;
				}
				this._tile.scrollVerticalReset();
			} else if (this._filterType == "vip") {
				this._tile.tileWidth = 149;
				this._tile.tileHeight = 170;
				this._tile.y = _tile_top;
				this._tile.itemRenderer = CropItemVip;
				this._tile.dataProvider = this._vipCache;
				this._tile.height = _tile_height - this._label.height - 3;
				this._tile.y = _tile_top + this._label.height + 3;
				if (this._isVip) {
					this._label.text = Settings.getInstance().getDynamicTip("shopVipTip");
				} else {
					this._label.text = Settings.getInstance().getDynamicTip("shopUnvipTip");
				}
				this._label.visible = true;
				if (this._loader == null) {
					this._loader = new ExtLoader();
					this._loader.y = 29;
					this._loader.x = 1;
					this._loader.load(Settings.getInstance().getSecondUrl("VipSeedTabBg"));
					addChildAt(this._loader, 0);
				} else {
					this._loader.visible = true;
				}
				if (this._loader2 == null) {
					_loc4_ = this._isVip ? Settings.getInstance().getSecondUrl("VipSeedButtonVip") : Settings.getInstance().getSecondUrl("VipSeedButtonNonVip");
					this._loader2 = new ExtLoader();
					this._loader2.load(Utils.addPrefix(_loc4_));
				}
				if (this._btnOpenVIP == null) {
					this._btnOpenVIP = new SimpleButton();
					this._btnOpenVIP.hitTestState = this._loader2;
					this._btnOpenVIP.upState = this._loader2;
					this._btnOpenVIP.downState = this._loader2;
					this._btnOpenVIP.overState = this._loader2;
					this._btnOpenVIP.x = 355;
					this._btnOpenVIP.y = _tile_top;
					this._btnOpenVIP.addEventListener(MouseEvent.CLICK, this.onNavigateToURL);
					addChild(this._btnOpenVIP);
				} else {
					this._btnOpenVIP.visible = true;
				}
				this._tile.scrollVerticalReset();
			}
		}
	}
}
