package mc.model;

import openfl.events.EventDispatcher;

/**
 * mc.model.FarmData —— FarmData.as 的签名面 stub（原类 258 loc，issue #87
 * 「数据」片充真身；issue #19 仅作为 MData.farmData 的返回类型被引用）。
 * 成员签名逐字取自反编译原文，方法体随 implement 充真身。
 * legacy/decompiled/Master2_v_142/scripts/mc/model/FarmData.as。
 */
@:keep
class FarmData extends EventDispatcher {
	// FarmData.as:9-13（静态位）
	public static var feedAnimalReturn:Dynamic;
	public static var sFeedTotalError:String;
	public static var feedAnimalSerial:Float;

	// FarmData.as:15-67（事件名与动物状态常量——原文 AS3 是 Number，
	// 静态目标 null-Int 坑不涉（常量有初值），按 Int 落）
	public static final USER_SEED:String = "userSeedChange";
	public static final USER_SEED_LOADING:String = "userSeedLoading";
	public static final FARM_OPERATE:String = "farmOperate";
	public static final HARVEST_DATA:String = "harvestData";
	public static final ADD_HEALTH:String = "addHealth";
	public static final USER_SEED_ERR:String = "userSeedErr";
	public static final ANIMAL_FOOD:String = "animalFoodChange";
	public static final PACKAGE_FOOD:String = "pack_age_food";
	public static final ACTIVITY_ITEMS:String = "activityItemsChange";
	public static final FLY_DATA_CHANGE:String = "fly_data_change";
	public static final BB_DATA_CHANGE:String = "bb_data_change";
	public static final INSECT_KILL:String = "insect_kill";
	public static final CLEAR_BB:String = "clear_bb_pos";
	public static final ENEMY_CHANGE:String = "enemy_change";
	public static final ANIMAL_YOUZAI:Int = 1;
	public static final ANIMAL_SHENGZHANG:Int = 2;
	public static final ANIMAL_DAICHAN:Int = 3;
	public static final ANIMAL_SHENGCHAN:Int = 4;
	public static final ANIMAL_CHANHOU:Int = 5;
	public static final ANIMAL_SHOUHUO:Int = 6;
	public static final BEAT_ANIMAL:String = "beat_animal";
	public static final USE_ANIMAL_CUB:String = "USE_ANIMAL_CUB";

	// FarmData.as:39-47
	public static var maxFly:Bool = false;
	public static var maxErrInfo:String = "每天最多使坏25次";
	public static var leftFly:Float = -1;
	public static var totalExp:Bool = false;
	public static var totalBB:Bool = false;

	// FarmData.as:69-97（backing）
	private var _userSeedLoading:Bool = false;
	public var activityItemsLoading:Bool = false;
	private var _insectExp:Dynamic;
	private var _animalFood:Int;
	private var _bbData:Dynamic = {};
	private var _farmOperate:Dynamic;
	private var _userSeedErr:String = "";
	private var _reloadUserSeed:Bool = true;
	private var _userSeed:Array<Dynamic>;
	private var _animalPackFood:Dynamic;
	public var reloadActivityItems:Bool = true;
	private var _activityItems:Array<Dynamic>;
	private var _harvestData:Dynamic;
	private var _clearBBPos:Float;
	private var _flyData:Dynamic;

	// FarmData.as:99-102
	public function new() {
		super();
	}

	// FarmData.as:156-161（killFly：flyNum<idx> 与 num 双扣 + 派发）
	public function killFly(param1:Float, param2:Float):Void {
		throw new openfl.errors.Error("not implemented");
	}

	// FarmData.as:110-113/:251-255（animalFood 存取——setter 派发 ANIMAL_FOOD）
	public var animalFood(get, set):Int;

	private function get_animalFood():Int {
		return this._animalFood;
	}

	private function set_animalFood(param1:Int):Int {
		throw new openfl.errors.Error("not implemented");
	}

	// FarmData.as:115-118/:126-130（bbData 存取——setter 派发 BB_DATA_CHANGE）
	public var bbData(get, set):Dynamic;

	private function get_bbData():Dynamic {
		return this._bbData;
	}

