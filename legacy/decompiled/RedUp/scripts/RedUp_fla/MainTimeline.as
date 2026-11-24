package RedUp_fla
{
   import flash.display.MovieClip;
   import flash.events.Event;
   
   [SWF(width="550", height="400", backgroundColor="#ffffff", frameRate="24")]
   public dynamic class MainTimeline extends MovieClip
   {
      
      public function MainTimeline()
      {
         super();
         addFrameScript(133,frame134);
      }
      
      internal function frame134() : *
      {
         this.dispatchEvent(new Event("end"));
      }
   }
}

