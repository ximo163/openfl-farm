package mc.view.main.cursor
{
   import common.MaterialLib;
   import flash.display.MovieClip;
   
   public class Cursor_ShouHuo extends BaseCursor
   {
      
      private var _cursor:MovieClip;
      
      public function Cursor_ShouHuo()
      {
         super();
         this._cursor = MaterialLib.getInstance().getMaterial("CursorHand") as MovieClip;
         this._cursor.cacheAsBitmap = true;
         addChild(this._cursor);
         this.cacheAsBitmap = true;
      }
      
      override public function down() : void
      {
         this._cursor.gotoAndStop(3);
      }
      
      override public function up() : void
      {
         this._cursor.gotoAndStop(1);
      }
   }
}

