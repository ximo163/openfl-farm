package module.monthBegin
{
   import com.minutes.ui.control.LipiButton;
   import com.minutes.ui.core.LipiSkin;
   import common.MaterialLib;
   import flash.display.Loader;
   import flash.events.MouseEvent;
   import flash.net.URLRequest;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import mc.view.common.BaseWindow;
   import mc.view.farm.GetCropID;
   
   public class MonthEndGift extends BaseWindow
   {
      
      public function MonthEndGift()
      {
         var _loc1_:Loader = null;
         super();
         this.width = 400;
         this.height = 250;
         _loc1_ = new Loader();
         _loc1_.load(new URLRequest(GetCropID.addPrefix("module/mc/icon/monthend.png")));
         addChild(_loc1_);
         _loc1_.x = 150;
         _loc1_.y = 40;
         var _loc2_:TextFormat = new TextFormat("Verdana",15,8999699,null,null,null,null,null,"center");
         var _loc3_:TextField = new TextField();
         _loc3_.width = 360;
         _loc3_.height = 200;
         _loc3_.x = 30;
         _loc3_.y = 160;
         _loc3_.wordWrap = true;
         _loc3_.multiline = true;
         _loc3_.selectable = false;
         addChild(_loc3_);
         _loc3_.defaultTextFormat = _loc2_;
         _loc3_.htmlText = "功夫不费有心人，恭喜您刷新出了本轮礼包的全部隐藏礼品。";
         var _loc4_:LipiButton = new LipiButton();
         _loc4_.width = 60;
         _loc4_.height = 25;
         _loc4_.bgAlpha = 0;
         _loc4_.bgSkin = new LipiSkin(MaterialLib.getInstance().getClass("ButtonGreen"));
         _loc4_.x = 175;
         _loc4_.y = 210;
         _loc4_.label = "确定";
         _loc4_.textColor = 16777215;
         _loc4_.addEventListener(MouseEvent.CLICK,this.closeBtnHandler);
         addChild(_loc4_);
      }
      
      private function closeBtnHandler(param1:MouseEvent) : void
      {
         this.closeHandler();
      }
   }
}

