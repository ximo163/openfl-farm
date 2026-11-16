package com.qzone.qui.utils
{
   import flash.net.registerClassAlias;
   import flash.text.TextFormat;
   import flash.utils.ByteArray;
   
   public class TextFormatUtil
   {
      
      public function TextFormatUtil()
      {
         super();
      }
      
      public static function clone(param1:TextFormat) : TextFormat
      {
         registerClassAlias("flash.text.TextFormat",TextFormat);
         var _loc2_:ByteArray = new ByteArray();
         _loc2_.writeObject(param1);
         _loc2_.position = 0;
         return _loc2_.readObject();
      }
   }
}

