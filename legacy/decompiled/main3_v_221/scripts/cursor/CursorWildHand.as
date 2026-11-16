package cursor
{
   import com.qzone.utils.DisplayUtil;
   import common.misc.Utils;
   import flash.display.MovieClip;
   
   public class CursorWildHand extends MovieClip
   {
      
      private var _cursor:MovieClip;
      
      public function CursorWildHand()
      {
         super();
      }
      
      public function click() : void
      {
         this._cursor.gotoAndPlay(2);
      }
      
      public function set cursorArgument(param1:String) : void
      {
         var _loc2_:String = param1;
         this._cursor = Utils.getMaterial(_loc2_) as MovieClip;
         this._cursor.cacheAsBitmap = true;
         this.cacheAsBitmap = true;
         DisplayUtil.disableMouse(this._cursor);
         addChild(this._cursor);
      }
   }
}

