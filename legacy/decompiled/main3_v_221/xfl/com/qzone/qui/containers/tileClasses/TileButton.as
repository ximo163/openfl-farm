package com.qzone.qui.containers.tileClasses
{
   import com.qzone.qui.controls.Button;
   
   public class TileButton extends Button
   {
      
      public var labelField:String = "label";
      
      private var _data:Object;
      
      public function TileButton()
      {
         super();
         _width = 44;
         _resized = true;
      }
      
      public function set data(param1:Object) : void
      {
         this._data = param1;
         if(this._data.hasOwnProperty(this.labelField))
         {
            text = this._data[this.labelField];
         }
         else
         {
            text = this._data.toString();
         }
         toolTip = text;
      }
      
      public function get data() : Object
      {
         return this._data;
      }
   }
}

