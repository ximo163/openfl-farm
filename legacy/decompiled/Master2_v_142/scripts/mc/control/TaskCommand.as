package mc.control
{
   import flash.events.EventDispatcher;
   import mc.FBridge.EventRecorder;
   import mc.FBridge.FRequest;
   import mc.model.TaskData;
   
   public class TaskCommand extends EventDispatcher
   {
      
      private var fr:FRequest;
      
      private var taskData:TaskData;
      
      public function TaskCommand()
      {
         super();
         this.fr = FRequest.getInstance();
         this.taskData = TaskData.getInstance();
      }
      
      public function run() : void
      {
         this.fr.postRequest("cgi_up_task",{"act":1},this.taskAccept);
      }
      
      private function taskAccept(param1:Object) : void
      {
         if(param1["ecode"] == 0)
         {
            if(!param1.task)
            {
               EventRecorder.recordErrorEvent("160942",0,14);
            }
            this.taskData.currentTask = {
               "taskId":param1.task.taskId,
               "taskFlag":1
            };
            EventRecorder.recordSueecssEvent("160942",0);
         }
         else if(param1.hasOwnProperty("direction"))
         {
            Command.getInstance().mainCommand.floatWindow(param1["direction"]);
            EventRecorder.recordSueecssEvent("160942",0);
         }
         else if(param1.hasOwnProperty("errorContent"))
         {
            Command.getInstance().mainCommand.floatWindow(param1["errorContent"]);
            EventRecorder.recordErrorEvent("160942",0,14);
         }
         else
         {
            Command.getInstance().mainCommand.floatWindow("系统繁忙，请稍候重试。");
            EventRecorder.recordErrorEvent("160942",0,14);
         }
      }
   }
}

