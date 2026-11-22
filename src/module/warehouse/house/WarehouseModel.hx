package module.warehouse.house;

import com.qzone.farm.api.interfaces.IPluginProxy;
import com.qzone.qfa.events.CommandEvent;
import common.Consts;
import common.GetCropID;
import common.Language;
import common.Session;
import common.Settings;
import common.misc.QzoneJSAPI;
import entities.WarehouseCrop;
import entities.WarehouseFish;
import entities.WarehouseSeed;
import events.CommonEvent;
import framework.api.PluginManager;
import framework.api.beast.WildData;
import framework.net.CommandDefs;
import framework.net.NetHelper;
import framework.net.vo.ServiceResultVO;
import openfl.events.EventDispatcher;
import openfl.events.IEventDispatcher;
import report.EventRecorder;
import shim.As3;
import EvtAPI;

/**
 * module.warehouse.house.WarehouseModel —— WarehouseModel.as 逐句对应
 * （issue #36 功能 swf 翻译：仓库）。仓库六页签的数据装载与出售：蔬果/鲜花
 * （cgi_farm_getusercrop 36，应答单表按 isFlower/type 拆三仓）、种子
 * （cgi_farm_seed_list 37）、收到的花束（cgi_farm_flower_received 47）、
 * 水晶材料（cgi_farm_get_usercrystal 55）、成鱼（cgi_fish_user_rep 62）；
 * 卖出单品（repertory sale 81 / cgi_farm_seed_sell 82 / cgi_fish_sale 64
 * flag=single / cgi_farm_sell_crystal 56 经 onSellPlantSuccess 复用）、全部
 * （repertory saleAll 80 / cgi_farm_seed_sell 103 cIds 批量 / cgi_fish_sale
 * 64 批量）、上锁（cgi_farm_set_lock 120 / cgi_fish_rep_lock 122）、送花
 * （cgi_farm_flower_send 50）。
 *
 * PORT-NOTE: 应答对象的 `x[k]` 读 → Reflect.field、`x[k] != undefined` 键判
 * → As3.hasProp、`code == 1/"1"` 的松等 → As3.floatOf/eqString（ShopModel
 * 先例）；`int -= parseFloat` → As3.intSub（隐式 int 强转显式化）；`x[k] as
 * VO/String` → Std.isOfType 判型收窄；AS3 for each 的**循环变量残留**（onFish
 * LockSuccess :184/:193 未命中派发载荷、onLockSuccess :162 命中载荷）经
 * 「循环体内赋值给外层同名 loc 变量」保形——Haxe for 循环变量按元素类型重新
 * 绑定（FarmStage 先例），直 for-in 会让残留丢失；for each 对 null 表零次
 * 迭代 → 显式判空（FarmLandModel 先例）。`splice(0)` → `splice(0, length)`。
 * NetHelper.sendRequest 在 theApp == null 时 no-op——请求侧参数拼装
 * （sellPlant 的 {cId,number,hw,onlineTime}、sellAll/sellAllFish 的 cIds/fIds
 * 逗号串、锁的 "id:1/2" 串）不可观测；EventRecorder 已按 deviations
 * （no-qq-telemetry）DISABLED，recordResp/recordSueecssEvent/
 * recordErrorEvent 只保不抛；QzoneJSAPI.reportError/getOnlineTime 在 eval
 * 上安全（QQOutlets.available 恒 false）。onCrystalsLoaded 的
 * WildData.reloadCrystal=false 走本 issue 的最小 stub（见
 * framework/api/beast/WildData.hx，beast 片整类翻译在后续模块）。
 * AS3 internal static const → private（CLAUDE.md 映射）；AS3 的 get/set 对
 * （flowers/cropDirty/seedDirty/fishDirty，声明点分散）合成一个 Haxe
 * property；同包消费方按 FriendsController 先例用 @:access 取。
 */
class WarehouseModel extends EventDispatcher {
	// WarehouseModel.as:27（AS3 internal static const → private，CLAUDE.md 映射）
	private static final EVENT_DATA_CHANGED:String = "DataChanged";

	// WarehouseModel.as:29
	private static final EVENT_DATA_LOADING:String = "WarehouseDataLoading";

	// WarehouseModel.as:31
	private static final EVENT_DATA_FAILED:String = "WarehouseDataFailed";

	// WarehouseModel.as:33
	public static final EVENT_NET_TRANSACTION_ERROR:String = "NetTransactionError";

	// WarehouseModel.as:35
	public static final EVENT_SELLALL_SUCCESS:String = "SellAllSuccess";

	// WarehouseModel.as:37
	public static final EVENT_SELLPLANT_SUCCESS:String = "SellPlantSuccess";

	// WarehouseModel.as:39
	public static final EVENT_SELLALLFISHS_SUCCESS:String = "SellAllFishsSuccess";

	// WarehouseModel.as:41
	public static final EVENT_SELLFISH_SUCCESS:String = "SellFishSuccess";

	// WarehouseModel.as:43
	public static final EVENT_SELLSEED_SUCCESS:String = "SellSeedSuccess";

	// WarehouseModel.as:45
	public static final EVENT_SELLALLSEEDS_SUCCESS:String = "SellAllSeedsSuccess";

	// WarehouseModel.as:47（常量名 SENTFlower、值 SellFlowerSuccess——原版拼写如此）
	public static final EVENT_SENDFLOWER_SUCCESS:String = "SellFlowerSuccess";

	// WarehouseModel.as:49
	public static final EVENT_UPDATELOCK_SUCCESS:String = "UpdateLockSuccess";

	// WarehouseModel.as:51
	public static final EVENT_UPDATEFISHLOCK_SUCCESS:String = "UpdateFishLockSuccess";

	// WarehouseModel.as:53
	private var m_fishDirty:Bool;

	// WarehouseModel.as:55
	private var m_allFlower:Array<Dynamic>;

	// WarehouseModel.as:57
	private var m_seedDirty:Bool;

	// WarehouseModel.as:59
	private var m_crops:Array<Dynamic>;

	// WarehouseModel.as:61
	private var m_cards:Array<Dynamic>;

	// WarehouseModel.as:63
	private var m_flowers:Array<Dynamic>;

	// WarehouseModel.as:65
	private var m_flowerPath:String;

	// WarehouseModel.as:67
	private var m_myFlower:Array<Dynamic>;

