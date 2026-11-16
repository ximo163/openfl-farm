package mc.view.main.window.tool
{
   import com.adobe.utils.StringUtil;
   import com.minutes.ui.control.LipiButton;
   import com.minutes.ui.core.LipiSkin;
   import common.MaterialLib;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.FocusEvent;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import flash.text.TextFieldType;
   import flash.text.TextFormat;
   import mc.control.Command;
   import mc.control.ViewControl;
   import mc.events.WindowEvent;
   import mc.model.FarmData;
   import mc.model.MData;
   import mc.model.ToolData;
   import mc.view.common.BaseWindow;
   import mc.view.main.cursor.Cursor;
   import mc.view.main.tip.TipControl;
   import mc.view.main.window.shop.ErrorText;
   
   public class WhistleToolWindow extends BaseWindow
   {
      
      private var whistleMc:MovieClip;
      
      private var confirmButton:LipiButton;
      
      private var errorText:ErrorText;
      
      private var selectWhistle:Number = 1;
      
      private var viewButton:LipiButton = new LipiButton();
      
      public function WhistleToolWindow()
      {
         super();
         width = 482;
         height = 400;
         titleIMG = MaterialLib.getInstance().getClass("WhistleWindowTitle");
         windowName = "WhistleToolWindow";
         mode = true;
      }
      
      private function checkAnimalNum() : void
      {
         var _loc1_:Number = 0;
         this.errorText.text = "";
         this.errorText.visible = false;
         var _loc2_:Array = MData.getInstance().mainData.animalData;
         var _loc3_:int = 0;
         while(_loc3_ < _loc2_.length)
         {
            if(Boolean(_loc2_[_loc3_]) && _loc2_[_loc3_].status == FarmData.ANIMAL_SHENGCHAN)
            {
               this.errorText.text = "动物生产中，请等待生产结束。";
            }
            if(_loc2_[_loc3_])
            {
               _loc1_++;
            }
            _loc3_++;
         }
         if(this.selectWhistle == 1)
         {
            if(_loc1_ < 5)
            {
               this.errorText.text = "对不起，该队形需要5只及以上动物（已饲养" + _loc1_ + "只）";
            }
         }
         if(this.selectWhistle == 2)
         {
            if(_loc1_ < 5)
            {
               this.errorText.text = "对不起，该队形需要5只及以上动物（已饲养" + _loc1_ + "只）";
            }
         }
         if(this.selectWhistle == 3)
         {
            if(_loc1_ != 6 && _loc1_ != 10 && _loc1_ != 15)
            {
               this.errorText.text = "对不起，该队形仅适合6/10/15只动物（已饲养" + _loc1_ + "只）";
            }
         }
         if(this.selectWhistle == 4)
         {
            if(_loc1_ != 9 && _loc1_ != 16)
            {
               this.errorText.text = "对不起，该队形仅适合9/16只动物（已饲养" + _loc1_ + "只）";
            }
         }
         if(this.selectWhistle == 5)
         {
            if(_loc1_ != 8 && _loc1_ != 12 && _loc1_ != 16)
            {
               this.errorText.text = "对不起，该队形仅适合8/12/16只动物（已饲养" + _loc1_ + "只）";
            }
         }
         if(this.errorText.text != "")
         {
            this.errorText.visible = true;
            this.errorText.x = Math.floor((this.width - this.errorText.width) / 2);
            this.confirmButton.enable = false;
            this.viewButton.enable = false;
         }
         else if(StringUtil.trim(this.whistleMc.infoTxt.text) == "")
         {
            this.errorText.visible = true;
            this.errorText.text = "请输入欢迎语！";
            this.errorText.x = Math.floor((this.width - this.errorText.width) / 2);
            this.confirmButton.enable = false;
            this.viewButton.enable = false;
         }
         else if(this.whistleMc.infoTxt.text.length > 18)
         {
            this.errorText.text = "对不起，欢迎语最多定义18字";
            this.errorText.visible = true;
            this.errorText.x = Math.floor((this.width - this.errorText.width) / 2);
            this.confirmButton.enable = false;
            this.viewButton.enable = false;
         }
         else
         {
            this.confirmButton.enable = true;
            this.viewButton.enable = true;
         }
         if(this.selectWhistle == 0)
         {
            this.errorText.text = "没选中任何队形";
            this.confirmButton.enable = true;
            this.viewButton.enable = false;
            this.errorText.visible = true;
            this.errorText.x = Math.floor((this.width - this.errorText.width) / 2);
            this.whistleMc.infoTxt.type = TextFieldType.DYNAMIC;
            this.whistleMc.infoTxt.removeEventListener(FocusEvent.FOCUS_IN,this.onFocusIn);
            (this.whistleMc.infoTxt as TextField).selectable = false;
            (this.whistleMc.infoTxt as TextField).setTextFormat(new TextFormat(null,null,11184810));
         }
         else
         {
            (this.whistleMc.infoTxt as TextField).selectable = true;
            this.whistleMc.infoTxt.type = TextFieldType.INPUT;
            (this.whistleMc.infoTxt as TextField).setTextFormat(new TextFormat(null,null,0));
            this.whistleMc.infoTxt.addEventListener(FocusEvent.FOCUS_IN,this.onFocusIn);
         }
      }
      
      private function onWhistleChange(param1:Event) : void
      {
         this.data = MData.getInstance().toolData.whistleDate;
      }
      
      private function viewButtonClick(param1:MouseEvent) : void
      {
         var _loc2_:WindowEvent = null;
         var _loc3_:CancelViewWindow = null;
         if(this.viewButton.enable == true)
         {
            _loc3_ = new CancelViewWindow();
            _loc2_ = new WindowEvent(WindowEvent.OPEN);
            _loc2_.window = _loc3_;
            _loc2_.startY = 220;
            _loc2_.startX = stage.stageWidth - 360;
            ViewControl.getInstance().dispatchEvent(_loc2_);
            MData.getInstance().toolData.viewWhistleData = {
               "v":1,
               "p":this.selectWhistle,
               "i":this.whistleMc.infoTxt.text
            };
            _loc2_ = new WindowEvent(WindowEvent.CLOSE);
            _loc2_.window = this;
            ViewControl.getInstance().dispatchEvent(_loc2_);
         }
      }
      
      override public function set data(param1:Object) : void
      {
         super.data = param1;
         this.setData();
      }
      
      private function confirmButtonClick(param1:MouseEvent = null) : void
      {
         var _loc2_:WindowEvent = null;
         this.checkAnimalNum();
         if(this.confirmButton.enable == true)
         {
            Command.getInstance().toolCommand.setWhistle({
               "pid":this.selectWhistle,
               "pinfo":this.whistleMc.infoTxt.text
            });
            _loc2_ = new WindowEvent(WindowEvent.CLOSE);
            _loc2_.window = this;
            ViewControl.getInstance().dispatchEvent(_loc2_);
         }
      }
      
      override public function init() : void
      {
         this.errorText = new ErrorText();
         this.errorText.visible = false;
         this.errorText.y = 312;
         addChild(this.errorText);
         this.whistleMc = MaterialLib.getInstance().getMaterial("WhistleList") as MovieClip;
         this.whistleMc.infoTxt.addEventListener(FocusEvent.FOCUS_IN,this.onFocusIn);
         this.whistleMc.infoTxt.addEventListener(Event.CHANGE,this.onInfoChange);
         this.whistleMc.addEventListener(MouseEvent.CLICK,this.onClick,false,0,true);
         this.whistleMc.addEventListener(MouseEvent.MOUSE_OVER,this.toolRollOver,false,0,true);
         this.whistleMc.addEventListener(MouseEvent.MOUSE_OUT,this.toolRollOut,false,0,true);
         addChild(this.whistleMc);
         this.whistleMc.x = 48;
         this.whistleMc.y = 78;
         this.confirmButton = new LipiButton();
         this.confirmButton.bgAlpha = 0;
         this.confirmButton.bgSkin = new LipiSkin(MaterialLib.getInstance().getClass("ButtonOrange"));
         this.confirmButton.width = 64;
         this.confirmButton.height = 25;
         this.confirmButton.x = 250;
         this.confirmButton.y = height - 50;
         this.confirmButton.label = "保存设置";
         this.confirmButton.textColor = 16777215;
         this.confirmButton.addEventListener(MouseEvent.CLICK,this.confirmButtonClick);
         addChild(this.confirmButton);
         this.viewButton.bgAlpha = 0;
         this.viewButton.bgSkin = new LipiSkin(MaterialLib.getInstance().getClass("ButtonBlue"));
         this.viewButton.width = 64;
         this.viewButton.height = 25;
         this.viewButton.x = 150;
         this.viewButton.y = height - 50;
         this.viewButton.label = "预览";
         this.viewButton.textColor = 16777215;
         this.viewButton.addEventListener(MouseEvent.CLICK,this.viewButtonClick);
         addChild(this.viewButton);
         this.addEventListener(MouseEvent.ROLL_OVER,this.onRollOver);
         this.addEventListener(MouseEvent.ROLL_OUT,this.onRollOut);
         this.setData();
      }
      
      private function toolRollOut(param1:MouseEvent) : void
      {
         TipControl.hide();
      }
      
      private function cancelButtonClick(param1:MouseEvent) : void
      {
         var _loc2_:WindowEvent = new WindowEvent(WindowEvent.CLOSE);
         _loc2_.window = this;
         ViewControl.getInstance().dispatchEvent(_loc2_);
      }
      
      private function onClick(param1:MouseEvent) : void
      {
         switch(param1.target)
         {
            case this.whistleMc.btn1:
               if(this.selectWhistle == 1)
               {
                  this.selectWhistle = 0;
                  this.whistleMc.gotoAndStop(1);
               }
               else
               {
                  this.selectWhistle = 1;
                  this.whistleMc.gotoAndStop(2);
               }
               break;
            case this.whistleMc.btn2:
               if(this.selectWhistle == 2)
               {
                  this.selectWhistle = 0;
                  this.whistleMc.gotoAndStop(1);
               }
               else
               {
                  this.selectWhistle = 2;
                  this.whistleMc.gotoAndStop(3);
               }
               break;
            case this.whistleMc.btn3:
               if(this.selectWhistle == 3)
               {
                  this.selectWhistle = 0;
                  this.whistleMc.gotoAndStop(1);
               }
               else
               {
                  this.selectWhistle = 3;
                  this.whistleMc.gotoAndStop(4);
               }
               break;
            case this.whistleMc.btn4:
               if(this.selectWhistle == 4)
               {
                  this.selectWhistle = 0;
                  this.whistleMc.gotoAndStop(1);
               }
               else
               {
                  this.selectWhistle = 4;
                  this.whistleMc.gotoAndStop(5);
               }
               break;
            case this.whistleMc.btn5:
               if(this.selectWhistle == 5)
               {
                  this.selectWhistle = 0;
                  this.whistleMc.gotoAndStop(1);
               }
               else
               {
                  this.selectWhistle = 5;
                  this.whistleMc.gotoAndStop(6);
               }
         }
         this.checkAnimalNum();
      }
      
      private function toolRollOver(param1:MouseEvent) : void
      {
         if(param1.target == this.whistleMc.btn1)
         {
            TipControl.show("MouseTip","适合5只及以上动物");
         }
         if(param1.target == this.whistleMc.btn2)
         {
            TipControl.show("MouseTip","适合5只及以上动物");
         }
         if(param1.target == this.whistleMc.btn3)
         {
            TipControl.show("MouseTip","仅适合6、10、15只动物");
         }
         if(param1.target == this.whistleMc.btn4)
         {
            TipControl.show("MouseTip","仅适合9、16只动物");
         }
         if(param1.target == this.whistleMc.btn5)
         {
            TipControl.show("MouseTip","仅适合8、12、16只动物");
         }
      }
      
      private function onRollOut(param1:MouseEvent) : void
      {
         Cursor.useSystem(false);
      }
      
      override public function keyEnter() : void
      {
         this.confirmButtonClick();
      }
      
      private function setData() : void
      {
         if(data == null)
         {
            Command.getInstance().toolCommand.getWhistle();
            MData.getInstance().toolData.addEventListener(ToolData.WHISTLE_CHANGE,this.onWhistleChange);
            return;
         }
         if(data.i == "")
         {
            data["i"] = "您可以定义好友访问时动物的欢迎语";
         }
         if(this.whistleMc)
         {
            this.whistleMc.gotoAndStop(data.p + 1);
            this.whistleMc.infoTxt.text = data.i;
            this.whistleMc.numTxt.text = this.whistleMc.infoTxt.text.length + "/18";
            this.selectWhistle = data.p;
            this.checkAnimalNum();
         }
         Cursor.useSystem(true);
      }
      
      private function onInfoChange(param1:Event) : void
      {
         var _loc2_:TextField = this.whistleMc.infoTxt as TextField;
         this.whistleMc.numTxt.text = _loc2_.text.length + "/18";
         this.checkAnimalNum();
      }
      
      private function onFocusIn(param1:FocusEvent) : void
      {
         if(this.whistleMc.infoTxt.text == "您可以定义好友访问时动物的欢迎语")
         {
            this.whistleMc.infoTxt.text = "";
         }
      }
      
      private function onRollOver(param1:MouseEvent) : void
      {
         Cursor.useSystem(true);
      }
   }
}

