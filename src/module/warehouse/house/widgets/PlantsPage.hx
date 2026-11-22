package module.warehouse.house.widgets;

import com.qzone.qui.containers.Canvas;
import com.qzone.qui.containers.TileList;
import com.qzone.qui.controls.Button;
import com.qzone.qui.controls.Label;
import com.qzone.qui.controls.scrollClasses.ScrollPolicy;
import common.Consts;
import common.Language;
import common.Session;
import common.Settings;
import common.misc.QzoneJSAPI;
import common.misc.Utils;
import common.view.Line;
import common.view.window.WindowLabelMaker;
import entities.Player;
import entities.WarehouseCrop;
import events.CommonEvent;
import events.ViewEvent;
import openfl.display.Sprite;
import openfl.events.MouseEvent;
import openfl.events.TextEvent;
import openfl.filters.GlowFilter;
import openfl.text.TextField;
import openfl.text.TextFieldAutoSize;
import openfl.text.TextFormat;
import framework.base.BasePage;
import module.uitools.widgets.profile.PropertyText;
import module.warehouse.house.WarehouseController;
import module.warehouse.house.WarehouseView;
import shim.As3;

/**
 * module.warehouse.house.widgets.PlantsPage —— PlantsPage.as 逐句对应
 * （issue #36 功能 swf 翻译：仓库）。蔬果/鲜花页（_isFlowerPage 分流）：
 * 底部合计金币（财神爷/仙皇按 myFairy 加成）+「卖出」按钮（疲劳时段确认
 * 框）+ 鲜花页专属「包装花束赠送」切换视图（FlowerRenderItem 两段瓦片，
 * 可包装/材料不足分组）。视觉参数逐字照抄。
 *
 * PORT-NOTE: `Language.L["…"]` → Reflect.field；`["k"] == 数` 宽松等值 →
 * As3.floatOf、`== true` → As3.truthy、`!= undefined` → As3.hasProp；
 * `parseInt(设置串)` → As3.intOf(As3.parseInt(...))（AS3 隐式 Number→int
 * 截断）；for-each → 外层 var + 循环内回填（FFDec 顶部声明照译）；
 * `_loc4_["mode"] = 0` 的 Dynamic 匿名对象写 → Reflect.setField；
 * `this._sum.toString()` → Std.string；onCreateTile/setData 原文 protected
 * → private 覆写。
 */
class PlantsPage extends BasePage {
	// PlantsPage.as:35
	private var _tfEmpty:TextField;

	// PlantsPage.as:37
	private var _tfPrice:TextField;

	// PlantsPage.as:39
	private var _sum:Float;

	// PlantsPage.as:41
	private var _yellowTip:Label;

	// PlantsPage.as:43
	private var _sendFlowerBtn:Button;

	// PlantsPage.as:45
	private var _sumPrice:PropertyText;

	// PlantsPage.as:47
	private var _warehouseType:Int;

	// PlantsPage.as:49
	private var _gotoShopBtn:Button;

	// PlantsPage.as:51
	private var _sellBtn:Button;

	// PlantsPage.as:53
	private var _canvas:Canvas;

	// PlantsPage.as:55
	private var _isFlowerPage:Bool;

	// PlantsPage.as:57
	private var _sendFlowerContainer:Sprite;

