package mc.view.farm.toolBar
{
   import common.MaterialLib;
   import flash.display.SimpleButton;
   
   public class Tool_Whistle2 extends ToolBase
   {
      
      public function Tool_Whistle2()
      {
         super();
         var _loc1_:SimpleButton = MaterialLib.getInstance().getMaterial("WhistleButton2") as SimpleButton;
         addChild(_loc1_);
      }
   }
}

