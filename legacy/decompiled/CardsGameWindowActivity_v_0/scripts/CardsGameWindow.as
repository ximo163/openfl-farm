package
{
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol73")]
   public dynamic class CardsGameWindow extends MovieClip
   {
      
      public var yellowBtn:SimpleButton;
      
      public var giftText3:TextField;
      
      public var giftText2:TextField;
      
      public var yellowBtn_vip:SimpleButton;
      
      public var yellowText:TextField;
      
      public var loginDays:TextField;
      
      public var closeBtn:SimpleButton;
      
      public var Activity:MovieClip;
      
      public var giftText1:TextField;
      
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

