package mc.model;

import com.adobe.crypto.SHA1;
import common.CommonData;
import common.LocalData;
import mc.control.Version;
import mc.view.farm.GetCropID;
import mc.view.farm.MPScene;
import openfl.display.Bitmap;
import openfl.events.Event;
import openfl.events.EventDispatcher;
import openfl.filters.ColorMatrixFilter;
import openfl.filters.GlowFilter;
import shim.As3;

/**
 * mc.model.MainData —— MainData.as 逐句对应（1382 loc 全量，issue #87
 * 「数据」片充真身；#19 曾立 profile 窗族签名面 stub）。
 * legacy/decompiled/Master2_v_142/scripts/mc/model/MainData.as。
 */
@:keep
class MainData extends EventDispatcher {
	// MainData.as:18-24（静态位）
	public static var MarkList:Dynamic;
	public static var commonUrlNc:String;
	public static var isNewUser:String;
	public static var commonUrlFarm:String;

	// MainData.as:26-156（事件名与常量）
	public static final NO_REG:String = "no_reg";
	public static final ANIMAL_CHANGE:String = "animalChange";
	public static final ANIMAL_SHOUHUO:String = "animalShouhuo";
	public static final ANIMAL_ADD:String = "animalAdd";
	public static final ANIMAL_SHENGCHAN:String = "animalShengChan";
	public static final ANIMAL_NEXTSTATUS:String = "animalnextstatus";
	public static final MODULE_CHANGE:String = "moduleChange";
	public static final RUN_COMP:String = "runComp";
	public static final CURRENT_USER_CHANGE:String = "currentUserChange";
	public static final HOST_CHANGE:String = "hostChange";
	public static final WEATHER:String = "weather";
	public static final FRIEND_CHANGE:String = "friendChange";
	public static final USER_ITEMS:String = "userItems";
	public static final USER_HUNTERS:String = "userhunters";
	public static final USER_CROP:String = "userCrop";
	public static final USER_CROP_LOADING:String = "userCropLoading";
	public static final USER_MATERIAL:String = "userMaterial";
	public static final USER_MATERIAL_RELOAD:String = "userMaterialReload";
	public static final USER_MATERIAL_LOADING:String = "userMaterialLoading";
	public static final USER_ITEM_LOADING:String = "userItemLoading";
	public static final SEED_INFO:String = "seedInfo";
	public static final TOOL_INFO:String = "toolInfo";
	public static final DIY_INFO:String = "diyInfo";
	public static final SHOP_SEED_LOADING:String = "shopSeedLoading";
	public static final SHOP_TOOL_LOADING:String = "shopToolLoading";
	public static final SHOP_DIY_LOADING:String = "shopDiyLoading";
	public static final PROFILE:String = "profile";
	public static final PROFILE_LOADING:String = "profileLoading";
	public static final ITEMS:String = "items";
	public static final ADD_EXP:String = "addExp";
	public static final ADD_MONEY:String = "addMoney";
	public static final ADD_FB:String = "addFB";
	public static final GET_FRIEND_LIST_LOADING:String = "getFriendListLoading";
	public static final UNREAD_DATA:String = "unreadData";
	public static final WELCOME:String = "welcome";
	public static final GIFT_PACKAGE:String = "giftPackage";
	public static final VIPRETURN_GIFT_PACKAGE:String = "vipReturnGiftPackage";
	public static final USER_CHANGING:String = "userChanging";
	public static final LEVEL_REWARD:String = "levelReward";
	public static final UPDATE_ANIMAL_MATERIAL:String = "update_animal_material";
	public static final USER_LEVEL_UP:String = "userLevelUp";
	public static final SESSION_TIMEOUT:String = "sessionTimeout";
	public static final RUN_ERROR:String = "runError";
	public static final SET_USER_ERROR:String = "setUserError";
	public static final USER_CROP_ERR:String = "userCropErr";
	public static final USER_MATERIAL_ERR:String = "userMaterialErr";
	public static final USER_ITEM_ERR:String = "userItemErr";
	public static final USER_HUNTER_ERR:String = "userhunterErr";
	public static final SHOP_SEED_ERR:String = "shopSeedErr";
	public static final SHOP_TOOL_ERR:String = "shopToolErr";
	public static final SHOP_DIY_ERR:String = "shopDiyErr";
	public static final PROFILE_ERR:String = "profileErr";
	public static final GET_FRIEND_LIST_ERR:String = "getFriendListErr";
	public static final HOUSE_DATA_CHANGE:String = "house_data_change";
	public static final MAX_FOOD:Float = 1000;
	public static final MAX_SEEDS:Float = 100;
	public static final HEAD_UPDATE:String = "head_update";
	public static final MARK_UPDATE:String = "mark_update";
	public static final UNLOCK_LOCK_CROP:String = "unlock_lock_crop";
	public static final LOGIN_FLOP_WINDOW:String = "loginFlopWindow";
	public static final UPDATADEN_WINDOW:String = "updatadenWindow";
	public static final USER_CUB_LOADING:String = "userCubLoading";
	public static final USER_CUB_ERR:String = "userCubErr";
	public static final USER_CUB:String = "UserCub";
	public static final FLOP_ICON_COMPLETE:String = "fopIconComplete";
	public static final LOAD_DIY_CONFIG_COMPLETE:String = "diy_config";

	// MainData.as:158-180（静态开关位）
	public static var loadedProfile:Bool = false;
	public static var loadedMsg:Bool = false;
	public static var loadedLog:Bool = false;
	public static var loadedSystemMsg:Bool = false;
	public static var autoCursor:Bool = true;
	public static var sPrice:Bool = true;
	public static var addPackAnimal:Bool = false;
	public static var gift:Bool = false;
	public static var vipReturnGift:Bool = false;
	public static var inGameBuyType:String = "";
	public static var inGameBuyObject:Dynamic = {};
	public static var Stage:String = "farm";

	// MainData.as:182
	public static final HUNTER_CHANGE:String = "hunter_change";

