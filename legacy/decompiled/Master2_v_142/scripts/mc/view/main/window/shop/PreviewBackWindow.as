package mc.view.main.window.shop
{
   import com.minutes.ui.control.LipiButton;
   import com.minutes.ui.core.LipiSkin;
   import common.MaterialLib;
   import flash.events.MouseEvent;
   import mc.control.Command;
   import mc.control.ViewControl;
   import mc.view.ViewEvent;
   import mc.view.common.AddButtonWindow;
   
   public class PreviewBackWindow extends AddButtonWindow
   {
      
      public function PreviewBackWindow()
      {
         var _loc1_:LipiButton = null;
         super();
         this.width = 160;
         this.height = 80;
         this.mode = false;
         titleIMG = MaterialLib.getInstance().getClass("CancelViewTitle");
         _loc1_ = new LipiButton();
         _loc1_.bgAlpha = 0;
         _loc1_.bgSkin = new LipiSkin(MaterialLib.getInstance().getClass("ButtonOrange"));
         _loc1_.width = 64;
         _loc1_.height = 25;
         _loc1_.x = width / 2 - _loc1_.width / 2;
         _loc1_.y = height - 20;
         _loc1_.label = "取消预览";
         _loc1_.textColor = 16777215;
         _loc1_.addEventListener(MouseEvent.CLICK,this.confirmButtonClick);
         addChild(_loc1_);
      }
      
      override protected function closeHandler() : void
      {
         super.closeHandler();
         ViewControl.getInstance().dispatchEvent(new ViewEvent("showWindow"));
         Command.getInstance().mainCommand.preview(null);
      }
      
      private function backShop() : void
      {
         this.closeHandler();
      }
      
      private function confirmButtonClick(param1:MouseEvent = null) : void
      {
         this.closeHandler();
      }
   }
}

