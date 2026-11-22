package module.shop;

import com.qzone.qui.containers.ViewStack;
import com.qzone.qui.controls.Label;
import com.qzone.qui.controls.TabBar;
import com.qzone.qui.styles.Style;
import com.qzone.utils.AlignUtil;
import common.CommonData;
import common.Consts;
import common.Language;
import common.Session;
import common.Settings;
import common.misc.Utils;
import common.view.window.BaseWindow;
import common.view.window.WindowTabBarMaker;
import entities.AdItem;
import entities.DIYDecor;
import entities.Item;
import entities.Seed;
import entities.ShopFish;
import events.CommonEvent;
import events.ViewEvent;
import framework.base.BasePage;
import framework.base.BaseTileItem;
import interfaces.IMsgCenter;
import module.GameGuide;
import module.shop.widgets.AdSeedsPage;
import module.shop.widgets.AdvertisementItem;
import module.shop.widgets.AdvertisementPage;
import module.shop.widgets.BuyAdSeedWindow;
import module.shop.widgets.BuyDiyWindow;
import module.shop.widgets.BuyFishWindow;
import module.shop.widgets.BuyItemWindow;
import module.shop.widgets.BuySeedWindow;
import module.shop.widgets.CropItem;
import module.shop.widgets.CropItemVip;
import module.shop.widgets.DiyItem;
import module.shop.widgets.DiyPage;
import module.shop.widgets.FishItem;
import module.shop.widgets.FishPage;
import module.shop.widgets.ItemsPage;
import module.shop.widgets.ShopSeedsPage;
import module.shop.widgets.ToolItem;
import module.shop.widgets.UnlockFishWindow;
import openfl.display.MovieClip;
import openfl.events.Event;
import openfl.events.TextEvent;
import openfl.net.URLRequest;
import openfl.text.StyleSheet;
import openfl.text.TextFormat;
import shim.As3;
import shim.QQOutlets;

/**
 * module.shop.ShopView —— ShopView.as 逐句对应（issue #35 功能 swf 翻译：
 * 商店）。商店主窗：TabBar 五/六页签（种子/鱼苗/道具/装饰/广告/合作专区，
 * 后两者按配置与等级门控），TileList 瓦片点击路由到对应买入窗。
 *
 * PORT-NOTE: `setTimeout(this.onSendToURLTimeout,500,x)` 的 AS3 rest 参 +
 * `arguments[0]` 读法 → 闭包捕获 + 具名参量（As3.setTimeout 无 rest）；
 * ExternalInterface/sendToURL → QQOutlets（统一 no-op 出口）；
 * `data["index"] as int`/`data["show"] as Boolean` → As3.intOf/truthy；
 * decors 元素的 `_alreadyOwn` 动态写 → cast 具型（三选一规则）。
 * addNewIcon 原版未被任何调用点引用（死代码），照抄保留。
 */
class ShopView extends BaseWindow {
	// ShopView.as:41
	private var m_viewStack:ViewStack;

	// ShopView.as:43
	private var m_buyFishWin:BuyFishWindow;

	// ShopView.as:45
	private var m_fishPage:FishPage;

	// ShopView.as:47
	private var m_adSeedsPage:AdSeedsPage;

	// ShopView.as:49
	public var showArrowOnClose:Int;

	// ShopView.as:51
	private var m_buyAdSeedWin:BuyAdSeedWindow;

	// ShopView.as:53
	private var m_unlockFishWin:UnlockFishWindow;

	// ShopView.as:55
	private var m_controller:ShopController;

	// ShopView.as:57
	private var m_buyToolWin:BuyItemWindow;

	// ShopView.as:59
	private var m_cropPage:ShopSeedsPage;

	// ShopView.as:61
	private var m_buySeedWin:BuySeedWindow;

	// ShopView.as:63
	private var fishTabNewIcon:MovieClip;

	// ShopView.as:65
	private var m_toolPage:ItemsPage;

	// ShopView.as:67
	private var m_advertisementPage:AdvertisementPage;

	// ShopView.as:69
	private var m_tabNav:TabBar;

	// ShopView.as:71
	private var m_diyPage:DiyPage;

	// ShopView.as:73
	private var m_buyDiyWin:BuyDiyWindow;