	// MainData.as:184-336（backing。PORT-NOTE(int 缺省)：`_addFB:int`/
	// `_addMoney:int`/`_addExp:int`/`_showFriendPage:int` 原文有初值照抄；
	// `_userMCBg:int`/`_animalShouHuoIndex:int` 原文无初值——AS3 int 缺省
	// 0，Haxe eval 无初值 Int 读回 null，按 AS3 语义补 = 0（lessons
	// null-Int 同族）。`_hostLevel:Number` 无初值——AS3 Number 缺省 NaN，
	// 补 = Math.NaN）
	private var _friendList:Array<Dynamic>;
	private var _upDateHead:Dynamic;
	private var _sessionTimeout:String = "";
	private var _userMaterialLoading:Bool = false;
	private var _friendStatus:Dynamic;
	private var _noReg:Bool = false;
	private var _levelReward:Dynamic;
	private var _getFriendListErr:String;
	private var _welcome:Bool = false;
	private var _seedInfo:Array<Dynamic>;
	private var _diyInfo:Array<Dynamic>;
	private var _searchFriendValue:String = "";
	private var _addFB:Int = 0;
	private var _userMCBg:Int = 0;
	private var _vipBtn:Bitmap;
	private var _friendStatusRelate:Dynamic = {};
	private var _animalShengChanData:Dynamic;
	private var _userCrop:Array<Dynamic>;
	private var _userCubErr:String = "";
	private var _shopDiyErr:String = "";
	private var _profile:Dynamic;
	private var _animalAddArray:Array<Dynamic>;
	private var _shopSeedLoading:Bool = false;
	private var _houseChangeData:Dynamic;
	private var _sortField:String = "exp";
	private var _lockCropData:Dynamic;
	private var _host:Dynamic;
	private var _setUserError:String = "";
	private var _profileErr:String = "";
	private var _seedType:String = "";
	private var _userCropErr:String = "";
	private var _moduleName:String = "farm";
	private var _items:Dynamic;
	private var _weather:String = "";
	private var _grassMp:String;
	private var _unread:Dynamic;
	private var _hunter:Dynamic = {};
	private var _addExp:Int = 0;
	private var _grassSkin:String;
	private var _userHunters:Array<Dynamic>;
	private var _reloadUserMaterial:Bool = true;
	private var _mpdata:Dynamic;
	private var _upDateMark:Dynamic;
	private var _vipIcon:Bitmap;
	private var _runComp:Bool = false;
	private var _shopToolErr:String = "";
	public var reloadUserItems:Bool = true;
	private var _currentUser:Dynamic;
	private var _userCub:Array<Dynamic>;
	private var _userCrystal:Array<Dynamic>;
	private var _userItems:Array<Dynamic>;
	private var _userChanging:Bool = false;
	private var _userCubLoading:Bool = false;
	private var _hostLevel:Float = Math.NaN;
	private var _giftPackage:Dynamic;
	private var _userItemErr:String = "";
	private var _showFriendPage:Int = 1;
	private var _updateAnimalMaterial:Bool = false;
	private var _showFriendList:Array<Dynamic>;
	private var _animalData:Array<Dynamic>;
	private var _getFriendListLoading:Bool = false;
	private var _profileLoading:Bool = false;
	private var _shopToolLoading:Bool = false;
	private var _nextStatusAnimal:Dynamic;
	private var _userCropLoading:Bool = false;
	private var _userItemLoading:Bool = false;
	private var _runError:String = "";
	public var millOpened:Bool = false;
	private var _shopSeedErr:String = "";
	private var _toolsInfo:Array<Dynamic>;
	private var _userMaterialErr:String = "";
	public var reloadUserCrop:Bool = true;
	private var _shopDiyLoading:Bool = false;
	private var _animalShouHuoIndex:Int = 0;
	private var _userFarmData:Dynamic;
	private var _userMaterial:Array<Dynamic>;
	private var _addMoney:Int = 0;

	// MainData.as:338-341
	public function new() {
		super();
	}

	// MainData.as:343-346（PORT-NOTE(String())：AS3 String(serverTime)——
	// serverTime 漂移公式整秒取整（CommonData.as:141-148），值恒整数浮点，
	// Std.string 整数浮点打印无小数点（eval 实测 "1700000000"），同构）
	public static function getKey2():String {
		return SHA1.hash(Std.string(CommonData.serverTime));
	}

	// MainData.as:348-351
	public static var lockFilter(get, never):Array<Dynamic>;

	private static function get_lockFilter():Array<Dynamic> {
		return [
			new ColorMatrixFilter([
				0.3, 0.7, 0.11, 0, 0, 0.3, 0.7, 0.11, 0, 0, 0.3, 0.7, 0.11, 0, 0, 0, 0, 0, 1, 0
			])
		];
	}

	// MainData.as:353-361（concat 逐项拼 4×5 矩阵——直写等长字面量等价，
	// 但原文 concat 形态无行为差，展开照抄为同值数组）
	public static var rollOverFilter(get, never):Array<Dynamic>;

	private static function get_rollOverFilter():Array<Dynamic> {
		// 矩阵数组类型随 ColorMatrixFilter 形参收敛 Array<Float>（数值语义不变）
		var _loc1_:Array<Float> = [];
		_loc1_ = _loc1_.concat([1.1, 0, 0, 0, 0]);
		_loc1_ = _loc1_.concat([0, 1.1, 0, 0, 0]);
		_loc1_ = _loc1_.concat([0, 0, 1.1, 0, 0]);
		_loc1_ = _loc1_.concat([0, 0, 0, 1, 0]);
		return [new GlowFilter(13434624, 1, 10, 10), new ColorMatrixFilter(_loc1_)];
	}

	// MainData.as:363-366/:1322-1326（unreadData 存取——setter 派发
	// UNREAD_DATA）
	public var unreadData(get, set):Dynamic;

	private function get_unreadData():Dynamic {
		return this._unread;
	}

	private function set_unreadData(param1:Dynamic):Dynamic {
		this._unread = param1;
		dispatchEvent(new ModelEvent(MainData.UNREAD_DATA));
		return param1;
	}

	// MainData.as:368-372
	public var VipReturnPackage(never, set):Dynamic;

	private function set_VipReturnPackage(param1:Dynamic):Dynamic {
		this._giftPackage = param1;
		dispatchEvent(new ModelEvent(MainData.VIPRETURN_GIFT_PACKAGE));
		return param1;
	}

	// MainData.as:374-377/:778-781（vipBtn 存取——原文 setter 无派发）
	public var vipBtn(get, set):Bitmap;

	private function get_vipBtn():Bitmap {
		return this._vipBtn;
	}

	private function set_vipBtn(param1:Bitmap):Bitmap {
		this._vipBtn = param1;
		return param1;
	}

	// MainData.as:379-383/:788-791（userItemErr 存取——setter 派发
	// USER_ITEM_ERR）
	public var userItemErr(get, set):String;

	private function get_userItemErr():String {
		return this._userItemErr;
	}

	private function set_userItemErr(param1:String):String {
		this._userItemErr = param1;
		dispatchEvent(new ModelEvent(MainData.USER_ITEM_ERR));
		return param1;
	}

	// MainData.as:385-388/:406-409（grassMp 存取——setter 无派发）
	public var grassMp(get, set):String;

