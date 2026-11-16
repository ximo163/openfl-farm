package com.qzone.allianceActivity.advertisement
{
   import flash.display.DisplayObject;
   
   public interface IAdvertisement
   {
      
      function get serverTime() : Number;
      
      function autoPop(param1:ADConfig) : void;
      
      function grayScale(param1:ADConfig, param2:Function, param3:Function) : void;
      
      function showStrongGuide(param1:DisplayObject, param2:int, param3:int, param4:String, param5:int = 5, param6:Boolean = false) : void;
      
      function whileList(param1:ADConfig, param2:Function, param3:Function) : void;
   }
}

