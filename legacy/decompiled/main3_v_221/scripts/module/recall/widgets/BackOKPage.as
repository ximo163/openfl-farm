package module.recall.widgets
{
   import com.qzone.qui.containers.TileList;
   import com.qzone.qui.controls.scrollClasses.ScrollPolicy;
   import flash.display.DisplayObjectContainer;
   import framework.base.BasePage;
   
   public class BackOKPage extends BasePage
   {
      
      private var _normalCache:Array;
      
      public function BackOKPage(param1:DisplayObjectContainer, param2:int, param3:int)
      {
         super(param1,param2,param3);
         this._normalCache = null;
      }
      
      override protected function onCreateTile() : void
      {
         if(_tile != null)
         {
            _tile.paddingH = 10;
            _tile.paddingV = 10;
            _tile.gapH = 0;
            _tile.gapV = 0;
            _tile.tileWidth = 400;
            _tile.tileHeight = 70;
            _tile.defaultSkin = null;
            _tile.horizontalScrollPolicy = ScrollPolicy.OFF;
            _tile.itemRenderer = BackOKItem;
            _tile.y = 25;
            _tile.width = _preferedWidth - 5;
            _tile.height = 220;
         }
      }
      
      override public function set dataList(param1:Array) : void
      {
         if(_tile == null)
         {
            _tile = new TileList();
            this.onCreateTile();
            addChild(_tile);
         }
         this._normalCache = param1;
         _tile.dataProvider = this._normalCache;
      }
   }
}

