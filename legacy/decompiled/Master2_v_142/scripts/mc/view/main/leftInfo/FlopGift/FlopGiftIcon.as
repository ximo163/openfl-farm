package mc.view.main.leftInfo.FlopGift
{
   import common.MaterialLib;
   import flash.display.MovieClip;
   import mc.view.farm.toolBar.ToolBase;
   
   public class FlopGiftIcon extends ToolBase
   {
      
      private var _icon:MovieClip;
      
      public function FlopGiftIcon()
      {
         super();
         this._icon = MaterialLib.getInstance().getMaterial("FlopIcon") as MovieClip;
         addChild(this._icon);
         buttonMode = true;
         useHandCursor = true;
      }
   }
}

