package module.decorate;

import com.qzone.qui.containers.ViewStack;
import com.qzone.qui.controls.Button;
import com.qzone.qui.controls.TabBar;
import common.Consts;
import common.Language;
import common.Session;
import common.view.window.BaseWindow;
import common.view.window.WindowControl;
import common.view.window.WindowTabBarMaker;
import entities.DecorateItem;
import events.CommonEvent;
import events.ViewEvent;
import framework.api.PluginManager;
import framework.base.BaseTileItem;
import interfaces.IMsgCenter;
import module.decorate.widgets.BoardRenderItem;
import module.decorate.widgets.BoardsPage;
import module.decorate.widgets.DecorRenderItem;
import module.decorate.widgets.DecorsPage;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.text.TextFormat;
import openfl.utils.Dictionary;
import shim.As3;

/**
 * module.decorate.DecorateView —— DecorateView.as 逐句对应（issue #38
 * 功能 swf 翻译：DIY 装饰）。装饰主窗（BaseWindow）：装饰/告示牌两页签
 * ViewStack + PluginManager 第三页签挂点；条目点击分流（BoardRenderItem →
 * selectBoard；DecorRenderItem → 狗类（id > 80000 且已装备且狗未饿）先弹
 * 「隐藏狗」确认框，默认背景 id==-1 已装备时点击直接吞掉，其余 select
 * Decorate）。视觉参数（窗 400×420、tabNav y=30 宽 WIDTH-2、页签高 24、
 * 标题 Verdana 16 白、狗粮确认框 380×270 等）逐字照抄。
 *
 * PORT-NOTE: DecorateModel 的 EVENT_* 与 NOTIFY_* 原文 internal 译
 * private，init 跨类读 → @:access（WarehouseView 先例）；`Language.L["…"]` →
 * Reflect.field（语言表把「农场装饰」映射成「装饰」，原版即如此）；
 * `as int`/`Boolean(...)` → As3.intOf/truthy；`data == "reload"` →
 * As3.eqString；instance const WIDTH/HEIGHT → static final。狗粮确认框/
 * 告警走 Controller.openWindow（窗口片 WindowControl 仍是 stub）。
 */
class DecorateView extends BaseWindow {
	// DecorateView.as:27
	private var m_decorPage:DecorsPage;

	// DecorateView.as:29
	private var m_boardPage:BoardsPage;

	// DecorateView.as:31
	private var m_viewStack:ViewStack;

	// DecorateView.as:33
	private var m_deselectDogCache:DecorateItem;

	// DecorateView.as:35
	private var m_tabNav:TabBar;

	// DecorateView.as:37（AS3 instance const → static final）
	private static final WIDTH:UInt = 400;

	// DecorateView.as:39
	private static final HEIGHT:UInt = 420;

	// DecorateView.as:41
	private var m_controller:DecorateController;

	public function new(param1:DecorateController) {
		super(Std.isOfType(param1.module.app, IMsgCenter) ? cast(param1.module.app, IMsgCenter) : null);
		width = WIDTH;
		height = HEIGHT;
		title = Reflect.field(Language.L, "农场装饰");
		windowName = Consts.WINDOW_NAME_DIY;
		mode = true;
		autoLayout = true;
		titleDefautFormat = new TextFormat("Verdana", 16, 16777215, true);
		this.m_deselectDogCache = null;
		this.m_controller = param1;
	}

	// DecorateView.as:57-69
	public function switchTab(param1:Int):Void {
		if (param1 < 0 || param1 > this.m_tabNav.tabNum) {
			param1 = 0;
		}
		if (param1 == this.m_tabNav.selectedIndex) {
			return;
		}
		this.m_tabNav.selectedIndex = param1;
		this.onTabSwitched(null);
	}

