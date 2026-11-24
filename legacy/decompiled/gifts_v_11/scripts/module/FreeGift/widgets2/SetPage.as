package module.FreeGift.widgets2
{
   import com.qzone.qui.containers.TileList;
   import com.qzone.qui.controls.scrollClasses.ScrollPolicy;
   import common.Settings;
   import common.misc.QzoneJSAPI;
   import common.misc.Utils;
   import events.CommonEvent;
   import events.ViewEvent;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import framework.base.BaseTileItem;
   import framework.base.SepBasePage;
   import module.FreeGift.FreeGiftModel;
   
   public class SetPage extends SepBasePage
   {
      
      private var _giftID:int;
      
      private var _vscrollPosition:int;
      
      private var _normalCache:Array;
      
      public function SetPage(param1:DisplayObjectContainer, param2:int, param3:int)
      {
         super(param1,param2,param3);
         this._normalCache = null;
         var _loc4_:MovieClip = Utils.getMaterial("FreeGiftSendTip") as MovieClip;
         addChild(_loc4_);
         _loc4_.y = -2;
         _loc4_.x = 0;
         addEventListener(BaseTileItem.CHILD_CLICK,this.setGiftHandler,false,0,true);
      }
      
      private function onClose(param1:Object) : void
      {
      }
      
      private function onSuccess(param1:Object) : void
      {
         var _loc3_:String = null;
         if(param1 == null)
         {
            return;
         }
         if(param1["receiver"] == null)
         {
            return;
         }
         var _loc2_:String = "";
         for(_loc3_ in param1["receiver"])
         {
            _loc2_ = _loc2_ + param1["receiver"][_loc3_] + ",";
         }
         _loc2_ = _loc2_.slice(0,_loc2_.length - 1);
         dispatchEvent(new CommonEvent(FreeGiftModel.SEND_FREE_GIFT,{
            "uins":_loc2_,
            "tip":0,
            "id":this._giftID
         }));
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
            _tile.tileHeight = 148;
            _tile.defaultSkin = null;
            _tile.horizontalScrollPolicy = ScrollPolicy.OFF;
            _tile.itemRenderer = SetItem;
            _tile.y = 15;
            _tile.width = _preferedWidth - 5;
            _tile.height = 310;
         }
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
      
      private function onCancel(param1:Object) : void
      {
      }
      
      private function setGiftHandler(param1:ViewEvent) : void
      {
         var _loc2_:Object = param1.data;
         this._giftID = _loc2_["data"]["bid"];
         QzoneJSAPI.sendRequestOpen(_loc2_["data"]["url"],"赠送",this.onSuccess,this.onCancel,this.onClose,_loc2_["data"]["name"],"常来看看，别错过收礼唷！");
      }
   }
}

