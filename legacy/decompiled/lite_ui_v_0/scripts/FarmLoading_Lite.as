package
{
   import flash.display.MovieClip;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol9")]
   public dynamic class FarmLoading_Lite extends MovieClip
   {
      
      public function FarmLoading_Lite()
      {
         super();
         addFrameScript(47,this.frame48);
      }
      
      internal function frame48() : *
      {
         gotoAndPlay("loop");
      }
   }
}

