package module.levelup
{
   import common.Consts;
   import events.CommonEvent;
   import framework.base.Module;
   import module.FarmApplication;
   
   public class LevelUpModule extends Module
   {
      
      private var _model:LevelUpModel;
      
      public function LevelUpModule(param1:FarmApplication)
      {
         super(param1);
         this._model = new LevelUpModel();
         param1.addEventListener(Consts.MSG_USER_LEVEL_UP,this.__onLevelUp);
      }
      
      private function __onLevelUp(param1:CommonEvent) : void
      {
         var _loc5_:LevelUpWindow = null;
         var _loc2_:Object = param1.data;
         var _loc3_:int = int(_loc2_.preLevel);
         var _loc4_:int = int(_loc2_.nowLevel);
         while(_loc4_ > _loc3_)
         {
            _loc5_ = new LevelUpWindow(_loc4_,this._model,app);
            _loc4_--;
         }
      }
   }
}

