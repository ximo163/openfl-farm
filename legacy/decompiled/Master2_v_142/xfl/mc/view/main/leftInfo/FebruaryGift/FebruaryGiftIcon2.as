package mc.view.main.leftInfo.FebruaryGift
{
   import common.MaterialLib;
   import flash.display.MovieClip;
   import mc.view.farm.toolBar.ToolBase;
   
   public class FebruaryGiftIcon2 extends ToolBase
   {
      
      private var _icon:MovieClip;
      
      public function FebruaryGiftIcon2()
      {
         super();
         this._icon = MaterialLib.getInstance().getMaterial("FebruaryBtn2") as MovieClip;
         addChild(this._icon);
         buttonMode = true;
         useHandCursor = true;
      }
   }
}

