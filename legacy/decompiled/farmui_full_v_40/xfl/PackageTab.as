package
{
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public dynamic class PackageTab extends MovieClip
   {
      
      public var btnTool:SimpleButton;
      
      public var btnSeed:SimpleButton;
      
      public var btnFish:SimpleButton;
      
      public var btn2:SimpleButton;
      
      public function PackageTab()
      {
         super();
      }
      
      internal function frame1() : *
      {
         btnTool.addEventListener(MouseEvent.CLICK,function():*
         {
            gotoAndStop(2);
            dispatchEvent(new Event("tool"));
         });
         btnFish.addEventListener(MouseEvent.CLICK,function():*
         {
            gotoAndStop(3);
            dispatchEvent(new Event("fish"));
         });
         stop();
      }
      
      internal function frame2() : *
      {
         btnSeed.addEventListener(MouseEvent.CLICK,function():*
         {
            gotoAndStop(1);
            dispatchEvent(new Event("seed"));
         });
         btnFish.addEventListener(MouseEvent.CLICK,function():*
         {
            gotoAndStop(3);
            dispatchEvent(new Event("fish"));
         });
         stop();
      }
      
      internal function frame3() : *
      {
         btnSeed.addEventListener(MouseEvent.CLICK,function():*
         {
            gotoAndStop(1);
            dispatchEvent(new Event("seed"));
         });
         btnTool.addEventListener(MouseEvent.CLICK,function():*
         {
            gotoAndStop(2);
            dispatchEvent(new Event("tool"));
         });
         stop();
      }
   }
}

