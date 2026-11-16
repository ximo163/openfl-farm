package com.qzone.utils
{
   import flash.text.TextField;
   
   public class HtmlUtil
   {
      
      private static var _textField:TextField;
      
      public function HtmlUtil()
      {
         super();
      }
      
      public static function escHTML(param1:String) : String
      {
         return param1.replace(/\&/g,"&amp;").replace(/\ /g,"&nbsp;").replace(/\</g,"&lt;").replace(/\>/g,"&gt;").replace(/\'/,"&apos;").replace(/\"/g,"&quot;");
      }
      
      public static function getRealLength(param1:String) : uint
      {
         return uint(param1.replace(/[^\x00-\xff]/mg,"00").length);
      }
      
      public static function restHTML(param1:String) : String
      {
         if(!_textField)
         {
            _textField = new TextField();
         }
         _textField.htmlText = param1.replace(/#39/ig,"\'");
         return _textField.text;
      }
   }
}

