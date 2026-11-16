package module.levelup
{
   import common.misc.Utils;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   
   public class LandRender extends Sprite
   {
      
      public static const NORMAL_LAND:int = 1;
      
      public static const RED_LAND:int = 2;
      
      public static const BLACK_LAND:int = 3;
      
      public static const ROW_GAP:int = 150;
      
      public static const COLUMN_GAP:int = 70;
      
      private var _data:Object;
      
      private var _ui:Sprite;
      
      public function LandRender(param1:Object)
      {
         super();
         this._data = param1;
         this._ui = Utils.getMaterial("Update.landRender") as Sprite;
         addChild(this._ui);
         this.setData();
      }
      
      private function setData() : void
      {
         if(this._data.landType == NORMAL_LAND)
         {
            this._ui["landTxt"].text = "黄土地";
            (this._ui["landIcon"] as MovieClip).gotoAndStop(NORMAL_LAND);
         }
         else if(this._data.landType == RED_LAND)
         {
            this._ui["landTxt"].text = "红土地";
            (this._ui["landIcon"] as MovieClip).gotoAndStop(RED_LAND);
         }
         else if(this._data.landType == BLACK_LAND)
         {
            this._ui["landTxt"].text = "黑土地";
            (this._ui["landIcon"] as MovieClip).gotoAndStop(BLACK_LAND);
         }
      }
   }
}