	// PlantsPage.as:59-123
	public function new(param1:WarehouseView, param2:Int, param3:Int, param4:Bool) {
		super(param1, param2, param3);
		this._isFlowerPage = param4;
		if (this._isFlowerPage) {
			this._warehouseType = Consts.WAREHOUSE_FLOWER;
		} else {
			this._warehouseType = Consts.WAREHOUSE_CROP;
		}
		this.createSendFlower();
		this._sendFlowerContainer.visible = false;
		this._yellowTip = new Label();
		this._yellowTip.text = Reflect.field(Language.L, "warehouseDirection");
		this._yellowTip.x = 2;
		this._yellowTip.width = param2 - 3;
		WindowLabelMaker.addTarget(this._yellowTip);
		this._sellBtn = new Button();
		this._sellBtn.width = 85;
		this._sellBtn.height = 25;
		this._sellBtn.defaultSkin = Utils.getClass("ButtonGreen");
		this._sellBtn.x = param2 - this._sellBtn.width - 15;
		this._sellBtn.y = param3 - this._sellBtn.height - 4;
		this._sellBtn.text = Reflect.field(Language.L, "sellSome");
		this._sellBtn.addEventListener(MouseEvent.ROLL_OVER, this.onSellBtnOver);
		this._sellBtn.addEventListener(MouseEvent.ROLL_OUT, this.onSellBtnOut);
		this._sellBtn.addEventListener(MouseEvent.CLICK, this.onSellBtnClicked);
		addChild(this._sellBtn);
		if (this._isFlowerPage == true && QzoneJSAPI.QPLUS == false && QzoneJSAPI.WB == false) {
			this._sendFlowerBtn = new Button();
			this._sendFlowerBtn.width = 85;
			this._sendFlowerBtn.height = 25;
			this._sendFlowerBtn.defaultSkin = Utils.getClass("ButtonBlue");
			this._sendFlowerBtn.x = this._sellBtn.x - this._sendFlowerBtn.width - 15;
			this._sendFlowerBtn.y = param3 - this._sendFlowerBtn.height - 4;
			this._sendFlowerBtn.cacheAsBitmap = true;
			this._sendFlowerBtn.text = "送给好友花束";
			this._sendFlowerBtn.clickFn = this.onSendFlowerBtn;
			addChild(this._sendFlowerBtn);
		}
		this._tfPrice = new TextField();
		this._tfPrice.selectable = false;
		this._tfPrice.defaultTextFormat = new TextFormat("Verdana", 12, 39423, true);
		this._tfPrice.autoSize = TextFieldAutoSize.LEFT;
		this._tfPrice.text = Reflect.field(Language.L, "sumGold");
		this._tfPrice.x = 8;
		this._tfPrice.y = param3 - this._tfPrice.height - 4;
		addChild(this._tfPrice);
		var _loc5_:Dynamic = Session.getInstance().myFairy;
		if (_loc5_ != null && (As3.floatOf(Reflect.field(_loc5_, "itemId")) == Consts.FAIRY_MONEY || As3.floatOf(Reflect.field(_loc5_, "itemId")) == Consts.FAIRY_GOD)) {
			this._sumPrice = new PropertyText("gold", 180, false);
			this._sumPrice.x = this._tfPrice.width + this._tfPrice.x - 7;
		} else {
			this._sumPrice = new PropertyText("gold", 180, true);
			this._sumPrice.x = this._tfPrice.width + this._tfPrice.x;
		}
		this._sumPrice.y = param3 - this._sumPrice.height;
		addChild(this._sumPrice);
	}

	// PlantsPage.as:125-128
	private function onOK():Void {
		this.controller.model.sellAll(this._warehouseType);
	}

	// PlantsPage.as:130-137
	private function onNotEnough(param1:ViewEvent):Void {
		if (param1 == null || param1.data == null) {
			return;
		}
		this.controller.openWindow(Consts.WINDOW_NAME_SENDFLOWER, param1.data);
	}

	// PlantsPage.as:139-184
	private function sumUp():Void {
		var _loc6_:WarehouseCrop = null;
		var _loc6In:Dynamic = null;
		var _loc7_:Dynamic = null;
		var _loc1_:Float = 0;
		var _loc2_:Float = 0;
		var _loc3_:Array<Dynamic> = this.dataList;
		var _loc4_:Array<Dynamic> = null;
		var _loc5_:String = Settings.getInstance().getStringAttribute("exclude_seeds");
		if (_loc5_ != null && _loc5_ != "") {
			_loc4_ = _loc5_.split(",");
		}
		for (_loc6In in _loc3_) {
			_loc6_ = _loc6In;
			if (_loc6_._isLock != 1) {
				if (_loc6_._high_price > 0) {
					_loc1_ += _loc6_._high_price * _loc6_._amount;
				} else {
					_loc1_ += _loc6_._price * _loc6_._amount;
				}
				if (_loc4_ != null && _loc4_.indexOf(Std.string(_loc6_._id)) != -1) {
					_loc2_ += _loc6_._price * _loc6_._amount;
				}
			}
		}
		this._sum = _loc1_;
		_loc7_ = Session.getInstance().myFairy;
		if (_loc7_ != null && (As3.floatOf(Reflect.field(_loc7_, "itemId")) == Consts.FAIRY_MONEY || As3.floatOf(Reflect.field(_loc7_, "itemId")) == Consts.FAIRY_GOD)) {
			this._sum -= _loc2_;
			this._sum *= 1 + As3.floatOf(Reflect.field(_loc7_, "rate")) / 100;
			this._sum += _loc2_;
			this._sum = Math.floor(this._sum);
			this._sumPrice.text = Std.string(this._sum)
				+ (As3.floatOf(Reflect.field(_loc7_, "itemId")) == Consts.FAIRY_MONEY ? " 财神爷加成" : " 仙皇加成")
				+ Std.string(Reflect.field(_loc7_, "rate")) + "%";
		} else {
			this._sumPrice.text = Std.string(this._sum);
		}
	}

