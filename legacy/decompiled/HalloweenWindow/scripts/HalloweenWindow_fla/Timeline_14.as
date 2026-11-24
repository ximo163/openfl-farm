package HalloweenWindow_fla
{
   import flash.display.MovieClip;
   import flash.events.Event;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol195")]
   public dynamic class Timeline_14 extends MovieClip
   {
      
      public function Timeline_14()
      {
         super();
         addFrameScript(24,this.frame25);
      }
      
      internal function frame25() : *
      {
         stop();
         dispatchEvent(new Event("eggJumpStop"));
      }
   }
}

