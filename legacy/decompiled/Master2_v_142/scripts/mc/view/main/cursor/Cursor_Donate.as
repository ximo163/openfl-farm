package mc.view.main.cursor
{
   import common.MaterialLib;
   import flash.display.MovieClip;
   
   public final class Cursor_Donate extends BaseCursor
   {
      
      private var _cursor:MovieClip;
      
      public function Cursor_Donate()
      {
         super();
         this._cursor = MaterialLib.getInstance().getMaterial("CursorDonate") as MovieClip;
         this._cursor.cacheAsBitmap = true;
         addChild(this._cursor);
         this.cacheAsBitmap = true;
      }
      
      override public function down() : void
      {
      }
      
      override public function up() : void
      {
      }
   }
}

