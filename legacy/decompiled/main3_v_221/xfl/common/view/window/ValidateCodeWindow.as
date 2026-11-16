package common.view.window
{
   import common.Consts;
   import common.Language;
   import common.misc.Utils;
   import flash.display.DisplayObjectContainer;
   import flash.display.Loader;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.FocusEvent;
   import flash.events.KeyboardEvent;
   import flash.events.TextEvent;
   import flash.net.URLRequest;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import flash.text.TextFormatAlign;
   import interfaces.IMsgCenter;
   
   public class ValidateCodeWindow extends AddButtonWindow
   {
      
      private var imgrequest:URLRequest;
      
      private var _text:String;
      
      private var img_loader:Loader;
      
      private var lipiT:TextField;
      
      private var _callback:Function;
      
      private const INPUT_TIP:String = "输入图形验证码";
      
      private var postText:TextField;
      
      private const HEADHEIGTH:int = 30;
      
      private const PADDING:int = 20;
      
      public function ValidateCodeWindow(param1:IMsgCenter)
      {
         super(param1);
         width = 320;
         height = 250;
         mode = true;
         title = this.INPUT_TIP;
         windowName = Consts.WINDOW_NAME_VALIDATE;
         this.img_loader = null;
         this.imgrequest = new URLRequest();
         this.postText = null;
         this.lipiT = null;
         this._callback = null;
      }
      
      private function onOK() : void
      {
         var _loc1_:String = this.lipiT.text;
         if(_loc1_ == "")
         {
            return;
         }
         var _loc2_:RegExp = /^[a-z0-9]*$/ig;
         if(_loc2_.test(_loc1_) == false)
         {
            return;
         }
         this.removePicture();
         super.close();
         if(this._callback != null)
         {
            this._callback(_loc1_);
         }
      }
      
      override protected function setSize() : void
      {
         super.setSize();
         super.panelTitle.x = (this.width - super.panelTitle.width) * 0.5;
      }
      
      private function imgRenew(param1:TextEvent) : void
      {
         if(this.img_loader == null)
         {
            return;
         }
         this.img_loader.unload();
         this.imgrequest.url = "" + Math.random();
         this.img_loader.load(this.imgrequest);
      }
      
      private function loadCodePicture() : void
      {
         var _loc1_:DisplayObjectContainer = getChildByName("__content__") as DisplayObjectContainer;
         if(_loc1_ == null)
         {
            return;
         }
         this.removePicture();
         this.img_loader = new Loader();
         this.imgRenew(null);
         var _loc2_:Sprite = _loc1_.getChildByName("img_mc") as Sprite;
         if(_loc2_ != null)
         {
            _loc2_.addChild(this.img_loader);
         }
      }
      
      override protected function init() : void
      {
         var content:Sprite = null;
         var renew_txt:TextField = null;
         content = Utils.getMaterial("ValidateCodeContent") as Sprite;
         if(content != null)
         {
            content.y = this.HEADHEIGTH + this.PADDING;
            content.x = this.PADDING;
            content.name = "__content__";
            addChild(content);
            addButton(Language.L["确定"],"ButtonOrange",65,25,this.onOK);
            this.addEventListener(KeyboardEvent.KEY_UP,this.onKeyUp);
            super.init();
            this.postText = content.getChildByName("postText") as TextField;
            this.lipiT = content.getChildByName("input_txt") as TextField;
            this.lipiT.defaultTextFormat = new TextFormat("Verdana",12,10855845,null,null,null,null,null,TextFormatAlign.LEFT);
            this.lipiT.text = this.INPUT_TIP;
            this.lipiT.maxChars = 8;
            this.lipiT.restrict = "a-zA-Z0-9";
            this.lipiT.addEventListener(FocusEvent.FOCUS_IN,function(param1:FocusEvent):void
            {
               if(lipiT.text == INPUT_TIP)
               {
                  lipiT.text = "";
               }
               lipiT.defaultTextFormat = new TextFormat("Verdana",12,3355443,null,null,null,null,null,TextFormatAlign.LEFT);
            });
            this.lipiT.addEventListener(FocusEvent.FOCUS_OUT,function(param1:FocusEvent):void
            {
               if(lipiT.text == "")
               {
                  lipiT.borderColor = 3381759;
                  lipiT.defaultTextFormat = new TextFormat("Verdana",12,10855845,null,null,null,null,null,TextFormatAlign.LEFT);
                  lipiT.text = INPUT_TIP;
               }
            });
            this.stage.focus = this.lipiT;
            renew_txt = content.getChildByName("renew_txt") as TextField;
            renew_txt.addEventListener(TextEvent.LINK,this.imgRenew);
         }
      }
      
      override protected function onClose(param1:Event) : void
      {
         this.removePicture();
         super.onClose(param1);
      }
      
      private function removePicture() : void
      {
         if(this.img_loader != null && this.img_loader.parent != null)
         {
            this.img_loader.parent.removeChild(this.img_loader);
            this.img_loader = null;
         }
      }
      
      public function set text(param1:String) : void
      {
         this._text = param1;
         if(this.postText != null)
         {
            this.postText.text = param1;
         }
      }
      
      override protected function setData() : void
      {
         if(this.lipiT != null && this.lipiT.text != this.INPUT_TIP)
         {
            this.lipiT.text = "";
         }
         this.loadCodePicture();
         if(super.data != null && super.data["callback"] != undefined)
         {
            this._callback = super.data["callback"] as Function;
         }
         else
         {
            this._callback = null;
         }
      }
      
      public function get text() : String
      {
         return this._text;
      }
      
      private function onKeyUp(param1:KeyboardEvent) : void
      {
         if(param1.charCode == 13)
         {
            this.onOK();
         }
      }
   }
}

