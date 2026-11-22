package module.shop;

import com.qzone.utils.StringUtil;
import common.CommonData;
import common.Consts;
import common.Language;
import common.Session;
import entities.Dog;
import entities.Item;
import entities.Seed;
import events.CommonEvent;
import framework.api.beast.BeastAPI;
import framework.base.Controller;
import interfaces.IMsgCenter;
import module.GameGuide;
import openfl.display.Stage;
import shim.As3;

/**
 * module.shop.ShopController —— ShopController.as 逐句对应（issue #35 功能
 * swf 翻译：商店）。app 上的 MSG_SHOW_* 三入口 → ShopView 开窗路由；model
 * 十事件 → 买入成功/失败提示。base Controller 的 m_view/m_model 是 Dynamic，
 * 本类自持 view/model 访问器（as 判型，原样）。
 *
 * PORT-NOTE: `__buyType`/`__exp` 是 Dynamic（ShopModel 里 "0" 字串与 Int 混写
 * ——原版即如此），AS3 宽松等值 `"0" == 0` 为 true；静态目标直 `==` 会因类型
 * 先行判不等而漏分支，故统一 As3.floatOf（toNumber 强转）再比。onUnlockFish
 * Success 的水晶分支 E4X 无对应物且本部署不可达（见方法内注）。
 *
 * 本类经 ModuleShop.onModuleLoadSuccess 的反射字符串构造（编译期零引用），
 * 入 SymbolClass.dceAnchor 锚住 + @:keep 在 dce full 下保命（LandTile 先例
 * ：零引用类不进产物，反射恒 null）；锚住后 html5 的 hasDefinition 即真，
 * ModuleShop 装配链按原版拉起链（spec/modules/farm-shop-ui.json notes）走通。
 */
@:keep
class ShopController extends Controller {
	// ShopController.as:21
	private var _tempID:Int;

	public function new() {
		super(null);
	}

	// ShopController.as:28-51
	private function registerListeners():Void {
		if (this.m_module == null || this.m_module.app == null) {
			return;
		}
		var _loc1_:IMsgCenter = Std.isOfType(this.m_module.app, IMsgCenter) ? cast(this.m_module.app, IMsgCenter) : null;
		if (_loc1_ != null) {
			_loc1_.addEventListener(Consts.MSG_SHOW_SHOP, this.onShowShop, false, 0, true);
			_loc1_.addEventListener(Consts.MSG_SHOW_BUY_DOG_FOOD, this.onShowBuyDogFood, false, 0, true);
			_loc1_.addEventListener(Consts.MSG_SHOW_BUY_SEED, this.onShowBuySeed, false, 0, true);
		}
		this.model.addEventListener(ShopModel.EVENT_BUY_SEED_SUCCESS, this.onBuySeedSuccess, false, 0, true);
		this.model.addEventListener(ShopModel.EVENT_BUY_SEED_FAIL, this.onReportError, false, 0, true);
		this.model.addEventListener(ShopModel.EVENT_BUY_FISH_SUCCESS, this.onBuyFishSuccess, false, 0, true);
		this.model.addEventListener(ShopModel.EVENT_BUY_FISH_FAIL, this.onReportError, false, 0, true);
		this.model.addEventListener(ShopModel.EVENT_BUY_TOOL_SUCCESS, this.onBuyToolSuccess, false, 0, true);
		this.model.addEventListener(ShopModel.EVENT_BUY_TOOL_FAIL, this.onReportError, false, 0, true);
		this.model.addEventListener(ShopModel.EVENT_BUY_DIY_SUCCESS, this.onBuyDiySuccess, false, 0, true);
		this.model.addEventListener(ShopModel.EVENT_BUY_DIY_FAIL, this.onReportError, false, 0, true);
		this.model.addEventListener(ShopModel.EVENT_UNLOCK_FISH_SUCCESS, this.onUnlockFishSuccess, false, 0, true);
		this.model.addEventListener(ShopModel.EVENT_NORMAL_ERROR, this.onReportError, false, 0, true);
	}