	// WarehouseModel.as:69
	private var m_fishs:Array<Dynamic>;

	// WarehouseModel.as:71
	private var m_crystalDirty:Bool;

	// WarehouseModel.as:73
	private var m_cropDirty:Bool;

	// WarehouseModel.as:75
	private var m_seeds:Array<Dynamic>;

	// WarehouseModel.as:77
	private var m_crystal:Array<Dynamic>;

	// WarehouseModel.as:79
	private var m_flowerDirty:Bool;

	// WarehouseModel.as:81
	private var m_sendFlowerID:Int;

	// WarehouseModel.as:83
	private var _tempCards:Array<Dynamic>;

	// WarehouseModel.as:85-103
	public function new(param1:IEventDispatcher = null) {
		super(param1);
		this.m_cropDirty = true;
		this.m_crystalDirty = true;
		this.m_seedDirty = true;
		this.m_flowerDirty = true;
		this.m_fishDirty = true;
		this.m_crops = null;
		this.m_flowers = null;
		this.m_seeds = null;
		this.m_cards = null;
		this.m_crystal = null;
		this.m_allFlower = null;
		this.m_myFlower = null;
		this.m_fishs = null;
		this.m_flowerPath = "";
		this.m_sendFlowerID = -1;
	}

	// WarehouseModel.as:105-167（三仓回写；_loc5_ 残留语义见类头 PORT-NOTE）
	private function onLockSuccess(param1:CommandEvent):Void {
		var _loc4_:Bool = false;
		var _loc5_:WarehouseCrop = null;
		var _loc6_:Dynamic = null;
		var _loc5In:Dynamic = null;
		if (param1 == null) {
			return;
		}
		var _loc2_:ServiceResultVO = Std.isOfType(param1.result, ServiceResultVO) ? cast(param1.result, ServiceResultVO) : null;
		if (_loc2_ == null) {
			return;
		}
		var _loc3_:Dynamic = _loc2_.m_extra;
		if (As3.eqString(Reflect.field(_loc3_, "code"), "1")) {
			_loc4_ = false;
			_loc5_ = null;
			var cropRows:Array<Dynamic> = Reflect.field(_loc3_, "crop");
			if (cropRows != null) {
				for (_loc6_ in cropRows) {
					_loc4_ = false;
					_loc5_ = null;
					if (this.m_crops != null) {
						for (_loc5In in this.m_crops) {
							_loc5_ = _loc5In;
							if (_loc5_._id == Reflect.field(_loc6_, "cId")) {
								_loc5_._isLock = As3.floatOf(Reflect.field(_loc6_, "isLock")) == 1 ? 1 : 0;
								_loc4_ = true;
								break;
							}
						}
					}
					if (_loc4_ == false) {
						if (this.m_flowers != null) {
							for (_loc5In in this.m_flowers) {
								_loc5_ = _loc5In;
								if (_loc5_._id == Reflect.field(_loc6_, "cId")) {
									_loc5_._isLock = As3.floatOf(Reflect.field(_loc6_, "isLock")) == 1 ? 1 : 0;
									_loc4_ = true;
									break;
								}
							}
						}
					}
					if (_loc4_ == false) {
						if (this.m_cards != null) {
							for (_loc5In in this.m_cards) {
								_loc5_ = _loc5In;
								if (_loc5_._id == Reflect.field(_loc6_, "cId")) {
									_loc5_._isLock = As3.floatOf(Reflect.field(_loc6_, "isLock")) == 1 ? 1 : 0;
									_loc4_ = true;
									break;
								}
							}
						}
					}
					if (_loc4_ == true) {
						dispatchEvent(new CommonEvent(EVENT_UPDATELOCK_SUCCESS, _loc5_));
					}
				}
			}
		}
		EventRecorder.recordSueecssEvent("160865", null);
	}

	// WarehouseModel.as:169-196（:193 派发用 _loc4_ 残留：非空未命中 → 尾元素，
	// 空表 → 初值 null——原版字面）
	private function onFishLockSuccess(param1:CommandEvent):Void {
		var _loc4_:WarehouseFish = null;
		var _loc4In:Dynamic = null;
		if (param1 == null) {
			return;
		}
		var _loc2_:ServiceResultVO = Std.isOfType(param1.result, ServiceResultVO) ? cast(param1.result, ServiceResultVO) : null;
		if (_loc2_ == null) {
			return;
		}
		var _loc3_:Dynamic = _loc2_.m_extra;
		if (As3.eqString(Reflect.field(_loc3_, "code"), "1")) {
			_loc4_ = null;
			if (this.m_fishs != null) {
				for (_loc4In in this.m_fishs) {
					_loc4_ = _loc4In;
					if (_loc4_._id == Reflect.field(_loc3_, "fid")) {
						_loc4_._isLock = As3.floatOf(Reflect.field(_loc3_, "lock")) == 1 ? 1 : 0;
						break;
					}
				}
			}
			dispatchEvent(new CommonEvent(EVENT_UPDATEFISHLOCK_SUCCESS, _loc4_));
		}
		EventRecorder.recordSueecssEvent("160866", null);
	}

	// WarehouseModel.as:198-201
	private function onFishLockFail(param1:CommandEvent):Void {
		EventRecorder.recordErrorEvent("160866", null, 4);
	}

	// WarehouseModel.as:203-220
	public function sendFlower(param1:String, param2:String, param3:Dynamic):Void {
		if (param1 == "") {
			return;
		}
		if (param3 == null || !As3.hasProp(param3, "fId")) {
			return;
		}
		var _loc4_:Dynamic = {
			"to": param1,
			"fId": Reflect.field(param3, "fId"),
			"w": param2
		};
		// AS3 隐式 int 强转（parseInt 回 Number）显式化
		this.m_sendFlowerID = As3.intOf(As3.parseInt(Reflect.field(param3, "fId")));
		NetHelper.sendRequest(CommandDefs.CMD_SEND_FLOWER, _loc4_, this.onFlowerSentSuccess, this.onTransactionFailed);
	}

	// WarehouseModel.as:222-233（水晶卖出复用 onSellPlantSuccess 应答链）
	public function sellCrystal(param1:Int, param2:Int):Void {
		if (param1 < 0 || param2 < 0) {
			return;
		}
		var _loc3_:Dynamic = {
			"id": param1,
			"num": param2
		};
		NetHelper.sendRequest(CommandDefs.CMD_SELL_CRYSTAL, _loc3_, this.onSellPlantSuccess, this.onTransactionFailed);
	}

