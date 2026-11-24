package
{
   import flash.display.*;
   import flash.events.*;
   import flash.text.*;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol48")]
   public dynamic class CardsGameWindow extends MovieClip
   {
      
      public var loginDays:TextField;
      
      public var yellowText:TextField;
      
      public var closeBtn:SimpleButton;
      
      public var yellowBtn_vip:SimpleButton;
      
      public var yellowBtn:SimpleButton;
      
      public var giftText1:TextField;
      
      public var giftText2:TextField;
      
      public var giftText3:TextField;
      
      public function CardsGameWindow()
      {
         super();
         addFrameScript(0,frame1);
      }
      
      internal function frame1() : *
      {
         closeBtn.addEventListener(MouseEvent.CLICK,function():*
         {
            dispatchEvent(new Event("closeCardsGameWindow"));
         });
         yellowBtn.addEventListener(MouseEvent.CLICK,function():*
         {
            dispatchEvent(new Event("openVipLink"));
         });
         yellowBtn_vip.addEventListener(MouseEvent.CLICK,function():*
         {
            dispatchEvent(new Event("openVipLink"));
         });
      }
   }
}

