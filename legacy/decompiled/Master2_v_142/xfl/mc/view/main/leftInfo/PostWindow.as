package mc.view.main.leftInfo
{
   import common.MaterialLib;
   import flash.events.TextEvent;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import mc.view.common.AddButtonWindow;
   
   public class PostWindow extends AddButtonWindow
   {
      
      private var _text:String = "";
      
      private var postText:TextField;
      
      public function PostWindow()
      {
         super();
         width = 370;
         height = 280;
         mode = true;
         titleIMG = MaterialLib.getInstance().getClass("NoticeWindowTitle");
      }
      
      override public function init() : void
      {
         this.postText = new TextField();
         this.postText.wordWrap = true;
         this.postText.multiline = true;
         var _loc1_:TextFormat = new TextFormat("Verdana");
         _loc1_.leading = 4;
         this.postText.defaultTextFormat = _loc1_;
         this.postText.y = 45;
         this.postText.x = 15;
         this.postText.width = 340;
         this.postText.height = 200;
         this.postText.htmlText = this.text || "";
         this.postText.selectable = false;
         this.postText.addEventListener(TextEvent.LINK,this._LINK);
         addChild(this.postText);
         addButton("确定","ButtonOrange",65,25,this.confirmFn);
         super.init();
      }
      
      public function set text(param1:String) : void
      {
         this._text = param1;
         if(this.postText != null)
         {
            this.postText.text = param1;
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
      
      private function _LINK(param1:TextEvent) : void
      {
         closeHandler();
      }
      
      private function confirmFn() : void
      {
         closeHandler();
      }
   }
}

