package events
{
   import flash.events.Event;
   
   public class ViewEvent extends Event
   {
      
      public static const CHILD_CLICK:String = "childClick";
      
      public static const CHILD_OUT:String = "childOut";
      
      public static const CHILD_OVER:String = "childOver";
      
      public static const ERROR_LOAD:String = "errorLoad";
      
      public static const LINK_CLICK:String = "linkClick";
      
      public static const PROGRESS_LOAD:String = "progressLoad";
      
      public static const RECLAIM_CLICK:String = "reclaimClick";
      
      public static const TASK_START:String = "taskStart";
      
      private var _data:Object;
      
      private var _changeLockStatus:Boolean = false;
      
      private var _newLockStatus:Boolean = false;
      
      public function ViewEvent(param1:String, param2:Boolean = false, param3:Boolean = false)
      {
         super(param1,param2,param3);
      }
      
      public function set lockStatus(param1:Boolean) : void
      {
         this._newLockStatus = param1;
      }
      
      public function get data() : Object
      {
         return this._data;
      }
      
      public function get changeLockStatus() : Boolean
      {
         return this._changeLockStatus;
      }
      
      public function set data(param1:Object) : void
      {
         this._data = param1;
      }
      
      public function set changeLockStatus(param1:Boolean) : void
      {
         this._changeLockStatus = param1;
      }
      
      public function get lockStatus() : Boolean
      {
         return this._newLockStatus;
      }
   }
}

