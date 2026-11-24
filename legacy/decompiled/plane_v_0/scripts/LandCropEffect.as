package
{
   import flash.display.MovieClip;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol6")]
   public dynamic class LandCropEffect extends MovieClip
   {
      
      public function LandCropEffect()
      {
         super();
         addFrameScript(74,this.frame75);
      }
      
      internal function frame75() : *
      {
         if(parent != null)
         {
            parent.removeChild(this);
         }
      }
   }
}

