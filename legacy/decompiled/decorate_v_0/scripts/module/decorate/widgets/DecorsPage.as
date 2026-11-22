package module.decorate.widgets
{
   import com.qzone.qui.containers.Canvas;
   import com.qzone.qui.controls.Label;
   import com.qzone.qui.controls.scrollClasses.ScrollPolicy;
   import com.qzone.qui.utils.TextFormatUtil;
   import com.qzone.utils.GraphicsUtil;
   import common.Consts;
   import common.Language;
   import common.view.window.WindowLabelMaker;
   import entities.DecorateItem;
   import flash.display.DisplayObjectContainer;
   import flash.display.Sprite;
   import flash.geom.Rectangle;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import flash.text.TextFormatAlign;
   import flash.utils.Dictionary;
   import framework.base.BasePage;
   import module.decorate.DecorateView;
   
   public class DecorsPage extends BasePage
   {
      
      private var _alreadyBuyedCanvas:Canvas;
      
      private var _alreadyBuyedContainer:DisplayObjectContainer;
      
      private var _currentDecorateContainer:DisplayObjectContainer;
      
      private var _currentDecorateCanvas:Canvas;
      
      public function DecorsPage(param1:DecorateView, param2:int, param3:int)
      {
         super(param1,param2,param3);
         this.createTopBanner();
         this._currentDecorateContainer = new Sprite();
         this._currentDecorateCanvas = new Canvas();
         this._currentDecorateCanvas.y = 65;
         this._currentDecorateCanvas.height = 80;
         this._currentDecorateCanvas.width = param2 - 4;
         this._currentDecorateCanvas.defaultSkin = null;
         this._currentDecorateCanvas.horizontalScrollPolicy = ScrollPolicy.OFF;
         this._currentDecorateCanvas.verticalScrollPolicy = ScrollPolicy.OFF;
         this._currentDecorateCanvas.content = this._currentDecorateContainer;
         addChild(this._currentDecorateCanvas);
         this._alreadyBuyedContainer = new Sprite();
         this._alreadyBuyedCanvas = new Canvas();
         this._alreadyBuyedCanvas.y = 188;
         this._alreadyBuyedCanvas.height = 160;
         this._alreadyBuyedCanvas.width = param2 - 4;
         this._alreadyBuyedCanvas.defaultSkin = null;
         this._alreadyBuyedCanvas.horizontalScrollPolicy = ScrollPolicy.OFF;
         this._alreadyBuyedCanvas.content = this._alreadyBuyedContainer;
         addChild(this._alreadyBuyedCanvas);
         this.addText();
      }
      
      private function arrangeItems(param1:DisplayObjectContainer) : void
      {
         var _loc2_:int = 15;
         var _loc3_:DecorRenderItem = null;
         var _loc4_:int = 20;
         var _loc5_:int = 90;
         var _loc6_:int = 160;
         var _loc7_:int = 230;
         var _loc8_:int = 300;
         var _loc9_:int = 12;
         var _loc10_:int = 12;
         var _loc11_:int = 12;
         var _loc12_:int = 12;
         var _loc13_:int = 12;
         var _loc14_:int = param1.numChildren;
         var _loc15_:int = 0;
         for(; _loc15_ < _loc14_; _loc15_++)
         {
            _loc3_ = param1.getChildAt(_loc15_) as DecorRenderItem;
            if(!(_loc3_ != null && _loc3_.data != null))
            {
               continue;
            }
            switch(_loc3_.data._type)
            {
               case 1:
                  _loc3_.x = _loc4_;
                  _loc3_.y = _loc9_;
                  _loc9_ += 60 + _loc2_;
                  break;
               case 2:
                  _loc3_.x = _loc5_;
                  _loc3_.y = _loc10_;
                  _loc10_ += 60 + _loc2_;
                  break;
               case 3:
                  _loc3_.x = _loc6_;
                  _loc3_.y = _loc11_;
                  _loc11_ += 60 + _loc2_;
                  break;
               case 4:
                  _loc3_.x = _loc7_;
                  _loc3_.y = _loc12_;
                  _loc12_ += 60 + _loc2_;
                  break;
               case 8:
                  _loc3_.x = _loc8_;
                  _loc3_.y = _loc13_;
                  _loc13_ += 60 + _loc2_;
            }
         }
         this._alreadyBuyedCanvas.validateNow();
      }
      
      private function clearContainer(param1:DisplayObjectContainer) : void
      {
         if(!param1)
         {
            return;
         }
         while(param1.numChildren > 0)
         {
            param1.removeChildAt(0);
         }
      }
      
      private function createTopBanner() : void
      {
         var _loc1_:int = 23;
         var _loc2_:TextField = this.addTypeTitle(Language.L["背景"]);
         _loc2_.x = 0;
         _loc2_.y = _loc1_;
         var _loc3_:TextField = this.addTypeTitle(Language.L["房子"]);
         _loc3_.x = 70;
         _loc3_.y = _loc1_;
         var _loc4_:TextField = this.addTypeTitle(Language.L["狗窝"]);
         _loc4_.x = 210;
         _loc4_.y = _loc1_;
         var _loc5_:TextField = this.addTypeTitle(Language.L["栅栏"]);
         _loc5_.x = 140;
         _loc5_.y = _loc1_;
         var _loc6_:TextField = this.addTypeTitle(Language.L["狗"]);
         _loc6_.x = 280;
         _loc6_.y = _loc1_;
      }
      
      override protected function onCreateTile() : void
      {
         if(_tile != null && contains(_tile) == true)
         {
            removeChild(_tile);
         }
      }
      
      private function getChildItemByID(param1:int) : DecorRenderItem
      {
         var _loc4_:DecorRenderItem = null;
         var _loc2_:int = this._alreadyBuyedContainer.numChildren;
         var _loc3_:int = 0;
         while(_loc3_ < _loc2_)
         {
            _loc4_ = this._alreadyBuyedContainer.getChildAt(_loc3_) as DecorRenderItem;
            if(_loc4_ != null)
            {
               if(_loc4_.data._id == param1)
               {
                  return _loc4_;
               }
            }
            _loc3_++;
         }
         return null;
      }
      
      private function addTypeTitle(param1:String) : TextField
      {
         var _loc2_:TextField = new TextField();
         _loc2_.text = param1;
         _loc2_.selectable = false;
         _loc2_.setTextFormat(new TextFormat("Verdana",14,39423,null,null,null,null,null,TextFormatAlign.CENTER));
         _loc2_.width = 100;
         _loc2_.height = 25;
         addChild(_loc2_);
         return _loc2_;
      }
      
      private function getHeadDecoChildItemByID(param1:int) : DecorHeadRenderItem
      {
         var _loc4_:DecorHeadRenderItem = null;
         var _loc2_:int = this._currentDecorateContainer.numChildren;
         var _loc3_:int = 0;
         while(_loc3_ < _loc2_)
         {
            _loc4_ = this._currentDecorateContainer.getChildAt(_loc3_) as DecorHeadRenderItem;
            if(_loc4_ != null)
            {
               if(_loc4_.data._id == param1)
               {
                  return _loc4_;
               }
            }
            _loc3_++;
         }
         return null;
      }
      
      private function addText() : void
      {
         var _loc1_:Label = new Label();
         _loc1_.mouseChildren = true;
         _loc1_.width = _preferedWidth + 16;
         WindowLabelMaker.addTarget(_loc1_);
         _loc1_.textDefaultFormat = TextFormatUtil.clone(_loc1_.textDefaultFormat);
         _loc1_.textDefaultFormat.color = 11171584;
         _loc1_.text = "点击\"已装饰\"装扮，即可将它隐藏。再次点击，即可重新装扮。";
         _loc1_.x = 1;
         _loc1_.y = 0;
         addChild(_loc1_);
         var _loc2_:Label = new Label();
         _loc2_.mouseChildren = false;
         _loc2_.width = _preferedWidth - 5;
         GraphicsUtil.draw(_loc2_,7855615,1,null,true);
         GraphicsUtil.hLine(_loc2_,7855615,1,new Rectangle(0,_loc2_.height,_loc2_.width));
         _loc2_.textDefaultFormat.align = "center";
         _loc2_.text = "当前装饰";
         _loc2_.x = 3;
         _loc2_.y = 45;
         addChild(_loc2_);
         var _loc3_:Label = new Label();
         _loc3_.mouseChildren = false;
         _loc3_.width = _preferedWidth - 5;
         GraphicsUtil.draw(_loc3_,7855615,1,null,true);
         GraphicsUtil.hLine(_loc3_,7855615,1,new Rectangle(0,_loc3_.height,_loc3_.width));
         _loc3_.textDefaultFormat.align = "center";
         _loc3_.text = "已购买装饰";
         _loc3_.x = 3;
         _loc3_.y = 166;
         addChild(_loc3_);
      }
      
      public function forceRefresh(param1:int, param2:int) : void
      {
         var _loc3_:int = this._currentDecorateContainer.numChildren;
         var _loc4_:DecorHeadRenderItem = null;
         var _loc5_:DecorateItem = null;
         var _loc6_:int = 0;
         while(_loc6_ < _loc3_)
         {
            _loc4_ = this._currentDecorateContainer.getChildAt(_loc6_) as DecorHeadRenderItem;
            if(_loc4_ != null && _loc4_.data != null)
            {
               _loc5_ = _loc4_.data as DecorateItem;
               if(_loc5_._id == param2 && _loc5_._type == param1)
               {
                  _loc4_.toggleDecorated();
                  break;
               }
            }
            _loc6_++;
         }
         var _loc7_:DecorRenderItem = this.getChildItemByID(param2);
         if(_loc7_ != null)
         {
            _loc7_.toggleDecorated();
         }
         _loc7_ = this.getChildItemByID(-1);
         if(_loc7_ != null)
         {
            _loc7_.toggleDecorated();
         }
      }
      
      private function removeAll() : void
      {
         this.clearContainer(this._currentDecorateContainer);
         this.clearContainer(this._alreadyBuyedContainer);
      }
      
      private function refreshBelow(param1:Array) : void
      {
         var _loc3_:DecorateItem = null;
         if(param1 == null || param1.length == 0)
         {
            return;
         }
         var _loc2_:DecorRenderItem = null;
         for each(_loc3_ in param1)
         {
            _loc2_ = this.getChildItemByID(_loc3_._id);
            if(_loc2_ != null)
            {
               _loc2_.toggleDecorated();
            }
         }
      }
      
      public function buildDecorateList(param1:Dictionary) : void
      {
         var _loc2_:Array = null;
         var _loc3_:DecorHeadRenderItem = null;
         var _loc4_:DecorRenderItem = null;
         var _loc5_:DecorateItem = null;
         var _loc6_:DecorateItem = null;
         this.removeAll();
         if(param1 == null)
         {
            return;
         }
         _loc2_ = param1[0] as Array;
         for each(_loc5_ in _loc2_)
         {
            _loc3_ = new DecorHeadRenderItem();
            _loc3_.data = _loc5_;
            this._currentDecorateContainer.addChild(_loc3_);
         }
         _loc2_ = param1[1] as Array;
         for each(_loc6_ in _loc2_)
         {
            _loc4_ = new DecorRenderItem();
            _loc4_.data = _loc6_;
            this._alreadyBuyedContainer.addChild(_loc4_);
         }
         this.arrangeItems(this._currentDecorateContainer);
         this.arrangeItems(this._alreadyBuyedContainer);
      }
      
      public function refresh(param1:Dictionary) : void
      {
         var _loc2_:Array = param1[0] as Array;
         this.initCurrentDivChildCache(_loc2_);
         this.arrangeItems(this._currentDecorateContainer);
         _loc2_ = param1[1] as Array;
         this.refreshBelow(_loc2_);
      }
      
      private function initCurrentDivChildCache(param1:Array) : Boolean
      {
         var _loc3_:DecorHeadRenderItem = null;
         var _loc4_:DecorateItem = null;
         var _loc6_:Boolean = false;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc9_:DecorHeadRenderItem = null;
         var _loc2_:Boolean = false;
         var _loc5_:int = 0;
         while(_loc5_ < param1.length)
         {
            _loc4_ = param1[_loc5_] as DecorateItem;
            if(_loc4_._type != Consts.DECOR_BILLBOARD)
            {
               _loc6_ = true;
               _loc7_ = this._currentDecorateContainer.numChildren;
               if(_loc7_ > 0)
               {
                  _loc8_ = 0;
                  while(_loc8_ < _loc7_)
                  {
                     _loc9_ = this._currentDecorateContainer.getChildAt(_loc8_) as DecorHeadRenderItem;
                     if(_loc9_)
                     {
                        if(_loc9_.data._type == _loc4_._type)
                        {
                           _loc9_.data = _loc4_;
                           _loc6_ = false;
                           break;
                        }
                     }
                     _loc8_++;
                  }
                  if(_loc5_ > _loc7_)
                  {
                     _loc3_ = new DecorHeadRenderItem();
                     _loc3_.data = _loc4_;
                     if(_loc4_._status == 1)
                     {
                        this._currentDecorateContainer.addChild(_loc3_);
                     }
                  }
               }
               if(_loc6_)
               {
                  _loc2_ = true;
                  _loc3_ = new DecorHeadRenderItem();
                  _loc3_.data = _loc4_;
                  if(_loc4_._status == 1)
                  {
                     this._currentDecorateContainer.addChild(_loc3_);
                  }
               }
            }
            _loc5_++;
         }
         return _loc2_;
      }
   }
}

