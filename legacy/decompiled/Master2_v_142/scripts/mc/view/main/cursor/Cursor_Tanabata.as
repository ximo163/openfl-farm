package mc.view.main.cursor
{
   import common.MaterialLib;
   import flash.display.MovieClip;
   
   public class Cursor_Tanabata extends BaseCursor
   {
      
      private var _cursor:MovieClip;
      
      public function Cursor_Tanabata()
      {
         super();
         this._cursor = new (MaterialLib.getInstance().getClass("cusor_tanabata") as Class)();
         this._cursor.cacheAsBitmap = true;
         addChild(this._cursor);
         this.cacheAsBitmap = true;
      }
   }
}

