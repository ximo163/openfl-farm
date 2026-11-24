package com.qzone.qui.controls
{
   import com.qzone.qui.controls.listClasses.ListBase;
   import com.qzone.qui.controls.listClasses.ListItemRenderer;
   import com.qzone.qui.controls.scrollClasses.ScrollPolicy;
   import com.qzone.qui.skins.ListDefaultSkin;
   import com.qzone.qui.styles.Style;
   import com.qzone.utils.DisplayUtil;
   import flash.display.DisplayObject;
   
   public class List extends ListBase
   {
      
      public var effect:Object;
      
      protected var _skin:DisplayObject;
      
      public var defaultSkin:Class;
      
      public function List(param1:Number = 100, param2:Number = 100)
      {
         super();
         paddingV = Style.listPaddingV;
         paddingH = Style.listPaddingH;
         borderSizeV = Style.listBorderSizeV;
         borderSizeH = Style.listBorderSizeH;
         _width = param1;
         _height = param2;
         _hScrollPolicy = ScrollPolicy.OFF;
         this.defaultSkin = ListDefaultSkin.skin;
         itemRenderer = ListItemRenderer;
      }
      
      override protected function init() : void
      {
         super.init();
      }
      
      override protected function setSize() : void
      {
         if(_added)
         {
            super.setSize();
            if(this._skin)
            {
               this._skin.width = _width;
               this._skin.height = _height;
            }
         }
      }
      
      override protected function setSkin() : void
      {
         if(this._skin)
         {
            DisplayUtil.removeChild(this,this._skin);
         }
         this._skin = new this.defaultSkin();
         this.addChildAt(this._skin,0);
         _added && this.setSize();
      }
   }
}

