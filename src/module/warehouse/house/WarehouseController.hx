package module.warehouse.house;

import com.greensock.TweenLite;
import com.qzone.farm.api.interfaces.IPluginProxy;
import common.CommonData;
import common.Consts;
import common.Language;
import common.Session;
import entities.WarehouseCrop;
import events.CommonEvent;
import framework.api.PluginManager;
import framework.base.BasePage;
import framework.base.Controller;
import interfaces.IMsgCenter;
import module.warehouse.house.widgets.CardsPage;
import module.warehouse.house.widgets.FlowerCard;
import module.warehouse.house.widgets.SendFlowerWindow;
import module.warehouse.house.widgets.WarehouseFishPage;
import openfl.display.Stage;
import openfl.events.Event;
import openfl.events.EventDispatcher;
import shim.As3;

/**
 * module.warehouse.house.WarehouseController —— WarehouseController.as
 * 逐句对应（issue #36 功能 swf 翻译：仓库）。仓库控制器：MSG_SHOW_WAREHOUSE
 * 四入口开窗选页、卖出四事件回填金币浮字、DATA_CHANGED 差异重载。
 * base Controller 的 m_view/m_model 是 Dynamic，本类自持 view/model 访问器
 * （`as` 判型 → Std.isOfType，ShopController 先例）。
 *
 * PORT-NOTE: WarehouseModel 的 EVENT_* 原文 private，registerListeners
 * 跨类读 → @:access（FriendsController 先例）；AS3 宽松等值
 * `data["k"] == 数` → As3.floatOf、`== 字串常量` → As3.eqString、
 * `k != undefined` → As3.hasProp、`== true` → As3.truthy；`as int` →
 * As3.intOf；updateHostAccount 的 int 形参按 ToInt32 语义经 intOf 强转；
 * showWarehouseSellEx 的匿名闭包自摘除（arguments.callee）→ 捕获局部
 * fn 的具名闭包（每次调用新闭包、自摘除保原语义）；for-each 的 FFDec
 * 顶部声明照译为外层 var + 循环内回填。
 */
@:keep
class WarehouseController extends Controller {
	// WarehouseController.as:25
	private var _tempID:Int;

	// WarehouseController.as:27-30
	public function new() {
		super(null);
	}

	// WarehouseController.as:32-46
	private function onSellSeedSuccess(param1:CommonEvent):Void {
		var e:CommonEvent = param1;
		module.app.dispatchEvent(new Event(Consts.DATA_BAG_RELOAD_FLAG));
		Session.getInstance().updateHostAccount(As3.intOf(Reflect.field(e.data, "money")), 0, 0);
		openFloat(Consts.FLOAT_TYPE_TEXTTIP, {
			"text": Reflect.field(e.data, "direction"),
			"parent": this.view.currentPage
		});
		this.model.seedDirty = true;
		TweenLite.delayedCall(0.5, function():Void {
			model.loadSeeds();
		});
	}

	// WarehouseController.as:48-58
	private function onSendFlower(param1:CommonEvent):Void {
		if (param1 == null || param1.data == null) {
			return;
		}
		if (this.model != null) {
			this.model.sendFlower(Reflect.field(param1.data, "uin"), Reflect.field(param1.data, "word"),
				Reflect.field(param1.data, "flower"));
		}
	}

	// WarehouseController.as:60-115
	private function onSellPlantSuccess(param1:CommonEvent):Void {
		var c:WarehouseCrop = null;
		var cIn:Dynamic = null;
		var x:Int = 0;
		var y:Int = 0;
		var stg:Stage = null;
		var pp:IPluginProxy = null;
		var e:CommonEvent = param1;
		module.app.dispatchEvent(new CommonEvent(Consts.MSG_CHECK_TASK, {"sale": e.data}));
		Session.getInstance().updateHostAccount(As3.intOf(Reflect.field(e.data, "money")), 0, 0);
		if (this.view.parent == null) {
			x = 0;
			y = 0;
			stg = Std.isOfType(Reflect.field(CommonData._root, "stage"), Stage) ? cast(Reflect.field(CommonData._root, "stage"), Stage) : null;
			if (stg != null) {
				x = Std.int((stg.stageWidth - 313) * 0.5);
				y = Std.int((stg.stageHeight - 87) * 0.5);
			}
			openFloat(Consts.FLOAT_TYPE_TEXTTIP, {
				"text": Reflect.field(e.data, "direction"),
				"parent": null,
				"x": x,
				"y": y
			});
		} else {
			openFloat(Consts.FLOAT_TYPE_TEXTTIP, {
				"text": Reflect.field(e.data, "direction"),
				"parent": As3.truthy(this.view.currentPage) ? this.view.currentPage : cast(this.view, Dynamic)
			});
		}
		module.app.dispatchEvent(new CommonEvent(Consts.DATA_CROP_RELOAD_FLAG, null));
		this.model.cropDirty = true;
		TweenLite.delayedCall(0.5, function():Void {
			model.loadCrops();
		});
		for (cIn in this.model.crops) {
			c = cIn;
			if (As3.floatOf(c._id) == As3.floatOf(Reflect.field(e.data, "cId"))) {
				pp = PluginManager.getInstance().getPluginByID(3);
				if (pp != null) {
					pp.executeCommand(2001, {"cId": c._id, "left": c._amount - As3.floatOf(Reflect.field(e.data, "num"))});
				}
				break;
			}
		}
	}

