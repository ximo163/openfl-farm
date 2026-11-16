package module.messages.widgets
{
   import com.qzone.qui.containers.TileList;
   import com.qzone.qui.controls.scrollClasses.ScrollPolicy;
   import flash.display.Sprite;
   
   public class ProfileHistory extends Sprite
   {
      
      private var _tile:TileList;
      
      public function ProfileHistory()
      {
         super();
         this._tile = new TileList();
         this._tile.itemRenderer = HistoryItem;
         this._tile.tileWidth = 90;
         this._tile.tileHeight = 100;
         this._tile.horizontalScrollPolicy = ScrollPolicy.OFF;
         this._tile.gapH = 0;
         this._tile.gapV = 0;
         this._tile.x = 20;
         this._tile.y = 2;
         this._tile.defaultSkin = null;
         this._tile.width = 470;
         this._tile.height = 210;
         addChild(this._tile);
      }
      
      public function get dataList() : Array
      {
         return this._tile.dataProvider;
      }
      
      public function set dataList(param1:Array) : void
      {
         this._tile.dataProvider = param1;
      }
   }
}

