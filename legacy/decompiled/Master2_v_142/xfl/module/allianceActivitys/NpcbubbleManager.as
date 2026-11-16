package module.allianceActivitys
{
   import common.MaterialLib;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.utils.clearTimeout;
   import flash.utils.setTimeout;
   
   public class NpcbubbleManager
   {
      
      private static var _mpFlag:MovieClip;
      
      public function NpcbubbleManager()
      {
         super();
      }
      
      public static function showBubble(param1:DisplayObjectContainer, param2:int, param3:String, param4:Number, param5:Number) : void
      {
         var _loc6_:int = 0;
         _mpFlag = MaterialLib.getInstance().getMaterial("MaoPaoFlag") as MovieClip;
         _mpFlag.mouseChildren = _mpFlag.mouseEnabled = false;
         param1.addChild(_mpFlag);
         _mpFlag.x = param4;
         _mpFlag.y = param5;
         _mpFlag.talkInfo = param3;
         _mpFlag.gotoAndPlay(2);
         _loc6_ = int(setTimeout(hideBubble,param2,param1,_loc6_));
      }
      
      public static function hideBubble(param1:DisplayObjectContainer, param2:int) : void
      {
         clearTimeout(param2);
         if(_mpFlag)
         {
            param1.removeChild(_mpFlag);
            _mpFlag = null;
         }
      }
   }
}