	// PlantsPage.as:186-202（AS3 protected → private 覆写）
	override private function onCreateTile():Void {
		if (_tile != null) {
			_tile.paddingH = 30;
			_tile.gapH = 0;
			_tile.gapV = 0;
			_tile.tileWidth = 90;
			_tile.tileHeight = 90;
			_tile.defaultSkin = null;
			_tile.horizontalScrollPolicy = ScrollPolicy.OFF;
			_tile.itemRenderer = PlantRenderItem;
			_tile.y = 20;
			_tile.width = _preferedWidth - 2;
			_tile.height = 260;
		}
	}

	// PlantsPage.as:204-212
	private function onSellBtnOut(param1:MouseEvent):Void {
		var _loc2_:WarehouseController = this.controller;
		if (_loc2_ == null) {
			return;
		}
		_loc2_.hideTip();
	}

	// PlantsPage.as:214-222
	private function onSellBtnOver(param1:MouseEvent):Void {
		var _loc2_:WarehouseController = this.controller;
		if (_loc2_ == null) {
			return;
		}
		_loc2_.showTip(Consts.TIP_NAME_MOUSE, Reflect.field(Language.L, "sellSomeTip"));
	}

	// PlantsPage.as:224-231
	private function onPreviewFlower(param1:ViewEvent):Void {
		if (param1 == null || param1.data == null || !As3.hasProp(param1.data, "fId")) {
			return;
		}
		FlowerPlayer.play(this.controller.module.app.farmView, this.controller.model.flowerPath, As3.intOf(Reflect.field(param1.data, "fId")));
	}

	// PlantsPage.as:233-236
	private function onSendFlowerBtn(param1:MouseEvent):Void {
		this.switchSendFlowerView(true);
	}

	// PlantsPage.as:238-246
	private var controller(get, never):WarehouseController;

	private function get_controller():WarehouseController {
		var _loc1_:WarehouseView = Std.isOfType(this._view, WarehouseView) ? cast(this._view, WarehouseView) : null;
		if (_loc1_ == null) {
			return null;
		}
		return _loc1_.controller;
	}

	// PlantsPage.as:248-294
	public function switchSendFlowerView(param1:Bool):Void {
		var _loc2_:Array<Dynamic> = null;
		if (this._isFlowerPage == false) {
			return;
		}
		this._sumPrice.visible = !param1;
		this._tfPrice.visible = !param1;
		this._sendFlowerBtn.visible = !param1;
		this._sellBtn.visible = !param1;
		if (_tile != null) {
			_tile.visible = !param1;
		}
		if (this._tfEmpty != null) {
			this._tfEmpty.visible = !param1;
		}
		if (this._gotoShopBtn != null) {
			this._gotoShopBtn.visible = !param1;
		}
		this.showAllFlowers();
		this._canvas.validateNow();
		this._sendFlowerContainer.visible = param1;
		if (param1 == true) {
			this._yellowTip.text = Settings.getInstance().getStringAttribute("flowerDayTips");
		} else {
			this._yellowTip.text = Reflect.field(Language.L, "warehouseDirection");
			_loc2_ = super.dataList;
			if (_loc2_ == null || _loc2_.length == 0) {
				if (this._tfEmpty != null) {
					this._tfEmpty.visible = true;
				}
				if (this._gotoShopBtn != null) {
					this._gotoShopBtn.visible = true;
				}
			}
		}
	}

