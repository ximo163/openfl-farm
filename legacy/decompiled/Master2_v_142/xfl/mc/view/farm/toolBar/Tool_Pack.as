package mc.view.farm.toolBar
{
   import common.MaterialLib;
   import flash.display.SimpleButton;
   
   public class Tool_Pack extends ToolBase
   {
      
      public function Tool_Pack()
      {
         super();
         var _loc1_:SimpleButton = MaterialLib.getInstance().getMaterial("ButtonSeed") as SimpleButton;
         addChild(_loc1_);
      }
   }
}

