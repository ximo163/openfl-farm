package com.qzone.qfa.interfaces
{
   public interface IModel extends INotifier
   {
      
      function getData(param1:String) : Object;
      
      function flush() : void;
      
      function setData(param1:String, param2:Object) : Boolean;
   }
}

