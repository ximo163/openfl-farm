package module.shop;

import com.qzone.qfa.events.CommandEvent;
import common.Consts;
import common.Language;
import common.Session;
import common.Settings;
import common.misc.QzoneJSAPI;
import entities.Seed;
import entities.ShopFish;
import events.CommonEvent;
import framework.net.CommandDefs;
import framework.net.NetHelper;
import openfl.events.EventDispatcher;
import openfl.events.IEventDispatcher;
import openfl.net.URLLoader;
import openfl.net.URLRequest;
import openfl.net.URLRequestMethod;
import openfl.net.URLVariables;
import report.EventRecorder;
import shim.As3;
import shim.QQOutlets;

/**
 * module.shop.ShopModel —— ShopModel.as 逐句对应（issue #35 功能 swf 翻译：
 * 商店）。商店六页签的数据装载与买入：种子/道具/装饰列表（mod=usertool&act=
 * getSeedInfo / getTools、mod=item&act=shop，ServerServices 33/34/35）、鱼苗
 * （cgi_fish_list 61、cgi_fish_buy 107、cgi_fish_unlock 63）、买入（repertory
 * buySeed 94 / usertool buyTool 95 / cgi_farm_buyweapon 151 / cgi_farm_buyitem
 * 98 / cgi_farm_tool_vip 106）、元宝支付预检（cgi_farm_shop_pay 105）、广告
 * 双网关（view_fcg getRequest：广告位 posid=72339074132595919、合作专区
 * posid=144396668170523855）与合作专区种子 cookie（c.gdt.qq.com/
 * gdt_cookie.fcg → isAdSeed 回购）。
 *
 * PORT-NOTE: flash.net.sendToURL 无 openfl 顶层等价 → QQOutlets.sendToURL
 * （不发送，见 shim）；ExternalInterface.call("eval") 仅 html5 可用 →
 * QQOutlets.call 同处收口。`x[k]`/`x[k]=v` 动态读写 → Reflect.field/
 * setField；`hasOwnProperty`/`!= undefined` 键判 → As3.hasProp；与字面量的
 * 松等（String 一侧）→ As3.eqString、Number 一侧直比（WelcomeModel 先例）；
 * Int 字段收 Number/数字字符串 → As3.intOf（隐式 int 强转显式化，"10000"
 * →10000 走 ShopFish.as:28）；`splice(0)` → `splice(0, length)`。onGetDecorsInfo
 * 四元块换位的越界读写经 As3.arrAt/arrPut 复刻 AS3 数组语义（原版尾部垫长
 * 缺陷照留）。onInGamePreCheckSuccess 无 VO null 守卫照原样（AS3 原生
 * TypeError 路径，Reflect.field(null) 得 null 不再抛，测试注明不钉）。
 */
class ShopModel extends EventDispatcher {
	// ShopModel.as:27（AS3 internal static const → public：Haxe 无包可见性，
	// 同包 ShopController/ShopView 要引用；纯常量、值不变，无行为面放大）
	public static final EVENT_SHOP_DATA_LOADED:String = "ShopDataLoaded";

	// ShopModel.as:29
	public static final EVENT_SHOP_DATA_LOADING:String = "ShopDataLoading";

	// ShopModel.as:31
	public static final EVENT_SHOP_DATA_FAILED:String = "ShopDataFailed";

	// ShopModel.as:33
	public static final EVENT_BUY_SEED_SUCCESS:String = "BuySeedSuccess";

	// ShopModel.as:35
	public static final EVENT_BUY_SEED_FAIL:String = "BuySeedFail";

	// ShopModel.as:37
	public static final EVENT_BUY_FISH_SUCCESS:String = "BuyFishSuccess";

	// ShopModel.as:39
	public static final EVENT_BUY_FISH_FAIL:String = "BuyFishFail";

	// ShopModel.as:41
	public static final EVENT_BUY_TOOL_SUCCESS:String = "BuyToolSuccess";

	// ShopModel.as:43
	public static final EVENT_BUY_TOOL_FAIL:String = "BuyToolFail";

	// ShopModel.as:45
	public static final EVENT_BUY_DIY_SUCCESS:String = "BuyDiySuccess";

	// ShopModel.as:47
	public static final EVENT_BUY_DIY_FAIL:String = "BuyDiyFail";

	// ShopModel.as:49
	public static final EVENT_SHOP_DIY_OWN_LOADED:String = "ShopDiyOwnDataLoaded";

	// ShopModel.as:51
	public static final EVENT_NORMAL_ERROR:String = "NormalErrorAlert";

	// ShopModel.as:53
	public static final EVENT_UNLOCK_FISH_SUCCESS:String = "UnlockFishSuccess";

	// ShopModel.as:55
	public static final EVENT_UNLOCK_FISH_FAIL:String = "UnlockFishFail";

	// ShopModel.as:57
	private var m_preBuyToolType:Int;

	// ShopModel.as:59
	private var _diyExp:Int;

	// ShopModel.as:61
	private var m_requestPending:Bool;

	// ShopModel.as:63
	private var _buyType:String;

	// ShopModel.as:65
	private var m_advertisement:Array<Dynamic>;

	// ShopModel.as:67
	private var m_decors:Array<Dynamic>;

	// ShopModel.as:69
	private var m_fishs:Array<Dynamic>;

	// ShopModel.as:71
	private var _itemType:String;

	// ShopModel.as:73
	private var m_seeds:Array<Dynamic>;

	// ShopModel.as:75
	private var seedID:Int;

	// ShopModel.as:77
	private var seedNum:Int;

	// ShopModel.as:79
	private var m_adSeeds:Array<Dynamic>;

	// ShopModel.as:81
	private var m_items:Array<Dynamic>;

	// ShopModel.as:83-92
	public function new(param1:IEventDispatcher = null) {
		super(param1);
		this.m_seeds = null;
		this.m_items = null;
		this.m_decors = null;
		this.m_adSeeds = null;
		this.m_preBuyToolType = -1;
		this.m_requestPending = false;
	}

