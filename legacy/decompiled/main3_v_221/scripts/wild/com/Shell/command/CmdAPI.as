package wild.com.Shell.command
{
   import flash.events.EventDispatcher;
   
   public class CmdAPI extends EventDispatcher
   {
      
      private static var instance:CmdAPI;
      
      private var _api:IBeastAPI;
      
      public function CmdAPI()
      {
         super();
      }
      
      public static function getInstance() : CmdAPI
      {
         if(!instance)
         {
            instance = new CmdAPI();
         }
         return instance;
      }
      
      public function get api() : IBeastAPI
      {
         return this._api;
      }
      
      public function set api(param1:IBeastAPI) : void
      {
         this._api = param1;
      }
   }
}

