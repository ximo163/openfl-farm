package module.mainScene.farmLand.widgets
{
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.geom.Point;
   import flash.utils.clearTimeout;
   import flash.utils.setTimeout;
   
   public class LandTalkTip
   {
      
      private var m_mcTalk:MovieClip;
      
      private var m_parent:Sprite;
      
      private var m_timeout:uint;
      
      public function LandTalkTip(param1:Sprite)
      {
         super();
         this.m_parent = param1;
         this.m_mcTalk = null;
         this.m_timeout = 0;
      }
      
      public function get visible() : Boolean
      {
         if(this.m_parent != null && this.m_mcTalk != null && this.m_parent.contains(this.m_mcTalk) == true)
         {
            return true;
         }
         return false;
      }
      
      public function startTalk(param1:String, param2:Point, param3:Number = 1) : void
      {
         if(this.m_parent == null)
         {
            return;
         }
         if(param1 == "" || param2 == null)
         {
            return;
         }
         if(this.m_mcTalk == null)
         {
            this.m_mcTalk = new MaoPaoFlag();
            this.m_mcTalk.x = param2.x;
            this.m_mcTalk.y = param2.y;
            this.m_mcTalk.mouseChildren = false;
            this.m_mcTalk.mouseEnabled = false;
         }
         var _loc4_:Number = 1 / param3;
         if(this.m_parent.parent != null && this.m_parent.parent.scaleX > 1)
         {
            _loc4_ /= this.m_parent.parent.scaleX;
         }
         this.m_mcTalk.scaleX = _loc4_;
         this.m_mcTalk.scaleY = _loc4_;
         this.m_mcTalk.gotoAndPlay(1);
         this.m_mcTalk.talkInfo = param1;
         this.m_parent.addChild(this.m_mcTalk);
         this.m_timeout = setTimeout(this.stopTalk,5000);
      }
      
      public function set parent(param1:Sprite) : void
      {
         this.m_parent = param1;
      }
      
      public function stopTalk() : void
      {
         if(this.m_mcTalk == null)
         {
            return;
         }
         if(this.m_parent != null && this.m_parent.contains(this.m_mcTalk) == true)
         {
            this.m_parent.removeChild(this.m_mcTalk);
         }
         this.m_parent = null;
         if(this.m_timeout != 0)
         {
            clearTimeout(this.m_timeout);
         }
      }
   }
}

