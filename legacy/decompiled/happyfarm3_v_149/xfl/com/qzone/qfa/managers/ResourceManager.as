package com.qzone.qfa.managers
{
   import com.qzone.qfa.data.Resource;
   import com.qzone.qfa.data.ResourceType;
   import com.qzone.qfa.events.LoaderEvent;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.Loader;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.geom.Matrix;
   import flash.system.ApplicationDomain;
   import flash.utils.Dictionary;
   
   public class ResourceManager
   {
      
      private static var _instance:ResourceManager;
      
      private var _dataList:Dictionary;
      
      public var loadManager:LoadManager;
      
      public function ResourceManager(param1:Enforcer)
      {
         super();
         this._dataList = new Dictionary(true);
      }
      
      public static function gi() : ResourceManager
      {
         return _instance = _instance || new ResourceManager(new Enforcer());
      }
      
      public static function get instance() : ResourceManager
      {
         return gi();
      }
      
      public function getImageOrSwf(param1:String, param2:Function = null, param3:int = 0, param4:int = 0, param5:Boolean = true, param6:Function = null) : Sprite
      {
         var addImage:Function;
         var resource:Resource;
         var img:Sprite = null;
         var url:String = param1;
         var onCompleted:Function = param2;
         var width:int = param3;
         var height:int = param4;
         var autoBitmap:Boolean = param5;
         var failed:Function = param6;
         img = new Sprite();
         if(!url)
         {
            return img;
         }
         img.mouseChildren = false;
         img.cacheAsBitmap = true;
         resource = this.findResource(url);
         addImage = function(param1:Resource):void
         {
            var ld:Loader = null;
            var res:Resource = param1;
            ld = new Loader();
            ld.contentLoaderInfo.addEventListener(Event.COMPLETE,function():void
            {
               var bmp:Bitmap = null;
               var bmpd:BitmapData = null;
               ld.contentLoaderInfo.removeEventListener(Event.COMPLETE,arguments.callee);
               try
               {
                  bmp = ld.content as Bitmap;
                  if(bmp)
                  {
                     bmpd = bmp.bitmapData.clone();
                     if(width != 0 && height != 0)
                     {
                        bmpd = fixWH(bmpd,width,height,true);
                     }
                     img.addChild(new Bitmap(bmpd,"auto",true));
                  }
                  if(autoBitmap)
                  {
                     bmpd = new BitmapData(ld.width,ld.height,true,0);
                     bmpd.draw(ld.content);
                     if(width != 0 && height != 0)
                     {
                        bmpd = fixWH(bmpd,width,height,true);
                     }
                     img.addChild(new Bitmap(bmpd,"auto",true));
                  }
                  else
                  {
                     img.addChild(ld);
                  }
               }
               catch(err:Error)
               {
                  img.addChild(ld);
               }
               if(onCompleted != null)
               {
                  if(!onCompleted.length)
                  {
                     onCompleted();
                  }
                  else
                  {
                     onCompleted(img);
                  }
               }
            });
            ld.loadBytes(res.data);
         };
         if(Boolean(resource) && Boolean(resource.data) && resource.type == ResourceType.TYPE_BINARY)
         {
            addImage(resource);
         }
         else
         {
            this.loadResource(url,function(param1:Resource):void
            {
               addImage(param1);
            },function():void
            {
               if(failed != null)
               {
                  failed();
               }
            },null,ResourceType.TYPE_BINARY);
         }
         return img;
      }
      
      public function getClass(param1:String) : Class
      {
         var _loc2_:Resource = null;
         var _loc3_:ApplicationDomain = null;
         _loc3_ = ApplicationDomain.currentDomain;
         if(_loc3_.hasDefinition(param1))
         {
            return _loc3_.getDefinition(param1) as Class;
         }
         return null;
      }
      
      public function getResource(param1:String) : Resource
      {
         return this.findResource(param1);
      }
      
      protected function fixWH(param1:BitmapData, param2:Number = 670, param3:Number = 800, param4:Boolean = false) : BitmapData
      {
         var _loc5_:int = param1.width;
         var _loc6_:int = param1.height;
         if(_loc5_ == param2 && _loc6_ == param3)
         {
            return param1;
         }
         if(_loc5_ / param2 > _loc6_ / param3)
         {
            _loc6_ = _loc6_ / _loc5_ * param2;
            _loc5_ = param2;
         }
         else
         {
            _loc5_ = _loc5_ / _loc6_ * param3;
            _loc6_ = param3;
         }
         var _loc7_:Bitmap = new Bitmap(param1,"auto",param4);
         var _loc8_:BitmapData = new BitmapData(_loc5_,_loc6_,true,0);
         _loc8_.draw(_loc7_,new Matrix(_loc5_ / param1.width,0,0,_loc6_ / param1.height,0,0),null,null,null,param4);
         param1.dispose();
         return _loc8_;
      }
      
      public function toString() : String
      {
         var _loc2_:String = null;
         var _loc1_:String = "";
         for(_loc2_ in this._dataList)
         {
            _loc1_ += "[Resource]" + _loc2_ + "," + this._dataList[_loc2_] + "\n";
         }
         return _loc1_;
      }
      
      public function addResource(param1:Resource) : Boolean
      {
         if(Boolean(param1 && param1.url) && Boolean(param1.url.length > 4) && this.findResource(param1.url) == null)
         {
            this._dataList[param1.url] = param1;
            return true;
         }
         return false;
      }
      
      public function removeResource(param1:String) : Boolean
      {
         var _loc2_:Resource = this.findResource(param1);
         if(_loc2_)
         {
            _loc2_.destroy();
            delete this._dataList[param1];
            return true;
         }
         return false;
      }
      
      public function loadResource(param1:String, param2:Function = null, param3:Function = null, param4:Object = null, param5:String = null) : void
      {
         var newResource:Resource;
         var succes:Function = null;
         var fault:Function = null;
         var url:String = param1;
         var onCompleted:Function = param2;
         var onError:Function = param3;
         var params:Object = param4;
         var resourceType:String = param5;
         var targetResource:Resource = this.findResource(url);
         if(Boolean(targetResource) && Boolean(targetResource.data) && (resourceType ? Boolean(targetResource.type == resourceType) : Boolean(true)))
         {
            if(onCompleted != null)
            {
               if(!onCompleted.length)
               {
                  onCompleted();
               }
               else
               {
                  onCompleted(targetResource);
               }
            }
            return;
         }
         if(!this.loadManager)
         {
            this.loadManager = new LoadManager();
         }
         this.loadManager.addEventListener(LoaderEvent.COMPLETE,succes = function(param1:LoaderEvent):void
         {
            var _loc3_:* = undefined;
            if(param1.item.url == url)
            {
               loadManager.removeEventListener(LoaderEvent.COMPLETE,arguments.callee);
               _loc3_ = findResource(url);
               if(_loc3_ != param1.item)
               {
                  delete _dataList[url];
                  addResource(param1.item as Resource);
               }
               if(fault != null)
               {
                  loadManager.removeEventListener(LoaderEvent.ERROR,fault);
               }
               if(onCompleted != null)
               {
                  if(!onCompleted.length)
                  {
                     onCompleted();
                  }
                  else
                  {
                     onCompleted(param1.item);
                  }
               }
            }
         });
         if(onError != null)
         {
            this.loadManager.addEventListener(LoaderEvent.ERROR,fault = function(param1:LoaderEvent):void
            {
               if(Boolean(param1.item) && param1.item.url == url)
               {
                  loadManager.removeEventListener(LoaderEvent.ERROR,arguments.callee);
                  if(succes != null)
                  {
                     loadManager.removeEventListener(LoaderEvent.COMPLETE,succes);
                  }
                  onError();
               }
            });
         }
         newResource = this.loadManager.add(url);
         if(newResource)
         {
            if(resourceType)
            {
               newResource.type = resourceType;
            }
            this.addResource(newResource);
            this.loadManager.start();
         }
      }
      
      public function getClassInstance(param1:String) : *
      {
         var _loc2_:Class = this.getClass(param1);
         if(!_loc2_)
         {
            return null;
         }
         return new _loc2_();
      }
      
      public function destroy() : void
      {
         this.removeAll();
         this._dataList = null;
         _instance = null;
      }
      
      public function removeAll() : void
      {
         var _loc1_:String = null;
         for(_loc1_ in this._dataList)
         {
            Resource(this._dataList[_loc1_]).destroy();
            delete this._dataList[_loc1_];
         }
      }
      
      private function findResource(param1:String) : Resource
      {
         return this._dataList[param1] as Resource;
      }
   }
}

class Enforcer
{
   
   public function Enforcer()
   {
      super();
   }
}