	// ShopView.as:75-89
	public function new(param1:ShopController) {
		super(Std.isOfType(param1.module.app, IMsgCenter) ? cast(param1.module.app, IMsgCenter) : null);
		title = Reflect.field(Language.L, "shopTitle");
		windowName = Consts.WINDOW_NAME_SHOP;
		width = 500;
		height = 390;
		mode = true;
		this.m_buySeedWin = null;
		this.m_buyToolWin = null;
		this.m_buyDiyWin = null;
		this.m_advertisementPage = null;
		this.m_controller = param1;
		this.showArrowOnClose = 0;
	}

	// ShopView.as:91-142
	private function onLoadFailed(param1:CommonEvent):Void {
		if (param1 == null || param1.data == null) {
			return;
		}
		var _loc2_:Int = As3.intOf(Reflect.field(param1.data, "index"));
		var _loc3_:String = Reflect.field(param1.data, "error");
		if (_loc2_ == 0) {
			if (this.m_cropPage != null) {
				this.m_cropPage.errText = _loc3_;
			}
		} else if (_loc2_ == 2) {
			if (this.m_toolPage != null) {
				this.m_toolPage.errText = _loc3_;
			}
		} else if (_loc2_ == 3) {
			if (this.m_diyPage != null) {
				this.m_diyPage.errText = _loc3_;
			}
		} else if (_loc2_ == 4) {
			if (this.m_advertisementPage != null) {
				this.m_advertisementPage.loadingVisible = false;
				this.m_advertisementPage.errText = _loc3_;
			}
		} else if (_loc2_ == 1) {
			if (this.m_fishPage != null) {
				this.m_fishPage.errText = _loc3_;
			}
		} else if (_loc2_ == 5) {
			if (this.m_adSeedsPage != null) {
				this.m_adSeedsPage.errText = "系统繁忙，请稍后重试";
			}
		}
	}

	// ShopView.as:144-236
	private function onTileItemClick(param1:ViewEvent):Void {
		var _loc3_:Seed = null;
		var _loc4_:DIYDecor = null;
		var _loc5_:AdItem = null;
		var _loc6_:ShopFish = null;
		if (param1 == null || param1.target == null) {
			return;
		}
		var _loc2_:Dynamic = param1.target;
		if (Std.isOfType(_loc2_, CropItem) || Std.isOfType(_loc2_, CropItemVip)) {
			_loc3_ = Std.isOfType(param1.data, Seed) ? cast(param1.data, Seed) : null;
			if (_loc3_ == null) {
				return;
			}
			if (_loc3_._isAdSeed != 1) {
				if (this.m_buySeedWin == null) {
					this.m_buySeedWin = new BuySeedWindow(this);
				}
				this.controller.module.app.farmView.winCtrl.open(this.m_buySeedWin);
				this.m_buySeedWin.data = _loc3_;
			} else {
				if (this.m_buyAdSeedWin == null) {
					this.m_buyAdSeedWin = new BuyAdSeedWindow(this);
				}
				this.controller.module.app.farmView.winCtrl.open(this.m_buyAdSeedWin);
				this.m_buyAdSeedWin.data = _loc3_;
				// AS3 setTimeout 的 rest 参（500ms 后把 _rl 当 arguments[0]
				// 传给 onSendToURLTimeout）→ 捕获后闭包转发，见类头 PORT-NOTE
				var rlAd:String = _loc3_._rl;
				As3.setTimeout(function():Void {
					this.onSendToURLTimeout(rlAd);
				}, 500);
			}
		} else if (Std.isOfType(_loc2_, ToolItem)) {
			this.showBuyItemWindow(Std.isOfType(param1.data, Item) ? cast(param1.data, Item) : null, false);
		} else if (Std.isOfType(_loc2_, DiyItem)) {
			_loc4_ = Std.isOfType(param1.data, DIYDecor) ? cast(param1.data, DIYDecor) : null;
			if (_loc4_ == null) {
				return;
			}
			if (this.m_buyDiyWin == null) {
				this.m_buyDiyWin = new BuyDiyWindow(this);
			}
			this.controller.module.app.farmView.winCtrl.open(this.m_buyDiyWin);
			this.m_buyDiyWin.data = _loc4_;
		} else if (Std.isOfType(_loc2_, AdvertisementItem)) {
			_loc5_ = new AdItem(param1.data);
			if (_loc5_ == null) {
				return;
			}
			QQOutlets.call("window.open", _loc5_._rl);
			var rlAc:String = _loc5_._acurl;
			As3.setTimeout(function():Void {
				this.onSendToURLTimeout(rlAc);
			}, 500);
		} else if (Std.isOfType(_loc2_, FishItem)) {
			_loc6_ = Std.isOfType(param1.data, ShopFish) ? cast(param1.data, ShopFish) : null;
			if (_loc6_ == null) {
				return;
			}
			if (_loc6_._lock == 1) {
				if (this.m_buyFishWin == null) {
					this.m_buyFishWin = new BuyFishWindow(this);
				}
				this.controller.module.app.farmView.winCtrl.open(this.m_buyFishWin);
				this.m_buyFishWin.data = _loc6_;
			} else {
				if (this.m_unlockFishWin == null) {
					this.m_unlockFishWin = new UnlockFishWindow(this);
				}
				this.controller.module.app.farmView.winCtrl.open(this.m_unlockFishWin);
				this.m_unlockFishWin.data = _loc6_;
			}
		}
	}

