package com.qzone.qfa.interfaces
{
   import com.qzone.qfa.view.AppStage;
   
   public interface IApplication
   {
      
      function set model(param1:IModel) : void;
      
      function run(param1:Class, param2:Object = null, param3:String = "", param4:Function = null, param5:Function = null, param6:Function = null) : void;
      
      function get view() : AppStage;
      
      function set name(param1:String) : void;
      
      function get model() : IModel;
      
      function set view(param1:AppStage) : void;
      
      function get name() : String;
      
      function kill(param1:Class) : void;
   }
}

