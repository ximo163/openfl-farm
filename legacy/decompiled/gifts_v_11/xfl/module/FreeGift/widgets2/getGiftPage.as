package module.FreeGift.widgets2
{
   import com.qzone.qui.containers.TileList;
   import com.qzone.qui.controls.scrollClasses.ScrollPolicy;
   import common.CommonData;
   import common.misc.Utils;
   import events.ViewEvent;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import framework.base.BasePage;
   import framework.base.BaseTileItem;
   import module.FreeGift.FreeGiftModel;
   
   public class getGiftPage extends BasePage
   {
      
      private static var isGetGiftFrist:Boolean = true;
      
      private var _normalCache:Array;
      
      private var _vscrollPosition:int;
      
      public function getGiftPage(param1:DisplayObjectContainer, param2:int, param3:int)
      {
         super(param1,param2,param3);
         this._normalCache = null;
         var _loc4_:MovieClip = Utils.getMaterial("FreeGiftGetTip") as MovieClip;
         if(_loc4_ != null)
         {
            _loc4_.name = "__freegiftTip__";
            addChild(_loc4_);
            _loc4_.y = -2;
            _loc4_.x = 3;
         }
         addEventListener(BaseTileItem.CHILD_CLICK,this.setScroll,false,0,true);
         addEventListener(GetGiftItem.GET_GIFT_CLICK,this.setScroll,false,0,true);
      }
      
      override public function set dataList(param1:Array) : void
      {
         var _loc2_:* = 0;
         var _loc3_:int = 0;
         var _loc4_:MovieClip = null;
         var _loc5_:Number = NaN;
         if(_tile == null)
         {
            _tile = new TileList();
            this.onCreateTile();
            addChild(_tile);
         }
         this._normalCache = param1;
         if(this._normalCache)
         {
            _loc3_ = int(this._normalCache.length);
            if(CommonData.freeGift["alread"] >= FreeGiftModel.MaxSend)
            {
               _loc2_ = 0;
               _loc3_ = int(this._normalCache.length);
               _loc2_ = int(_loc3_ - 1);
               while(_loc2_ >= 0)
               {
                  this._normalCache[_loc2_]["AllCannot"] = 1;
                  _loc2_--;
               }
               _loc4_ = this.getChildByName("__freegiftTip__") as MovieClip;
               if(_loc4_)
               {
                  _loc4_.gotoAndStop(2);
               }
            }
            if(isGetGiftFrist)
            {
               this._normalCache.sortOn("status",Array.NUMERIC);
               this._normalCache.sortOn("time",Array.NUMERIC | Array.DESCENDING);
               isGetGiftFrist = false;
            }
         }
         _tile.dataProvider = this._normalCache;
         if(_tile.vScrollBar)
         {
            _loc5_ = Number(_tile.vScrollBar.maxScrollPosition);
            _tile.vScrollBar.scrollPosition = this._vscrollPosition > _loc5_ ? int(_loc5_) : this._vscrollPosition;
         }
      }
      
      override protected function onCreateTile() : void
      {
         if(_tile != null)
         {
            _tile.paddingH = 10;
            _tile.paddingV = 10;
            _tile.gapH = 0;
            _tile.gapV = 0;
            _tile.tileWidth = 405;
            _tile.tileHeight = 100;
            _tile.defaultSkin = null;
            _tile.horizontalScrollPolicy = ScrollPolicy.OFF;
            _tile.itemRenderer = GetGiftItem;
            _tile.y = 15;
            _tile.width = _preferedWidth - 5;
            _tile.height = 310;
         }
      }
      
      private function setScroll(param1:ViewEvent) : void
      {
         if(_tile.vScrollBar)
         {
            this._vscrollPosition = _tile.vScrollBar.scrollPosition;
         }
      }
   }
}

