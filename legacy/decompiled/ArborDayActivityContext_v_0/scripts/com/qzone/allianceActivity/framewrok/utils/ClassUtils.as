package com.qzone.allianceActivity.framewrok.utils
{
   import flash.display.MovieClip;
   import flash.system.ApplicationDomain;
   import flash.utils.getDefinitionByName;
   import flash.utils.getQualifiedClassName;
   
   public class ClassUtils
   {
      
      private static const MODULE_SEPERATOR:String = "::";
      
      public function ClassUtils()
      {
         super();
      }
      
      public static function getMc(param1:String, param2:ApplicationDomain = null) : MovieClip
      {
         if(param2 == null)
         {
            param2 = ApplicationDomain.currentDomain;
         }
         var _loc3_:Class = param2.getDefinition(param1) as Class;
         if(_loc3_)
         {
            return new _loc3_();
         }
         return null;
      }
      
      public static function getClassFullName(param1:Class) : String
      {
         return getQualifiedClassName(param1).replace(MODULE_SEPERATOR,".");
      }
      
      public static function getInstanceClassName(param1:Object) : String
      {
         return getQualifiedClassName(param1).replace(MODULE_SEPERATOR,".");
      }
      
      public static function getClassByFullName(param1:String) : Class
      {
         return getDefinitionByName(param1) as Class;
      }
   }
}

