package help0316_fla
{
   import flash.display.*;
   import flash.events.*;
   
   public dynamic class page1_9 extends MovieClip
   {
      
      public var nextButton:SimpleButton;
      
      public function page1_9()
      {
         super();
      }
      
      public function nextButtonClick(param1:MouseEvent) : void
      {
         dispatchEvent(new Event("nextButtonClick"));
      }
   }
}