	// PlantsPage.as:296-332
	private function createSendFlower():Void {
		if (this._sendFlowerContainer == null) {
			this._sendFlowerContainer = new Sprite();
			addChild(this._sendFlowerContainer);
		}
		var _loc1_:TextField = new TextField();
		_loc1_.mouseEnabled = _loc1_.selectable = false;
		_loc1_.width = 130;
		_loc1_.defaultTextFormat = new TextFormat("黑体", 18, 6397281, true);
		_loc1_.text = "包装花束赠送";
		_loc1_.x = 185;
		_loc1_.y = 22;
		this._sendFlowerContainer.addChild(_loc1_);
		var _loc2_:TextField = new TextField();
		_loc2_.selectable = false;
		_loc2_.defaultTextFormat = new TextFormat("Verdana", 12, 5145255);
		_loc2_.filters = [new GlowFilter(12451839, 0.5, 3, 3)];
		_loc2_.width = 100;
		_loc2_.htmlText = "<a href=\"event:back\">&lt;&lt; 返回鲜花列表</a>";
		_loc2_.y = 22;
		_loc2_.x = 394;
		this._sendFlowerContainer.addChild(_loc2_);
		addEventListener(TextEvent.LINK, this.onReturnLink);
		this._canvas = new Canvas();
		this._canvas.horizontalScrollPolicy = ScrollPolicy.OFF;
		this._canvas.x = 15;
		this._canvas.y = 46;
		this._canvas.width = _preferedWidth - 25;
		this._canvas.height = 282;
		this._canvas.defaultSkin = null;
		this._sendFlowerContainer.addChild(this._canvas);
		addEventListener(FlowerRenderItem.PREVIEW, this.onPreviewFlower, false, 0, true);
		addEventListener(FlowerRenderItem.NOT_ENOUGH, this.onNotEnough, false, 0, true);
		addEventListener(FlowerRenderItem.SEND_FLOWER, this.onSendFlower, false, 0, true);
	}

	// PlantsPage.as:334-337
	private function onReturnLink(param1:TextEvent):Void {
		this.switchSendFlowerView(false);
	}

	// PlantsPage.as:339-367
	private function onSellBtnClicked(param1:MouseEvent):Void {
		var _loc4_:Dynamic = null;
		var _loc2_:Int = QzoneJSAPI.getOnlineTime(Settings.getInstance().mode);
		var _loc3_:String = "";
		if (_loc2_ > 5 * 3600) {
			_loc3_ = "您现在处于长时间游戏的不健康时间段，适当休息一下吧。本次卖出将无法获得任何收益，您确定要卖出吗？";
		} else if (_loc2_ > 3 * 3600) {
			_loc3_ = "您现在处于疲劳时间段，适当休息一下吧。本次卖出将只能获得正常收益的一半，您确定要卖出吗？";
		} else {
			this.sellAll();
		}
		if (_loc3_ != "") {
			_loc4_ = {
				"width": 327,
				"height": 270,
				"title": "温馨提示",
				"text": _loc3_,
				"confirmFn": this.sellAll
			};
			this.controller.module.app.openWindowByName(Consts.WINDOW_NAME_CONFIRM, _loc4_);
		}
	}

	// PlantsPage.as:369-373
	private function onGotoShop(param1:MouseEvent):Void {
		this.controller.module.app.closeWindowByName(Consts.WINDOW_NAME_WAREHOUSE);
		this.controller.module.app.dispatchEvent(new CommonEvent(Consts.MSG_SHOW_SHOP, null));
	}

	// PlantsPage.as:375-406（AS3 protected → private 覆写）
	override private function setData():Void {
		var _loc1_:Array<Dynamic> = super.dataList;
		if (_loc1_ == null || _loc1_.length == 0) {
			this.createEmptyView();
			_tile.visible = false;
			this._sellBtn.enabled = false;
			if (this._sendFlowerContainer == null || this._sendFlowerContainer.visible == false) {
				this._tfEmpty.visible = true;
				this._gotoShopBtn.visible = true;
			}
		} else {
			if (this._tfEmpty != null) {
				this._tfEmpty.visible = false;
			}
			if (this._gotoShopBtn != null) {
				this._gotoShopBtn.visible = false;
			}
			if (this._sendFlowerContainer == null || this._sendFlowerContainer.visible == false) {
				_tile.visible = true;
				this._sellBtn.enabled = true;
			}
		}
		this.sumUp();
	}

	// PlantsPage.as:408-428
	public function refreshLock(param1:WarehouseCrop):Void {
		var _loc2_:PlantRenderItem = null;
		var _loc2In:Dynamic = null;
		if (param1 == null) {
			return;
		}
		if (_tile == null || _tile.items == null) {
			return;
		}
		for (_loc2In in _tile.items) {
			_loc2_ = _loc2In;
			if (_loc2_.data == param1) {
				_loc2_.refreshLock();
				this.sumUp();
				break;
			}
		}
	}

