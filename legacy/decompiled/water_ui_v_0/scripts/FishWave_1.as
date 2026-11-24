package
{
   import flash.display.MovieClip;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol55")]
   public dynamic class FishWave_1 extends MovieClip
   {
      
      public function FishWave_1()
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

