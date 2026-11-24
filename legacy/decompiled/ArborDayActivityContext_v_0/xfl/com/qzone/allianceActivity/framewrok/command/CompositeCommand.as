package com.qzone.allianceActivity.framewrok.command
{
   import com.qzone.allianceActivity.framewrok.events.CommandEvent;
   import com.qzone.allianceActivity.framewrok.events.MVCEvent;
   
   public class CompositeCommand extends AsyncCommand
   {
      
      protected var _subCommands:Array = new Array();
      
      protected var _maxThreads:int = 1;
      
      protected var _runningThreads:int = 0;
      
      protected var _completedThreads:int = 0;
      
      protected var _pointer:int = 0;
      
      public function CompositeCommand()
      {
         super();
      }
      
      override protected function __exec(param1:MVCEvent) : void
      {
         var _loc3_:int = 0;
         super.__exec(param1);
         var _loc2_:int = Math.min(this._maxThreads,this._subCommands.length);
         if(_loc2_ > 0)
         {
            _loc3_ = this._runningThreads;
            while(_loc3_ < _loc2_)
            {
               this.execSubCommand();
               _loc3_++;
            }
         }
         else
         {
            dispatchCompleteEvent();
         }
      }
      
      public function execSubCommand(param1:MVCEvent = null) : void
      {
         var command:ICommand = null;
         var event:MVCEvent = param1;
         event = event == null ? _event : event;
         if(this._pointer < this._subCommands.length)
         {
            command = this._subCommands[this._pointer];
            ++this._pointer;
            ++this._runningThreads;
            if(command is IAsyncCommand)
            {
               IAsyncCommand(command).addResultHandler(this.nextHandler);
               IAsyncCommand(command).addErrorHandler(this.nextHandler);
               command.exec(_event);
            }
            else
            {
               try
               {
                  command.exec(_event);
                  command.addEventListener(CommandEvent.COMMAND_ERROR,this.nextHandler);
                  command.addEventListener(CommandEvent.COMMAND_COMPLETE,this.nextHandler);
               }
               catch(e:Error)
               {
                  _error = e;
               }
               if(_error)
               {
                  command.dispatchEvent(new CommandEvent(CommandEvent.COMMAND_ERROR));
               }
               else
               {
                  command.dispatchEvent(new CommandEvent(CommandEvent.COMMAND_COMPLETE));
               }
            }
         }
         else
         {
            dispatchCompleteEvent();
         }
      }
      
      protected function nextHandler(param1:CommandEvent) : void
      {
         var _loc2_:ICommand = param1.target as ICommand;
         if(_loc2_ is IAsyncCommand)
         {
            IAsyncCommand(_loc2_).removeResultHandler(this.nextHandler);
            IAsyncCommand(_loc2_).removeErrorHandler(this.nextHandler);
         }
         else
         {
            _loc2_.removeEventListener(CommandEvent.COMMAND_COMPLETE,this.nextHandler);
            _loc2_.removeEventListener(CommandEvent.COMMAND_ERROR,this.nextHandler);
         }
         this._runningThreads = Math.max(0,this._runningThreads - 1);
         ++this._completedThreads;
         if(this._completedThreads < this._subCommands.length)
         {
            if(this._runningThreads < this._maxThreads)
            {
               if(param1.type == CommandEvent.COMMAND_ERROR)
               {
                  if(faultContinue)
                  {
                     this.execSubCommand();
                  }
                  else
                  {
                     dispatchErrorEvent();
                  }
               }
               else if(param1.type == CommandEvent.COMMAND_COMPLETE)
               {
                  this.execSubCommand();
               }
               else
               {
                  dispatchErrorEvent();
               }
            }
         }
         else
         {
            dispatchCompleteEvent();
         }
      }
      
      public function addSubCommand(param1:ICommand) : void
      {
         this._subCommands.push(param1);
      }
      
      public function get subCommands() : Array
      {
         return this._subCommands;
      }
      
      public function set subCommands(param1:Array) : void
      {
         this._subCommands = param1;
      }
      
      public function get maxThreads() : int
      {
         return this._maxThreads;
      }
      
      public function set maxThreads(param1:int) : void
      {
         this._maxThreads = param1;
      }
   }
}