	private function get_grassMp():String {
		return this._grassMp;
	}

	private function set_grassMp(param1:String):String {
		this._grassMp = param1;
		return param1;
	}

	// MainData.as:390-394/:793-796（animalShengChanData 存取——setter
	// 派发 ANIMAL_SHENGCHAN，Event）
	public var animalShengChanData(get, set):Dynamic;

	private function get_animalShengChanData():Dynamic {
		return this._animalShengChanData;
	}

	private function set_animalShengChanData(param1:Dynamic):Dynamic {
		this._animalShengChanData = param1;
		dispatchEvent(new Event(MainData.ANIMAL_SHENGCHAN));
		return param1;
	}

	// MainData.as:396-399/:417-421（userMaterial 存取——setter 派发
	// USER_MATERIAL）
	public var userMaterial(get, set):Array<Dynamic>;

	private function get_userMaterial():Array<Dynamic> {
		return this._userMaterial;
	}

	private function set_userMaterial(param1:Array<Dynamic>):Array<Dynamic> {
		this._userMaterial = param1;
		dispatchEvent(new ModelEvent(MainData.USER_MATERIAL));
		return param1;
	}

	// MainData.as:401-404
	public function gradeToExp(param1:Int):UInt {
		return 100 * param1 * (param1 + 1);
	}

	// MainData.as:411-415
	public var updateMaterial(never, set):Bool;

	private function set_updateMaterial(param1:Bool):Bool {
		this._updateAnimalMaterial = param1;
		dispatchEvent(new Event(MainData.UPDATE_ANIMAL_MATERIAL));
		return param1;
	}

	// MainData.as:423-429（空 if 块原文如此——照抄不补）
	public var noReg(never, set):Bool;

	private function set_noReg(param1:Bool):Bool {
		this._noReg = param1;
		if (this._noReg) {}
		return param1;
	}

	// MainData.as:431-435/:810-813（moduleName 存取——setter 派发
	// MODULE_CHANGE）
	public var moduleName(get, set):String;

	private function get_moduleName():String {
		return this._moduleName;
	}

	private function set_moduleName(param1:String):String {
		this._moduleName = param1;
		dispatchEvent(new ModelEvent(MainData.MODULE_CHANGE));
		return param1;
	}

	// MainData.as:437-440/:534-537（friendStatus 存取——setter 无派发）
	public var friendStatus(get, set):Dynamic;

	private function get_friendStatus():Dynamic {
		return this._friendStatus;
	}

	private function set_friendStatus(param1:Dynamic):Dynamic {
		this._friendStatus = param1;
		return param1;
	}

	// MainData.as:442-446/:820-823（userCubLoading 存取——setter 派发
	// USER_CUB_LOADING）
	public var userCubLoading(get, set):Bool;

	private function get_userCubLoading():Bool {
		return this._userCubLoading;
	}

	private function set_userCubLoading(param1:Bool):Bool {
		this._userCubLoading = param1;
		dispatchEvent(new ModelEvent(MainData.USER_CUB_LOADING));
		return param1;
	}

	// MainData.as:448-451/:561-565（runComp 存取——setter 派发 RUN_COMP）
	public var runComp(get, set):Bool;

	private function get_runComp():Bool {
		return this._runComp;
	}

	private function set_runComp(param1:Bool):Bool {
		this._runComp = param1;
		dispatchEvent(new ModelEvent(MainData.RUN_COMP));
		return param1;
	}

	// MainData.as:453-456/:567-571（runError 存取——setter 派发 RUN_ERROR）
	public var runError(get, set):String;

	private function get_runError():String {
		return this._runError;
	}

	private function set_runError(param1:String):String {
		this._runError = param1;
		dispatchEvent(new ModelEvent(MainData.RUN_ERROR));
		return param1;
	}

	// MainData.as:458-462/:815-818（addFB 存取——setter 派发 ADD_FB）
	public var addFB(get, set):Int;

	private function get_addFB():Int {
		return this._addFB;
	}

	private function set_addFB(param1:Int):Int {
		this._addFB = param1;
		dispatchEvent(new ModelEvent(MainData.ADD_FB));
		return param1;
	}

	// MainData.as:464-468/:834-837（nextStatusAnimal 存取——setter 派发
	// ANIMAL_NEXTSTATUS）
	public var nextStatusAnimal(get, set):Dynamic;

	private function get_nextStatusAnimal():Dynamic {
		return this._nextStatusAnimal;
	}

	private function set_nextStatusAnimal(param1:Dynamic):Dynamic {
		this._nextStatusAnimal = param1;
		dispatchEvent(new ModelEvent(MainData.ANIMAL_NEXTSTATUS));
		return param1;
	}

	// MainData.as:470-473/:758-761（vipIcon 存取——setter 无派发）
	public var vipIcon(get, set):Bitmap;

	private function get_vipIcon():Bitmap {
		return this._vipIcon;
	}

	private function set_vipIcon(param1:Bitmap):Bitmap {
		this._vipIcon = param1;
		return param1;
	}

	// MainData.as:475-478/:587-591（updateHead 存取——setter 派发
	// HEAD_UPDATE，Event）
	public var updateHead(get, set):Dynamic;

	private function get_updateHead():Dynamic {
		return this._upDateHead;
	}

	private function set_updateHead(param1:Dynamic):Dynamic {
		this._upDateHead = param1;
		dispatchEvent(new Event(MainData.HEAD_UPDATE));
		return param1;
	}

	// MainData.as:480-483/:578-585（reloadUserMaterial 存取——true 时
	// 先派发 USER_MATERIAL_RELOAD 再赋值，顺序原文如此）
	public var reloadUserMaterial(get, set):Bool;

	private function get_reloadUserMaterial():Bool {
		return this._reloadUserMaterial;
	}

	private function set_reloadUserMaterial(param1:Bool):Bool {
		if (param1 == true) {
			dispatchEvent(new ModelEvent(MainData.USER_MATERIAL_RELOAD));
		}
		this._reloadUserMaterial = param1;
		return param1;
	}

	// MainData.as:485-489/:839-842（animalShouHuoIndex 存取——setter
	// 派发 ANIMAL_SHOUHUO）
	public var animalShouHuoIndex(get, set):Int;

	private function get_animalShouHuoIndex():Int {
		return this._animalShouHuoIndex;
	}

	private function set_animalShouHuoIndex(param1:Int):Int {
		this._animalShouHuoIndex = param1;
		dispatchEvent(new ModelEvent(MainData.ANIMAL_SHOUHUO));
		return param1;
	}

	// MainData.as:491-506（showFriendSum 分页 ceil——空搜索按 friendList、
	// 否则 filterFriendList；0 页钳 1）
	public var showFriendSum(get, never):Int;

