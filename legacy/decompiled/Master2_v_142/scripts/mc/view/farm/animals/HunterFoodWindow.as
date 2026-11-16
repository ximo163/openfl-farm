package mc.view.farm.animals
{
   import com.minutes.ui.control.LipiButton;
   import com.minutes.ui.core.LipiSkin;
   import common.MaterialLib;
   import flash.display.*;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormat;
   import mc.control.ViewControl;
   import mc.events.WindowEvent;
   import mc.model.MData;
   import mc.model.MainData;
   import mc.view.common.BaseWindow;
   import mc.view.common.MaterialProxyBig;
   
   public class HunterFoodWindow extends BaseWindow
   {
      
      private var titleText:TextField;
      
      private var materialProxy:MaterialProxyBig;
      
      public var confirmFn:Function;
      
      private var confirmButton:LipiButton;
      
      public function HunterFoodWindow()
      {
         super();
         width = 380;
         height = 280;
         titleIMG = MaterialLib.getInstance().getClass("BuyTinItemTitle");
         windowName = "ShopTinWindow";
         mode = true;
      }
      
      private function setData() : void
      {
         var _loc1_:MainData = MData.getInstance().mainData;
         var _loc2_:Number = _loc1_.hunter.t / 3600;
         var _loc3_:String = "<font color=\'#FF6600\'><b>" + int(_loc2_ / 24) + "</b></font> 天 <font color=\'#FF6600\'><b>" + int(_loc2_ % 24) + "</b></font> 小时";
         var _loc4_:String = "剩余工资还可以维持" + _loc1_.hunter["name"] + "工作<br><br>";
         _loc4_ = _loc4_ + _loc3_;
         _loc4_ = _loc4_ + ("<br><br>记得及时给" + _loc1_.hunter["name"] + "发工资，<br>不然他会消极怠工的哦！");
         this.titleText.htmlText = _loc4_;
         var _loc5_:Sprite = MaterialLib.getInstance().getMaterial("Tool_5_101") as Sprite;
         addChild(_loc5_);
         _loc5_.x = 46;
         _loc5_.y = 80;
      }
      
      override public function init() : void
      {
         var _loc1_:LipiButton = null;
         this.materialProxy = new MaterialProxyBig();
         this.materialProxy.x = 10;
         this.materialProxy.y = 50;
         addChild(this.materialProxy);
         this.titleText = new TextField();
         this.titleText.defaultTextFormat = new TextFormat(null,14,8999699,false);
         this.titleText.selectable = false;
         this.titleText.autoSize = TextFieldAutoSize.CENTER;
         this.titleText.x = 100;
         this.titleText.y = 70;
         this.titleText.multiline = true;
         this.titleText.width = 280;
         addChild(this.titleText);
         this.confirmButton = new LipiButton();
         this.confirmButton.bgAlpha = 0;
         this.confirmButton.bgSkin = new LipiSkin(MaterialLib.getInstance().getClass("ButtonOrange"));
         this.confirmButton.width = 80;
         this.confirmButton.height = 25;
         this.confirmButton.x = width / 2 - this.confirmButton.width - 10;
         this.confirmButton.y = height - 44;
         this.confirmButton.label = "购买工资卡";
         this.confirmButton.textColor = 16777215;
         this.confirmButton.addEventListener(MouseEvent.MOUSE_DOWN,this.confirmWindowClick);
         addChild(this.confirmButton);
         _loc1_ = new LipiButton();
         _loc1_.bgAlpha = 0;
         _loc1_.bgSkin = new LipiSkin(MaterialLib.getInstance().getClass("ButtonBlue"));
         _loc1_.width = 64;
         _loc1_.height = 25;
         _loc1_.x = width / 2 + 10;
         _loc1_.y = height - 44;
         _loc1_.label = "取消";
         _loc1_.textColor = 16777215;
         _loc1_.addEventListener(MouseEvent.CLICK,this.cancelButtonClick);
         addChild(_loc1_);
         this.setData();
      }
      
      override public function set data(param1:Object) : void
      {
         super.data = param1;
         this.setData();
      }
      
      private function confirmWindowClick(param1:MouseEvent) : void
      {
         this.confirmFn();
         this.closeMe();
      }
      
      override public function keyEnter() : void
      {
         this.confirmWindowClick(null);
      }
      
      private function cancelButtonClick(param1:MouseEvent) : void
      {
         this.closeMe();
      }
      
      private function closeMe() : void
      {
         var _loc1_:WindowEvent = new WindowEvent(WindowEvent.CLOSE);
         _loc1_.window = this;
         ViewControl.getInstance().dispatchEvent(_loc1_);
      }
   }
}

