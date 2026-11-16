package mc.view.main.window.warehouse
{
   import com.minutes.ui.control.LipiButton;
   import com.minutes.ui.control.NumbericStepper;
   import com.minutes.ui.core.LipiSkin;
   import com.minutes.ui.core.UIEvent;
   import common.MaterialLib;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TextEvent;
   import flash.external.ExternalInterface;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormat;
   import mc.control.ViewControl;
   import mc.events.WindowEvent;
   import mc.model.MainData;
   import mc.view.common.BaseWindow;
   import mc.view.common.Language;
   import mc.view.common.MaterialLoaderProxy;
   import mc.view.farm.GetCropID;
   import mc.view.main.WindowControl.WControl;
   
   public class SellCubWindow extends BaseWindow
   {
      
      private var _form:Object;
      
      private var materialProxy:MaterialLoaderProxy;
      
      private var tipText:TextField;
      
      private var directionText:TextField;
      
      private var confirmButton:LipiButton;
      
      private var numbericStepper:NumbericStepper;
      
      public function SellCubWindow()
      {
         super();
         width = 400;
         height = 300;
         titleIMG = MaterialLib.getInstance().getClass("SellCubWindowTitle");
         windowName = "SellCubWindow";
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
      
      private function cancelButtonClick(param1:MouseEvent = null) : void
      {
         var _loc2_:WindowEvent = new WindowEvent(WindowEvent.CLOSE);
         _loc2_.window = this;
         ViewControl.getInstance().dispatchEvent(_loc2_);
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
      
      private function SellSureFn() : void
      {
         this.cancelButtonClick();
      }
      
      override public function set data(param1:Object) : void
      {
         super.data = param1;
         this.setData();
      }
      
      private function numChange(param1:UIEvent) : void
      {
         if(Boolean(data["sprice"]) && MainData.sPrice == true)
         {
            this._form.income.text = int(data["sprice"] / 2) * this.numbericStepper.get_num;
         }
         else
         {
            this._form.income.text = int(data["price"] / 2) * this.numbericStepper.get_num;
         }
      }
      
      override public function init() : void
      {
         var _loc2_:LipiButton = null;
         var _loc1_:String = "WarehouseForm2";
         this._form = MaterialLib.getInstance().getMaterial(_loc1_) as Object;
         this._form.x = 190;
         this._form.y = 65;
         addChild(this._form as Sprite);
         this.materialProxy = new MaterialLoaderProxy();
         this.materialProxy.x = 75;
         this.materialProxy.y = 65;
         addChildAt(this.materialProxy,0);
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
         _loc2_ = new LipiButton();
         _loc2_.bgAlpha = 0;
         _loc2_.bgSkin = new LipiSkin(MaterialLib.getInstance().getClass("ButtonBlue"));
         _loc2_.width = 64;
         _loc2_.height = 25;
         _loc2_.x = width / 2 + 10;
         _loc2_.y = height - 50;
         _loc2_.label = "取消";
         _loc2_.textColor = 16777215;
         _loc2_.addEventListener(MouseEvent.CLICK,this.cancelButtonClick);
         addChild(_loc2_);
      }
      
      override public function keyEnter() : void
      {
         if(!data["lock"] && !data["isLock"])
         {
            this.confirmButtonClick();
         }
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
               this.materialProxy.setContent("9",data["cId"]);
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
               this._form.price.text = int(data["sprice"] / 2);
               this._form.initialPrice.text = "(原价：金币 " + int(data["price"] / 2) + ")";
               this._form.income.text = int(data["sprice"] / 2) * this.numbericStepper.get_num;
            }
            else
            {
               this._form.price.text = int(data["price"] / 2);
               this._form.income.text = int(data["price"] / 2) * this.numbericStepper.get_num;
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
         }
      }
      
      private function confirmButtonClick(param1:MouseEvent = null) : void
      {
         var _loc2_:SellCubSureWin = new SellCubSureWin();
         _loc2_.data = {
            "cId":data["cId"],
            "income":int(this._form.income.text),
            "num":this.numbericStepper.get_num
         };
         _loc2_.confirmFn = this.SellSureFn;
         WControl.open(_loc2_);
      }
      
      private function linkHandler(param1:TextEvent) : void
      {
         ExternalInterface.call("window.open",param1.text);
      }
   }
}