	// ShopView.as:238-245
	public var currentPageIndex(get, set):Int;

	private function get_currentPageIndex():Int {
		if (this.m_tabNav == null) {
			return -1;
		}
		return this.m_tabNav.selectedIndex;
	}

	private function set_currentPageIndex(param1:Int):Int {
		if (this.m_tabNav != null) {
			this.m_tabNav.selectedIndex = param1;
		}
		return param1;
	}

	// ShopView.as:247-263
	public function showBuyItemWindow(param1:Item, param2:Bool):Void {
		if (param1 == null) {
			return;
		}
		if (param1._type == 909090 && param2 == true) {
			this.controller.module.app.dispatchEvent(new Event(Consts.MSG_REFRSH_MY_DOG_FOOD));
		}
		if (this.m_buyToolWin == null) {
			this.m_buyToolWin = new BuyItemWindow(this);
		}
		this.controller.module.app.farmView.winCtrl.open(this.m_buyToolWin);
		this.m_buyToolWin.data = param1;
	}

	// ShopView.as:265-288
	public function getTabPage(param1:Int):BasePage {
		if (param1 == 0) {
			return this.m_cropPage;
		}
		if (param1 == 2) {
			return this.m_toolPage;
		}
		if (param1 == 3) {
			return this.m_diyPage;
		}
		if (param1 == 4) {
			return this.m_advertisementPage;
		}
		if (param1 == 1) {
			return this.m_fishPage;
		}
		return null;
	}

	// ShopView.as:290-303
	override private function init():Void {
		super.init();
		this.createView();
		this.addAdvertiseLink();
		var _loc1_:ShopModel = this.m_controller.model;
		if (_loc1_ != null) {
			_loc1_.addEventListener(ShopModel.EVENT_SHOP_DATA_LOADED, this.onDataLoaded, false, 0, true);
			_loc1_.addEventListener(ShopModel.EVENT_SHOP_DATA_FAILED, this.onLoadFailed, false, 0, true);
			_loc1_.addEventListener(ShopModel.EVENT_SHOP_DATA_LOADING, this.onDataLoading, false, 0, true);
			_loc1_.addEventListener(ShopModel.EVENT_SHOP_DIY_OWN_LOADED, this.onDiyDataLoaded, false, 0, true);
		}
	}

