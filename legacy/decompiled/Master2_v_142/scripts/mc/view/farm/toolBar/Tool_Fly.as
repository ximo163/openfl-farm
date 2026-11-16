package mc.view.farm.toolBar
{
   import common.MaterialLib;
   import flash.display.SimpleButton;
   
   public class Tool_Fly extends ToolBase
   {
      
      public function Tool_Fly()
      {
         super();
         var _loc1_:SimpleButton = MaterialLib.getInstance().getMaterial("FlyButton") as SimpleButton;
         addChild(_loc1_);
      }
   }
}

