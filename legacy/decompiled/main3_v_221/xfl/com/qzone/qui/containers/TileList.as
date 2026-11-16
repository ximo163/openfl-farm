package com.qzone.qui.containers
{
   import com.qzone.qui.containers.tileClasses.TileBase;
   import com.qzone.qui.containers.tileClasses.TileButton;
   import com.qzone.qui.events.ScrollEvent;
   import com.qzone.qui.skins.ListDefaultSkin;
   import com.qzone.utils.DisplayUtil;
   import flash.display.DisplayObject;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   
   public class TileList extends TileBase
   {
      
      private var maxGrop:int;
      
      protected var groupChild:Array = [];
      
      private var scrolled:Boolean;
      
      protected var groupInfo:Array = [];
      
      public function TileList()
      {
         super();
         _width = 100;
         _height = 100;
         defaultSkin = ListDefaultSkin.skin;
         itemRenderer = TileButton;
      }
      
      override protected function rebuild() : void
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:Object = null;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         if(!tileWidth || !tileHeight)
         {
            throw new Error("TileList 需要设置 tileWidth 和 tileHeight 数值。");
         }
         removeAll();
         if(content != null)
         {
            while(content.numChildren > 0)
            {
               content.removeChildAt(0);
            }
         }
         _childrenWidth = 0;
         _childrenHeight = 0;
         this.groupChild = [];
         this.groupInfo = [];
         this.maxGrop = 0;
         if(Boolean(_data) && Boolean(content))
         {
            _loc1_ = int(_data.length);
            _loc7_ = 0;
            while(_loc7_ < _loc1_)
            {
               if(this.groupInfo.length == 0 || this.groupInfo[_loc5_].y + this.groupInfo[_loc5_].height < _scrollRect.y + _scrollRect.height)
               {
                  _loc6_ = new itemRenderer();
               }
               else
               {
                  _loc6_ = new Point();
               }
               _childArray[_loc7_] = _loc6_;
               _loc2_ = int(int(tileWidth) || int(_loc6_.width));
               _loc3_ = int(int(tileHeight) || int(_loc6_.height));
               if(!this.maxGrop)
               {
                  _loc8_ = Math.floor((_width - paddingH) / (_loc2_ + gapH));
                  _loc9_ = Math.ceil(_loc1_ / _loc8_);
                  this.maxGrop = _loc8_;
               }
               _loc4_ = _loc7_ % _loc8_;
               _loc5_ = Math.floor(_loc7_ / _loc8_);
               _loc6_.x = paddingH + _loc2_ * _loc4_ + gapH * _loc4_;
               _loc6_.y = paddingV + _loc3_ * _loc5_ + gapV * _loc5_;
               if(this.groupInfo[_loc5_] == null)
               {
                  this.groupInfo[_loc5_] = new Rectangle(0,_loc6_.y,0,_loc3_);
                  this.groupChild[_loc5_] = {};
               }
               this.groupChild[_loc5_][_loc4_] = _loc6_;
               _loc7_++;
            }
            _childrenWidth = paddingH + _loc8_ * (_loc2_ + gapH) - gapH;
            _childrenHeight = paddingV + _loc9_ * (_loc3_ + gapV) - gapV;
         }
         this.scrolled = true;
         this.layout();
         onRebuildComplete();
      }
      
      override protected function layout() : void
      {
         var _loc1_:DisplayObject = null;
         var _loc2_:Object = null;
         var _loc3_:* = undefined;
         var _loc4_:int = 0;
         for(_loc3_ in this.groupInfo)
         {
            if(this.groupInfo[_loc3_].y + this.groupInfo[_loc3_].height > _scrollRect.y && this.groupInfo[_loc3_].y < _scrollRect.y + _scrollRect.height)
            {
               for(_loc2_ in this.groupChild[_loc3_])
               {
                  _loc1_ = this.groupChild[_loc3_][_loc2_] as DisplayObject;
                  if(_loc1_ == null)
                  {
                     _loc1_ = new itemRenderer();
                     DisplayUtil.copyProperties(this.groupChild[_loc3_][_loc2_],_loc1_,["x","y"]);
                     this.groupChild[_loc3_][_loc2_] = _loc1_;
                     _loc4_ = 0;
                     while(_loc4_ < _childArray.length)
                     {
                        if(_childArray[_loc4_] is itemRenderer == false)
                        {
                           _childArray[_loc4_] = _loc1_;
                           break;
                        }
                        _loc4_++;
                     }
                  }
                  if(_loc1_.parent == null)
                  {
                     _loc1_[dataField] = _data[_loc2_ + _loc3_ * this.maxGrop];
                     eventHandle(_loc1_);
                     content.addChild(_loc1_);
                  }
               }
            }
            else
            {
               for(_loc2_ in this.groupChild[_loc3_])
               {
                  _loc1_ = this.groupChild[_loc3_][_loc2_] as DisplayObject;
                  if(_loc1_)
                  {
                     eventHandle(_loc1_,"removeEventListener");
                     DisplayUtil.removeChild(content,_loc1_);
                     _loc1_[dataField] = null;
                  }
               }
            }
         }
         if(this.scrolled)
         {
            validateNow();
            this.scrolled = false;
         }
      }
      
      override protected function onScrollChange(param1:ScrollEvent) : void
      {
         this.layout();
      }
   }
}

