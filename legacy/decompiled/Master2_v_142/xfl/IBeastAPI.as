package
{
   import flash.display.DisplayObjectContainer;
   
   public interface IBeastAPI extends IGameAPI
   {
      
      function addMoralexp(param1:int) : void;
      
      function updateWildStatus(param1:Number) : void;
      
      function openControlisOpen(param1:String) : Boolean;
      
      function get beastPackContainer() : DisplayObjectContainer;
      
      function set animalContainer(param1:DisplayObjectContainer) : void;
      
      function showReward(param1:String) : void;
      
      function get wildStageContainer() : DisplayObjectContainer;
      
      function getProductName2(param1:Object) : String;
      
      function steal(param1:Object) : void;
      
      function get beastBase() : Object;
      
      function set beastPackContainer(param1:DisplayObjectContainer) : void;
      
      function tipString(param1:String) : String;
      
      function showWildStage() : void;
      
      function set wildStageContainer(param1:DisplayObjectContainer) : void;
      
      function showBeastPack() : void;
      
      function set beastConfigUrl(param1:String) : void;
      
      function getAnimalURL(param1:String, param2:int) : String;
      
      function get wildToolBarContainer() : DisplayObjectContainer;
      
      function set beastBase(param1:Object) : void;
      
      function get canUserHunter() : Boolean;
      
      function get animalContainer() : DisplayObjectContainer;
      
      function get ISFARM() : int;
      
      function getShopIconUrl(param1:Number, param2:Boolean = false) : String;
      
      function showFarmStage() : void;
      
      function get beastConfigUrl() : String;
      
      function set wildToolBarContainer(param1:DisplayObjectContainer) : void;
      
      function getOpenExpLv(param1:String) : int;
      
      function set reloadCrystal(param1:Boolean) : void;
      
      function get hunterId() : int;
      
      function hideBeastPack() : void;
      
      function getOpenYellowLv(param1:String) : int;
   }
}

