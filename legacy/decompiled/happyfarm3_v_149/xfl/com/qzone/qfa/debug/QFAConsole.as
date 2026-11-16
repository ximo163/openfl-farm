package com.qzone.qfa.debug
{
   import com.qzone.qfa.model.DebugLog;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.events.KeyboardEvent;
   
   public class QFAConsole
   {
      
      public static var consoleWindow:IConsoleWindow;
      
      private static var _logs:Array;
      
      public static var consoleWindowClass:Class;
      
      private static var _stage:DisplayObjectContainer;
      
      public function QFAConsole(param1:DisplayObjectContainer, param2:Class = null)
      {
         super();
         consoleWindowClass = param2 || SimpleConsoleWindow;
         _stage = param1;
         if(_stage)
         {
            _stage.addEventListener(KeyboardEvent.KEY_UP,handleKeyUp);
         }
      }
      
      public static function getAllLogs() : Array
      {
         return _logs;
      }
      
      public static function set stage(param1:DisplayObjectContainer) : void
      {
         _stage = param1;
         if(_stage)
         {
            _stage.addEventListener(KeyboardEvent.KEY_UP,handleKeyUp);
         }
      }
      
      public static function log(param1:*, param2:int = 0) : void
      {
         _logs = _logs || [];
         var _loc3_:DebugLog = new DebugLog(param1.toString(),param2);
         _logs.push(_loc3_);
         if(consoleWindow)
         {
            if(consoleWindow.logType == -1)
            {
               consoleWindow.dataProvider = _logs;
            }
            else
            {
               consoleWindow.dataProvider = getLogsByType(consoleWindow.logType) || [];
            }
         }
         trace(_loc3_.toStringWithoutFormat());
      }
      
      public static function get stage() : DisplayObjectContainer
      {
         return _stage;
      }
      
      public static function clear() : void
      {
         _logs = [];
         if(Boolean(consoleWindow) && !consoleWindow.isHidden)
         {
            consoleWindow.dataProvider = _logs;
         }
      }
      
      private static function handleKeyUp(param1:KeyboardEvent) : void
      {
         var _loc3_:Array = null;
         if(param1.keyCode == 191 && param1.ctrlKey)
         {
            if(!consoleWindow)
            {
               consoleWindow = new consoleWindowClass() as IConsoleWindow;
            }
            if(consoleWindow.isHidden)
            {
               show();
            }
            else
            {
               hide();
            }
         }
         if(!consoleWindow || consoleWindow.isHidden || param1.keyCode == 33 || param1.keyCode == 34)
         {
            return;
         }
         if(Boolean(param1.keyCode == 88) && Boolean(consoleWindow) && !consoleWindow.isHidden)
         {
            clear();
         }
         var _loc2_:int = param1.keyCode - 49;
         if(_loc2_ == DebugLog.ERROR || _loc2_ == DebugLog.LOG || _loc2_ == DebugLog.TRAFFIC || _loc2_ == DebugLog.WARNING)
         {
            _loc3_ = getLogsByType(_loc2_) || [];
            consoleWindow.logType = _loc2_;
         }
         else
         {
            _loc3_ = _logs || [];
            consoleWindow.logType = -1;
         }
         consoleWindow.dataProvider = _loc3_;
      }
      
      public static function getLogsByType(param1:int) : Array
      {
         var _loc3_:DebugLog = null;
         var _loc2_:int = int(_logs.length);
         var _loc4_:Array = [];
         var _loc5_:int = 0;
         while(_loc5_ < _loc2_)
         {
            _loc3_ = _logs[_loc5_] as DebugLog;
            if(_loc3_.type == param1)
            {
               _loc4_.push(_loc3_);
            }
            _loc5_++;
         }
         return _loc4_;
      }
      
      public static function hide() : void
      {
         if(consoleWindow)
         {
            if(!consoleWindow.isHidden)
            {
               consoleWindow.hide();
            }
         }
      }
      
      public static function show() : void
      {
         if(!consoleWindow)
         {
            consoleWindow = new consoleWindowClass() as IConsoleWindow;
         }
         if(consoleWindow.isHidden)
         {
            _stage.addChildAt(consoleWindow as DisplayObject,_stage.numChildren);
            consoleWindow.dataProvider = consoleWindow.logType == -1 ? _logs : getLogsByType(consoleWindow.logType);
         }
      }
   }
}