	private function get_showFriendSum():Int {
		var _loc1_:Int = 1;
		if (this.friendList != null) {
			if (this.searchFriendValue == "") {
				_loc1_ = Math.ceil(this.friendList.length / this.friendPageNum);
			} else {
				_loc1_ = Math.ceil(this.filterFriendList.length / this.friendPageNum);
			}
		}
		return _loc1_ == 0 ? 1 : _loc1_;
	}

	// MainData.as:508-512/:844-847（toolsInfo 存取——setter 派发 TOOL_INFO）
	public var toolsInfo(get, set):Array<Dynamic>;

	private function get_toolsInfo():Array<Dynamic> {
		return this._toolsInfo;
	}

	private function set_toolsInfo(param1:Array<Dynamic>):Array<Dynamic> {
		this._toolsInfo = param1;
		dispatchEvent(new ModelEvent(MainData.TOOL_INFO));
		return param1;
	}

	// MainData.as:514-517/:631-634（grassSkin 存取——setter 无派发）
	public var grassSkin(get, set):String;

	private function get_grassSkin():String {
		return this._grassSkin;
	}

	private function set_grassSkin(param1:String):String {
		this._grassSkin = param1;
		return param1;
	}

	// MainData.as:519-522/:614-624（animalAddArray 存取——setter 按 serial
	// 键回填 _animalData（下标写走 arrPut 越界语义）后派发 ANIMAL_ADD。
	// PORT-NOTE：`_animalData` 未经 animalData setter 初始化时原文是
	// null 下标写抛 TypeError——Haxe null 数组写同抛（eval），等价不守卫）
	public var animalAddArray(get, set):Array<Dynamic>;

	private function get_animalAddArray():Array<Dynamic> {
		return this._animalAddArray;
	}

	private function set_animalAddArray(param1:Array<Dynamic>):Array<Dynamic> {
		this._animalAddArray = param1;
		var _loc2_:Int = 0;
		while (_loc2_ < param1.length) {
			As3.arrPut(this._animalData, As3.intOf(Reflect.field(param1[_loc2_], "serial")), param1[_loc2_]);
			_loc2_++;
		}
		dispatchEvent(new ModelEvent(MainData.ANIMAL_ADD));
		return param1;
	}

	// MainData.as:524-527/:849-852（showFriendPage 存取——setter 无派发）
	public var showFriendPage(get, set):Int;

	private function get_showFriendPage():Int {
		return this._showFriendPage;
	}

	private function set_showFriendPage(param1:Int):Int {
		this._showFriendPage = param1;
		return param1;
	}

	// MainData.as:529-532/:652-655（friendList 存取——setter 无派发）
	public var friendList(get, set):Array<Dynamic>;

	private function get_friendList():Array<Dynamic> {
		return this._friendList;
	}

	private function set_friendList(param1:Array<Dynamic>):Array<Dynamic> {
		this._friendList = param1;
		return param1;
	}

	// MainData.as:539-542/:752-756（userCub 存取——setter 派发 USER_CUB）
	public var userCub(get, set):Array<Dynamic>;

	private function get_userCub():Array<Dynamic> {
		return this._userCub;
	}

	private function set_userCub(param1:Array<Dynamic>):Array<Dynamic> {
		this._userCub = param1;
		dispatchEvent(new ModelEvent(MainData.USER_CUB));
		return param1;
	}

	// MainData.as:544-547/:732-736（userCropErr 存取——setter 派发
	// USER_CROP_ERR）
	public var userCropErr(get, set):String;

	private function get_userCropErr():String {
		return this._userCropErr;
	}

	private function set_userCropErr(param1:String):String {
		this._userCropErr = param1;
		dispatchEvent(new ModelEvent(MainData.USER_CROP_ERR));
		return param1;
	}

	// MainData.as:549-552（uin 正则过滤——RegExp 照译为 EReg；AS3/EReg
	// 同为 PCRE 子集，"?"/"i" 形态一致）
	private function friendFilterByUin(param1:Dynamic, param2:Int, param3:Array<Dynamic>):Bool {
		var _loc4_:String = Reflect.field(param1, "uin");
		return new EReg(".*?" + this.searchFriendValue + ".*", "i").match(_loc4_);
	}

	// MainData.as:555-559/:854-857（showFriendList 存取——setter 派发
	// FRIEND_CHANGE）
	public var showFriendList(get, set):Array<Dynamic>;

	private function get_showFriendList():Array<Dynamic> {
		return this._showFriendList;
	}

	private function set_showFriendList(param1:Array<Dynamic>):Array<Dynamic> {
		this._showFriendList = param1;
		dispatchEvent(new ModelEvent(MainData.FRIEND_CHANGE));
		return param1;
	}

	// MainData.as:573-576/:804-808（getFriendListLoading 存取——setter
	// 派发 GET_FRIEND_LIST_LOADING）
	public var getFriendListLoading(get, set):Bool;

	private function get_getFriendListLoading():Bool {
		return this._getFriendListLoading;
	}

	private function set_getFriendListLoading(param1:Bool):Bool {
		this._getFriendListLoading = param1;
		dispatchEvent(new ModelEvent(MainData.GET_FRIEND_LIST_LOADING));
		return param1;
	}

	// MainData.as:593-596/:907-910（seedType 存取——setter 无派发）
	public var seedType(get, set):String;

	private function get_seedType():String {
		return this._seedType;
	}

	private function set_seedType(param1:String):String {
		this._seedType = param1;
		return param1;
	}

	// MainData.as:598-601/:912-916（addMoney 存取——setter 派发 ADD_MONEY）
	public var addMoney(get, set):Int;

	private function get_addMoney():Int {
		return this._addMoney;
	}

	private function set_addMoney(param1:Int):Int {
		this._addMoney = param1;
		dispatchEvent(new ModelEvent(MainData.ADD_MONEY));
		return param1;
	}

	// MainData.as:603-606/:924-928（lockCropData 存取——setter 派发
	// UNLOCK_LOCK_CROP，Event）
	public var lockCropData(get, set):Dynamic;

	private function get_lockCropData():Dynamic {
		return this._lockCropData;
	}

	private function set_lockCropData(param1:Dynamic):Dynamic {
		this._lockCropData = param1;
		dispatchEvent(new Event(MainData.UNLOCK_LOCK_CROP));
		return param1;
	}

	// MainData.as:608-612/:935-938（profileLoading 存取——setter 派发
	// PROFILE_LOADING）
	public var profileLoading(get, set):Bool;

	private function get_profileLoading():Bool {
		return this._profileLoading;
	}

