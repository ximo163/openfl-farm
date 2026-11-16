package mc.view.farm.toolBar
{
   import common.MaterialLib;
   import flash.display.SimpleButton;
   
   public class Tool_Donate extends ToolBase
   {
      
      public function Tool_Donate()
      {
         super();
         var _loc1_:SimpleButton = MaterialLib.getInstance().getMaterial("DonateButton") as SimpleButton;
         addChild(_loc1_);
      }
   }
}