	// WarehouseModel.as:235-238（get）与 :556-559（set）合成一对
	public var flowers(get, set):Array<Dynamic>;

	private function get_flowers():Array<Dynamic> {
		return this.m_flowers;
	}

	private function set_flowers(param1:Array<Dynamic>):Array<Dynamic> {
		this.m_flowers = param1;
		return param1;
	}

	// WarehouseModel.as:240-251
	private function onSellPlantSuccess(param1:CommandEvent):Void {
		var _loc2_:Dynamic = NetHelper.getVOData(param1);
		if (_loc2_ == null) {
			return;
		}
		// PORT-NOTE: 原版 `param1.body["__body"]["number"]` 在 body/__body 为
		// null 时抛 TypeError；Haxe Reflect.field(null) 得 null 不再抛（ShopModel
		// onInGamePreCheckSuccess 同口径），缺位时 num 写 null——真实链路 body
		// 恒为 buildRequest 形状，该差异仅原版会崩的缺位状态
		Reflect.setField(_loc2_, "num", Reflect.field(Reflect.field(param1.body, "__body"), "number"));
		dispatchEvent(new CommonEvent(EVENT_SELLPLANT_SUCCESS, _loc2_));
		dispatchEvent(new EvtAPI(EvtAPI.REFRESH_CRYSTAL));
		this.recordResp(EventRecorder.HF_SELL_PLANT, true, "mod=repertory&act=sale");
	}

	// WarehouseModel.as:253-279
	public function removeSeed(param1:Int, param2:Int = 1):Bool {
		var _loc4_:WarehouseSeed = null;
		var _loc4In:Dynamic = null;
		var _loc3_:Int = 0;
		if (this.m_seeds != null) {
			for (_loc4In in this.m_seeds) {
				_loc4_ = _loc4In;
				if (_loc4_._id == param1) {
					_loc4_._amount = As3.intSub(_loc4_._amount, param2);
					if (_loc4_._amount <= 0) {
						this.m_seeds.splice(_loc3_, 1);
						dispatchEvent(new CommonEvent(EVENT_DATA_CHANGED, {
							"index": 1,
							"data": this.m_seeds
						}));
						return true;
					}
					dispatchEvent(new CommonEvent(EVENT_DATA_CHANGED, {
						"index": 1,
						"data": this.m_seeds
					}));
				}
				_loc3_++;
			}
		}
		return false;
	}

	// WarehouseModel.as:281-331（:318 恒真门 `_loc3_ != 0 || _loc3_ != 1` 使
	// :322-330 重试文案成死分支；:313 的 body 键 "cmdId" 小写 d 与 buildRequest
	// 的 "cmdID" 不符——两处均照原版字面保留）
	private function onLoadDataError(param1:CommandEvent):Void {
		var _loc5_:String = null;
		if (param1 == null) {
			return;
		}
		var _loc2_:ServiceResultVO = Std.isOfType(param1.result, ServiceResultVO) ? cast(param1.result, ServiceResultVO) : null;
		if (_loc2_ == null) {
			return;
		}
		var _loc3_:Int = -1;
		if (param1.body != null && As3.hasProp(param1.body, "cmdID")) {
			if (As3.intOf(Reflect.field(param1.body, "cmdID")) == CommandDefs.CMD_GET_WAREHOUSE_CROPS) {
				_loc3_ = 0;
				QzoneJSAPI.reportError("仓库作物加载失败", 2);
				this.recordResp(EventRecorder.HF_GET_WAREHOUSE_CROPS, false, "cgi_farm_getusercrop?f=1");
			} else if (As3.intOf(Reflect.field(param1.body, "cmdID")) == CommandDefs.CMD_GET_WAREHOUSE_SEEDS) {
				_loc3_ = 1;
				QzoneJSAPI.reportError("仓库种子加载失败", 2);
				this.recordResp(EventRecorder.HF_GET_WAREHOUSE_SEEDS, false, "cgi_farm_seed_list");
			} else if (As3.intOf(Reflect.field(param1.body, "cmdID")) == CommandDefs.CMD_GET_WAREHOUSE_CRYSTAL) {
				QzoneJSAPI.reportError("仓库材料加载失败", 2);
				this.recordResp(EventRecorder.HF_GET_WAREHOUSE_CRYSTAL, false, "cgi_farm_get_usercrystal");
			} else if (As3.intOf(Reflect.field(param1.body, "cmdId")) == CommandDefs.CMD_GET_WAREHOUSE_MYFLOWERS) {
				EventRecorder.recordErrorEvent("160867", null, 4);
			}
		}
		if (_loc3_ != 0 || _loc3_ != 1) {
			return;
		}
		var _loc4_:String = Std.isOfType(Reflect.field(_loc2_.m_extra, "errorType"), String) ? cast(Reflect.field(_loc2_.m_extra, "errorType"), String) : null;
		if (_loc4_ != "") {
			_loc5_ = Reflect.field(Language.L, "请求超时，") + "<a href='event:reload'><u><font color='#ff6600'>" + Reflect.field(Language.L, "点击重试") + "</font></u></a>";
			dispatchEvent(new CommonEvent(EVENT_DATA_FAILED, {
				"index": _loc3_,
				"error": _loc5_
			}));
		}
	}

	// WarehouseModel.as:333-336
	public var fishs(get, never):Array<Dynamic>;

	private function get_fishs():Array<Dynamic> {
		return this.m_fishs;
	}

	// WarehouseModel.as:338-346
	public function storeUserCropLockInfo(param1:WarehouseCrop, param2:Bool):Void {
		if (param1 == null || param1._isLock == -1) {
			return;
		}
		var _loc3_:String = param1._id + ":" + (param2 ? "1" : "2");
		NetHelper.sendRequest(CommandDefs.CMD_UPDATE_LOCK, {"crop": _loc3_}, this.onLockSuccess, this.onLockFail);
	}

	// WarehouseModel.as:348-358
	public function loadCrops():Void {
		if (this.m_cropDirty == true) {
			dispatchEvent(new CommonEvent(EVENT_DATA_LOADING, {
				"index": 0,
				"show": true
			}));
			NetHelper.sendRequest(CommandDefs.CMD_GET_WAREHOUSE_CROPS, null, this.onCropsLoaded, this.onLoadDataError);
		}
	}

