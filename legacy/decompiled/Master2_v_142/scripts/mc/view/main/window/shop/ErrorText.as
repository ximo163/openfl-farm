package mc.view.main.window.shop
{
   import common.*;
   import flash.display.*;
   import flash.text.*;
   
   public class ErrorText extends Sprite
   {
      
      private var _error:MovieClip;
      
      public function ErrorText(param1:Boolean = true)
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:DisplayObject = null;
         super();
         this._error = MaterialLib.getInstance().getMaterial("ErrorTips") as MovieClip;
         this._error.errorTxt.selectable = false;
         (this._error.errorTxt as TextField).autoSize = TextFieldAutoSize.LEFT;
         this._error.errorTxt.defaultTextFormat = new TextFormat("Verdana",12,13382400,null,null,null,null,null,TextFormatAlign.LEFT);
         this._error.errorTxt.text = "";
         if(param1 == false)
         {
            _loc2_ = this._error.numChildren;
            _loc3_ = 0;
            while(_loc3_ < _loc2_)
            {
               _loc4_ = this._error.getChildAt(_loc3_);
               if(_loc3_ == 0)
               {
                  _loc4_.visible = false;
               }
               _loc3_++;
            }
         }
         addChild(this._error);
      }
      
      public function set showBackGround(param1:Boolean) : void
      {
         var _loc4_:DisplayObject = null;
         var _loc2_:int = this._error.numChildren;
         var _loc3_:int = 0;
         while(_loc3_ < _loc2_)
         {
            _loc4_ = this._error.getChildAt(_loc3_);
            if(_loc3_ == 0)
            {
               _loc4_.visible = param1;
            }
            _loc3_++;
         }
      }
      
      public function set text(param1:String) : void
      {
         if(param1 == "")
         {
            this.visible = false;
         }
         else
         {
            this.visible = true;
         }
         this._error.errorTxt.htmlText = param1;
         this._error.bg.width = this._error.errorTxt.width + 30;
         this._error.bg.height = this._error.errorTxt.height + 10;
      }
      
      public function get text() : String
      {
         return this._error.errorTxt.text;
      }
   }
}

