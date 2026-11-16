package mc.view
{
   import flash.events.Event;
   
   public class ViewEvent extends Event
   {
      
      public static const ERROR_LOAD:String = "errorLoad";
      
      public static const PROGRESS_LOAD:String = "progressLoad";
      
      public static const RECLAIM_CLICK:String = "reclaimClick";
      
      public static const MODULE_COMP:String = "moduleComp";
      
      public static const CHILD_CLICK:String = "childClick";
      
      public static const CHILD_OVER:String = "childOver";
      
      public static const CHILD_OUT:String = "childOut";
      
      public static const LINK_CLICK:String = "linkClick";
      
      private var _data:Object;
      
      public function ViewEvent(param1:String, param2:Boolean = false, param3:Boolean = false)
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

