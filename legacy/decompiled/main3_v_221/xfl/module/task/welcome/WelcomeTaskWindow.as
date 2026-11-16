package module.task.welcome
{
   import com.qzone.qui.controls.Button;
   import com.qzone.utils.AlignUtil;
   import common.CommonData;
   import common.Consts;
   import common.Language;
   import common.Settings;
   import common.misc.Utils;
   import common.view.window.ConfirmWindow;
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import interfaces.IMsgCenter;
   
   public class WelcomeTaskWindow extends ConfirmWindow
   {
      
      private var _awokeText:TextField;
      
      private var _res:Sprite;
      
      private var _mode:int;
      
      private var _id:int;
      
      public function WelcomeTaskWindow(param1:IMsgCenter)
      {
         super(param1);
         mode = true;
         width = 360;
         height = 240;
         windowName = Consts.WINDOW_NAME_TASK_ACCEPT;
         this._res = null;
         this._id = -1;
         this._awokeText = null;
         this._mode = 0;
      }
      
      override protected function setSize() : void
      {
         super.setSize();
         if(this._mode == 0)
         {
            _confirmButton.x = width * 0.5 - _confirmButton.width - 10;
         }
         else
         {
            _confirmButton.x = (width - _confirmButton.width) * 0.5;
         }
         if(panelTitle != null)
         {
            panelTitle.x = AlignUtil.middle(width,panelTitle.width);
         }
      }
      
      private function changeMode(param1:int) : void
      {
         var _loc2_:DisplayObject = null;
         if(_inited == false)
         {
            return;
         }
         graphics.clear();
         this._mode = param1;
         if(param1 == 0)
         {
            _confirmButton.text = Language.L["接受"];
            _confirmButton.visible = true;
            _cancelButton.visible = true;
            if(this._awokeText != null && this._awokeText.parent != null)
            {
               this._awokeText.parent.removeChild(this._awokeText);
            }
         }
         else
         {
            _confirmButton.text = Language.L["确定"];
            _confirmButton.visible = true;
            _cancelButton.visible = false;
            if(this._awokeText == null)
            {
               this._awokeText = new TextField();
               this._awokeText.text = Language.L["(此任务进行中)"];
               this._awokeText.selectable = false;
               this._awokeText.mouseEnabled = false;
               this._awokeText.width = 150;
               this._awokeText.height = 25;
               this._awokeText.setTextFormat(new TextFormat("Verdana",14,13369344,true));
            }
            if(this._res != null)
            {
               this._res.addChild(this._awokeText);
               _loc2_ = this._res.getChildAt(0);
               if(_loc2_ != null)
               {
                  this._awokeText.x = _loc2_.x + _loc2_.width;
                  this._awokeText.y = -3;
               }
            }
         }
         if(this._mode == 0)
         {
            _confirmButton.x = width * 0.5 - _confirmButton.width - 10;
         }
         else
         {
            _confirmButton.x = (width - _confirmButton.width) * 0.5;
         }
      }
      
      override protected function setData() : void
      {
         var _loc2_:String = null;
         this.graphics.clear();
         if(super.data["title"] != undefined)
         {
            this.title = super.data["title"] as String;
         }
         if(super.data["confirmFn"] != undefined)
         {
            _confirmFn = data["confirmFn"] as Function;
         }
         else
         {
            _confirmFn = null;
         }
         if(super.data["mode"] != undefined)
         {
            this.changeMode(super.data["mode"] as int);
         }
         var _loc1_:int = super.data["id"] as int;
         if(_loc1_ == this._id && this._res != null)
         {
            return;
         }
         if(_loc1_ >= 0)
         {
            if(this._res != null && this._res.parent != null)
            {
               this._res.parent.removeChild(this._res);
            }
            this._res = Utils.getMaterial("task" + _loc1_) as Sprite;
            if(this._res != null)
            {
               this._res.x = 20;
               this._res.y = 40;
               addChild(this._res);
               this.height = this._res.height < 155 ? 245 : this._res.height + 90;
            }
            else
            {
               _loc2_ = Settings.getInstance().getSecondUrl("fresherTask");
               if(_loc2_ != "")
               {
                  CommonData.rslManager.requestClass("task" + _loc1_,this.rslCallBack,_loc2_);
               }
            }
            this._id = _loc1_;
         }
      }
      
      override protected function init() : void
      {
         if(_inited == true)
         {
            return;
         }
         _confirmButton = new Button();
         _confirmButton.defaultSkin = Utils.getClass("ButtonOrange");
         _confirmButton.width = 64;
         _confirmButton.height = 25;
         _confirmButton.y = height - 30;
         _confirmButton.text = Language.L["接受"];
         _confirmButton.addEventListener(MouseEvent.CLICK,super.confirmButtonClick);
         _confirmButton.visible = false;
         addChild(_confirmButton);
         _cancelButton = new Button();
         _cancelButton.defaultSkin = Utils.getClass("ButtonBlue");
         _cancelButton.width = 64;
         _cancelButton.height = 25;
         _cancelButton.y = height - 30;
         _cancelButton.text = Language.L["取消"];
         _cancelButton.addEventListener(MouseEvent.CLICK,super.cancelButtonClick);
         _cancelButton.visible = false;
         addChild(_cancelButton);
      }
      
      override protected function addedToLayer() : void
      {
         super.addedToLayer();
         _inited = true;
      }
      
      private function rslCallBack() : void
      {
         if(this._id <= 0)
         {
            return;
         }
         this.graphics.clear();
         if(this._res != null && this._res.parent != null)
         {
            this._res.parent.removeChild(this._res);
         }
         this._res = Utils.getMaterial("task" + this._id) as Sprite;
         if(this._res != null)
         {
            this._res.x = 20;
            this._res.y = 40;
            addChild(this._res);
            this.height = this._res.height < 155 ? 245 : this._res.height + 90;
         }
      }
      
      public function get disableAnimation() : Boolean
      {
         return true;
      }
   }
}