	// WarehouseController.as:117-158
	private function showWarehouseSellEx(param1:Int):Void {
		var wc:WarehouseCrop = null;
		var wcIn:Dynamic = null;
		var id:Int = param1;
		if (id == 0) {
			return;
		}
		wc = null;
		if (this.model.cropDirty == false) {
			for (wcIn in this.model.crops) {
				wc = wcIn;
				if (wc._id == id) {
					this.view.showSellSeedWindow(wc);
					return;
				}
			}
			m_module.app.dispatchEvent(new CommonEvent(Consts.MSG_NO_CROP_WAREHOUSE, id));
			return;
		}
		this.model.loadCrops();
		this._tempID = id;
		// AS3 匿名闭包经 arguments.callee 自摘除 → 捕获局部 fn 的闭包
		// （每次调用新闭包，语义同原版；WarehouseModel.EVENT_DATA_CHANGED
		// 原文 private → 本方法 @:access）
		var fn:Dynamic = null;
		fn = function(ev:CommonEvent):Void {
			if (As3.floatOf(Reflect.field(ev.data, "index")) != 0) {
				return;
			}
			cast(ev.currentTarget, EventDispatcher).removeEventListener(ev.type, fn);
			for (wcIn in this.model.crops) {
				wc = wcIn;
				if (wc._id == this._tempID) {
					this.view.showSellSeedWindow(wc);
					return;
				}
			}
			this.m_module.app.dispatchEvent(new CommonEvent(Consts.MSG_NO_CROP_WAREHOUSE, this._tempID));
		};
		this.model.addEventListener(WarehouseModel.EVENT_DATA_CHANGED, fn, false, 0, true);
	}

	// WarehouseController.as:160-170
	private function onBuyItemSuccess(param1:CommonEvent):Void {
		if (param1 == null || param1.data == null) {
			return;
		}
		if (As3.hasProp(param1.data, "cId") && As3.eqString(Reflect.field(param1.data, "type"), Consts.ITEM_TYPE_SEED)) {
			this.model.seedDirty = true;
		}
	}

	// WarehouseController.as:172-183
	private function onSellAllSuccess(param1:CommonEvent):Void {
		module.app.dispatchEvent(new CommonEvent(Consts.MSG_CHECK_TASK, {"sale": param1.data}));
		var _loc2_:String = Language.replaceText("saleAllFnText", {"money": Reflect.field(param1.data, "money")});
		openFloat(Consts.FLOAT_TYPE_TEXTTIP, {
			"text": _loc2_,
			"parent": this.view.currentPage
		});
		Session.getInstance().updateHostAccount(As3.intOf(Reflect.field(param1.data, "money")), 0, 0);
		this.model.cropDirty = true;
		this.model.loadCrops();
	}

	// WarehouseController.as:185-195
	private function onDataModelChanged(param1:CommonEvent):Void {
		if (param1 == null || param1.data == null) {
			return;
		}
		if (As3.floatOf(Reflect.field(param1.data, "index")) == 2) {
			module.app.dispatchEvent(new Event(Consts.MY_FLOWER_LOADED));
		}
	}

	// WarehouseController.as:197-203
	private function onNeedReloadFishData(param1:CommonEvent):Void {
		if (this.model != null) {
			this.model.fishDirty = true;
		}
	}

	// WarehouseController.as:205-221
	private function onWarehouseItemRemoved(param1:CommonEvent):Void {
		if (param1 == null || param1.data == null || !As3.hasProp(param1.data, "id")) {
			return;
		}
		var _loc2_:Int = As3.intOf(Reflect.field(param1.data, "id"));
		var _loc3_:String = Std.string(Reflect.field(param1.data, "type"));
		if (_loc3_ != Consts.ITEM_TYPE_SEED) {
			return;
		}
		if (this.model.removeSeed(_loc2_) == true) {
			useSystemCursor(true);
		}
	}