	// ShopView.as:313-386
	private function onDataLoaded(param1:CommonEvent):Void {
		var _loc4_:String = null;
		if (param1 == null || param1.data == null) {
			return;
		}
		var _loc2_:Int = As3.intOf(Reflect.field(param1.data, "index"));
		var _loc3_:Array<Dynamic> = Std.isOfType(Reflect.field(param1.data, "data"), Array)
			? cast(Reflect.field(param1.data, "data"), Array<Dynamic>) : null;
		if (_loc2_ == 0) {
			if (this.m_cropPage != null) {
				this.m_cropPage.loadingVisible = false;
				this.m_cropPage.dataList = _loc3_;
			}
		} else if (_loc2_ == 2) {
			if (this.m_toolPage != null) {
				this.m_toolPage.loadingVisible = false;
				this.m_toolPage.dataList = _loc3_;
			}
		} else if (_loc2_ == 3) {
			if (this.m_diyPage != null) {
				this.m_diyPage.loadingVisible = false;
				this.m_diyPage.dataList = _loc3_;
				this.m_controller.model.loadDecorsItemOwnInfo();
			}
		} else if (_loc2_ == 4) {
			if (this.m_advertisementPage != null) {
				this.m_advertisementPage.loadingVisible = false;
				this.m_advertisementPage.dataList = _loc3_;
			}
		} else if (_loc2_ == 1) {
			if (this.m_fishPage != null) {
				this.m_fishPage.loadingVisible = false;
				this.m_fishPage.dataList = _loc3_;
			}
			if (this.m_tabNav.selectedIndex == 1 && _loc3_ != null && _loc3_.length > 0) {
				_loc4_ = As3.intOf(Reflect.field(_loc3_[0], "_lock")) == 0 ? "点击查看解锁条件" : "";
				GameGuide.instance().showStep(GameGuide.WATER_FISH_ITEM, 0, 0, _loc4_);
				GameGuide.instance().autoHide(5);
			}
		} else if (_loc2_ == 5) {
			if (this.m_adSeedsPage != null) {
				this.m_adSeedsPage.dataList = _loc3_;
				if (!As3.truthy(_loc3_) || _loc3_.length <= 0) {
					this.m_adSeedsPage.loadingVisible = true;
					this.m_adSeedsPage.errText = "暂未有合作物品，敬请期待";
				} else {
					this.m_adSeedsPage.loadingVisible = false;
					this.m_adSeedsPage.errText = "";
				}
			}
		}
	}

	// ShopView.as:388-399
	private function onFishUILoaded(param1:Dynamic):Void {
		var _loc2_:ShopModel = null;
		if (this.m_tabNav.selectedIndex == 1) {
			_loc2_ = this.m_controller.model;
			if (_loc2_.isEmpty(4) == false) {
				this.m_fishPage.dataList = _loc2_.fishs;
			}
		}
	}

	// ShopView.as:401-429
	private function addAdvertiseLink():Void {
		var _loc2_:String = null;
		var _loc3_:Label = null;
		var _loc4_:StyleSheet = null;
		var _loc1_:String = Settings.getInstance().getDynamicTip("shopLinkTip");
		if (_loc1_ != "") {
			_loc2_ = Settings.getInstance().getDynamicTip("shopLinkTip", Settings.TIP_URL);
			_loc3_ = new Label();
			_loc3_.mouseChildren = true;
			if (As3.truthy(_loc2_)) {
				_loc3_.text = "<a target=\"_blank\" href=\"event:" + _loc2_ + "\">" + _loc1_ + "</a>";
			} else {
				_loc3_.textDefaultFormat = new TextFormat(Style.fontFace, Style.fontSize, 16711680, null, null, null, null, null, "left");
				_loc3_.text = _loc1_;
			}
			_loc3_.y = 36;
			_loc3_.x = AlignUtil.right(this.width, _loc3_.width) - 6;
			_loc3_.textField.addEventListener(TextEvent.LINK, this.onNavigateToURL);
			this.addChild(_loc3_);
			_loc4_ = new StyleSheet();
			_loc4_.parseCSS("a:link {color:#FF0000;font-family:\"Arial Black\";} a:hover{text-decoration:underline;color:#FF0000;}");
			_loc3_.textField.styleSheet = _loc4_;
		}
	}

	// ShopView.as:431-434
	public var controller(get, never):ShopController;

	private function get_controller():ShopController {
		return this.m_controller;
	}

	// ShopView.as:436-443
	public var currentPage(get, never):BasePage;

	private function get_currentPage():BasePage {
		if (this.m_tabNav == null) {
			return null;
		}
		return this.getTabPage(this.m_tabNav.selectedIndex);
	}

