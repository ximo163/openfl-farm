package
{
   import flash.display.MovieClip;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol57")]
   public dynamic class FishWave_3 extends MovieClip
   {
      
      public function FishWave_3()
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

