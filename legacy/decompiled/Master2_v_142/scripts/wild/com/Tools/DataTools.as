package wild.com.Tools
{
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.IEventDispatcher;
   import wild.com.Shell.DataShell;
   import wild.com.Shell.command.CmdAPI;
   
   public class DataTools extends EventDispatcher
   {
      
      private static var instance:DataTools;
      
      public static var InIData:XML;
      
      public static const SLOTID:String = "maxslotid";
      
      public static const SLOT_ERROR:String = "slot_error";
      
      public static const SLOTING:String = "sloting";
      
      public static const GET_SLOT:String = "get_slot";
      
      public static const GET_MORALEXP:String = "get_moralexp";
      
      public static const STATUS:Array = ["无动物","可放养","放养中","已返回","休息中","可捐赠","昏迷"];
      
      public static const GET_WILDANIMALS:String = "get_wildanimals";
      
      public static var MaxSlot:int = 3;
      
      public static var RewardList:Array = [];
      
      public static var SelectedSlot:int = 0;
      
      private var _slotIng:Boolean;
      
      private var _wildAnimals:Array;
      
      private var _maxslotid:Number = 0;
      
      private var _moralexp:int;
      
      private var _hasReward:String;
      
      private var _slotError:String;
      
      private var _canReleaseNum:int;
      
      private var _beastSlot:Array;
      
      public function DataTools(param1:IEventDispatcher = null)
      {
         super(param1);
      }
      
      public static function getInstance() : DataTools
      {
         if(!instance)
         {
            instance = new DataTools();
         }
         return instance;
      }
      
      public function set maxslotid(param1:int) : void
      {
         this._maxslotid = param1;
         dispatchEvent(new Event(DataTools.SLOTID));
      }
      
      public function get slotIng() : Boolean
      {
         return this._slotIng;
      }
      
      public function get slotErr() : String
      {
         return this._slotError;
      }
      
      public function set slotIng(param1:Boolean) : void
      {
         this._slotIng = param1;
         dispatchEvent(new Event(DataTools.SLOTING));
      }
      
      public function get moralexp() : int
      {
         return this._moralexp;
      }
      
      public function set moralexp(param1:int) : void
      {
         this._moralexp = param1;
         dispatchEvent(new Event(DataTools.GET_MORALEXP));
      }
      
      public function get beastSlot() : Array
      {
         return this._beastSlot;
      }
      
      public function get wildAnimals() : Array
      {
         return this._wildAnimals;
      }
      
      public function set hasReward(param1:String) : void
      {
         this._hasReward = param1;
         dispatchEvent(new Event(DataShell.REWARD_CHANGE));
      }
      
      public function set slotErr(param1:String) : void
      {
         this._slotError = param1;
         dispatchEvent(new Event(DataTools.SLOT_ERROR));
      }
      
      public function set wildAnimals(param1:Array) : void
      {
         this._wildAnimals = param1;
         dispatchEvent(new Event(DataTools.GET_WILDANIMALS));
      }
      
      public function set canReleaseNum(param1:int) : void
      {
         this._canReleaseNum = param1;
         var _loc2_:EvtAPI = new EvtAPI("canReleaseNum");
         _loc2_.data = {"value":param1};
         CmdAPI.getInstance().dispatchEvent(_loc2_);
      }
      
      public function get hasReward() : String
      {
         return this._hasReward;
      }
      
      public function get canReleaseNum() : int
      {
         return this._canReleaseNum;
      }
      
      public function set beastSlot(param1:Array) : void
      {
         this._beastSlot = param1;
         dispatchEvent(new Event(DataTools.GET_SLOT));
      }
      
      public function get maxslotid() : int
      {
         return this._maxslotid;
      }
   }
}

