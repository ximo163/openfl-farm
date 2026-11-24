package com.qzone.allianceActivity
{
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.text.TextField;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol17")]
   public dynamic class ArborDayFinalPresentPanelView extends MovieClip
   {
      
      public var getScoreBtn:SimpleButton;
      
      public var faultMsgTf:TextField;
      
      public var closeBtn:SimpleButton;
      
      public function ArborDayFinalPresentPanelView()
      {
         super();
         addFrameScript(0,this.frame1);
      }
      
      internal function frame1() : *
      {
         stop();
      }
   }
}