	private function set_bbData(param1:Dynamic):Dynamic {
		throw new openfl.errors.Error("not implemented");
	}

	// FarmData.as:120-124/:190-193（clearBBPos 存取——setter 派发 CLEAR_BB）
	public var clearBBPos(get, set):Float;

	private function get_clearBBPos():Float {
		return this._clearBBPos;
	}

	private function set_clearBBPos(param1:Float):Float {
		throw new openfl.errors.Error("not implemented");
	}

	// FarmData.as:132-135/:169-173（insectExp 存取——setter 派发 INSECT_KILL）
	public var insectExp(get, set):Dynamic;

	private function get_insectExp():Dynamic {
		return this._insectExp;
	}

	private function set_insectExp(param1:Dynamic):Dynamic {
		throw new openfl.errors.Error("not implemented");
	}

	// FarmData.as:137-149（reloadUserSeed——true 时派发 "reloadUserSeed"）
	public var reloadUserSeed(get, set):Bool;

	private function get_reloadUserSeed():Bool {
		return this._reloadUserSeed;
	}

	private function set_reloadUserSeed(param1:Bool):Bool {
		throw new openfl.errors.Error("not implemented");
	}

	// FarmData.as:151-154/:218-222（animalPackFood 存取——setter 派发
	// PACKAGE_FOOD）
	public var animalPackFood(get, set):Dynamic;

	private function get_animalPackFood():Dynamic {
		return this._animalPackFood;
	}

	private function set_animalPackFood(param1:Dynamic):Dynamic {
		throw new openfl.errors.Error("not implemented");
	}

	// FarmData.as:163-167/:201-204（userSeed 存取——setter 派发 USER_SEED）
	public var userSeed(get, set):Array<Dynamic>;

	private function get_userSeed():Array<Dynamic> {
		return this._userSeed;
	}

	private function set_userSeed(param1:Array<Dynamic>):Array<Dynamic> {
		throw new openfl.errors.Error("not implemented");
	}

	// FarmData.as:175-178/:229-233（harvestData 存取——setter 派发
	// HARVEST_DATA）
	public var harvestData(get, set):Dynamic;

	private function get_harvestData():Dynamic {
		return this._harvestData;
	}

	private function set_harvestData(param1:Dynamic):Dynamic {
		throw new openfl.errors.Error("not implemented");
	}

	// FarmData.as:180-183/:245-249（flyData 存取——setter 派发
	// FLY_DATA_CHANGE）
	public var flyData(get, set):Dynamic;

	private function get_flyData():Dynamic {
		return this._flyData;
	}

	private function set_flyData(param1:Dynamic):Dynamic {
		throw new openfl.errors.Error("not implemented");
	}

	// FarmData.as:185-188/:104-108（userSeedLoading 存取——setter 派发
	// USER_SEED_LOADING）
	public var userSeedLoading(get, set):Bool;

	private function get_userSeedLoading():Bool {
		return this._userSeedLoading;
	}

	private function set_userSeedLoading(param1:Bool):Bool {
		throw new openfl.errors.Error("not implemented");
	}

	// FarmData.as:195-199/:224-227（userSeedErr 存取——setter 派发
	// USER_SEED_ERR）
	public var userSeedErr(get, set):String;

	private function get_userSeedErr():String {
		return this._userSeedErr;
	}

	private function set_userSeedErr(param1:String):String {
		throw new openfl.errors.Error("not implemented");
	}

	// FarmData.as:206-210/:240-243（activityItems 存取——setter 派发
	// ACTIVITY_ITEMS）
	public var activityItems(get, set):Array<Dynamic>;

	private function get_activityItems():Array<Dynamic> {
		return this._activityItems;
	}

	private function set_activityItems(param1:Array<Dynamic>):Array<Dynamic> {
		throw new openfl.errors.Error("not implemented");
	}

	// FarmData.as:212-216/:235-238（farmOperate 存取——setter 派发
	// FARM_OPERATE）
	public var farmOperate(get, set):Dynamic;

	private function get_farmOperate():Dynamic {
		return this._farmOperate;
	}

	private function set_farmOperate(param1:Dynamic):Dynamic {
		throw new openfl.errors.Error("not implemented");
	}
}
