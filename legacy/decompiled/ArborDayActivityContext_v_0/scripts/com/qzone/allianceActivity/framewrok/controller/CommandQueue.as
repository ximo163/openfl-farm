package com.qzone.allianceActivity.framewrok.controller
{
   import com.qzone.allianceActivity.framewrok.command.CompositeCommand;
   import com.qzone.allianceActivity.framewrok.command.ICommand;
   import com.qzone.allianceActivity.framewrok.events.CommandEvent;
   import com.qzone.allianceActivity.framewrok.events.MVCEvent;
   import flash.utils.Dictionary;
   
   public class CommandQueue extends CompositeCommand
   {
      
      private var _isRunning:Boolean = false;
      
      private var _eventMap:Dictionary = new Dictionary(true);
      
      public function CommandQueue()
      {
         super();
      }
      
      override public function execSubCommand(param1:MVCEvent = null) : void
      {
         var _loc2_:ICommand = null;
         if(_pointer < _subCommands.length)
         {
            _loc2_ = _subCommands[_pointer];
            param1 = this._eventMap[_loc2_];
            this.execSubCommand(param1);
         }
      }
      
      override protected function nextHandler(param1:CommandEvent) : void
      {
         var _loc2_:ICommand = param1.target as ICommand;
         if(this._eventMap[_loc2_])
         {
            delete this._eventMap[_loc2_];
         }
         super.nextHandler(param1);
      }
      
      public function start() : void
      {
         if(this._isRunning)
         {
            return;
         }
         this._isRunning = true;
         exec();
      }
      
      public function stop() : void
      {
         this._isRunning = false;
      }
      
      public function push(param1:ICommand, param2:MVCEvent) : void
      {
         subCommands.push(param1);
         this._eventMap[param1] = param2;
         if(!this._isRunning)
         {
            this.start();
         }
      }
      
      public function get isRunning() : Boolean
      {
         return this._isRunning;
      }
      
      public function set isRunning(param1:Boolean) : void
      {
         this._isRunning = param1;
      }
   }
}

