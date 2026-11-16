package mc.view.main.game
{
   import common.MaterialLib;
   import flash.display.Loader;
   import flash.display.Sprite;
   import flash.events.FocusEvent;
   import flash.events.KeyboardEvent;
   import flash.events.TextEvent;
   import flash.net.URLRequest;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import mc.control.Command;
   import mc.view.common.AddButtonWindow;
   
   public class ValidateCodeWindow extends AddButtonWindow
   {
      
      private var _headHeight:int = 30;
      
      private var imgrequest:URLRequest = new URLRequest();
      
      private var postText:TextField;
      
      private var _text:String;
      
      private var img_loader:Loader;
      
      private var _padding:int = 20;
      
      private var lipiT:TextField;
      
      public function ValidateCodeWindow()
      {
         super();
         width = 320;
         height = 250;
         mode = true;
         titleIMG = MaterialLib.getInstance().getClass("AlertWindowTitle");
      }
      
      private function _KEY_UP(param1:KeyboardEvent) : void
      {
         if(param1.charCode == 13)
         {
            this.confirmFn();
         }
      }
      
      private function cancelFn() : void
      {
         closeHandler();
      }
      
      private function confirmFn() : void
      {
         if(this.lipiT.text.length > 0)
         {
            Command.getInstance().mainCommand.validateCode(this.lipiT.text);
            closeHandler();
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
      
      private function imgRenew(param1:TextEvent) : void
      {
         this.img_loader.unload();
         this.imgrequest.url = "" + Math.random();
         this.img_loader.load(this.imgrequest);
      }
      
      override public function init() : void
      {
         var renew_txt:TextField = null;
         var img_mc:Sprite = null;
         var content:Sprite = MaterialLib.getInstance().getMaterial("ValidateCodeContent") as Sprite;
         if(content)
         {
            content.y = this._headHeight + this._padding;
            content.x = this._padding;
            addChild(content);
            addButton("确定","ButtonOrange",65,25,this.confirmFn);
            this.addEventListener(KeyboardEvent.KEY_UP,this._KEY_UP);
            super.init();
            this.postText = content.getChildByName("postText") as TextField;
            this.lipiT = content.getChildByName("input_txt") as TextField;
            this.lipiT.borderColor = 3381759;
            this.lipiT.defaultTextFormat = new TextFormat("Verdana",12,10855845,null,null,null,null,null,"left");
            this.lipiT.text = "请输入图形验证码";
            this.lipiT.maxChars = 8;
            this.lipiT.restrict = "a-z A-Z 0-9";
            this.lipiT.addEventListener(FocusEvent.FOCUS_IN,function(param1:FocusEvent):void
            {
               lipiT.text = "";
               lipiT.defaultTextFormat = new TextFormat("Verdana",12,3355443,null,null,null,null,null,"left");
            });
            this.lipiT.addEventListener(FocusEvent.FOCUS_OUT,function(param1:FocusEvent):void
            {
               if(lipiT.text == "")
               {
                  lipiT.borderColor = 3381759;
                  lipiT.defaultTextFormat = new TextFormat("Verdana",12,10855845,null,null,null,null,null,"left");
                  lipiT.text = "请输入图形验证码";
               }
            });
            this.stage.focus = this.lipiT;
            renew_txt = content.getChildByName("renew_txt") as TextField;
            renew_txt.addEventListener(TextEvent.LINK,this.imgRenew);
            img_mc = content.getChildByName("img_mc") as Sprite;
            this.img_loader = new Loader();
            img_mc.addChild(this.img_loader);
            this.imgRenew(null);
         }
      }
      
      public function get text() : String
      {
         return this._text;
      }
      
      private function getPostDataFn(param1:Object) : void
      {
         if(param1["code"] == 1)
         {
            if(param1["content"] != null)
            {
               this.text = param1["content"];
            }
         }
      }
   }
}