	// ShopModel.as:94-105
	public function loadDecorsInfo():Void {
		if (this.m_decors != null) {
			return;
		}
		dispatchEvent(new CommonEvent(EVENT_SHOP_DATA_LOADING, {
			"index": 3,
			"show": true
		}));
		NetHelper.sendRequest(CommandDefs.CMD_GET_SHOP_DIY, null, this.onGetDecorsInfo, this.onLoadDataError);
	}

	// ShopModel.as:107-111
	private function endTransaction():Void {
		this.m_preBuyToolType = -1;
		this.m_requestPending = false;
	}

	// ShopModel.as:113-122
	public function loadAdvertisementInfo():Void {
		var _loc1_:String = "posid=72339074132595919&adposcount=1&count=6&siteset=1&datatype=2";
		var _loc2_:URLVariables = new URLVariables(_loc1_);
		dispatchEvent(new CommonEvent(EVENT_SHOP_DATA_LOADING, {
			"index": 4,
			"show": true
		}));
		NetHelper.getRequest(CommandDefs.CMD_GET_SNS_AD, _loc2_, this.onGetAdvertisementInfo, this.onLoadDataError);
	}

	// ShopModel.as:124-136
	private function onUnlockFishSuccess(param1:CommandEvent):Void {
		var _loc2_:Dynamic = NetHelper.getVOData(param1);
		if (_loc2_ == null) {
			return;
		}
		if (Reflect.field(_loc2_, "code") == 1) {
			dispatchEvent(new CommonEvent(EVENT_UNLOCK_FISH_SUCCESS, _loc2_));
		}
		this.loadFishInfo(true);
	}

	// ShopModel.as:138-152
	private function onDecorsItemLoadedInfo(param1:CommandEvent):Void {
		var _loc4_:Dynamic = null;
		var _loc2_:Dynamic = NetHelper.getVOData(param1);
		if (_loc2_ == null) {
			return;
		}
		var _loc3_:Array<Dynamic> = [];
		// AS3 `_loc2_[1]`：VO data 是 Parser 的双元素数组（当前装饰 + 已购表），
		// 索引取 [1]；Dynamic 不能下标，cast 后取
		for (_loc4_ in (cast(cast(_loc2_, Array<Dynamic>)[1], Array<Dynamic>))) {
			_loc3_.push(Reflect.field(_loc4_, "_id"));
		}
		dispatchEvent(new CommonEvent(EVENT_SHOP_DIY_OWN_LOADED, {"data": _loc3_}));
	}

	// ShopModel.as:154-156
	public var advertisements(get, never):Array<Dynamic>;

	private function get_advertisements():Array<Dynamic> {
		return this.m_advertisement;
	}

	// ShopModel.as:159-171
	private function fishSort(param1:ShopFish, param2:ShopFish):Int {
		if (param1 == null || param2 == null) {
			return 0;
		}
		var _loc3_:Int = param1._output * param1._sale > param2._output * param2._sale ? 1 : -1;
		if (param1._output * param1._sale == param2._output * param2._sale) {
			_loc3_ = param1._id > param2._id ? 1 : -1;
		}
		return _loc3_;
	}

	// ShopModel.as:173-224
	private function onLoadDataError(param1:CommandEvent):Void {
		var _loc2_:Dynamic = NetHelper.getVOData(param1);
		if (_loc2_ == null) {
			return;
		}
		var _loc3_:Int = -1;
		if (param1.body != null && As3.hasProp(param1.body, "cmdID")) {
			if (As3.intOf(Reflect.field(param1.body, "cmdID")) == CommandDefs.CMD_GET_SHOP_SEED) {
				_loc3_ = 0;
				this.recordResp(EventRecorder.HF_GET_SHOP_SEED, false, "mod=usertool&act=getSeedInfo");
				QzoneJSAPI.reportError("商店种子加载失败", 2);
			} else if (As3.intOf(Reflect.field(param1.body, "cmdID")) == CommandDefs.CMD_GET_SHOP_ITEMS) {
				_loc3_ = 2;
				this.recordResp(EventRecorder.HF_GET_SHOP_ITEM, false, "mod=usertool&act=getTools");
				QzoneJSAPI.reportError("商店道具加载失败", 2);
			} else if (As3.intOf(Reflect.field(param1.body, "cmdID")) == CommandDefs.CMD_GET_SHOP_DIY) {
				_loc3_ = 3;
				this.recordResp(EventRecorder.HF_GET_SHOP_DIY, false, "mod=item&act=shop");
				QzoneJSAPI.reportError("商店装饰加载失败", 2);
			} else if (As3.intOf(Reflect.field(param1.body, "cmdID")) == CommandDefs.CMD_GET_SNS_AD) {
				this.recordResp(EventRecorder.HF_GET_SNS_AD, false, "i.gdt.qq.com");
			} else if (As3.intOf(Reflect.field(param1.body, "cmdID")) == CommandDefs.CMD_GET_SHOP_FISH) {
				_loc3_ = 1;
				EventRecorder.recordErrorEvent("160857", null, 4);
			} else if (As3.intOf(Reflect.field(param1.body, "cmdID")) == CommandDefs.CMD_GET_SHOP_ADVERTISEMENT_SEED) {
				_loc3_ = 5;
			}
		}
		if (_loc3_ == -1) {
			return;
		}
		var _loc4_:String = Reflect.field(Language.L, "请求超时，")
			+ "<a href='event:reload'><u><font color='#ff6600'>"
			+ Reflect.field(Language.L, "点击重试") + "</font></u></a>";
		dispatchEvent(new CommonEvent(EVENT_SHOP_DATA_FAILED, {
			"index": _loc3_,
			"error": _loc4_
		}));
	}

	// ShopModel.as:226-228
	public var fishs(get, never):Array<Dynamic>;