	// ShopView.as:445-494
	private function onTabSwitched(param1:Event):Void {
		if (param1 == null || param1.currentTarget == null) {
			return;
		}
		// 判型后取具型引用再读 @:property（cpp 上 Dynamic 直读 property
		// 不保证走 getter；RadioGroup:50 同款模式）
		var _loc1_:TabBar = Std.isOfType(param1.currentTarget, TabBar) ? cast(param1.currentTarget, TabBar) : null;
		var _loc2_:ShopModel = this.m_controller.model;
		if (_loc1_.selectedIndex == 0) {
			if (_loc2_.isEmpty(0) == true) {
				_loc2_.loadSeedsInfo();
			}
		} else if (_loc1_.selectedIndex == 1) {
			if (!Session.getInstance().m_waterPoolOpen) {
				this.m_fishPage.errText = "您的池塘未开通，无法购买鱼苗，请开通池塘之后再来购买。";
				return;
			}
			this.m_fishPage.errText = "";
			if (_loc2_.isEmpty(4) == true) {
				_loc2_.loadFishInfo();
			}
		} else if (_loc1_.selectedIndex == 2) {
			if (_loc2_.isEmpty(1) == true) {
				_loc2_.loadItemsInfo();
			}
		} else if (_loc1_.selectedIndex == 3) {
			if (_loc2_.isEmpty(2) == true) {
				_loc2_.loadDecorsInfo();
			}
		} else if (_loc1_.selectedIndex == 4) {
			_loc2_.loadAdvertisementInfo();
		} else if (_loc1_.selectedIndex == 5) {
			_loc2_.loadAdvertisementSeedsList();
		}
	}

	// ShopView.as:496-506
	private function fishLinkClick(param1:ViewEvent):Void {
		if (param1 == null || param1.data == null) {
			return;
		}
		if (param1.data == "reload") {
			this.m_controller.model.loadFishInfo();
		}
	}