	// WarehouseController.as:223-237
	private function onShowWarehouseSell(param1:CommonEvent):Void {
		if (param1 == null || param1.data == null) {
			return;
		}
		if (Std.isOfType(param1.data, WarehouseCrop)) {
			this.view.showSellSeedWindow(cast(param1.data, WarehouseCrop));
		} else {
			this.showWarehouseSellEx(As3.intOf(Reflect.field(param1.data, "id")));
		}
	}

	// WarehouseController.as:239-254
	private function onCropPriceChanged(param1:CommonEvent):Void {
		var _loc2_:WarehouseCrop = null;
		var _loc2In:Dynamic = null;
		if (param1 == null || param1.data == null) {
			return;
		}
		for (_loc2In in this.model.crops) {
			_loc2_ = _loc2In;
			if (As3.floatOf(_loc2_._id) == As3.floatOf(Reflect.field(param1.data, "cId"))) {
				_loc2_._price = As3.intOf(Reflect.field(param1.data, "times")) * As3.intOf(Reflect.field(param1.data, "price"));
				break;
			}
		}
	}

	// WarehouseController.as:256-266
	private function onSellAllFishSuccess(param1:CommonEvent):Void {
		var _loc2_:String = Language.replaceText("saleAllFishFnText", {"money": Reflect.field(param1.data, "money")});
		openFloat(Consts.FLOAT_TYPE_TEXTTIP, {
			"text": _loc2_,
			"parent": this.view.currentPage
		});
		Session.getInstance().updateHostAccount(As3.intOf(Reflect.field(param1.data, "money")), 0, 0);
		this.model.fishDirty = true;
		this.model.loadFishs();
	}

	// WarehouseController.as:268-298。WarehouseModel 的 EVENT_* 原文
	// private → @:access 跨类读
	@:access(module.warehouse.house.WarehouseModel)
	private function registerListeners():Void {
		if (m_module == null || m_module.app == null) {
			return;
		}
		if (m_model != null) {
			m_model.addEventListener(WarehouseModel.EVENT_SELLALL_SUCCESS, this.onSellAllSuccess, false, 0, true);
			m_model.addEventListener(WarehouseModel.EVENT_SELLPLANT_SUCCESS, this.onSellPlantSuccess, false, 0, true);
			m_model.addEventListener(WarehouseModel.EVENT_SELLSEED_SUCCESS, this.onSellSeedSuccess, false, 0, true);
			m_model.addEventListener(WarehouseModel.EVENT_SELLALLSEEDS_SUCCESS, this.onSellAllSeedsSuccess, false, 0, true);
			m_model.addEventListener(WarehouseModel.EVENT_DATA_CHANGED, this.onDataModelChanged, false, 0, true);
			m_model.addEventListener(WarehouseModel.EVENT_NET_TRANSACTION_ERROR, this.onNetTransactionFailed, false, 0, true);
			m_model.addEventListener(WarehouseModel.EVENT_SELLALLFISHS_SUCCESS, this.onSellAllFishSuccess, false, 0, true);
			m_model.addEventListener(WarehouseModel.EVENT_SELLFISH_SUCCESS, this.onSellFishSuccess, false, 0, true);
		}
		var _loc1_:IMsgCenter = Std.isOfType(m_module.app, IMsgCenter) ? cast(m_module.app, IMsgCenter) : null;
		if (_loc1_ != null) {
			_loc1_.addEventListener(Consts.MSG_SHOW_WAREHOUSE, this.onShowWarehouse, false, 0, true);
			_loc1_.addEventListener(Consts.MSG_SHOW_WAREHOUSE_SELL, this.onShowWarehouseSell, false, 0, true);
			_loc1_.addEventListener(Consts.DATA_BUY_ITEM_ADD, this.onBuyItemSuccess, false, 0, true);
			_loc1_.addEventListener(Consts.DATA_BAG_DATA_REMOVE, this.onWarehouseItemRemoved, false, 0, true);
			_loc1_.addEventListener(Consts.DATA_CROP_RELOAD_FLAG, this.onNeedReloadData, false, 0, true);
			_loc1_.addEventListener(Consts.DATA_FISH_RELOAD_FLAG, this.onNeedReloadFishData, false, 0, true);
			_loc1_.addEventListener(Consts.MSG_FLOWER_DELETED, this.onFlowerDeleted, false, 0, true);
			_loc1_.addEventListener(Consts.MSG_FLOWER_SEND, this.onSendFlower, false, 0, true);
			_loc1_.addEventListener("__PLUGIN_3_PRICE__", this.onCropPriceChanged, false, 0, true);
		}
	}