	// ShopController.as:53-75
	private function onBuyFishSuccess(param1:CommonEvent):Void {
		if (param1 == null || param1.data == null) {
			return;
		}
		var _loc2_:Dynamic = param1.data;
		Session.getInstance().updateHostAccount(Std.int(As3.parseInt(Reflect.field(_loc2_, "money"))), 0, 0);
		var _loc3_:Dynamic = {
			"money": Math.abs(As3.floatOf(Reflect.field(_loc2_, "money"))),
			"num": Reflect.field(_loc2_, "num"),
			"name": Reflect.field(_loc2_, "name")
		};
		var _loc4_:String = Language.replaceText("buyFishFnText", _loc3_);
		this.openFloat(Consts.FLOAT_TYPE_TEXTTIP, {
			"text": _loc4_,
			"parent": this.view.currentPage
		});
		Reflect.setField(_loc2_, "type", Consts.ITEM_TYPE_FISH);
		var _loc5_:IMsgCenter = Std.isOfType(this.m_module.app, IMsgCenter) ? cast(this.m_module.app, IMsgCenter) : null;
		_loc5_.dispatchEvent(new CommonEvent(Consts.DATA_BUY_ITEM_ADD, _loc2_));
		this.view.showArrowOnClose = 1;
	}

	// ShopController.as:77-80
	public var view(get, never):ShopView;

	private function get_view():ShopView {
		return Std.isOfType(this.m_view, ShopView) ? cast(this.m_view, ShopView) : null;
	}

	// ShopController.as:82-116
	private function onBuyToolSuccess(param1:CommonEvent):Void {
		var _loc4_:Dog = null;
		if (param1 == null || param1.data == null) {
			return;
		}
		var _loc2_:Dynamic = param1.data;
		var _loc3_:IMsgCenter = Std.isOfType(this.m_module.app, IMsgCenter) ? cast(this.m_module.app, IMsgCenter) : null;
		_loc3_.dispatchEvent(new CommonEvent(Consts.DATA_BUY_ITEM_ADD, _loc2_));
		if (As3.eqString(Reflect.field(_loc2_, "type"), Consts.ITEM_TYPE_DOG)) {
			_loc4_ = new Dog(null);
			_loc4_._dogId = As3.intOf(Reflect.field(_loc2_, "tId"));
			_loc4_._isHungry = 0;
			_loc3_.dispatchEvent(new CommonEvent(Consts.DATA_DOG_CHANGED, _loc4_));
			_loc3_.dispatchEvent(new CommonEvent(Consts.MSG_SWITCH_USER, null));
			_loc3_.dispatchEvent(new CommonEvent(Consts.DATA_DECORATE_RELOAD_FLAG, null));
		}
		if (As3.floatOf(Reflect.field(_loc2_, "__buyType")) == 2) {
			this.openWindow(Consts.WINDOW_NAME_ALERT, {
				"type": Consts.ALERT_TYPE_SUCCESS,
				"text": "购买成功"
			});
		} else if (As3.floatOf(Reflect.field(_loc2_, "__buyType")) == 1 || As3.floatOf(Reflect.field(_loc2_, "__buyType")) == 0) {
			Session.getInstance().updateHostAccount(Std.int(As3.parseInt(Reflect.field(_loc2_, "money"))), 0, As3.intOf(Reflect.field(_loc2_, "FB")));
			this.openWindow(Consts.WINDOW_NAME_ALERT, {
				"type": Consts.ALERT_TYPE_SUCCESS,
				"text": "购买成功"
			});
		}
	}

