package mc.view.main.window.shop
{
   import com.minutes.ui.collections.LipiListChild;
   import com.minutes.ui.control.LipiButton;
   import com.minutes.ui.core.LipiSkin;
   import common.INI;
   import common.MaterialLib;
   import flash.display.Bitmap;
   import flash.display.DisplayObject;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.filters.GlowFilter;
   import flash.geom.Point;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormat;
   import flash.text.TextFormatAlign;
   import mc.control.ViewControl;
   import mc.events.TipEvent;
   import mc.events.WindowEvent;
   import mc.model.MData;
   import mc.model.MainData;
   import mc.view.ViewEvent;
   import mc.view.common.MaterialLoaderProxy;
   import mc.view.common.MoneyIcon;
   import mc.view.farm.GetCropID;
   import mc.view.main.WindowControl.WindowClassLib;
   
   public class CropItem extends LipiListChild
   {
      
      public static var CHILD_OVER:String = "childOver";
      
      public static var CHILD_OUT:String = "childOut";
      
      public static var CHILD_MOVE:String = "childMove";
      
      private var _material:MaterialLoaderProxy;
      
      private var houseLoc:Point = new Point(46,46);
      
      private var isGetVipPic:Boolean;
      
      private var _shopMode:String;
      
      private var house:MovieClip;
      
      private var vipIconClass:Class = CropItem_vipIconClass;
      
      private var LimitIconClass:Class = CropItem_LimitIconClass;
      
      private var leveltxt:TextField;
      
      private var leveltxtLoca:Point = new Point(1,44);
      
      private var CautionIconClass:Class = CropItem_CautionIconClass;
      
      private var isSWF:Boolean;
      
      public function CropItem()
      {
         super();
         this.buttonMode = true;
         this.useHandCursor = true;
         this._material = new MaterialLoaderProxy();
         addChild(this._material);
         this._material.addEventListener(MouseEvent.CLICK,this.onClick);
         this._material.addEventListener(MouseEvent.ROLL_OVER,this.onOver);
         this._material.addEventListener(MouseEvent.ROLL_OUT,this.onOut);
      }
      
      private function onOver(param1:MouseEvent) : void
      {
         var _loc2_:TipEvent = new TipEvent(TipEvent.TIP_SHOW);
         _loc2_.tipType = "MouseTip";
         _loc2_.tipArgument = data["cName"] + "\n动物价值：" + data["productprice"];
         ViewControl.getInstance().dispatchEvent(_loc2_);
      }
      
      private function confirmButtonClick(param1:MouseEvent) : void
      {
         WindowClassLib.register("ShopSeedWindow",ShopSeedWindow);
         var _loc2_:WindowEvent = new WindowEvent(WindowEvent.OPEN);
         _loc2_.windowName = "ShopSeedWindow";
         _loc2_.windowArgument = data;
         ViewControl.getInstance().dispatchEvent(_loc2_);
      }
      
      override public function set data(param1:Object) : void
      {
         var hostLevel:int;
         var host:Object;
         var child:DisplayObject = null;
         var activityIcon:MovieClip = null;
         var mainData:MainData = null;
         var _sp:Sprite = null;
         var vipTxt:TextField = null;
         var _xml:XML = null;
         var desc:String = null;
         var vipIcon:Bitmap = null;
         var _sp1:Sprite = null;
         var limitIcon:Bitmap = null;
         var cautionIcon:Bitmap = null;
         var limitTxt:TextField = null;
         var vipTxt1:TextField = null;
         var yellowIcon:Bitmap = null;
         var priceText1:TextField = null;
         var buyButton:LipiButton = null;
         var priceText:TextField = null;
         var goldIcon:MoneyIcon = null;
         var value:Object = param1;
         super.data = value;
         this.setShopMode();
         while(this.numChildren > 1)
         {
            child = this.getChildAt(numChildren - 1);
            if(child == this._material)
            {
               addChildAt(this._material,0);
            }
            else
            {
               removeChildAt(numChildren - 1);
            }
         }
         if(this._material.numChildren > 1)
         {
            child = this._material.getChildAt(1) as DisplayObject;
            if(child is Loader)
            {
               (child as Loader).unload();
            }
            this._material.removeChild(child);
         }
         this._material.setContent("1",value["cId"],null,this.isGetVipPic,false,false,this.isSWF);
         if(GetCropID.getHouse(value["cId"]) == "窝")
         {
            this.house = MaterialLib.getInstance().getMaterial("HouseIcon1") as MovieClip;
         }
         else
         {
            this.house = MaterialLib.getInstance().getMaterial("HouseIcon2") as MovieClip;
         }
         addChild(this.house);
         this.house.x = this.houseLoc.x;
         this.house.y = this.houseLoc.y;
         this.leveltxt = new TextField();
         this.leveltxt.autoSize = TextFieldAutoSize.LEFT;
         this.leveltxt.htmlText = "<font color=\'#048020\'>" + value["cLevel"] + "级</font>";
         this.leveltxt.selectable = false;
         this.leveltxt.mouseEnabled = false;
         addChild(this.leveltxt);
         this.leveltxt.x = this.leveltxtLoca.x;
         this.leveltxt.y = this.leveltxtLoca.y;
         this.leveltxt.filters = [new GlowFilter(16777215,1,2,2,10,1,false,false)];
         host = MData.getInstance().mainData.host;
         hostLevel = MData.getInstance().mainData.expToGrade(host["exp"]);
         if(hostLevel < value["cLevel"])
         {
            this.leveltxt.htmlText = "<font color=\'#666666\'>" + value["cLevel"] + "级</font>";
         }
         if(GetCropID.getActivity(value["cId"]))
         {
            activityIcon = MaterialLib.getInstance().getMaterial("ActivityIcon") as MovieClip;
            addChild(activityIcon);
            activityIcon.x = this.houseLoc.x - 10;
            activityIcon.y = 0;
         }
         if(this._shopMode == "vipAnimal")
         {
            mainData = MData.getInstance().mainData;
            if(mainData.vipIcon)
            {
               vipIcon = new Bitmap(mainData.vipIcon.bitmapData);
               addChild(vipIcon);
            }
            _sp = new Sprite();
            _sp.graphics.beginFill(0,0);
            _sp.graphics.drawRect(0,0,50,70);
            _sp.graphics.endFill();
            _sp.y = this.leveltxt.y + this.leveltxt.height;
            addChild(_sp);
            vipTxt = new TextField();
            addChild(vipTxt);
            vipTxt.y = this.leveltxt.y + this.leveltxt.height;
            vipTxt.x = -5;
            vipTxt.multiline = true;
            vipTxt.wordWrap = true;
            vipTxt.width = 140;
            vipTxt.mouseEnabled = false;
            vipTxt.selectable = false;
            vipTxt.autoSize = TextFieldAutoSize.CENTER;
            _xml = INI.getInstance().data;
            desc = "";
            if(_xml.animals.animal.(@id == value["cId"]).@desc != null)
            {
               desc = _xml.animals.animal.(@id == value["cId"]).@desc;
            }
            vipTxt.htmlText = "<p align=\'center\'><font color=\'#AB834F\' size=\'14\' align=\'center\'><B>" + value["cName"] + "</B></font></p><p align=\'center\'><font color=\'#CBB142\' size=\'12\' align=\'center\'><b>" + desc + "</b></font></p>";
            vipTxt.filters = [new GlowFilter(16777215,1,2,2,10,1,false,false)];
         }
         else if(this._shopMode == "limitSales")
         {
            _sp1 = new Sprite();
            _sp1.graphics.beginFill(0,0);
            _sp1.graphics.drawRect(0,0,50,20);
            _sp1.graphics.endFill();
            _sp1.y = 225;
            addChild(_sp1);
            limitIcon = new this.LimitIconClass();
            addChild(limitIcon);
            cautionIcon = new this.CautionIconClass();
            addChild(cautionIcon);
            cautionIcon.y = 120;
            limitTxt = new TextField();
            addChild(limitTxt);
            limitTxt.x = 22;
            limitTxt.y = 120;
            limitTxt.width = 94;
            limitTxt.mouseEnabled = false;
            limitTxt.htmlText = "<font color=\'#CC3300\'>还剩 <b>" + value.deadline + "</b> 天下架</font>";
            vipTxt1 = new TextField();
            addChild(vipTxt1);
            vipTxt1.x = -4;
            vipTxt1.y = 140;
            vipTxt1.multiline = true;
            vipTxt1.wordWrap = true;
            vipTxt1.width = 126;
            vipTxt1.mouseEnabled = false;
            vipTxt1.selectable = false;
            vipTxt1.autoSize = TextFieldAutoSize.CENTER;
            vipTxt1.htmlText = "<p align=\'center\'><font color=\'#895313\' size=\'14\' align=\'center\'><b>" + value["cName"] + "</b></font></p><p align=\'center\'><font color=\'#F39800\' size=\'12\' align=\'center\'>" + value["desc"] + "</font></p>";
            vipTxt1.filters = [new GlowFilter(16777215,1,2,2,10,1,false,false)];
            yellowIcon = new this.vipIconClass();
            addChild(yellowIcon);
            yellowIcon.x = -4;
            yellowIcon.y = 178;
            priceText1 = new TextField();
            addChild(priceText1);
            priceText1.selectable = false;
            priceText1.width = 130;
            priceText1.height = 23;
            priceText1.x = 12;
            priceText1.y = 174;
            priceText1.htmlText = "<font color=\'#FF6600\' size=\'14\'><b>" + int(0.8 * value["qdprice"]) + "元宝</b></font><font color=\'#895313\' size=\'12\'> 原价" + value["qdprice"] + "元宝</font>";
            priceText1.autoSize = TextFieldAutoSize.LEFT;
            buyButton = new LipiButton();
            buyButton.bgAlpha = 0;
            buyButton.bgSkin = new LipiSkin(MaterialLib.getInstance().getClass("ButtonOrange"));
            buyButton.width = 64;
            buyButton.height = 25;
            buyButton.x = 24;
            buyButton.y = 200;
            buyButton.label = "购买";
            buyButton.textColor = 16777215;
            buyButton.addEventListener(MouseEvent.CLICK,this.confirmButtonClick);
            addChild(buyButton);
         }
         else
         {
            priceText = new TextField();
            priceText.defaultTextFormat = new TextFormat("Verdana",11,294176,true,null,null,null,null,TextFormatAlign.LEFT);
            priceText.selectable = false;
            priceText.width = 45;
            priceText.height = 23;
            addChild(priceText);
            priceText.text = value["price"];
            priceText.x = 27;
            priceText.y = 65;
            goldIcon = new MoneyIcon();
            addChild(goldIcon);
            goldIcon.x = -5;
            goldIcon.y = 65;
         }
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
      
      private function setShopMode() : void
      {
         if(Boolean(data["isvip"]) && data["isvip"] == 1)
         {
            this._shopMode = "vipAnimal";
         }
         else if(Boolean(data["cType"]) && data["cType"] == 6)
         {
            this._shopMode = "limitSales";
         }
         else
         {
            this._shopMode = "normal";
         }
         if(this._shopMode == "vipAnimal")
         {
            this.houseLoc = new Point(105,105);
            this.leveltxtLoca = new Point(1,103);
            this.isGetVipPic = true;
            this.isSWF = false;
         }
         else if(this._shopMode == "limitSales")
         {
            this.houseLoc = new Point(102,102);
            this.leveltxtLoca = new Point(1,100);
            this.isGetVipPic = false;
            this.isSWF = true;
         }
         else
         {
            this.houseLoc = new Point(46,46);
            this.leveltxtLoca = new Point(1,44);
            this.isGetVipPic = false;
            this.isSWF = false;
         }
      }
   }
}

