package com.qzone.allianceActivity.framewrok.serialization
{
   public class Json
   {
      
      public function Json()
      {
         super();
      }
      
      public static function encode(param1:*) : String
      {
         return new JsonEncoder(param1).getString();
      }
      
      public static function decode(param1:String) : *
      {
         return new JsonDecoder(param1).parse();
      }
   }
}

