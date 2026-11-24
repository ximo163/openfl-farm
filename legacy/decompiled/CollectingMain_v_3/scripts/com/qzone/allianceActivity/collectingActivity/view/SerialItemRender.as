package com.qzone.allianceActivity.collectingActivity.view
{
   import com.qzone.allianceActivity.collectingActivity.model.CollectingConsts;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.filters.GlowFilter;
   
   public class SerialItemRender extends Sprite
   {
      
      private static const _filter:GlowFilter = new GlowFilter(16777215,1,6,6,3);
      
      private var _class:Class = SerialItemRender__class;
      
      private var _bmp:Bitmap;
      
      private var _data:Object;
      
      private var _render:MovieClip;
      
      public function SerialItemRender()
      {
         super();
         this._data = null;
         mouseChildren = false;
         buttonMode = true;
      }
      
      public function hilightBorder(param1:Boolean) : void
      {
         if(param1 == true)
         {
            this.filters = [_filter];
         }
         else
         {
            if(this._data != null && parseInt(this._data["collected"]) == parseInt(this._data["sum"]))
            {
               this._render["gray"].visible = false;
            }
            else
            {
               this._render["gray"].visible = true;
            }
            this.filters = null;
         }
      }
      
      public function hide() : void
      {
         if(this._render != null)
         {
            if(this._bmp != null)
            {
               this._bmp.bitmapData = null;
            }
            this._render.visible = false;
         }
      }
      
      public function get serial() : int
      {
         if(this._data == null || this._data["id"] == undefined)
         {
            return 0;
         }
         return this._data["id"];
      }
      
      public function get sum() : int
      {
         if(this._data == null || this._data["sum"] == undefined)
         {
            return 0;
         }
         return this._data["sum"] as int;
      }
      
      public function set friends(param1:int) : void
      {
         if(this._data != null)
         {
            this._data["friends"] = param1;
            if(param1 > 0)
            {
               this._render["tfName"].text = this._data["friends"] + "个好友完成";
            }
            else
            {
               this._render["tfName"].text = "尚无好友完成";
            }
         }
      }
      
      public function set collected(param1:int) : void
      {
         if(this._data != null)
         {
            this._data["collected"] = param1;
         }
         if(param1 == this._data["sum"])
         {
            this._render["gray"].visible = false;
         }
      }
      
      private function render() : void
      {
         if(this._render == null)
         {
            this._render = new this._class() as MovieClip;
            addChild(this._render);
         }
         else
         {
            this._render.visible = true;
         }
         var _loc1_:BitmapData = SerialsCache.getInstance().getSerialIconFromCache(this._data["id"] as int);
         this.icon = _loc1_;
         this._render.gotoAndStop(this._data["id"] >= CollectingConsts.NORMAL_SERIAL_START ? 2 : 1);
         this._render["tfName0"].text = this._data["name"];
         this._render["tfName"].text = "";
         if(this._data["collected"] > 0 && this._data["collected"] == this._data["sum"])
         {
            this._render["gray"].visible = false;
         }
         else
         {
            this._render["gray"].visible = true;
         }
      }
      
      public function get data() : Object
      {
         return this._data;
      }
      
      public function destroy() : void
      {
         if(this._bmp != null)
         {
            this._bmp.bitmapData = null;
            this._bmp = null;
         }
         if(this._render != null)
         {
            removeChild(this._render);
            this._render = null;
         }
         this._data = null;
      }
      
      public function set data(param1:Object) : void
      {
         this._data = param1;
         if(this._data == null)
         {
            this.hide();
         }
         else
         {
            this.render();
         }
      }
      
      public function set icon(param1:BitmapData) : void
      {
         var _loc2_:DisplayObjectContainer = null;
         if(param1 == null)
         {
            return;
         }
         if(this._bmp == null)
         {
            this._bmp = new Bitmap(param1,"auto",true);
         }
         else
         {
            this._bmp.bitmapData = param1;
         }
         if(this._render != null)
         {
            _loc2_ = this._render["holder"] as DisplayObjectContainer;
            while(_loc2_.numChildren > 0)
            {
               _loc2_.removeChildAt(0);
            }
            this._render["holder"].addChild(this._bmp);
            this._bmp.x = (50 - this._bmp.width) * 0.5;
            this._bmp.y = (50 - this._bmp.height) * 0.5;
         }
      }
   }
}

