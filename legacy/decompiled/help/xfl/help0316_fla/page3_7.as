package help0316_fla
{
   import flash.display.*;
   import flash.events.*;
   
   public dynamic class page3_7 extends MovieClip
   {
      
      public var nextButton:SimpleButton;
      
      public var preButton:SimpleButton;
      
      public function page3_7()
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

