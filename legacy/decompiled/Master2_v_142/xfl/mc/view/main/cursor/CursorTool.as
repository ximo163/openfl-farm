package mc.view.main.cursor
{
   import common.MaterialLib;
   import flash.display.*;
   
   public class CursorTool extends BaseCursor
   {
      
      private var _cursor:MovieClip;
      
      public function CursorTool()
      {
         super();
         this.cacheAsBitmap = true;
      }
      
      override public function click() : void
      {
         this._cursor.gotoAndPlay(2);
      }
      
      override public function set cursorArgument(param1:Object) : void
      {
         var _loc2_:String = null;
         var _loc3_:Number = NaN;
         var _loc4_:Sprite = null;
         super.cursorArgument = param1;
         if(param1["type"] != 9)
         {
            _loc2_ = "CursorTool_" + param1["type"] + "_" + param1["tId"];
            this._cursor = MaterialLib.getInstance().getMaterial(_loc2_) as MovieClip;
            this._cursor.cacheAsBitmap = true;
         }
         else
         {
            this._cursor = new MovieClip();
            if(param1.hasOwnProperty("cId"))
            {
               _loc3_ = Number(param1["cId"]);
            }
            else if(param1.hasOwnProperty("tId"))
            {
               _loc3_ = Number(param1["tId"]);
            }
            _loc4_ = MaterialLib.getInstance().getMaterial("Animal_" + _loc3_ + "_1") as Sprite;
            this._cursor.addChild(_loc4_.getChildAt(0));
         }
         addChild(this._cursor);
      }
   }
}

