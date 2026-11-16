package mc.view.main.floating
{
   import flash.display.Sprite;
   
   public class FloatingBase extends Sprite
   {
      
      private var _fid:int = -1;
      
      public function FloatingBase()
      {
         super();
      }
      
      public function get fid() : int
      {
         return this._fid;
      }
      
      public function start() : void
      {
      }
      
      public function set fid(param1:int) : void
      {
         this._fid = param1;
      }
   }
}

