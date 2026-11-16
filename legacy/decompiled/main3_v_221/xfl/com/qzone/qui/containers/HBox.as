package com.qzone.qui.containers
{
   import com.qzone.qui.containers.boxClasses.Box;
   import com.qzone.qui.core.Direction;
   
   public class HBox extends Box
   {
      
      public function HBox(param1:Number = 200, param2:Number = 200)
      {
         super(param1,param2);
         direction = Direction.HORIZONTAL;
      }
   }
}

