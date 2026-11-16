package mc.view.main.levelup
{
   import mc.model.MData;
   import mc.model.MainData;
   import mc.model.ModelEvent;
   
   public class LevelUpModule
   {
      
      private var _model:LevelUpModel;
      
      public function LevelUpModule()
      {
         super();
         this._model = new LevelUpModel();
         MData.getInstance().mainData.addEventListener(MainData.USER_LEVEL_UP,this.__onLevelUp);
      }
      
      private function __onLevelUp(param1:ModelEvent) : void
      {
         var _loc5_:LevelUpWindow = null;
         var _loc2_:Object = param1.data;
         var _loc3_:int = int(_loc2_.preLevel);
         var _loc4_:int = int(_loc2_.nowLevel);
         while(_loc4_ > _loc3_)
         {
            _loc5_ = new LevelUpWindow(_loc4_,this._model);
            _loc4_--;
         }
      }
   }
}

