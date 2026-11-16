package framework.base
{
   import com.qzone.qui.containers.TileList;
   import common.view.DataLoading;
   import events.ViewEvent;
   import flash.display.DisplayObjectContainer;
   import flash.display.Sprite;
   
   public class BasePage extends Sprite
   {
      
      protected var _view:DisplayObjectContainer;
      
      protected var _tile:TileList;
      
      protected var _preferedHeight:int;
      
      protected var _preferedWidth:int;
      
      protected var _dataLoading:DataLoading;
      
      public function BasePage(param1:DisplayObjectContainer, param2:int, param3:int)
      {
         super();
         this._preferedWidth = param2;
         this._preferedHeight = param3;
         this._view = param1;
         this._tile = null;
         this.createLoadingBar();
      }
      
      protected function createLoadingBar() : void
      {
         if(this._dataLoading == null)
         {
            this._dataLoading = new DataLoading();
            this._dataLoading.addEventListener(ViewEvent.LINK_CLICK,this.onLinkClicked);
            this._dataLoading.x = (this._preferedWidth - this._dataLoading.width) / 2;
            this._dataLoading.y = (this._preferedHeight - this._dataLoading.height) / 2;
            addChild(this._dataLoading);
         }
      }
      
      protected function onCreateTile() : void
      {
      }
      
      public function set errText(param1:String) : void
      {
         if(this._dataLoading != null)
         {
            this._dataLoading.errorText = param1;
         }
      }
      
      protected function setData() : void
      {
      }
      
      private function onLinkClicked(param1:ViewEvent) : void
      {
         if(param1 == null || param1.data == null)
         {
            return;
         }
         var _loc2_:ViewEvent = new ViewEvent(ViewEvent.LINK_CLICK);
         _loc2_.data = param1.data;
         dispatchEvent(_loc2_);
      }
      
      public function get dataList() : Array
      {
         if(this._tile == null)
         {
            return null;
         }
         return this._tile.dataProvider;
      }
      
      public function set dataList(param1:Array) : void
      {
         if(this._tile == null)
         {
            this._tile = new TileList();
            this.onCreateTile();
            addChild(this._tile);
         }
         this._tile.dataProvider = param1;
         this.setData();
      }
      
      public function set loadingVisible(param1:Boolean) : void
      {
         if(this._dataLoading != null)
         {
            this._dataLoading.visible = param1;
         }
         if(this._tile != null)
         {
            this._tile.visible = !param1;
         }
      }
   }
}

