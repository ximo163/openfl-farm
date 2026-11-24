package wild.com.Shell
{
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.IEventDispatcher;
   import flash.filters.ColorMatrixFilter;
   import flash.filters.GlowFilter;
   import wild.com.Shell.business.analyzer.setup.ParserBeast;
   import wild.com.Shell.command.CmdSetup;
   import wild.com.Shell.model.beast.BeastBase;
   import wild.com.Shell.model.beast.BeastInfo;
   
   public class DataShell extends EventDispatcher
   {
      
      public static var InIData:XML;
      
      private static var _instance:DataShell;
      
      private static var _parser:ParserBeast;
      
      public static const ANIMAL_CHANGE:String = "animal_change";
      
      public static const ANIMAL_UPDATE:String = "animal_update";
      
      public static const NICK_CHANGE:String = "nick_change";
      
      public static const REWARD_CHANGE:String = "reward_change";
      
      public static var sceneLoaded:int = 0;
      
      public static var toolLoaded:int = 0;
      
      public static const STATUS:Array = ["无动物","可放养","放养中","已返回","休息中","可捐赠","昏迷"];
      
      private var _nickList:Object = {};
      
      private var _data:BeastBase;
      
      private var _updateAnimals:BeastInfo;
      
      public function DataShell(param1:IEventDispatcher = null)
      {
         super(param1);
      }
      
      public static function get rollOverFilter() : Array
      {
         var _loc1_:Array = new Array();
         _loc1_ = _loc1_.concat([1.1,0,0,0,0]);
         _loc1_ = _loc1_.concat([0,1.1,0,0,0]);
         _loc1_ = _loc1_.concat([0,0,1.1,0,0]);
         _loc1_ = _loc1_.concat([0,0,0,1,0]);
         return [new GlowFilter(13434624,1,10,10),new ColorMatrixFilter(_loc1_)];
      }
      
      public static function getInstance() : DataShell
      {
         if(!_instance)
         {
            _instance = new DataShell();
         }
         return _instance;
      }
      
      public static function getShowYellow(param1:String) : XML
      {
         var type:String = param1;
         return InIData.weapon.info.(@name == type)[0];
      }
      
      public static function getAnimalInfo(param1:String) : XML
      {
         var type:String = param1;
         return InIData.beast.info.(@id == type)[0];
      }
      
      public static function getYellowTip() : XML
      {
         if(InIData.weapon[0] == null)
         {
            return null;
         }
         return InIData.weapon[0];
      }
      
      public static function getAnimalName(param1:String) : String
      {
         var type:String = param1;
         return InIData.beast.info.(@id == type).@name;
      }
      
      public static function getWeaponInfo(param1:String) : XML
      {
         var type:String = param1;
         return InIData.weapon.info.(@id == type)[0];
      }
      
      public static function formatString(param1:String) : String
      {
         var _loc2_:RegExp = null;
         var _loc3_:RegExp = null;
         var _loc4_:RegExp = null;
         if(param1.indexOf("<") != -1 || param1.indexOf(">") != -1)
         {
            _loc2_ = /&/g;
            param1 = param1.replace(_loc2_,"&amp;");
            _loc3_ = /</g;
            param1 = param1.replace(_loc3_,"&lt;");
            _loc4_ = />/g;
            param1 = param1.replace(_loc4_,"&gt;");
         }
         return param1;
      }
      
      public static function analyzerData(param1:Object, param2:Boolean = true) : BeastBase
      {
         if(!_parser)
         {
            _parser = new ParserBeast();
         }
         var _loc3_:BeastBase = _parser.parse(param1) as BeastBase;
         return CmdSetup.getInstance().checkUpdate(_loc3_,param2);
      }
      
      public static function getDropInfo(param1:String) : XML
      {
         var type:String = param1;
         return InIData.crystal.info.(@id == type)[0];
      }
      
      public function addNickList(param1:String, param2:Object) : void
      {
         this._nickList[param1] = param2;
         dispatchEvent(new Event(DataShell.NICK_CHANGE));
      }
      
      public function getNickData(param1:String, param2:String) : Object
      {
         var _loc3_:Array = this._nickList[param1];
         if(!_loc3_)
         {
            return null;
         }
         var _loc4_:int = 0;
         while(_loc4_ < _loc3_.length)
         {
            if(_loc3_[_loc4_]["fid"] == param2)
            {
               return _loc3_[_loc4_];
            }
            _loc4_++;
         }
         return null;
      }
      
      public function get updateAnimal() : BeastInfo
      {
         return this._updateAnimals;
      }
      
      public function get data() : BeastBase
      {
         return this._data;
      }
      
      public function deleteNick(param1:String) : void
      {
         if(this._nickList[param1])
         {
            delete this._nickList[param1];
         }
      }
      
      public function set updateAnimal(param1:BeastInfo) : void
      {
         this._updateAnimals = param1;
         dispatchEvent(new Event(DataShell.ANIMAL_UPDATE));
      }
      
      public function set data(param1:BeastBase) : void
      {
         this._data = param1;
      }
      
      public function set animals(param1:BeastInfo) : void
      {
         this._data.info = param1;
         dispatchEvent(new Event(DataShell.ANIMAL_CHANGE));
      }
      
      public function get animalReturan() : Array
      {
         return this._data.bReturn;
      }
      
      public function get animals() : BeastInfo
      {
         return this._data.info;
      }
      
      public function get crystals() : Array
      {
         return this._data.drop;
      }
   }
}

