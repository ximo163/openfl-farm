package mc.view.main.window.shop
{
   import com.minutes.ui.collections.LipiListChild;
   import common.MaterialLib;
   import flash.display.*;
   import flash.events.MouseEvent;
   import flash.net.URLRequest;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormat;
   import flash.text.TextFormatAlign;
   import mc.control.ViewControl;
   import mc.events.TipEvent;
   import mc.view.ViewEvent;
   import mc.view.common.MaterialProxy;
   import mc.view.common.MoneyIcon;
   import mc.view.farm.GetCropID;
   
   public class ShopDiyItem extends LipiListChild
   {
      
      public static var CHILD_OVER:String = "childOver";
      
      public static var CHILD_OUT:String = "childOut";
      
      public static var CHILD_MOVE:String = "childMove";
      
      private var _material:MaterialProxy;
      
      private var priceText:TextField;
      
      private var _haveBuyIcon:Sprite;
      
      private var goldIcon:MoneyIcon;
      
      public function ShopDiyItem()
      {
         super();
         this.buttonMode = true;
         this.useHandCursor = true;
         this.priceText = new TextField();
         this.priceText.defaultTextFormat = new TextFormat("Verdana",12,null,true,null,null,null,null,TextFormatAlign.LEFT,null,null,null,5);
         this.priceText.selectable = false;
         this.priceText.width = 200;
         this.priceText.autoSize = TextFieldAutoSize.LEFT;
         this.priceText.multiline = true;
         addChild(this.priceText);
         this.priceText.x = 0;
         this.priceText.y = 157;
         this._material = new MaterialProxy();
         addChild(this._material);
         addEventListener(MouseEvent.CLICK,this.onClick);
         addEventListener(MouseEvent.ROLL_OVER,this.onOver);
         addEventListener(MouseEvent.ROLL_OUT,this.onOut);
         var _loc1_:Shape = new Shape();
         _loc1_.graphics.beginFill(16711680,0);
         _loc1_.graphics.drawRect(0,0,10,1);
         _loc1_.graphics.endFill();
         _loc1_.y = 100;
         addChild(_loc1_);
      }
      
      private function onClick(param1:MouseEvent) : void
      {
         var _loc2_:ViewEvent = new ViewEvent(ViewEvent.CHILD_CLICK,true);
         _loc2_.data = data;
         dispatchEvent(_loc2_);
      }
      
      public function updateHaveBuyIcon(param1:Boolean) : void
      {
         var _loc2_:TextField = null;
         var _loc3_:TextFormat = null;
         if(param1)
         {
            if(!this._haveBuyIcon)
            {
               this._haveBuyIcon = new Sprite();
               this._haveBuyIcon.mouseEnabled = false;
               this._haveBuyIcon.mouseChildren = false;
               this._haveBuyIcon.graphics.beginGradientFill(GradientType.LINEAR,[10797638,10797638],[0.6,0.6],[0,255]);
               this._haveBuyIcon.graphics.drawRoundRect(5,0,width - 12,40,10,10);
               this._haveBuyIcon.graphics.endFill();
               _loc2_ = new TextField();
               _loc2_.width = width;
               _loc2_.height = 40;
               _loc3_ = new TextFormat("微软雅黑",20,16777215);
               _loc3_.align = "center";
               _loc3_.bold = true;
               _loc2_.defaultTextFormat = _loc3_;
               _loc2_.text = "已购买";
               this._haveBuyIcon.addChild(_loc2_);
               _loc2_.y = 8;
            }
            if(!this._haveBuyIcon.parent)
            {
               addChild(this._haveBuyIcon);
               this._haveBuyIcon.y = 60;
            }
         }
         else if(Boolean(this._haveBuyIcon) && Boolean(this._haveBuyIcon.parent))
         {
            removeChild(this._haveBuyIcon);
            this._haveBuyIcon = null;
         }
      }
      
      private function onOut(param1:MouseEvent) : void
      {
         var _loc2_:TipEvent = new TipEvent(TipEvent.TIP_HIDE);
         _loc2_.tipType = "MouseTip";
         ViewControl.getInstance().dispatchEvent(_loc2_);
      }
      
      override public function set data(param1:Object) : void
      {
         if(!param1)
         {
            return;
         }
         super.data = param1;
         var _loc2_:Loader = new Loader();
         addChild(_loc2_);
         _loc2_.load(new URLRequest(GetCropID.getShopDiyUrl(data["itemId"])));
         var _loc3_:Sprite = MaterialLib.getInstance().getMaterial("DiyLine") as Sprite;
         addChild(_loc3_);
         var _loc4_:String = "";
         if(param1["price"] > 0)
         {
            _loc4_ += "<font color=\'#cc3300\'>金币 <font/><font color=\'#f2693d\'>" + param1["price"] + "</font> ";
         }
         if(param1["FBPrice"] > 0 && param1["YFBPrice"] > 0)
         {
            if(param1["price"] > 0)
            {
               _loc4_ += "<br>";
            }
            _loc4_ += "<font color=\'#895313\'>元宝 </font><font color=\'#f2693d\'>" + param1["FBPrice"] + "</font> <font color=\'#f39800\'>(VIP价 " + param1["YFBPrice"] + " )</font>";
         }
         this.priceText.htmlText = _loc4_;
      }
      
      private function onOver(param1:MouseEvent) : void
      {
         var _loc2_:TipEvent = new TipEvent(TipEvent.TIP_SHOW);
         _loc2_.tipType = "MouseTip";
         _loc2_.tipArgument = _loc2_.tipArgument = data["itemName"] + "\n" + "可得经验：" + data["exp"];
         ViewControl.getInstance().dispatchEvent(_loc2_);
      }
   }
}

