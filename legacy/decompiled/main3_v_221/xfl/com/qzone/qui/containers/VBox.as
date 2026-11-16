package com.qzone.qui.containers
{
   import com.qzone.qui.containers.boxClasses.Box;
   import com.qzone.qui.core.Direction;
   
   public class VBox extends Box
   {
      
      public function VBox(param1:Number = 200, param2:Number = 200)
      {
         super(param1,param2);
         direction = Direction.VERTICAL;
      }
   }
}