	// ShopView.as:508-596
	private function createView():Void {
		this.m_viewStack = new ViewStack();
		this.m_tabNav = new TabBar();
		this.m_tabNav.viewStack = this.m_viewStack;
		WindowTabBarMaker.addTarget(this.m_tabNav);
		this.m_tabNav.paddingH = 18;
		this.m_tabNav.x = 0;
		this.m_tabNav.y = 33;
		this.m_tabNav.width = width - 2;
		this.m_tabNav.addEventListener(Event.CHANGE, this.onTabSwitched);
		this.m_viewStack.y = this.m_tabNav.y + this.m_tabNav.height;
		this.m_viewStack.width = width - 2;
		this.m_viewStack.height = height - this.m_viewStack.y;
		var _loc1_:ShopModel = this.m_controller.model;
		if (_loc1_ == null) {
			return;
		}
		this.m_cropPage = new ShopSeedsPage(this, 500, 320);
		this.m_cropPage.addEventListener(ViewEvent.LINK_CLICK, this.cropLinkClick, false, 0, true);
		this.m_cropPage.addEventListener(BaseTileItem.CHILD_CLICK, this.onTileItemClick, true, 0, true);
		this.m_cropPage.addEventListener(BaseTileItem.CHILD_OVER, this.onTileItemOver, true, 0, true);
		this.m_cropPage.addEventListener(BaseTileItem.CHILD_OUT, this.onTileItemOut, true, 0, true);
		if (_loc1_.isEmpty(0) == false) {
			this.m_cropPage.dataList = _loc1_.seeds;
		}
		this.m_tabNav.addTab(Reflect.field(Language.L, "shopTagSell"), Math.NaN, 24);
		this.m_viewStack.addView(this.m_cropPage);
		this.m_fishPage = new FishPage(this, 500, 320);
		this.m_fishPage.addEventListener(ViewEvent.LINK_CLICK, this.fishLinkClick, false, 0, true);
		this.m_fishPage.addEventListener(BaseTileItem.CHILD_CLICK, this.onTileItemClick, true, 0, true);
		this.m_fishPage.addEventListener(BaseTileItem.CHILD_OVER, this.onTileItemOver, true, 0, true);
		this.m_fishPage.addEventListener(BaseTileItem.CHILD_OUT, this.onTileItemOut, true, 0, true);
		if (_loc1_.isEmpty(4) == false) {
			this.m_fishPage.dataList = _loc1_.fishs;
		}
		this.m_tabNav.addTab("鱼苗", Math.NaN, 24);
		this.m_viewStack.addView(this.m_fishPage);
		this.m_toolPage = new ItemsPage(this, 500, 320);
		this.m_toolPage.addEventListener(ViewEvent.LINK_CLICK, this.toolLinkClick, false, 0, true);
		this.m_toolPage.addEventListener(BaseTileItem.CHILD_CLICK, this.onTileItemClick, true, 0, true);
		this.m_toolPage.addEventListener(BaseTileItem.CHILD_OVER, this.onTileItemOver, true, 0, true);
		this.m_toolPage.addEventListener(BaseTileItem.CHILD_OUT, this.onTileItemOut, true, 0, true);
		if (_loc1_.isEmpty(1) == false) {
			this.m_toolPage.dataList = _loc1_.items;
		}
		this.m_tabNav.addTab(Reflect.field(Language.L, "shopTagFertilizer"), Math.NaN, 24);
		this.m_viewStack.addView(this.m_toolPage);
		this.m_diyPage = new DiyPage(this, 500, 320);
		this.m_diyPage.addEventListener(ViewEvent.LINK_CLICK, this.diyLinkClick, false, 0, true);
		this.m_diyPage.addEventListener(BaseTileItem.CHILD_CLICK, this.onTileItemClick, true, 0, true);
		this.m_diyPage.addEventListener(BaseTileItem.CHILD_OVER, this.onTileItemOver, true, 0, true);
		this.m_diyPage.addEventListener(BaseTileItem.CHILD_OUT, this.onTileItemOut, true, 0, true);
		if (_loc1_.isEmpty(2) == false) {
			this.m_diyPage.dataList = _loc1_.decors;
		}
		this.m_tabNav.addTab(Reflect.field(Language.L, "shopTagDecorate"), Math.NaN, 24);
		this.m_viewStack.addView(this.m_diyPage);
		if (Session.getInstance().host.level >= Settings.getInstance().snsAdAllowLvl) {
			this.m_advertisementPage = new AdvertisementPage(this, 500, 320);
			this.m_advertisementPage.addEventListener(ViewEvent.LINK_CLICK, this.toolLinkClick, false, 0, true);
			this.m_advertisementPage.addEventListener(BaseTileItem.CHILD_CLICK, this.onTileItemClick, true, 0, true);
			if (_loc1_.isEmpty(3) == false) {
				this.m_advertisementPage.dataList = _loc1_.advertisements;
			}
			this.m_tabNav.addTab(Reflect.field(Language.L, "shopTagAdvertisement"), Math.NaN, 24);
			this.m_viewStack.addView(this.m_advertisementPage);
		}
		if (Settings.getInstance().getStringAttribute("adSeedTabOpen") == "1") {
			this.m_adSeedsPage = new AdSeedsPage(this, 500, 320);
			this.m_adSeedsPage.addEventListener(ViewEvent.LINK_CLICK, this.diyLinkClick, false, 0, true);
			this.m_adSeedsPage.addEventListener(BaseTileItem.CHILD_CLICK, this.onTileItemClick, true, 0, true);
			this.m_adSeedsPage.addEventListener(BaseTileItem.CHILD_OVER, this.onTileItemOver, true, 0, true);
			this.m_adSeedsPage.addEventListener(BaseTileItem.CHILD_OUT, this.onTileItemOut, true, 0, true);
			this.m_tabNav.addTab("合作专区", Math.NaN, 24);
			this.m_viewStack.addView(this.m_adSeedsPage);
		}
		addChild(this.m_viewStack);
		addChild(this.m_tabNav);
		this.loadFishUIRes();
	}

	// ShopView.as:598-606
	private function loadFishUIRes():Void {
		var _loc1_:String = Settings.getInstance().getSecondUrl("water_ui");
		if (_loc1_ == null || _loc1_ == "") {
			return;
		}
		CommonData.rslManager.requestFile(_loc1_, this.onFishUILoaded);
	}

