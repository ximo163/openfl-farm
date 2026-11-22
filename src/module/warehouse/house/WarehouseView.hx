package module.warehouse.house;

import EvtAPI;
import com.qzone.qui.containers.ViewStack;
import com.qzone.qui.controls.Label;
import com.qzone.qui.controls.TabBar;
import com.qzone.utils.AlignUtil;
import common.Consts;
import common.Language;
import common.misc.QzoneJSAPI;
import common.view.window.BaseWindow;
import common.view.window.WindowControl;
import common.view.window.WindowTabBarMaker;
import entities.WarehouseCrop;
import entities.WarehouseFish;
import entities.WarehouseSeed;
import events.CommonEvent;
import events.ViewEvent;
import framework.base.BasePage;
import framework.base.BaseTileItem;
import interfaces.IMsgCenter;
import module.warehouse.house.widgets.CardsPage;
import module.warehouse.house.widgets.FlowerRenderItem;
import module.warehouse.house.widgets.PlantRenderItem;
import module.warehouse.house.widgets.PlantsPage;
import module.warehouse.house.widgets.RecvFlowersPage;
import module.warehouse.house.widgets.SellFishWindow;
import module.warehouse.house.widgets.SellPlantWindow;
import module.warehouse.house.widgets.SellToolWindow;
import module.warehouse.house.widgets.WarehouseFishPage;
import module.warehouse.house.widgets.WarehouseSeedsPage;
import openfl.events.Event;
import openfl.events.TextEvent;
import openfl.text.TextFormat;
import shim.As3;

/**
 * module.warehouse.house.WarehouseView —— WarehouseView.as 逐句对应
 * （issue #36 功能 swf 翻译：仓库）。仓库主窗（BaseWindow）：六页签
 * ViewStack（蔬果/鲜花/成鱼/收到的花束/种子/材料）+ 卖出窗口按条目类型
 * 惰性复用。视觉参数（页签高 25、paddingH 20、gapH 3、x=0 y=33、宽
 * width-2 等）逐字照抄。
 *
 * PORT-NOTE: WarehouseModel 的 EVENT_* 原文 private，构造器与 init 跨类读
 * → 各自 @:access（FriendsView 构造器先例）；`Language.L["…"]` →
 * Reflect.field；`as int` → As3.intOf、`as Boolean` → As3.truthy、
 * `x == 字串常量` → Std.string 后直比；`_isLock == true` 的 Int/Bool 宽松
 * 真值 → As3.truthy；onUpdateLock/onUpdateFishLock 尾行对可能为 null 的
 * 卖出窗直呼 updateLock()（原版同样空指针即崩，照抄不改）；onDataLoading
 * 的嵌套 else-if（index==1 内嵌 index==2/5 死支）照抄。
 */
class WarehouseView extends BaseWindow {
	// WarehouseView.as:29
	private var m_viewStack:ViewStack;

	// WarehouseView.as:31
	private var m_fishPage:WarehouseFishPage;

	// WarehouseView.as:33
	private var m_flowerPage:PlantsPage;

	// WarehouseView.as:35
	private var m_sellSeedWin:SellToolWindow;

	// WarehouseView.as:37
	private var m_sellCropWin:SellPlantWindow;

	// WarehouseView.as:39
	private var m_recvFlowerPage:RecvFlowersPage;

	// WarehouseView.as:41
	private var m_controller:WarehouseController;

	// WarehouseView.as:43
	private var m_seedPage:WarehouseSeedsPage;

	// WarehouseView.as:45
	private var m_sellMaterialWin:SellPlantWindow;

	// WarehouseView.as:47
	private var m_txtSendFlower:Label;

	// WarehouseView.as:49
	private var m_cardPage:CardsPage;

	// WarehouseView.as:51
	private var m_cropPage:PlantsPage;

	// WarehouseView.as:53
	private var m_tabNav:TabBar;

	// WarehouseView.as:55
	private var m_sellFishWin:SellFishWindow;