	// WarehouseModel.as:360-382（无 VO null 守卫照原样；getVOData null 时
	// 原版在下语句抛 TypeError，Haxe 同点报错中断）
	private function onCrystalsLoaded(param1:CommandEvent):Void {
		var _loc3_:WarehouseCrop = null;
		var _loc4_:Dynamic = null;
		var _loc2_:Dynamic = NetHelper.getVOData(param1);
		WildData.reloadCrystal = false;
		this.m_crystal = [];
		for (_loc4_ in (Reflect.field(_loc2_, "info") : Array<Dynamic>)) {
			_loc3_ = new WarehouseCrop(_loc4_);
			this.m_crystal.push(_loc3_);
		}
		if (!As3.truthy(this._tempCards)) {
			this._tempCards = [];
		}
		this.m_cards = this._tempCards.concat(this.m_crystal);
		dispatchEvent(new CommonEvent(EVENT_DATA_CHANGED, {
			"index": 3,
			"show": true
		}));
		this.recordResp(EventRecorder.HF_GET_WAREHOUSE_CRYSTAL, true, "cgi_farm_get_usercrystal");
	}

	// WarehouseModel.as:384-430
	public function collectNotLockedIDs(param1:Int):Array<Dynamic> {
		var _loc3_:WarehouseCrop = null;
		var _loc4_:WarehouseFish = null;
		var _loc2_:Array<Dynamic> = [];
		if (param1 == Consts.WAREHOUSE_CROP) {
			if (this.m_crops != null) {
				for (_loc3_ in this.m_crops) {
					if (_loc3_._id > 0 && _loc3_._isLock <= 0) {
						_loc2_.push(_loc3_._id);
					}
				}
			}
		} else if (param1 == Consts.WAREHOUSE_FLOWER) {
			if (this.m_flowers != null) {
				for (_loc3_ in this.m_flowers) {
					if (_loc3_._id > 0 && _loc3_._isLock <= 0) {
						_loc2_.push(_loc3_._id);
					}
				}
			}
		} else if (param1 == Consts.WAREHOUSE_FISH) {
			if (this.m_fishs != null) {
				for (_loc4_ in this.m_fishs) {
					if (_loc4_._id > 0 && _loc4_._isLock <= 0) {
						_loc2_.push(_loc4_._id);
					}
				}
			}
		} else {
			if (this.m_cards != null) {
				for (_loc3_ in this.m_cards) {
					if (_loc3_._id > 0 && _loc3_._isLock <= 0) {
						_loc2_.push(_loc3_._id);
					}
				}
			}
		}
		return _loc2_;
	}

	// WarehouseModel.as:432-468
	private function onFishsLoaded(param1:CommandEvent):Void {
		var _loc4_:WarehouseFish = null;
		var _loc4In:Dynamic = null;
		var _loc2_:Dynamic = NetHelper.getVOData(param1);
		if (_loc2_ == null) {
			return;
		}
		this.m_fishDirty = false;
		dispatchEvent(new CommonEvent(EVENT_DATA_LOADING, {
			"index": 5,
			"show": false
		}));
		if (this.m_fishs == null) {
			this.m_fishs = new Array<Dynamic>();
		} else {
			this.m_fishs.splice(0, this.m_fishs.length);
		}
		this.m_fishs = this.m_fishs.concat(_loc2_);
		var _loc3_:Dynamic = null;
		for (_loc4In in this.m_fishs) {
			_loc4_ = _loc4In;
			_loc3_ = Settings.getInstance().getFishByID(Std.string(_loc4_._id));
			if (_loc3_ != null) {
				_loc4_._name = Reflect.field(_loc3_, "crop_name");
				_loc4_._sale = As3.intOf(Reflect.field(_loc3_, "sale"));
			}
		}
		dispatchEvent(new CommonEvent(EVENT_DATA_CHANGED, {
			"index": 5,
			"data": this.m_fishs
		}));
	}

	// WarehouseModel.as:470-508
	private function onTransactionFailed(param1:CommandEvent):Void {
		var _loc2_:ServiceResultVO = Std.isOfType(param1.result, ServiceResultVO) ? cast(param1.result, ServiceResultVO) : null;
		if (_loc2_ == null || _loc2_.m_message == "") {
			dispatchEvent(new CommonEvent(EVENT_NET_TRANSACTION_ERROR, {"error": Reflect.field(Language.L, "请求超时，稍后再试")}));
		} else {
			dispatchEvent(new CommonEvent(EVENT_NET_TRANSACTION_ERROR, {"error": _loc2_.m_message}));
		}
		if (param1.body != null && As3.hasProp(param1.body, "cmdID")) {
			if (As3.intOf(Reflect.field(param1.body, "cmdID")) == CommandDefs.CMD_SELL_ALL_PLANTS) {
				this.recordResp(EventRecorder.HF_SELL_ALL_PLANTS, false, "mod=repertory&act=saleAll");
			} else if (As3.intOf(Reflect.field(param1.body, "cmdID")) == CommandDefs.CMD_SELL_PLANT) {
				this.recordResp(EventRecorder.HF_SELL_PLANT, false, "mod=repertory&act=sale");
			} else if (As3.intOf(Reflect.field(param1.body, "cmdID")) == CommandDefs.CMD_SEND_FLOWER) {
				EventRecorder.recordErrorEvent("160868", null, 4);
			} else if (As3.intOf(Reflect.field(param1.body, "cmdID")) == CommandDefs.CMD_SELL_ALL_SEEDS) {
				EventRecorder.recordErrorEvent("160869", null, 4);
			} else if (As3.intOf(Reflect.field(param1.body, "cmdID")) == CommandDefs.CMD_SELL_WAREHOUSE_FISH) {
				EventRecorder.recordErrorEvent("160870", null, 4);
			} else if (As3.intOf(Reflect.field(param1.body, "cmdID")) == CommandDefs.CMD_SELL_SEED) {
				EventRecorder.recordErrorEvent("160871", null, 4);
			}
		}
	}

	// WarehouseModel.as:510-513
	public var myFlowers(get, never):Array<Dynamic>;

	private function get_myFlowers():Array<Dynamic> {
		return this.m_myFlower;
	}

