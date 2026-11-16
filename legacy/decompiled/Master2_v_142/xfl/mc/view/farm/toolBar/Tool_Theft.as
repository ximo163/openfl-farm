package mc.view.farm.toolBar
{
   import common.MaterialLib;
   import flash.display.SimpleButton;
   
   public class Tool_Theft extends ToolBase
   {
      
      public function Tool_Theft()
      {
         super();
         var _loc1_:SimpleButton = MaterialLib.getInstance().getMaterial("ButtonTheft") as SimpleButton;
         addChild(_loc1_);
      }
   }
}

