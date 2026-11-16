package module.recall.widgets
{
   import com.qzone.corelib.net.RSLManager;
   import common.CommonData;
   import common.GetCropID;
   import common.Settings;
   import common.misc.Utils;
   import events.ViewEvent;
   import flash.display.DisplayObject;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.MouseEvent;
   import flash.filters.GlowFilter;
   import flash.net.URLRequest;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormat;
   import framework.base.BaseTileItem;
   
   public class BackItem extends BaseTileItem
   {
      
      private var box:MovieClip;
      
      public function BackItem(param1:Boolean = false)
      {
         super();
         buttonMode = false;
         useHandCursor = false;
         mouseChildren = true;
         this.box = Utils.getMaterial("recallItem") as MovieClip;
         addChildAt(this.box,1);
      }
      
      private function AddHead(param1:String = null) : void
      {
         var _loc2_:Loader = null;
         if(_loc2_ != null)
         {
            this.removeChild(_loc2_);
            _loc2_ = null;
         }
         _loc2_ = new Loader();
         _loc2_.name = "__PHOTO__";
         _loc2_.contentLoaderInfo.addEventListener(Event.COMPLETE,this.onLoaded);
         _loc2_.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,this.onLoadError);
         if(param1 != null && param1 != "")
         {
            _loc2_.load(new URLRequest(param1));
         }
         this.box.headPic.addChild(_loc2_);
      }
      
      private function onLoadError(param1:IOErrorEvent) : void
      {
         trace("加载失败");
      }
      
      private function onLoaded(param1:Event) : void
      {
         trace("加载成功");
      }
      
      private function AddText(param1:String) : void
      {
         var _loc2_:GlowFilter = new GlowFilter(16777215,1,2,2,10,1,false,false);
         this.box.Name_txt.text = param1;
         var _loc3_:Array = ["喊你回家种菜!","你的菜都枯萎了看着好心疼！","你不在，摘菜都没有动力啦！"];
         var _loc4_:int = Math.floor(Math.random() * _loc3_.length);
         this.box.message_txt.text = _loc3_[_loc4_];
         var _loc5_:TextFormat = new TextFormat();
         _loc5_.bold = true;
         this.box.message_txt.setTextFormat(_loc5_);
      }
      
      private function onOKHandler(param1:MouseEvent) : void
      {
         var _loc2_:ViewEvent = new ViewEvent(CHILD_CLICK,true);
         _loc2_.data = _item;
         dispatchEvent(_loc2_);
      }
      
      public function init(param1:Object) : void
      {
         this.AddHead(param1["portrail_url"]);
         this.AddText(param1["nick"]);
         this.AddGift();
         this.AddButton();
      }
      
      private function AddGift() : void
      {
         var giftUrl:String;
         var giftName:String = null;
         var onOutputIconLoaded:Function = null;
         onOutputIconLoaded = function(param1:Object):void
         {
            var _loc3_:TextField = null;
            var _loc2_:Sprite = RSLManager.getMaterial(giftName) as Sprite;
            if(_loc2_)
            {
               _loc2_.scaleX = _loc2_.scaleY = 0.8;
               _loc2_.x = 10;
               _loc2_.y = 2;
               _loc2_.name = "__GIFT__";
               param1["box"].giftBox.addChild(_loc2_);
            }
            _loc3_ = new TextField();
            _loc3_.autoSize = TextFieldAutoSize.LEFT;
            _loc3_.x = 52;
            _loc3_.y = 40;
            _loc3_.selectable = false;
            _loc3_.htmlText = "<font color=\'#FD7902\'><b>5</b></font>";
            _loc3_.background = true;
            _loc3_.name = "__NUM__";
            param1["box"].giftBox.addChild(_loc3_);
         };
         giftName = Settings.getInstance().getSeedName(458);
         if(giftName == null || giftName == "")
         {
            return;
         }
         giftUrl = GetCropID.getSeedUrl(458);
         CommonData.rslManager.requestClass(giftName,onOutputIconLoaded,giftUrl,{"box":this.box});
      }
      
      private function AddButton() : void
      {
         this.box.accept_btn.addEventListener(MouseEvent.CLICK,this.onOKHandler);
      }
      
      override public function set data(param1:Object) : void
      {
         var _loc2_:DisplayObject = null;
         super.data = param1;
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
            _loc2_ = getChildByName("__PHOTO__");
            if(_loc2_ != null)
            {
               removeChild(_loc2_);
            }
            return;
         }
         this.graphics.clear();
         this.init(param1);
      }
   }
}

