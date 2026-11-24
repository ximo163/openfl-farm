package
{
   import flash.display.MovieClip;
   import flash.text.TextField;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol232")]
   public dynamic class MaoPaoFlag extends MovieClip
   {
      
      public var infoTxt:TextField;
      
      public var talkInfo:String;
      
      public function MaoPaoFlag()
      {
         super();
         addFrameScript(0,frame1,23,frame24);
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

