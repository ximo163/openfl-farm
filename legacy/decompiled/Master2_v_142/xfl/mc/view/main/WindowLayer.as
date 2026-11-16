package mc.view.main
{
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   import mc.control.ViewControl;
   import mc.events.TipEvent;
   import mc.events.WindowEvent;
   import mc.model.MData;
   import mc.model.ModelEvent;
   import mc.view.common.BaseWindow;
   import mc.view.main.WindowControl.WindowClassLib;
   import mc.view.main.cursor.Cursor;
   import mc.view.main.leftInfo.FlopGift.FlopCardsGift;
   import mc.view.main.window.diy.DiyWindow;
   import mc.view.main.window.profile.ProfileWindow;
   import mc.view.main.window.shop.ShopWindow;
   import mc.view.main.window.warehouse.WarehouseWindow;
   
   public class WindowLayer extends Sprite
   {
      
      private var animationArrayClose:Array = [];
      
      private var _shopWindow:BaseWindow;
      
      private var _profileWindow:BaseWindow;
      
      private var _warehouseWindow:WarehouseWindow;
      
      private var _flopWindow:FlopCardsGift;
      
      private var animationTimer:Timer;
      
      private var _diyWindow:BaseWindow;
      
      private var modeLayer:Sprite;
      
      private var animationArray:Array = [];
      
      private var viewControl:ViewControl;
      
      private var windowList:Object = new Object();
      
      public function WindowLayer()
      {
         super();
         addEventListener(Event.ADDED_TO_STAGE,this.addedToStage);
      }
      
      private function onMouseOver(param1:MouseEvent) : void
      {
         Cursor.useSystem(true);
      }
      
      private function closeWindow(param1:BaseWindow, param2:String) : void
      {
         var _loc3_:BaseWindow = null;
         var _loc5_:int = 0;
         if(param1 != null)
         {
            _loc3_ = param1;
         }
         else if(param2 != "")
         {
            _loc5_ = 0;
            while(_loc5_ < numChildren)
            {
               if(getChildAt(_loc5_) is BaseWindow)
               {
                  if((getChildAt(_loc5_) as BaseWindow).windowName == param2)
                  {
                     _loc3_ = getChildAt(_loc5_) as BaseWindow;
                     break;
                  }
               }
               _loc5_++;
            }
         }
         var _loc4_:Object = {};
         _loc4_["aWindow"] = _loc3_;
         _loc4_["aValue"] = 1;
         _loc4_["x"] = _loc3_.x;
         _loc4_["y"] = _loc3_.y;
         _loc4_["w"] = _loc3_.width;
         _loc4_["h"] = _loc3_.height;
         if(Boolean(_loc3_) && _loc3_.windowMode != null)
         {
            if(contains(_loc3_.windowMode))
            {
               removeChild(_loc3_.windowMode);
            }
         }
         this.animationArrayClose.push(_loc4_);
         _loc3_.removeAll();
      }
      
      private function openDiyWindow() : void
      {
         if(this._diyWindow != null)
         {
            this.openWindow(this._diyWindow);
         }
         else
         {
            this._diyWindow = new DiyWindow();
            this._diyWindow.windowName = "diy";
            this._diyWindow.x = Math.floor((stage.stageWidth - this._diyWindow.width) / 2);
            this._diyWindow.y = Math.floor((stage.stageHeight - this._diyWindow.height) / 2);
            this.openWindow(this._diyWindow);
         }
      }
      
      private function init() : void
      {
         this.animationTimer = new Timer(50);
         this.animationTimer.addEventListener(TimerEvent.TIMER,this.onTimer);
         this.animationTimer.start();
         this.viewControl = ViewControl.getInstance();
         this.viewControl.addEventListener(WindowEvent.OPEN,this.windowOpen,false,0,true);
         this.viewControl.addEventListener(WindowEvent.CLOSE,this.windowClose,false,0,true);
         stage.addEventListener(KeyboardEvent.KEY_UP,this.stageKeyUp);
         addEventListener(MouseEvent.ROLL_OVER,this.onMouseOver);
         addEventListener(MouseEvent.ROLL_OUT,this.onMouseOut);
      }
      
      private function openflopGiftWindow(param1:Object) : void
      {
         if(this._flopWindow != null)
         {
            this.openWindow(this._flopWindow);
         }
         else
         {
            this._flopWindow = new FlopCardsGift();
            this._flopWindow.windowName = "flopGiftW";
            this._flopWindow.dataList = param1;
            this._flopWindow.x = Math.floor((stage.stageWidth - this._flopWindow.width) / 2);
            this._flopWindow.y = Math.floor((stage.stageHeight - this._flopWindow.height) / 2);
            this.openWindow(this._flopWindow);
         }
      }
      
      private function openWindow(param1:BaseWindow, param2:Boolean = false, param3:WindowEvent = null) : void
      {
         var _loc5_:Object = null;
         if(param1.mode)
         {
            if(param1.windowMode == null)
            {
               param1.windowMode = new Sprite();
               param1.windowMode.graphics.beginFill(16777215,0);
               param1.windowMode.graphics.drawRect(0,0,stage.stageWidth,stage.stageHeight);
               param1.windowMode.graphics.endFill();
            }
            addChild(param1.windowMode);
         }
         if(Boolean(param3) && Boolean(param3.startX != 0) && param3.startY != 0)
         {
            param1.x = param3.startX;
            param1.y = param3.startY;
         }
         else
         {
            param1.x = Math.floor((stage.stageWidth - param1.width) / 2);
            param1.y = Math.floor((stage.stageHeight - param1.height) / 2);
         }
         if(contains(param1))
         {
            addChild(param1);
         }
         else
         {
            param1.alpha = 0;
            addChild(param1);
            _loc5_ = {};
            _loc5_["aWindow"] = param1;
            _loc5_["aValue"] = 0;
            _loc5_["x"] = param1.x;
            _loc5_["y"] = param1.y;
            _loc5_["w"] = param1.width;
            _loc5_["h"] = param1.height;
            this.animationArray.push(_loc5_);
         }
         var _loc4_:TipEvent = new TipEvent(TipEvent.TIP_HIDE);
         ViewControl.getInstance().dispatchEvent(_loc4_);
      }
      
      private function openWarehouse(param1:Boolean = false) : void
      {
         if(this._warehouseWindow != null)
         {
            this.openWindow(this._warehouseWindow);
            if(param1)
            {
               this._warehouseWindow.OkForWareHouse(1);
            }
         }
         else
         {
            this._warehouseWindow = new WarehouseWindow();
            if(stage != null)
            {
               this._warehouseWindow.x = Math.floor((stage.stageWidth - this._warehouseWindow.width) / 2);
               this._warehouseWindow.y = Math.floor((stage.stageHeight - this._warehouseWindow.height) / 2);
            }
            else
            {
               this._warehouseWindow.x = 150;
               this._warehouseWindow.y = 100;
            }
            this.openWindow(this._warehouseWindow);
            if(param1)
            {
               MData.getInstance().mainData.addEventListener("OkForWareHouse",this.OkForWareHouse,false,0,true);
            }
         }
      }
      
      private function openShop(param1:WindowEvent = null) : void
      {
         if(this._shopWindow != null)
         {
            if(param1)
            {
               this._shopWindow.data = param1.windowArgument;
            }
            this.openWindow(this._shopWindow);
            return;
         }
         this._shopWindow = new ShopWindow();
         if(param1)
         {
            this._shopWindow.data = param1.windowArgument;
         }
         if(stage != null)
         {
            this._shopWindow.x = Math.floor((stage.stageWidth - this._shopWindow.width) / 2);
            this._shopWindow.y = Math.floor((stage.stageHeight - this._shopWindow.height) / 2);
         }
         else
         {
            this._shopWindow.x = 150;
            this._shopWindow.y = 100;
         }
         this._shopWindow.windowName = "shop";
         this.openWindow(this._shopWindow);
      }
      
      private function addedToStage(param1:Event) : void
      {
         removeEventListener(Event.ADDED_TO_STAGE,this.addedToStage);
         this.init();
      }
      
      private function getWindow(param1:String) : BaseWindow
      {
         var _loc2_:BaseWindow = null;
         var _loc3_:WindowClassLib = null;
         if(param1 == "")
         {
            return null;
         }
         return new (WindowClassLib.getClass(param1))() as BaseWindow;
      }
      
      private function onMouseOut(param1:MouseEvent) : void
      {
         Cursor.useSystem(false);
      }
      
      private function windowOpen(param1:WindowEvent) : void
      {
         if(param1.windowName == "warehouse")
         {
            this.openWarehouse();
         }
         else if(param1.windowName == "shop")
         {
            this.openShop(param1);
         }
         else if(param1.windowName == "profile")
         {
            this.openProfile(int(param1.windowArgument));
         }
         else if(param1.windowName == "diy")
         {
            this.openDiyWindow();
         }
         else if(param1.windowName == "flopGift")
         {
            this.openflopGiftWindow(param1.windowArgument);
         }
         else if(param1.windowName == "sellCub")
         {
            this.openWarehouse(true);
         }
         else if(param1.window != null)
         {
            this.openWindow(param1.window,false,param1);
         }
         else
         {
            this.openWindowForName(param1.windowName,param1.windowArgument);
         }
      }
      
      private function closeAnimation() : void
      {
         var _loc3_:Object = null;
         var _loc4_:BaseWindow = null;
         if(this.animationArrayClose.length == 0)
         {
            return;
         }
         var _loc1_:Array = [];
         var _loc2_:int = 0;
         while(_loc2_ < this.animationArrayClose.length)
         {
            _loc3_ = this.animationArrayClose[_loc2_];
            _loc4_ = _loc3_["aWindow"] as BaseWindow;
            if(_loc3_["aValue"] <= 0)
            {
               _loc4_.removedFromLayer();
               if(contains(_loc4_))
               {
                  removeChild(_loc4_);
               }
            }
            else
            {
               _loc3_["aValue"] -= 0.34;
               _loc4_.alpha = _loc3_["aValue"];
               _loc4_.scaleX = _loc4_.scaleY = _loc3_["aValue"];
               _loc4_.x = Math.floor(_loc3_["x"] + (_loc3_["w"] - _loc3_["w"] * _loc3_["aValue"]) / 2);
               _loc4_.y = Math.floor(_loc3_["y"] + (_loc3_["h"] - _loc3_["h"] * _loc3_["aValue"]) / 2);
               _loc1_.push(_loc3_);
            }
            _loc2_++;
         }
         this.animationArrayClose = _loc1_;
      }
      
      private function onTimer(param1:Event) : void
      {
         this.openAnimation();
         this.closeAnimation();
      }
      
      private function windowClose(param1:WindowEvent) : void
      {
         this.closeWindow(param1.window,param1.windowName);
      }
      
      private function hasWindow(param1:String) : BaseWindow
      {
         var _loc2_:int = 0;
         while(_loc2_ < numChildren)
         {
            if(getChildAt(_loc2_) is BaseWindow)
            {
               if((getChildAt(_loc2_) as BaseWindow).windowName == param1)
               {
                  return getChildAt(_loc2_) as BaseWindow;
               }
            }
            _loc2_++;
         }
         return null;
      }
      
      private function openAnimation() : void
      {
         var _loc3_:Object = null;
         var _loc4_:BaseWindow = null;
         if(this.animationArray.length == 0)
         {
            return;
         }
         var _loc1_:Array = [];
         var _loc2_:int = 0;
         while(_loc2_ < this.animationArray.length)
         {
            _loc3_ = this.animationArray[_loc2_];
            _loc4_ = _loc3_["aWindow"] as BaseWindow;
            if(_loc3_["aValue"] >= 1)
            {
               _loc4_.alpha = 1;
               _loc4_.scaleX = _loc4_.scaleY = 1;
               _loc4_.x = _loc3_["x"];
               _loc4_.y = _loc3_["y"];
               if(_loc4_.isInit == false)
               {
                  _loc4_.isInit = true;
                  _loc4_.init();
               }
               else
               {
                  _loc4_.addAll();
               }
               _loc4_.addedToLayer();
            }
            else
            {
               _loc3_["aValue"] += 0.34;
               _loc4_.alpha = _loc3_["aValue"];
               _loc4_.scaleX = _loc4_.scaleY = _loc3_["aValue"];
               _loc4_.x = Math.floor(_loc3_["x"] + (_loc3_["w"] - _loc3_["w"] * _loc3_["aValue"]) / 2);
               _loc4_.y = Math.floor(_loc3_["y"] + (_loc3_["h"] - _loc3_["h"] * _loc3_["aValue"]) / 2);
               _loc1_.push(_loc3_);
            }
            _loc2_++;
         }
         this.animationArray = _loc1_;
      }
      
      private function OkForWareHouse(param1:ModelEvent) : void
      {
         this._warehouseWindow.OkForWareHouse(1);
      }
      
      private function openWindowForName(param1:String, param2:Object) : void
      {
         var _loc3_:BaseWindow = this.hasWindow(param1);
         if(_loc3_ == null)
         {
            _loc3_ = this.getWindow(param1);
            _loc3_.data = param2;
            this.openWindow(_loc3_);
         }
         else
         {
            _loc3_.data = param2;
            this.openWindow(_loc3_,true);
         }
      }
      
      private function stageKeyUp(param1:KeyboardEvent) : void
      {
         var _loc2_:* = 0;
         if(param1.keyCode == 13)
         {
            _loc2_ = int(numChildren - 1);
            while(_loc2_ >= 0)
            {
               if(getChildAt(_loc2_) is BaseWindow)
               {
                  (getChildAt(_loc2_) as BaseWindow).keyEnter();
                  break;
               }
               _loc2_--;
            }
         }
      }
      
      private function openProfile(param1:int) : void
      {
         if(this._profileWindow != null)
         {
            (this._profileWindow as ProfileWindow).selected = param1;
            this.openWindow(this._profileWindow);
         }
         else
         {
            this._profileWindow = new ProfileWindow();
            this._profileWindow.x = Math.floor((stage.stageWidth - this._profileWindow.width) / 2);
            this._profileWindow.y = Math.floor((stage.stageHeight - this._profileWindow.height) / 2);
            (this._profileWindow as ProfileWindow).selected = param1;
            this.openWindow(this._profileWindow);
         }
      }
   }
}

