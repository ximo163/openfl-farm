package
{
   import flash.events.Event;
   
   public class EvtAPI extends Event
   {
      
      public static const SHOW_BEAST_PACK:String = "show_Beast_Pack";
      
      public static const HIDE_BEAST_PACK:String = "hide_Beast_Pack";
      
      public static const BEAST_DATA_CHANGE:String = "animals_Change";
      
      public static const SHOW_WILD_STAGE:String = "show_wild_stage";
      
      public static const SHOW_FARM_STAGE:String = "show_farm_stage";
      
      public static const REWARD_CHANGE:String = "reward_change";
      
      public static const HUNTER_CHANGE:String = "hunter_change";
      
      public static const HOST_CHANGE:String = "host_Change";
      
      public static const CURRENT_USER_CHANGE:String = "current_user_change";
      
      public static const REFRESH_CRYSTAL:String = "refreshCrystal";
      
      private var _data:Object;
      
      public function EvtAPI(param1:String)
      {
         super(param1);
      }
      
      public function set data(param1:Object) : void
      {
         this._data = param1;
      }
      
      public function get data() : Object
      {
         return this._data;
      }
   }
}

