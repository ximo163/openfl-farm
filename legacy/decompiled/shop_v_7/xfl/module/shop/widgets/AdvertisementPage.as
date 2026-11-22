package module.shop.widgets
{
   import com.qzone.qui.controls.Label;
   import com.qzone.qui.controls.scrollClasses.ScrollPolicy;
   import common.Language;
   import common.view.window.WindowLabelMaker;
   import flash.display.DisplayObjectContainer;
   import framework.base.BasePage;
   
   public class AdvertisementPage extends BasePage
   {
      
      public function AdvertisementPage(param1:DisplayObjectContainer, param2:int, param3:int)
      {
         var _loc4_:Label = null;
         super(param1,param2,param3);
         _loc4_ = new Label(Language.L["adTileDirection"]);
         _loc4_.x = 2;
         _loc4_.width = param2 - 3;
         WindowLabelMaker.addTarget(_loc4_);
         addChild(_loc4_);
      }
      
      override protected function onCreateTile() : void
      {
         if(_tile != null)
         {
            _tile.paddingH = 17;
            _tile.paddingV = 7;
            _tile.gapH = 10;
            _tile.gapV = 10;
            _tile.tileWidth = 147;
            _tile.tileHeight = 140;
            _tile.defaultSkin = null;
            _tile.horizontalScrollPolicy = ScrollPolicy.OFF;
            _tile.itemRenderer = AdvertisementItem;
            _tile.y = 22;
            _tile.width = _preferedWidth - 5;
            _tile.height = 310;
         }
      }
   }
}