	private function get_fishs():Array<Dynamic> {
		return this.m_fishs;
	}

	// ShopModel.as:231-279
	private function onGetAdvertisementInfo(param1:CommandEvent):Void {
		var _loc3_:String = null;
		var _loc2_:Dynamic = NetHelper.getVOData(param1);
		if (_loc2_ == null) {
			return;
		}
		if (Reflect.field(_loc2_, "ret") != 0) {
			dispatchEvent(new CommonEvent(EVENT_SHOP_DATA_FAILED, {
				"index": 4,
				"error": Reflect.field(_loc2_, "msg")
			}));
		} else if (Reflect.field(Reflect.field(Reflect.field(_loc2_, "data"), "72339074132595919"), "ret") == 0) {
			dispatchEvent(new CommonEvent(EVENT_SHOP_DATA_LOADING, {
				"index": 4,
				"show": false
			}));
			if (this.m_advertisement == null) {
				this.m_advertisement = new Array<Dynamic>();
			} else {
				this.m_advertisement.splice(0, this.m_advertisement.length);
			}
			this.m_advertisement = this.m_advertisement.concat(cast(Reflect
				.field(Reflect.field(Reflect.field(_loc2_, "data"), "72339074132595919"), "list"), Array<Dynamic>));
			dispatchEvent(new CommonEvent(EVENT_SHOP_DATA_LOADED, {
				"index": 4,
				"data": this.m_advertisement
			}));
			_loc3_ = Reflect.field(Reflect.field(Reflect.field(Reflect.field(_loc2_, "data"), "72339074132595919"), "cfg"), "apurl");
			if (_loc3_ != null && _loc3_ != "") {
				QQOutlets.sendToURL(new URLRequest(_loc3_));
			}
		} else {
			dispatchEvent(new CommonEvent(EVENT_SHOP_DATA_LOADED, {
				"index": 4,
				"data": this.m_advertisement
			}));
		}
		this.recordResp(EventRecorder.HF_GET_SNS_AD, true, "i.gdt.qq.com");
	}

	// ShopModel.as:281-283
	public var seeds(get, never):Array<Dynamic>;

	private function get_seeds():Array<Dynamic> {
		return this.m_seeds;
	}

	// ShopModel.as:286-303
	private function onBuyToolSuccess(param1:CommandEvent):Void {
		var _loc2_:Dynamic = NetHelper.getVOData(param1);
		if (_loc2_ == null) {
			return;
		}
		var _loc3_:Dynamic = {};
		if (Reflect.field(param1.body, "cmdID") == CommandDefs.CMD_BUY_TOOLS
			|| Reflect.field(param1.body, "cmdID") == CommandDefs.CMD_BUY_WEAPONS
			|| Reflect.field(param1.body, "cmdID") == CommandDefs.CMD_BUY_TOOLS_VIP) {
			if (Reflect.field(_loc2_, "code") == 1) {
				Reflect.setField(_loc2_, "__buyType", "0");
				dispatchEvent(new CommonEvent(EVENT_BUY_TOOL_SUCCESS, _loc2_));
			}
		}
		this.endTransaction();
	}

	// ShopModel.as:305-311
	public function resetLoadingFlags():Void {
		if (this.m_requestPending == true) {
			this.m_requestPending = false;
		}
	}

	// ShopModel.as:313-325
	public function loadSeedsInfo():Void {
		if (this.m_seeds != null) {
			return;
		}
		dispatchEvent(new CommonEvent(EVENT_SHOP_DATA_LOADING, {
			"index": 0,
			"show": true,
			"isact": 0
		}));
		NetHelper.sendRequest(CommandDefs.CMD_GET_SHOP_SEED, null, this.onGetSeedsInfo, this.onLoadDataError);
	}

	// ShopModel.as:327-348
	private function onBuySeedSuccess(param1:CommandEvent):Void {
		var _loc3_:String = null;
		var _loc4_:URLVariables = null;
		var _loc2_:Dynamic = NetHelper.getVOData(param1);
		if (_loc2_ == null) {
			return;
		}
		if (Reflect.field(_loc2_, "code") == 1) {
			dispatchEvent(new CommonEvent(EVENT_BUY_SEED_SUCCESS, _loc2_));
		}
		this.endTransaction();
		if (As3.hasProp(Reflect.field(param1.body, "__body"), "isAdSeed")
			&& As3.truthy(Reflect.field(Reflect.field(param1.body, "__body"), "isAdSeed"))) {
			_loc3_ = "actionid=6&targettype=18&tagetid=" + Std.string(Reflect.field(_loc2_, "cId"))
				+ "&amt=" + Std.string(Reflect.field(_loc2_, "num"));
			_loc4_ = new URLVariables(_loc3_);
			this.postUrl("", _loc4_, URLRequestMethod.GET);
		}
		this.recordResp(EventRecorder.HF_BUY_SEEDS, true, "mod=repertory&act=buySeed");
	}

	// ShopModel.as:350-365
	public function loadFishInfo(param1:Bool = false):Void {
		if (!Session.getInstance().m_waterPoolOpen) {
			return;
		}
		if (this.m_fishs != null && !param1) {
			return;
		}
		dispatchEvent(new CommonEvent(EVENT_SHOP_DATA_LOADING, {
			"index": 1,
			"show": true
		}));
		NetHelper.sendRequest(CommandDefs.CMD_GET_SHOP_FISH, null, this.onGetFishInfo, this.onLoadDataError);
	}

	// ShopModel.as:367-375
	public function buyDiy(param1:Int):Void {
		if (this.beginTransaction(Std.int(As3.parseInt(Consts.ITEM_TYPE_DIY))) == false) {
			return;
		}
		var _loc2_:Dynamic = {"itemId": param1};
		NetHelper.sendRequest(CommandDefs.CMD_BUY_DIY, _loc2_, this.onBuyDIYSuccess, this.onTransactionError);
	}

