package mc.model
{
   import flash.events.EventDispatcher;
   
   public class TaskData extends EventDispatcher
   {
      
      private static var instance:TaskData;
      
      public static const TASKDATA_CHANGE:String = "taskDataChange";
      
      public static const COMPLETE:String = "complete";
      
      public static const TASK_DOING:String = "taskDoing";
      
      public static const TASK_MAX:Number = 9;
      
      private var _updata:Object;
      
      private var _currentTask:Object = {
         "taskId":1,
         "taskFlag":2
      };
      
      public function TaskData()
      {
         if(instance == null)
         {
            super();
            return;
         }
         throw new Error("实例化单例类出错-TaskData");
      }
      
      public static function getInstance() : TaskData
      {
         if(instance == null)
         {
            instance = new TaskData();
         }
         return instance;
      }
      
      public function set updata(param1:Object) : void
      {
         this._updata = param1;
         dispatchEvent(new ModelEvent(TaskData.COMPLETE));
      }
      
      public function set currentTask(param1:Object) : void
      {
         this._currentTask = param1;
         dispatchEvent(new ModelEvent(TaskData.TASKDATA_CHANGE));
      }
      
      public function get updata() : Object
      {
         return this._updata;
      }
      
      public function get currentTask() : Object
      {
         return this._currentTask;
      }
   }
}