	// DecorateView.as:71-123（狗粮确认文案原文如此，含 \n 后前导空格）
	private function onTileItemClick(param1:ViewEvent):Void {
		var _loc3_:BoardRenderItem = null;
		var _loc4_:DecorRenderItem = null;
		var _loc5_:DecorateItem = null;
		var _loc6_:Bool = false;
		if (param1 == null || param1.data == null) {
			return;
		}
		var _loc2_:WindowControl = this.m_controller.module.app.farmView.winCtrl;
		if (_loc2_ == null) {
			return;
		}
		if (Std.isOfType(param1.target, BoardRenderItem)) {
			_loc3_ = cast(param1.target, BoardRenderItem);
			this.m_controller.model.selectBoard(As3.intOf(Reflect.field(_loc3_.data, "id")));
		} else if (Std.isOfType(param1.target, DecorRenderItem)) {
			_loc4_ = cast(param1.target, DecorRenderItem);
			_loc5_ = Std.isOfType(_loc4_.data, DecorateItem) ? cast(_loc4_.data, DecorateItem) : null;
			_loc6_ = _loc5_._status == 1 ? true : false;
			if (_loc5_._id > Consts.DECOR_DOG_BASE_ID) {
				if (_loc6_ == true) {
					if (Session.getInstance().m_isDogHungry == false) {
						this.m_deselectDogCache = _loc5_;
						this.m_controller.openWindow(Consts.WINDOW_NAME_CONFIRM, {
							"width": 380,
							"height": 270,
							"title": "温馨提示",
							"confirmFn": this.unUseDogComfirmFn,
							"text": "您当前还有剩余狗粮，隐藏狗后，狗将不再抓摘取果实的好友。是否现在隐藏？\n 特别说明：隐藏狗后，还是会正常消耗狗粮。"
						});
						return;
					}
				}
			} else if (_loc5_._id == -1) {
				if (_loc6_ == true) {
					return;
				}
			}
			this.m_controller.model.selectDecorate(_loc5_);
		}
	}

	// DecorateView.as:125-137
	private function onLoadFailed(param1:CommonEvent):Void {
		if (param1 == null || param1.data == null) {
			return;
		}
		var _loc2_:String = Reflect.field(param1.data, "error");
		var _loc3_:Int = this.m_tabNav.selectedIndex;
		if (_loc3_ == 0) {
			this.m_decorPage.errText = _loc2_;
		}
	}

	// DecorateView.as:139-162
	private function onDataChanged(param1:CommonEvent):Void {
		var _loc3_:Dictionary<Int, Array<Dynamic>> = null;
		if (param1 == null || param1.data == null) {
			return;
		}
		var _loc2_:Int = As3.intOf(Reflect.field(param1.data, "index"));
		if (_loc2_ == 0) {
			_loc3_ = cast Reflect.field(param1.data, "data");
			if (this.m_decorPage != null) {
				this.m_decorPage.refresh(_loc3_);
			}
		} else if (_loc2_ == 1) {
			if (this.m_boardPage != null) {
				this.m_boardPage.changeBoard(As3.intOf(Reflect.field(param1.data, "newItemId")), As3.intOf(Reflect.field(param1.data, "oldItemId")));
			}
		}
	}

	// DecorateView.as:164-175
	private function onLinkClick(param1:ViewEvent):Void {
		if (param1 == null || param1.data == null) {
			return;
		}
		if (As3.eqString(param1.data, "reload")) {
			this.m_controller.model.dirty = true;
			this.m_controller.model.loadItems();
		}
	}

	// DecorateView.as:177-191（DecorateModel.EVENT_* 原文 internal 译
	// private → @:access，WarehouseView 先例）
	@:access(module.decorate.DecorateModel)
	override private function init():Void {
		super.init();
		this.createTabs();
		var _loc1_:DecorateModel = this.m_controller.model;
		if (_loc1_ != null) {
			_loc1_.addEventListener(DecorateModel.EVENT_DATA_LOADED, this.onDataLoaded, false, 0, true);
			_loc1_.addEventListener(DecorateModel.EVENT_DATA_CHANGED, this.onDataChanged, false, 0, true);
			_loc1_.addEventListener(DecorateModel.EVENT_DATA_STATUS_CHANGED, this.onDataStatusChanged, false, 0, true);
			_loc1_.addEventListener(DecorateModel.EVENT_DATA_LOADING, this.onDataLoading, false, 0, true);
			_loc1_.addEventListener(DecorateModel.EVENT_DATA_FAILED, this.onLoadFailed, false, 0, true);
			_loc1_.addEventListener(DecorateModel.EVENT_OPERATE_FAILED, this.onOperateFailed, false, 0, true);
		}
	}