	// ShopController.as:118-144
	private function onUnlockFishSuccess(param1:CommonEvent):Void {
		var xml:Dynamic = null;
		var msg:String = null;
		var data:Dynamic = null;
		var crystalName:String = null;
		var e:CommonEvent = param1;
		if (e == null || e.data == null) {
			return;
		}
		data = e.data;
		Session.getInstance().updateHostAccount(Std.int(As3.parseInt(Reflect.field(data, "money"))), 0, 0);
		xml = BeastAPI.getInstance().iniData;
		msg = "鱼苗解锁成功，共花费金币<font color='#FF6600'>" + Math.abs(As3.floatOf(Reflect.field(data, "money"))) + "</font>";
		if (As3.hasProp(data, "crystal_num") && As3.hasProp(data, "crystal_id")) {
			// PORT-NOTE: 原版此分支做 E4X 滤取
			// `crystalName = xml.crystal.info.(@id == data["crystal_id"].toString()).@name;
			//  msg += "，" + crystalName + "<font color='#FF6600'>" + data["crystal_num"] + "</font>个";`
			// E4X 在 Haxe 无对应物；且本部署不可达——cgi_fish_unlock.php 回包只含
			// code/money/n/fid（无水晶字段），BeastAPI.iniData 保持 null（见
			// BeastAPI.hx iniData 注）。守卫照译，分支体不追加水晶段；若未来
			// 牧场片接入需补 XML 取名逻辑（列 spec/deviations.json 人工裁决）。
		}
		this.openFloat(Consts.FLOAT_TYPE_TEXTTIP, {
			"text": msg,
			"parent": this.view.currentPage
		});
		GameGuide.instance().showStep(GameGuide.WATER_FISH_ITEM_AGAIN);
		GameGuide.instance().autoHide(5);
	}

	// ShopController.as:146-148
	public var model(get, never):ShopModel;

	private function get_model():ShopModel {
		return Std.isOfType(this.m_model, ShopModel) ? cast(this.m_model, ShopModel) : null;
	}

	// ShopController.as:151-195
	private function onBuySeedSuccess(param1:CommonEvent):Void {
		var _loc6_:Int = 0;
		var _loc7_:Int = 0;
		var _loc8_:Stage = null;
		if (param1 == null || param1.data == null) {
			return;
		}
		var _loc2_:Dynamic = param1.data;
		Session.getInstance().updateHostAccount(Std.int(As3.parseInt(Reflect.field(_loc2_, "money"))), 0, 0);
		var _loc3_:Dynamic = {
			"money": Math.abs(As3.floatOf(Reflect.field(_loc2_, "money"))),
			"num": Reflect.field(_loc2_, "num"),
			"cName": Reflect.field(_loc2_, "cName")
		};
		var _loc4_:String = Language.replaceText("buySeedFnText", _loc3_);
		if (this.view.parent == null) {
			_loc6_ = 0;
			_loc7_ = 0;
			_loc8_ = Std.isOfType(Reflect.field(CommonData._root, "stage"), Stage) ? cast(Reflect.field(CommonData._root, "stage"), Stage) : null;
			if (_loc8_ != null) {
				_loc6_ = Std.int((_loc8_.stageWidth - 313) * 0.5);
				_loc7_ = Std.int((_loc8_.stageHeight - 87) * 0.5);
			}
			this.openFloat(Consts.FLOAT_TYPE_TEXTTIP, {
				"text": _loc4_,
				"parent": null,
				"x": _loc6_,
				"y": _loc7_
			});
		} else {
			this.openFloat(Consts.FLOAT_TYPE_TEXTTIP, {
				"text": _loc4_,
				"parent": As3.or(this.view.currentPage, this.view)
			});
		}
		Reflect.setField(_loc2_, "type", Consts.ITEM_TYPE_SEED);
		var _loc5_:IMsgCenter = Std.isOfType(this.m_module.app, IMsgCenter) ? cast(this.m_module.app, IMsgCenter) : null;
		_loc5_.dispatchEvent(new CommonEvent(Consts.DATA_BUY_ITEM_ADD, _loc2_));
	}

