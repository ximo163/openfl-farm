package help0316_fla
{
   import flash.display.*;
   import flash.events.*;
   
   [SWF(width="1010", height="780", backgroundColor="#ffffff", frameRate="12")]
   public dynamic class MainTimeline extends MovieClip
   {
      
      public var closeButton1:SimpleButton;
      
      public var page2:MovieClip;
      
      public var page3:MovieClip;
      
      public var page1:MovieClip;
      
      public var page5:MovieClip;
      
      public var page4:MovieClip;
      
      public function MainTimeline()
      {
         super();
      }
      
      public function nextClick(param1:Event) : void
      {
         page1.visible = false;
         page2.visible = false;
         page3.visible = false;
         page4.visible = false;
         page5.visible = false;
         if(param1.currentTarget == page1)
         {
            page2.visible = true;
         }
         else if(param1.currentTarget == page2)
         {
            page3.visible = true;
         }
         else if(param1.currentTarget == page3)
         {
            page4.visible = true;
         }
         else if(param1.currentTarget == page4)
         {
            page5.visible = true;
         }
      }
      
      public function closeButtonClick(param1:MouseEvent) : void
      {
         dispatchEvent(new Event("closeEvent"));
      }
      
      public function preClick(param1:Event) : void
      {
         page1.visible = false;
         page2.visible = false;
         page3.visible = false;
         page4.visible = false;
         page5.visible = false;
         if(param1.currentTarget == page5)
         {
            page4.visible = true;
         }
         else if(param1.currentTarget == page2)
         {
            page1.visible = true;
         }
         else if(param1.currentTarget == page3)
         {
            page2.visible = true;
         }
         else if(param1.currentTarget == page4)
         {
            page3.visible = true;
         }
      }
   }
}

