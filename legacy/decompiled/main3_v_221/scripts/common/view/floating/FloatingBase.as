package common.view.floating
{
   import events.FloatingEvent;
   import flash.display.Sprite;
   import interfaces.IMsgCenter;
   
   public class FloatingBase extends Sprite
   {
      
      private static var ID_COUNTER:int = 0;
      
      private var _fid:int;
      
      private var m_msgCenter:IMsgCenter;
      
      protected var _data:Object;
      
      private var _name:String;
      
      public function FloatingBase(param1:IMsgCenter)
      {
         super();
         this.m_msgCenter = param1;
         this._fid = ID_COUNTER++;
         this._name = "";
      }
      
      public function get fid() : int
      {
         return this._fid;
      }
      
      public function get floatName() : String
      {
         return this._name;
      }
      
      public function set floatName(param1:String) : void
      {
         this._name = param1;
      }
      
      public function start(param1:Object) : void
      {
         if(param1 == null)
         {
            return;
         }
         this._data = param1;
         if(param1["x"] != undefined)
         {
            x = parseInt(param1["x"]);
         }
         if(param1["y"] != undefined)
         {
            y = parseInt(param1["y"]);
         }
      }
      
      protected function close() : void
      {
         var _loc1_:FloatingEvent = new FloatingEvent(FloatingEvent.FLOATING_CLOSE);
         _loc1_.floating = this._name;
         _loc1_.fid = this._fid;
         if(this.m_msgCenter != null)
         {
            this.m_msgCenter.dispatchEvent(_loc1_);
         }
      }
      
      public function set fid(param1:int) : void
      {
         this._fid = param1;
      }
      
      public function end() : void
      {
      }
   }
}

