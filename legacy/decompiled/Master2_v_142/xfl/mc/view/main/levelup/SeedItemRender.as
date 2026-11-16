package mc.view.main.levelup
{
   import common.MaterialLib;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import mc.view.common.MaterialLoaderProxy;
   import mc.view.farm.GetCropID;
   
   public class SeedItemRender extends Sprite
   {
      
      public static const GAP_ROW:int = 76;
      
      private var _data:Object;
      
      private var _ui:Sprite;
      
      public function SeedItemRender(param1:Object)
      {
         super();
         this._data = param1;
         this._ui = MaterialLib.getInstance().getMaterial("Update.seedsRender") as Sprite;
         this.setData();
      }
      
      private function setData() : void
      {
         var _loc2_:MovieClip = null;
         this._ui["nameTxt"].text = this._data["cName"];
         var _loc1_:MaterialLoaderProxy = new MaterialLoaderProxy();
         _loc1_.mouseEnabled = false;
         _loc1_.setContent("1",this._data["cId"]);
         _loc1_.x = this._ui["holder"].x;
         _loc1_.y = this._ui["holder"].y;
         this._ui.addChildAt(_loc1_,0);
         if(GetCropID.getHouse(this._data["cId"]) == "窝")
         {
            _loc2_ = MaterialLib.getInstance().getMaterial("HouseIcon1") as MovieClip;
         }
         else
         {
            _loc2_ = MaterialLib.getInstance().getMaterial("HouseIcon2") as MovieClip;
         }
         _loc2_.x = 53;
         _loc2_.y = 48;
         this._ui.addChildAt(_loc2_,1);
         addChild(this._ui);
      }
   }
}

