package mc.view.common
{
   import common.MaterialLib;
   import flash.text.TextField;
   import flash.text.TextFormat;
   
   public class HtmlTextWindow extends AddButtonWindow
   {
      
      public static const OK:int = 2;
      
      public static const CANCEL:int = 4;
      
      private var _closeFn:Function;
      
      public var okLabel:String = "确定";
      
      private var _padding:int;
      
      public var vMiddle:Boolean = false;
      
      private var _text:String;
      
      private var _detail:int;
      
      private var _txt:TextField;
      
      public var textFormat:TextFormat;
      
      private var _type:int;
      
      public var isSetHeight:Boolean = false;
      
      public function HtmlTextWindow(param1:String = "", param2:int = 2, param3:int = 12, param4:Function = null)
      {
         super();
         this._text = param1;
         this._padding = param3;
         this._txt = new TextField();
         addChild(this._txt);
         this._type = param2;
         this._detail = CANCEL;
         this._closeFn = param4;
         titleIMG = MaterialLib.getInstance().getClass("AlertWindowTitle");
      }
      
      override protected function closeHandler() : void
      {
         this._closeFn(this._detail);
         super.closeHandler();
      }
      
      override public function init() : void
      {
         this._txt.selectable = false;
         this._txt.mouseWheelEnabled = false;
         this.textFormat = this.textFormat || new TextFormat("Verdana",12,3355443);
         this.textFormat.leading = 6;
         this._txt.defaultTextFormat = this.textFormat;
         this._txt.wordWrap = true;
         this._txt.multiline = true;
         this._txt.autoSize = "left";
         this._txt.x = this._padding + 2;
         this._txt.y = 27 + this._padding;
         this._txt.htmlText = this._text;
         this._txt.width = width - (this._padding + 2) * 2;
         this._txt.defaultTextFormat = this.textFormat;
         if(!this.isSetHeight)
         {
            height = this._txt.textHeight + 27 + this._padding * 2 + 45;
         }
         if(this.vMiddle)
         {
            this._txt.y = int(height / 2 - this._txt.textHeight / 2) - 13;
         }
         if(this._type == 2 || this._type == 6)
         {
            addButton(this.okLabel,"ButtonOrange",68,25,function():void
            {
               _detail = OK;
               closeHandler();
            });
         }
         if(this._type == 4 || this._type == 6)
         {
            addButton(Language.L["取消"],"ButtonBlue",68,25,function():void
            {
               _detail = CANCEL;
               closeHandler();
            });
         }
         super.init();
      }
   }
}