	// WarehouseView.as:57-76（WarehouseModel.EVENT_* 原文 private → @:access）
	@:access(module.warehouse.house.WarehouseModel)
	public function new(param1:WarehouseController) {
		super(Std.isOfType(param1.module.app, IMsgCenter) ? cast(param1.module.app, IMsgCenter) : null);
		width = 500;
		height = 392;
		title = Reflect.field(Language.L, "warehouseTitle");
		windowName = Consts.WINDOW_NAME_WAREHOUSE;
		mode = true;
		titleDefautFormat = new TextFormat("Verdana", 16, 16777215, true);
		this.m_sellCropWin = null;
		this.m_sellMaterialWin = null;
		this.m_sellSeedWin = null;
		this.m_sellFishWin = null;
		this.m_controller = param1;
		m_msgCenter.addEventListener(EvtAPI.REFRESH_CRYSTAL, this.onCrystalDataChanged, false, 0, true);
		m_msgCenter.addEventListener(Consts.MSG_HIDE_WAREHOUSE, this.closeHandler, false, 0, true);
		param1.model.addEventListener(EvtAPI.REFRESH_CRYSTAL, this.onCrystalDataChanged);
		param1.model.addEventListener(WarehouseModel.EVENT_UPDATELOCK_SUCCESS, this.onUpdateLock);
		param1.model.addEventListener(WarehouseModel.EVENT_UPDATEFISHLOCK_SUCCESS, this.onUpdateFishLock);
	}

	// WarehouseView.as:78-128
	private function onTileItemClick(param1:ViewEvent):Void {
		if (param1 == null || param1.data == null) {
			return;
		}
		var _loc2_:WindowControl = this.controller.module.app.farmView.winCtrl;
		if (_loc2_ == null) {
			return;
		}
		if (Std.isOfType(param1.data, WarehouseCrop)) {
			if (Std.string(cast(param1.data, WarehouseCrop)._type) == Consts.ITEM_TYPE_CARD || Std.string(cast(param1.data, WarehouseCrop)._type) == Consts.ITEM_TYPE_CRYSTAL) {
				if (this.m_sellMaterialWin == null) {
					this.m_sellMaterialWin = new SellPlantWindow(this, true);
				}
				_loc2_.open(this.m_sellMaterialWin);
				this.m_sellMaterialWin.data = param1.data;
			} else {
				if (this.m_sellCropWin == null) {
					this.m_sellCropWin = new SellPlantWindow(this);
				}
				_loc2_.open(this.m_sellCropWin);
				this.m_sellCropWin.data = param1.data;
			}
		} else if (Std.isOfType(param1.data, WarehouseFish)) {
			if (this.m_sellFishWin == null) {
				this.m_sellFishWin = new SellFishWindow(this);
			}
			_loc2_.open(this.m_sellFishWin);
			this.m_sellFishWin.data = param1.data;
		} else {
			if (this.m_sellSeedWin == null) {
				this.m_sellSeedWin = new SellToolWindow(this);
			}
			_loc2_.open(this.m_sellSeedWin);
			this.m_sellSeedWin.data = param1.data;
		}
	}

	// WarehouseView.as:130-154
	private function onLoadFailed(param1:CommonEvent):Void {
		if (param1 == null || param1.data == null) {
			return;
		}
		var _loc2_:Int = As3.intOf(Reflect.field(param1.data, "index"));
		var _loc3_:String = Reflect.field(param1.data, "error");
		var _loc4_:Int = this.m_tabNav.selectedIndex;
		if (_loc2_ == 0 || _loc2_ == 1) {
			if (_loc4_ == 0) {
				this.m_cropPage.errText = _loc3_;
			} else if (_loc4_ == 1) {
				this.m_flowerPage.errText = _loc3_;
			}
		} else if (_loc4_ == 2) {
			this.m_seedPage.errText = _loc3_;
		}
	}