	private function set_profileLoading(param1:Bool):Bool {
		this._profileLoading = param1;
		dispatchEvent(new ModelEvent(MainData.PROFILE_LOADING));
		return param1;
	}

	// MainData.as:626-629/:940-943（searchFriendValue 存取——原文
	// setter 无派发，纯赋值）
	public var searchFriendValue(get, set):String;

	private function get_searchFriendValue():String {
		return this._searchFriendValue;
	}

	private function set_searchFriendValue(param1:String):String {
		this._searchFriendValue = param1;
		return param1;
	}

	// MainData.as:636-639/:945-949（userHunters 存取——setter 派发
	// USER_HUNTERS）
	public var userHunters(get, set):Array<Dynamic>;

	private function get_userHunters():Array<Dynamic> {
		return this._userHunters;
	}

	private function set_userHunters(param1:Array<Dynamic>):Array<Dynamic> {
		this._userHunters = param1;
		dispatchEvent(new ModelEvent(MainData.USER_HUNTERS));
		return param1;
	}

	// MainData.as:641-645/:951-954（userChanging 存取——setter 派发
	// USER_CHANGING）
	public var userChanging(get, set):Bool;

	private function get_userChanging():Bool {
		return this._userChanging;
	}

	private function set_userChanging(param1:Bool):Bool {
		this._userChanging = param1;
		dispatchEvent(new ModelEvent(MainData.USER_CHANGING));
		return param1;
	}

	// MainData.as:647-650/:1033-1037（shopSeedLoading 存取——setter 派发
	// SHOP_SEED_LOADING）
	public var shopSeedLoading(get, set):Bool;

	private function get_shopSeedLoading():Bool {
		return this._shopSeedLoading;
	}

	private function set_shopSeedLoading(param1:Bool):Bool {
		this._shopSeedLoading = param1;
		dispatchEvent(new ModelEvent(MainData.SHOP_SEED_LOADING));
		return param1;
	}

	// MainData.as:657-660/:1005-1012（houseChangeData 存取——setter 只在
	// 数据真且 f==1 时派发 HOUSE_DATA_CHANGE（Event）。PORT-NOTE(松等)：
	// `_houseChangeData.f == 1` 是 Dynamic==数宽松相等——floatOf 数值化
	// 比较复刻）
	public var houseChangeData(get, set):Dynamic;

	private function get_houseChangeData():Dynamic {
		return this._houseChangeData;
	}

	private function set_houseChangeData(param1:Dynamic):Dynamic {
		this._houseChangeData = param1;
		if (As3.truthy(this._houseChangeData) && As3.floatOf(Reflect.field(this._houseChangeData, "f")) == 1) {
			dispatchEvent(new Event(MainData.HOUSE_DATA_CHANGE));
		}
		return param1;
	}

	// MainData.as:662-665/:1039-1043（setUserError 存取——setter 派发
	// SET_USER_ERROR）
	public var setUserError(get, set):String;

	private function get_setUserError():String {
		return this._setUserError;
	}

	private function set_setUserError(param1:String):String {
		this._setUserError = param1;
		dispatchEvent(new ModelEvent(MainData.SET_USER_ERROR));
		return param1;
	}

	// MainData.as:667-671/:1045-1049（shopSeedErr 存取——setter 派发
	// SHOP_SEED_ERR）
	public var shopSeedErr(get, set):String;

	private function get_shopSeedErr():String {
		return this._shopSeedErr;
	}

	private function set_shopSeedErr(param1:String):String {
		this._shopSeedErr = param1;
		dispatchEvent(new ModelEvent(MainData.SHOP_SEED_ERR));
		return param1;
	}

	// MainData.as:673-676/:1045-1049（seedInfo 存取——setter 派发 SEED_INFO）
	public var seedInfo(get, set):Array<Dynamic>;

	private function get_seedInfo():Array<Dynamic> {
		return this._seedInfo;
	}

	private function set_seedInfo(param1:Array<Dynamic>):Array<Dynamic> {
		this._seedInfo = param1;
		dispatchEvent(new ModelEvent(MainData.SEED_INFO));
		return param1;
	}

	// MainData.as:678-681/:1069-1073（userCubErr 存取——setter 派发
	// USER_CUB_ERR）
	public var userCubErr(get, set):String;

	private function get_userCubErr():String {
		return this._userCubErr;
	}

	private function set_userCubErr(param1:String):String {
		this._userCubErr = param1;
		dispatchEvent(new ModelEvent(MainData.USER_CUB_ERR));
		return param1;
	}

	// MainData.as:683-687（hostLevel：读 host.exp 反解等级写回 _hostLevel
	// 再返。PORT-NOTE(int())：`int(this.host["exp"])` 是 AS3 int 强转
	// （截断）——intOf 复刻；getter 声明 int 而字段 Number，返回再截断
	// （Std.int——expToGrade 已返 Int，值恒整数））
	public var hostLevel(get, never):Int;

	private function get_hostLevel():Int {
		this._hostLevel = this.expToGrade(As3.intOf(Reflect.field(this.host, "exp")));
		return Std.int(this._hostLevel);
	}

	// MainData.as:689-692/:1169-1172（userMCBg 存取——setter 无派发）
	public var userMCBg(get, set):Int;

	private function get_userMCBg():Int {
		return this._userMCBg;
	}

	private function set_userMCBg(param1:Int):Int {
		this._userMCBg = param1;
		return param1;
	}

	// MainData.as:694-697/:1081-1085（shopDiyErr 存取——setter 派发
	// SHOP_DIY_ERR）
	public var shopDiyErr(get, set):String;

	private function get_shopDiyErr():String {
		return this._shopDiyErr;
	}

	private function set_shopDiyErr(param1:String):String {
		this._shopDiyErr = param1;
		dispatchEvent(new ModelEvent(MainData.SHOP_DIY_ERR));
		return param1;
	}

	// MainData.as:699-703/:978-981（welcome 存取——setter 派发 WELCOME）
	public var welcome(get, set):Bool;

	private function get_welcome():Bool {
		return this._welcome;
	}

	private function set_welcome(param1:Bool):Bool {
		this._welcome = param1;
		dispatchEvent(new ModelEvent(MainData.WELCOME));
		return param1;
	}

	// MainData.as:705-708/:999-1003（userItems 存取——setter 派发
	// USER_ITEMS）
	public var userItems(get, set):Array<Dynamic>;

	private function get_userItems():Array<Dynamic> {
		return this._userItems;
	}

	private function set_userItems(param1:Array<Dynamic>):Array<Dynamic> {
		this._userItems = param1;
		dispatchEvent(new ModelEvent(MainData.USER_ITEMS));
		return param1;
	}