	// DecorateView.as:193-201
	private function onDataLoading(param1:CommonEvent):Void {
		if (param1 == null || param1.data == null) {
			return;
		}
		var _loc2_:Bool = As3.truthy(Reflect.field(param1.data, "show"));
		this.m_decorPage.loadingVisible = _loc2_;
	}

	// DecorateView.as:203-219
	private function onTileItemOver(param1:ViewEvent):Void {
		if (param1 == null || param1.data == null) {
			return;
		}
		var _loc2_:DecorateItem = Std.isOfType(param1.data, DecorateItem) ? cast(param1.data, DecorateItem) : null;
		if (_loc2_ == null) {
			return;
		}
		var _loc3_:Dynamic = {
			"itemName": _loc2_._name,
			"validTime": _loc2_._validTime
		};
		this.m_controller.showTip(Consts.TIP_NAME_DIY_MOUSE, _loc3_);
	}

	// DecorateView.as:221-229
	private function unUseDogComfirmFn():Void {
		if (this.m_deselectDogCache == null) {
			return;
		}
		this.m_controller.model.selectDecorate(this.m_deselectDogCache);
		this.m_deselectDogCache = null;
	}

	// DecorateView.as:231-269（addTab 第三参 24 是页签高，NaN 是宽）
	private function createTabs():Void {
		this.m_viewStack = new ViewStack();
		this.m_tabNav = new TabBar();
		this.m_tabNav.viewStack = this.m_viewStack;
		WindowTabBarMaker.addTarget(this.m_tabNav);
		this.m_tabNav.x = 0;
		this.m_tabNav.y = 30;
		this.m_tabNav.width = WIDTH - 2;
		this.m_viewStack.y = this.m_tabNav.y + this.m_tabNav.height;
		this.m_viewStack.width = WIDTH - 2;
		this.m_viewStack.height = HEIGHT - this.m_viewStack.y;
		this.m_tabNav.addEventListener(Event.CHANGE, this.onTabSwitched);
		var _loc1_:DecorateModel = this.m_controller.model;
		if (_loc1_ == null) {
			return;
		}
		this.m_decorPage = new DecorsPage(this, WIDTH, HEIGHT);
		this.m_decorPage.addEventListener(ViewEvent.LINK_CLICK, this.onReloadDecors, false, 0, true);
		this.m_decorPage.addEventListener(BaseTileItem.CHILD_CLICK, this.onTileItemClick, false, 0, true);
		this.m_decorPage.addEventListener(BaseTileItem.CHILD_OVER, this.onTileItemOver, false, 0, true);
		this.m_decorPage.addEventListener(BaseTileItem.CHILD_OUT, this.onTileItemOut, false, 0, true);
		this.m_tabNav.addTab("装饰", Math.NaN, 24);
		this.m_viewStack.addView(this.m_decorPage);
		this.m_boardPage = new BoardsPage(this, WIDTH, HEIGHT);
		this.m_boardPage.addEventListener(BaseTileItem.CHILD_CLICK, this.onTileItemClick, false, 0, true);
		this.m_boardPage.addEventListener(BaseTileItem.CHILD_OVER, this.onTileItemOver, false, 0, true);
		this.m_boardPage.addEventListener(BaseTileItem.CHILD_OUT, this.onTileItemOut, false, 0, true);
		this.m_tabNav.addTab("告示牌", Math.NaN, 24);
		this.m_viewStack.addView(this.m_boardPage);
		PluginManager.getInstance().amountPlugins(Consts.PLUGIN_AMOUNT_DECORATE, this.m_tabNav, {
			"width": Math.NaN,
			"height": 24,
			"index": 2
		});
		addChild(this.m_viewStack);
		addChild(this.m_tabNav);
	}