	// ShopController.as:197-260
	private function showBuySeedEx(param1:Int, param2:String):Void {
		var seed:Seed = null;
		var it:Item = null;
		var id:Int = param1;
		var type:String = param2;
		if (id == 0) {
			return;
		}
		if (type == null || type == "" || type == "seed") {
			for (seedIn in this.model.seeds) {
				seed = Std.isOfType(seedIn, Seed) ? cast(seedIn, Seed) : null;
				if (seed._id == id) {
					this.view.showBuySeedWindow(seed);
					return;
				}
			}
			this.model.loadSeedsInfo();
		} else if (type == "item") {
			for (itIn in this.model.items) {
				it = Std.isOfType(itIn, Item) ? cast(itIn, Item) : null;
				if (it._id == id) {
					this.view.showBuyItemWindow(it, false);
					break;
				}
			}
			this.model.loadItemsInfo();
		}
		this._tempID = id;
		// PORT-NOTE: 原版监听器是匿名函数并以 arguments.callee 自摘除；Haxe 无
		// callee → 具名局部闭包自引用，摘除调用照原样走 param1.currentTarget
		var onLoadedOnce:Dynamic->Void = null;
		onLoadedOnce = function(param1:CommonEvent):Void {
			var _loc3_:Seed = null;
			var _loc4_:Item = null;
			param1.currentTarget.removeEventListener(param1.type, onLoadedOnce);
			if (As3.intOf(Reflect.field(param1.data, "index")) == 0) {
				for (seedIn in model.seeds) {
					_loc3_ = Std.isOfType(seedIn, Seed) ? cast(seedIn, Seed) : null;
					if (_loc3_._id == _tempID) {
						view.showBuySeedWindow(_loc3_);
						break;
					}
				}
			} else if (As3.intOf(Reflect.field(param1.data, "index")) == 2) {
				for (itIn in model.items) {
					_loc4_ = Std.isOfType(itIn, Item) ? cast(itIn, Item) : null;
					if (_loc4_._id == _tempID) {
						view.showBuyItemWindow(_loc4_, false);
						break;
					}
				}
			}
		};
		this.model.addEventListener(ShopModel.EVENT_SHOP_DATA_LOADED, onLoadedOnce);
	}

	// ShopController.as:262-274
	override public function initialze():Void {
		super.initialze();
		if (this.m_model == null) {
			this.m_model = new ShopModel();
		}
		this.registerListeners();
		if (this.m_view == null) {
			this.m_view = new ShopView(this);
		}
	}

	// ShopController.as:276-283
	private function onShowBuyDogFood(param1:CommonEvent):Void {
		if (param1 == null || param1.data == null) {
			return;
		}
		this.view.showBuyItemWindow(Std.isOfType(param1.data, Item) ? cast(param1.data, Item) : null, true);
	}

	// ShopController.as:285-351
	private function onShowShop(param1:CommonEvent):Void {
		var _loc2_:Int = 0;
		if (param1.data == null) {
			_loc2_ = this.view.currentPageIndex;
			if (_loc2_ == -1) {
				_loc2_ = 0;
			}
			if (this.model.isEmpty(_loc2_) == true) {
				if (_loc2_ == 0) {
					this.model.loadSeedsInfo();
				} else if (_loc2_ == 1) {
					this.model.loadFishInfo();
				} else if (_loc2_ == 2) {
					this.model.loadItemsInfo();
				} else if (_loc2_ == 3) {
					this.model.loadDecorsInfo();
				}
			}
			this.m_module.app.farmView.winCtrl.open(this.m_view);
		} else {
			this.m_module.app.farmView.winCtrl.open(this.m_view);
			_loc2_ = As3.intOf(Reflect.field(param1.data, "tabIndex"));
			if (this.model.isEmpty(_loc2_) == true) {
				if (_loc2_ == 0) {
					this.model.loadSeedsInfo();
				} else if (_loc2_ == 1) {
					this.model.loadFishInfo();
				} else if (_loc2_ == 2) {
					this.model.loadItemsInfo();
				} else if (_loc2_ == 3) {
					this.model.loadDecorsInfo();
				}
			}
			(Std.isOfType(this.m_view, ShopView) ? cast(this.m_view, ShopView) : null).currentPageIndex = _loc2_;
		}
		if (_loc2_ == 1) {
			GameGuide.instance().showStep(GameGuide.WATER_FISH_ITEM);
			GameGuide.instance().autoHide(5);
		} else {
			GameGuide.instance().showStep(GameGuide.WATER_FISH_TAB);
			GameGuide.instance().autoHide(5);
		}
	}