	// ShopModel.as:377-385
	private function postUrl(param1:String, param2:URLVariables, param3:String):Void {
		param1 = QzoneJSAPI.addGToken(param1);
		var _loc4_:URLRequest = new URLRequest(param1);
		_loc4_.data = param2;
		_loc4_.method = param3;
		var _loc5_:URLLoader = new URLLoader();
		_loc5_.load(_loc4_);
	}

	// ShopModel.as:387-455
	private function onGetAdvertisementSeedsList(param1:CommandEvent):Void {
		var _loc6_:Seed = null;
		var _loc2_:Dynamic = NetHelper.getVOData(param1);
		if (_loc2_ == null) {
			return;
		}
		if (this.m_adSeeds == null) {
			this.m_adSeeds = new Array<Dynamic>();
		} else {
			this.m_adSeeds.splice(0, this.m_adSeeds.length);
		}
		this.m_adSeeds = this.m_adSeeds.concat(cast(_loc2_, Array<Dynamic>));
		var _loc3_:Array<Dynamic> = null;
		var _loc4_:String = Settings.getInstance().getStringAttribute("crops_sort");
		if (_loc4_ != "") {
			_loc3_ = _loc4_.split(",");
		}
		var _loc5_:Dynamic = null;
		// for-each：AS3 声明 `_loc6_:Seed`，转译经 typed 收窄（FarmLandModel:1288 先例）
		var typed:Array<Seed> = cast this.m_adSeeds;
		for (_loc6_ in typed) {
			if (_loc3_ != null) {
				_loc6_._sort = _loc3_.indexOf(Std.string(_loc6_._id));
			}
			_loc5_ = Settings.getInstance().getCropByID(Std.string(_loc6_._id));
			if (_loc5_ != null) {
				if (_loc6_._isFood == -1 && As3.hasProp(_loc5_, "isFood")) {
					_loc6_._isFood = As3.eqString(Reflect.field(_loc5_, "isFood"), "1") ? 1 : 0;
				}
				if (_loc6_._isRestaurant == -1 && As3.hasProp(_loc5_, "isRestaurant")) {
					_loc6_._isRestaurant = As3.eqString(Reflect.field(_loc5_, "isRestaurant"), "1") ? 1 : 0;
				}
				if (_loc6_._isActivity == -1 && As3.hasProp(_loc5_, "isActivity")) {
					_loc6_._isActivity = As3.eqString(Reflect.field(_loc5_, "isActivity"), "1") ? 1 : 0;
				}
				if (_loc6_._isMill == -1 && As3.hasProp(_loc5_, "isMill")) {
					_loc6_._isMill = As3.eqString(Reflect.field(_loc5_, "isMill"), "1") ? 1 : 0;
				}
				if (_loc6_._isVip == -1 && As3.hasProp(_loc5_, "isVIP")) {
					_loc6_._isVip = As3.eqString(Reflect.field(_loc5_, "isVIP"), "1") ? 1 : 0;
					if (As3.hasProp(_loc5_, "vipDesc")) {
						_loc6_._vipDesc = Reflect.field(_loc5_, "vipDesc");
					}
				}
				if (As3.hasProp(_loc5_, "isRed")) {
					_loc6_._isRed = As3.eqString(Reflect.field(_loc5_, "isRed"), "1") ? true : false;
				}
			}
		}
		if (_loc3_ != null) {
			this.m_adSeeds.sort(this.seedSort);
		}
		this.loadAdvertisementSeedsInfo();
	}

	// ShopModel.as:457-472
	public function buyFishs(param1:Int, param2:Int):Void {
		if (param1 <= 0 || param2 <= 0) {
			return;
		}
		if (this.beginTransaction(Std.int(As3.parseInt(Consts.ITEM_TYPE_FISH))) == false) {
			return;
		}
		var _loc3_:Dynamic = {
			"fid": param1,
			"num": param2
		};
		NetHelper.sendRequest(CommandDefs.CMD_BUY_FISHS, _loc3_, this.onBuyFishSuccess, this.onTransactionError);
	}

	// ShopModel.as:474-486
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

