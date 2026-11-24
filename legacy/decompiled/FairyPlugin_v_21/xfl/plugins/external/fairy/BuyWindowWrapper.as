package plugins.external.fairy
{
   import com.greensock.TweenLite;
   import com.qzone.allianceActivity.common.utils.StylesManager;
   import common.Session;
   import entities.Player;
   import events.CommonEvent;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.events.EventDispatcher;
   import flash.events.MouseEvent;
   import flash.net.URLRequest;
   import flash.net.navigateToURL;
   
   public class BuyWindowWrapper extends EventDispatcher
   {
      
      private var _selected:int;
      
      private var _price:int;
      
      private var _winCls:Class = BuyWindowWrapper__winCls;
      
      private var _index:int;
      
      private var _btnOkEnable:Boolean = true;
      
      private var _win:MovieClip;
      
      public function BuyWindowWrapper()
      {
         super();
         this._selected = 0;
         this._price = 600;
      }
      
      private function updatePrice() : void
      {
         var _loc4_:Player = null;
         var _loc1_:int = 1;
         if(this._selected == 0)
         {
            _loc1_ = 1;
         }
         else if(this._selected == 1)
         {
            _loc1_ = 6;
         }
         else
         {
            _loc1_ = 12;
         }
         if(this._index == 3)
         {
            _loc4_ = Session.getInstance().host;
            if(_loc4_._yellowstatus > 0 && _loc4_._yellowlevel > 0)
            {
               this._win["vip"].visible = true;
               this._win["vip"]["xfBtn"].buttonMode = true;
               this._win["vip"]["xfBtn"].addEventListener(MouseEvent.CLICK,this.onClick,false,0,true);
               this._win["normal"].visible = false;
               this._btnOkEnable = true;
               this._win["btnOK"].filters = [];
            }
            else
            {
               this._win["vip"].visible = false;
               this._win["normal"].visible = true;
               this._win["normal"]["ktBtn"].buttonMode = true;
               this._win["normal"]["ktBtn"].addEventListener(MouseEvent.CLICK,this.onClick,false,0,true);
               this._btnOkEnable = false;
               this._win["btnOK"].filters = StylesManager.getGrayFilter();
            }
         }
         else
         {
            this._btnOkEnable = true;
            this._win["btnOK"].filters = [];
         }
         var _loc2_:int = _loc1_ * this._price;
         this._win["tfPrice"].text = _loc2_.toString();
         this._win["tfPrice1"].text = int(_loc2_ * 0.8).toString();
         var _loc3_:int = this._index == 3 ? 750 : 600;
         this._win["discount"]["tp0"].text = _loc2_.toString();
         this._win["discount"]["tp1"].text = (_loc1_ * _loc3_).toString();
         this._win["discount"]["tp2"].text = int(_loc2_ * 0.8).toString();
         this._win["discount"]["tp3"].text = int(_loc1_ * _loc3_ * 0.8).toString();
         if(this._index == 3)
         {
            this._win["xhDiscount"]["tp2"].text = int(_loc2_ * 0.8).toString();
            this._win["xhDiscount"]["tp3"].text = int(_loc1_ * _loc3_ * 0.8).toString();
         }
      }
      
      public function show(param1:int, param2:DisplayObjectContainer, param3:int) : void
      {
         if(param2 == null)
         {
            return;
         }
         if(param1 < 0 || param1 > 3)
         {
            return;
         }
         this._index = param1;
         var _loc4_:int = param1 == 3 ? 750 : 600;
         if(param3 == 1)
         {
            this._price = _loc4_ * 0.4;
         }
         else if(param3 == 2)
         {
            this._price = _loc4_ * 0.5;
         }
         else if(param3 == 3)
         {
            this._price = _loc4_ * 0.6;
         }
         else if(param3 == 4)
         {
            this._price = _loc4_ * 0.8;
         }
         if(this._win == null)
         {
            this._win = new this._winCls() as MovieClip;
            this._win["btn0"].gotoAndStop(2);
            this._win["btn0"].mouseChildren = false;
            this._win["btn0"].buttonMode = true;
            this._selected = 0;
            this._win["btn1"].stop();
            this._win["btn1"].mouseChildren = false;
            this._win["btn1"].buttonMode = true;
            this._win["btn2"].stop();
            this._win["btn2"].mouseChildren = false;
            this._win["btn2"].buttonMode = true;
            this._win["discount_mask"].visible = false;
            if(param3 == 0)
            {
               this._win["discount"].visible = false;
               this._win["flag7"].visible = false;
            }
            else
            {
               this._win["flag7"].gotoAndStop(param3);
            }
            this._win.addEventListener(MouseEvent.CLICK,this.onClicked,false,0,true);
         }
         this._win.gotoAndStop(param1 + 1);
         this.updatePrice();
         this._win.alpha = 0;
         this._win.x = (param2.width - this._win.width) * 0.5;
         this._win.y = (param2.height - this._win.height) * 0.5 - 20;
         param2.addChild(this._win);
         param2.addEventListener(MouseEvent.CLICK,this.disableParentMouse,true,0,true);
         TweenLite.to(this._win,0.33,{
            "alpha":1,
            "y":(param2.height - this._win.height) * 0.5
         });
      }
      
      private function onClicked(param1:MouseEvent) : void
      {
         var _loc2_:int = 0;
         if(param1.target.name == "btn0")
         {
            this._win["btn0"].gotoAndStop(2);
            this._win["btn1"].gotoAndStop(1);
            this._win["btn2"].gotoAndStop(1);
            this._selected = 0;
            this.updatePrice();
         }
         else if(param1.target.name == "btn1")
         {
            this._win["btn0"].gotoAndStop(1);
            this._win["btn1"].gotoAndStop(2);
            this._win["btn2"].gotoAndStop(1);
            this._selected = 1;
            this.updatePrice();
         }
         else if(param1.target.name == "btn2")
         {
            this._win["btn0"].gotoAndStop(1);
            this._win["btn1"].gotoAndStop(1);
            this._win["btn2"].gotoAndStop(2);
            this._selected = 2;
            this.updatePrice();
         }
         else if(param1.target.name == "btnOK")
         {
            if(!this._btnOkEnable)
            {
               return;
            }
            this.hide();
            _loc2_ = 1;
            if(this._selected == 0)
            {
               _loc2_ = 1;
            }
            else if(this._selected == 1)
            {
               _loc2_ = 6;
            }
            else
            {
               _loc2_ = 12;
            }
            dispatchEvent(new CommonEvent("buy",{
               "index":this._win.currentFrame - 1,
               "month":_loc2_
            }));
         }
         else if(param1.target.name == "btnCancel")
         {
            this.hide();
         }
         param1.stopImmediatePropagation();
      }
      
      private function disableParentMouse(param1:MouseEvent) : void
      {
         if(param1.target.name != "btn0" && param1.target.name != "btn1" && param1.target.name != "btn2" && param1.target.name != "btnOK" && param1.target.name != "btnCancel" && param1.target.name != "xfBtn" && param1.target.name != "ktBtn")
         {
            param1.stopImmediatePropagation();
            return;
         }
      }
      
      private function onClick(param1:MouseEvent) : void
      {
         navigateToURL(new URLRequest(""),"_bank");
      }
      
      public function hide() : void
      {
         var onCompleted:Function = null;
         onCompleted = function():void
         {
            _win.parent.removeEventListener(MouseEvent.CLICK,disableParentMouse,true);
            _win.parent.removeChild(_win);
         };
         if(this._win == null || this._win.parent == null)
         {
            return;
         }
         TweenLite.to(this._win,0.33,{
            "alpha":0,
            "onComplete":onCompleted
         });
      }
   }
}

