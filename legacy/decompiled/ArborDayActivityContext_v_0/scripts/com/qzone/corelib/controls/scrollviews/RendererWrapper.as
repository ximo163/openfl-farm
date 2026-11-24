package com.qzone.corelib.controls.scrollviews
{
   import com.qzone.corelib.controls.interfaces.IRenderer;
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   
   public class RendererWrapper extends Sprite
   {
      
      public static var scrolling:Boolean = false;
      
      private var _data:Object = null;
      
      private var _index:int = 0;
      
      private var _dataIndex:int = 0;
      
      private var _renderer:IRenderer = null;
      
      public function RendererWrapper(param1:Class)
      {
         super();
         this._renderer = new param1() as IRenderer;
         if(this._renderer is DisplayObject)
         {
            addChild(this._renderer as DisplayObject);
            if(this.width == 0 || this.height == 0)
            {
               throw new ArgumentError(this._renderer + "高度或者宽度为0，这样会导致布局控件的遮罩宽高计算错误！");
            }
            return;
         }
         throw new ArgumentError(param1 + "必须实现IRenderer接口，并且继承显示对象类！");
      }
      
      public function get data() : Object
      {
         return this._data;
      }
      
      public function set data(param1:Object) : void
      {
         this._data = param1;
         this._renderer.data = param1;
      }
      
      public function get index() : int
      {
         return this._index;
      }
      
      public function set index(param1:int) : void
      {
         this._index = param1;
      }
      
      public function get dataIndex() : int
      {
         return this._dataIndex;
      }
      
      public function set dataIndex(param1:int) : void
      {
         this._dataIndex = param1;
      }
      
      override public function get height() : Number
      {
         return DisplayObject(this._renderer).height;
      }
      
      override public function get width() : Number
      {
         return DisplayObject(this._renderer).width;
      }
      
      public function get renderer() : IRenderer
      {
         return this._renderer;
      }
   }
}