	// WarehouseModel.as:515-522（原版参数 *：调用方传 WarehouseCrop/WarehouseSeed）
	private function sort(param1:Dynamic, param2:Dynamic):Int {
		if (Reflect.field(param1, "_lvl") == Reflect.field(param2, "_lvl")) {
			return Reflect.field(param1, "_id") >= Reflect.field(param2, "_id") ? 1 : -1;
		}
		return Reflect.field(param1, "_lvl") >= Reflect.field(param2, "_lvl") ? 1 : -1;
	}

	// WarehouseModel.as:524-527
	private function onLockFail(param1:CommandEvent):Void {
		EventRecorder.recordErrorEvent("160865", null, 4);
	}

	// WarehouseModel.as:529-532
	public var flowerPath(get, never):String;

	private function get_flowerPath():String {
		return this.m_flowerPath;
	}

	// WarehouseModel.as:534-549
	private function onSellAllSeedsSuccess(param1:CommandEvent):Void {
		var _loc3_:String = null;
		var _loc2_:Dynamic = NetHelper.getVOData(param1);
		if (_loc2_ == null) {
			return;
		}
		if (As3.floatOf(Reflect.field(_loc2_, "code")) == 1) {
			_loc3_ = Language.replaceText("saleAllFnText2", {"money": Reflect.field(_loc2_, "money")});
			Reflect.setField(_loc2_, "direction", _loc3_);
			dispatchEvent(new CommonEvent(EVENT_SELLALLSEEDS_SUCCESS, _loc2_));
			EventRecorder.recordSueecssEvent("160869", null);
		}
	}

	// WarehouseModel.as:551-554（set）与 :784-787（get）合成一对
	public var fishDirty(get, set):Bool;

	private function get_fishDirty():Bool {
		return this.m_fishDirty;
	}

	private function set_fishDirty(param1:Bool):Bool {
		this.m_fishDirty = param1;
		return param1;
	}

	// WarehouseModel.as:561-574
	public function sellPlant(param1:Int, param2:Int):Void {
		if (param1 < 0 || param2 < 0) {
			return;
		}
		var _loc3_:Dynamic = {
			"cId": param1,
			"number": param2,
			"hw": 1
		};
		Reflect.setField(_loc3_, "onlineTime", QzoneJSAPI.getOnlineTime(Settings.getInstance().mode));
		NetHelper.sendRequest(CommandDefs.CMD_SELL_PLANT, _loc3_, this.onSellPlantSuccess, this.onTransactionFailed);
	}

	// WarehouseModel.as:576-579（get）与 :626-629（set）合成一对
	public var cropDirty(get, set):Bool;

	private function get_cropDirty():Bool {
		return this.m_cropDirty;
	}

	private function set_cropDirty(param1:Bool):Bool {
		this.m_cropDirty = param1;
		return param1;
	}

	// WarehouseModel.as:581-592
	private function getFlowerCount(param1:Int):Int {
		var _loc2_:WarehouseCrop = null;
		if (this.m_flowers != null) {
			for (_loc2_ in this.m_flowers) {
				if (_loc2_._id == param1) {
					return _loc2_._amount;
				}
			}
		}
		return 0;
	}

	// WarehouseModel.as:594-606
	private function onSellSeedSuccess(param1:CommandEvent):Void {
		var _loc2_:Dynamic = NetHelper.getVOData(param1);
		if (_loc2_ == null) {
			return;
		}
		if (As3.floatOf(Reflect.field(_loc2_, "code")) == 1) {
			dispatchEvent(new CommonEvent(EVENT_SELLSEED_SUCCESS, _loc2_));
			EventRecorder.recordSueecssEvent("160871", null);
		}
	}

	// WarehouseModel.as:608-611（set）与 :828-831（get）合成一对
	public var seedDirty(get, set):Bool;

	private function get_seedDirty():Bool {
		return this.m_seedDirty;
	}

	private function set_seedDirty(param1:Bool):Bool {
		this.m_seedDirty = param1;
		return param1;
	}

	// WarehouseModel.as:613-624
	public function isEmpty(param1:Int):Bool {
		if (param1 == 0 || param1 == 1) {
			return this.m_crops == null || this.m_crops.length == 0 ? true : false;
		}
		if (param1 == 2) {
			return this.m_seeds == null || this.m_seeds.length == 0 ? true : false;
		}
		return this.m_cards == null || this.m_cards.length == 0 ? true : false;
	}

	// WarehouseModel.as:631-652（:648 派发在循环外无守卫——未命中也派发）
	public function removeMyFlower(param1:Dynamic):Void {
		var _loc3_:Dynamic = null;
		if (param1 == null || !As3.hasProp(param1, "fId")) {
			return;
		}
		var _loc2_:Int = 0;
		if (this.m_myFlower != null) {
			for (_loc3_ in this.m_myFlower) {
				if (Reflect.field(_loc3_, "fId") == Reflect.field(param1, "fId")) {
					this.m_myFlower.splice(_loc2_, 1);
					break;
				}
				_loc2_++;
			}
		}
		dispatchEvent(new CommonEvent(EVENT_DATA_CHANGED, {
			"index": 2,
			"data": this.m_myFlower
		}));
	}

	// WarehouseModel.as:654-657
	public var seeds(get, never):Array<Dynamic>;

	private function get_seeds():Array<Dynamic> {
		return this.m_seeds;
	}

	// WarehouseModel.as:659-668
	public function sellFish(param1:Int, param2:Int):Void {
		var _loc3_:String = Session.getInstance().hostId;
		var _loc4_:Dynamic = {
			"fIds": param1,
			"num": param2,
			"flag": "single"
		};
		NetHelper.sendRequest(CommandDefs.CMD_SELL_WAREHOUSE_FISH, _loc4_, this.onSellFishSuccess, this.onTransactionFailed);
	}

