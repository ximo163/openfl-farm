package com.qzone.qfa.data
{
   public class ResourceType
   {
      
      public static const TYPE_BITMAP:String = "tBitmap";
      
      public static const TYPE_TEXT:String = "tText";
      
      public static const TYPE_SWF:String = "tSWF";
      
      public static const TYPE_BINARY:String = "tBin";
      
      public function ResourceType()
      {
         super();
      }
      
      public static function getType(param1:String) : String
      {
         var _loc2_:RegExp = /(.*?).(jpg|jpeg|png|gif)/i;
         var _loc3_:RegExp = /(.*?).(txt|js|xml|css)/i;
         var _loc4_:RegExp = /(.*?).(swf)/i;
         if(_loc2_.test(param1))
         {
            return TYPE_BITMAP;
         }
         if(_loc3_.test(param1))
         {
            return TYPE_TEXT;
         }
         if(_loc4_.test(param1))
         {
            return TYPE_SWF;
         }
         return TYPE_BINARY;
      }
   }
}