	// PlantsPage.as:430-471
	private function sellAll():Void {
		var _loc2_:String = null;
		var _loc3_:Int = 0;
		var _loc4_:Float = Math.NaN;
		var _loc5_:Dynamic = null;
		var _loc1_:Array<Dynamic> = this.controller.model.collectNotLockedIDs(this._warehouseType);
		if (_loc1_ != null && _loc1_.length > 0) {
			_loc3_ = QzoneJSAPI.getOnlineTime(Settings.getInstance().mode);
			_loc4_ = this._sum;
			if (_loc3_ > 5 * 3600) {
				_loc4_ = 0;
			} else if (_loc3_ > 3 * 3600) {
				_loc4_ = Math.ceil(_loc4_ / 2);
			}
			_loc2_ = Language.replaceText("allSellText", {"goldValue": _loc4_});
			_loc5_ = {
				"width": 336,
				"height": 270,
				"title": "确认",
				"text": _loc2_,
				"confirmFn": this.onOK,
				"confirmEnable": true
			};
		} else {
			_loc2_ = Reflect.field(Language.L, "allSellText2");
			_loc5_ = {
				"width": 336,
				"height": 270,
				"title": "确认",
				"text": _loc2_,
				"confirmEnable": false
			};
		}
		this.controller.module.app.openWindowByName(Consts.WINDOW_NAME_CONFIRM, _loc5_);
	}

	// PlantsPage.as:473-508
	private function onSendFlower(param1:ViewEvent):Void {
		var _loc4_:Player = null;
		var _loc5_:String = null;
		var _loc6_:Dynamic = null;
		if (param1 == null || param1.data == null) {
			return;
		}
		var _loc2_:Int = As3.intOf(As3.parseInt(Settings.getInstance().getStringAttribute("flowerYDLevel")));
		if (_loc2_ == 0) {
			_loc2_ = 3;
		}
		var _loc3_:Int = As3.intOf(As3.parseInt(Settings.getInstance().getStringAttribute("flowerLevel")));
		if (_loc3_ == 0) {
			_loc3_ = 15;
		}
		if (_loc2_ > 0) {
			_loc4_ = Session.getInstance().host;
			if ((_loc4_._yellowlevel < _loc2_ || _loc4_._yellowstatus == 0) && _loc4_.level < _loc3_) {
				_loc5_ = "<p align=\"left\"><font size=\"12\">" + Settings.getInstance().getStringAttribute("flowerDayTips") + "</font></p>";
				_loc6_ = {
					"title": "温馨提示",
					"type": Consts.ALERT_TYPE_TEXT,
					"text": _loc5_
				};
				this.controller.openWindow(Consts.WINDOW_NAME_ALERT, _loc6_);
				return;
			}
		}
		this.controller.openWindow(Consts.WINDOW_NAME_SENDFLOWER, param1.data);
	}

	// PlantsPage.as:510-542
	private function createEmptyView():Void {
		var _loc1_:TextFormat = null;
		if (this._tfEmpty == null) {
			this._tfEmpty = new TextField();
			this._tfEmpty.selectable = false;
			this._tfEmpty.visible = false;
			_loc1_ = new TextFormat("Verdana", 16, 3355443);
			_loc1_.leading = 8;
			this._tfEmpty.defaultTextFormat = _loc1_;
			this._tfEmpty.width = 350;
			this._tfEmpty.height = 76;
			this._tfEmpty.text = Reflect.field(Language.L, "仓库里空空");
			this._tfEmpty.wordWrap = true;
			this._tfEmpty.x = (_preferedWidth - this._tfEmpty.width) / 2;
			this._tfEmpty.y = (_preferedHeight - this._tfEmpty.height) / 2;
			addChild(this._tfEmpty);
		}
		if (this._gotoShopBtn == null) {
			this._gotoShopBtn = new Button();
			this._gotoShopBtn.visible = false;
			this._gotoShopBtn.addEventListener(MouseEvent.CLICK, this.onGotoShop);
			this._gotoShopBtn.defaultSkin = Utils.getClass("ButtonBlue");
			this._gotoShopBtn.text = Reflect.field(Language.L, "去商店");
			this._gotoShopBtn.x = 270;
			this._gotoShopBtn.y = 150;
			this._gotoShopBtn.width = 60;
			this._gotoShopBtn.height = 24;
			addChild(this._gotoShopBtn);
		}
	}