	// WarehouseModel.as:670-696（else-if 链：errorType 有键不在表内时后两分支
	// 不可达——原版字面）
	private function onSellAllSuccess(param1:CommandEvent):Void {
		var _loc3_:String = null;
		var _loc2_:Dynamic = NetHelper.getVOData(param1);
		if (_loc2_ == null) {
			return;
		}
		if (As3.hasProp(_loc2_, "errorType")) {
			_loc3_ = Reflect.field(_loc2_, "errorType");
			if (_loc3_ == "IOError" || _loc3_ == "httpStatus" || _loc3_ == "timeOut" || _loc3_ == "PHPError") {
				dispatchEvent(new CommonEvent(EVENT_NET_TRANSACTION_ERROR, {"error": Reflect.field(Language.L, "请求超时，稍后再试")}));
				return;
			}
		} else if (As3.floatOf(Reflect.field(_loc2_, "code")) == 1) {
			dispatchEvent(new CommonEvent(EVENT_SELLALL_SUCCESS, _loc2_));
			this.recordResp(EventRecorder.HF_SELL_ALL_PLANTS, true, "mod=repertory&act=saleAll");
		} else if (As3.hasProp(_loc2_, "direction") && Reflect.field(_loc2_, "direction") != "") {
			dispatchEvent(new CommonEvent(EVENT_NET_TRANSACTION_ERROR, {"error": Reflect.field(_loc2_, "direction")}));
		}
	}

	// WarehouseModel.as:698-708
	public function loadFishs():Void {
		if (this.m_fishDirty == true) {
			dispatchEvent(new CommonEvent(EVENT_DATA_LOADING, {
				"index": 5,
				"show": true
			}));
			NetHelper.sendRequest(CommandDefs.CMD_GET_WAREHOUSE_FISH, null, this.onFishsLoaded, this.onLoadDataError);
		}
	}

	// WarehouseModel.as:710-762
	private function onFlowerSentSuccess(param1:CommandEvent):Void {
		var _loc3_:Dynamic = null;
		var _loc4_:Dynamic = null;
		var _loc5_:UInt = 0;
		var _loc6_:Dynamic = null;
		var _loc7_:Int = 0;
		var _loc8_:WarehouseCrop = null;
		var _loc2_:Dynamic = NetHelper.getVOData(param1);
		if (_loc2_ == null) {
			return;
		}
		if (As3.floatOf(Reflect.field(_loc2_, "code")) == 1) {
			_loc3_ = null;
			if (this.m_allFlower != null) {
				for (_loc4_ in this.m_allFlower) {
					if (Reflect.field(_loc4_, "fId") == this.m_sendFlowerID) {
						_loc3_ = _loc4_;
						break;
					}
				}
			}
			if (_loc3_ != null) {
				_loc5_ = this.m_flowers.length;
				for (_loc6_ in (Reflect.field(_loc3_, "need") : Array<Dynamic>)) {
					_loc7_ = 0;
					while (_loc7_ < _loc5_) {
						_loc8_ = this.m_flowers[_loc7_];
						if (_loc8_._id == Reflect.field(_loc6_, "cId")) {
							// AS3 `int -= parseInt(amount)` 的隐式 int 强转显式化
							_loc8_._amount = As3.intSub(_loc8_._amount, As3.parseInt(Reflect.field(_loc6_, "amount")));
							if (_loc8_._amount <= 0) {
								this.m_flowers.splice(_loc7_, 1);
							}
							break;
						}
						_loc7_++;
					}
				}
				dispatchEvent(new CommonEvent(EVENT_SENDFLOWER_SUCCESS, {
					"msg": Reflect.field(_loc2_, "direction"),
					"data": this.m_flowers
				}));
			}
			EventRecorder.recordSueecssEvent("160868", null);
		}
	}

	// WarehouseModel.as:764-782
	private function recordResp(param1:String, param2:Bool, param3:String, param4:Int = 0):Void {
		if (param1 == "") {
			return;
		}
		if (param2 == true) {
			EventRecorder.recordSueecssEvent(param1, null, param3);
		} else if (param4 == 0) {
			EventRecorder.recordErrorEvent(param1, null, EventRecorder.FAULT_ERROR, param3);
		} else {
			EventRecorder.recordErrorEvent(param1, null, param4, param3);
		}
	}

	// WarehouseModel.as:789-801
	private function onSellAllFishSuccess(param1:CommandEvent):Void {
		var _loc2_:Dynamic = NetHelper.getVOData(param1);
		if (_loc2_ == null) {
			return;
		}
		if (As3.floatOf(Reflect.field(_loc2_, "code")) == 1) {
			dispatchEvent(new CommonEvent(EVENT_SELLALLFISHS_SUCCESS, _loc2_));
			EventRecorder.recordSueecssEvent("160870", null);
		}
	}

	// WarehouseModel.as:803-813
	public function loadSeeds():Void {
		if (this.m_seedDirty == true) {
			dispatchEvent(new CommonEvent(EVENT_DATA_LOADING, {
				"index": 1,
				"show": true
			}));
			NetHelper.sendRequest(CommandDefs.CMD_GET_WAREHOUSE_SEEDS, null, this.onSeedsLoaded, this.onLoadDataError);
		}
	}

	// WarehouseModel.as:815-826
	public function storeUserFishLockInfo(param1:WarehouseFish, param2:Bool):Void {
		if (param1 == null || param1._isLock == -1) {
			return;
		}
		var _loc3_:String = param2 ? "lock" : "unlock";
		NetHelper.sendRequest(CommandDefs.CMD_UPDATE_FISH_LOCK, {
			"fId": param1._id,
			"flag": _loc3_
		}, this.onFishLockSuccess, this.onFishLockFail);
	}

	// WarehouseModel.as:833-845
	public function sellSeed(param1:Int, param2:Int):Void {
		if (param1 < 0 || param2 < 0) {
			return;
		}
		var _loc3_:Dynamic = {
			"cId": param1,
			"number": param2
		};
		Reflect.setField(_loc3_, "onlineTime", QzoneJSAPI.getOnlineTime(Settings.getInstance().mode));
		NetHelper.sendRequest(CommandDefs.CMD_SELL_SEED, _loc3_, this.onSellSeedSuccess, this.onTransactionFailed);
	}

	// WarehouseModel.as:847-857
	public function loadMyFlowers():Void {
		if (this.m_flowerDirty == true) {
			dispatchEvent(new CommonEvent(EVENT_DATA_LOADING, {
				"index": 2,
				"show": true
			}));
			NetHelper.sendRequest(CommandDefs.CMD_GET_WAREHOUSE_MYFLOWERS, null, this.onMyFlowersLoaded, this.onLoadDataError);
		}
	}

