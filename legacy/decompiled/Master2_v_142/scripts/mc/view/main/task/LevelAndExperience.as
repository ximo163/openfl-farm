package mc.view.main.task
{
   import common.MaterialLib;
   import flash.display.Sprite;
   
   public class LevelAndExperience extends Task
   {
      
      public function LevelAndExperience()
      {
         var _loc1_:Sprite = null;
         super();
         this.width = 470;
         this.height = 290;
         titleIMG = MaterialLib.getInstance().getClass("LExpTitle");
         operationAction = closeWindow;
         operationButtonLabel = "确定";
         addCancelButton = false;
         _loc1_ = MaterialLib.getInstance().getMaterial("LevelAndExperienss") as Sprite;
         if(_loc1_ != null)
         {
            _loc1_.y = 55;
            _loc1_.x = 30;
            _loc1_.mouseEnabled = false;
            taskAddChild(_loc1_);
         }
      }
   }
}

