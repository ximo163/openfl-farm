package com.lipi
{
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormat;
   import flash.utils.ByteArray;
   
   public class LipiUtil
   {
      
      public function LipiUtil()
      {
         super();
      }
      
      public static function randRange(param1:Number, param2:Number) : Number
      {
         return Math.floor(Math.random() * (param2 - param1 + 1)) + param1;
      }
      
      public static function getStringLength(param1:String) : int
      {
         var _loc2_:ByteArray = new ByteArray();
         _loc2_.writeUTFBytes(param1);
         return _loc2_.length;
      }
      
      public static function clone(param1:Object) : *
      {
         var _loc2_:ByteArray = new ByteArray();
         _loc2_.writeObject(param1);
         _loc2_.position = 0;
         return _loc2_.readObject();
      }
      
      public static function getTextLangth(param1:String, param2:TextFormat = null) : Number
      {
         var _loc3_:Number = 0;
         var _loc4_:TextField = new TextField();
         if(param2 != null)
         {
            _loc4_.defaultTextFormat = param2;
         }
         _loc4_.autoSize = TextFieldAutoSize.LEFT;
         _loc4_.text = param1;
         return _loc4_.width;
      }
   }
}