	// WarehouseModel.as:859-869
	public function sellAllFish(param1:Int):Void {
		var _loc2_:String = Session.getInstance().hostId;
		var _loc3_:Array<Dynamic> = this.collectNotLockedIDs(param1);
		if (_loc3_ == null || _loc3_.length == 0) {
			return;
		}
		var _loc4_:Dynamic = {"fIds": _loc3_.join(",")};
		NetHelper.sendRequest(CommandDefs.CMD_SELL_WAREHOUSE_FISH, _loc4_, this.onSellAllFishSuccess, this.onTransactionFailed);
	}

	// WarehouseModel.as:871-911
	private function onSeedsLoaded(param1:CommandEvent):Void {
		var _loc4_:WarehouseSeed = null;
		var _loc4In:Dynamic = null;
		var _loc2_:Dynamic = NetHelper.getVOData(param1);
		if (_loc2_ == null) {
			return;
		}
		this.m_seedDirty = false;
		dispatchEvent(new CommonEvent(EVENT_DATA_LOADING, {
			"index": 1,
			"show": false
		}));
		if (this.m_seeds == null) {
			this.m_seeds = new Array<Dynamic>();
		} else {
			this.m_seeds.splice(0, this.m_seeds.length);
		}
		this.m_seeds = this.m_seeds.concat(_loc2_);
		this.m_seeds.sort(this.sort);
		var _loc3_:Dynamic = null;
		for (_loc4In in this.m_seeds) {
			_loc4_ = _loc4In;
			_loc3_ = Settings.getInstance().getCropByID(Std.string(_loc4_._id));
			if (_loc3_ != null) {
				if (_loc4_._isVip == -1 && As3.hasProp(_loc3_, "isVIP")) {
					_loc4_._isVip = As3.floatOf(Reflect.field(_loc3_, "isVIP")) == 1 ? 1 : 0;
				}
			}
		}
		dispatchEvent(new CommonEvent(EVENT_DATA_CHANGED, {
			"index": 1,
			"data": this.m_seeds
		}));
		this.recordResp(EventRecorder.HF_GET_WAREHOUSE_SEEDS, true, "cgi_farm_seed_list");
	}

	// WarehouseModel.as:913-983（原版 public，非私有）
	public function onCropsLoaded(param1:CommandEvent):Void {
		var _loc8_:WarehouseCrop = null;
		var _loc8In:Dynamic = null;
		var _loc2_:Dynamic = NetHelper.getVOData(param1);
		if (_loc2_ == null) {
			return;
		}
		this.m_cropDirty = false;
		dispatchEvent(new CommonEvent(EVENT_DATA_LOADING, {
			"index": 0,
			"show": false
		}));
		if (As3.hasProp(_loc2_, "flowerPath")) {
			this.m_flowerPath = Reflect.field(_loc2_, "flowerPath");
		}
		var _loc3_:Array<Dynamic> = new Array<Dynamic>();
		if (As3.hasProp(_loc2_, "crops")) {
			_loc3_ = _loc3_.concat(Reflect.field(_loc2_, "crops"));
		}
		var _loc4_:Array<Dynamic> = null;
		var _loc5_:String = Settings.getInstance().getStringAttribute("crops_sort");
		if (_loc5_ != "") {
			_loc4_ = _loc5_.split(",");
		}
		var _loc6_:Dynamic = null;
		var _loc7_:IPluginProxy = PluginManager.getInstance().getPluginByID(3);
		for (_loc8In in _loc3_) {
			_loc8_ = _loc8In;
			if (_loc4_ != null) {
				_loc8_._sort = _loc4_.indexOf(Std.string(_loc8_._id));
			}
			_loc6_ = Settings.getInstance().getCropByID(Std.string(_loc8_._id));
			if (_loc6_ != null) {
				if (_loc8_._isFlower == -1 && As3.hasProp(_loc6_, "isFlower")) {
					_loc8_._isFlower = As3.floatOf(Reflect.field(_loc6_, "isFlower")) == 1 ? 1 : 0;
				}
				if (_loc8_._isLock <= 0 && As3.hasProp(_loc6_, "isLock")) {
					_loc8_._isLock = As3.floatOf(Reflect.field(_loc6_, "isLock")) == 1 ? 1 : 0;
				}
				if (_loc8_._isLock == 2) {
					_loc8_._isLock = 0;
				}
				if (_loc8_._isFood == -1 && As3.hasProp(_loc6_, "isFood")) {
					_loc8_._isFood = As3.floatOf(Reflect.field(_loc6_, "isFood")) == 1 ? 1 : 0;
				}
				if (_loc8_._isVip == -1 && As3.hasProp(_loc6_, "isVIP")) {
					_loc8_._isVip = As3.floatOf(Reflect.field(_loc6_, "isVIP")) == 1 ? 1 : 0;
				}
			}
			if (_loc7_ != null) {
				_loc7_.executeCommand(2002, _loc8_);
			}
		}
		_loc3_.sort(this.sort);
		this.seperateFlowers(_loc3_);
		this.processAllFlowers(_loc2_);
		dispatchEvent(new CommonEvent(EVENT_DATA_CHANGED, {"index": 0}));
		this.recordResp(EventRecorder.HF_GET_WAREHOUSE_CROPS, true, "cgi_farm_getusercrop?f=1");
	}

	// WarehouseModel.as:985-988
	public var crops(get, never):Array<Dynamic>;

	private function get_crops():Array<Dynamic> {
		return this.m_crops;
	}

	// WarehouseModel.as:990-1022
	private function processAllFlowers(param1:Dynamic):Void {
		var _loc3_:Dynamic = null;
		var _loc4_:Int = 0;
		var _loc5_:Dynamic = null;
		var _loc6_:Int = 0;
		var _loc7_:Int = 0;
		if (param1 == null || !As3.hasProp(param1, "allFlower") || !As3.hasProp(param1, "flowerPath")) {
			return;
		}
		var _loc2_:String = Std.isOfType(Reflect.field(param1, "flowerPath"), String) ? cast(Reflect.field(param1, "flowerPath"), String) : null;
		if (_loc2_ == "") {
			return;
		}
		for (_loc3_ in (Reflect.field(param1, "allFlower") : Array<Dynamic>)) {
			_loc4_ = 0;
			for (_loc5_ in (Reflect.field(_loc3_, "need") : Array<Dynamic>)) {
				// PORT-NOTE: 原版把 cId 的 * 值隐式强转 String 后传参
				// （allflower.php 的 need 行 cId 恒为数值字面量）；Std.string
				// 显式化同一强转
				Reflect.setField(_loc5_, "cName", GetCropID.getNameByIDType(Consts.ITEM_TYPE_SEED, Std.string(Reflect.field(_loc5_, "cId"))));
				_loc6_ = this.getFlowerCount(As3.intOf(Reflect.field(_loc5_, "cId")));
				_loc7_ = _loc6_ >= As3.floatOf(Reflect.field(_loc5_, "amount")) ? 0 : As3.intSub(Reflect.field(_loc5_, "amount"), _loc6_);
				Reflect.setField(_loc5_, "lack", _loc7_);
				_loc4_ += _loc7_;
			}
			Reflect.setField(_loc3_, "pic", _loc2_ + "/" + Reflect.field(_loc3_, "fId") + ".gif");
			Reflect.setField(_loc3_, "swf", _loc2_ + "/" + Reflect.field(_loc3_, "fId") + ".swf");
			Reflect.setField(_loc3_, "canMake", _loc4_ == 0);
		}
		this.m_allFlower = Reflect.field(param1, "allFlower");
	}

