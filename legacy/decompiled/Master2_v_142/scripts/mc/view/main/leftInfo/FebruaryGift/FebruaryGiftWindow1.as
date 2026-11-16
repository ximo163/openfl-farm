package mc.view.main.leftInfo.FebruaryGift
{
   import common.INI;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.net.URLRequest;
   import mc.model.MData;
   import mc.view.common.BaseWindow;
   import mc.view.farm.GetCropID;
   import mc.view.main.cursor.Cursor;
   
   public class FebruaryGiftWindow1 extends BaseWindow
   {
      
      private var isReload:Boolean = false;
      
      private var _theBox:MovieClip;
      
      public function FebruaryGiftWindow1()
      {
         var _loader:Loader;
         super();
         this.closeVisible = false;
         this.width = 0;
         this.height = 0;
         this.mode = true;
         this.visible = false;
         this.addEventListener(MouseEvent.ROLL_OVER,function(param1:MouseEvent):void
         {
            Cursor.useSystem(true);
         });
         FebruaryGiftModel.gi().addEventListener(FebruaryGiftEvent.OPEN_FEBRUARYGIFT1,this.onOpenFebruaryGift,false,0,true);
         _loader = new Loader();
         _loader.contentLoaderInfo.addEventListener(Event.COMPLETE,this.WinComplete);
         _loader.load(new URLRequest(GetCropID.addPrefix(String(INI.getInstance().data.february.@window1))));
      }
      
      private function closeClick(param1:MouseEvent) : void
      {
         var _loc2_:MData = null;
         Cursor.setCursor("CursorArrow");
         if(this.isReload)
         {
            _loc2_ = MData.getInstance();
            _loc2_.farmData.reloadUserSeed = true;
            _loc2_.mainData.reloadUserCrop = true;
         }
         this.removeAll();
         this.closeHandler();
      }
      
      private function buyClick(param1:MouseEvent) : void
      {
         FebruaryGiftModel.gi().isBuy9 = true;
         var _loc2_:FebruaryGiftControl = new FebruaryGiftControl();
         _loc2_.verifyQBRequest();
      }
      
      private function WinComplete(param1:Event) : void
      {
         this.visible = true;
         this._theBox = param1.target.content as MovieClip;
         this.addChildAt(this._theBox,0);
         var _loc2_:Point = new Point(-this._theBox.width / 2 + this.width / 2,-this._theBox.height / 2 + this.height / 2);
         this._theBox.x = _loc2_.x;
         this._theBox.y = _loc2_.y;
         this._theBox.closeBtn.addEventListener(MouseEvent.CLICK,this.closeClick);
         this._theBox.buyBtn.addEventListener(MouseEvent.CLICK,this.buyClick);
         Cursor.useSystem(true);
      }
      
      private function onOpenFebruaryGift(param1:FebruaryGiftEvent) : void
      {
         this.isReload = true;
      }
   }
}

