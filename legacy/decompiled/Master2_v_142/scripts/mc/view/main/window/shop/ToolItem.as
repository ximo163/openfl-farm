package mc.view.main.window.shop
{
   import com.minutes.ui.collections.LipiListChild;
   import flash.display.Shape;
   import flash.events.MouseEvent;
   import flash.filters.GlowFilter;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormat;
   import flash.text.TextFormatAlign;
   import mc.control.ViewControl;
   import mc.events.TipEvent;
   import mc.view.ViewEvent;
   import mc.view.common.MaterialProxy;
   import mc.view.common.MoneyIcon;
   
   public class ToolItem extends LipiListChild
   {
      
      public static var CHILD_OVER:String = "childOver";
      
      public static var CHILD_OUT:String = "childOut";
      
      public static var CHILD_MOVE:String = "childMove";
      
      private var _material:MaterialProxy;
      
      private var priceText:TextField;
      
      private var goldIcon:MoneyIcon;
      
      public function ToolItem()
      {
         super();
         this.buttonMode = true;
         this.useHandCursor = true;
         this.priceText = new TextField();
         this.priceText.defaultTextFormat = new TextFormat("Verdana",11,294176,true,null,null,null,null,TextFormatAlign.LEFT);
         this.priceText.selectable = false;
         this.priceText.width = 45;
         this.priceText.height = 23;
         addChild(this.priceText);
         this.priceText.x = 27;
         this.priceText.y = 65;
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
      
      private function onOut(param1:MouseEvent) : void
      {
         var _loc2_:TipEvent = new TipEvent(TipEvent.TIP_HIDE);
         _loc2_.tipType = "MouseTip";
         ViewControl.getInstance().dispatchEvent(_loc2_);
      }
      
      private function onOver(param1:MouseEvent) : void
      {
         var _loc2_:TipEvent = new TipEvent(TipEvent.TIP_SHOW);
         _loc2_.tipType = "MouseTip";
         _loc2_.tipArgument = data.tName;
         ViewControl.getInstance().dispatchEvent(_loc2_);
      }
      
      override public function set data(param1:Object) : void
      {
         super.data = param1;
         var _loc2_:TextField = new TextField();
         _loc2_.autoSize = TextFieldAutoSize.LEFT;
         _loc2_.htmlText = "<font color=\'#048020\'>0级</font>";
         _loc2_.selectable = false;
         addChild(_loc2_);
         _loc2_.x = 1;
         _loc2_.y = 44;
         _loc2_.filters = [new GlowFilter(16777215,1,4,4,3,1,false,false)];
         if(int(param1["FBPrice"]) == 0)
         {
            if(this.goldIcon == null)
            {
               this.goldIcon = new MoneyIcon();
               addChild(this.goldIcon);
            }
            else if(this.goldIcon.type != MoneyIcon.GOLD)
            {
               removeChild(this.goldIcon);
               this.goldIcon = null;
               this.goldIcon = new MoneyIcon();
               addChild(this.goldIcon);
            }
            this.priceText.defaultTextFormat = new TextFormat("Verdana",11,294176,true,null,null,null,null,TextFormatAlign.LEFT);
            this.priceText.text = param1["price"];
         }
         else
         {
            if(this.goldIcon == null)
            {
               this.goldIcon = new MoneyIcon(MoneyIcon.FB);
               addChild(this.goldIcon);
            }
            else if(this.goldIcon.type != MoneyIcon.FB)
            {
               removeChild(this.goldIcon);
               this.goldIcon = null;
               this.goldIcon = new MoneyIcon(MoneyIcon.FB);
               addChild(this.goldIcon);
            }
            this.priceText.defaultTextFormat = new TextFormat("Verdana",11,15886653,true,null,null,null,null,TextFormatAlign.LEFT);
            this.priceText.text = param1["FBPrice"];
         }
         this.goldIcon.x = -5;
         this.goldIcon.y = 65;
         this._material.setContent(param1["type"],param1["tId"]);
      }
   }
}

