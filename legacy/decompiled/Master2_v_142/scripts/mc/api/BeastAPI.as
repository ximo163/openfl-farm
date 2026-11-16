package mc.api
{
   import flash.display.*;
   import flash.events.Event;
   import flash.utils.getDefinitionByName;
   import mc.control.ViewControl;
   import mc.model.MainData;
   import mc.model.OpenControl;
   import mc.view.common.Tool_Wild;
   import mc.view.farm.GetCropID;
   
   public class BeastAPI extends McAPI implements IBeastAPI
   {
      
      private static var instance:BeastAPI;
      
      public static const FARM_STAGE:String = "wild_show_farmstage";
      
      public static const WILD_STAGE:String = "wild_show_wildstage";
      
      private var _beastBaseData:Object;
      
      private var _animalContainer:DisplayObjectContainer;
      
      private var _wildStageContainer:DisplayObjectContainer;
      
      private var _wildToolBarContainer:DisplayObjectContainer;
      
      private var _configUrl:String;
      
      private var _beastPackContainer:DisplayObjectContainer;
      
      public function BeastAPI()
      {
         super();
      }
      
      public static function get cmdSetupClassObj() : Object
      {
         var _loc1_:String = "wild.com.Shell.command.CmdSetup";
         var _loc2_:Class = getDefinitionByName(_loc1_) as Class;
         return _loc2_.getInstance();
      }
      
      public static function getInstance() : BeastAPI
      {
         if(instance == null)
         {
            instance = new BeastAPI();
         }
         return instance;
      }
      
      public function openControlisOpen(param1:String) : Boolean
      {
         return OpenControl.open(param1);
      }
      
      public function set canReleaseWildNum(param1:int) : void
      {
         Tool_Wild._canReleaseNum = param1;
      }
      
      public function showReward(param1:String) : void
      {
         var _loc2_:EvtAPI = new EvtAPI(EvtAPI.REWARD_CHANGE);
         _loc2_.data = param1;
         dispatchEvent(_loc2_);
      }
      
      public function get wildStageContainer() : DisplayObjectContainer
      {
         return this._wildStageContainer;
      }
      
      public function set beastPackContainer(param1:DisplayObjectContainer) : void
      {
         this._beastPackContainer = param1;
      }
      
      public function set wildStageContainer(param1:DisplayObjectContainer) : void
      {
         this._wildStageContainer = param1;
      }
      
      public function getAnimalURL(param1:String, param2:int) : String
      {
         return GetCropID.getAnimalURL(param1,param2);
      }
      
      public function get isDogHungry() : int
      {
         return 0;
      }
      
      public function set wildToolBarContainer(param1:DisplayObjectContainer) : void
      {
         this._wildToolBarContainer = param1;
      }
      
      public function get canUserHunter() : Boolean
      {
         var _loc1_:Object = _mainData.hunter;
         if(Boolean(_loc1_) && _loc1_.t > 0)
         {
            return true;
         }
         return false;
      }
      
      public function get beastConfigUrl() : String
      {
         return this._configUrl;
      }
      
      public function getShopIconUrl(param1:Number, param2:Boolean = false) : String
      {
         return GetCropID.getShopIconUrl(param1,param2);
      }
      
      public function updateWildStatus(param1:Number) : void
      {
         _mainCommand.updateWildStatus(param1);
      }
      
      public function set beastBase(param1:Object) : void
      {
         this._beastBaseData = param1;
         dispatchEvent(new Event(EvtAPI.BEAST_DATA_CHANGE));
      }
      
      public function set reloadCrystal(param1:Boolean) : void
      {
         WildData.reloadCrystal = param1;
      }
      
      public function showBeastPack() : void
      {
         dispatchEvent(new EvtAPI(EvtAPI.SHOW_BEAST_PACK));
      }
      
      public function getOpenExpLv(param1:String) : int
      {
         return OpenControl.getOpenExpLv(param1);
      }
      
      public function get hunterId() : int
      {
         return _mainData.hunter["id"];
      }
      
      public function addMoralexp(param1:int) : void
      {
         _mainData.host["moralexp"] = int(_mainData.host["moralexp"]) + param1;
         _mainData.dispatchEvent(new Event(MainData.HOST_CHANGE));
      }
      
      public function tipString(param1:String) : String
      {
         switch(param1)
         {
            case "hunterName":
               return "猎人";
            case "hunterError":
               return "没有看守员或者没有工资";
            default:
               return "";
         }
      }
      
      public function get beastPackContainer() : DisplayObjectContainer
      {
         return this._beastPackContainer;
      }
      
      public function set animalContainer(param1:DisplayObjectContainer) : void
      {
         this._animalContainer = param1;
      }
      
      public function steal(param1:Object) : void
      {
         _productData.addProduct(param1["cid"],-1);
      }
      
      public function getProductName2(param1:Object) : String
      {
         return GetCropID.getProductName2(param1);
      }
      
      public function get beastBase() : Object
      {
         return this._beastBaseData;
      }
      
      public function set beastConfigUrl(param1:String) : void
      {
         this._configUrl = param1;
      }
      
      public function showWildStage() : void
      {
         ViewControl.getInstance().dispatchEvent(new Event(EvtAPI.SHOW_WILD_STAGE));
         dispatchEvent(new Event(EvtAPI.SHOW_WILD_STAGE));
      }
      
      public function get animalContainer() : DisplayObjectContainer
      {
         return this._animalContainer;
      }
      
      public function get ISFARM() : int
      {
         return 0;
      }
      
      public function get wildToolBarContainer() : DisplayObjectContainer
      {
         return this._wildToolBarContainer;
      }
      
      public function showFarmStage() : void
      {
         ViewControl.getInstance().dispatchEvent(new Event(EvtAPI.SHOW_FARM_STAGE));
         dispatchEvent(new Event(EvtAPI.SHOW_FARM_STAGE));
      }
      
      public function hideBeastPack() : void
      {
         dispatchEvent(new EvtAPI(EvtAPI.HIDE_BEAST_PACK));
      }
      
      public function get dogId() : int
      {
         return 0;
      }
      
      public function getOpenYellowLv(param1:String) : int
      {
         return OpenControl.getOpenYellowLv(param1);
      }
   }
}

