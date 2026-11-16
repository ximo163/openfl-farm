package mc.view.main.window.warehouse
{
   import com.minutes.ui.control.LipiButton;
   import com.minutes.ui.control.NumbericStepper;
   import com.minutes.ui.core.LipiSkin;
   import com.minutes.ui.core.UIEvent;
   import common.MaterialLib;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.events.TextEvent;
   import flash.external.ExternalInterface;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormat;
   import mc.api.WildCommand;
   import mc.control.ViewControl;
   import mc.events.WindowEvent;
   import mc.view.common.BaseWindow;
   import mc.view.common.Language;
   import mc.view.common.MaterialLoaderProxy;
   import mc.view.farm.GetCropID;
   
   public class SellCrystalWindow extends BaseWindow
   {
      
      private var _form:MovieClip;
      
      private var _material:MaterialLoaderProxy;
      
      private var tipText:TextField;
      
      private var directionText:TextField;
      
      private var numbericStepper:NumbericStepper;
      
      private var confirmButton:LipiButton;
      
      public function SellCrystalWindow()
      {
         super();
         width = 400;
         height = 300;
         titleIMG = MaterialLib.getInstance().getClass("SellCropWindowTitle");
         windowName = "SellCrystalWindow";
         mode = true;
      }
      
      override public function keyEnter() : void
      {
         this.confirmButtonClick();
      }
      
      private function cancelButtonClick(param1:MouseEvent) : void
      {
         var _loc2_:WindowEvent = new WindowEvent(WindowEvent.CLOSE);
         _loc2_.window = this;
         ViewControl.getInstance().dispatchEvent(_loc2_);
      }
      
      override public function set data(param1:Object) : void
      {
         super.data = param1;
         this.setData();
      }
      
      private function numChange(param1:UIEvent) : void
      {
         this._form.income.text = data["price"] * this.numbericStepper.get_num;
      }
      
      override public function init() : void
      {
         var _loc2_:LipiButton = null;
         var _loc1_:String = "SellCrystalForm";
         this._form = MaterialLib.getInstance().getMaterial(_loc1_) as MovieClip;
         this._form.x = 190;
         this._form.y = 55;
         addChild(this._form as Sprite);
         this._material = new MaterialLoaderProxy();
         this._material.x = 75;
         this._material.y = 80;
         addChild(this._material);
         this.numbericStepper = new NumbericStepper();
         this.numbericStepper.addEventListener(UIEvent.TEXT_CHANGE,this.numChange);
         this.numbericStepper.x = 60;
         this.numbericStepper.y = 165;
         addChild(this.numbericStepper);
         this.directionText = new TextField();
         this.directionText.mouseEnabled = false;
         this.directionText.selectable = false;
         this.directionText.x = 51;
         this.directionText.y = 200;
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
      
      private function setData() : void
      {
         var _loc1_:String = null;
         var _loc2_:TextFormat = null;
         if(data == null)
         {
            return;
         }
         if(this._material != null)
         {
            this._material.setContent("wild_drop",data["cId"],data);
            this._material.y = 55;
            this.numbericStepper.y = 140;
            this.directionText.y = 175;
         }
         if(this._form != null)
         {
            this.numbericStepper.max_num = data["amount"];
            this.numbericStepper.get_num = data["amount"];
            this._form.cropName.text = data["cName"];
            this._form.cropName.width = 240;
            this._form.initialPrice.text = "";
            this._form.price.text = data["price"];
            this._form.income.text = data["price"] * this.numbericStepper.get_num;
            this.directionText.text = Language.replaceText("sellNum",{
               "minNum":1,
               "maxNum":data["amount"]
            });
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
         WildCommand.getInstance().saleCrystal(data["cId"],this.numbericStepper.get_num);
         var _loc2_:WindowEvent = new WindowEvent(WindowEvent.CLOSE);
         _loc2_.window = this;
         ViewControl.getInstance().dispatchEvent(_loc2_);
      }
      
      private function linkHandler(param1:TextEvent) : void
      {
         ExternalInterface.call("window.open",param1.text);
      }
   }
}

