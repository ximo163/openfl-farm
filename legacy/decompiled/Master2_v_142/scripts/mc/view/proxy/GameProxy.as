package mc.view.proxy
{
   import flash.display.*;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.IEventDispatcher;
   
   public class GameProxy extends EventDispatcher
   {
      
      public static var parameters:Object;
      
      public static var npcLand:Sprite;
      
      private static var instance:GameProxy;
      
      public static var iniData:XML;
      
      public static const CURRENT_USER_CHANGE:String = "proxy_UserChange";
      
      private var _currentUser:Object;
      
      private var _host:Object;
      
      public function GameProxy(param1:IEventDispatcher = null)
      {
         if(instance == null)
         {
            super();
            return;
         }
         throw new Error("实例化单例类出错-LifeData");
      }
      
      public static function getInstance() : GameProxy
      {
         if(instance == null)
         {
            instance = new GameProxy();
         }
         return instance;
      }
      
      public function set host(param1:Object) : void
      {
         this._host = param1;
      }
      
      public function get me() : Boolean
      {
         var _loc1_:Boolean = true;
         if(this.currentUser != null && this.host != null)
         {
            if(this.currentUser["uId"] != this.host["uId"])
            {
               _loc1_ = false;
            }
         }
         return _loc1_;
      }
      
      public function get currentUser() : Object
      {
         return this._currentUser;
      }
      
      public function get host() : Object
      {
         return this._host;
      }
      
      public function set currentUser(param1:Object) : void
      {
         this._currentUser = param1;
         dispatchEvent(new Event(GameProxy.CURRENT_USER_CHANGE));
      }
   }
}

