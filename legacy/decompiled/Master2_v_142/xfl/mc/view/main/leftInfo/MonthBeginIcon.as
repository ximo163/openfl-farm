package mc.view.main.leftInfo
{
   import common.MaterialLib;
   import flash.display.MovieClip;
   import mc.view.farm.toolBar.ToolBase;
   
   public class MonthBeginIcon extends ToolBase
   {
      
      private var _icon:MovieClip;
      
      public function MonthBeginIcon()
      {
         super();
         this._icon = MaterialLib.getInstance().getMaterial("MonthBeginIcon") as MovieClip;
         addChild(this._icon);
         mouseChildren = false;
         buttonMode = true;
         useHandCursor = true;
      }
   }
}

