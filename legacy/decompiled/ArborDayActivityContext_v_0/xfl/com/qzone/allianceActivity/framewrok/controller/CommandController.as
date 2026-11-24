package com.qzone.allianceActivity.framewrok.controller
{
   import com.qzone.allianceActivity.framewrok.command.ICommand;
   import com.qzone.allianceActivity.framewrok.events.MVCEvent;
   import flash.utils.Dictionary;
   
   public class CommandController
   {
      
      private var _globalCommandQueue:CommandQueue = new CommandQueue();
      
      private var _commandClsCollection:Dictionary = new Dictionary();
      
      public function CommandController()
      {
         super();
      }
      
      public function executeCommand(param1:MVCEvent, param2:Boolean = false) : void
      {
         if(param1 == null)
         {
            return;
         }
         if(param1.type == null || param1.type == "")
         {
            return;
         }
         var _loc3_:ICommand = this.getCommand(param1.type);
         if(_loc3_)
         {
            if(param2)
            {
               this.executeCommandInGlobalQue(_loc3_,param1);
            }
            else
            {
               _loc3_.exec(param1);
            }
         }
      }
      
      public function executeCommandInGlobalQue(param1:ICommand, param2:MVCEvent) : void
      {
         if(param1)
         {
            this._globalCommandQueue.push(param1,param2);
         }
      }
      
      public function getCommand(param1:String) : ICommand
      {
         var _loc3_:Object = null;
         var _loc2_:Class = this._commandClsCollection[param1];
         if(_loc2_)
         {
            _loc3_ = new _loc2_();
         }
         if(_loc3_ != null)
         {
            return _loc3_ as ICommand;
         }
         return null;
      }
      
      public function registerCommand(param1:String, param2:Class) : void
      {
         this._commandClsCollection[param1] = param2;
      }
   }
}

