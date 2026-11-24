package com.qzone.corelib.controls.interfaces
{
   public interface IScroller extends IController
   {
      
      function get value() : Number;
      
      function set value(param1:Number) : void;
      
      function setCurrentLineCount(param1:int) : void;
   }
}

