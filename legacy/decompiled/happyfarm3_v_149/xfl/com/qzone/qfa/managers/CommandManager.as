package com.qzone.qfa.managers
{
   import com.qzone.qfa.core.Command;
   import com.qzone.qfa.events.CommandEvent;
   import flash.utils.Dictionary;
   
   public class CommandManager
   {
      
      private static var _instance:CommandManager;
      
      private var _listeners:Dictionary;
      
      public function CommandManager(param1:Enforcer)
      {
         super();
         this._listeners = new Dictionary();
      }
      
      public static function getInstance() : CommandManager
      {
         return _instance = _instance || new CommandManager(new Enforcer());
      }
      
      public function run(param1:*, param2:Object = null, param3:Function = null, param4:Function = null, param5:int = 0) : void
      {
         var _loc6_:Command = null;
         if(param1)
         {
            if(param1 is Class)
            {
               _loc6_ = new param1() as Command;
            }
            else
            {
               _loc6_ = param1 as Command;
            }
            _loc6_.body = param2;
            this._listeners[_loc6_] = {};
            if(param3 != null)
            {
               this._listeners[_loc6_].complete = param3;
               _loc6_.addEventListener(CommandEvent.COMPLETE,param3,false,param5,true);
            }
            if(param4 != null)
            {
               this._listeners[_loc6_].error = param4;
               _loc6_.addEventListener(CommandEvent.ERROR,param4,false,param5,true);
            }
         }
         _loc6_.addEventListener(CommandEvent.COMPLETE,this.handleCommandEvents,false,param5,true);
         _loc6_.addEventListener(CommandEvent.ERROR,this.handleCommandEvents,false,param5,true);
         _loc6_.execute();
      }
      
      private function handleCommandEvents(param1:CommandEvent) : void
      {
         var _loc2_:Command = param1.target as Command;
         var _loc3_:Object = this._listeners[_loc2_] as Object;
         if(!_loc3_)
         {
            return;
         }
         if(_loc3_.complete != null)
         {
            _loc2_.removeEventListener(CommandEvent.COMPLETE,_loc3_.complete);
            _loc3_.complete = null;
         }
         if(_loc3_.error != null)
         {
            _loc2_.removeEventListener(CommandEvent.COMPLETE,_loc3_.error);
            _loc3_.error = null;
         }
         delete this._listeners[_loc2_];
      }
   }
}

class Enforcer
{
   
   public function Enforcer()
   {
      super();
   }
}
