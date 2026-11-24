package module.FreeGift.widgets2
{
   import com.qzone.qui.containers.TileList;
   import com.qzone.qui.controls.scrollClasses.ScrollPolicy;
   import common.Settings;
   import events.ViewEvent;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import framework.base.BaseTileItem;
   import framework.base.SepBasePage;
   
   public class GiftSetFriends extends SepBasePage
   {
      
      private var _giftID:int;
      
      private var _vscrollPosition:int;
      
      private var _oldItem:GiftSetItem;
      
      private var _normalCache:Array;
      
      public function GiftSetFriends(param1:DisplayObjectContainer, param2:int, param3:int)
      {
         super(param1,param2,param3);
         this._normalCache = null;
      }
      
      private function changsDataHandler(param1:ViewEvent) : void
      {
         var _loc2_:MovieClip = null;
         if(this._oldItem)
         {
            _loc2_ = this._oldItem.getChildByName("__tick__") as MovieClip;
            if(_loc2_)
            {
               this._oldItem.removeChild(_loc2_);
               _loc2_ = null;
            }
         }
         this._oldItem = param1.target as GiftSetItem;
         this._oldItem.name = "__oldTick__";
      }
      
      override protected function onCreateTile() : void
      {
         if(_tile != null)
         {
            _tile.paddingH = 40;
            _tile.paddingV = 5;
            _tile.gapH = 0;
            _tile.gapV = 0;
            _tile.tileWidth = 100;
            _tile.tileHeight = 128;
            _tile.verticalScrollPolicy = ScrollPolicy.OFF;
            _tile.defaultSkin = null;
            _tile.horizontalScrollPolicy = ScrollPolicy.OFF;
            _tile.itemRenderer = GiftSetItem;
            _tile.y = 15;
            _tile.width = _preferedWidth - 5;
            _tile.height = 265;
         }
         _tile.addEventListener(BaseTileItem.CHILD_CLICK,this.changsDataHandler,false,0,true);
      }
      
      override public function set dataList(param1:Array) : void
      {
         var _loc2_:* = 0;
         var _loc4_:Object = null;
         if(_tile == null)
         {
            _tile = new TileList();
            this.onCreateTile();
            addChild(_tile);
         }
         this._normalCache = param1;
         var _loc3_:int = int(this._normalCache.length);
         _loc2_ = int(_loc3_ - 1);
         while(_loc2_ >= 0)
         {
            _loc4_ = Settings.getInstance().getFreeGift(this._normalCache[_loc2_].toString());
            if(_loc4_["visible"] == "0")
            {
               this._normalCache.splice(_loc2_,1);
            }
            _loc2_--;
         }
         _tile.dataProvider = this._normalCache;
      }
   }
}

