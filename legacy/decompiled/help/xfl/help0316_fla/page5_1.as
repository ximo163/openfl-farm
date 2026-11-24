package help0316_fla
{
   import flash.display.*;
   import flash.events.*;
   
   public dynamic class page5_1 extends MovieClip
   {
      
      public var closeButton2:SimpleButton;
      
      public var preButton:SimpleButton;
      
      public function page5_1()
      {
         super();
      }
      
      public function closeButtonClick(param1:MouseEvent) : void
      {
         dispatchEvent(new Event("closeEvent",true));
      }
      
      public function preButtonClick(param1:MouseEvent) : void
      {
         dispatchEvent(new Event("preButtonClick"));
      }
   }
}

