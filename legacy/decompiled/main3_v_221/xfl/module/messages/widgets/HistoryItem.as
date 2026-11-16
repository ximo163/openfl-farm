package module.messages.widgets
{
   import com.qzone.qui.utils.FrameTimer;
   import common.Consts;
   import common.Settings;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import flash.text.TextFormatAlign;
   import framework.base.BaseTileItem;
   
   public class HistoryItem extends BaseTileItem
   {
      
      private var _setCropInter:int;
      
      private var _setIconDelay:int;
      
      private var _text:TextField;
      
      private var _hasSetCrop:Boolean;
      
      public function HistoryItem()
      {
         super();
         this._setCropInter = -1;
         var _loc1_:String = Settings.getInstance().getStringAttribute("setIconDelay");
         if(_loc1_ != "")
         {
            this._setIconDelay = parseInt(_loc1_);
         }
         if(this._setIconDelay == 0 || isNaN(this._setIconDelay) == true)
         {
            this._setIconDelay = 1000;
         }
         this.init();
      }
      
      private function onDelayShowPic() : void
      {
         if(this._setCropInter != -1)
         {
            FrameTimer.clearTimeout(this._setCropInter);
         }
         this._setCropInter = -1;
         this._hasSetCrop = true;
         if(super.data["harvestNumber"] == undefined)
         {
            _material.setContent(Consts.ITEM_TYPE_FISH,_item["cid"]);
         }
         else
         {
            _material.setContent(Consts.ITEM_TYPE_SEED,_item["cId"]);
         }
         _material.hideLoading();
      }
      
      private function init() : void
      {
         createBackground("ItemBg");
         this._text = new TextField();
         this._text.selectable = false;
         this._text.width = 60;
         this._text.height = 22;
         this._text.defaultTextFormat = new TextFormat("embedFontA",14,16737792,null,null,null,null,null,TextFormatAlign.CENTER);
         this._text.embedFonts = true;
         this._text.x = 0;
         this._text.y = 60;
         this._text.text = "0";
         addChild(this._text);
         registerListeners();
      }
      
      override public function set data(param1:Object) : void
      {
         super.data = param1;
         if(param1 == null || param1 == _item && this._hasSetCrop == true)
         {
            if(this._setCropInter != -1)
            {
               FrameTimer.clearTimeout(this._setCropInter);
            }
            this._setCropInter = -1;
            return;
         }
         FrameTimer.clearTimeout(this._setCropInter);
         this._setCropInter = FrameTimer.setTimeout(this.onDelayShowPic,this._setIconDelay);
         var _loc2_:int = 0;
         if(super.data["harvestNumber"] == undefined)
         {
            _loc2_ = parseInt(param1["hn"]) + parseInt(param1["sn"]);
         }
         else
         {
            _loc2_ = parseInt(param1["harvestNumber"]) + parseInt(param1["scroungeNumber"]);
         }
         this._text.text = _loc2_.toString();
      }
   }
}