	// PlantsPage.as:544-641
	public function showAllFlowers():Void {
		var _loc4_:Dynamic = null;
		var _loc4In:Dynamic = null;
		var _loc5_:String = null;
		var _loc9_:Line = null;
		if (this._canvas != null && this._canvas.content != null) {
			while (this._canvas.content.numChildren > 0) {
				this._canvas.content.removeChildAt(0);
			}
		}
		var _loc1_:Array<Dynamic> = [];
		var _loc2_:Array<Dynamic> = [];
		var _loc3_:Array<Dynamic> = this.controller.model.allFlower;
		for (_loc4In in _loc3_) {
			_loc4_ = _loc4In;
			Reflect.setField(_loc4_, "mode", 0);
			if (As3.truthy(Reflect.field(_loc4_, "canMake"))) {
				_loc1_.push(_loc4_);
			} else {
				_loc2_.push(_loc4_);
			}
		}
		_loc5_ = "<b>我目前可以包装的花束</b>";
		if (_loc1_.length <= 0) {
			_loc5_ += "<br/><br/>鲜花不够，暂时无法包装花束哦！<br/>自己种的美丽鲜花送给好友，好友一定会很高兴，快点想想办法吧！";
		}
		var _loc6_:TextField = null;
		var _loc7_:TextFormat = new TextFormat("Verdana", 12, 6514536);
		_loc6_ = new TextField();
		_loc7_.leading = 4;
		_loc6_.defaultTextFormat = _loc7_;
		_loc6_.autoSize = TextFieldAutoSize.LEFT;
		_loc6_.multiline = true;
		_loc6_.htmlText = _loc5_;
		_loc6_.selectable = false;
		this._canvas.content.addChild(_loc6_);
		var _loc8_:TileList = null;
		if (_loc1_.length > 0) {
			_loc8_ = new TileList();
			_loc8_.paddingH = 2;
			_loc8_.paddingV = 0;
			_loc8_.gapH = 12;
			_loc8_.gapV = 10;
			_loc8_.tileWidth = 94;
			_loc8_.tileHeight = 134;
			_loc8_.defaultSkin = null;
			_loc8_.horizontalScrollPolicy = ScrollPolicy.OFF;
			_loc8_.itemRenderer = FlowerRenderItem;
			_loc8_.y = _loc6_.y + _loc6_.height;
			_loc8_.width = this._canvas.width;
			_loc8_.height = Math.ceil(_loc1_.length / 4) * (134 + 10);
			this._canvas.content.addChild(_loc8_);
			_loc8_.dataProvider = _loc1_;
		}
		if (_loc2_.length > 0) {
			_loc9_ = new Line(450, 3, 3852787);
			if (_loc8_ != null) {
				_loc9_.y = _loc8_.y + _loc8_.height + 5;
			} else {
				_loc9_.y = _loc6_.y + _loc6_.height + 5;
			}
			this._canvas.content.addChild(_loc9_);
			_loc6_ = new TextField();
			_loc6_.defaultTextFormat = _loc7_;
			_loc6_.autoSize = TextFieldAutoSize.LEFT;
			_loc6_.multiline = true;
			_loc6_.htmlText = "<b>以下花束因仓库鲜花材料不足，无法包装赠送</b>";
			_loc6_.selectable = false;
			_loc6_.y = _loc9_.y + _loc9_.height + 5;
			this._canvas.content.addChild(_loc6_);
			_loc8_ = new TileList();
			_loc8_.paddingH = 2;
			_loc8_.paddingV = 0;
			_loc8_.gapH = 10;
			_loc8_.gapV = 5;
			_loc8_.tileWidth = 94;
			_loc8_.tileHeight = 134;
			_loc8_.defaultSkin = null;
			_loc8_.horizontalScrollPolicy = ScrollPolicy.OFF;
			_loc8_.itemRenderer = FlowerRenderItem;
			_loc8_.y = _loc6_.y + _loc6_.height;
			_loc8_.width = this._canvas.width;
			_loc8_.height = Math.ceil(_loc2_.length / 4) * (5 + 134);
			this._canvas.content.addChild(_loc8_);
			_loc8_.dataProvider = _loc2_;
		}
	}
}
