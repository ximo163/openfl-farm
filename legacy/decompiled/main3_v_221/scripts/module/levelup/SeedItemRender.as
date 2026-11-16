package module.levelup
{
   import common.Consts;
   import common.misc.Utils;
   import common.view.MaterialProxy;
   import entities.Seed;
   import flash.display.Sprite;
   
   public class SeedItemRender extends Sprite
   {
      
      public static const ROW_GAP:int = 72;
      
      public static const COLUMN_GAP:int = 86;
      
      private var _data:Seed;
      
      private var _ui:Sprite;
      
      public function SeedItemRender(param1:Seed)
      {
         super();
         this._data = param1;
         this._ui = Utils.getMaterial("Update.seedsRender") as Sprite;
         this.setData();
      }
      
      private function setData() : void
      {
         var _loc1_:MaterialProxy = null;
         this._ui["nameTxt"].text = this._data._name;
         _loc1_ = new MaterialProxy();
         _loc1_.mouseEnabled = false;
         _loc1_.setContent(Consts.ITEM_TYPE_SEED,this._data._id);
         var _loc2_:Sprite = this._ui["holder"];
         _loc1_.x = _loc2_.x;
         _loc1_.y = _loc2_.y;
         this._ui.addChild(_loc1_);
         addChild(this._ui);
      }
   }
}

