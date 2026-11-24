package
{
   import flash.display.MovieClip;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol7")]
   public dynamic class FishFoodEffect extends MovieClip
   {
      
      public function FishFoodEffect()
      {
         super();
         addFrameScript(14,frame15);
      }
      
      internal function frame15() : *
      {
         stop();
         if(parent != null)
         {
            parent.removeChild(this);
         }
      }
   }
}