	// ShopController.as:353-379
	private function onReportError(param1:CommonEvent):Void {
		var _loc3_:String = null;
		if (param1 == null || param1.data == null) {
			return;
		}
		var _loc2_:Dynamic = param1.data;
		if (As3.hasProp(_loc2_, "direction") == true && StringUtil.trim(Reflect.field(_loc2_, "direction")) != "") {
			this.openWindow(Consts.WINDOW_NAME_ALERT, {
				"type": Consts.ALERT_TYPE_ERROR,
				"text": Reflect.field(_loc2_, "direction")
			});
		} else if (As3.hasProp(_loc2_, "errorType") == true) {
			_loc3_ = Reflect.field(_loc2_, "errorType");
			if (_loc3_ == "IOError" || _loc3_ == "httpStatus" || _loc3_ == "timeOut" || _loc3_ == "PHPError") {
				this.openWindow(Consts.WINDOW_NAME_ALERT, {
					"type": Consts.ALERT_TYPE_ERROR,
					"text": Reflect.field(Language.L, "请求超时，稍后再试")
				});
			}
		}
	}

	// ShopController.as:381-432
	private function onBuyDiySuccess(param1:CommonEvent):Void {
		var _loc4_:String = null;
		if (param1 == null || param1.data == null) {
			return;
		}
		var _loc2_:IMsgCenter = Std.isOfType(this.m_module.app, IMsgCenter) ? cast(this.m_module.app, IMsgCenter) : null;
		_loc2_.dispatchEvent(new CommonEvent(Consts.DATA_DECORATE_RELOAD_FLAG, null));
		var _loc3_:Dynamic = param1.data;
		if (As3.floatOf(Reflect.field(_loc3_, "__buyType")) == 1) {
			if (As3.floatOf(Reflect.field(_loc3_, "__exp")) > 0) {
				_loc2_.dispatchEvent(new CommonEvent(Consts.MSG_CHECK_LEVELUP, As3.intOf(Reflect.field(_loc3_, "__exp"))));
				Session.getInstance().updateHostAccount(0, As3.intOf(Reflect.field(_loc3_, "__exp")), 0);
				this.openWindow(Consts.WINDOW_NAME_ALERT, {
					"type": Consts.ALERT_TYPE_SUCCESS,
					"text": Reflect.field(Language.L, "购买装饰成功")
				});
			}
		} else if (As3.floatOf(Reflect.field(_loc3_, "__buyType")) == 2) {
			this.openWindow(Consts.WINDOW_NAME_ALERT, {
				"type": Consts.ALERT_TYPE_SUCCESS,
				"text": "购买成功"
			});
		} else if (As3.floatOf(Reflect.field(_loc3_, "__buyType")) == 3) {
			if (As3.floatOf(Reflect.field(_loc3_, "__exp")) > 0) {
				_loc2_.dispatchEvent(new CommonEvent(Consts.MSG_CHECK_LEVELUP, As3.intOf(Reflect.field(_loc3_, "__exp"))));
				Session.getInstance().updateHostAccount(0, As3.intOf(Reflect.field(_loc3_, "__exp")), 0);
			}
		} else {
			Session.getInstance().updateHostAccount(As3.intOf(Reflect.field(_loc3_, "money")), As3.intOf(Reflect.field(_loc3_, "exp")), As3.intOf(Reflect.field(_loc3_, "FB")));
			_loc4_ = StringUtil.replaceText("购买成功，花费金币<font color=\"#FF6600\"> <b>{money}</b> </font>，获得经验<font color=\"#FF6600\"> <b>{exp}</b> </font>", {
				"money": Math.abs(As3.floatOf(Reflect.field(_loc3_, "money"))),
				"exp": Reflect.field(_loc3_, "exp")
			});
			this.openFloat(Consts.FLOAT_TYPE_TEXTTIP, {
				"text": _loc4_,
				"parent": this.view.currentPage
			});
			_loc2_.dispatchEvent(new CommonEvent(Consts.MSG_LEVELUP, _loc3_));
		}
		this.view.setDiyBought(As3.intOf(Reflect.field(_loc3_, "itemId")));
	}

	// ShopController.as:434-448
	private function onShowBuySeed(param1:CommonEvent):Void {
		if (param1 == null || param1.data == null) {
			return;
		}
		if (Std.isOfType(param1.data, Seed)) {
			this.view.showBuySeedWindow(Std.isOfType(param1.data, Seed) ? cast(param1.data, Seed) : null);
		} else {
			this.showBuySeedEx(As3.intOf(Reflect.field(param1.data, "id")), Reflect.field(param1.data, "type"));
		}
	}

	// ShopController.as:450-453
	override public function finalize():Void {
		super.finalize();
	}
}