	// WarehouseModel.as:1024-1039
	public function sellAll(param1:Int):Void {
		var _loc2_:String = Session.getInstance().hostId;
		var _loc3_:Array<Dynamic> = this.collectNotLockedIDs(param1);
		if (_loc3_ == null || _loc3_.length == 0) {
			return;
		}
		var _loc4_:Dynamic = {
			"uId": _loc2_,
			"cIds": _loc3_.join(","),
			"hw": 1,
			"onlineTime": QzoneJSAPI.getOnlineTime(Settings.getInstance().mode)
		};
		NetHelper.sendRequest(CommandDefs.CMD_SELL_ALL_PLANTS, _loc4_, this.onSellAllSuccess, this.onTransactionFailed);
	}

	// WarehouseModel.as:1041-1052
	public function sellAllSeeds():Void {
		var _loc2_:WarehouseSeed = null;
		var _loc3_:Dynamic = null;
		var _loc1_:Array<Dynamic> = [];
		if (this.m_seeds != null) {
			for (_loc2_ in this.m_seeds) {
				_loc1_.push(_loc2_._id);
			}
		}
		_loc3_ = {"cIds": _loc1_.join(",")};
		NetHelper.sendRequest(CommandDefs.CMD_SELL_ALL_SEEDS, _loc3_, this.onSellAllSeedsSuccess, this.onTransactionFailed);
	}

	// WarehouseModel.as:1054-1057
	public var allFlower(get, never):Array<Dynamic>;

	private function get_allFlower():Array<Dynamic> {
		return this.m_allFlower;
	}

	// WarehouseModel.as:1059-1069
	public function loadCrystal():Void {
		if (this.m_crystalDirty == true) {
			dispatchEvent(new CommonEvent(EVENT_DATA_LOADING, {
				"index": 3,
				"show": true
			}));
			NetHelper.sendRequest(CommandDefs.CMD_GET_WAREHOUSE_CRYSTAL, {"type": 9}, this.onCrystalsLoaded, this.onLoadDataError);
		}
	}

	// WarehouseModel.as:1071-1106
	private function onMyFlowersLoaded(param1:CommandEvent):Void {
		var _loc3_:Dynamic = null;
		var _loc2_:Dynamic = NetHelper.getVOData(param1);
		if (_loc2_ == null) {
			return;
		}
		this.m_flowerDirty = false;
		dispatchEvent(new CommonEvent(EVENT_DATA_LOADING, {
			"index": 2,
			"show": false
		}));
		if (!As3.hasProp(_loc2_, "myFlower") || !As3.hasProp(_loc2_, "flowerPath")) {
			return;
		}
		if (this.m_myFlower == null) {
			this.m_myFlower = new Array<Dynamic>();
		} else {
			this.m_myFlower.splice(0, this.m_myFlower.length);
		}
		this.m_myFlower = this.m_myFlower.concat(Reflect.field(_loc2_, "myFlower"));
		for (_loc3_ in this.m_myFlower) {
			Reflect.setField(_loc3_, "pic", Reflect.field(_loc2_, "flowerPath") + "/" + Reflect.field(_loc3_, "fId") + ".gif");
		}
		dispatchEvent(new CommonEvent(EVENT_DATA_CHANGED, {
			"index": 2,
			"data": this.m_myFlower
		}));
		EventRecorder.recordSueecssEvent("160867", null);
	}

	// WarehouseModel.as:1108-1120
	private function onSellFishSuccess(param1:CommandEvent):Void {
		var _loc2_:Dynamic = NetHelper.getVOData(param1);
		if (_loc2_ == null) {
			return;
		}
		if (As3.floatOf(Reflect.field(_loc2_, "code")) == 1) {
			dispatchEvent(new CommonEvent(EVENT_SELLFISH_SUCCESS, _loc2_));
			EventRecorder.recordSueecssEvent("160870", null);
		}
	}

	// WarehouseModel.as:1122-1125
	public var cards(get, never):Array<Dynamic>;

	private function get_cards():Array<Dynamic> {
		return this.m_cards;
	}

	// WarehouseModel.as:1127-1165（filter 回调原版签 (item,index,array)，多余
	// 形参是 AS3 Array.filter 约定产物，Haxe filter 只传元素——体不引用后两者）
	private function seperateFlowers(param1:Array<Dynamic>):Void {
		var isFlower:WarehouseCrop->Bool = null;
		var isCrop:WarehouseCrop->Bool = null;
		var isCard:WarehouseCrop->Bool = null;
		var arr:Array<Dynamic> = param1;
		isFlower = function(param1:WarehouseCrop):Bool {
			return param1._isFlower == 1;
		};
		isCrop = function(param1:WarehouseCrop):Bool {
			return param1._isFlower <= 0 && param1._type != 11;
		};
		isCard = function(param1:WarehouseCrop):Bool {
			return param1._type == 11;
		};
		if (arr == null) {
			return;
		}
		if (arr.length == 0) {
			this.m_flowers = [];
			this.m_crops = [];
			this.m_cards = [];
			return;
		}
		this.m_flowers = arr.filter(isFlower);
		this.m_crops = arr.filter(isCrop);
		this.m_cards = arr.filter(isCard);
		this._tempCards = this.m_cards;
		if (!As3.truthy(this.m_crystal)) {
			this.m_crystal = [];
		}
		this.m_cards = this._tempCards.concat(this.m_crystal);
	}
}
