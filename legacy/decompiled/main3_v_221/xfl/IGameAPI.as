package
{
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.IEventDispatcher;
   import flash.system.ApplicationDomain;
   
   public interface IGameAPI extends IEventDispatcher
   {
      
      function hideTip() : void;
      
      function requestClass(param1:String, param2:Function, param3:String = null, param4:Object = null) : void;
      
      function get cursorArgument() : Object;
      
      function get friendFid() : String;
      
      function useSystemCurosr(param1:Boolean) : void;
      
      function get hostFid() : String;
      
      function open(param1:Sprite, param2:String, param3:String = "", param4:Function = null, param5:Function = null) : void;
      
      function get appCurrentDomain() : ApplicationDomain;
      
      function get swfUrl() : String;
      
      function postRequest(param1:String, param2:Object, param3:Function, param4:String = null, param5:String = "farm") : void;
      
      function get cursorName() : String;
      
      function openForName(param1:String, param2:Object = null) : void;
      
      function addPrefix(param1:String) : String;
      
      function setUser(param1:Object) : void;
      
      function get version() : String;
      
      function setExpressUser(param1:Object) : void;
      
      function getMaterialClass(param1:String) : Class;
      
      function set iniData(param1:XML) : void;
      
      function getMaterial(param1:String) : DisplayObject;
      
      function showTip(param1:String, param2:Object) : void;
      
      function addMoney(param1:Object) : void;
      
      function openShop(param1:int) : void;
      
      function isMe() : Boolean;
      
      function closeForName(param1:String, param2:Object = null) : void;
      
      function get currentUser() : Object;
      
      function openConfirmWindow(param1:Object, param2:Function, param3:Function, param4:Boolean = true) : void;
      
      function setCursor(param1:String, param2:Object = null, param3:String = null) : void;
      
      function set reloadUserCrop(param1:Boolean) : void;
      
      function pushToMaterialLib(param1:ApplicationDomain) : void;
      
      function set reloadUserSeed(param1:Boolean) : void;
      
      function alertWindow(param1:String, param2:String, param3:Boolean = false) : void;
      
      function get iniData() : XML;
      
      function get host() : Object;
      
      function get serverTime() : Number;
      
      function floatWindow(param1:String, param2:String = "info") : void;
      
      function jsonDecode(param1:String) : Object;
      
      function close(param1:Sprite) : void;
      
      function getURL(param1:String, param2:Object = null) : String;
      
      function getMaterialMC(param1:String) : MovieClip;
      
      function get hostLevel() : int;
      
      function getFriendByFid(param1:int) : Object;
      
      function refreshFriendsList(param1:Boolean) : void;
   }
}

