package module.warehouse.house.widgets
{
   import com.qzone.qui.controls.Button;
   import com.qzone.utils.AlignUtil;
   import com.qzone.utils.GraphicsUtil;
   import common.Language;
   import common.misc.Utils;
   import events.ViewEvent;
   import flash.display.Bitmap;
   import flash.display.Loader;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TextEvent;
   import flash.filters.GlowFilter;
   import flash.geom.Rectangle;
   import flash.net.URLRequest;
   import flash.system.LoaderContext;
   import flash.text.TextField;
   import flash.text.TextFormat;
   
   public class FlowerRenderItem extends Sprite
   {
      
      public static const SEND_FLOWER:String = "SendFlower";
      
      public static const PREVIEW:String = "PreviewFlower";
      
      public static const NOT_ENOUGH:String = "NotEnough";
      
      public static const CHILD_CLICK:String = "childClick";
      
      public static const CHILD_OUT:String = "childOut";
      
      public static const CHILD_OVER:String = "childOver";
      
      private var _pictureSize:int;
      
      private var _txtDesc:TextField;
      
      protected var _item:Object;
      
      private var _ld:Loader;
      
      private var _border:Sprite;
      
      private var _txtName:TextField;
      
      public function FlowerRenderItem()
      {
         super();
         this._pictureSize = 0;
         this._border = Utils.getMaterial("ItemBg") as Sprite;
         this._border.name = "ItemBg";
         addChild(this._border);
         this._border.buttonMode = true;
         this._ld = new Loader();
         this._ld.mouseChildren = this._ld.mouseEnabled = false;
         this._ld.contentLoaderInfo.addEventListener(Event.COMPLETE,function():void
         {
            var _loc2_:Loader = null;
            _loc2_ = arguments[0].target.loader;
            _loc2_.width = _loc2_.height = _pictureSize - 4;
            _loc2_.x = (_pictureSize - _loc2_.width) / 2;
            _loc2_.y = (_pictureSize - _loc2_.height) / 2;
            Bitmap(_loc2_.content).smoothing = true;
            _loc2_.contentLoaderInfo.removeEventListener(Event.COMPLETE,arguments.callee);
         });
         addChild(this._ld);
         this._txtName = new TextField();
         this._txtName.selectable = false;
         this._txtName.height = 22;
         this._txtName.width = 98;
         this._txtName.defaultTextFormat = new TextFormat("Verdana",12,6710886);
         addChild(this._txtName);
         this._txtDesc = new TextField();
         this._txtDesc.selectable = false;
         this._txtDesc.defaultTextFormat = new TextFormat("Verdana",12,16777215);
         this._txtDesc.filters = [new GlowFilter(30148,1,3,3)];
         this._txtDesc.autoSize = "left";
         addChild(this._txtDesc);
         GraphicsUtil.draw(this,16777215,0,new Rectangle(0,0,90,145));
         this._border.addEventListener(MouseEvent.ROLL_OVER,this.onOver);
         this._border.addEventListener(MouseEvent.ROLL_OUT,this.onOut);
         this._border.addEventListener(MouseEvent.CLICK,this.onSendOutFlower);
         addEventListener(TextEvent.LINK,this.onLinkClicked);
      }
      
      private function onSendOutFlower(param1:MouseEvent) : void
      {
         var _loc2_:ViewEvent = new ViewEvent(SEND_FLOWER,true);
         _loc2_.data = this._item;
         dispatchEvent(_loc2_);
      }
      
      public function get data() : Object
      {
         return this._item;
      }
      
      private function onOut(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         var _loc2_:ViewEvent = new ViewEvent(CHILD_OUT,true);
         _loc2_.data = this._item;
         dispatchEvent(_loc2_);
      }
      
      public function set data(param1:Object) : void
      {
         var _loc2_:Button = null;
         var _loc3_:TextField = null;
         if(this._item == param1)
         {
            return;
         }
         this._item = param1;
         if(this._item == null)
         {
            return;
         }
         if(this._item["mode"] == 0)
         {
            this._pictureSize = 90;
            this._txtName.text = this._item["fName"];
            this._txtName.y = this._pictureSize;
            this._txtDesc.htmlText = "<a href=\'event:view\'>" + "预览" + "</a>";
            this._txtDesc.x = this._pictureSize - this._txtDesc.width - 2;
            this._txtDesc.y = this._pictureSize;
            if(this._item["canMake"] == true)
            {
               _loc2_ = new Button();
               _loc2_.defaultSkin = Utils.getClass("ButtonBlue");
               _loc2_.width = 60;
               _loc2_.height = 25;
               _loc2_.text = Language.L["赠送花束"];
               _loc2_.x = AlignUtil.middle(this._pictureSize,_loc2_.width);
               _loc2_.y = this._txtName.y + 22;
               _loc2_.clickFn = this.onSendOutFlower;
               addChild(_loc2_);
            }
            else
            {
               _loc3_ = new TextField();
               _loc3_.defaultTextFormat = new TextFormat("Verdana",12,16711680);
               _loc3_.selectable = false;
               _loc3_.width = 80;
               _loc3_.htmlText = "<a href=\"event:cant\">材料不足</a>";
               _loc3_.y = this._txtName.y + 22;
               _loc3_.height = 22;
               addChild(_loc3_);
            }
         }
         else
         {
            this._pictureSize = 96;
            this._txtName.text = this._item["friendName"];
            this._txtName.x = (this._pictureSize - this._txtName.width) * 0.5;
            this._txtName.y = this._pictureSize;
            this._txtName.autoSize = "center";
            this._txtDesc.htmlText = "<a href=\'event:view\'>" + "点击查看" + "</a>";
            this._txtDesc.x = this._pictureSize - this._txtDesc.width - 2;
            this._txtDesc.y = this._pictureSize - this._txtDesc.height - 2;
         }
         this._border.width = this._border.height = this._pictureSize;
         if(this._item["pic"] != undefined && this._item["pic"] != "")
         {
            this._ld.load(new URLRequest(this._item["pic"]),new LoaderContext(true));
         }
      }
      
      private function onOver(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         var _loc2_:ViewEvent = new ViewEvent(CHILD_OVER,true);
         _loc2_.data = this._item;
         dispatchEvent(_loc2_);
      }
      
      private function onLinkClicked(param1:TextEvent) : void
      {
         param1.stopPropagation();
         var _loc2_:ViewEvent = null;
         if(param1.text == "view")
         {
            _loc2_ = new ViewEvent(PREVIEW,true);
            _loc2_.data = this._item;
            dispatchEvent(_loc2_);
         }
         else if(param1.text == "cant")
         {
            _loc2_ = new ViewEvent(NOT_ENOUGH,true);
            _loc2_.data = this._item;
            dispatchEvent(_loc2_);
         }
      }
   }
}

