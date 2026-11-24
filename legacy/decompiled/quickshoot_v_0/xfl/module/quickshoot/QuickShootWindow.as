package module.quickshoot
{
   import com.qzone.qui.controls.Button;
   import com.qzone.qui.controls.RadioButton;
   import com.qzone.qui.makers.RadioGroup;
   import com.qzone.utils.AlignUtil;
   import com.qzone.utils.DateTimeUtils;
   import common.Consts;
   import common.Language;
   import common.Session;
   import common.misc.Utils;
   import common.view.window.BaseWindow;
   import entities.Player;
   import events.CommonEvent;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.text.TextFormat;
   import interfaces.IMsgCenter;
   
   public class QuickShootWindow extends BaseWindow
   {
      
      public static const UPLOADING:int = 1;
      
      public static const SUCCESS:int = 2;
      
      public static const ERROR:int = 3;
      
      private var _rbSmallRes:RadioButton;
      
      private var _preview:DisplayObject;
      
      public var currentStatus:int;
      
      private var cancelButton:Button;
      
      private var confirmButton:Button;
      
      public var confirmFn:Function;
      
      private var textDefaultFormat:TextFormat;
      
      private var _rbBigRes:RadioButton;
      
      private var _rbGroup:RadioGroup;
      
      private var _ui:MovieClip;
      
      public function QuickShootWindow(param1:IMsgCenter)
      {
         super(param1);
         this._ui = Utils.getMaterial("CameraShootWindow") as MovieClip;
         width = this._ui.width + 25;
         height = this._ui.height + 75;
         title = "快照预览";
         mode = true;
         windowName = "CameraShootWindow";
         this._ui.y = 26;
         addChild(this._ui);
         this.confirmFn = null;
         this.currentStatus = 0;
         var _loc2_:Player = Session.getInstance().currentUser;
         var _loc3_:String = _loc2_.me ? "我" : _loc2_._userName;
         this._ui["tfName"].text = _loc3_ + "的农场" + DateTimeUtils.getDate().substr(2).split("-").join("");
         this._ui["tfName"].maxChars = 30;
         this._ui["tfName"].borderColor = 3381759;
         this._ui["tfName"].addEventListener(Event.CHANGE,this.onTextChanged,false,0,true);
         this._ui["tfDesc"].maxChars = 200;
         this._ui["tfDesc"].borderColor = 3381759;
         this._ui["tfDesc"].addEventListener(Event.CHANGE,this.onTextChanged,false,0,true);
         this._ui["tfNum1"].text = this._ui["tfName"].text.length + "/30";
         this.confirmButton = new Button();
         this.confirmButton.defaultSkin = Utils.getClass("ButtonOrange");
         this.confirmButton.width = 64;
         this.confirmButton.height = 25;
         this.confirmButton.x = width / 2 - this.confirmButton.width - 10;
         this.confirmButton.y = height - 38;
         this.confirmButton.text = Language.L["确定"];
         this.confirmButton.addEventListener(MouseEvent.CLICK,this.onOK);
         addChild(this.confirmButton);
         this.cancelButton = new Button();
         this.cancelButton.defaultSkin = Utils.getClass("ButtonBlue");
         this.cancelButton.width = 64;
         this.cancelButton.height = 25;
         this.cancelButton.x = width / 2 + 10;
         this.cancelButton.y = height - 38;
         this.cancelButton.text = Language.L["取消"];
         this.cancelButton.addEventListener(MouseEvent.CLICK,this.onCancel);
         addChild(this.cancelButton);
         this._rbGroup = new RadioGroup();
         this._rbSmallRes = new RadioButton("分辨率：800*600");
         this.setRaidoStyle(this._rbSmallRes);
         this._rbSmallRes.x = 85;
         this._rbSmallRes.y = 442;
         addChild(this._rbSmallRes);
         this._rbBigRes = new RadioButton("分辨率：1000*768");
         this.setRaidoStyle(this._rbBigRes);
         this._rbBigRes.x = 230;
         this._rbBigRes.y = 442;
         this._rbGroup.addTarget(this._rbBigRes);
         addChild(this._rbBigRes);
         this._rbSmallRes.selected = true;
         this._rbGroup.addTarget(this._rbSmallRes);
         this._rbGroup.selectedTarget = this._rbSmallRes;
      }
      
      private function onTextChanged(param1:Event) : void
      {
         if(param1.target.name == "tfName")
         {
            this._ui["tfNum1"].text = param1.target.text.length + "/30";
         }
         else if(param1.target.name == "tfDesc")
         {
            this._ui["tfNum2"].text = param1.target.text.length + "/200";
         }
      }
      
      public function get picDesc() : String
      {
         return this._ui["tfDesc"].text;
      }
      
      override protected function setSize() : void
      {
         super.setSize();
         panelTitle.x = AlignUtil.middle(_width,panelTitle.width);
      }
      
      public function get picName() : String
      {
         return this._ui["tfName"].text;
      }
      
      private function setRaidoStyle(param1:RadioButton) : void
      {
         param1.textDefaultFormat = this.getTextDefaultFormat();
         param1.textDisabledFormat = this.getTextDisabledFormat();
         param1.textSelectedFormat = this.getTextDefaultFormat();
      }
      
      public function get preview() : DisplayObject
      {
         return this._preview;
      }
      
      public function get smallResolution() : Boolean
      {
         return this._rbGroup.selectedTarget == this._rbSmallRes ? true : false;
      }
      
      private function getTextDisabledFormat() : TextFormat
      {
         if(!this.textDefaultFormat)
         {
            this.textDefaultFormat = new TextFormat("Verdana",12,8947848,null,null,null,null,null,"left");
         }
         return this.textDefaultFormat;
      }
      
      public function addBitmap(param1:DisplayObject) : void
      {
         this.graphics.clear();
         if(param1 == null)
         {
            return;
         }
         this._preview = param1;
         this._preview.width = 400;
         this._preview.height = 300;
         this._preview.x = 14;
         this._preview.y = 10;
         this._ui.addChild(this._preview);
      }
      
      public function setStatus(param1:int) : void
      {
         this.currentStatus = param1;
         switch(param1)
         {
            case UPLOADING:
               this.confirmButton.visible = this.cancelButton.visible = true;
               this.confirmButton.enabled = false;
               this.graphics.clear();
               this.setTxtInfo("正在保存图片，请耐心等等...");
               break;
            case SUCCESS:
               this.confirmButton.visible = this.cancelButton.visible = true;
               this.confirmButton.enabled = true;
               this.confirmButton.text = "查看";
               this.graphics.clear();
               this.setTxtInfo("保存图片成功了！");
               break;
            case ERROR:
               this.confirmButton.visible = false;
               this.cancelButton.visible = true;
               this.cancelButton.text = Language.L["确定"];
               this.cancelButton.x = AlignUtil.middle(width,this.cancelButton.width);
               this.graphics.clear();
               this.setTxtInfo("保存图片失败了，请检查您的网络连接...");
         }
      }
      
      private function getTextDefaultFormat() : TextFormat
      {
         if(!this.textDefaultFormat)
         {
            this.textDefaultFormat = new TextFormat("Verdana",12,0,null,null,null,null,null,"left");
         }
         return this.textDefaultFormat;
      }
      
      override protected function close() : void
      {
         super.close();
         if(this.confirmFn != null)
         {
            this.confirmFn(false);
         }
         if(this.confirmButton != null)
         {
            this.confirmButton.enabled = true;
         }
         if(m_msgCenter != null)
         {
            m_msgCenter.dispatchEvent(new CommonEvent(Consts.MSG_CAMERA,false));
         }
      }
      
      private function onCancel(param1:MouseEvent) : void
      {
         this.close();
      }
      
      private function onOK(param1:MouseEvent) : void
      {
         if(this.confirmFn != null)
         {
            this.confirmFn(true);
         }
      }
      
      public function setTxtInfo(param1:String) : void
      {
         this._ui["tfInfo"].text = param1;
      }
   }
}

