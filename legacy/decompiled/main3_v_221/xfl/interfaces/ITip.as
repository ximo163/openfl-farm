package interfaces
{
   import flash.display.DisplayObject;
   
   public interface ITip
   {
      
      function get displayObject() : DisplayObject;
      
      function get tX() : Number;
      
      function get tY() : Number;
      
      function get tipName() : String;
      
      function set tX(param1:Number) : void;
      
      function set tY(param1:Number) : void;
      
      function get mX() : Number;
      
      function get mY() : Number;
      
      function get data() : Object;
      
      function set data(param1:Object) : void;
      
      function set mX(param1:Number) : void;
      
      function set mY(param1:Number) : void;
   }
}