	// ShopModel.as:488-577
	private function onGetSeedsInfo(param1:CommandEvent):Void {
		var _loc6_:Seed = null;
		dispatchEvent(new CommonEvent(EVENT_SHOP_DATA_LOADING, {
			"index": 0,
			"show": false
		}));
		var _loc2_:Dynamic = NetHelper.getVOData(param1);
		if (_loc2_ == null) {
			return;
		}
		if (this.m_seeds == null) {
			this.m_seeds = new Array<Dynamic>();
		} else {
			this.m_seeds.splice(0, this.m_seeds.length);
		}
		this.m_seeds = this.m_seeds.concat(cast(_loc2_, Array<Dynamic>));
		var _loc3_:Array<Dynamic> = null;
		var _loc4_:String = Settings.getInstance().getStringAttribute("crops_sort");
		if (_loc4_ != "") {
			_loc3_ = _loc4_.split(",");
		}
		var _loc5_:Dynamic = null;
		var typed:Array<Seed> = cast this.m_seeds;
		for (_loc6_ in typed) {
			if (_loc3_ != null) {
				_loc6_._sort = _loc3_.indexOf(Std.string(_loc6_._id));
			}
			_loc5_ = Settings.getInstance().getCropByID(Std.string(_loc6_._id));
			if (_loc5_ != null) {
				if (_loc6_._isFood == -1 && As3.hasProp(_loc5_, "isFood")) {
					_loc6_._isFood = As3.eqString(Reflect.field(_loc5_, "isFood"), "1") ? 1 : 0;
				}
				if (_loc6_._isRestaurant == -1 && As3.hasProp(_loc5_, "isRestaurant")) {
					if (As3.eqString(Reflect.field(_loc5_, "isRestaurant"), "1")) {
						_loc6_._isRestaurant = 1;
					} else if (As3.eqString(Reflect.field(_loc5_, "isRestaurant"), "2")) {
						_loc6_._isRestaurant = 2;
					} else {
						_loc6_._isRestaurant = 0;
					}
				}
				if (_loc6_._isMill == -1 && As3.hasProp(_loc5_, "isMill")) {
					_loc6_._isMill = As3.eqString(Reflect.field(_loc5_, "isMill"), "1") ? 1 : 0;
				}
				if (_loc6_._isActivity == -1 && As3.hasProp(_loc5_, "isActivity")) {
					_loc6_._isActivity = As3.eqString(Reflect.field(_loc5_, "isActivity"), "1") ? 1 : 0;
				}
				if (_loc6_._isVip == -1 && As3.hasProp(_loc5_, "isVIP")) {
					_loc6_._isVip = As3.eqString(Reflect.field(_loc5_, "isVIP"), "1") ? 1 : 0;
					if (As3.hasProp(_loc5_, "vipDesc")) {
						_loc6_._vipDesc = Reflect.field(_loc5_, "vipDesc");
					}
				}
				if (As3.hasProp(_loc5_, "isRed")) {
					_loc6_._isRed = As3.eqString(Reflect.field(_loc5_, "isRed"), "1") ? true : false;
					_loc6_._isBlack = As3.eqString(Reflect.field(_loc5_, "isRed"), "2") ? true : false;
				}
				_loc6_._isGreen = Reflect.field(_loc5_, "isYouji") == 1 ? true : false;
			}
		}
		if (_loc3_ != null) {
			this.m_seeds.sort(this.seedSort);
		}
		dispatchEvent(new CommonEvent(EVENT_SHOP_DATA_LOADED, {
			"index": 0,
			"data": this.m_seeds
		}));
		this.recordResp(EventRecorder.HF_GET_SHOP_SEED, true, "mod=usertool&act=getSeedInfo");
	}

	// ShopModel.as:579-605
	public function buySeeds(param1:Int, param2:Int, param3:Bool = false):Void {
		var _loc5_:String = null;
		var _loc6_:URLVariables = null;
		if (param1 == 0 || param2 <= 0) {
			return;
		}
		if (this.beginTransaction(Std.int(As3.parseInt(Consts.ITEM_TYPE_SEED))) == false) {
			return;
		}
		var _loc4_:Dynamic = {
			"cId": param1,
			"number": param2
		};
		if (param3) {
			this.seedID = param1;
			this.seedNum = param2;
			_loc5_ = Settings.getInstance().mode == "qzone" ? "dtype=qq" : "dtype=pengyou";
			_loc6_ = new URLVariables(_loc5_);
			NetHelper.getRequest(CommandDefs.CMD_SET_ADSEED_COOKIE, _loc6_, this.onSetCookie, this.onSetCookie);
			return;
		}
		NetHelper.sendRequest(CommandDefs.CMD_BUY_SEEDS, _loc4_, this.onBuySeedSuccess, this.onTransactionError);
	}

	// ShopModel.as:607-657
	private function onGetFishInfo(param1:CommandEvent):Void {
		var _loc4_:ShopFish = null;
		dispatchEvent(new CommonEvent(EVENT_SHOP_DATA_LOADING, {
			"index": 1,
			"show": false
		}));
		var _loc2_:Dynamic = NetHelper.getVOData(param1);
		if (_loc2_ == null) {
			return;
		}
		if (this.m_fishs == null) {
			this.m_fishs = new Array<Dynamic>();
		} else {
			this.m_fishs.splice(0, this.m_fishs.length);
		}
		this.m_fishs = this.m_fishs.concat(cast(_loc2_, Array<Dynamic>));
		var _loc3_:Dynamic = null;
		var typed:Array<ShopFish> = cast this.m_fishs;
		for (_loc4_ in typed) {
			_loc3_ = Settings.getInstance().getFishByID(Std.string(_loc4_._id));
			if (_loc3_ != null) {
				// Int 字段收 Dynamic 配置值：AS3 隐式 int 强转显式化（lock_money
				// "10000" → 10000，ShopFish.as:28）
				_loc4_._pool_size = As3.intOf(Reflect.field(_loc3_, "pool_size"));
				_loc4_._exp = As3.intOf(Reflect.field(_loc3_, "exp"));
				_loc4_._name = Reflect.field(_loc3_, "crop_name");
				_loc4_._output = As3.intOf(Reflect.field(_loc3_, "output"));
				_loc4_._sale = As3.intOf(Reflect.field(_loc3_, "sale"));
				_loc4_._price = As3.intOf(Reflect.field(_loc3_, "price"));
				_loc4_._mature = As3.intOf(Reflect.field(_loc3_, "mature"));
				if (_loc4_._lock_gold == 0 && As3.hasProp(_loc3_, "lock_money")) {
					_loc4_._lock_gold = As3.intOf(Reflect.field(_loc3_, "lock_money"));
				}
				if (_loc4_._lock_crystal == "" && As3.hasProp(_loc3_, "lock_crystal")) {
					_loc4_._lock_crystal = Reflect.field(_loc3_, "lock_crystal");
				}
			}
		}
		this.m_fishs.sort(this.fishSort);
		dispatchEvent(new CommonEvent(EVENT_SHOP_DATA_LOADED, {
			"index": 1,
			"data": this.m_fishs
		}));
		EventRecorder.recordSueecssEvent("160857", null);
	}

	// ShopModel.as:659-671
	public function buyTool(param1:Int, param2:Int, param3:Int, param4:Bool = false, param5:String = "", param6:Int = 0):Void {
		if (this.beginTransaction(param3) == false) {
			return;
		}
		var _loc7_:Dynamic = {
			"tId": param1,
			"number": param2,
			"type": param3
		};
		NetHelper.sendRequest(CommandDefs.CMD_BUY_TOOLS, _loc7_, this.onBuyToolSuccess, this.onTransactionError);
	}

