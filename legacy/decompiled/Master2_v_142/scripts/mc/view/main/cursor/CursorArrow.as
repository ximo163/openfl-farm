package mc.view.main.cursor
{
   import common.MaterialLib;
   import flash.display.MovieClip;
   
   public class CursorArrow extends BaseCursor
   {
      
      private var _cursor:MovieClip;
      
      public function CursorArrow()
      {
         super();
         this._cursor = MaterialLib.getInstance().getMaterial("CursorArrow") as MovieClip;
         addChild(this._cursor);
         this.cacheAsBitmap = true;
      }
      
      override public function down() : void
      {
         this._cursor.gotoAndPlay(2);
      }
      
      override public function up() : void
      {
         this._cursor.gotoAndPlay(1);
      }
   }
}