	// WarehouseView.as:156-179
	public function getTabPage(param1:Int):BasePage {
		if (param1 == 0) {
			return this.m_cropPage;
		}
		if (param1 == 1) {
			return this.m_flowerPage;
		}
		if (param1 == 2) {
			return this.m_fishPage;
		}
		if (param1 == 3) {
			return this.m_recvFlowerPage;
		}
		if (param1 == 4) {
			return this.m_seedPage;
		}
		return this.m_cardPage;
	}

	// WarehouseView.as:181-202
	private function onLinkClick(param1:ViewEvent):Void {
		if (param1 == null || param1.data == null) {
			return;
		}
		if (As3.eqString(param1.data, "reload")) {
			if (param1.target == this.m_cropPage) {
				this.m_controller.model.loadCrops();
			} else if (param1.target == this.m_flowerPage) {
				this.m_controller.model.loadCrops();
			} else if (param1.target == this.m_seedPage) {
				this.m_controller.model.loadSeeds();
			}
		}
	}

	// WarehouseView.as:204-213
	public function showSellSeedWindow(param1:WarehouseCrop):Void {
		var _loc2_:WindowControl = this.controller.module.app.farmView.winCtrl;
		if (this.m_sellCropWin == null) {
			this.m_sellCropWin = new SellPlantWindow(this);
		}
		_loc2_.open(this.m_sellCropWin);
		this.m_sellCropWin.data = param1;
	}

	// WarehouseView.as:215-237（WarehouseModel.EVENT_* 原文 private → @:access）
	@:access(module.warehouse.house.WarehouseModel)
	override private function init():Void {
		super.init();
		this.createTabs();
		if (QzoneJSAPI.WB == false && QzoneJSAPI.QPLUS == false) {
			this.m_txtSendFlower = new Label();
			this.m_txtSendFlower.text = "<a href='event:give'>将鲜花包装成花束送给好友吧！</a>";
			this.m_txtSendFlower.x = AlignUtil.right(this.width, this.m_txtSendFlower.width);
			this.m_txtSendFlower.y = 35;
			this.m_txtSendFlower.mouseChildren = true;
			this.m_txtSendFlower.addEventListener(TextEvent.LINK, this.onSendFlowerLink);
			addChild(this.m_txtSendFlower);
		}
		var _loc1_:WarehouseModel = this.m_controller.model;
		if (_loc1_ != null) {
			_loc1_.addEventListener(WarehouseModel.EVENT_DATA_CHANGED, this.onDataChanged);
			_loc1_.addEventListener(WarehouseModel.EVENT_DATA_FAILED, this.onLoadFailed);
			_loc1_.addEventListener(WarehouseModel.EVENT_DATA_LOADING, this.onDataLoading);
			_loc1_.addEventListener(WarehouseModel.EVENT_SENDFLOWER_SUCCESS, this.onFlowerSendout);
		}
	}

