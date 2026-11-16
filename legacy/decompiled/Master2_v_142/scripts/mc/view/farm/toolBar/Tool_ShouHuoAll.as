package mc.view.farm.toolBar
{
   import common.MaterialLib;
   import flash.display.SimpleButton;
   
   public class Tool_ShouHuoAll extends ToolBase
   {
      
      public function Tool_ShouHuoAll()
      {
         super();
         var _loc1_:SimpleButton = MaterialLib.getInstance().getMaterial("ShouHuoAllButton") as SimpleButton;
         addChild(_loc1_);
      }
   }
}

