package module.warehouse.bag;

import common.Consts;
import entities.BagItem;
import events.CommonEvent;
import framework.base.Controller;
import interfaces.IMsgCenter;
import module.GameGuide;
import openfl.display.DisplayObject;
import openfl.events.Event;
import shim.As3;

/**
 * module.warehouse.bag.MyBagController —— MyBagController.as 逐句对应
 * （issue #36 功能 swf 翻译：仓库）。背包控制器：MSG_SHOW_PACK 开关背包条、
 * DATA_BAG_* 增删改标脏重载、EVENT_INITIALZED 装载完回填视图。
 * base Controller 的 m_view/m_model 是 Dynamic，本类自持 view/model 访问器
 * （`as` 判型 → Std.isOfType，ShopController 先例）。
 *
 * PORT-NOTE: MyBagModel 的 EVENT_INITIALZED 原文 private，registerListeners
 * 跨类读 → @:access（FriendsController 先例）；`data["close"] == true` 的
 * 宽松真值 → As3.truthy；`data["id"] as int`/`data["type"] as int` →
 * As3.intOf；`parseInt(this._buyType)` → As3.parseInt（NaN→0 由 intOf 吸收，
 * updateBag 形参 int 的 AS3 隐式截断等价）。
 */
@:keep
class MyBagController extends Controller {
	// MyBagController.as:12
	private var _buyType:String = "";

	// MyBagController.as:14
	private var _openLater:Bool;

	// MyBagController.as:16-20
	public function new() {
		super(null);
		this._openLater = false;
	}

	// MyBagController.as:22-25
	public var view(get, never):MyBagView;

	private function get_view():MyBagView {
		return Std.isOfType(this.m_view, MyBagView) ? cast(this.m_view, MyBagView) : null;
	}

	// MyBagController.as:27-36
	private function showFishGuide():Void {
		var _loc1_:GameGuide = GameGuide.instance();
		if (_loc1_.currentStep == GameGuide.WATER_BAG_ICON_FISH) {
			this.view.switchTab(1);
			_loc1_.showStep(GameGuide.WATER_BAG_FISH_ITEM);
			_loc1_.autoHide(3);
		}
	}

	// MyBagController.as:38-64
	private function onShowMyPack(param1:CommonEvent):Void {
		if (param1.data != null && As3.truthy(Reflect.field(param1.data, "close"))) {
			if (this.m_view != null) {
				this.m_view.show(false);
			}
		} else {
			if (this.m_view == null) {
				this.m_view = new MyBagView(this);
				if (this.m_module != null && this.m_module.container != null) {
					this.m_module.container.addChild(cast(this.m_view, DisplayObject));
				}
			}
			if (this.model.dirty == false) {
				this.view.toggleVisible();
				this.showFishGuide();
			} else {
				this._openLater = true;
				this.model.reload();
				GameGuide.instance().hide();
			}
		}
	}

	// MyBagController.as:66-78
	private function onBagDirty(param1:Event):Void {
		if (this.model != null) {
			this.model.dirty = true;
		}
		if (As3.truthy(this.m_view) && As3.truthy(this.m_view.visible)) {
			if (this._buyType == Consts.ITEM_TYPE_FISH || this._buyType == Consts.ITEM_TYPE_SEED) {
				this.model.reload();
			}
		}
	}

	// MyBagController.as:80-89
	private function onDataLoaded(param1:CommonEvent):Void {
		if (this._openLater == true) {
			this.view.show(true);
			this.showFishGuide();
		} else if (As3.truthy(this.m_view)) {
			this.m_view.updateBag(As3.intOf(As3.parseInt(this._buyType)));
		}
		this._openLater = false;
	}

	// MyBagController.as:91-102
	override public function initialze():Void {
		super.initialze();
		if (this.m_module.container == null) {
			return;
		}
		if (this.m_model == null) {
			this.m_model = new MyBagModel();
		}
		this.registerListeners();
	}

	// MyBagController.as:104-113
	private function onBuyItemSuccess(param1:CommonEvent):Void {
		if (As3.truthy(param1) && As3.truthy(param1.data)) {
			this._buyType = Reflect.field(param1.data, "type");
		} else {
			this._buyType = "";
		}
		this.onBagDirty(param1);
	}

	// MyBagController.as:115-120
	private function onPoolOrLandIsFull(param1:Event):Void {
		if (As3.truthy(this.m_view)) {
			this.m_view.onPoolOrLandIsFull(param1);
		}
	}

	// MyBagController.as:122-147
	private function onBagRemoved(param1:CommonEvent):Void {
		if (param1 == null || param1.data == null) {
			return;
		}
		var _loc2_:Int = As3.intOf(Reflect.field(param1.data, "id"));
		var _loc3_:Int = As3.intOf(Reflect.field(param1.data, "type"));
		var _loc4_:BagItem = this.model.getItem(_loc2_, _loc3_);
		if (_loc4_ != null && _loc4_._amount > 0) {
			_loc4_._amount--;
			if (_loc4_._amount <= 0) {
				if (As3.truthy(this.m_view)) {
					this.m_model.deleteItem(_loc2_, _loc3_);
					this.m_view.updateBag(_loc3_);
				}
				this.setCursor(Consts.CURSOR_STYLE_ARROW, "");
			} else {
				this.m_view.updateBag(_loc3_);
			}
			this.onBagDirty(param1);
		}
	}

	// MyBagController.as:149-156
	public var model(get, never):MyBagModel;

	private function get_model():MyBagModel {
		if (this.m_model != null) {
			return Std.isOfType(this.m_model, MyBagModel) ? cast(this.m_model, MyBagModel) : null;
		}
		return null;
	}

	// MyBagController.as:158-161
	private function onBagAdded(param1:CommonEvent):Void {
		this.onBagDirty(param1);
	}

	// MyBagController.as:163-177。MyBagModel.EVENT_INITIALZED 原文 private
	// → @:access 跨类读（FriendsController 先例）
	@:access(module.warehouse.bag.MyBagModel)
	private function registerListeners():Void {
		var _loc1_:IMsgCenter = Std.isOfType(this.m_module.app, IMsgCenter) ? cast(this.m_module.app, IMsgCenter) : null;
		if (_loc1_ != null) {
			_loc1_.addEventListener(Consts.MSG_SHOW_PACK, this.onShowMyPack, false, 0, true);
			_loc1_.addEventListener(Consts.DATA_BUY_ITEM_ADD, this.onBuyItemSuccess, false, 0, true);
			_loc1_.addEventListener(Consts.DATA_BAG_RELOAD_FLAG, this.onBagDirty, false, 0, true);
			_loc1_.addEventListener(Consts.DATA_BAG_DATA_REMOVE, this.onBagRemoved, false, 0, true);
			_loc1_.addEventListener(Consts.DATA_BAG_DATA_ADD, this.onBagAdded, false, 0, true);
		}
		this.m_model.addEventListener(MyBagModel.EVENT_INITIALZED, this.onDataLoaded, false, 0, true);
		this.m_module.app.addEventListener(Consts.CLOSE_MY_BAG, this.onPoolOrLandIsFull, false, 0, true);
	}

	// MyBagController.as:179-182
	override public function finalize():Void {
		super.finalize();
	}
}
