package mc.view.farm
{
   import common.MaterialLib;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import mc.model.MData;
   import mc.model.MainData;
   
   public class MPScene extends Sprite
   {
      
      public static const MAO_PAO:String = "maopao";
      
      public static const OPEN_MAOPAO:String = "openMP";
      
      private var mainData:MainData;
      
      private var _mpFlag:MovieClip;
      
      public function MPScene()
      {
         super();
         this._mpFlag = MaterialLib.getInstance().getMaterial("MaoPaoFlag") as MovieClip;
         this.mainData = MData.getInstance().mainData;
         this.mainData.addEventListener(MPScene.OPEN_MAOPAO,this.showMP);
         this.mainData.addEventListener(MainData.CURRENT_USER_CHANGE,this.hideMP);
         this.mouseChildren = false;
         this.mouseEnabled = false;
      }
      
      private function showMP(param1:Event = null) : void
      {
         if(this.mainData.mpData == null)
         {
            if(this._mpFlag.parent)
            {
               this._mpFlag.parent.removeChild(this._mpFlag);
            }
            return;
         }
         addChild(this._mpFlag);
         this._mpFlag.x = this.mainData.mpData["vx"];
         this._mpFlag.y = this.mainData.mpData["vy"];
         this._mpFlag.talkInfo = this.mainData.mpData["talkInfo"] || "";
         this._mpFlag.gotoAndPlay(2);
      }
      
      private function hideMP(param1:Event = null) : void
      {
         this.mainData.mpData = null;
      }
   }
}

