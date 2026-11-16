package mc.view.farm.toolBar
{
   import common.MaterialLib;
   import flash.display.SimpleButton;
   
   public class Tool_ClearBB extends ToolBase
   {
      
      public function Tool_ClearBB()
      {
         super();
         var _loc1_:SimpleButton = MaterialLib.getInstance().getMaterial("BBButton") as SimpleButton;
         addChild(_loc1_);
      }
   }
}

