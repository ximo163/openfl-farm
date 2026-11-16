package mc.model
{
   import flash.events.Event;
   import flash.events.EventDispatcher;
   
   public class FarmData extends EventDispatcher
   {
      
      public static var feedAnimalReturn:Object;
      
      public static var sFeedTotalError:String;
      
      public static var feedAnimalSerial:Number;
      
      public static const USER_SEED:String = "userSeedChange";
      
      public static const USER_SEED_LOADING:String = "userSeedLoading";
      
      public static const FARM_OPERATE:String = "farmOperate";
      
      public static const HARVEST_DATA:String = "harvestData";
      
      public static const ADD_HEALTH:String = "addHealth";
      
      public static const USER_SEED_ERR:String = "userSeedErr";
      
      public static const ANIMAL_FOOD:String = "animalFoodChange";
      
      public static const PACKAGE_FOOD:String = "pack_age_food";
      
      public static const ACTIVITY_ITEMS:String = "activityItemsChange";
      
      public static const FLY_DATA_CHANGE:String = "fly_data_change";
      
      public static const BB_DATA_CHANGE:String = "bb_data_change";
      
      public static const INSECT_KILL:String = "insect_kill";
      
      public static var maxFly:Boolean = false;
      
      public static var maxErrInfo:String = "每天最多使坏25次";
      
      public static var leftFly:Number = -1;
      
      public static var totalExp:Boolean = false;
      
      public static var totalBB:Boolean = false;
      
      public static const CLEAR_BB:String = "clear_bb_pos";
      
      public static const ENEMY_CHANGE:String = "enemy_change";
      
      public static const ANIMAL_YOUZAI:Number = 1;
      
      public static const ANIMAL_SHENGZHANG:Number = 2;
      
      public static const ANIMAL_DAICHAN:Number = 3;
      
      public static const ANIMAL_SHENGCHAN:Number = 4;
      
      public static const ANIMAL_CHANHOU:Number = 5;
      
      public static const ANIMAL_SHOUHUO:Number = 6;
      
      public static const BEAT_ANIMAL:String = "beat_animal";
      
      public static const USE_ANIMAL_CUB:String = "USE_ANIMAL_CUB";
      
      private var _userSeedLoading:Boolean = false;
      
      public var activityItemsLoading:Boolean = false;
      
      private var _insectExp:Object;
      
      private var _animalFood:int;
      
      private var _bbData:Object = {};
      
      private var _farmOperate:Object;
      
      private var _userSeedErr:String = "";
      
      private var _reloadUserSeed:Boolean = true;
      
      private var _userSeed:Array;
      
      private var _animalPackFood:Object;
      
      public var reloadActivityItems:Boolean = true;
      
      private var _activityItems:Array;
      
      private var _harvestData:Object;
      
      private var _clearBBPos:Number;
      
      private var _flyData:Object;
      
      public function FarmData()
      {
         super();
      }
      
      public function set userSeedLoading(param1:Boolean) : void
      {
         this._userSeedLoading = param1;
         dispatchEvent(new ModelEvent(FarmData.USER_SEED_LOADING));
      }
      
      public function get animalFood() : int
      {
         return this._animalFood;
      }
      
      public function get bbData() : Object
      {
         return this._bbData;
      }
      
      public function set clearBBPos(param1:Number) : void
      {
         this._clearBBPos = param1;
         dispatchEvent(new Event(FarmData.CLEAR_BB));
      }
      
      public function set bbData(param1:Object) : void
      {
         this._bbData = param1;
         dispatchEvent(new Event(FarmData.BB_DATA_CHANGE));
      }
      
      public function get insectExp() : Object
      {
         return this._insectExp;
      }
      
      public function get reloadUserSeed() : Boolean
      {
         return this._reloadUserSeed;
      }
      
      public function set reloadUserSeed(param1:Boolean) : void
      {
         this._reloadUserSeed = param1;
         if(param1)
         {
            dispatchEvent(new Event("reloadUserSeed"));
         }
      }
      
      public function get animalPackFood() : Object
      {
         return this._animalPackFood;
      }
      
      public function killFly(param1:Number, param2:Number) : void
      {
         this._flyData["flyNum" + param1] -= param2;
         this._flyData["num"] -= param2;
         dispatchEvent(new Event(FarmData.FLY_DATA_CHANGE));
      }
      
      public function set userSeed(param1:Array) : void
      {
         this._userSeed = param1;
         dispatchEvent(new ModelEvent(FarmData.USER_SEED));
      }
      
      public function set insectExp(param1:Object) : void
      {
         this._insectExp = param1;
         dispatchEvent(new Event(FarmData.INSECT_KILL));
      }
      
      public function get harvestData() : Object
      {
         return this._harvestData;
      }
      
      public function get flyData() : Object
      {
         return this._flyData;
      }
      
      public function get userSeedLoading() : Boolean
      {
         return this._userSeedLoading;
      }
      
      public function get clearBBPos() : Number
      {
         return this._clearBBPos;
      }
      
      public function set userSeedErr(param1:String) : void
      {
         this._userSeedErr = param1;
         dispatchEvent(new ModelEvent(FarmData.USER_SEED_ERR));
      }
      
      public function get userSeed() : Array
      {
         return this._userSeed;
      }
      
      public function set activityItems(param1:Array) : void
      {
         this._activityItems = param1;
         dispatchEvent(new ModelEvent(FarmData.ACTIVITY_ITEMS));
      }
      
      public function set farmOperate(param1:Object) : void
      {
         this._farmOperate = param1;
         dispatchEvent(new ModelEvent(FarmData.FARM_OPERATE));
      }
      
      public function set animalPackFood(param1:Object) : void
      {
         this._animalPackFood = param1;
         dispatchEvent(new ModelEvent(FarmData.PACKAGE_FOOD));
      }
      
      public function get userSeedErr() : String
      {
         return this._userSeedErr;
      }
      
      public function set harvestData(param1:Object) : void
      {
         this._harvestData = param1;
         dispatchEvent(new ModelEvent(FarmData.HARVEST_DATA));
      }
      
      public function get farmOperate() : Object
      {
         return this._farmOperate;
      }
      
      public function get activityItems() : Array
      {
         return this._activityItems;
      }
      
      public function set flyData(param1:Object) : void
      {
         this._flyData = param1;
         dispatchEvent(new Event(FarmData.FLY_DATA_CHANGE));
      }
      
      public function set animalFood(param1:int) : void
      {
         this._animalFood = param1;
         dispatchEvent(new ModelEvent(FarmData.ANIMAL_FOOD));
      }
   }
}

