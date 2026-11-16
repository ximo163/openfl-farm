package mc.view.main.leftInfo
{
   import common.MaterialLib;
   import flash.display.MovieClip;
   import mc.view.farm.toolBar.ToolBase;
   
   public class InformationIcon extends ToolBase
   {
      
      private var _icon:MovieClip;
      
      public function InformationIcon()
      {
         super();
         this._icon = MaterialLib.getInstance().getMaterial("InformationIcon") as MovieClip;
         this._icon.gotoAndStop(1);
         addChild(this._icon);
         buttonMode = true;
         useHandCursor = true;
      }
      
      public function stopIcon() : void
      {
         this._icon.gotoAndStop(1);
      }
      
      public function playIcon() : void
      {
         this._icon.play();
      }
   }
}

