package com.qzone.qfa.interfaces
{
   public interface INotifier
   {
      
      function notify(param1:String) : void;
      
      function removeNotifier(param1:String, param2:Function) : void;
      
      function addNotifier(param1:String, param2:Function) : void;
   }
}