	// MainData.as:710-714/:983-986（updateMark 存取——setter 派发
	// MARK_UPDATE，Event）
	public var updateMark(get, set):Dynamic;

	private function get_updateMark():Dynamic {
		return this._upDateMark;
	}

	private function set_updateMark(param1:Dynamic):Dynamic {
		this._upDateMark = param1;
		dispatchEvent(new Event(MainData.MARK_UPDATE));
		return param1;
	}

	// MainData.as:716-719/:1153-1157（userMaterialLoading 存取——setter
	// 派发 USER_MATERIAL_LOADING）
	public var userMaterialLoading(get, set):Bool;

	private function get_userMaterialLoading():Bool {
		return this._userMaterialLoading;
	}

	private function set_userMaterialLoading(param1:Bool):Bool {
		this._userMaterialLoading = param1;
		dispatchEvent(new ModelEvent(MainData.USER_MATERIAL_LOADING));
		return param1;
	}

	// MainData.as:721-724/:1135-1138（UserCrystal 存取——原文大小写即
	// 如此；setter 无派发）
	public var UserCrystal(get, set):Array<Dynamic>;

	private function get_UserCrystal():Array<Dynamic> {
		return this._userCrystal;
	}

	private function set_UserCrystal(param1:Array<Dynamic>):Array<Dynamic> {
		this._userCrystal = param1;
		return param1;
	}

	// MainData.as:726-730/:994-997（diyInfo 存取——setter 派发 DIY_INFO）
	public var diyInfo(get, set):Array<Dynamic>;

	private function get_diyInfo():Array<Dynamic> {
		return this._diyInfo;
	}

	private function set_diyInfo(param1:Array<Dynamic>):Array<Dynamic> {
		this._diyInfo = param1;
		dispatchEvent(new ModelEvent(MainData.DIY_INFO));
		return param1;
	}

	// MainData.as:738-745（原文只读 getter：无 setter）
	public var currentUserUin(get, never):String;

	private function get_currentUserUin():String {
		if (this.currentUser != null) {
			return Reflect.field(this.currentUser, "uin");
		}
		return "";
	}

	// MainData.as:747-750/:1205-1209（shopToolErr 存取——setter 派发
	// SHOP_TOOL_ERR）
	public var shopToolErr(get, set):String;

	private function get_shopToolErr():String {
		return this._shopToolErr;
	}

	private function set_shopToolErr(param1:String):String {
		this._shopToolErr = param1;
		dispatchEvent(new ModelEvent(MainData.SHOP_TOOL_ERR));
		return param1;
	}

	// MainData.as:763-766/:1238-1242（currentUser 存取——setter 派发
	// CURRENT_USER_CHANGE）
	public var currentUser(get, set):Dynamic;

	private function get_currentUser():Dynamic {
		return this._currentUser;
	}

	private function set_currentUser(param1:Dynamic):Dynamic {
		this._currentUser = param1;
		dispatchEvent(new ModelEvent(MainData.CURRENT_USER_CHANGE));
		return param1;
	}

	// MainData.as:768-771/:1374-1378（profileErr 存取——setter 派发
	// PROFILE_ERR）
	public var profileErr(get, set):String;

	private function get_profileErr():String {
		return this._profileErr;
	}

	private function set_profileErr(param1:String):String {
		this._profileErr = param1;
		dispatchEvent(new ModelEvent(MainData.PROFILE_ERR));
		return param1;
	}

	// MainData.as:773-776/:1311-1315（giftPackage 存取——setter 派发
	// GIFT_PACKAGE）
	public var giftPackage(get, set):Dynamic;

	private function get_giftPackage():Dynamic {
		return this._giftPackage;
	}

	private function set_giftPackage(param1:Dynamic):Dynamic {
		this._giftPackage = param1;
		dispatchEvent(new ModelEvent(MainData.GIFT_PACKAGE));
		return param1;
	}

	// MainData.as:783-786/:1343-1347（userCrop 存取——setter 派发 USER_CROP）
	public var userCrop(get, set):Array<Dynamic>;

	private function get_userCrop():Array<Dynamic> {
		return this._userCrop;
	}

	private function set_userCrop(param1:Array<Dynamic>):Array<Dynamic> {
		this._userCrop = param1;
		dispatchEvent(new ModelEvent(MainData.USER_CROP));
		return param1;
	}

	// MainData.as:798-802/:1164-1167（hunter 存取——setter 派发
	// HUNTER_CHANGE，Event）
	public var hunter(get, set):Dynamic;

	private function get_hunter():Dynamic {
		return this._hunter;
	}

	private function set_hunter(param1:Dynamic):Dynamic {
		this._hunter = param1;
		this.dispatchEvent(new Event(MainData.HUNTER_CHANGE));
		return param1;
	}

	// MainData.as:825-832（原文只读 getter：无 setter）
	public var currentUserId(get, never):String;

	private function get_currentUserId():String {
		if (this.currentUser != null) {
			return Reflect.field(this.currentUser, "uId");
		}
		return "";
	}

	// MainData.as:859-885（getAnimalNum 窝/棚容量档位表）
	public function getAnimalNum(param1:Float, param2:String):Float {
		if (param1 >= 8) {
			return 10;
		}
		if (param2 == "窝") {
			if (param1 == 1) {
				return 2;
			}
			if (param1 == 2) {
				return 3;
			}
			if (param1 >= 3) {
				return param1 + 2;
			}
		}
		if (param2 == "棚" && param1 != 0) {
			return param1 + 2;
		}
		return 0;
	}

	// MainData.as:887-891/:1159-1162（shopDiyLoading 存取——setter 派发
	// SHOP_DIY_LOADING）
	public var shopDiyLoading(get, set):Bool;

	private function get_shopDiyLoading():Bool {
		return this._shopDiyLoading;
	}

	private function set_shopDiyLoading(param1:Bool):Bool {
		this._shopDiyLoading = param1;
		dispatchEvent(new ModelEvent(MainData.SHOP_DIY_LOADING));
		return param1;
	}

	// MainData.as:893-896（expToGrade 反解公式——AS3 int 返回类型截断
	// 趋向零，值域非负，Std.int 等价）
	public function expToGrade(param1:UInt):Int {
		return Std.int(Math.sqrt((param1 + 25) / 100) - 0.5);
	}

	// MainData.as:898-905（hostFid：qzone 取 uin，否则 uId）
	public var hostFid(get, never):String;

	private function get_hostFid():String {
		if (Version.value == "qzone") {
			return Reflect.field(this.host, "uin");
		}
		return Reflect.field(this.host, "uId");
	}