	// DecorateView.as:271-290
	private function onDataLoaded(param1:CommonEvent):Void {
		var _loc3_:Dictionary<Int, Array<Dynamic>> = null;
		var _loc4_:Array<Dynamic> = null;
		if (param1 == null || param1.data == null) {
			return;
		}
		var _loc2_:Int = As3.intOf(Reflect.field(param1.data, "index"));
		if (_loc2_ == 0) {
			_loc3_ = cast Reflect.field(param1.data, "data");
			this.m_decorPage.buildDecorateList(_loc3_);
		} else if (_loc2_ == 1) {
			_loc4_ = cast Reflect.field(param1.data, "data");
			this.m_boardPage.dataList = _loc4_;
		}
	}

	// DecorateView.as:292-321（按页签文字找 Button，逐字照抄）
	public function switchTabByName(param1:String):Void {
		var _loc5_:Button = null;
		if (param1 == null || param1 == "") {
			return;
		}
		var _loc2_:Int = this.m_tabNav.tabNum;
		var _loc3_:Sprite = Std.isOfType(this.m_tabNav.content, Sprite) ? cast(this.m_tabNav.content, Sprite) : null;
		if (_loc3_ == null) {
			return;
		}
		var _loc4_:Int = 0;
		while (_loc4_ < _loc2_) {
			_loc5_ = Std.isOfType(_loc3_.getChildAt(_loc4_), Button) ? cast(_loc3_.getChildAt(_loc4_), Button) : null;
			if (_loc5_ != null && _loc5_.text == param1) {
				if (this.m_tabNav.selectedIndex == _loc4_) {
					return;
				}
				this.m_tabNav.selectedIndex = _loc4_;
				this.onTabSwitched(null);
				break;
			}
			_loc4_++;
		}
	}

	// DecorateView.as:323-334
	private function onOperateFailed(param1:CommonEvent):Void {
		if (param1 == null || param1.data == null) {
			return;
		}
		var _loc2_:String = Reflect.field(param1.data, "error");
		this.m_controller.openWindow(Consts.WINDOW_NAME_ALERT, {
			"type": Consts.ALERT_TYPE_ERROR,
			"text": _loc2_
		});
	}

	// DecorateView.as:336-363（页签 2 是插件页：PluginManager 挂点，窗口矮 100）
	private function onTabSwitched(param1:Event):Void {
		if (this.m_tabNav == null) {
			return;
		}
		var _loc2_:Int = this.m_tabNav.selectedIndex;
		if (_loc2_ == 0) {
			this.m_controller.model.loadItems();
		} else if (_loc2_ == 1) {
			this.m_controller.model.loadBoards();
		} else if (_loc2_ == 2) {
			PluginManager.getInstance().onTabSwitched(Consts.PLUGIN_AMOUNT_DECORATE, 2);
		}
		if (_loc2_ == 2) {
			this.height = HEIGHT - 100;
		} else {
			this.height = HEIGHT;
		}
	}

	// DecorateView.as:365-379
	private function onReloadDecors(param1:ViewEvent):Void {
		if (param1 == null || param1.data == null) {
			return;
		}
		if (As3.eqString(param1.data, "reload")) {
			if (param1.target == this.m_decorPage) {
				this.m_controller.model.dirty = true;
				this.m_controller.model.loadItems();
			}
		}
	}

	// DecorateView.as:381-384
	private function onTileItemOut(param1:ViewEvent):Void {
		this.m_controller.hideTip();
	}

	// DecorateView.as:386-397
	private function onDataStatusChanged(param1:CommonEvent):Void {
		if (param1 == null || param1.data == null) {
			return;
		}
		if (this.m_decorPage != null) {
			this.m_decorPage.forceRefresh(As3.intOf(Reflect.field(param1.data, "type")), As3.intOf(Reflect.field(param1.data, "id")));
		}
	}
}
