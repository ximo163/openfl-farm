package mc.view.main.window.warehouse
{
   import com.minutes.ui.control.LipiButton;
   import com.minutes.ui.control.NumbericStepper;
   import com.minutes.ui.core.LipiSkin;
   import com.minutes.ui.core.UIEvent;
   import common.MaterialLib;
   import flash.display.Bitmap;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TextEvent;
   import flash.external.ExternalInterface;
   import flash.filters.GlowFilter;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormat;
   import mc.control.Command;
   import mc.control.ViewControl;
   import mc.events.WindowEvent;
   import mc.model.MData;
   import mc.model.MainData;
   import mc.view.common.BaseWindow;
   import mc.view.common.Language;
   import mc.view.common.MaterialLoaderProxy;
   import mc.view.farm.GetCropID;
   import module.weekendSale.WeekendSaleHelper;
   
   public class SellCropWindow extends BaseWindow
   {
      
      private var materialProxy:MaterialLoaderProxy;
      
      private var directionText:TextField;
      
      private var confirmButton:LipiButton;
      
      private var _form:Object;
      
      private var tipText:TextField;
      
      private var numbericStepper:NumbericStepper;
      
      private var _9txt:TextField;
      
      private var _exText:TextField;
      
      private var alertTxt2:TextField;
      
      public function SellCropWindow()
      {
         super();
         width = 400;
         height = 300;
         titleIMG = MaterialLib.getInstance().getClass("SellCropWindowTitle");
         windowName = "SellCropWindow";
         mode = true;
      }
      
      private function onLoadCompete(param1:Event) : void
      {
      }
      
      private function delayUpdateLockStatus(param1:Event = null) : void
      {
         removeEventListener(Event.ENTER_FRAME,this.delayUpdateLockStatus,false);
         this.updateLockStatus();
      }
      
      override public function set data(param1:Object) : void
      {
         super.data = param1;
         this.setData();
      }
      
      private function confirmButtonClick(param1:MouseEvent = null) : void
      {
         if(data["type"] == "11")
         {
            Command.getInstance().mainCommand.saleMaterial(data["cId"],this.numbericStepper.get_num);
         }
         else
         {
            Command.getInstance().mainCommand.sale(data["cId"],this.numbericStepper.get_num);
         }
         var _loc2_:WindowEvent = new WindowEvent(WindowEvent.CLOSE);
         _loc2_.window = this;
         ViewControl.getInstance().dispatchEvent(_loc2_);
      }
      
      private function onButtonClick(param1:MouseEvent) : void
      {
         if(param1.target.name == "unlock_btn")
         {
            Command.getInstance().mainCommand.unLockCrop(data["cId"],data["type"]);
         }
         else if(param1.target.name == "lock_btn")
         {
            Command.getInstance().mainCommand.lockCrop(data["cId"],data["type"]);
         }
      }
      
      private function numChange(param1:UIEvent) : void
      {
         if(Boolean(data["sprice"]) && MainData.sPrice == true)
         {
            this._form.income.text = data["sprice"] * this.numbericStepper.get_num;
         }
         else
         {
            this._form.income.text = this.getDataPrice(data) * this.numbericStepper.get_num;
         }
      }
      
      override public function init() : void
      {
         var _loc3_:LipiButton = null;
         var _loc4_:MainData = null;
         var _loc5_:Bitmap = null;
         var _loc1_:String = "WarehouseForm";
         this._form = MaterialLib.getInstance().getMaterial(_loc1_) as Object;
         this._form.x = 190;
         this._form.y = 55;
         addChild(this._form as Sprite);
         this.materialProxy = new MaterialLoaderProxy();
         this.materialProxy.x = 75;
         this.materialProxy.y = 65;
         addChildAt(this.materialProxy,0);
         if(data.hasOwnProperty("isvip"))
         {
            if(data["isvip"].toString() == "1")
            {
               _loc4_ = MData.getInstance().mainData;
               _loc5_ = new Bitmap(_loc4_.vipIcon.bitmapData);
               _loc5_.scaleX = _loc5_.scaleY = 0.7;
               _loc5_.x = this.materialProxy.x;
               _loc5_.y = this.materialProxy.y;
               addChildAt(_loc5_,1);
            }
         }
         this.numbericStepper = new NumbericStepper();
         this.numbericStepper.addEventListener(UIEvent.TEXT_CHANGE,this.numChange);
         this.numbericStepper.x = 60;
         this.numbericStepper.y = 145;
         addChild(this.numbericStepper);
         this.directionText = new TextField();
         this.directionText.mouseEnabled = false;
         this.directionText.selectable = false;
         this.directionText.x = 51;
         this.directionText.y = 185;
         this.directionText.autoSize = TextFieldAutoSize.LEFT;
         this.directionText.defaultTextFormat = new TextFormat("Verdana",12,8999699);
         this.directionText.text = Language.replaceText("sellNum",{
            "minNum":1,
            "maxNum":99
         });
         addChild(this.directionText);
         this.tipText = new TextField();
         this.tipText.width = 175;
         this.tipText.wordWrap = true;
         this.tipText.multiline = true;
         this.tipText.autoSize = TextFieldAutoSize.LEFT;
         this.tipText.selectable = false;
         this.tipText.mouseWheelEnabled = false;
         addChild(this.tipText);
         this.tipText.x = 195;
         this.tipText.y = 210;
         this._exText = new TextField();
         this._exText.mouseEnabled = false;
         this._exText.selectable = false;
         this._exText.x = (this.width - this._exText.width) / 2;
         this._exText.y = height - 75;
         this._exText.autoSize = TextFieldAutoSize.LEFT;
         this._exText.defaultTextFormat = new TextFormat("Verdana",12,16731743);
         this._exText.visible = false;
         addChild(this._exText);
         this._9txt = new TextField();
         this._9txt.mouseEnabled = false;
         this._9txt.selectable = false;
         this._9txt.x = this.width - 90;
         this._9txt.y = 180;
         this._9txt.autoSize = TextFieldAutoSize.LEFT;
         this._9txt.defaultTextFormat = new TextFormat("Verdana",12,16731743,true);
         this._9txt.visible = false;
         this._9txt.text = "9倍";
         this._9txt.filters = [new GlowFilter(16777215,1,4,4,30)];
         addChild(this._9txt);
         var _loc2_:TextFormat = new TextFormat("Verdana",12,8999699,null,null,null,null,null,"center");
         this.alertTxt2 = new TextField();
         this.alertTxt2.backgroundColor = 16777176;
         this.alertTxt2.background = true;
         this.alertTxt2.width = 380;
         this.alertTxt2.height = 18;
         this.alertTxt2.x = 10;
         this.alertTxt2.y = 27;
         this.alertTxt2.selectable = false;
         addChild(this.alertTxt2);
         this.alertTxt2.defaultTextFormat = _loc2_;
         addChild(this.alertTxt2);
         this.alertTxt2.visible = false;
         this.alertTxt2.htmlText = "达到99的倍数方可9倍售出，系统默认显示最大收益数！";
         this.setData();
         this.confirmButton = new LipiButton();
         this.confirmButton.bgAlpha = 0;
         this.confirmButton.bgSkin = new LipiSkin(MaterialLib.getInstance().getClass("ButtonOrange"));
         this.confirmButton.width = 64;
         this.confirmButton.height = 25;
         this.confirmButton.x = width / 2 - this.confirmButton.width - 10;
         this.confirmButton.y = height - 50;
         this.confirmButton.label = "确定";
         this.confirmButton.textColor = 16777215;
         this.confirmButton.name = "confirm_btn";
         this.confirmButton.addEventListener(MouseEvent.CLICK,this.confirmButtonClick);
         addChild(this.confirmButton);
         _loc3_ = new LipiButton();
         _loc3_.bgAlpha = 0;
         _loc3_.bgSkin = new LipiSkin(MaterialLib.getInstance().getClass("ButtonBlue"));
         _loc3_.width = 64;
         _loc3_.height = 25;
         _loc3_.x = width / 2 + 10;
         _loc3_.y = height - 50;
         _loc3_.label = "取消";
         _loc3_.textColor = 16777215;
         _loc3_.addEventListener(MouseEvent.CLICK,this.cancelButtonClick);
         addChild(_loc3_);
         addEventListener(MouseEvent.CLICK,this.onButtonClick,false,0,true);
         MData.getInstance().mainData.addEventListener(MainData.UNLOCK_LOCK_CROP,this.onLockChange);
      }
      
      private function getDataPrice(param1:Object) : Number
      {
         if(WeekendSaleHelper.avaliable)
         {
            return WeekendSaleHelper.getProductPrice(param1);
         }
         return param1.price;
      }
      
      private function updateLockStatus() : void
      {
         this._form.gotoAndStop(Boolean(data["lock"]) || Boolean(data["isLock"]) ? "lock" : "unlock");
         if(Boolean(data["lock"]) || Boolean(data["isLock"]))
         {
            this.confirmButton.enable = false;
            this.confirmButton.mouseEnabled = false;
            this.confirmButton.mouseChildren = false;
            this.confirmButton.useHandCursor = false;
         }
         else
         {
            this.confirmButton.enable = true;
            this.confirmButton.mouseEnabled = true;
            this.confirmButton.mouseChildren = true;
            this.confirmButton.useHandCursor = true;
         }
      }
      
      private function confirmButtonClick2(param1:MouseEvent = null) : void
      {
         if(data["type"] == "11")
         {
            Command.getInstance().mainCommand.saleMaterial(data["cId"],this.numbericStepper.get_num);
         }
         else
         {
            Command.getInstance().mainCommand.sale(data["cId"],this.numbericStepper.get_num);
         }
         var _loc2_:WindowEvent = new WindowEvent(WindowEvent.CLOSE);
         _loc2_.window = this;
         ViewControl.getInstance().dispatchEvent(_loc2_);
      }
      
      private function linkHandler(param1:TextEvent) : void
      {
         ExternalInterface.call("window.open",param1.text);
      }
      
      private function cancelButtonClick(param1:MouseEvent) : void
      {
         var _loc2_:WindowEvent = new WindowEvent(WindowEvent.CLOSE);
         _loc2_.window = this;
         ViewControl.getInstance().dispatchEvent(_loc2_);
      }
      
      override public function keyEnter() : void
      {
         if(!data["lock"] && !data["isLock"])
         {
            this.confirmButtonClick();
         }
      }
      
      private function onLockChange(param1:Event) : void
      {
         this.updateLockStatus();
      }
      
      private function setData() : void
      {
         var _loc1_:String = null;
         var _loc2_:TextFormat = null;
         if(data == null)
         {
            return;
         }
         if(this.materialProxy != null)
         {
            if(data["type"] == "11")
            {
               this.materialProxy.setContent("11",data["cId"]);
            }
            else
            {
               this.materialProxy.setContent("2",data["cId"]);
            }
         }
         if(this._form != null)
         {
            this.numbericStepper.max_num = data["amount"];
            this.numbericStepper.get_num = data["amount"];
            this._form.cropName.text = data["cName"];
            this._form.cropName.width = 240;
            this._form.initialPrice.text = "";
            if(Boolean(data["sprice"]) && MainData.sPrice == true)
            {
               this._form.price.text = data["sprice"];
               this._form.initialPrice.text = "(原价：金币 " + this.getDataPrice(data) + ")";
               this._form.income.text = data["sprice"] * this.numbericStepper.get_num;
            }
            else
            {
               this._form.price.text = this.getDataPrice(data);
               this._form.income.text = this.getDataPrice(data) * this.numbericStepper.get_num;
            }
            this.directionText.text = Language.replaceText("sellNum",{
               "minNum":1,
               "maxNum":data["amount"]
            });
            addEventListener(Event.ENTER_FRAME,this.delayUpdateLockStatus,false,0,true);
            _loc1_ = GetCropID.getProductTip(data["cId"]);
            this.tipText.htmlText = _loc1_;
            this.tipText.addEventListener(TextEvent.LINK,this.linkHandler);
            _loc2_ = new TextFormat();
            _loc2_.leading = 4;
            _loc2_.color = 8999699;
            this.tipText.setTextFormat(_loc2_);
            if(this.alertTxt2)
            {
               this.alertTxt2.visible = false;
            }
            if(this._exText)
            {
               this._exText.visible = false;
            }
         }
      }
      
      private function setTextChange(param1:Number) : void
      {
         var _loc2_:int = int(this.numbericStepper.get_num);
         if(_loc2_ % 99 == 0)
         {
            this._form.income.text = param1 * 9;
            this._exText.htmlText = "丘比特小9恭喜您：此时符合99的倍数，收入是原来的9倍。";
            this._9txt.visible = true;
         }
         else
         {
            this._exText.htmlText = "丘比特小9提醒您：此时不符合99的倍数，无法得到9倍收益。";
            this._9txt.visible = false;
         }
         this._exText.x = (this.width - this._exText.width) / 2;
      }
   }
}

