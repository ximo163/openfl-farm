package module.shop.widgets
{
   import com.qzone.qui.controls.Label;
   import com.qzone.qui.controls.scrollClasses.ScrollPolicy;
   import common.view.window.WindowLabelMaker;
   import flash.display.DisplayObjectContainer;
   import framework.base.BasePage;
   
   public class FishPage extends BasePage
   {
      
      public function FishPage(param1:DisplayObjectContainer, param2:int, param3:int)
      {
         var _loc4_:Label = null;
         super(param1,param2,param3);
         _loc4_ = new Label("鱼苗需要解锁才可以进行购买，解锁鱼苗需要花费一定的资源。");
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
            _tile.itemRenderer = FishItem;
            _tile.y = 22;
            _tile.width = _preferedWidth - 5;
            _tile.height = 273;
         }
      }
   }
}

