package module.FreeGift.widgets2
{
   import common.Settings;
   import common.misc.Utils;
   import common.view.MaterialProxy;
   import events.ViewEvent;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.MouseEvent;
   import flash.net.URLRequest;
   import framework.base.BaseTileItem;
   
   public class SetItem extends BaseTileItem
   {
      
      public static const GET_GIFT_CLICK:String = "getGiftClick";
      
      private var gifts:Object;
      
      private var _data:Object;
      
      private var box:MovieClip;
      
      public function SetItem(param1:Boolean = false)
      {
         super(param1);
         buttonMode = false;
         useHandCursor = false;
         mouseChildren = true;
         this.box = Utils.getMaterial("freeSendItem") as MovieClip;
         addChildAt(this.box,1);
      }
      
      private function onLoaded(param1:Event) : void
      {
         trace("加载成功");
      }
      
      private function onLoadError(param1:IOErrorEvent) : void
      {
         trace("加载失败");
      }
      
      public function init(param1:int) : void
      {
         var _loc2_:MovieClip = null;
         var _loc3_:MaterialProxy = null;
         var _loc4_:Loader = null;
         this._data = param1;
         this.gifts = Settings.getInstance().getFreeGift(param1.toString());
         this.box.title.text = this.gifts["name"] + "X" + this.gifts["num"];
         if(this.gifts["type"] == 7)
         {
            _loc2_ = Utils.getMaterial("HallowExp") as MovieClip;
            this.box.imgMc.addChild(_loc2_);
         }
         else if(this.gifts["type"] != 10)
         {
            _loc3_ = new MaterialProxy();
            _loc3_.setContent(this.gifts["type"],this.gifts["cId"]);
            _loc3_.x = 0;
            _loc3_.y = 0;
            this.box.imgMc.addChild(_loc3_);
         }
         else
         {
            _loc4_ = new Loader();
            _loc4_.load(new URLRequest(Utils.addPrefix(this.gifts["url"])));
            _loc4_.scaleX = _loc4_.scaleY = 0.5;
            this.box.imgMc.addChild(_loc4_);
         }
         if(this.gifts["type"] == 909090)
         {
            this.box.itemRight.gotoAndStop(26);
         }
         else if(this.gifts["cId"] != 40)
         {
            this.box.itemRight.gotoAndStop(this.gifts["type"]);
         }
         else
         {
            this.box.itemRight.gotoAndStop(25);
         }
         this.box.setBtn.addEventListener(MouseEvent.CLICK,this.setGiftHandler,false,0,true);
         this.box.imgMc.addEventListener(MouseEvent.ROLL_OVER,this.HeadRollOver,false,0,true);
         this.box.imgMc.addEventListener(MouseEvent.ROLL_OUT,this.HeadRollOut,false,0,true);
      }
      
      private function HeadRollOver(param1:MouseEvent) : void
      {
         var _loc2_:ViewEvent = new ViewEvent(CHILD_OVER,true);
         _loc2_.data = this.gifts;
         dispatchEvent(_loc2_);
      }
      
      override public function set data(param1:Object) : void
      {
         super.data = param1;
         if(!data)
         {
            return;
         }
         this.graphics.clear();
         this.init(int(param1));
      }
      
      private function HeadRollOut(param1:MouseEvent) : void
      {
         var _loc2_:ViewEvent = new ViewEvent(CHILD_OUT,true);
         dispatchEvent(_loc2_);
      }
      
      private function setGiftHandler(param1:MouseEvent) : void
      {
         var _loc2_:ViewEvent = new ViewEvent(CHILD_CLICK,true);
         _loc2_.data = {"data":this.gifts};
         dispatchEvent(_loc2_);
      }
   }
}