	// WarehouseView.as:239-309
	private function createTabs():Void {
		this.m_viewStack = new ViewStack();
		this.m_tabNav = new TabBar();
		this.m_tabNav.viewStack = this.m_viewStack;
		WindowTabBarMaker.addTarget(this.m_tabNav);
		this.m_tabNav.height = 25;
		this.m_tabNav.paddingH = 20;
		this.m_tabNav.gapH = 3;
		this.m_tabNav.x = 0;
		this.m_tabNav.y = 33;
		this.m_tabNav.width = width - 2;
		this.m_viewStack.y = this.m_tabNav.y + this.m_tabNav.height;
		this.m_viewStack.width = width - 2;
		this.m_viewStack.height = height - this.m_viewStack.y;
		this.m_tabNav.addEventListener(Event.CHANGE, this.onTabSwitched);
		var _loc1_:WarehouseModel = this.m_controller.model;
		if (_loc1_ == null) {
			return;
		}
		this.m_cropPage = new PlantsPage(this, 496, 324, false);
		this.m_cropPage.addEventListener(ViewEvent.LINK_CLICK, this.onLinkClick, false, 0, true);
		this.m_cropPage.addEventListener(PlantRenderItem.LOCK_ICON_CLICKED, this.onLockClicked, false, 0, true);
		this.m_cropPage.addEventListener(BaseTileItem.CHILD_CLICK, this.onTileItemClick, false, 0, true);
		this.m_cropPage.addEventListener(BaseTileItem.CHILD_OVER, this.onTileItemOver, false, 0, true);
		this.m_cropPage.addEventListener(BaseTileItem.CHILD_OUT, this.onTileItemOut, false, 0, true);
		this.m_tabNav.addTab("蔬果", Math.NaN, 24);
		this.m_viewStack.addView(this.m_cropPage);
		this.m_flowerPage = new PlantsPage(this, 496, 324, true);
		this.m_flowerPage.addEventListener(ViewEvent.LINK_CLICK, this.onLinkClick, false, 0, true);
		this.m_flowerPage.addEventListener(PlantRenderItem.LOCK_ICON_CLICKED, this.onLockClicked, false, 0, true);
		this.m_flowerPage.addEventListener(BaseTileItem.CHILD_CLICK, this.onTileItemClick, false, 0, true);
		this.m_flowerPage.addEventListener(BaseTileItem.CHILD_OVER, this.onTileItemOver, false, 0, true);
		this.m_flowerPage.addEventListener(BaseTileItem.CHILD_OUT, this.onTileItemOut, false, 0, true);
		this.m_tabNav.addTab("鲜花", Math.NaN, 24);
		this.m_viewStack.addView(this.m_flowerPage);
		this.m_fishPage = new WarehouseFishPage(this, 496, 324);
		this.m_fishPage.addEventListener(ViewEvent.LINK_CLICK, this.onLinkClick, false, 0, true);
		this.m_fishPage.addEventListener(PlantRenderItem.LOCK_ICON_CLICKED, this.onLockClicked, false, 0, true);
		this.m_fishPage.addEventListener(BaseTileItem.CHILD_CLICK, this.onTileItemClick, false, 0, true);
		this.m_fishPage.addEventListener(BaseTileItem.CHILD_OVER, this.onTileItemOver, false, 0, true);
		this.m_fishPage.addEventListener(BaseTileItem.CHILD_OUT, this.onTileItemOut, false, 0, true);
		this.m_tabNav.addTab("成鱼", Math.NaN, 24);
		this.m_viewStack.addView(this.m_fishPage);
		if (QzoneJSAPI.QPLUS == false && QzoneJSAPI.WB == false) {
			this.m_recvFlowerPage = new RecvFlowersPage(this, 496, 324);
			this.m_recvFlowerPage.addEventListener(FlowerRenderItem.CHILD_OVER, this.onTileItemOver, false, 0, true);
			this.m_recvFlowerPage.addEventListener(FlowerRenderItem.CHILD_OUT, this.onTileItemOut, false, 0, true);
			this.m_tabNav.addTab("收到的花束", Math.NaN, 24);
			this.m_viewStack.addView(this.m_recvFlowerPage);
		}
		this.m_seedPage = new WarehouseSeedsPage(this, 496, 324);
		this.m_seedPage.addEventListener(ViewEvent.LINK_CLICK, this.onLinkClick, false, 0, true);
		this.m_seedPage.addEventListener(BaseTileItem.CHILD_CLICK, this.onTileItemClick, false, 0, true);
		this.m_seedPage.addEventListener(BaseTileItem.CHILD_OVER, this.onTileItemOver, false, 0, true);
		this.m_seedPage.addEventListener(BaseTileItem.CHILD_OVER, this.onTileItemOver, false, 0, true);
		this.m_seedPage.addEventListener(BaseTileItem.CHILD_OUT, this.onTileItemOut, false, 0, true);
		this.m_tabNav.addTab("种子", Math.NaN, 24);
		this.m_viewStack.addView(this.m_seedPage);
		this.m_cardPage = new CardsPage(this, 496, 324);
		this.m_cardPage.addEventListener(ViewEvent.LINK_CLICK, this.onLinkClick, false, 0, true);
		this.m_cardPage.addEventListener(PlantRenderItem.LOCK_ICON_CLICKED, this.onLockClicked, false, 0, true);
		this.m_cardPage.addEventListener(BaseTileItem.CHILD_CLICK, this.onTileItemClick, false, 0, true);
		this.m_cardPage.addEventListener(BaseTileItem.CHILD_OVER, this.onTileItemOver, false, 0, true);
		this.m_cardPage.addEventListener(BaseTileItem.CHILD_OUT, this.onTileItemOut, false, 0, true);
		this.m_tabNav.addTab("材料", Math.NaN, 24);
		this.m_viewStack.addView(this.m_cardPage);
		addChild(this.m_viewStack);
		addChild(this.m_tabNav);
	}

