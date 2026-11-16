package mc.view.farm.toolBar
{
   import common.MaterialLib;
   import flash.display.SimpleButton;
   
   public class Tool_Camera extends ToolBase
   {
      
      public function Tool_Camera()
      {
         super();
         var _loc1_:SimpleButton = MaterialLib.getInstance().getMaterial("CameraButton") as SimpleButton;
         addChild(_loc1_);
      }
   }
}

