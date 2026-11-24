package com.qzone.allianceActivity.collectingActivity.view
{
   import com.qzone.allianceActivity.collectingActivity.model.CollectingConsts;
   import com.qzone.allianceActivity.framewrok.MVCFacade;
   import com.qzone.allianceActivity.interfaces.IAllianceAppHelper;
   import flash.display.DisplayObjectContainer;
   import flash.display.SimpleButton;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.system.ApplicationDomain;
   import flash.text.TextField;
   
   public class BuyItemQDWindow
   {
      
      private var _price:int;
      
      private var _yellow:int;
      
      private var _class:Class = BuyItemQDWindow__class;
      
      private var _id:int;
      
      private var _api:IAllianceAppHelper;
      
      private var _win:Sprite;
      
      public function BuyItemQDWindow(param1:IAllianceAppHelper)
      {
         super();
         this._api = param1;
      }
      
      public function show(param1:int, param2:int, param3:int) : void
      {
         var _loc8_:Class = null;
         this._id = param1;
         this._price = param2;
         this._yellow = param3;
         var _loc4_:Sprite = null;
         if(ApplicationDomain.currentDomain.hasDefinition("Crop_" + param1 + "_Seed") == true)
         {
            _loc8_ = ApplicationDomain.currentDomain.getDefinition("Crop_" + param1 + "_Seed") as Class;
            if(_loc8_ != null)
            {
               _loc4_ = new _loc8_() as Sprite;
            }
         }
         if(this._win == null)
         {
            this._win = new this._class() as Sprite;
            (this._win["tfNumber"] as TextField).restrict = "0-9";
            (this._win["tfNumber"] as TextField).maxChars = 2;
            (this._win["tfNumber"] as TextField).addEventListener(Event.CHANGE,this.onNumberChanged,false,0,true);
            this._win.addEventListener(MouseEvent.CLICK,this.onMouseEvent,false,0,true);
         }
         this._win["tfNumber"].text = "1";
         this.onNumberChanged(null);
         var _loc5_:DisplayObjectContainer = this._win["holder"] as DisplayObjectContainer;
         var _loc6_:Sprite = null;
         var _loc7_:int = 0;
         while(_loc7_ < _loc5_.numChildren)
         {
            _loc6_ = _loc5_.getChildAt(_loc7_) as Sprite;
            if(_loc6_ != null)
            {
               _loc5_.removeChild(_loc6_);
            }
            _loc7_++;
         }
         if(_loc4_ != null)
         {
            _loc4_.scaleX = 1.45;
            _loc4_.scaleY = 1.45;
            _loc4_.x = (65 - _loc4_.width) * 0.5;
            _loc4_.y = (65 - _loc4_.height) * 0.5;
            _loc5_.addChild(_loc4_);
         }
         this._api.popupWindow(this._win);
      }
      
      public function destroy() : void
      {
         if(this._win != null)
         {
            this._api.removePopup(this._win);
            this._win = null;
         }
      }
      
      private function onNumberChanged(param1:Event) : void
      {
         var _loc2_:int = parseInt((this._win["tfNumber"] as TextField).text);
         if(_loc2_ == 0)
         {
            _loc2_ = 1;
            this._win["tfNumber"].text = "1";
         }
         this._win["tfQD1"].text = this._yellow * _loc2_ + " 元宝";
         this._win["tfQD2"].text = this._price * _loc2_ + " 元宝";
      }
      
      private function onMouseEvent(param1:MouseEvent) : void
      {
         var _loc4_:Mediator = null;
         var _loc2_:SimpleButton = param1.target as SimpleButton;
         if(_loc2_ == null)
         {
            return;
         }
         var _loc3_:int = 0;
         switch(_loc2_.name)
         {
            case "btnClose":
            case "btnCancel":
               this.destroy();
               break;
            case "btnBuy":
               _loc3_ = parseInt(this._win["tfNumber"].text);
               if(_loc3_ == 0)
               {
                  break;
               }
               _loc4_ = MVCFacade.getInstance().getObj(CollectingConsts.MEDIATOR) as Mediator;
               _loc4_.buySeed(this._id,_loc3_);
               break;
            case "btnLeft":
               _loc3_ = parseInt(this._win["tfNumber"].text);
               if(_loc3_ == 1)
               {
                  break;
               }
               _loc3_ = Math.max(0,_loc3_ - 1);
               this._win["tfNumber"].text = _loc3_;
               this.onNumberChanged(null);
               break;
            case "btnRight":
               _loc3_ = parseInt(this._win["tfNumber"].text);
               if(_loc3_ == 99)
               {
                  break;
               }
               _loc3_ = Math.min(99,_loc3_ + 1);
               this._win["tfNumber"].text = _loc3_;
               this.onNumberChanged(null);
         }
      }
   }
}

