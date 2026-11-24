package
{
   import flash.display.MovieClip;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol51")]
   public dynamic class FishWave_0 extends MovieClip
   {
      
      public function FishWave_0()
      {
         super();
         addFrameScript(14,this.frame15);
      }
      
      internal function frame15() : *
      {
         if(parent != null)
         {
            parent.removeChild(this);
         }
      }
   }
}

