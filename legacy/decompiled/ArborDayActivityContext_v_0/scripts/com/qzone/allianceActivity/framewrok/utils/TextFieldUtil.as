package com.qzone.allianceActivity.framewrok.utils
{
   import flash.text.TextField;
   
   public class TextFieldUtil
   {
      
      public function TextFieldUtil()
      {
         super();
      }
      
      public static function refreshText(param1:TextField, param2:String) : void
      {
         if(param1)
         {
            if(param2 == null)
            {
               param2 = "";
            }
            param1.text = param2;
         }
      }
   }
}