	// WarehouseController.as:300-309
	private function onNetTransactionFailed(param1:CommonEvent):Void {
		if (param1 != null && param1.data != null) {
			openWindow(Consts.WINDOW_NAME_ALERT, {
				"type": Consts.ALERT_TYPE_ERROR,
				"text": Reflect.field(param1.data, "error")
			});
		}
	}

	// WarehouseController.as:311-314
	override public function finalize():Void {
		super.finalize();
	}

	// WarehouseController.as:316-323
	private function onNeedReloadData(param1:CommonEvent):Void {
		if (this.model != null) {
			this.model.cropDirty = true;
			this.model.seedDirty = true;
		}
	}

	// WarehouseController.as:325-328
	public var view(get, never):WarehouseView;

	private function get_view():WarehouseView {
		return Std.isOfType(this.m_view, WarehouseView) ? cast(this.m_view, WarehouseView) : null;
	}

	// WarehouseController.as:330-340
	private function onFlowerDeleted(param1:CommonEvent):Void {
		if (param1 == null || param1.data == null) {
			return;
		}
		if (this.model != null) {
			this.model.removeMyFlower(param1.data);
		}
	}

	// WarehouseController.as:342-378
	private function onShowWarehouse(param1:CommonEvent):Void {
		var _loc2_:BasePage = null;
		if (param1.data == null) {
			m_module.app.farmView.winCtrl.open(cast(this.m_view, framework.base.BaseWindow));
			this.model.cropDirty = true;
			this.model.loadCrops();
			_loc2_ = this.view.currentPage;
			if (_loc2_ != null && Std.isOfType(_loc2_, WarehouseFishPage)) {
				this.model.loadFishs();
			}
			if (_loc2_ != null && Std.isOfType(_loc2_, CardsPage)) {
				this.model.loadCrystal();
			}
		} else if (As3.truthy(Reflect.field(param1.data, "openWithSeeds"))) {
			m_module.app.farmView.winCtrl.open(cast(this.m_view, framework.base.BaseWindow));
			this.view.switchTab(4);
			this.model.loadSeeds();
		} else if (As3.truthy(Reflect.field(param1.data, "openWithFlower"))) {
			m_module.app.farmView.winCtrl.open(cast(this.m_view, framework.base.BaseWindow));
			this.view.switchTab(3);
			this.model.loadMyFlowers();
		} else if (As3.truthy(Reflect.field(param1.data, "openWithCrystal"))) {
			m_module.app.farmView.winCtrl.open(cast(this.m_view, framework.base.BaseWindow));
			this.view.switchTab(5);
			this.model.loadCrystal();
		}
	}

	// WarehouseController.as:380-383
	public var model(get, never):WarehouseModel;

	private function get_model():WarehouseModel {
		return Std.isOfType(this.m_model, WarehouseModel) ? cast(this.m_model, WarehouseModel) : null;
	}

	// WarehouseController.as:385-402
	override public function initialze():Void {
		super.initialze();
		if (m_model == null) {
			m_model = new WarehouseModel();
		}
		this.registerListeners();
		if (m_view == null) {
			m_view = new WarehouseView(this);
		}
		if (m_module != null) {
			m_module.app.farmView.winCtrl.register(Consts.WINDOW_NAME_SENDFLOWER, SendFlowerWindow);
			m_module.app.farmView.winCtrl.register(Consts.WINDOW_NAME_FLOWER_CARD, FlowerCard);
		}
	}

	// WarehouseController.as:404-407
	private function onSellAllSeedsSuccess(param1:CommonEvent):Void {
		this.onSellSeedSuccess(param1);
	}

	// WarehouseController.as:409-423
	private function onSellFishSuccess(param1:CommonEvent):Void {
		var _loc2_:String = Language.replaceText("saleFishText", {
			"money": Reflect.field(param1.data, "money"),
			"num": Reflect.field(param1.data, "number"),
			"name": Reflect.field(param1.data, "name")
		});
		openFloat(Consts.FLOAT_TYPE_TEXTTIP, {
			"text": _loc2_,
			"parent": this.view.currentPage
		});
		Session.getInstance().updateHostAccount(As3.intOf(Reflect.field(param1.data, "money")), 0, 0);
		this.model.fishDirty = true;
		this.model.loadFishs();
	}
}
