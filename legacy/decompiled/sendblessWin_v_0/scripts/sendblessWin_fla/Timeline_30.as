package sendblessWin_fla
{
   import flash.display.MovieClip;
   import flash.events.Event;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol144")]
   public dynamic class Timeline_30 extends MovieClip
   {
      
      public function Timeline_30()
      {
         super();
         addFrameScript(0,this.frame1,11,this.frame12);
      }
      
      internal function frame1() : *
      {
         stop();
      }
      
      internal function frame12() : *
      {
         if(parent)
         {
            parent.dispatchEvent(new Event("movieMoveOut"));
         }
      }
   }
}

