package module.cardsgame
{
   import common.Consts;
   import common.misc.Utils;
   import framework.base.BaseLayer;
   import framework.base.Controller;
   import framework.base.Module;
   import module.FarmApplication;
   
   public class ModuleCardsGame extends Module
   {
      
      private var _controller:Controller;
      
      public function ModuleCardsGame(param1:FarmApplication)
      {
         super(param1);
         _reportID = "160614";
      }
      
      override protected function onModuleLoadSuccess() : void
      {
         var _loc1_:Class = Utils.getClass("module.cardsgame.CardsGameController");
         if(_loc1_ != null)
         {
            this._controller = new _loc1_();
            this._controller.module = this;
            this._controller.initialze();
         }
      }
      
      override public function get name() : String
      {
         return Consts.MODULE_CARDS_GAME;
      }
      
      override public function load(param1:BaseLayer) : void
      {
      }
      
      override public function unload() : void
      {
         if(this._controller != null)
         {
            this._controller.finalize();
            this._controller = null;
         }
      }
   }
}

