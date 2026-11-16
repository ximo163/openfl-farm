package common.view.floating
{
   import common.CommonData;
   import common.Consts;
   import common.GetCropID;
   import flash.display.Loader;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.SecurityErrorEvent;
   import flash.net.URLRequest;
   import flash.system.LoaderContext;
   import flash.system.SecurityDomain;
   import interfaces.IMsgCenter;
   
   public class HarvestAnimationCustom extends FloatingBase
   {
      
      private var _loader:Loader;
      
      private var _text:String;
      
      public function HarvestAnimationCustom(param1:IMsgCenter)
      {
         super(param1);
         super.floatName = Consts.FLOAT_TYPE_HAC;
         this._loader = new Loader();
         addChild(this._loader);
         addEventListener(Event.REMOVED_FROM_STAGE,this.onRemoveFromStage,false,0,true);
      }
      
      private function onRemoveFromStage(param1:Event) : void
      {
         removeEventListener(Event.REMOVED_FROM_STAGE,this.onRemoveFromStage);
         this.end();
      }
      
      override public function start(param1:Object) : void
      {
         super.start(param1);
         if(param1 != null && param1["type"] != undefined && param1["cId"] != undefined)
         {
            this.text = param1["text"];
            this.setContent(param1["type"],param1["cId"]);
         }
      }
      
      public function setContent(param1:String, param2:int) : void
      {
         if(this._loader == null)
         {
            return;
         }
         this._loader.contentLoaderInfo.addEventListener(Event.COMPLETE,this.onComplete);
         this._loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,this.onComplete);
         this._loader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR,this.onComplete);
         var _loc3_:String = GetCropID.getHarvrstUrl(param2);
         if(_loc3_ == "")
         {
            return;
         }
         this._loader.x = 40 * 0.75;
         this._loader.y = -135 * 0.75;
         if(param2 == 28)
         {
            this._loader.x = 0;
            this._loader.y = 0;
         }
         var _loc4_:URLRequest = new URLRequest(_loc3_);
         var _loc5_:LoaderContext = new LoaderContext(false,CommonData.applicationDomain,SecurityDomain.currentDomain);
         this._loader.load(_loc4_,_loc5_);
      }
      
      public function set text(param1:String) : void
      {
         this._text = param1;
      }
      
      override public function end() : void
      {
         super.end();
         if(this._loader != null)
         {
            this._loader.contentLoaderInfo.removeEventListener(Event.COMPLETE,this.onComplete);
            this._loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR,this.onComplete);
            this._loader.contentLoaderInfo.removeEventListener(SecurityErrorEvent.SECURITY_ERROR,this.onComplete);
            this._loader = null;
         }
      }
      
      private function onEnd(param1:Event) : void
      {
         this._loader.content.removeEventListener("end",this.onEnd);
         this._loader.unload();
         removeChild(this._loader);
         this._loader = null;
         super.close();
      }
      
      private function onComplete(param1:Event) : void
      {
         if(this._loader == null)
         {
            return;
         }
         this._loader.contentLoaderInfo.removeEventListener(Event.COMPLETE,this.onComplete);
         this._loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR,this.onComplete);
         this._loader.contentLoaderInfo.removeEventListener(SecurityErrorEvent.SECURITY_ERROR,this.onComplete);
         if(param1.type == Event.COMPLETE)
         {
            this._loader.content.addEventListener("end",this.onEnd);
         }
         else
         {
            super.close();
         }
      }
   }
}

