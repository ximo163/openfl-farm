package com.qzone.allianceActivity.framewrok.cache
{
   public interface IBindableCache
   {
      
      function addBinding(param1:String, param2:Object, param3:String) : void;
      
      function removeBinding(param1:String, param2:Object, param3:String) : void;
      
      function removeBindedTarget(param1:Object) : void;
      
      function isPropertyBinding(param1:String) : Boolean;
      
      function isTargetBindedToProperty(param1:Object, param2:String) : Boolean;
      
      function isTargetBinded(param1:Object) : Boolean;
      
      function get bindable() : Boolean;
      
      function set bindable(param1:Boolean) : void;
   }
}

