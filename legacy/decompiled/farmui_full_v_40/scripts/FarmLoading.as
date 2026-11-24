package
{
   import flash.display.MovieClip;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol680")]
   public dynamic class FarmLoading extends MovieClip
   {
      
      public function FarmLoading()
      {
         super();
         addFrameScript(47,frame48);
      }
      
      internal function frame48() : *
      {
         gotoAndPlay("loop");
      }
   }
}

