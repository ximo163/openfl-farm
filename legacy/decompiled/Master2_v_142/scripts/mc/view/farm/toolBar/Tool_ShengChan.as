package mc.view.farm.toolBar
{
   import common.MaterialLib;
   import flash.display.SimpleButton;
   
   public class Tool_ShengChan extends ToolBase
   {
      
      public function Tool_ShengChan()
      {
         super();
         var _loc1_:SimpleButton = MaterialLib.getInstance().getMaterial("ShengChanButton") as SimpleButton;
         addChild(_loc1_);
      }
   }
}

