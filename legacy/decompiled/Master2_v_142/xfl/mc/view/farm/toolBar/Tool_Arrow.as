package mc.view.farm.toolBar
{
   import common.MaterialLib;
   import flash.display.SimpleButton;
   
   public class Tool_Arrow extends ToolBase
   {
      
      public function Tool_Arrow()
      {
         super();
         var _loc1_:SimpleButton = MaterialLib.getInstance().getMaterial("Cursor") as SimpleButton;
         addChild(_loc1_);
      }
   }
}

