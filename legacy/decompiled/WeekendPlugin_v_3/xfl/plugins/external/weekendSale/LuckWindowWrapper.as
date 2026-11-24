package plugins.external.weekendSale
{
   import events.CommonEvent;
   import flash.display.SimpleButton;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   
   public class LuckWindowWrapper
   {
      
      private var _win:Sprite;
      
      private var _index:int;
      
      private var _Class:Class = LuckWindowWrapper__Class;
      
      private var _control:WeekendPlugin;
      
      public function LuckWindowWrapper(param1:WeekendPlugin)
      {
         super();
         this._control = param1;
         this._index = 0;
      }
      
      public function hide() : void
      {
         this._control.api.hidePopUp(this._win);
      }
      
      private function onClicked(param1:MouseEvent) : void
      {
         var _loc2_:SimpleButton = param1.target as SimpleButton;
         if(_loc2_ == null)
         {
            return;
         }
         if(_loc2_.name == "btnBuy")
         {
            this._control.api.messageCenter.addEventListener("AddBuyItem",this.onCardsBought,false,0,true);
            this._control.api.messageCenter.dispatchEvent(new CommonEvent("ShowBuySeed",{
               "id":34,
               "type":"item"
            }));
         }
         else if(_loc2_.name == "btnUse")
         {
            this._control.model.refreshFactor(this._index);
            this.hide();
            this._control.showRefreshEffect(this._index);
         }
         else if(_loc2_.name == "btnClose")
         {
            this.hide();
         }
         else if(_loc2_.name == "openYellowVIP")
         {
            this._control.openYellowVIP();
         }
      }
      
      private function updateUI(param1:int, param2:Boolean) : void
      {
         if(param1 == 0)
         {
            this._win["tfLeft"].text = "现有0张";
            this._win["btnUse"].visible = false;
            this._win["btnBuy"].visible = true;
         }
         else
         {
            this._win["tfLeft"].text = "现有" + param1 + "张";
            this._win["btnUse"].visible = true;
            this._win["btnBuy"].visible = false;
         }
      }
      
      private function onCardsBought(param1:CommonEvent) : void
      {
         var e:CommonEvent = param1;
         if(e == null || e.data == null)
         {
            return;
         }
         e.target.removeEventListener(e.type,this.onCardsBought);
         if(e.data["type"].toString() == "3")
         {
            this._control.model.loadCards();
            this._control.model.addEventListener(WeekendSaleModel.DATA_CARD_LOADED,function(param1:CommonEvent):void
            {
               param1.target.removeEventListener(param1.type,arguments.callee);
               updateUI(param1.data["cards"],param1.data["free"]);
            });
         }
      }
      
      public function show(param1:int, param2:int, param3:Boolean) : void
      {
         if(this._win == null)
         {
            this._win = new this._Class() as Sprite;
            this._win.addEventListener(MouseEvent.CLICK,this.onClicked,false,0,true);
         }
         this.updateUI(param2,param3);
         this._index = param1;
         this._control.api.showPopUp(this._win,true);
      }
   }
}

