package mc.view.main.cursor
{
   import common.MaterialLib;
   import flash.display.MovieClip;
   
   public class Cursor_ShengChan extends BaseCursor
   {
      
      private var _cursor:MovieClip;
      
      public function Cursor_ShengChan()
      {
         super();
         this._cursor = MaterialLib.getInstance().getMaterial("CursorPesticide") as MovieClip;
         this._cursor.cacheAsBitmap = true;
         addChild(this._cursor);
         this.cacheAsBitmap = true;
      }
      
      override public function click() : void
      {
         this._cursor.gotoAndPlay(2);
      }
   }
}

