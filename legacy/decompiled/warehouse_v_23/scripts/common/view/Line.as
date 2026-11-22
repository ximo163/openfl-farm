package common.view
{
   import flash.display.Shape;
   
   public class Line extends Shape
   {
      
      public function Line(param1:int = 100, param2:int = 0, param3:uint = 16777215)
      {
         super();
         graphics.lineStyle(1,param3);
         graphics.moveTo(param2,0);
         graphics.lineTo(param1,0);
         graphics.endFill();
      }
   }
}