	// ShopModel.as:673-691
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

	// ShopModel.as:693-712
	public function isEmpty(param1:Int):Bool {
		if (param1 == 0) {
			return this.m_seeds == null || this.m_seeds.length == 0 ? true : false;
		}
		if (param1 == 1) {
			return this.m_items == null || this.m_items.length == 0 ? true : false;
		}
		if (param1 == 2) {
			return this.m_decors == null || this.m_decors.length == 0 ? true : false;
		}
		if (param1 == 4) {
			return this.m_fishs == null || this.m_fishs.length == 0 ? true : false;
		}
		return true;
	}

	// ShopModel.as:714-716
	public var decors(get, never):Array<Dynamic>;

	private function get_decors():Array<Dynamic> {
		return this.m_decors;
	}

	// ShopModel.as:719-736
	private function onSetCookie(param1:CommandEvent):Void {
		var _loc2_:Dynamic = NetHelper.getVOData(param1);
		if (_loc2_ == null) {
			return;
		}
		if (As3.hasProp(_loc2_, "errorContent")) {
			QQOutlets.call("eval", Std.string(Reflect.field(_loc2_, "errorContent")));
		}
		var _loc3_:Dynamic = {
			"cId": this.seedID,
			"number": this.seedNum,
			"isAdSeed": true
		};
		NetHelper.sendRequest(CommandDefs.CMD_BUY_SEEDS, _loc3_, this.onBuySeedSuccess, this.onTransactionError);
	}

	// ShopModel.as:738-749
	public function loadItemsInfo():Void {
		if (this.m_items != null) {
			return;
		}
		dispatchEvent(new CommonEvent(EVENT_SHOP_DATA_LOADING, {
			"index": 2,
			"show": true
		}));
		NetHelper.sendRequest(CommandDefs.CMD_GET_SHOP_ITEMS, null, this.onGetItemsInfo, this.onLoadDataError);
	}

	// ShopModel.as:751-759
	public function unlockFish(param1:Int):Void {
		if (param1 <= 0) {
			return;
		}
		var _loc2_:Dynamic = {"fid": param1};
		NetHelper.sendRequest(CommandDefs.CMD_UNLOCK_SHOP_FISH, _loc2_, this.onUnlockFishSuccess, this.onTransactionError);
	}

	// ShopModel.as:761-795
	public function clear(param1:Int):Void {
		if (param1 == 0) {
			if (this.m_seeds != null) {
				this.m_seeds.splice(0, this.m_seeds.length);
			}
			this.m_seeds = null;
		} else if (param1 == 1) {
			if (this.m_items != null) {
				this.m_items.splice(0, this.m_items.length);
			}
			this.m_items = null;
		} else if (param1 == 2) {
			if (this.m_decors != null) {
				this.m_decors.splice(0, this.m_decors.length);
			}
			this.m_decors = null;
		} else if (param1 == 3) {
			if (this.m_advertisement != null) {
				this.m_advertisement.splice(0, this.m_advertisement.length);
			}
			this.m_advertisement = null;
		}
	}

	// ShopModel.as:797-831
	private function onInGamePreCheckSuccess(param1:CommandEvent):Void {
		var onInGameBuySuccess:Dynamic->Void = null;
		var obj:Dynamic = null;
		var e:CommandEvent = param1;
		onInGameBuySuccess = function(param1:Dynamic):Void {
			var _loc2_:Dynamic = {};
			Reflect.setField(_loc2_, "__buyType", 3);
			if (this._buyType == "Item") {
				Reflect.setField(_loc2_, "type", this._itemType);
				dispatchEvent(new CommonEvent(EVENT_BUY_TOOL_SUCCESS, _loc2_));
			} else if (this._buyType == "DIY") {
				if (this._diyExp > 0) {
					Reflect.setField(_loc2_, "__exp", this._diyExp);
				}
				dispatchEvent(new CommonEvent(EVENT_BUY_DIY_SUCCESS, _loc2_));
			}
		};
		var data:Dynamic = NetHelper.getVOData(e);
		if (Reflect.field(data, "code") == 1) {
			QzoneJSAPI.getInGamePay(Reflect.field(data, "url_params"), onInGameBuySuccess);
		} else {
			obj = {};
			Reflect.setField(obj, "direction", Reflect.field(data, "direction"));
			dispatchEvent(new CommonEvent(EVENT_BUY_DIY_FAIL, obj));
		}
	}

	// ShopModel.as:833-841
	public function buyWeapon(param1:Int, param2:Int, param3:Int):Void {
		var _loc4_:Dynamic = {
			"tId": param1,
			"number": param2,
			"type": param3
		};
		NetHelper.sendRequest(CommandDefs.CMD_BUY_WEAPONS, _loc4_, this.onBuyToolSuccess, this.onTransactionError);
	}

	// ShopModel.as:843-861
	private function onBuyDIYSuccess(param1:CommandEvent):Void {
		var _loc2_:Dynamic = NetHelper.getVOData(param1);
		if (_loc2_ == null) {
			return;
		}
		var _loc3_:Dynamic = {};
		if (Reflect.field(param1.body, "cmdID") == CommandDefs.CMD_BUY_DIY) {
			if (Reflect.field(_loc2_, "code") == 1) {
				Reflect.setField(_loc2_, "__buyType", "0");
				dispatchEvent(new CommonEvent(EVENT_BUY_DIY_SUCCESS, _loc2_));
				this.recordResp(EventRecorder.HF_BUY_DIY, true, "mod=cgi_farm_buyitem");
			}
		}
		this.endTransaction();
	}

