package mc.view.main.leftInfo
{
   import common.MaterialLib;
   import flash.display.MovieClip;
   import mc.view.farm.toolBar.ToolBase;
   
   public class GiftIcon extends ToolBase
   {
      
      private var _icon:MovieClip;
      
      public function GiftIcon()
      {
         super();
         this._icon = MaterialLib.getInstance().getMaterial("GiftIcon") as MovieClip;
         addChild(this._icon);
         buttonMode = true;
         useHandCursor = true;
      }
      
      public function stopIcon() : void
      {
         this._icon.gotoAndStop(1);
      }
      
      public function NoVipIcon() : void
      {
         this._icon.gotoAndStop(2);
      }
      
      public function playIcon() : void
      {
         this._icon.gotoAndPlay("GiftMove");
      }
   }
}

