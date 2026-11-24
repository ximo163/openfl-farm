package plugins.external.promotions
{
   import common.Consts;
   import common.view.MaterialProxy;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.filters.ColorMatrixFilter;
   import flash.net.URLRequest;
   import flash.net.navigateToURL;
   import flash.text.TextField;
   import flash.utils.Dictionary;
   import promotions.ItemRenderer;
   import promotoins.MainWnd;
   
   public class MainWindowWrapper
   {
      
      private var _advPackItemContainer:DisplayObjectContainer;
      
      private var _normalGiftItemCollection:Array;
      
      private var _advBuyBtn:SimpleButton;
      
      private var _itemRendererPool:Array = new Array();
      
      private var _normalPriceItem:MovieClip;
      
      private var _win:MovieClip;
      
      private var _closeBtn:SimpleButton;
      
      private var _control:PromotionsPlugin;
      
      private const ITEM_DISPLAY_PADDING:int = 3;
      
      private var _normalBuyBtn:SimpleButton;
      
      private var _advPackItemCollection:Array;
      
      private var _normalPackItemContainer:DisplayObjectContainer;
      
      private var _normalPackItemCollection:Array;
      
      private var _currentAdvPackData:PromotionsPackData;
      
      private var _itemTipsMap:Dictionary = new Dictionary(true);
      
      private var _materialProxyPool:Array = new Array();
      
      private var _advGiftItemContainer:DisplayObjectContainer;
      
      private var _currentNormalPackData:PromotionsPackData;
      
      private var _linkBtn1:SimpleButton;
      
      private var _linkBtn2:SimpleButton;
      
      private var _title:MovieClip;
      
      private var _isVipState:Boolean = false;
      
      private var _advPriceItem:MovieClip;
      
      private var _frame:MovieClip;
      
      private var _advGiftItemCollection:Array;
      
      private var _normalGiftItemContainer:DisplayObjectContainer;
      
      public function MainWindowWrapper(param1:PromotionsPlugin)
      {
         super();
         this._control = param1;
      }
      
      private function removeItemShowTipsListener(param1:DisplayObject) : void
      {
         param1.removeEventListener(MouseEvent.MOUSE_OVER,this.itemMouseOverHandler);
         param1.removeEventListener(MouseEvent.MOUSE_OUT,this.itemMouseOutHandler);
      }
      
      private function closeBtnClickHandler(param1:Event) : void
      {
         this.hide();
      }
      
      public function createItemRenderer() : ItemRenderer
      {
         if(this._itemRendererPool.length > 0)
         {
            return this._itemRendererPool.pop();
         }
         return new ItemRenderer();
      }
      
      private function itemMouseOutHandler(param1:Event) : void
      {
         this._control.api.hideMouseTip();
      }
      
      private function changeTitle() : void
      {
         if(this._isVipState)
         {
            this._title.gotoAndStop(2);
            this._frame.gotoAndStop(2);
         }
         else
         {
            this._title.gotoAndStop(1);
            this._frame.gotoAndStop(1);
         }
      }
      
      private function changePriceState(param1:PromotionsPackData, param2:MovieClip) : void
      {
         var _loc3_:TextField = null;
         var _loc4_:TextField = null;
         var _loc5_:TextField = null;
         var _loc6_:TextField = null;
         if(this._isVipState)
         {
            param2.gotoAndStop(2);
            _loc4_ = param2.value2Tf;
            _loc3_ = param2.value1Tf;
            _loc4_.text = String(param1.f_price * 0.8);
            _loc3_.text = String(param1.price * 0.8);
            this._linkBtn1.visible = true;
            this._linkBtn2.visible = true;
         }
         else
         {
            param2.gotoAndStop(1);
            _loc4_ = param2.value2Tf;
            _loc3_ = param2.value1Tf;
            _loc5_ = param2.value3Tf;
            _loc6_ = param2.value4Tf;
            _loc4_.text = String(param1.f_price);
            _loc3_.text = String(param1.price);
            _loc5_.text = String(int(param1.price * 0.8));
            _loc6_.text = String(int(param1.f_price * 0.8));
            this._linkBtn1.visible = false;
            this._linkBtn2.visible = false;
         }
      }
      
      private function createItems(param1:PromotionsPackData, param2:DisplayObjectContainer, param3:DisplayObjectContainer) : Array
      {
         var _loc6_:Object = null;
         var _loc4_:Array = new Array();
         var _loc5_:Array = new Array();
         var _loc7_:Array = new Array();
         var _loc8_:Array = new Array();
         if(Boolean(param1.item) && param1.item.length > 0)
         {
            for each(_loc6_ in param1.item)
            {
               if(_loc6_.pack == 1)
               {
                  if(_loc6_.type != Consts.ITEM_TYPE_DECORATE)
                  {
                     _loc4_.push(_loc6_);
                  }
                  else
                  {
                     _loc7_.push(_loc6_);
                  }
               }
               else if(_loc6_.pack == 2)
               {
                  if(_loc6_.type != Consts.ITEM_TYPE_DECORATE)
                  {
                     _loc5_.push(_loc6_);
                  }
                  else
                  {
                     _loc8_.push(_loc6_);
                  }
               }
            }
            if(_loc7_.length > 0)
            {
               _loc7_.sortOn("id",Array.NUMERIC);
               _loc7_[0].name = this._control.model.decorName;
               _loc4_.push(_loc7_[0]);
            }
            if(_loc8_.length > 0)
            {
               _loc8_.sortOn("id",Array.NUMERIC);
               _loc8_[0].name = this._control.model.decorName;
               _loc8_.push(_loc8_[0]);
            }
         }
         var _loc9_:Array = this.posRendererItems(param2,_loc4_);
         var _loc10_:Array = this.posRendererItems(param3,_loc5_);
         return [_loc9_,_loc10_];
      }
      
      public function getGrayFilter() : Array
      {
         return [new ColorMatrixFilter([0.3086,0.6094,0.082,0,0,0.3086,0.6094,0.082,0,0,0.3086,0.6094,0.082,0,0,0,0,0,1,0])];
      }
      
      private function addItemShowTipsListener(param1:DisplayObject) : void
      {
         param1.addEventListener(MouseEvent.MOUSE_OVER,this.itemMouseOverHandler);
         param1.addEventListener(MouseEvent.MOUSE_OUT,this.itemMouseOutHandler);
      }
      
      public function hide() : void
      {
         this._control.api.hidePopUp(this._win);
         this.removeListener();
         this.clearItems();
         this._currentNormalPackData = null;
         this._currentAdvPackData = null;
      }
      
      private function posRendererItems(param1:DisplayObjectContainer, param2:Array) : Array
      {
         var _loc10_:ItemRenderer = null;
         var _loc11_:Object = null;
         var _loc14_:Array = null;
         var _loc16_:int = 0;
         var _loc17_:int = 0;
         var _loc18_:int = 0;
         var _loc3_:Number = 60;
         var _loc4_:Number = 60;
         var _loc5_:Number = param1.width;
         var _loc6_:Number = param1.height;
         var _loc7_:Number = _loc3_ * param2.length + this.ITEM_DISPLAY_PADDING * (param2.length - 1);
         var _loc8_:Number = _loc4_;
         var _loc9_:Array = new Array();
         var _loc12_:Number = 0;
         var _loc13_:Number = 0;
         if(param2.length <= 3)
         {
            _loc14_ = [param2.length];
            _loc12_ = _loc5_ / 2 - (60 * param2.length + this.ITEM_DISPLAY_PADDING * (param2.length - 1)) / 2;
            _loc13_ = _loc6_ / 2 - _loc4_ / 2;
         }
         else
         {
            if(param2.length == 4)
            {
               _loc14_ = [2,2];
            }
            else if(param2.length == 5)
            {
               _loc14_ = [2,3];
            }
            else if(param2.length == 6)
            {
               _loc14_ = [3,3];
            }
            _loc12_ = _loc5_ / 2 - (60 * _loc14_[0] + this.ITEM_DISPLAY_PADDING * (_loc14_[0] - 1)) / 2;
            _loc13_ = _loc6_ / 2 - (2 * _loc4_ + this.ITEM_DISPLAY_PADDING) / 2;
         }
         var _loc15_:int = 0;
         while(_loc15_ < _loc14_.length)
         {
            _loc16_ = int(_loc14_[_loc15_]);
            _loc12_ = _loc5_ / 2 - (60 * _loc14_[_loc15_] + this.ITEM_DISPLAY_PADDING * (_loc14_[_loc15_] - 1)) / 2;
            _loc17_ = 0;
            while(_loc17_ < _loc16_)
            {
               _loc18_ = _loc15_ == 0 ? _loc17_ : int(_loc14_[_loc15_ - 1] + _loc17_);
               _loc11_ = param2[_loc18_];
               _loc10_ = this.compItem(_loc11_);
               _loc10_.x = _loc12_;
               _loc10_.y = _loc13_;
               _loc9_.push(_loc10_);
               param1.addChild(_loc10_);
               _loc12_ += _loc3_ + this.ITEM_DISPLAY_PADDING;
               _loc17_++;
            }
            _loc13_ += _loc4_ + this.ITEM_DISPLAY_PADDING;
            _loc15_++;
         }
         return _loc9_;
      }
      
      private function itemMouseOverHandler(param1:Event) : void
      {
         var _loc2_:ItemRenderer = param1.currentTarget as ItemRenderer;
         if(Boolean(this._itemTipsMap[_loc2_]) && this._itemTipsMap[_loc2_] != "")
         {
            this._control.api.popMouseTip(this._itemTipsMap[_loc2_]);
         }
      }
      
      public function showAdvPackItems() : void
      {
         var _loc2_:Array = null;
         var _loc1_:PromotionsPackData = this._control.model.getAdvPackData(this._isVipState);
         if(Boolean(_loc1_) && this._currentAdvPackData != _loc1_)
         {
            this._currentAdvPackData = _loc1_;
            this.changePriceState(_loc1_,this._advPriceItem);
            _loc2_ = this.createItems(_loc1_,this._advPackItemContainer,this._advGiftItemContainer);
            if(this._advPackItemCollection == null)
            {
               this._advPackItemCollection = _loc2_[0];
            }
            if(this._advGiftItemCollection == null)
            {
               this._advGiftItemCollection = _loc2_[1];
            }
         }
      }
      
      public function showItems() : void
      {
         this.clearItems();
         this.changeBtnState();
         this.changeTitle();
         this.showNormalPackItems();
         this.showAdvPackItems();
      }
      
      private function linkBtnClickHandler(param1:Event) : void
      {
         navigateToURL(new URLRequest(""),"_blank");
      }
      
      private function removeListener() : void
      {
         this._closeBtn.removeEventListener(MouseEvent.CLICK,this.closeBtnClickHandler);
         this._normalBuyBtn.removeEventListener(MouseEvent.CLICK,this.buyPackBtnClickHandler);
         this._advBuyBtn.removeEventListener(MouseEvent.CLICK,this.buyPackBtnClickHandler);
         this._linkBtn1.removeEventListener(MouseEvent.CLICK,this.linkBtnClickHandler);
         this._linkBtn2.removeEventListener(MouseEvent.CLICK,this.linkBtnClickHandler);
      }
      
      private function compItem(param1:Object) : ItemRenderer
      {
         var _loc2_:ItemRenderer = null;
         var _loc3_:MaterialProxy = null;
         _loc3_ = this.createMaterialProxy();
         _loc3_.setContent(param1.type,param1.id);
         _loc2_ = this.createItemRenderer();
         _loc2_.iconContainer.addChildAt(_loc3_,0);
         _loc2_.numTf.text = String("x" + param1.num);
         this._itemTipsMap[_loc2_] = param1.name;
         this.addItemShowTipsListener(_loc2_);
         return _loc2_;
      }
      
      public function showNormalPackItems() : void
      {
         var _loc2_:Array = null;
         var _loc1_:PromotionsPackData = this._control.model.getNormalPackData(this._isVipState);
         if(Boolean(_loc1_) && this._currentNormalPackData != _loc1_)
         {
            this._currentNormalPackData = _loc1_;
            this.changePriceState(_loc1_,this._normalPriceItem);
            _loc2_ = this.createItems(_loc1_,this._normalPackItemContainer,this._normalGiftItemContainer);
            if(this._normalPackItemCollection == null)
            {
               this._normalPackItemCollection = _loc2_[0];
            }
            if(this._normalGiftItemCollection == null)
            {
               this._normalGiftItemCollection = _loc2_[1];
            }
         }
      }
      
      private function buyPackBtnClickHandler(param1:Event) : void
      {
         var _loc2_:PromotionsPackData = null;
         if(param1.currentTarget == this._normalBuyBtn)
         {
            _loc2_ = this._currentNormalPackData;
         }
         else if(param1.currentTarget == this._advBuyBtn)
         {
            _loc2_ = this._currentAdvPackData;
         }
         this._control.model.buyPack(_loc2_);
         if(_loc2_.isYellow)
         {
            if(_loc2_.type == PromotionsModel.NORMAL_PACK_TYPE)
            {
               this._control.api.reportReturnCode(PromotionsModel.CLICK_REPORT_CODE,PromotionsModel.REPORT_VALUE5);
            }
            else
            {
               this._control.api.reportReturnCode(PromotionsModel.CLICK_REPORT_CODE,PromotionsModel.REPORT_VALUE6);
            }
         }
         else if(_loc2_.type == PromotionsModel.NORMAL_PACK_TYPE)
         {
            this._control.api.reportReturnCode(PromotionsModel.CLICK_REPORT_CODE,PromotionsModel.REPORT_VALUE3);
         }
         else
         {
            this._control.api.reportReturnCode(PromotionsModel.CLICK_REPORT_CODE,PromotionsModel.REPORT_VALUE4);
         }
      }
      
      private function changeBtnState() : void
      {
         if(this._isVipState)
         {
            if(this._control.model.IsMeVip())
            {
               this._normalBuyBtn.filters = this._advBuyBtn.filters = null;
               this._normalBuyBtn.enabled = this._advBuyBtn.enabled = true;
               this._normalBuyBtn.mouseEnabled = this._advBuyBtn.mouseEnabled = true;
            }
            else
            {
               this._normalBuyBtn.filters = this._advBuyBtn.filters = this.getGrayFilter();
               this._normalBuyBtn.enabled = this._advBuyBtn.enabled = false;
               this._normalBuyBtn.mouseEnabled = this._advBuyBtn.mouseEnabled = false;
            }
         }
         else
         {
            this._normalBuyBtn.filters = this._advBuyBtn.filters = null;
            this._normalBuyBtn.enabled = this._advBuyBtn.enabled = true;
            this._normalBuyBtn.mouseEnabled = this._advBuyBtn.mouseEnabled = true;
         }
      }
      
      private function createMaterialProxy() : MaterialProxy
      {
         if(this._materialProxyPool.length > 0)
         {
            return this._materialProxyPool.pop();
         }
         return new MaterialProxy();
      }
      
      private function clearItems() : void
      {
         var _loc1_:ItemRenderer = null;
         this._itemTipsMap = new Dictionary(true);
         this._normalPackItemCollection = this._normalPackItemCollection || [];
         this._normalGiftItemCollection = this._normalGiftItemCollection || [];
         this._advPackItemCollection = this._advPackItemCollection || [];
         this._advGiftItemCollection = this._advGiftItemCollection || [];
         var _loc2_:Array = this._normalPackItemCollection.concat(this._normalGiftItemCollection);
         _loc2_ = _loc2_.concat(this._advPackItemCollection);
         _loc2_ = _loc2_.concat(this._advGiftItemCollection);
         while(_loc2_.length > 0)
         {
            _loc1_ = _loc2_.pop();
            this.removeItemShowTipsListener(_loc1_);
            if(Boolean(_loc1_) && Boolean(_loc1_.parent))
            {
               _loc1_.parent.removeChild(_loc1_);
            }
            this._itemRendererPool.push(_loc1_);
            if(this._materialProxyPool.indexOf(_loc1_) < 0)
            {
               if(_loc1_.iconContainer.numChildren > 0)
               {
                  this._materialProxyPool.push(_loc1_.iconContainer.removeChildAt(0));
               }
            }
         }
         this._normalPackItemCollection = null;
         this._normalGiftItemCollection = null;
         this._advPackItemCollection = null;
         this._advGiftItemCollection = null;
      }
      
      private function addListener() : void
      {
         this._closeBtn.addEventListener(MouseEvent.CLICK,this.closeBtnClickHandler);
         this._normalBuyBtn.addEventListener(MouseEvent.CLICK,this.buyPackBtnClickHandler);
         this._advBuyBtn.addEventListener(MouseEvent.CLICK,this.buyPackBtnClickHandler);
         this._linkBtn1.addEventListener(MouseEvent.CLICK,this.linkBtnClickHandler);
         this._linkBtn2.addEventListener(MouseEvent.CLICK,this.linkBtnClickHandler);
      }
      
      public function show(param1:Boolean) : void
      {
         if(this._win == null)
         {
            this._win = new MainWnd();
            this._title = this._win.title;
            this._title.stop();
            this._frame = this._win.frame;
            this._frame.stop();
            this._normalPackItemContainer = this._win.itemContainer1;
            this._advPackItemContainer = this._win.itemContainer3;
            this._normalGiftItemContainer = this._win.itemContainer2;
            this._advGiftItemContainer = this._win.itemContainer4;
            this._normalBuyBtn = this._win.buyBtn1;
            this._advBuyBtn = this._win.buyBtn2;
            this._closeBtn = this._win.closeBtn;
            this._normalPriceItem = this._win.priceItem1;
            this._normalPriceItem.stop();
            this._advPriceItem = this._win.priceItem2;
            this._advPriceItem.stop();
            this._linkBtn1 = this._win.linkBtn1;
            this._linkBtn2 = this._win.linkBtn2;
         }
         this._isVipState = param1;
         this.addListener();
         this.showItems();
         this._control.api.showPopUp(this._win,true);
      }
   }
}