	// WarehouseView.as:311-324
	private function onLockClicked(param1:CommonEvent):Void {
		if (param1 == null || param1.data == null) {
			return;
		}
		var _loc2_:WarehouseCrop = Std.isOfType(Reflect.field(param1.data, "data"), WarehouseCrop) ? cast(Reflect.field(param1.data, "data"), WarehouseCrop) : null;
		var _loc3_:Bool = As3.truthy(Reflect.field(param1.data, "lock"));
		if (_loc2_ == null) {
			return;
		}
		this.m_controller.model.storeUserCropLockInfo(_loc2_, _loc3_);
	}

	// WarehouseView.as:326-329
	public var controller(get, never):WarehouseController;

	private function get_controller():WarehouseController {
		return this.m_controller;
	}

	// WarehouseView.as:331-338
	public function refreshItemLockStatus(param1:WarehouseCrop, param2:Bool):Void {
		if (param1 == null) {
			return;
		}
		this.m_controller.model.storeUserCropLockInfo(param1, param2);
	}

	// WarehouseView.as:340-347
	public var currentPage(get, never):BasePage;

	private function get_currentPage():BasePage {
		if (this.m_tabNav == null) {
			return null;
		}
		return this.getTabPage(this.m_tabNav.selectedIndex);
	}

	// WarehouseView.as:349-412
	private function onTabSwitched(param1:Event):Void {
		if (this.m_tabNav == null) {
			return;
		}
		var _loc2_:Int = this.m_tabNav.selectedIndex;
		if (_loc2_ == 0) {
			this.m_controller.model.loadCrops();
			if (this.m_txtSendFlower != null) {
				this.m_txtSendFlower.text = "<a href='event:give'>将鲜花包装成花束送给好友吧！</a>";
			}
		} else if (_loc2_ == 1) {
			this.m_controller.model.loadCrops();
			if (this.m_txtSendFlower != null) {
				this.m_txtSendFlower.text = "";
			}
		} else if (_loc2_ == 2) {
			this.m_controller.model.loadFishs();
			if (this.m_txtSendFlower != null) {
				this.m_txtSendFlower.text = "";
			}
		} else {
			if ((QzoneJSAPI.QPLUS == true || QzoneJSAPI.WB == true) && (_loc2_ == 3 || _loc2_ == 4)) {
				_loc2_ += 1;
			}
			if (_loc2_ == 3) {
				this.m_controller.model.loadMyFlowers();
				if (this.m_txtSendFlower != null) {
					this.m_txtSendFlower.text = "";
				}
			} else if (_loc2_ == 4) {
				this.m_controller.model.loadSeeds();
				if (this.m_txtSendFlower != null) {
					this.m_txtSendFlower.text = "";
				}
			} else if (_loc2_ == 5) {
				this.m_controller.model.loadCrops();
				this.m_controller.model.loadCrystal();
				if (this.m_txtSendFlower != null) {
					this.m_txtSendFlower.text = "";
				}
			}
		}
	}

