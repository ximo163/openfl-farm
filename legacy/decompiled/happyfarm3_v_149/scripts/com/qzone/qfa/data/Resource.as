package com.qzone.qfa.data
{
   import flash.display.LoaderInfo;
   
   public dynamic class Resource
   {
      
      public var type:String;
      
      public var loaded:Boolean;
      
      public var loaderInfo:LoaderInfo;
      
      public var data:*;
      
      public var url:String;
      
      public function Resource()
      {
         super();
      }
   }
}

