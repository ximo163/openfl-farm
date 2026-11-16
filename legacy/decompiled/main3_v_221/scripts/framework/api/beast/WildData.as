package framework.api.beast
{
   import flash.events.Event;
   import flash.events.EventDispatcher;
   
   public class WildData extends EventDispatcher
   {
      
      private static var _instance:WildData;
      
      public static const CRYSTAL_CHANGE:String = "crystal_change";
      
      public static const CRYSTAL_LOADING:String = "crystal_loading";
      
      public static const CRYSTAL_ERROR:String = "crystal_errror";
      
      public static var reloadCrystal:Boolean = true;
      
      private var _crystalsLoading:Boolean;
      
      private var _crystalsError:String;
      
      private var _crystals:Array;
      
      public function WildData()
      {
         super();
      }
      
      public static function getInstance() : WildData
      {
         if(!_instance)
         {
            _instance = new WildData();
         }
         return _instance;
      }
      
      public function get crystalsLoading() : Boolean
      {
         return this._crystalsLoading;
      }
      
      public function get crystalsError() : String
      {
         return this._crystalsError;
      }
      
      public function set crystalsError(param1:String) : void
      {
         this._crystalsError = param1;
         dispatchEvent(new Event(WildData.CRYSTAL_ERROR));
      }
      
      public function set crystals(param1:Array) : void
      {
         this._crystals = param1;
         dispatchEvent(new Event(WildData.CRYSTAL_CHANGE));
      }
      
      public function get crystals() : Array
      {
         return this._crystals;
      }
      
      public function set crystalsLoading(param1:Boolean) : void
      {
         this._crystalsLoading = param1;
         dispatchEvent(new Event(WildData.CRYSTAL_LOADING));
      }
   }
}

