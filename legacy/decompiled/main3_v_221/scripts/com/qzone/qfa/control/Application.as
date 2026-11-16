package com.qzone.qfa.control
{
   import com.qzone.qfa.core.Command;
   import com.qzone.qfa.events.CommandEvent;
   import com.qzone.qfa.interfaces.IApplication;
   import com.qzone.qfa.interfaces.IModel;
   import com.qzone.qfa.model.AppData;
   import com.qzone.qfa.view.AppStage;
   import flash.display.DisplayObjectContainer;
   import flash.utils.Dictionary;
   
   public class Application implements IApplication
   {
      
      private var _listeners:Dictionary;
      
      private var _view:AppStage;
      
      private var _runningCmds:Dictionary;
      
      private var _name:String;
      
      private var _model:IModel;
      
      public function Application(param1:String = "", param2:DisplayObjectContainer = null)
      {
         super();
         if(param1)
         {
            this._name = param1;
         }
         this._view = new AppStage(this);
         this._model = AppData.gi();
         this._runningCmds = new Dictionary();
         this._listeners = new Dictionary();
         if(param2)
         {
            param2.addChild(this._view);
         }
      }
      
      public function set view(param1:AppStage) : void
      {
         if(param1)
         {
            if(Boolean(this._view) && Boolean(this._view.parent))
            {
               this._view.parent.addChild(param1);
               this._view.parent.removeChild(this._view);
            }
            this._view = param1;
         }
      }
      
      public function run(param1:Class, param2:Object = null, param3:String = "", param4:Function = null, param5:Function = null, param6:Function = null) : void
      {
         var _loc7_:Command = null;
         if(param1)
         {
            _loc7_ = new param1() as Command;
            _loc7_.body = param2;
            this._listeners[_loc7_] = {};
            if(param5 != null)
            {
               this._listeners[_loc7_].complete = param5;
               _loc7_.addEventListener(CommandEvent.COMPLETE,param5);
            }
            if(param6 != null)
            {
               this._listeners[_loc7_].error = param6;
               _loc7_.addEventListener(CommandEvent.ERROR,param6);
            }
            if(param4 != null && Boolean(param3))
            {
               this._model.addNotifier(param3,param4);
            }
            _loc7_.addEventListener(CommandEvent.COMPLETE,this.handleCommandEvents);
            _loc7_.addEventListener(CommandEvent.ERROR,this.handleCommandEvents);
            _loc7_.execute();
         }
      }
      
      public function set model(param1:IModel) : void
      {
         this._model = param1;
      }
      
      public function get name() : String
      {
         return this._name;
      }
      
      public function set name(param1:String) : void
      {
         this._name = param1;
      }
      
      public function kill(param1:Class) : void
      {
      }
      
      public function get view() : AppStage
      {
         return this._view;
      }
      
      public function get model() : IModel
      {
         return this._model;
      }
      
      public function isRunning(param1:Class) : Boolean
      {
         var _loc2_:* = undefined;
         for(_loc2_ in this._runningCmds)
         {
            if(_loc2_ == param1)
            {
               return true;
            }
         }
         return false;
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

