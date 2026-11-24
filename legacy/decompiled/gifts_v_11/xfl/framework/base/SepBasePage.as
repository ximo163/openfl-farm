package framework.base
{
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   
   public class SepBasePage extends BasePage
   {
      
      private var prevPageBtn:SimpleButton;
      
      private var bottomPage:MovieClip;
      
      private var nextPageBtn:SimpleButton;
      
      public function SepBasePage(param1:DisplayObjectContainer, param2:int, param3:int)
      {
         super(param1,param2,param3);
      }
   }
}

