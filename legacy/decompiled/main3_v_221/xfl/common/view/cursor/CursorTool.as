package common.view.cursor
{
   import common.Consts;
   import common.misc.Utils;
   import flash.display.MovieClip;
   
   public dynamic class CursorTool extends MovieClip
   {
      
      private var m_cursor:MovieClip;
      
      public function CursorTool()
      {
         super();
         this.m_cursor = null;
      }
      
      override public function gotoAndPlay(param1:Object, param2:String = null) : void
      {
         if(this.m_cursor != null)
         {
            this.m_cursor.gotoAndPlay(param1);
         }
      }
      
      override public function gotoAndStop(param1:Object, param2:String = null) : void
      {
         if(this.m_cursor != null)
         {
            this.m_cursor.gotoAndStop(param1);
         }
      }
      
      public function set cursorArgument(param1:String) : void
      {
         if(param1 == null || param1 == "")
         {
            return;
         }
         var _loc2_:Array = param1.split(",");
         if(_loc2_.length != 2)
         {
            return;
         }
         var _loc3_:String = "CursorTool2" + _loc2_[1];
         if(_loc2_[1] >= Consts.ORGANIC_FERTILIZER_ID)
         {
            _loc3_ = "CursorTool3" + (_loc2_[1] - Consts.ORGANIC_FERTILIZER_ID);
         }
         if(_loc2_[0] == Consts.ITEM_TYPE_FISHFEED)
         {
            _loc3_ = "Cursor_FishFood_" + _loc2_[1];
         }
         this.m_cursor = Utils.getMaterial(_loc3_) as MovieClip;
         if(this.m_cursor == null)
         {
            return;
         }
         this.m_cursor.cacheAsBitmap = true;
         addChild(this.m_cursor);
      }
   }
}

