package com.qzone.allianceActivity.framewrok.utils
{
   import flash.filters.ColorMatrixFilter;
   import flash.filters.DropShadowFilter;
   import flash.filters.GlowFilter;
   import flash.text.Font;
   import flash.text.TextFormat;
   
   public class StylesManager
   {
      
      private static var _fontFormat:TextFormat;
      
      private static var _defaultEnumerateFonts:String;
      
      public function StylesManager()
      {
         super();
      }
      
      public static function getShadowColor(param1:int) : uint
      {
         var _loc2_:uint = 13421772;
         switch(param1)
         {
            case 1:
               _loc2_ = 10750217;
               break;
            case 2:
               _loc2_ = 10909700;
               break;
            case 3:
               _loc2_ = 2782896;
               break;
            case 4:
               _loc2_ = 10750217;
         }
         return _loc2_;
      }
      
      public static function getGrayFilter() : Array
      {
         return [new ColorMatrixFilter([0.3086,0.6094,0.082,0,0,0.3086,0.6094,0.082,0,0,0.3086,0.6094,0.082,0,0,0,0,0,1,0])];
      }
      
      public static function getShadowFilter(param1:uint) : Array
      {
         return [new DropShadowFilter(2,90,param1,1,2,2,1.9),new GlowFilter(param1,1,2,2,10)];
      }
      
      public static function getFontFormat() : TextFormat
      {
         var _loc1_:TextFormat = new TextFormat();
         _loc1_.font = "FZCuYuan-M03S";
         return _loc1_;
      }
      
      public static function get DefaultEnumerateFonts() : String
      {
         var _loc1_:Array = null;
         var _loc2_:Font = null;
         var _loc3_:* = 0;
         if(!_defaultEnumerateFonts)
         {
            _loc1_ = Font.enumerateFonts(true);
            _defaultEnumerateFonts = "SimSun";
            _loc3_ = int(_loc1_.length - 1);
            while(_loc3_ > 0)
            {
               _loc2_ = _loc1_[_loc3_] as Font;
               if(_loc2_.fontName == "微软雅黑")
               {
                  _defaultEnumerateFonts = "微软雅黑";
                  break;
               }
               if(_loc2_.fontName == "黑体")
               {
                  _defaultEnumerateFonts = "SimHei";
               }
               _loc3_--;
            }
         }
         return _defaultEnumerateFonts;
      }
   }
}

