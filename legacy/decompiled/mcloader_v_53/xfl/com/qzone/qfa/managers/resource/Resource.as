package com.qzone.qfa.managers.resource
{
   import flash.display.Bitmap;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.Loader;
   import flash.display.LoaderInfo;
   import flash.display.MovieClip;
   
   public dynamic class Resource
   {
      
      public var loaderInfo:LoaderInfo;
      
      public var message:String;
      
      public var data:*;
      
      public var loader:Object;
      
      public var url:String;
      
      public var type:String;
      
      public function Resource()
      {
         super();
      }
      
      public function destroy() : void
      {
         var _loc1_:DisplayObjectContainer = null;
         if(this.data is DisplayObject)
         {
            _loc1_ = DisplayObject(this.data).parent;
            if(_loc1_ is Loader)
            {
               if(Loader(_loc1_).hasOwnProperty("unloadAndStop"))
               {
                  Loader(_loc1_)["unloadAndStop"]();
               }
               else
               {
                  Loader(_loc1_).unload();
               }
            }
         }
         if(this.data is MovieClip && !(_loc1_ is Loader))
         {
            _loc1_.removeChild(MovieClip(this.data));
         }
         else if(this.data is Bitmap)
         {
            Bitmap(this.data).bitmapData.dispose();
            Bitmap(this.data).bitmapData = null;
         }
         this.url = undefined;
         this.type = undefined;
         this.data = null;
      }
      
      public function toString() : String
      {
         return "[Resource]{url:" + this.url + ", type:" + this.type + "}";
      }
   }
}

