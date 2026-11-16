package mc.view.main.window.shop
{
   import com.minutes.ui.collections.LipiListChild;
   import com.qzone.qui.styles.Style;
   import common.MaterialLib;
   import flash.display.Loader;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.net.URLRequest;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import flash.text.TextFormatAlign;
   import mc.control.ViewControl;
   import mc.events.TipEvent;
   import mc.view.ViewEvent;
   import mc.view.common.MaterialProxy;
   import mc.view.common.MoneyIcon;
   import mc.view.common.WildMaterialLoaderProxy;
   import mc.view.farm.GetCropID;
   
   public class TinItem extends LipiListChild
   {
      
      public static var CHILD_OVER:String = "childOver";
      
      public static var CHILD_OUT:String = "childOut";
      
      public static var CHILD_MOVE:String = "childMove";
      
      private var _material:MaterialProxy;
      
      private var priceText:TextField;
      
      private var goldIcon:MoneyIcon;
      
      public function TinItem()
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
         this.priceText.y = 63;
         this._material = new MaterialProxy();
         addChild(this._material);
         addEventListener(MouseEvent.CLICK,this.onClick);
         addEventListener(MouseEvent.ROLL_OVER,this.onOver);
         addEventListener(MouseEvent.ROLL_OUT,this.onOut);
         var _loc1_:Shape = new Shape();
         _loc1_.graphics.beginFill(16711680,0);
         _loc1_.graphics.drawRect(0,0,90,98);
         _loc1_.graphics.endFill();
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
         _loc2_.tipArgument = data["n"] + "\n" + data["d"];
         ViewControl.getInstance().dispatchEvent(_loc2_);
      }
      
      override public function set data(param1:Object) : void
      {
         var _loc2_:TextField = null;
         var _loc3_:Loader = null;
         var _loc4_:WildMaterialLoaderProxy = null;
         var _loc5_:Loader = null;
         var _loc6_:Sprite = null;
         super.data = param1;
         if(int(param1["p"]) != 0)
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
            this.priceText.text = param1["p"];
         }
         else if(int(param1["qd"]) != 0)
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
            this.priceText.text = param1["qd"];
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
            this.priceText.text = param1["setprice"][0]["money"];
         }
         if(this.goldIcon)
         {
            this.goldIcon.x = -5;
            this.goldIcon.y = 65;
         }
         if(param1["l"] != undefined && param1["l"] <= 0)
         {
            this._material.filters = Style.getDisableFilter();
            _loc2_ = new TextField();
            _loc2_.defaultTextFormat = new TextFormat("_sans",12,13369344);
            _loc2_.x = 10;
            _loc2_.y = 40;
            _loc2_.text = "已售完";
            _loc2_.multiline = false;
            _loc2_.selectable = false;
            _loc2_.mouseEnabled = false;
            _loc2_.filters = Style.getTextGlowFilter();
            addChild(_loc2_);
         }
         if(param1["t"] == 106)
         {
            _loc3_ = new Loader();
            this._material.addChild(_loc3_);
            _loc3_.load(new URLRequest(GetCropID.getHunterPicUrl(param1["id"])));
         }
         else if(param1["t"] == 10 && param1["appid"] == 353)
         {
            _loc4_ = new WildMaterialLoaderProxy();
            addChild(_loc4_);
            _loc4_.setContent("weapon",param1["id"],{"type":"Small"});
         }
         else if(param1["tp"] == 1)
         {
            _loc5_ = new Loader();
            this._material.addChild(_loc5_);
            _loc5_.load(new URLRequest(GetCropID.getSwfUrl() + "farm/tools/prop_" + param1["id"] + ".jpg"));
         }
         else
         {
            _loc6_ = MaterialLib.getInstance().getMaterial("Tool_" + param1["t"] + "_" + param1["id"]) as Sprite;
            if(_loc6_)
            {
               this._material.addChild(_loc6_);
            }
         }
      }
   }
}

