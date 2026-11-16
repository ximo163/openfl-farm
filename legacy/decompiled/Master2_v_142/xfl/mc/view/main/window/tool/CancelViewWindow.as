package mc.view.main.window.tool
{
   import com.minutes.ui.control.LipiButton;
   import com.minutes.ui.core.LipiSkin;
   import common.MaterialLib;
   import flash.events.MouseEvent;
   import mc.control.ViewControl;
   import mc.events.WindowEvent;
   import mc.model.MData;
   import mc.view.common.BaseWindow;
   import mc.view.farm.WhistleManager;
   import mc.view.main.WindowControl.WControl;
   import mc.view.main.cursor.Cursor;
   
   public class CancelViewWindow extends BaseWindow
   {
      
      private var confirmButton:LipiButton;
      
      public function CancelViewWindow()
      {
         super();
         width = 160;
         height = 80;
         titleIMG = MaterialLib.getInstance().getClass("CancelViewTitle");
         windowName = "CancelViewWindow";
         mode = true;
      }
      
      override public function init() : void
      {
         this.addEventListener(MouseEvent.ROLL_OVER,this.onRollOver);
         this.addEventListener(MouseEvent.ROLL_OUT,this.onRollOut);
         this.confirmButton = new LipiButton();
         this.confirmButton.bgAlpha = 0;
         this.confirmButton.bgSkin = new LipiSkin(MaterialLib.getInstance().getClass("ButtonOrange"));
         this.confirmButton.width = 64;
         this.confirmButton.height = 25;
         this.confirmButton.x = width / 2 - this.confirmButton.width / 2;
         this.confirmButton.y = height - 20;
         this.confirmButton.label = "取消预览";
         this.confirmButton.textColor = 16777215;
         this.confirmButton.addEventListener(MouseEvent.CLICK,this.confirmButtonClick);
         addChild(this.confirmButton);
         this.setData();
      }
      
      private function onRollOut(param1:MouseEvent) : void
      {
         Cursor.useSystem(false);
      }
      
      private function confirmButtonClick(param1:MouseEvent = null) : void
      {
         var _loc2_:Object = null;
         var _loc3_:WhistleToolWindow = null;
         var _loc4_:WindowEvent = null;
         if(this.confirmButton.enable == true)
         {
            _loc2_ = MData.getInstance().toolData.viewWhistleData;
            _loc3_ = new WhistleToolWindow();
            _loc3_.data = _loc2_;
            WControl.open(_loc3_);
            WhistleManager.getInstance().stop();
            _loc4_ = new WindowEvent(WindowEvent.CLOSE);
            _loc4_.window = this;
            ViewControl.getInstance().dispatchEvent(_loc4_);
            if(MData.getInstance().toolData.mpData)
            {
               MData.getInstance().toolData.mpData = null;
            }
         }
      }
      
      private function onRollOver(param1:MouseEvent) : void
      {
         Cursor.useSystem(true);
      }
      
      override public function keyEnter() : void
      {
         this.confirmButtonClick();
      }
      
      override public function set data(param1:Object) : void
      {
         super.data = param1;
         this.setData();
      }
      
      private function cancelButtonClick(param1:MouseEvent) : void
      {
         var _loc2_:WindowEvent = new WindowEvent(WindowEvent.CLOSE);
         _loc2_.window = this;
         ViewControl.getInstance().dispatchEvent(_loc2_);
      }
      
      private function setData() : void
      {
         if(data == null)
         {
            return;
         }
      }
   }
}

