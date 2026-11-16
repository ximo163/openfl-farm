package module.task.welcome
{
   import com.qzone.qui.controls.Button;
   import com.qzone.utils.AlignUtil;
   import common.Consts;
   import common.misc.Utils;
   import common.view.MaterialProxy;
   import common.view.window.ConfirmWindow;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import flash.text.TextFormatAlign;
   import interfaces.IMsgCenter;
   
   public class TaskOverWindow extends ConfirmWindow
   {
      
      private var _giftContent:Sprite;
      
      public function TaskOverWindow(param1:IMsgCenter)
      {
         super(param1);
         width = 360;
         height = 240;
         title = "完成任务";
         windowName = Consts.WINDOW_NAME_TASK_OVER;
         mode = true;
         _hideIcon = true;
         _confirmEnable = true;
         _confirmFn = null;
      }
      
      override protected function init() : void
      {
         if(_inited == true)
         {
            return;
         }
         _alertText = new TextField();
         _alertText.x = 20;
         _alertText.y = 20;
         _alertText.width = 315;
         _alertText.height = 40;
         _alertText.wordWrap = true;
         _alertText.defaultTextFormat = new TextFormat("Verdana",14,39423,true);
         addChild(_alertText);
         _confirmButton = new Button();
         _confirmButton.defaultSkin = Utils.getClass("ButtonOrange");
         _confirmButton.width = 120;
         _confirmButton.height = 25;
         _confirmButton.y = height - 36;
         _confirmButton.text = "进行下一个任务";
         _confirmButton.addEventListener(MouseEvent.CLICK,confirmButtonClick);
         addChild(_confirmButton);
         _cancelButton = new Button();
         _cancelButton.defaultSkin = Utils.getClass("ButtonBlue");
         _cancelButton.width = 64;
         _cancelButton.height = 25;
         _cancelButton.y = height - 36;
         _cancelButton.text = "取消";
         _cancelButton.addEventListener(MouseEvent.CLICK,cancelButtonClick);
         addChild(_cancelButton);
         this._giftContent = new Sprite();
         this._giftContent.x = 4;
         this._giftContent.y = 84;
         addChild(this._giftContent);
      }
      
      override protected function setSize() : void
      {
         var _loc1_:int = 0;
         super.setSize();
         if(_inited == true)
         {
            _loc1_ = (this.width - _confirmButton.width - _cancelButton.width - 20) * 0.5;
            _confirmButton.x = _loc1_;
            _cancelButton.x = _loc1_ + _confirmButton.width + 20;
            this._giftContent.x = (this.width - this._giftContent.width) * 0.5;
            if(panelTitle != null)
            {
               panelTitle.x = AlignUtil.middle(width,panelTitle.width);
            }
         }
      }
      
      override protected function addedToLayer() : void
      {
         super.addedToLayer();
         _inited = true;
      }
      
      public function set confirmBtnText(param1:String) : void
      {
         if(param1 == null || param1 == "")
         {
            return;
         }
         if(_confirmButton != null)
         {
            _confirmButton.text = param1;
            if(param1.length > 2)
            {
               _confirmButton.width = 120;
            }
            else
            {
               _confirmButton.width = 64;
            }
         }
      }
      
      override protected function setData() : void
      {
         var _loc1_:Array = null;
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:MaterialProxy = null;
         var _loc7_:Number = NaN;
         var _loc8_:TextField = null;
         this.graphics.clear();
         if(super.data["direction"] != undefined && super.data["direction"] != "")
         {
            if(_alertText != null)
            {
               _alertText.text = super.data["direction"] as String;
            }
         }
         if(super.data["item"] != undefined)
         {
            while(this._giftContent.numChildren > 0)
            {
               this._giftContent.removeChildAt(0);
            }
            _loc1_ = super.data["item"] as Array;
            if(_loc1_ == null || _loc1_.length == 0)
            {
               return;
            }
            _loc2_ = 100;
            _loc3_ = int(_loc1_.length);
            _loc4_ = 0;
            _loc5_ = 0;
            while(_loc5_ < _loc3_)
            {
               _loc6_ = new MaterialProxy();
               _loc6_.setContent(_loc1_[_loc5_]["eType"],_loc1_[_loc5_]["eParam"]);
               _loc7_ = 50 / _loc6_.width;
               _loc6_.scaleX = _loc7_;
               _loc6_.scaleY = _loc7_;
               this._giftContent.addChild(_loc6_);
               _loc6_.x = _loc4_ + (_loc2_ - _loc6_.width) * 0.5;
               _loc6_.y = 5;
               _loc8_ = new TextField();
               _loc8_.height = 40;
               _loc8_.wordWrap = true;
               _loc8_.htmlText = _loc1_[_loc5_]["eNum"];
               _loc8_.setTextFormat(new TextFormat("embedFontA",20,16737792,false,null,null,null,null,TextFormatAlign.CENTER));
               _loc8_.embedFonts = true;
               this._giftContent.addChild(_loc8_);
               _loc8_.x = _loc6_.x + (_loc6_.width - _loc8_.width) * 0.5;
               _loc8_.y = _loc6_.y + 60;
               _loc4_ += _loc2_;
               _loc5_++;
            }
         }
         if(super.data["confirmFn"] != undefined)
         {
            _confirmFn = super.data["confirmFn"] as Function;
         }
         else
         {
            _confirmFn = null;
         }
      }
   }
}

