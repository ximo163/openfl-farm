package module.shop.widgets
{
   import com.qzone.qui.controls.Label;
   import com.qzone.qui.styles.Style;
   import com.qzone.qui.utils.FrameTimer;
   import com.qzone.utils.AlignUtil;
   import common.Session;
   import common.misc.Utils;
   import entities.Seed;
   import flash.display.MovieClip;
   import flash.display.Shape;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import flash.text.TextFormatAlign;
   import framework.base.BaseTileItem;
   
   public class CropItemVip extends BaseTileItem
   {
      
      private var _timerID:int;
      
      private var _loaded:Boolean;
      
      private var _vipIcon:MovieClip;
      
      private var _levelLabel:Label;
      
      private var _nameText:TextField;
      
      private var _descText:TextField;
      
      public function CropItemVip()
      {
         var _loc3_:Shape = null;
         super();
         createBackground("ItemBgRed",125,125);
         this._timerID = -1;
         this._loaded = false;
         var _loc1_:TextFormat = new TextFormat();
         _loc1_.size = 14;
         _loc1_.bold = true;
         _loc1_.color = 12284739;
         _loc1_.align = TextFormatAlign.CENTER;
         this._nameText = new TextField();
         this._nameText.width = 125;
         this._nameText.height = 20;
         this._nameText.defaultTextFormat = _loc1_;
         this._nameText.selectable = false;
         addChild(this._nameText);
         this._nameText.x = 0;
         this._nameText.y = _bg.height;
         var _loc2_:TextFormat = new TextFormat();
         _loc2_.size = 12;
         _loc2_.bold = false;
         _loc2_.color = 13084462;
         _loc2_.align = TextFormatAlign.CENTER;
         this._descText = new TextField();
         this._descText.width = 125;
         this._descText.height = 19;
         this._descText.defaultTextFormat = _loc2_;
         this._descText.selectable = false;
         addChild(this._descText);
         this._descText.x = 0;
         this._descText.y = this._nameText.y + this._nameText.height;
         _loc3_ = new Shape();
         _loc3_.graphics.beginFill(16711680,0);
         _loc3_.graphics.drawRect(0,0,10,1);
         _loc3_.graphics.endFill();
         _loc3_.y = 100;
         addChild(_loc3_);
         _material.scaleX = 2;
         _material.scaleY = 2;
         _material.x = (_bg.width - _material.width) / 2 - 5;
         _material.hideLoading();
         this._vipIcon = Utils.getMaterial("VipSeedIcon") as MovieClip;
         this._vipIcon.x = 2;
         this._vipIcon.y = 1;
         addChild(this._vipIcon);
         this._levelLabel = new Label("");
         this.addChild(this._levelLabel);
         this._levelLabel.textDefaultFormat = new TextFormat("Verdana",14,9211020);
         this._levelLabel.textField.filters = Style.getTextGlowFilter();
         this._levelLabel.y = AlignUtil.right(120,this._levelLabel.height) + 2;
         this._levelLabel.x = 3;
      }
      
      override public function set data(param1:Object) : void
      {
         if(param1 == null || param1 == _item && this._loaded == true)
         {
            this.clearTimer();
            return;
         }
         super.data = param1;
         var _loc2_:Seed = _item as Seed;
         if(_loc2_ == null)
         {
            this.clearTimer();
            return;
         }
         var _loc3_:TextFormat = this._levelLabel.textDefaultFormat;
         var _loc4_:int = 0;
         var _loc5_:Session = Session.getInstance();
         if(_loc5_ != null && _loc5_.host != null)
         {
            _loc4_ = int(_loc5_.host.level);
         }
         if(_loc2_._lvl <= _loc4_)
         {
            _loc3_.color = 16737792;
         }
         this.clearTimer();
         this._timerID = FrameTimer.setTimeout(this.delaySetCrop,1000);
         this._nameText.htmlText = _loc2_._name;
         this._descText.htmlText = _loc2_._vipDesc;
         this._levelLabel.text = _loc2_._lvl.toString() + "级";
         registerListeners();
      }
      
      private function delaySetCrop() : void
      {
         if(_item == null)
         {
            return;
         }
         _material.setContent("1",_item._id);
         this._loaded = true;
      }
      
      private function clearTimer() : void
      {
         if(this._timerID > 0)
         {
            FrameTimer.clearTimeout(this._timerID);
         }
         this._timerID = -1;
      }
   }
}

