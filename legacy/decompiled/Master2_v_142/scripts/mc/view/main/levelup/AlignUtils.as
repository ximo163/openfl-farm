package mc.view.main.levelup
{
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   
   public class AlignUtils
   {
      
      public function AlignUtils()
      {
         super();
      }
      
      public static function align_BOTTOM_CENTER(param1:Sprite, param2:DisplayObject) : void
      {
         param2.x = int((param1.width - param2.width) * 0.5);
         param2.y = int(param1.height - param2.height);
      }
      
      public static function align_TOP_CENTER(param1:Sprite, param2:DisplayObject) : void
      {
         param2.x = int((param1.width - param2.width) * 0.5);
      }
      
      public static function getPositionX_Line(param1:int, param2:int) : int
      {
         return param2 * param1;
      }
      
      public static function scale_TO_Height_D(param1:DisplayObject, param2:int) : void
      {
         var _loc3_:Number = NaN;
         if(param1.height > param2)
         {
            _loc3_ = param2 / param1.height;
            param1.width *= _loc3_;
            param1.height = param2;
         }
      }
      
      public static function scale_TO_WIDTH_D(param1:DisplayObject, param2:int) : void
      {
         var _loc3_:Number = NaN;
         if(param1.width > param2)
         {
            _loc3_ = param2 / param1.width;
            param1.height *= _loc3_;
            param1.width = param2;
         }
      }
      
      public static function align_CENTER(param1:Sprite, param2:DisplayObject) : void
      {
         param2.x = int((param1.width - param2.width) * 0.5);
         param2.y = int((param1.height - param2.height) * 0.5);
      }
   }
}

