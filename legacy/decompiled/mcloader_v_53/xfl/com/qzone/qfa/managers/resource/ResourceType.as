package com.qzone.qfa.managers.resource
{
   public class ResourceType
   {
      
      public static const TYPE_BITMAP:String = "tBitmap";
      
      public static const TYPE_XML:String = "tXML";
      
      public static const TYPE_CSS:String = "tCSS";
      
      public static const TYPE_TEXT:String = "tText";
      
      public static const TYPE_SWF:String = "tSWF";
      
      public static const TYPE_MP3:String = "tMP3";
      
      public static const TYPE_UNKNOWN:String = "tUnknown";
      
      public static const TYPE_BINARY:String = "tBinary";
      
      public function ResourceType()
      {
         super();
      }
      
      public static function getType(param1:String) : String
      {
         var _loc2_:RegExp = /(.*?).(jpg|jpeg|png|gif)/i;
         var _loc3_:RegExp = /(.*?).(xml)/i;
         var _loc4_:RegExp = /(.*?).(css)/i;
         var _loc5_:RegExp = /(.*?).(txt|rtf)/i;
         var _loc6_:RegExp = /(.*?).(swf)/i;
         var _loc7_:RegExp = /(.*?).(mp3)/i;
         if(_loc2_.test(param1))
         {
            return ResourceType.TYPE_BITMAP;
         }
         if(_loc3_.test(param1))
         {
            return ResourceType.TYPE_XML;
         }
         if(_loc4_.test(param1))
         {
            return ResourceType.TYPE_CSS;
         }
         if(_loc5_.test(param1))
         {
            return ResourceType.TYPE_TEXT;
         }
         if(_loc6_.test(param1))
         {
            return ResourceType.TYPE_SWF;
         }
         if(_loc7_.test(param1))
         {
            return ResourceType.TYPE_MP3;
         }
         return ResourceType.TYPE_UNKNOWN;
      }
   }
}

