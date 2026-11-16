package com.qzone.utils
{
   import flash.xml.XMLDocument;
   import flash.xml.XMLNode;
   import flash.xml.XMLNodeType;
   
   public final class StringUtil
   {
      
      public function StringUtil()
      {
         super();
      }
      
      public static function replaceText(param1:String, param2:Object) : String
      {
         var _loc3_:String = null;
         var _loc4_:RegExp = null;
         for(_loc3_ in param2)
         {
            _loc4_ = new RegExp("{" + _loc3_ + "}","g");
            param1 = param1.replace(_loc4_,param2[_loc3_]);
         }
         return param1;
      }
      
      public static function htmlUnescape(param1:String) : String
      {
         return new XMLDocument(param1).firstChild.nodeValue;
      }
      
      public static function trim(param1:String) : String
      {
         return StringUtil.ltrim(StringUtil.rtrim(param1));
      }
      
      public static function htmlEscape(param1:String) : String
      {
         return XML(new XMLNode(XMLNodeType.TEXT_NODE,param1)).toXMLString();
      }
      
      public static function ltrim(param1:String) : String
      {
         if(param1 == null)
         {
            return "";
         }
         var _loc2_:Number = param1.length;
         var _loc3_:Number = 0;
         while(_loc3_ < _loc2_)
         {
            if(param1.charCodeAt(_loc3_) > 32)
            {
               return param1.substring(_loc3_);
            }
            _loc3_++;
         }
         return "";
      }
      
      public static function getZeroString(param1:Number, param2:uint = 2) : String
      {
         var _loc3_:String = param1.toString();
         while(param2 > _loc3_.length)
         {
            _loc3_ = "0" + _loc3_;
         }
         return _loc3_;
      }
      
      private static function doubleString(param1:int) : String
      {
         if(param1 < 10)
         {
            return "0" + param1;
         }
         return param1.toString();
      }
      
      public static function dateFormat(param1:int) : String
      {
         var _loc2_:Date = new Date(param1 * 1000);
         return doubleString(_loc2_.getFullYear()) + "-" + doubleString(_loc2_.getMonth() + 1) + "-" + doubleString(_loc2_.getDate()) + " " + doubleString(_loc2_.getHours()) + ":" + doubleString(_loc2_.getMinutes());
      }
      
      public static function tirmCallBack(param1:String) : String
      {
         if(param1.substr(0,10).toLocaleLowerCase() == "_callback(")
         {
            param1 = param1.substr(10);
         }
         var _loc2_:int = param1.lastIndexOf("}");
         if(_loc2_ != param1.length - 1)
         {
            param1 = param1.substr(0,_loc2_ + 1);
         }
         return param1;
      }
      
      public static function getChineseNum(param1:Number) : String
      {
         var _loc5_:Number = NaN;
         var _loc2_:String = "";
         var _loc3_:Array = ["零","一","二","三","四","五","六","七","八","九","十"];
         if(param1 <= 10)
         {
            return _loc3_[param1];
         }
         var _loc4_:Array = param1.toString().split("");
         for each(_loc5_ in _loc4_)
         {
            _loc2_ += _loc3_[_loc5_];
         }
         return _loc2_;
      }
      
      public static function rtrim(param1:String) : String
      {
         if(param1 == null)
         {
            return "";
         }
         var _loc2_:Number = param1.length;
         var _loc3_:Number = _loc2_;
         while(_loc3_ > 0)
         {
            if(param1.charCodeAt(_loc3_ - 1) > 32)
            {
               return param1.substring(0,_loc3_);
            }
            _loc3_--;
         }
         return "";
      }
      
      public static function getFixedLengthString(param1:int, param2:int) : String
      {
         var _loc3_:String = param1.toString();
         var _loc4_:int = param2 - _loc3_.length;
         var _loc5_:int = 1;
         while(_loc5_ <= _loc4_)
         {
            _loc3_ = "0" + _loc3_;
            _loc5_++;
         }
         return _loc3_;
      }
      
      public static function getFloatNumber(param1:Number, param2:uint = 2) : String
      {
         return param1.toFixed(param2);
      }
      
      public static function getByteSize(param1:int, param2:uint = 2) : String
      {
         if(param1 > 1024 * 1024 * 1024)
         {
            return getFloatNumber(param1 / 1024 / 1024 / 1024,param2) + " GB";
         }
         if(param1 > 1024 * 1024)
         {
            return getFloatNumber(param1 / 1024 / 1024,param2) + " MB";
         }
         if(param1 > 1024)
         {
            return getFloatNumber(param1 / 1024,param2) + " KB";
         }
         return param1.toString() + " B";
      }
   }
}