	// ShopModel.as:863-888
	private function onGetItemsInfo(param1:CommandEvent):Void {
		dispatchEvent(new CommonEvent(EVENT_SHOP_DATA_LOADING, {
			"index": 2,
			"show": false
		}));
		var _loc2_:Dynamic = NetHelper.getVOData(param1);
		if (_loc2_ == null) {
			return;
		}
		if (this.m_items == null) {
			this.m_items = new Array<Dynamic>();
		} else {
			this.m_items.splice(0, this.m_items.length);
		}
		this.m_items = this.m_items.concat(cast(_loc2_, Array<Dynamic>));
		dispatchEvent(new CommonEvent(EVENT_SHOP_DATA_LOADED, {
			"index": 2,
			"data": this.m_items
		}));
		this.recordResp(EventRecorder.HF_GET_SHOP_ITEM, true, "mod=usertool&act=getTools");
	}

	// ShopModel.as:890-929
	private function onTransactionError(param1:CommandEvent):Void {
		var _loc2_:Dynamic = NetHelper.getVOData(param1);
		if (_loc2_ == null) {
			return;
		}
		var _loc3_:Int = As3.intOf(Reflect.field(param1.body, "cmdID"));
		var _loc4_:Dynamic = {};
		if (_loc3_ == CommandDefs.CMD_BUY_SEEDS) {
			Reflect.setField(_loc2_, "__buyType", "0");
			dispatchEvent(new CommonEvent(EVENT_BUY_SEED_FAIL, _loc2_));
			this.recordResp(EventRecorder.HF_BUY_SEEDS, false, "mod=repertory&act=buySeed");
		} else if (_loc3_ == CommandDefs.CMD_BUY_FISHS || _loc3_ == CommandDefs.CMD_UNLOCK_SHOP_FISH) {
			Reflect.setField(_loc2_, "__buyType", "0");
			dispatchEvent(new CommonEvent(EVENT_BUY_FISH_FAIL, _loc2_));
		} else if (_loc3_ == CommandDefs.CMD_BUY_TOOLS || _loc3_ == CommandDefs.CMD_BUY_TOOLS_VIP) {
			Reflect.setField(_loc2_, "__buyType", "0");
			dispatchEvent(new CommonEvent(EVENT_BUY_TOOL_FAIL, _loc2_));
		} else if (_loc3_ == CommandDefs.CMD_BUY_DIY) {
			Reflect.setField(_loc2_, "__buyType", "0");
			dispatchEvent(new CommonEvent(EVENT_BUY_DIY_FAIL, _loc2_));
			if (Reflect.field(_loc2_, "ecode") != -30017) {
				this.recordResp(EventRecorder.HF_BUY_DIY, false, "mod=cgi_farm_buyitem");
			}
		} else if (_loc3_ == CommandDefs.CMD_BUY_INGAME_BUY) {
			dispatchEvent(new CommonEvent(EVENT_NORMAL_ERROR, _loc2_));
		}
		this.endTransaction();
	}

	// ShopModel.as:931-945
	public function buyInGame(param1:Dynamic, param2:Int, param3:String, param4:Int = 0, param5:String = ""):Void {
		if (param4 > 0) {
			this._diyExp = param4;
		} else {
			this._diyExp = 0;
		}
		this._buyType = param3;
		this._itemType = param5;
		Reflect.setField(param1, "payType", param2);
		NetHelper.sendRequest(CommandDefs.CMD_BUY_INGAME_BUY, param1, this.onInGamePreCheckSuccess, this.onTransactionError);
	}

	// ShopModel.as:947-955
	public function loadAdvertisementSeedsList():Void {
		dispatchEvent(new CommonEvent(EVENT_SHOP_DATA_LOADING, {
			"index": 5,
			"show": true
		}));
		var _loc1_:Dynamic = {"isact": 1};
		NetHelper.sendRequest(CommandDefs.CMD_GET_SHOP_SEED, _loc1_, this.onGetAdvertisementSeedsList, this.onLoadDataError);
	}

	// ShopModel.as:957-995
	private function onGetDecorsInfo(param1:CommandEvent):Void {
		dispatchEvent(new CommonEvent(EVENT_SHOP_DATA_LOADING, {
			"index": 3,
			"show": false
		}));
		var _loc2_:Dynamic = NetHelper.getVOData(param1);
		if (_loc2_ == null) {
			return;
		}
		if (this.m_decors == null) {
			this.m_decors = new Array<Dynamic>();
		} else {
			this.m_decors.splice(0, this.m_decors.length);
		}
		this.m_decors = this.m_decors.concat(cast(_loc2_, Array<Dynamic>));
		this.m_decors.reverse();
		var _loc3_:Dynamic = null;
		var _loc4_:Int = 0;
		// PORT-NOTE: 原版块换位在非 4 倍数长度时读/写 _loc4_+1..+3 越界——AS3
		// 越界读得 undefined、写垫长到下一个 4 的倍数（尾部留空槽，原版缺陷照留；
		// 垫完 _loc4_ 追平即退出，非死循环）。Haxe 数组越界 cpp 崩溃，按 CLAUDE.md
		// 静态目标规则经 As3.arrAt/arrPut 判下标范围复刻同语义。
		while (_loc4_ < this.m_decors.length) {
			_loc3_ = As3.arrAt(this.m_decors, _loc4_);
			this.m_decors[_loc4_] = As3.arrAt(this.m_decors, _loc4_ + 3);
			As3.arrPut(this.m_decors, _loc4_ + 3, _loc3_);
			_loc3_ = As3.arrAt(this.m_decors, _loc4_ + 1);
			As3.arrPut(this.m_decors, _loc4_ + 1, As3.arrAt(this.m_decors, _loc4_ + 2));
			As3.arrPut(this.m_decors, _loc4_ + 2, _loc3_);
			_loc4_ += 4;
		}
		dispatchEvent(new CommonEvent(EVENT_SHOP_DATA_LOADED, {
			"index": 3,
			"data": this.m_decors
		}));
		this.recordResp(EventRecorder.HF_GET_SHOP_DIY, true, "mod=item&act=shop");
	}

