package com.qzone.allianceActivity
{
   import flash.display.MovieClip;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol6")]
   public dynamic class ArborDayEntranceIconView extends MovieClip
   {
      
      public var tfMc:ScoreTfMc;
      
      public function ArborDayEntranceIconView()
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

