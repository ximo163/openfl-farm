package wild.com.Scene
{
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.IEventDispatcher;
   
   public class DataScene extends EventDispatcher
   {
      
      public static var InIData:XML;
      
      private static var _instance:DataScene;
      
      public static const ATTACK_TYPE:Object = {
         "Fight":1,
         "Dog":2,
         "Hunter":4,
         "Gun":8
      };
      
      public static const ANIMAL_CHANGE:String = "manimal_change";
      
      public static const ATTACK_ACTION:String = "attack_action";
      
      public static const WEAPONS_CHANGE:String = "get_weapons";
      
      public static const WEAPONS_LOADING:String = "weapons_loading";
      
      public static const WEAPONS_ERROR:String = "weapons_errror";
      
      public static const REWARD_CHANGE:String = "reward_change";
      
      public static const CRYSTAL_CHANGE:String = "crystal_change";
      
      public static const CRYSTAL_LOADING:String = "crystal_loading";
      
      public static const CRYSTAL_ERROR:String = "crystal_errror";
      
      public static const ATTACK_DROPS_CHANGE:String = "attack_drops_change";
      
      public static const ATTACK_DROPS_ADD:String = "attack_drops_add";
      
      public static const PICK_RETURN:String = "pick_return";
      
      public static var RewardList:Array = [];
      
      public static var attackReturnList:Array = [];
      
      public static var loadingMaterial:Boolean = true;
      
      public var attackWeapon:int = 0;
      
      private var _weaponsLoading:Boolean;
      
      private var _weapons:Array;
      
      private var _attacType:String;
      
      private var _farmAnimals:Array = [];
      
      private var _hasReward:Boolean = false;
      
      private var _attackFail:Boolean = false;
      
      private var _weaponsErr:String;
      
      private var _addDrops:Array;
      
      private var _drops:Array = [];
      
      private var _pickReturnIndex:int;
      
      public function DataScene(param1:IEventDispatcher = null)
      {
         super(param1);
      }
      
      public static function getInstance() : DataScene
      {
         if(!_instance)
         {
            _instance = new DataScene();
         }
         return _instance;
      }
      
      public function set pickReturnIndex(param1:int) : void
      {
         this._pickReturnIndex = param1;
         dispatchEvent(new Event(DataScene.PICK_RETURN));
      }
      
      public function get addDrops() : Array
      {
         return this._addDrops;
      }
      
      public function get attackFail() : Boolean
      {
         return this._attackFail;
      }
      
      public function set weaponsLoading(param1:Boolean) : void
      {
         this._weaponsLoading = param1;
         dispatchEvent(new Event(DataScene.WEAPONS_LOADING));
      }
      
      public function set attackFail(param1:Boolean) : void
      {
         this._attackFail = param1;
      }
      
      public function set addDrops(param1:Array) : void
      {
         if(param1)
         {
            this._drops = this._drops.concat(param1);
            this._addDrops = param1;
            dispatchEvent(new Event(DataScene.ATTACK_DROPS_ADD));
         }
      }
      
      public function get weaponsErr() : String
      {
         return this._weaponsErr;
      }
      
      public function set hasReward(param1:Boolean) : void
      {
         this._hasReward = param1;
         dispatchEvent(new Event(DataScene.REWARD_CHANGE));
      }
      
      public function get weapons() : Array
      {
         return this._weapons;
      }
      
      public function set weaponsErr(param1:String) : void
      {
         this._weaponsErr = param1;
         dispatchEvent(new Event(DataScene.WEAPONS_ERROR));
      }
      
      public function set drops(param1:Array) : void
      {
         if(param1)
         {
            this._drops = param1;
            dispatchEvent(new Event(DataScene.ATTACK_DROPS_CHANGE));
         }
      }
      
      public function get pickReturnIndex() : int
      {
         return this._pickReturnIndex;
      }
      
      public function get drops() : Array
      {
         return this._drops;
      }
      
      public function get weaponsLoading() : Boolean
      {
         return this._weaponsLoading;
      }
      
      public function set attackType(param1:String) : void
      {
         this._attacType = param1;
         dispatchEvent(new Event(DataScene.ATTACK_ACTION));
      }
      
      public function get attackType() : String
      {
         return this._attacType;
      }
      
      public function set animals(param1:Array) : void
      {
         this._farmAnimals = param1;
         dispatchEvent(new Event(DataScene.ANIMAL_CHANGE));
      }
      
      public function set weapons(param1:Array) : void
      {
         this._weapons = param1;
         dispatchEvent(new Event(DataScene.WEAPONS_CHANGE));
      }
      
      public function get animals() : Array
      {
         return this._farmAnimals;
      }
      
      public function get hasReward() : Boolean
      {
         return this._hasReward;
      }
   }
}

