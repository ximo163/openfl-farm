package entities
{
   import common.misc.Utils;
   
   public final class Task
   {
      
      public var _taskFlag:int;
      
      public var _taskId:int;
      
      public function Task(param1:*)
      {
         super();
         this.importObject(param1);
      }
      
      public function importObject(param1:*) : void
      {
         if(param1 == null)
         {
            return;
         }
         this._taskId = Utils.getIntAttribute(param1,"taskId");
         this._taskFlag = Utils.getIntAttribute(param1,"taskFlag");
      }
   }
}

