package com.qzone.allianceActivity.collectingActivity.view
{
   public class LayoutManager
   {
      
      public function LayoutManager()
      {
         super();
      }
      
      public static function sortByGrid(param1:Array, param2:int, param3:int, param4:int, param5:int, param6:int) : void
      {
         var _loc13_:* = undefined;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         var _loc10_:int = 0;
         var _loc11_:Number = 0;
         var _loc12_:Number = 0;
         for each(_loc13_ in param1)
         {
            _loc7_ = Math.floor(_loc10_ / param2);
            _loc9_ = _loc10_ % param2;
            _loc10_++;
            if(_loc8_ != _loc7_)
            {
               _loc11_ = 0;
               _loc12_ += _loc13_["height"] as Number;
            }
            _loc13_.x = param3 + _loc11_ + param5 * _loc9_;
            _loc13_.y = param4 + _loc12_ + param6 * _loc7_;
            _loc11_ += _loc13_["width"] as Number;
            _loc8_ = _loc7_;
         }
      }
      
      public static function sortByCol(param1:Array, param2:int, param3:int, param4:int) : void
      {
         var _loc7_:* = undefined;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         for each(_loc7_ in param1)
         {
            _loc7_.y = param3 + _loc5_ + param4 * _loc6_;
            _loc7_.x = param2;
            _loc5_ += _loc7_["height"] as Number;
            _loc6_++;
         }
      }
      
      public static function sortByRow(param1:Array, param2:int, param3:int, param4:int) : void
      {
         var _loc7_:* = undefined;
         var _loc5_:Number = 0;
         var _loc6_:int = 0;
         for each(_loc7_ in param1)
         {
            _loc7_.x = param2 + _loc5_ + param4 * _loc6_;
            _loc7_.y = param3;
            _loc5_ += _loc7_["width"] as Number;
            _loc6_++;
         }
      }
   }
}

