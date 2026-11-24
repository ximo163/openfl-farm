package module.health
{
   import com.qzone.qui.controls.Button;
   import com.qzone.qui.controls.ComboBox;
   import com.qzone.utils.AlignUtil;
   import com.qzone.utils.StringUtil;
   import common.CommonData;
   import common.Consts;
   import common.Language;
   import common.misc.Utils;
   import common.view.window.BaseWindow;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import interfaces.IMsgCenter;
   
   public class HealthView extends BaseWindow
   {
      
      private var _confirmWindow1:HealthConfirmWindow;
      
      private var _cbHour:ComboBox;
      
      private var _okButton:Button;
      
      private var _hourArray:Array = ["23","00","01","02","03","04","05","06","07","08","09","10","11","12","13","14","15","16","17","18","19","20","21","22"];
      
      private var _minuteArray:Array = [];
      
      private var m_controller:HealthController;
      
      private var _txt:TextField;
      
      private var _cbMinute:ComboBox;
      
      private var _confirmWindow0:HealthConfirmWindow;
      
      public function HealthView(param1:HealthController)
      {
         super(param1.module.app as IMsgCenter);
         this.m_controller = param1;
         mode = true;
         title = Language.L["HM_TITLE"];
         this._hourArray = this._hourArray.reverse();
         var _loc2_:int = 0;
         while(_loc2_ < 60)
         {
            this._minuteArray.push(StringUtil.getZeroString(_loc2_));
            _loc2_++;
         }
         this._txt = new TextField();
         this._txt.selectable = false;
         this._txt.mouseWheelEnabled = false;
         var _loc3_:TextFormat = new TextFormat("Verdana",12,3355443);
         _loc3_.leading = 13;
         this._txt.defaultTextFormat = _loc3_;
         this._txt.wordWrap = false;
         this._txt.multiline = true;
         this._txt.autoSize = "left";
         this._txt.x = 30;
         this._txt.y = 47;
         addChildAt(this._txt,0);
         this._okButton = new Button();
         this._okButton.defaultSkin = Utils.getClass("ButtonOrange");
         this._okButton.height = 25;
         this._okButton.width = 135;
         this._okButton.addEventListener(MouseEvent.CLICK,this.onOK);
         addChild(this._okButton);
         this._cbHour = null;
         this._cbMinute = null;
      }
      
      override protected function setSize() : void
      {
         super.setSize();
         panelTitle.x = AlignUtil.middle(_width,panelTitle.width);
      }
      
      private function updateComboBox() : void
      {
         var _loc2_:Array = null;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc1_:HealthModel = this.m_controller.model;
         if(_loc1_.healthModeOpened == true)
         {
            if(_loc1_.healthModeTime != "")
            {
               _loc2_ = _loc1_.healthModeTime.split("|");
               _loc3_ = 0;
               _loc4_ = int(this._hourArray.length);
               while(_loc3_ < _loc4_)
               {
                  if(int(this._hourArray[_loc3_]) == _loc2_[0])
                  {
                     this._cbHour.selectedIndex = _loc3_;
                     break;
                  }
                  _loc3_++;
               }
               this._cbMinute.selectedIndex = _loc2_[1];
            }
         }
      }
      
      override protected function setData() : void
      {
         var _loc2_:String = null;
         var _loc3_:HealthModel = null;
         var _loc4_:Array = null;
         var _loc5_:String = null;
         var _loc1_:int = int(super.data["mode"]);
         if(_loc1_ == 0)
         {
            _loc2_ = "";
            _loc3_ = this.m_controller.model;
            _loc4_ = _loc3_.healthModeTime.split("|");
            _loc5_ = _loc4_[0] + ":" + _loc4_[1] + "-" + StringUtil.getZeroString(this.getEndHour(Number(_loc4_[0]))) + ":" + _loc4_[1];
            _loc2_ = Language.L["HM_TO_CLOSE"];
            _loc2_ = _loc2_.replace(/@healModeTotalHour/g,Consts.HEALTH_MODE_TOTAL_HOURS);
            _loc2_ = _loc2_.replace(/@totalDay/g,Consts.HEALTH_MODE_TOTAL_DAYS);
            _loc2_ = _loc2_.replace(/@time/g,_loc5_);
            _loc2_ = _loc2_.replace(/@period/,_loc3_.healthModePeriod);
            if(this._txt != null)
            {
               this._txt.htmlText = _loc2_;
            }
            this._okButton.text = Language.L["取消健康模式"];
            if(this._cbHour != null)
            {
               this._cbHour.visible = false;
            }
            if(this._cbMinute != null)
            {
               this._cbMinute.visible = false;
            }
         }
         else if(_loc1_ == 1)
         {
            this._okButton.text = Language.L["马上开启健康模式"];
            if(this._cbHour == null || this._cbMinute == null)
            {
               this.createComboBoxes();
            }
            this._cbHour.visible = true;
            this._cbMinute.visible = true;
            this.updateComboBox();
            this.onComboBoxChanged();
         }
         width = 518;
         height = 290;
         this._okButton.x = (width - this._okButton.width) * 0.5;
         this._okButton.y = height - 45;
         this.graphics.clear();
      }
      
      private function onConfirmToClose() : void
      {
         this.m_controller.model.closeHealthMode();
      }
      
      private function createComboBoxes() : void
      {
         var _loc1_:Date = new Date();
         _loc1_.setTime(CommonData.serverTime * 1000);
         this._cbHour = new ComboBox();
         this._cbHour.dataProvider = this._hourArray;
         this._cbHour.x = 108;
         this._cbHour.y = 190;
         this._cbHour.width = 46;
         this._cbMinute = new ComboBox();
         this._cbMinute.dataProvider = this._minuteArray;
         this._cbMinute.x = 165;
         this._cbMinute.y = 190;
         this._cbMinute.width = 46;
         var _loc2_:Number = _loc1_.getHours();
         var _loc3_:int = 0;
         var _loc4_:int = int(this._hourArray.length);
         while(_loc3_ < _loc4_)
         {
            if(int(this._hourArray[_loc3_]) == _loc2_)
            {
               this._cbHour.selectedIndex = _loc3_;
               break;
            }
            _loc3_++;
         }
         this._cbMinute.selectedIndex = _loc1_.getMinutes();
         this._cbHour.addEventListener(Event.CHANGE,this.onComboBoxChanged);
         this._cbMinute.addEventListener(Event.CHANGE,this.onComboBoxChanged);
         addChild(this._cbHour);
         addChild(this._cbMinute);
      }
      
      private function getEndHour(param1:Number) : Number
      {
         var _loc2_:Date = new Date(2009,11,1,param1);
         _loc2_.setHours(param1 + Consts.HEALTH_MODE_TOTAL_HOURS);
         return _loc2_.getHours();
      }
      
      private function onConfirmToOpen() : void
      {
         this.m_controller.model.openHealthMode(this._cbHour.value,this._cbMinute.value);
      }
      
      private function onComboBoxChanged(param1:Event = null) : void
      {
         var keywords:* = undefined;
         var e:Event = param1;
         var startHourString:String = this._cbHour.value;
         var endHourString:String = StringUtil.getZeroString(this.getEndHour(Number(startHourString)));
         keywords = {
            "@endTime":endHourString + ":" + this._cbMinute.value,
            "@healModeTotalHour":Consts.HEALTH_MODE_TOTAL_HOURS.toString(),
            "@totalDay":Consts.HEALTH_MODE_TOTAL_DAYS.toString()
         };
         var str:String = Language.L["HM_TO_OPEN"];
         str = str.replace(/(@endTime|@healModeTotalHour|@totalDay)/g,function():String
         {
            var _loc2_:* = keywords[arguments[1]];
            return _loc2_ ? _loc2_ : arguments[0];
         });
         this._txt.htmlText = str;
      }
      
      private function onCancel(param1:MouseEvent) : void
      {
         super.close();
      }
      
      private function onOK(param1:MouseEvent) : void
      {
         var _loc3_:Array = null;
         var _loc4_:String = null;
         var _loc5_:String = null;
         var _loc2_:int = int(super.data["mode"]);
         if(_loc2_ == 0)
         {
            if(this._confirmWindow0 == null)
            {
               this._confirmWindow0 = new HealthConfirmWindow(this.m_controller.module.app as IMsgCenter);
               this._confirmWindow0.width = 260;
               this._confirmWindow0.height = 150;
            }
            this._confirmWindow0.data = {
               "text":Language.L["HM_CLOSE_CONFIRM"],
               "confirmFn":this.onConfirmToClose
            };
            this.m_controller.module.app.openWindow(this._confirmWindow0);
         }
         else if(_loc2_ == 1)
         {
            _loc3_ = [this._cbHour.value,this._cbMinute.value];
            _loc4_ = _loc3_[0] + ":" + _loc3_[1] + "-" + StringUtil.getZeroString(this.getEndHour(Number(_loc3_[0]))) + ":" + _loc3_[1];
            _loc5_ = Language.L["HM_OPEN_CONFIRM"];
            _loc5_ = _loc5_.replace(/@time/g,_loc4_);
            _loc5_ = _loc5_.replace(/@totalDay/g,Consts.HEALTH_MODE_TOTAL_DAYS.toString());
            if(this._confirmWindow1 == null)
            {
               this._confirmWindow1 = new HealthConfirmWindow(this.m_controller.module.app as IMsgCenter);
               this._confirmWindow1.width = 400;
               this._confirmWindow1.height = 200;
            }
            this._confirmWindow1.data = {
               "text":_loc5_,
               "confirmFn":this.onConfirmToOpen
            };
            this.m_controller.module.app.openWindow(this._confirmWindow1);
         }
         super.close();
      }
   }
}

