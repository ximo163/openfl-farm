package mc.view.farm
{
   import common.LocalData;
   import common.MaterialLib;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.net.URLRequest;
   import mc.control.MainCommand;
   import mc.control.ViewControl;
   
   public class AniScene extends Sprite
   {
      
      private var _loader:Loader;
      
      private var _ani:MovieClip;
      
      public function AniScene()
      {
         super();
      }
      
      private function onIOError(param1:IOErrorEvent) : void
      {
         this._loader = null;
      }
      
      private function onAniComplete(param1:Event = null) : void
      {
         if(Boolean(this._ani) && Boolean(this._ani.parent))
         {
            this._ani.removeEventListener(Event.COMPLETE,this.onAniComplete);
            removeChild(this._ani);
            this._ani = null;
            ViewControl.getInstance().dispatchEvent(new Event("upgrade_end"));
         }
      }
      
      private function startUpgrage() : void
      {
         var _loc1_:int = 0;
         this.onAniComplete();
         if(LocalData.reclaimType == 3 || LocalData.reclaimType == 1)
         {
            _loc1_ = 1;
         }
         else if(LocalData.reclaimType == 4 || LocalData.reclaimType == 2)
         {
            _loc1_ = 2;
         }
         this._ani = MaterialLib.getInstance().getMaterial("Upgrade" + _loc1_) as MovieClip;
         addChild(this._ani);
         ViewControl.getInstance().dispatchEvent(new Event("upgrade_start"));
         if(LocalData.reclaimType == 2 || LocalData.reclaimType == 4)
         {
            this._ani.x = 310;
            this._ani.y = 350;
         }
         if(LocalData.reclaimType == 1 || LocalData.reclaimType == 3)
         {
            this._ani.scaleX = -1;
            this._ani.x = 665;
            this._ani.y = 380;
         }
      }
      
      public function playAni() : void
      {
         if(this._ani)
         {
            this._ani.play();
            this._ani.addEventListener(Event.COMPLETE,this.onAniComplete);
         }
      }
      
      public function addAni() : void
      {
         if(!this._loader)
         {
            this._loader = new Loader();
            this._loader.contentLoaderInfo.addEventListener(Event.COMPLETE,this.onComp);
            this._loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,this.onIOError);
            this._loader.load(new URLRequest(MainCommand.getModule2Url("upgrade")["url"]));
         }
         else
         {
            this.startUpgrage();
         }
      }
      
      private function onComp(param1:Event) : void
      {
         MaterialLib.getInstance().push(param1.currentTarget.applicationDomain);
         this.startUpgrage();
      }
      
      public function removeAni() : void
      {
         this.onAniComplete();
      }
   }
}

