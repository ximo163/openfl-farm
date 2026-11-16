package mc.view.main.cursor
{
   import common.MaterialLib;
   import flash.display.MovieClip;
   
   public class CursorAPI extends BaseCursor
   {
      
      private var _cursor:MovieClip;
      
      public function CursorAPI(param1:String = null)
      {
         super();
         this._cursor = MaterialLib.getInstance().getMaterial(param1) as MovieClip;
         this._cursor.cacheAsBitmap = true;
         addChild(this._cursor);
      }
      
      override public function click() : void
      {
         this._cursor.gotoAndPlay(2);
      }
      
      override public function set cursorArgument(param1:Object) : void
      {
         super.cursorArgument = param1;
      }
   }
}