	// MainData.as:918-922/:1174-1177（host 存取——setter 派发 HOST_CHANGE）
	public var host(get, set):Dynamic;

	private function get_host():Dynamic {
		return this._host;
	}

	private function set_host(param1:Dynamic):Dynamic {
		this._host = param1;
		dispatchEvent(new ModelEvent(MainData.HOST_CHANGE));
		return param1;
	}

	// MainData.as:930-933/:1179-1182（friendStatusRelate 存取——setter
	// 无派发）
	public var friendStatusRelate(get, set):Dynamic;

	private function get_friendStatusRelate():Dynamic {
		return this._friendStatusRelate;
	}

	private function set_friendStatusRelate(param1:Dynamic):Dynamic {
		this._friendStatusRelate = param1;
		return param1;
	}

	// MainData.as:962-966/:1190-1193（shopToolLoading 存取——setter 派发
	// SHOP_TOOL_LOADING）
	public var shopToolLoading(get, set):Bool;

	private function get_shopToolLoading():Bool {
		return this._shopToolLoading;
	}

	private function set_shopToolLoading(param1:Bool):Bool {
		this._shopToolLoading = param1;
		dispatchEvent(new ModelEvent(MainData.SHOP_TOOL_LOADING));
		return param1;
	}

	// MainData.as:956-960/:1195-1198（profile 存取——setter 派发 PROFILE）
	public var profile(get, set):Dynamic;

	private function get_profile():Dynamic {
		return this._profile;
	}

	private function set_profile(param1:Dynamic):Dynamic {
		this._profile = param1;
		dispatchEvent(new ModelEvent(MainData.PROFILE));
		return param1;
	}

	// MainData.as:973-976（millLimitYDLevel 直读 LocalData.parameters）
	public var millLimitYDLevel(get, never):Float;

	private function get_millLimitYDLevel():Float {
		return Reflect.field(LocalData.parameters, "millLimitYDLevel");
	}

	// MainData.as:988-992/:1200-1203（getFriendListErr 存取——setter 派发
	// GET_FRIEND_LIST_ERR）
	public var getFriendListErr(get, set):String;

	private function get_getFriendListErr():String {
		return this._getFriendListErr;
	}

	private function set_getFriendListErr(param1:String):String {
		this._getFriendListErr = param1;
		dispatchEvent(new ModelEvent(MainData.GET_FRIEND_LIST_ERR));
		return param1;
	}

	// MainData.as:1014-1031（addExp：派发 ADD_EXP 后按升级跨度再派
	// USER_LEVEL_UP（data={preLevel,nowLevel}）。PORT-NOTE(int)：
	// `_loc2_:int = host["exp"] - _addExp` 的 int 赋值是 ToInt32 截断
	// （exp 量级小、int32/intOf 同果，取 intOf 数值化兼字符串形态）；
	// `_loc4_ - _loc3_ > 0` 是 Int 比较）
	public var addExp(get, set):Int;

	private function get_addExp():Int {
		return this._addExp;
	}

	private function set_addExp(param1:Int):Int {
		var _loc5_:ModelEvent = null;
		this._addExp = param1;
		dispatchEvent(new ModelEvent(MainData.ADD_EXP));
		var _loc2_:Int = As3.intOf(As3.floatOf(Reflect.field(this.host, "exp")) - this._addExp);
		var _loc3_:Int = this.expToGrade(_loc2_);
		var _loc4_:Int = this.expToGrade(As3.intOf(Reflect.field(this.host, "exp")));
		if (_loc4_ - _loc3_ > 0) {
			_loc5_ = new ModelEvent(MainData.USER_LEVEL_UP);
			_loc5_.data = {
				"preLevel": _loc3_,
				"nowLevel": _loc4_
			};
			dispatchEvent(_loc5_);
		}
		return param1;
	}

	// MainData.as:1051-1066（uniq：按 uId 去重保序——AS3 对象键字符串化，
	// Reflect 同通道）
	private function uniq(param1:Array<Dynamic>):Array<Dynamic> {
		var _loc2_:Dynamic = {};
		var _loc3_:Array<Dynamic> = [];
		var _loc4_:Int = 0;
		var _loc5_:Int = param1.length;
		while (_loc4_ < _loc5_) {
			var key:String = Std.string(Reflect.field(param1[_loc4_], "uId"));
			if (!As3.truthy(Reflect.field(_loc2_, key))) {
				Reflect.setField(_loc2_, key, 1);
				_loc3_.push(param1[_loc4_]);
			}
			_loc4_++;
		}
		return _loc3_;
	}

	// MainData.as:1075-1079/:1228-1231（userCropLoading 存取——setter
	// 派发 USER_CROP_LOADING）
	public var userCropLoading(get, set):Bool;

	private function get_userCropLoading():Bool {
		return this._userCropLoading;
	}

	private function set_userCropLoading(param1:Bool):Bool {
		this._userCropLoading = param1;
		dispatchEvent(new ModelEvent(MainData.USER_CROP_LOADING));
		return param1;
	}

	// MainData.as:1087-1091/:1223-1226（items 存取——setter 派发 ITEMS）
	public var items(get, set):Dynamic;

	private function get_items():Dynamic {
		return this._items;
	}

	private function set_items(param1:Dynamic):Dynamic {
		this._items = param1;
		dispatchEvent(new ModelEvent(MainData.ITEMS));
		return param1;
	}

	// MainData.as:1093-1133/:1244-1247（animalData 存取——setter：
	// buyTime!=0 的条目按 serial 键回填进 40 槽新表；自家农场（me）时按
	// GetCropID.getHouse 窝/棚计数写回 host.animal1/animal2；派发
	// ANIMAL_CHANGE。PORT-NOTE(Array(40))：AS3 new Array(40) 是 40 槽
	// undefined 预长——迭代表长恒 ≥40 且空洞 falsy 跳过，用 40 个 null
	// 预填等价（arrPut 越界写垫 null 同语义）。PORT-NOTE(松等)：
	// `buyTime != 0` 是宽松不等——floatOf 数值化 != 0 复刻（缺键
	// undefined→NaN≠0 为真、照收，原文怪癖保留））
	public var animalData(get, set):Array<Dynamic>;

	private function get_animalData():Array<Dynamic> {
		return this._animalData;
	}

