package mc.view.main.window.diy
{
   import com.minutes.ui.collections.LipiBox;
   import flash.display.Sprite;
   import mc.view.main.window.diy.Diy.CurrentDiy;
   import mc.view.main.window.diy.Diy.MyDiy;
   
   public class DiyTile extends Sprite
   {
      
      private var _myDiy:MyDiy;
      
      private var tile:LipiBox;
      
      private var _data:Array;
      
      private var _currentDiy:CurrentDiy;
      
      public function DiyTile()
      {
         super();
         this.tile = new LipiBox();
         this.tile.y = 0;
         this.tile.width = 480;
         this.tile.height = 320;
         this.tile.bgAlpha = 0;
         addChild(this.tile);
      }
      
      private function myDiy() : void
      {
         var _loc2_:String = null;
         this._myDiy = new MyDiy();
         this._myDiy.y = 178;
         var _loc1_:Array = new Array();
         for(_loc2_ in this._data)
         {
            if(this._data[_loc2_].hasOwnProperty("yellowtype"))
            {
               if(this._data[_loc2_].yellowtype == 0)
               {
                  _loc1_.push(this._data[_loc2_]);
               }
            }
         }
         if(_loc1_.length == 0)
         {
            _loc1_ = this._data;
         }
         this._myDiy.data = _loc1_;
         this.tile.addChild(this._myDiy);
      }
      
      public function get dataList() : Array
      {
         return this._data;
      }
      
      private function init() : void
      {
         this.currentDiy();
         this.myDiy();
      }
      
      public function set dataList(param1:Array) : void
      {
         this.tile.removeAll();
         this._data = param1;
         this.init();
      }
      
      private function currentDiy() : void
      {
         var _loc1_:String = null;
         this._currentDiy = new CurrentDiy();
         this._currentDiy.y = 0;
         for(_loc1_ in this._data)
         {
            if(this._data[_loc1_].status == 1)
            {
               this._currentDiy.data = [this._data[_loc1_]];
               if(this._data[_loc1_].hasOwnProperty("yellowtype"))
               {
                  if(this._data[_loc1_].yellowtype >= 1)
                  {
                     this._currentDiy.setLVDiy(true);
                  }
                  else
                  {
                     this._currentDiy.setLVDiy(false);
                  }
               }
               break;
            }
         }
         this.tile.addChild(this._currentDiy);
      }
   }
}

