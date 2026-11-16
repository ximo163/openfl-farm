package mc.view.farm.toolBar
{
   import common.MaterialLib;
   import flash.display.DisplayObject;
   import flash.display.SimpleButton;
   import flash.display.Sprite;
   import mc.model.MData;
   import mc.model.MainData;
   import mc.model.ModelEvent;
   
   public class Tool_Tools extends ToolBase
   {
      
      public function Tool_Tools()
      {
         var _loc2_:Sprite = null;
         super();
         var _loc1_:SimpleButton = MaterialLib.getInstance().getMaterial("ToolsButton") as SimpleButton;
         addChild(_loc1_);
         _loc2_ = MaterialLib.getInstance().getMaterial("NewIcon") as Sprite;
         _loc2_.x = 28;
         _loc2_.y = 5;
         _loc2_.mouseChildren = false;
         _loc2_.mouseEnabled = false;
         _loc2_.name = "newIcon";
         addChild(_loc2_);
         _loc2_.visible = false;
         var _loc3_:MainData = MData.getInstance().mainData;
         _loc3_.addEventListener(MainData.CURRENT_USER_CHANGE,this.currentUserChange,false,0,true);
      }
      
      private function currentUserChange(param1:ModelEvent) : void
      {
         var _loc2_:DisplayObject = getChildByName("newIcon");
         if(_loc2_ == null)
         {
            return;
         }
         var _loc3_:MainData = MData.getInstance().mainData;
      }
   }
}

