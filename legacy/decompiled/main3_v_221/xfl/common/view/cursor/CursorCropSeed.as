package common.view.cursor
{
   import com.qzone.utils.DisplayUtil;
   import common.Consts;
   import common.Settings;
   import common.misc.Utils;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   
   public class CursorCropSeed extends MovieClip
   {
      
      private var _cursor:Sprite;
      
      public function CursorCropSeed()
      {
         super();
         this._cursor = null;
      }
      
      public function set cursorArgument(param1:String) : void
      {
         if(param1 == null || param1 == "")
         {
            return;
         }
         var _loc2_:Array = param1.split(",");
         if(_loc2_ == null || _loc2_.length < 2)
         {
            return;
         }
         var _loc3_:String = _loc2_[0];
         var _loc4_:int = parseInt(_loc2_[1]);
         var _loc5_:String = "";
         if(_loc3_ == Consts.ITEM_TYPE_SEED)
         {
            _loc5_ = Settings.getInstance().getSeedName(_loc4_);
         }
         else if(_loc3_ == Consts.ITEM_TYPE_FISH)
         {
            _loc5_ = Settings.getInstance().getFishName(_loc4_);
         }
         if(_loc5_ == "")
         {
            return;
         }
         this._cursor = Utils.getMaterial(_loc5_) as Sprite;
         if(this._cursor == null)
         {
            return;
         }
         this._cursor.cacheAsBitmap = true;
         DisplayUtil.disableMouse(this._cursor);
         addChild(this._cursor);
      }
   }
}