	private function set_animalData(param1:Array<Dynamic>):Array<Dynamic> {
		var _loc4_:Float = Math.NaN;
		var _loc5_:Float = Math.NaN;
		var _loc2_:Array<Dynamic> = [for (_ in 0...40) null];
		var _loc3_:Int = 0;
		_loc3_ = 0;
		while (_loc3_ < param1.length) {
			if (As3.floatOf(Reflect.field(param1[_loc3_], "buyTime")) != 0) {
				As3.arrPut(_loc2_, As3.intOf(Reflect.field(param1[_loc3_], "serial")), param1[_loc3_]);
			}
			_loc3_++;
		}
		if (this.me) {
			_loc4_ = 0;
			_loc5_ = 0;
			_loc3_ = 0;
			while (_loc3_ < _loc2_.length) {
				if (As3.truthy(_loc2_[_loc3_])) {
					if (GetCropID.getHouse(Reflect.field(_loc2_[_loc3_], "cId")) == "窝") {
						_loc4_++;
					} else {
						_loc5_++;
					}
				}
				_loc3_++;
			}
			Reflect.setField(this.host, "animal1", _loc4_);
			Reflect.setField(this.host, "animal2", _loc5_);
		}
		this._animalData = _loc2_;
		dispatchEvent(new ModelEvent(MainData.ANIMAL_CHANGE));
		return param1;
	}

	// MainData.as:1140-1151（原文只读 getter：无 setter。
	// PORT-NOTE(宽松!=)：uId 同源同型（profile JSON 字串），裸比等价）
	public var me(get, never):Bool;

	private function get_me():Bool {
		var _loc1_:Bool = true;
		if (this.currentUser != null && this.host != null) {
			if (Reflect.field(this.currentUser, "uId") != Reflect.field(this.host, "uId")) {
				_loc1_ = false;
			}
		}
		return _loc1_;
	}

	// MainData.as:1184-1188/:1258-1261（levelReward 存取——setter 派发
	// LEVEL_REWARD）
	public var levelReward(get, set):Dynamic;

	private function get_levelReward():Dynamic {
		return this._levelReward;
	}

	private function set_levelReward(param1:Dynamic):Dynamic {
		this._levelReward = param1;
		dispatchEvent(new ModelEvent(MainData.LEVEL_REWARD));
		return param1;
	}

	// MainData.as:1211-1215（userName 正则过滤）
	private function friendFilter(param1:Dynamic, param2:Int, param3:Array<Dynamic>):Bool {
		var _loc4_:String = Reflect.field(param1, "userName");
		return new EReg(".*?" + this.searchFriendValue + ".*", "i").match(_loc4_);
	}

	// MainData.as:1217-1221/:1289-1292（userItemLoading 存取——setter
	// 派发 USER_ITEM_LOADING）
	public var userItemLoading(get, set):Bool;

	private function get_userItemLoading():Bool {
		return this._userItemLoading;
	}

	private function set_userItemLoading(param1:Bool):Bool {
		this._userItemLoading = param1;
		dispatchEvent(new ModelEvent(MainData.USER_ITEM_LOADING));
		return param1;
	}

	// MainData.as:1249-1256（currentFid：qzone 取 currentUserUin，
	// 否则 currentUserId）
	public var currentFid(get, never):String;

	private function get_currentFid():String {
		if (Version.value == "qzone") {
			return this.currentUserUin;
		}
		return this.currentUserId;
	}

	// MainData.as:1263-1266/:1306-1309（userFarmData 存取——setter 无派发）
	public var userFarmData(get, set):Dynamic;

	private function get_userFarmData():Dynamic {
		return this._userFarmData;
	}

	private function set_userFarmData(param1:Dynamic):Dynamic {
		this._userFarmData = param1;
		return param1;
	}

	// MainData.as:1268-1275（原文只读 getter：无 setter）
	public var getHostId(get, never):String;

	private function get_getHostId():String {
		if (this.host != null) {
			return Reflect.field(this.host, "uId");
		}
		return "";
	}

	// MainData.as:1277-1281/:1317-1320（mpData 存取——setter 派发
	// MPScene.OPEN_MAOPAO，Event）
	public var mpData(get, set):Dynamic;

	private function get_mpData():Dynamic {
		return this._mpdata;
	}

	private function set_mpData(param1:Dynamic):Dynamic {
		this._mpdata = param1;
		dispatchEvent(new Event(MPScene.OPEN_MAOPAO));
		return param1;
	}

	// MainData.as:1283-1287/:1359-1362（sessionTimeout 存取——setter
	// 派发 SESSION_TIMEOUT）
	public var sessionTimeout(get, set):String;

	private function get_sessionTimeout():String {
		return this._sessionTimeout;
	}

	private function set_sessionTimeout(param1:String):String {
		this._sessionTimeout = param1;
		dispatchEvent(new ModelEvent(MainData.SESSION_TIMEOUT));
		return param1;
	}

	// MainData.as:1294-1298/:1328-1331（userMaterialErr 存取——setter
	// 派发 USER_MATERIAL_ERR）
	public var userMaterialErr(get, set):String;

	private function get_userMaterialErr():String {
		return this._userMaterialErr;
	}

	private function set_userMaterialErr(param1:String):String {
		this._userMaterialErr = param1;
		dispatchEvent(new ModelEvent(MainData.USER_MATERIAL_ERR));
		return param1;
	}

	// MainData.as:1300-1304/:1364-1367（weather 存取——setter 派发 WEATHER）
	public var weather(get, set):String;

	private function get_weather():String {
		return this._weather;
	}

	private function set_weather(param1:String):String {
		this._weather = param1;
		dispatchEvent(new ModelEvent(MainData.WEATHER));
		return param1;
	}

	// MainData.as:1333-1341（filterFriendList：userName 过滤 + qzone 追加
	// uin 过滤 + uniq 去重。PORT-NOTE(filter 回调)：AS3 filter 回调三参
	// (item,index,array)，Haxe filter 单参——回调体只用 item，包装转发
	// 等价（下标/数组两参原文未读））
	public var filterFriendList(get, never):Array<Dynamic>;

	private function get_filterFriendList():Array<Dynamic> {
		var self = this;
		var _loc1_:Array<Dynamic> = this.friendList.filter(function(item:Dynamic):Bool {
			return self.friendFilter(item, 0, null);
		});
		if (Version.value == Version.QZONE) {
			_loc1_ = _loc1_.concat(this.friendList.filter(function(item:Dynamic):Bool {
				return self.friendFilterByUin(item, 0, null);
			}));
		}
		return this.uniq(_loc1_);
	}

	// MainData.as:1349-1352/:1369-1372（sortField 存取——setter 无派发）
	public var sortField(get, set):String;

	private function get_sortField():String {
		return this._sortField;
	}

	private function set_sortField(param1:String):String {
		this._sortField = param1;
		return param1;
	}

	// MainData.as:1354-1357（friendPageNum 恒 10）
	public var friendPageNum(get, never):Int;

	private function get_friendPageNum():Int {
		return 10;
	}
}
