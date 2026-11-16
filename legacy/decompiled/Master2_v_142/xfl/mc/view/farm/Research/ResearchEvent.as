package mc.view.farm.Research
{
   import flash.events.Event;
   
   public class ResearchEvent extends Event
   {
      
      public static const OPEN_WINDOW:String = "openWindow";
      
      public static const UPDATA_DEN:String = "updataDen";
      
      public static const UPDATA_SHED:String = "updataShed";
      
      public static const UPDATEDENSHED_SUCESS:String = "UPDATEDENSHED_SUCESS";
      
      public static const MUCH_CATCH_CGI:String = "MUCH_CATCH_CGI";
      
      public static const DENSHED_OPEN:String = "den_shed_open";
      
      public static const UPDATA_HOUR_GLASS_NUM_0:String = "updatahourglassnum0";
      
      public static const UPDATA_HOUR_GLASS_NUM:String = "updatahourglassnum";
      
      public static const DENSHED_UPDATE:String = "DENSHED_UPDATE";
      
      public static const DENSHED_RESEARCH_ANIMAL:String = "DENSHED_RESEARCH_ANIMAL";
      
      public static const DENSHED_RESEARCH_CHANGE:String = "DENSHED_RESEARCH_CHANGE";
      
      public static const DENSHED_RESEARCH_SHOUCOMPLETE:String = "DENSHED_RESEARCH_SHOUCOMPLETE";
      
      public static const DENSHED_RESEARCH_SHOUCOMPLETE_OK:String = "DENSHED_RESEARCH_SHOUCOMPLETE_OK";
      
      private var _data:Object;
      
      public function ResearchEvent(param1:String, param2:Boolean = false, param3:Boolean = false)
      {
         super(param1,param2,param3);
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

