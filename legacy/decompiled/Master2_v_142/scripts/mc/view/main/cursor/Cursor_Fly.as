package mc.view.main.cursor
{
   import common.MaterialLib;
   import flash.display.MovieClip;
   
   public class Cursor_Fly extends BaseCursor
   {
      
      private var _cursor:MovieClip;
      
      public function Cursor_Fly()
      {
         super();
         this._cursor = MaterialLib.getInstance().getMaterial("CursorFly") as MovieClip;
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

