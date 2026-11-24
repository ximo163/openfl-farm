package
{
   import flash.display.MovieClip;
   import flash.text.TextField;
   
   public dynamic class MaoPaoFlag extends MovieClip
   {
      
      public var infoTxt:TextField;
      
      public var talkInfo:String;
      
      public function MaoPaoFlag()
      {
         super();
      }
      
      internal function frame1() : *
      {
      }
      
      internal function frame24() : *
      {
         infoTxt.text = talkInfo;
         stop();
      }
   }
}

