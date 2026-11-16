package mc.view.farm.toolBar
{
   import common.MaterialLib;
   import flash.display.SimpleButton;
   
   public class Tool_Whistle extends ToolBase
   {
      
      public function Tool_Whistle()
      {
         super();
         var _loc1_:SimpleButton = MaterialLib.getInstance().getMaterial("WhistleButton") as SimpleButton;
         addChild(_loc1_);
      }
   }
}

