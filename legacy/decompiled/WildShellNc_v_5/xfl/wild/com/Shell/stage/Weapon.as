package wild.com.Shell.stage
{
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import wild.com.Shell.command.CmdAPI;
   
   public class Weapon extends Sprite
   {
      
      private var _data:Object;
      
      public var attackInfo:Object;
      
      public function Weapon(param1:String, param2:Object)
      {
         super();
         this._data = param2;
         var _loc3_:IBeastAPI = CmdAPI.getInstance().api;
         addChild(_loc3_.getMaterial(param1 + "_Over_" + this._data["id"]) as MovieClip);
         this.cacheAsBitmap = true;
         this.mouseChildren = false;
      }
      
      public function get data() : Object
      {
         return this._data;
      }
   }
}

