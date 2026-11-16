package mc.view.farm.toolBar
{
   import common.MaterialLib;
   import flash.display.SimpleButton;
   
   public class Tool_Flapper extends ToolBase
   {
      
      public function Tool_Flapper()
      {
         super();
         var _loc1_:SimpleButton = MaterialLib.getInstance().getMaterial("FlapperButton") as SimpleButton;
         addChild(_loc1_);
      }
   }
}

