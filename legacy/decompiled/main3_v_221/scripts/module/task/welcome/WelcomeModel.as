package module.task.welcome
{
   import com.qzone.qfa.events.CommandEvent;
   import common.Session;
   import entities.Task;
   import events.CommonEvent;
   import flash.events.EventDispatcher;
   import framework.net.CommandDefs;
   import framework.net.NetHelper;
   import report.EventRecorder;
   
   public class WelcomeModel extends EventDispatcher
   {
      
      public static const EVENT_TASK_CHANGED:String = "TaskChanged";
      
      public static const EVENT_TASK_COMPLETED:String = "TaskCompleted";
      
      private static var taskList:Object = {
         "1":{
            "name":"harvest",
            "me":true
         },
         "2":{
            "name":"scarify",
            "me":true
         },
         "3":{
            "name":"sale",
            "me":true
         },
         "4":{
            "name":"planting",
            "me":true
         },
         "5":{
            "name":"water",
            "me":true
         },
         "6":{
            "name":"clearWeed",
            "me":true
         },
         "7":{
            "name":"spraying",
            "me":true
         },
         "8":{
            "name":"water",
            "me":false
         },
         "9":{
            "name":"clearWeed",
            "me":false
         },
         "10":{
            "name":"spraying",
            "me":false
         },
         "11":{
            "name":"harvest",
            "me":false
         }
      };
      
      private static const newIDToOldID:Array = [99,21,24,25,26,27,22,23,99,28,29,30];
      
      private var m_currentTaskID:int;
      
      private var m_currentTaskFlag:int;
      
      private var m_taskUpdating:Boolean;
      
      public function WelcomeModel()
      {
         super();
         this.m_currentTaskID = 0;
         this.m_currentTaskFlag = 0;
         this.m_taskUpdating = false;
      }
      
      public function get taskID() : int
      {
         return this.m_currentTaskID;
      }
      
      public function get newIDToOldIDArray() : Array
      {
         return newIDToOldID.concat();
      }
      
      private function onAccepted(param1:CommandEvent) : void
      {
         var _loc3_:Task = null;
         var _loc2_:Object = NetHelper.getVOData(param1);
         if(_loc2_ != null && _loc2_["taskId"] != undefined)
         {
            _loc3_ = new Task(null);
            _loc3_._taskId = _loc2_["taskId"] as int;
            _loc3_._taskFlag = 1;
            this.currentTask = _loc3_;
         }
         EventRecorder.recordSueecssEvent("160858",null);
      }
      
      private function onNetError(param1:CommandEvent) : void
      {
         if(param1 == null || param1.result == null)
         {
            return;
         }
         if(param1.body["cmdId"] == CommandDefs.CMD_ACCEPT_TASK)
         {
            EventRecorder.recordErrorEvent("160858",null,4);
         }
         if(param1.body["cmdID"] == CommandDefs.CMD_UPDATE_TASK)
         {
            this.m_taskUpdating = false;
            EventRecorder.recordErrorEvent("160859",null,4);
         }
      }
      
      public function acceptTask() : void
      {
         NetHelper.sendRequest(CommandDefs.CMD_ACCEPT_TASK,null,this.onAccepted,this.onNetError);
      }
      
      private function updateTask() : void
      {
         if(this.m_taskUpdating == true)
         {
            return;
         }
         this.m_taskUpdating = true;
         NetHelper.sendRequest(CommandDefs.CMD_UPDATE_TASK,null,this.onTaskUpdated,this.onNetError);
      }
      
      public function get taskFlag() : int
      {
         return this.m_currentTaskFlag;
      }
      
      public function taskComp(param1:String, param2:Object) : void
      {
         if(this.m_currentTaskFlag != 1)
         {
            return;
         }
         var _loc3_:Object = taskList[this.m_currentTaskID.toString()];
         if(_loc3_ == null)
         {
            return;
         }
         var _loc4_:Boolean = Session.getInstance().me;
         if(_loc3_["name"] == param1 && _loc4_ == _loc3_["me"] as Boolean)
         {
            if(param2.hasOwnProperty("code") == true && param2["code"] == 1)
            {
               this.updateTask();
            }
         }
      }
      
      public function preSetTaskFlag() : void
      {
         this.m_currentTaskFlag = 2;
      }
      
      public function resetLoadingFlags() : void
      {
         if(this.m_taskUpdating == true)
         {
            this.m_taskUpdating = false;
         }
      }
      
      public function set currentTask(param1:Task) : void
      {
         if(param1 == null)
         {
            return;
         }
         if(param1._taskId < 20)
         {
            this.m_currentTaskID = param1._taskId;
            Session.getInstance().isNewGuideTask = false;
         }
         else
         {
            this.m_currentTaskID = newIDToOldID.indexOf(param1._taskId);
            Session.getInstance().isNewGuideTask = true;
         }
         this.m_currentTaskFlag = param1._taskFlag;
         dispatchEvent(new CommonEvent(EVENT_TASK_CHANGED,{
            "taskID":this.m_currentTaskID,
            "taskFlag":this.m_currentTaskFlag
         }));
      }
      
      private function onTaskUpdated(param1:CommandEvent) : void
      {
         this.m_taskUpdating = false;
         var _loc2_:Object = NetHelper.getVOData(param1);
         if(_loc2_ == null)
         {
            return;
         }
         var _loc3_:Object = _loc2_["task"];
         if(_loc3_ != null && _loc3_["taskId"] != undefined)
         {
            if(_loc3_["taskId"] == 0 && _loc3_["taskFlag"] == 0)
            {
               _loc3_["taskId"] = 0;
            }
            this.currentTask = new Task(_loc3_);
            dispatchEvent(new CommonEvent(EVENT_TASK_COMPLETED,_loc2_));
         }
         EventRecorder.recordSueecssEvent("160859",null);
      }
   }
}

