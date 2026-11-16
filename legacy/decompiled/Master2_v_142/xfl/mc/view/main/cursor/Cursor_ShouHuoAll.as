package mc.view.main.cursor
{
   import common.MaterialLib;
   import flash.display.MovieClip;
   
   public class Cursor_ShouHuoAll extends BaseCursor
   {
      
      private var _cursor:MovieClip;
      
      public function Cursor_ShouHuoAll()
      {
         super();
         this._cursor = MaterialLib.getInstance().getMaterial("CursorShouHuoAll") as MovieClip;
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

