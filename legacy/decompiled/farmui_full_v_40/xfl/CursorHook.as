package
{
   import flash.display.MovieClip;
   
   public dynamic class CursorHook extends MovieClip
   {
      
      public function CursorHook()
      {
         super();
      }
      
      internal function frame1() : *
      {
         stop();
      }
   }
}

