package mc.view.main.task
{
   import com.minutes.ui.control.LipiButton;
   import com.minutes.ui.core.LipiSkin;
   import common.MaterialLib;
   import flash.display.DisplayObject;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import mc.view.common.BaseWindow;
   
   public class Task extends BaseWindow
   {
      
      private var _operationButtonHeight:int = 25;
      
      private var _cancelButtonLabel:String = "取消";
      
      private var _cancelButtonbgAlpha:int = 0;
      
      private var _cancelButtonTextBold:Boolean = false;
      
      private var _operationButtonbgAlpha:int = 0;
      
      private var _cancelButtonTextSize:int = 12;
      
      private var _operationButtonTextColor:int = 16777215;
      
      private var _operationButtonTextSize:int = 12;
      
      private var _operationButtonWidth:int = 60;
      
      private var _cancelButtonTextFont:String = "";
      
      private var _cancelButtonHeight:int = 25;
      
      private var _addOperationButton:Boolean = true;
      
      private var _operationButtonTextBold:Boolean = false;
      
      private var addChildCache:Array = [];
      
      private var _cancelButtonTextColor:int = 16777215;
      
      private var cancelButton:LipiButton = null;
      
      private var _addCancelButton:Boolean = true;
      
      private var _operationButtonLabel:String = "接受";
      
      private var _cancelButtonWidth:int = 60;
      
      private var operationButton:LipiButton = null;
      
      private var _operationButtonTextFont:String = "";
      
      private var fun:Function = null;
      
      public function Task()
      {
         super();
         width = 370;
         height = 260;
         titleIMG = MaterialLib.getInstance().getClass("TaskWindowTitle");
         windowName = "TaskWindow";
         mode = true;
      }
      
      public function set operationButtonHeight(param1:int) : void
      {
         this._operationButtonHeight = param1;
      }
      
      public function set operationButtonbgAlpha(param1:int) : void
      {
         this._operationButtonbgAlpha = param1;
      }
      
      public function closeWindow(param1:Event = null) : void
      {
         this.closeHandler();
      }
      
      override public function init() : void
      {
         if(this._addOperationButton)
         {
            this.operationButton = new LipiButton();
            this.operationButton.name = "operation";
            this.operationButton.bgSkin = new LipiSkin(MaterialLib.getInstance().getClass("ButtonOrange"));
            this.operationButton.label = this._operationButtonLabel;
            this.operationButton.textColor = this._operationButtonTextColor;
            this.operationButton.textSize = this._operationButtonTextSize;
            this.operationButton.textBold = this._operationButtonTextBold;
            this.operationButton.textFont = this._operationButtonTextFont;
            this.operationButton.bgAlpha = this._operationButtonbgAlpha;
            this.operationButton.width = this._operationButtonWidth;
            this.operationButton.height = this._operationButtonHeight;
            this.addChild(this.operationButton);
            this.operationButton.addEventListener(MouseEvent.CLICK,this.operation);
         }
         if(this._addCancelButton)
         {
            this.cancelButton = new LipiButton();
            this.cancelButton.name = "cancel";
            this.cancelButton.bgSkin = new LipiSkin(MaterialLib.getInstance().getClass("ButtonBlue"));
            this.cancelButton.label = this._cancelButtonLabel;
            this.cancelButton.textColor = this._cancelButtonTextColor;
            this.cancelButton.textSize = this._cancelButtonTextSize;
            this.cancelButton.textBold = this._cancelButtonTextBold;
            this.cancelButton.textFont = this._cancelButtonTextFont;
            this.cancelButton.bgAlpha = this._cancelButtonbgAlpha;
            this.cancelButton.width = this._cancelButtonWidth;
            this.cancelButton.height = this._cancelButtonHeight;
            this.addChild(this.cancelButton);
            this.cancelButton.addEventListener(MouseEvent.CLICK,this.closeWindow);
         }
         var _loc1_:int = 0;
         while(_loc1_ < this.addChildCache.length)
         {
            this.addChild(this.addChildCache[_loc1_]);
            _loc1_++;
         }
         if(this.operationButton != null && this.cancelButton != null)
         {
            this.operationButton.x = (this.width - this.operationButton.width - this.cancelButton.width - 20) * 0.5;
            this.operationButton.y = this.height - this.operationButton.height - 18;
            this.cancelButton.x = this.operationButton.x + this.operationButton.width + 20;
            this.cancelButton.y = this.height - this.cancelButton.height - 18;
         }
         else if(this.operationButton != null)
         {
            this.operationButton.x = (this.width - this.operationButton.width) * 0.5;
            this.operationButton.y = this.height - this.operationButton.height - 18;
         }
         else if(this.cancelButton != null)
         {
            this.cancelButton.x = (this.width - this.cancelButton.width) * 0.5;
            this.cancelButton.y = this.height - this.cancelButton.height - 18;
         }
         this.toCenterPositon();
      }
      
      public function set operationAction(param1:Function) : void
      {
         this.fun = param1;
      }
      
      public function set cancelButtonTextColor(param1:int) : void
      {
         this._cancelButtonTextColor = param1;
      }
      
      public function set cancelButtonLabel(param1:String) : void
      {
         this._cancelButtonLabel = param1;
      }
      
      public function set addCancelButton(param1:Boolean) : void
      {
         this._addCancelButton = param1;
      }
      
      public function set operationButtonWidth(param1:int) : void
      {
         this._operationButtonWidth = param1;
      }
      
      public function set cancelButtonHeight(param1:int) : void
      {
         this._cancelButtonHeight = param1;
      }
      
      public function taskAddChild(param1:DisplayObject) : DisplayObject
      {
         this.addChildCache.push(param1);
         return param1;
      }
      
      public function set cancelButtonbgAlpha(param1:int) : void
      {
         this._cancelButtonbgAlpha = param1;
      }
      
      public function set addOperationButton(param1:Boolean) : void
      {
         this._addOperationButton = param1;
      }
      
      public function set cancelButtonWidth(param1:int) : void
      {
         this._cancelButtonWidth = param1;
      }
      
      public function set cancelButtonTextFont(param1:String) : void
      {
         this._cancelButtonTextFont = param1;
      }
      
      public function set operationButtonTextSize(param1:int) : void
      {
         this._operationButtonTextSize = param1;
      }
      
      public function set operationButtonTextBold(param1:Boolean) : void
      {
         this._operationButtonTextBold = param1;
      }
      
      public function toCenterPositon() : void
      {
         x = Math.floor(stage.stageWidth * 0.5 - width * 0.5);
         y = Math.floor(stage.stageHeight * 0.5 - height * 0.5);
      }
      
      public function operation(param1:Event) : void
      {
         if(this.fun != null)
         {
            this.fun();
         }
      }
      
      public function set operationButtonTextFont(param1:String) : void
      {
         this._operationButtonTextFont = param1;
      }
      
      public function set cancelButtonTextSize(param1:int) : void
      {
         this._cancelButtonTextSize = param1;
      }
      
      public function set operationButtonLabel(param1:String) : void
      {
         this._operationButtonLabel = param1;
      }
      
      public function set operationButtonTextColor(param1:int) : void
      {
         this._operationButtonTextColor = param1;
      }
      
      public function set cancelButtonTextBold(param1:Boolean) : void
      {
         this._cancelButtonTextBold = param1;
      }
   }
}