	// ShopModel.as:997-1080
	private function onGetAdvertisementSeedsInfo(param1:CommandEvent):Void {
		var _loc3_:Array<Dynamic> = null;
		var _loc4_:Array<Dynamic> = null;
		var _loc5_:Dynamic = null;
		var _loc6_:Int = 0;
		var _loc7_:String = null;
		var _loc8_:Array<Dynamic> = null;
		var _loc9_:Int = 0;
		var _loc10_:URLVariables = null;
		var _loc11_:String = null;
		var _loc12_:Int = 0;
		var _loc13_:URLVariables = null;
		var _loc2_:Dynamic = NetHelper.getVOData(param1);
		if (_loc2_ == null) {
			return;
		}
		if (Reflect.field(_loc2_, "ret") != 0) {
			dispatchEvent(new CommonEvent(EVENT_SHOP_DATA_FAILED, {
				"index": 5,
				"error": Reflect.field(_loc2_, "msg")
			}));
		} else if (Reflect.field(Reflect.field(Reflect.field(_loc2_, "data"), "144396668170523855"), "ret") == 0) {
			dispatchEvent(new CommonEvent(EVENT_SHOP_DATA_LOADING, {
				"index": 5,
				"show": false
			}));
			_loc3_ = [];
			_loc3_ = _loc3_.concat(cast(Reflect
				.field(Reflect.field(Reflect.field(_loc2_, "data"), "144396668170523855"), "list"), Array<Dynamic>));
			_loc4_ = [];
			for (_loc5_ in (cast(_loc3_, Array<Dynamic>))) {
				_loc4_.push(Reflect.field(_loc5_, "targetid"));
			}
			_loc6_ = 0;
			_loc7_ = "";
			_loc8_ = [];
			_loc9_ = this.m_adSeeds.length;
			while (_loc9_ > 0) {
				_loc9_--;
				// 数组元素是 Seed 实例：cast 真类型后写实体字段（禁 Dynamic 裸写分流）
				if (_loc4_.indexOf(Std.string(cast(this.m_adSeeds[_loc6_], Seed)._id)) == -1) {
					this.m_adSeeds.splice(_loc6_, 1);
				} else {
					cast(this.m_adSeeds[_loc6_], Seed)._isAdSeed = 1;
					cast(this.m_adSeeds[_loc6_], Seed)._rl = Reflect.field(_loc3_[_loc4_.indexOf(Std.string(cast(this.m_adSeeds[_loc6_],
						Seed)._id))], "rl");
					_loc7_ = Std.string(Reflect.field(_loc3_[_loc4_.indexOf(Std.string(cast(this.m_adSeeds[_loc6_],
						Seed)._id))], "apurl"));
					_loc7_ = _loc7_.substr(_loc7_.indexOf("fcg?") + 4);
					_loc13_ = new URLVariables(_loc7_);
					_loc8_.push(Reflect.field(_loc13_, "viewid"));
					_loc6_++;
				}
			}
			dispatchEvent(new CommonEvent(EVENT_SHOP_DATA_LOADED, {
				"index": 5,
				"data": this.m_adSeeds
			}));
			_loc10_ = new URLVariables();
			_loc11_ = "";
			_loc12_ = 0;
			while (_loc12_ < _loc8_.length) {
				_loc11_ = "viewid" + Std.string(_loc12_);
				Reflect.setField(_loc10_, _loc11_, _loc8_[_loc12_]);
				_loc12_++;
			}
			Reflect.setField(_loc10_, "count", _loc8_.length);
			this.postUrl("", _loc10_, URLRequestMethod.POST);
		} else {
			dispatchEvent(new CommonEvent(EVENT_SHOP_DATA_LOADED, {
				"index": 5,
				"data": null
			}));
		}
	}

	// ShopModel.as:1082-1094
	private function onBuyFishSuccess(param1:CommandEvent):Void {
		var _loc2_:Dynamic = NetHelper.getVOData(param1);
		if (_loc2_ == null) {
			return;
		}
		if (Reflect.field(_loc2_, "code") == 1) {
			dispatchEvent(new CommonEvent(EVENT_BUY_FISH_SUCCESS, _loc2_));
		}
		this.endTransaction();
	}

	// ShopModel.as:1096-1101
	public function loadAdvertisementSeedsInfo():Void {
		var _loc1_:String = "posid=144396668170523855&adposcount=1&count=15&callback=_gdttxtbc&datatype=2";
		var _loc2_:URLVariables = new URLVariables(_loc1_);
		NetHelper.getRequest(CommandDefs.CMD_GET_SHOP_ADVERTISEMENT_SEED, _loc2_, this.onGetAdvertisementSeedsInfo,
			this.onGetAdvertisementSeedsInfo);
	}

	// ShopModel.as:1103-1110
	public function loadDecorsItemOwnInfo():Void {
		if (this.m_decors == null) {
			return;
		}
		NetHelper.sendRequest(CommandDefs.CMD_GET_DIY_ITEMS, null, this.onDecorsItemLoadedInfo, this.onLoadDataError);
	}

	// ShopModel.as:1112-1121
	private function beginTransaction(param1:Int):Bool {
		if (this.m_requestPending == true) {
			return false;
		}
		this.m_preBuyToolType = param1;
		this.m_requestPending = true;
		return true;
	}

	// ShopModel.as:1123-1125
	public var items(get, never):Array<Dynamic>;

	private function get_items():Array<Dynamic> {
		return this.m_items;
	}

	// ShopModel.as:1128-1139
	public function buyToolVIP(param1:Int, param2:Int):Void {
		if (param1 == 0 || param2 <= 0) {
			return;
		}
		var _loc3_:Dynamic = {
			"itemId": param1,
			"itemNum": param2
		};
		NetHelper.sendRequest(CommandDefs.CMD_BUY_TOOLS_VIP, _loc3_, this.onBuyToolSuccess, this.onTransactionError);
	}
}