	// ShopView.as:608-658
	private function onDataLoading(param1:CommonEvent):Void {
		if (param1 == null || param1.data == null) {
			return;
		}
		var _loc2_:Int = As3.intOf(Reflect.field(param1.data, "index"));
		var _loc3_:Bool = As3.truthy(Reflect.field(param1.data, "show"));
		if (_loc2_ == 0) {
			if (this.m_cropPage != null) {
				this.m_cropPage.loadingVisible = _loc3_;
			}
		} else if (_loc2_ == 2) {
			if (this.m_toolPage != null) {
				this.m_toolPage.loadingVisible = _loc3_;
			}
		} else if (_loc2_ == 3) {
			if (this.m_diyPage != null) {
				this.m_diyPage.loadingVisible = _loc3_;
			}
		} else if (_loc2_ == 4) {
			if (this.m_advertisementPage != null) {
				this.m_advertisementPage.loadingVisible = _loc3_;
			}
		} else if (_loc2_ == 1) {
			if (this.m_fishPage != null) {
				this.m_fishPage.loadingVisible = _loc3_;
			}
		} else if (_loc2_ == 5) {
			if (this.m_adSeedsPage != null) {
				this.m_adSeedsPage.loadingVisible = _loc3_;
			}
		}
	}

	// ShopView.as:660-714
	private function onTileItemOver(param1:ViewEvent):Void {
		var _loc3_:Seed = null;
		var _loc4_:Item = null;
		var _loc5_:DIYDecor = null;
		var _loc6_:ShopFish = null;
		if (param1 == null || param1.target == null) {
			return;
		}
		var _loc2_:Dynamic = param1.target;
		if (Std.isOfType(_loc2_, CropItem) || Std.isOfType(_loc2_, CropItemVip)) {
			_loc3_ = Std.isOfType(param1.data, Seed) ? cast(param1.data, Seed) : null;
			if (_loc3_ == null) {
				return;
			}
			this.m_controller.showTip(Consts.TIP_NAME_MOUSE, _loc3_._name + "\n预计所得：" + _loc3_._expect);
		} else if (Std.isOfType(_loc2_, ToolItem)) {
			_loc4_ = Std.isOfType(param1.data, Item) ? cast(param1.data, Item) : null;
			if (_loc4_ == null) {
				return;
			}
			this.m_controller.showTip(Consts.TIP_NAME_MOUSE, _loc4_._name + "\n" + _loc4_._desc);
		} else if (Std.isOfType(_loc2_, DiyItem)) {
			_loc5_ = Std.isOfType(param1.data, DIYDecor) ? cast(param1.data, DIYDecor) : null;
			if (_loc5_ == null) {
				return;
			}
			this.m_controller.showTip(Consts.TIP_NAME_MOUSE, _loc5_._name + "\n可得经验：" + _loc5_._exp);
		} else if (Std.isOfType(_loc2_, FishItem)) {
			_loc6_ = Std.isOfType(param1.data, ShopFish) ? cast(param1.data, ShopFish) : null;
			if (_loc6_._lock == 1) {
				this.m_controller.showTip(Consts.TIP_NAME_MOUSE, _loc6_._name + "\n预计所得：" + Std.string(_loc6_._output * _loc6_._sale));
			} else if (_loc6_._lock == 0) {
				this.m_controller.showTip(Consts.TIP_NAME_MOUSE, "锁定中");
			} else if (_loc6_._lock == 2) {
				this.m_controller.showTip(Consts.TIP_NAME_MOUSE, "可解锁");
			}
		}
	}

	// ShopView.as:716-739
	private function onTileItemOut(param1:ViewEvent):Void {
		if (param1 == null || param1.target == null) {
			return;
		}
		var _loc2_:Dynamic = param1.target;
		if (Std.isOfType(_loc2_, CropItem) || Std.isOfType(_loc2_, CropItemVip)) {
			this.m_controller.hideTip();
		} else if (Std.isOfType(_loc2_, ToolItem)) {
			this.m_controller.hideTip();
		} else if (Std.isOfType(_loc2_, DiyItem)) {
			this.m_controller.hideTip();
		} else if (Std.isOfType(_loc2_, FishItem)) {
			this.m_controller.hideTip();
		}
	}