	// WarehouseView.as:414-421
	public function refreshFishLockStatus(param1:WarehouseFish, param2:Bool):Void {
		if (param1 == null) {
			return;
		}
		this.m_controller.model.storeUserFishLockInfo(param1, param2);
	}

	// WarehouseView.as:423-427
	public function gotoSendFlower():Void {
		this.switchTab(1);
		this.m_flowerPage.switchSendFlowerView(true);
	}

	// WarehouseView.as:429-436
	public function switchTab(param1:Int):Void {
		if (param1 < 0 || param1 > this.m_tabNav.tabNum) {
			param1 = 0;
		}
		this.m_tabNav.selectedIndex = param1;
	}

	// WarehouseView.as:438-442
	private function closeHandler(param1:CommonEvent):Void {
		this.visible = false;
		this.close();
	}

	// WarehouseView.as:444-476
	private function onDataChanged(param1:CommonEvent):Void {
		if (param1 == null || param1.data == null) {
			return;
		}
		var _loc2_:Int = As3.intOf(Reflect.field(param1.data, "index"));
		if (_loc2_ == 0) {
			this.m_cropPage.dataList = this.controller.model.crops;
			this.m_flowerPage.dataList = this.controller.model.flowers;
			this.m_cardPage.dataList = this.controller.model.cards;
		} else if (_loc2_ == 1) {
			this.m_seedPage.dataList = this.controller.model.seeds;
		} else if (_loc2_ == 2) {
			if (this.m_recvFlowerPage != null) {
				this.m_recvFlowerPage.dataList = this.controller.model.myFlowers;
			}
		} else if (_loc2_ == 3) {
			this.m_cardPage.dataList = this.controller.model.cards;
		} else if (_loc2_ == 5) {
			this.m_fishPage.dataList = this.controller.model.fishs;
		}
	}

	// WarehouseView.as:478-491
	private function onFlowerSendout(param1:CommonEvent):Void {
		if (param1 == null || param1.data == null) {
			return;
		}
		this.controller.openWindow(Consts.WINDOW_NAME_ALERT, {
			"type": Consts.ALERT_TYPE_SUCCESS,
			"text": Reflect.field(param1.data, "msg")
		});
		this.m_flowerPage.dataList = this.controller.model.flowers;
		this.m_flowerPage.showAllFlowers();
		this.m_controller.hideTip();
	}

	// WarehouseView.as:493-506。尾行 m_sellFishWin 未判空直呼（原版如此）
	private function onUpdateFishLock(param1:CommonEvent):Void {
		if (param1 == null || param1.data == null) {
			return;
		}
		var _loc2_:WarehouseFish = Std.isOfType(param1.data, WarehouseFish) ? cast(param1.data, WarehouseFish) : null;
		if (_loc2_ == null) {
			return;
		}
		this.m_fishPage.refreshLock(_loc2_);
		this.m_sellFishWin.updateLock();
	}

	// WarehouseView.as:508-538。嵌套 else-if 原文如此（index==2/5 是
	// index==1 内的死支），照抄
	private function onDataLoading(param1:CommonEvent):Void {
		if (param1 == null || param1.data == null) {
			return;
		}
		var _loc2_:Int = As3.intOf(Reflect.field(param1.data, "index"));
		var _loc3_:Bool = As3.truthy(Reflect.field(param1.data, "show"));
		if (_loc2_ == 0) {
			this.m_cropPage.loadingVisible = _loc3_;
		} else if (_loc2_ == 1) {
			if (this.m_seedPage != null) {
				this.m_seedPage.loadingVisible = _loc3_;
			} else if (_loc2_ == 2) {
				if (this.m_recvFlowerPage != null) {
					this.m_recvFlowerPage.loadingVisible = _loc3_;
				} else if (_loc2_ == 5) {
					this.m_fishPage.loadingVisible = _loc3_;
				}
			}
		}
	}

