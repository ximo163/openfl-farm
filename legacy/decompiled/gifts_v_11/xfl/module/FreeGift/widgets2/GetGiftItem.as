package module.FreeGift.widgets2
{
   import com.qzone.qui.styles.Style;
   import common.Settings;
   import common.misc.Utils;
   import common.view.MaterialProxy;
   import events.ViewEvent;
   import flash.display.DisplayObject;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.MouseEvent;
   import flash.filters.GlowFilter;
   import flash.net.URLRequest;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormat;
   import framework.base.BaseTileItem;
   
   public class GetGiftItem extends BaseTileItem
   {
      
      public static const GET_GIFT_CLICK:String = "getGiftClick";
      
      public static const THANKS_OVER:String = "thanksover";
      
      public static const THANKS_OUT:String = "thanksout";
      
      private var errorType:String = "";
      
      private var gifts:Object;
      
      private var _data:Object;
      
      private var box:MovieClip;
      
      public function GetGiftItem(param1:Boolean = false)
      {
         super();
         buttonMode = false;
         useHandCursor = false;
         mouseChildren = true;
         this.box = Utils.getMaterial("getfreeGiftItem") as MovieClip;
         addChildAt(this.box,1);
      }
      
      private function HeadRollOut(param1:MouseEvent) : void
      {
         var _loc2_:ViewEvent = new ViewEvent(CHILD_OUT,true);
         dispatchEvent(_loc2_);
      }
      
      private function AddHead() : void
      {
         var _loc1_:MovieClip = null;
         var _loc2_:MaterialProxy = null;
         var _loc3_:Loader = null;
         if(this.gifts == null)
         {
            return;
         }
         if(this.gifts["type"] == 7)
         {
            _loc1_ = Utils.getMaterial("HallowExp") as MovieClip;
            this.box.head_mc.addChild(_loc1_);
         }
         else if(this.gifts["type"] != 10)
         {
            _loc2_ = new MaterialProxy();
            _loc2_.setContent(this.gifts["type"],this.gifts["cId"]);
            this.box.head_mc.addChild(_loc2_);
         }
         else
         {
            _loc3_ = new Loader();
            _loc3_.load(new URLRequest(Utils.addPrefix(this.gifts["url"])));
            _loc3_.scaleX = _loc3_.scaleY = 0.5;
            this.box.head_mc.addChild(_loc3_);
         }
         if(this.gifts["cId"] != 40)
         {
            this.box.head_mc.itemRight.gotoAndStop(this.gifts["type"]);
         }
         else
         {
            this.box.head_mc.itemRight.gotoAndStop(25);
         }
      }
      
      private function thanksHandler(param1:MouseEvent) : void
      {
         var _loc2_:ViewEvent = new ViewEvent(CHILD_CLICK,true);
         _loc2_.data = this._data;
         dispatchEvent(_loc2_);
      }
      
      private function onLoadError(param1:IOErrorEvent) : void
      {
         trace("加载失败");
      }
      
      private function AddText() : void
      {
         var _loc5_:MovieClip = null;
         var _loc1_:GlowFilter = new GlowFilter(16777215,1,2,2,10,1,false,false);
         var _loc2_:TextField = new TextField();
         _loc2_.x = 75;
         _loc2_.y = 32;
         _loc2_.width = 230;
         _loc2_.selectable = false;
         _loc2_.autoSize = TextFieldAutoSize.LEFT;
         _loc2_.wordWrap = true;
         _loc2_.htmlText = "";
         var _loc3_:Date = new Date(this._data["time"] * 1000);
         _loc2_.htmlText = _loc2_.htmlText + "<font color=\'#ff6600\'>" + this._data["nick"] + "</font><font color=\'#006DB7\'>" + "在" + _loc3_.getFullYear() + "-" + (_loc3_.getMonth() + 1) + "-" + _loc3_.getDate() + " 赠送您</font>";
         _loc2_.htmlText = _loc2_.htmlText + "<font color=\'#ff6600\'>" + this.gifts["name"] + "</font><font color=\'#006DB7\'>" + this.gifts["num"] + "个" + "</font>";
         var _loc4_:TextFormat = new TextFormat("SimSun");
         _loc4_.size = 14;
         _loc4_.bold = true;
         _loc4_.leading = 10;
         _loc2_.setTextFormat(_loc4_);
         addChild(_loc2_);
         this.box.getGiftBtn.addEventListener(MouseEvent.CLICK,this.getGiftHandler,false,0,true);
         this.box.thanksBtn.addEventListener(MouseEvent.ROLL_OVER,this.thanksRollOver,false,0,true);
         this.box.thanksBtn.addEventListener(MouseEvent.ROLL_OUT,this.thanksRollOut,false,0,true);
         if(this.errorType == "")
         {
            this.box.thanksBtn.buttonMode = true;
            this.box.thanksBtn.addEventListener(MouseEvent.CLICK,this.thanksHandler,false,0,true);
         }
         this.box.head_mc.addEventListener(MouseEvent.ROLL_OVER,this.HeadRollOver,false,0,true);
         this.box.head_mc.addEventListener(MouseEvent.ROLL_OUT,this.HeadRollOut,false,0,true);
         if(this.errorType == "repeat")
         {
            _loc5_ = Utils.getMaterial("freegiftToday") as MovieClip;
            _loc5_.x = 171;
            _loc5_.y = 66;
            addChild(_loc5_);
         }
      }
      
      private function thanksRollOut(param1:MouseEvent) : void
      {
         var _loc2_:ViewEvent = new ViewEvent(THANKS_OUT,true);
         dispatchEvent(_loc2_);
      }
      
      public function init(param1:Object) : void
      {
         this._data = param1;
         this.gifts = Settings.getInstance().getFreeGift(this._data["type"]);
         this.AddTitle(param1["nick"]);
         this.AddHead();
         this.AddText();
      }
      
      private function getGiftHandler(param1:MouseEvent) : void
      {
         this.enableGetButton = false;
         var _loc2_:ViewEvent = new ViewEvent(GET_GIFT_CLICK,true);
         _loc2_.data = {"id":this._data["id"]};
         dispatchEvent(_loc2_);
      }
      
      override public function set data(param1:Object) : void
      {
         var _loc2_:DisplayObject = null;
         super.data = param1;
         if(!data)
         {
            return;
         }
         if(data.hasOwnProperty("status"))
         {
            if(data["status"] == 1)
            {
               this.box.getGiftBtn.visible = false;
               this.box.getGiftBtn.mouseEnabled = false;
            }
         }
         if(data.hasOwnProperty("AllCannot"))
         {
            if(data["AllCannot"] == 1)
            {
               this.errorType = "count";
               this.box.thanksBtn.gotoAndStop(2);
            }
         }
         else if(data.hasOwnProperty("alread"))
         {
            if(data["alread"] == true)
            {
               this.errorType = "repeat";
               this.box.thanksBtn.gotoAndStop(2);
            }
         }
         if(param1 == null)
         {
            _loc2_ = getChildByName("__GIFT__");
            if(_loc2_ != null)
            {
               removeChild(_loc2_);
            }
            _loc2_ = getChildByName("__NUM__");
            if(_loc2_ != null)
            {
               removeChild(_loc2_);
            }
            return;
         }
         this.graphics.clear();
         this.init(param1);
      }
      
      private function AddTitle(param1:String = "") : void
      {
         if(param1)
         {
            this.box.title.text = param1;
         }
      }
      
      private function HeadRollOver(param1:MouseEvent) : void
      {
         var _loc2_:ViewEvent = new ViewEvent(CHILD_OVER,true);
         _loc2_.data = this.gifts;
         dispatchEvent(_loc2_);
      }
      
      public function set enableGetButton(param1:Boolean) : void
      {
         if(param1 == true)
         {
            this.box["getGiftBtn"].filters = null;
            this.box["getGiftBtn"].mouseEnabled = true;
         }
         else
         {
            this.box["getGiftBtn"].filters = Style.getDisableFilter();
            this.box["getGiftBtn"].mouseEnabled = false;
         }
      }
      
      private function thanksRollOver(param1:MouseEvent) : void
      {
         var _loc2_:ViewEvent = new ViewEvent(THANKS_OVER,true);
         _loc2_.data = {"errorType":this.errorType};
         dispatchEvent(_loc2_);
      }
      
      private function onLoaded(param1:Event) : void
      {
         trace("加载成功");
      }
   }
}

