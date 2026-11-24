package
{
   import flash.display.MovieClip;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol53")]
   public dynamic class FishWave_2 extends MovieClip
   {
      
      public function FishWave_2()
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

