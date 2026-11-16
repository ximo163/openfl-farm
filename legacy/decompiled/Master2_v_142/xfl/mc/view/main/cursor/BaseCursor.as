package mc.view.main.cursor
{
   import flash.display.Sprite;
   import flash.filters.ColorMatrixFilter;
   import flash.filters.GlowFilter;
   
   public class BaseCursor extends Sprite implements IBaseCursor
   {
      
      private var _cursorArgument:Object;
      
      public function BaseCursor()
      {
         super();
      }
      
      public function down() : void
      {
      }
      
      public function set cursorArgument(param1:Object) : void
      {
         this._cursorArgument = param1;
      }
      
      public function click() : void
      {
      }
      
      public function up() : void
      {
      }
      
      public function setCursorFilter() : void
      {
         var _loc1_:Array = new Array();
         _loc1_ = _loc1_.concat([1.1,0,0,0,0]);
         _loc1_ = _loc1_.concat([0,1.1,0,0,0]);
         _loc1_ = _loc1_.concat([0,0,1.1,0,0]);
         _loc1_ = _loc1_.concat([0,0,0,1,0]);
         this.filters = [new GlowFilter(13434624,1,10,10),new ColorMatrixFilter(_loc1_)];
      }
      
      public function cancelCursorFilter() : void
      {
         this.filters = null;
      }
      
      public function get cursorArgument() : Object
      {
         return this._cursorArgument;
      }
   }
}

