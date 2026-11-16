package com.qzone.qui.controls.scrollClasses
{
   import com.qzone.qui.core.Direction;
   import com.qzone.qui.makers.ButtonMaker;
   import com.qzone.qui.styles.Style;
   import com.qzone.utils.AlignUtil;
   import flash.display.Sprite;
   
   public class ScrollThumb extends Sprite
   {
      
      private var _direction:String;
      
      private var pos2Prop:String;
      
      private var len2Prop:String;
      
      protected var thumbIconSkin:Class;
      
      private var thumbIcon:Sprite;
      
      private var lenProp:String;
      
      protected var thumbSkin:Class;
      
      private var thumb:Sprite;
      
      private var posProp:String;
      
      private var _scrollBar:ScrollBar;
      
      public function ScrollThumb(param1:ScrollBar, param2:Class, param3:Class, param4:String)
      {
         super();
         if(param4 == Direction.VERTICAL)
         {
            this.lenProp = "height";
            this.posProp = "y";
            this.len2Prop = "width";
            this.pos2Prop = "x";
         }
         else if(param4 == Direction.HORIZONTAL)
         {
            this.lenProp = "width";
            this.posProp = "x";
            this.len2Prop = "height";
            this.pos2Prop = "y";
         }
         this._scrollBar = param1;
         this.thumbSkin = param2;
         this.thumbIconSkin = param3;
      }
      
      protected function setSkin() : void
      {
         this.thumb = new this.thumbSkin();
         ButtonMaker.addTarget(this.thumb);
         this.thumb.useHandCursor = false;
         this.thumb.tabEnabled = false;
         this.addChild(this.thumb);
         this.thumbIcon = new this.thumbIconSkin();
         this.thumbIcon.mouseEnabled = false;
         this.addChild(this.thumbIcon);
      }
      
      public function setThumbSize(param1:int) : void
      {
         if(this.thumb == null)
         {
            this.setSkin();
         }
         if(param1 >= Style.ScrollBarMinSize)
         {
            this.thumb[this.lenProp] = param1;
            this.thumb.visible = true;
            if(param1 <= Style.ScrollBarMinIconSize)
            {
               this.thumbIcon.visible = false;
            }
            else
            {
               this.thumbIcon[this.posProp] = this.thumb[this.posProp] + Math.floor(AlignUtil.middle(this.thumb[this.lenProp],this.thumbIcon[this.lenProp]));
               this.thumbIcon[this.pos2Prop] = Math.floor(AlignUtil.middle(this.thumb[this.len2Prop],this.thumbIcon[this.len2Prop]));
               this.thumbIcon.visible = true;
            }
         }
      }
   }
}

