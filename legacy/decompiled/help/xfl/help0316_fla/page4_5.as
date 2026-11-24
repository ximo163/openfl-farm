package help0316_fla
{
   import flash.display.*;
   import flash.events.*;
   
   public dynamic class page4_5 extends MovieClip
   {
      
      public var nextButton:SimpleButton;
      
      public var preButton:SimpleButton;
      
      public function page4_5()
      {
         super();
      }
      
      public function nextButtonClick(param1:MouseEvent) : void
      {
         dispatchEvent(new Event("nextButtonClick"));
      }
      
      public function preButtonClick(param1:MouseEvent) : void
      {
         dispatchEvent(new Event("preButtonClick"));
      }
   }
}