	// WarehouseView.as:540-585
	private function onTileItemOver(param1:ViewEvent):Void {
		var _loc3_:WarehouseCrop = null;
		var _loc4_:WarehouseSeed = null;
		var _loc5_:WarehouseFish = null;
		var _loc6_:Dynamic = null;
		var _loc7_:Dynamic = null;
		if (param1 == null || param1.data == null) {
			return;
		}
		var _loc2_:String = "";
		if (Std.isOfType(param1.data, WarehouseCrop)) {
			_loc3_ = cast(param1.data, WarehouseCrop);
			_loc2_ = As3.truthy(_loc3_._isLock) ? Reflect.field(Language.L, "该果实已锁定不能卖出") : _loc3_._name;
			this.m_controller.showTip(Consts.TIP_NAME_MOUSE, _loc2_);
		} else if (Std.isOfType(param1.data, WarehouseSeed)) {
			_loc4_ = cast(param1.data, WarehouseSeed);
			_loc2_ = _loc4_._name;
			this.m_controller.showTip(Consts.TIP_NAME_MOUSE, _loc2_);
		} else if (Std.isOfType(param1.data, WarehouseFish)) {
			_loc5_ = cast(param1.data, WarehouseFish);
			_loc2_ = _loc5_._name;
			this.m_controller.showTip(Consts.TIP_NAME_MOUSE, _loc2_);
		} else {
			_loc6_ = param1.data;
			if (_loc6_ == null || !As3.hasProp(_loc6_, "need") || !As3.hasProp(_loc6_, "fName")) {
				return;
			}
			for (_loc7_ in cast(Reflect.field(_loc6_, "need"), Array<Dynamic>)) {
				_loc2_ += Reflect.field(_loc7_, "cName") + Reflect.field(_loc7_, "amount") + "朵，";
			}
			_loc2_ = _loc2_.substr(0, _loc2_.length - 1);
			_loc2_ = "<b>" + Reflect.field(_loc6_, "fName") + "</b><br/>花语：" + Reflect.field(_loc6_, "desc") + "<br/>需要：" + _loc2_;
			this.m_controller.showTip(Consts.TIP_NAME_CROPINFO_MOUSE, _loc2_);
		}
	}

	// WarehouseView.as:587-590
	private function onTileItemOut(param1:ViewEvent):Void {
		this.m_controller.hideTip();
	}

	// WarehouseView.as:592-622。尾行 m_sellCropWin 未判空直呼（原版如此）
	private function onUpdateLock(param1:CommonEvent):Void {
		if (param1 == null || param1.data == null) {
			return;
		}
		var _loc2_:WarehouseCrop = Std.isOfType(param1.data, WarehouseCrop) ? cast(param1.data, WarehouseCrop) : null;
		if (_loc2_ == null) {
			return;
		}
		if (_loc2_._isFlower != 1) {
			if (Std.string(_loc2_._type) == Consts.ITEM_TYPE_CARD) {
				if (this.m_cardPage != null) {
					this.m_cardPage.refreshLock(_loc2_);
				}
			} else if (this.m_cropPage != null) {
				this.m_cropPage.refreshLock(_loc2_);
			}
		} else if (this.m_flowerPage != null) {
			this.m_flowerPage.refreshLock(_loc2_);
		}
		this.m_sellCropWin.updateLock();
	}

	// WarehouseView.as:624-633
	private function onSendFlowerLink(param1:TextEvent):Void {
		param1.stopPropagation();
		this.m_tabNav.selectedIndex = 1;
		this.m_flowerPage.switchSendFlowerView(true);
		if (this.m_txtSendFlower != null) {
			this.m_txtSendFlower.text = "";
		}
	}

	// WarehouseView.as:635-642
	override public function onEffectEnd():Void {
		super.onEffectEnd();
		if (this.currentPage == this.m_seedPage) {
			this.controller.model.loadSeeds();
		}
	}

	// WarehouseView.as:644-647
	private function onCrystalDataChanged(param1:Event):Void {
		this.m_controller.model.loadCrystal();
	}
}
