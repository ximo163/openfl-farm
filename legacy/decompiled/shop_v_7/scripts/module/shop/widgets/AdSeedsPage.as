package module.shop.widgets
{
   import com.qzone.qui.controls.Label;
   import com.qzone.qui.controls.scrollClasses.ScrollPolicy;
   import common.view.window.WindowLabelMaker;
   import flash.display.DisplayObjectContainer;
   import framework.base.BasePage;
   
   public class AdSeedsPage extends BasePage
   {
      
      private const _tile_height:int = 300;
      
      private const _tile_top:int = 23;
      
      public function AdSeedsPage(param1:DisplayObjectContainer, param2:int, param3:int)
      {
         var _loc4_:Label = null;
         super(param1,param2,param3);
         _loc4_ = new Label("温馨提示：合作专区中的物品非全部用户可见，且限时限量供应，欲购从速哦~~");
         _loc4_.x = 2;
         _loc4_.width = param2 - 3;
         WindowLabelMaker.addTarget(_loc4_);
         addChild(_loc4_);
      }
      
      override protected function onCreateTile() : void
      {
         if(_tile != null)
         {
            _tile.paddingH = 23;
            _tile.paddingV = 10;
            _tile.gapH = 0;
            _tile.gapV = 0;
            _tile.tileWidth = 90;
            _tile.tileHeight = 98;
            _tile.defaultSkin = null;
            _tile.horizontalScrollPolicy = ScrollPolicy.OFF;
            _tile.itemRenderer = CropItem;
            _tile.y = this._tile_top;
            _tile.width = _preferedWidth - 5;
            _tile.height = this._tile_height;
         }
      }
   }
}