	// ShopView.as:741-751（原版无调用点，死代码照抄）
	private function addNewIcon():Void {
		this.fishTabNewIcon = Std.isOfType(Utils.getMaterial("ShopTabNewIcon"), MovieClip)
			? cast(Utils.getMaterial("ShopTabNewIcon"), MovieClip) : null;
		if (this.fishTabNewIcon == null) {
			return;
		}
		this.fishTabNewIcon.x = 128;
		this.fishTabNewIcon.y = 28;
		addChild(this.fishTabNewIcon);
	}

	// ShopView.as:753-762
	override private function onClose(param1:Event):Void {
		super.onClose(param1);
		GameGuide.instance().hide();
		if (this.showArrowOnClose == 1) {
			GameGuide.instance().showStep(GameGuide.WATER_BAG_ICON_FISH);
			GameGuide.instance().autoHide(5);
		}
	}

	// ShopView.as:764-779
	public function setDiyBought(param1:Int):Void {
		var _loc2_:Array<Dynamic> = this.m_controller.model.decors;
		var _loc3_:Int = _loc2_.length;
		var _loc4_:Int = 0;
		while (_loc4_ < _loc3_) {
			if (As3.intOf(Reflect.field(_loc2_[_loc4_], "_id")) == param1) {
				cast(_loc2_[_loc4_], DIYDecor)._alreadyOwn = true;
				break;
			}
			_loc4_++;
		}
		this.m_diyPage.dataList = _loc2_;
	}

	// ShopView.as:781-808
	private function onDiyDataLoaded(param1:CommonEvent):Void {
		var _loc4_:Int = 0;
		var _loc5_:Int = 0;
		if (param1 == null || param1.data == null) {
			return;
		}
		var _loc2_:Array<Dynamic> = Std.isOfType(Reflect.field(param1.data, "data"), Array)
			? cast(Reflect.field(param1.data, "data"), Array<Dynamic>) : null;
		var _loc3_:Array<Dynamic> = this.m_controller.model.decors;
		if (_loc2_ != null) {
			if (_loc3_ != null) {
				_loc4_ = _loc3_.length;
				_loc5_ = 0;
				while (_loc5_ < _loc4_) {
					if (_loc3_[_loc5_] != null && _loc2_.indexOf(Reflect.field(_loc3_[_loc5_], "_id")) != -1) {
						cast(_loc3_[_loc5_], DIYDecor)._alreadyOwn = true;
					}
					_loc5_++;
				}
			}
		}
		this.m_diyPage.dataList = _loc3_;
	}

	// ShopView.as:810-822
	public function showBuySeedWindow(param1:Seed):Void {
		if (param1 == null) {
			return;
		}
		if (this.m_buySeedWin == null) {
			this.m_buySeedWin = new BuySeedWindow(this);
		}
		this.controller.module.app.farmView.winCtrl.open(this.m_buySeedWin);
		this.m_buySeedWin.data = param1;
	}

	// ShopView.as:824-832
	private function onNavigateToURL(param1:TextEvent):Void {
		var _loc2_:String = param1.text;
		if (_loc2_ == "" || QQOutlets.available == false) {
			return;
		}
		QQOutlets.call("window.open", _loc2_);
	}

	// ShopView.as:834-844
	private function toolLinkClick(param1:ViewEvent):Void {
		if (param1 == null || param1.data == null) {
			return;
		}
		if (param1.data == "reload") {
			this.m_controller.model.loadItemsInfo();
		}
	}

	// ShopView.as:846-856
	private function diyLinkClick(param1:ViewEvent):Void {
		if (param1 == null || param1.data == null) {
			return;
		}
		if (param1.data == "reload") {
			this.m_controller.model.loadDecorsInfo();
		}
	}

	// ShopView.as:858-865（原版零参 + arguments[0] 读 rest 实参，具名参量等价）
	private function onSendToURLTimeout(param1:String):Void {
		if (param1 == null || param1 == "") {
			return;
		}
		QQOutlets.sendToURL(new URLRequest(param1));
	}

	// ShopView.as:867-877
	private function cropLinkClick(param1:ViewEvent):Void {
		if (param1 == null || param1.data == null) {
			return;
		}
		if (param1.data == "reload") {
			this.m_controller.model.loadSeedsInfo();
		}
	}
}
