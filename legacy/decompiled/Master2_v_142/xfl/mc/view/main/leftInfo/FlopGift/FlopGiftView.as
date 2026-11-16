package mc.view.main.leftInfo.FlopGift
{
   import cn.snowkit.containers.Pane;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import mc.events.CommonEvent;
   import mc.model.MData;
   import mc.model.MainData;
   import mc.view.farm.toolBar.ToolBase;
   import mc.view.main.leftInfo.FebruaryGift.FebruaryGiftView;
   import mc.view.main.tip.TipControl;
   
   public class FlopGiftView extends Sprite
   {
      
      private var _flopData:FlopGiftData;
      
      private var _contain:Pane;
      
      private var _flopControl:FlopGiftControl;
      
      private var onlyOne:Boolean = true;
      
      private var _febGift:FebruaryGiftView;
      
      private var _flopIcon:ToolBase;
      
      public function FlopGiftView()
      {
         super();
         this._febGift = new FebruaryGiftView();
         this._flopData = FlopGiftData.gi();
         this._flopControl = new FlopGiftControl();
         this._flopData.addEventListener(FlopGiftControl.FLOPDATA,this.getFlopData);
         this._flopData.addEventListener(FlopGiftControl.HAVEFLOPDATA,this.hasFlopData);
         this._flopData.addEventListener(FlopGiftControl.FLOP_ICON_CLICK,this.getFlopClickData);
      }
      
      private function flopClick(param1:MouseEvent) : void
      {
         if(this._flopData.canClickIcon)
         {
            this._flopData.flopIconClick();
            this._flopData.canClickIcon = false;
         }
      }
      
      private function flopOver(param1:MouseEvent) : void
      {
         TipControl.show("MouseTip",(param1.currentTarget as ToolBase).tipText);
      }
      
      private function getFlopData(param1:CommonEvent) : void
      {
         var _loc2_:Object = param1.data.data;
         if(_loc2_.hasOwnProperty("bonus"))
         {
            if(_loc2_["bonus"] != 0)
            {
               this._flopData.flopGetGift = _loc2_["days"];
            }
         }
         if(_loc2_.hasOwnProperty("days"))
         {
            this._flopData.flopDate = _loc2_["days"];
         }
         if(_loc2_.hasOwnProperty("number"))
         {
            this._flopControl.hasFlopTime(_loc2_["number"]);
         }
         this._febGift.init(this._contain);
      }
      
      private function hasFlopData(param1:CommonEvent) : void
      {
         var _loc2_:Object = param1.data;
         if(_loc2_["number"] != 0 || this._flopData.flopGetGift != 0)
         {
            this.flopIcon(true);
         }
         else
         {
            this.flopIcon(false);
         }
      }
      
      private function flopIcon(param1:Boolean) : void
      {
         if(param1)
         {
            if(this._flopIcon == null)
            {
               this._flopIcon = new FlopGiftIcon();
               this._flopIcon.tipText = "点击签到赢奖励";
               this._flopIcon.y = 6;
               this._flopIcon.addEventListener(MouseEvent.CLICK,this.flopClick,false,0,true);
               this._flopIcon.addEventListener(MouseEvent.ROLL_OVER,this.flopOver,false,0,true);
               this._flopIcon.addEventListener(MouseEvent.MOUSE_OUT,this.flopOut,false,0,true);
               this._contain.appendChild(this._flopIcon);
            }
         }
         else if(this._flopIcon != null)
         {
            this._contain.removeChild(this._flopIcon);
            this._flopIcon = null;
         }
         MData.getInstance().mainData.dispatchEvent(new Event(MainData.FLOP_ICON_COMPLETE));
      }
      
      public function init(param1:Pane) : void
      {
         this._contain = param1;
         this._flopData.getIsFlop();
      }
      
      private function flopOut(param1:MouseEvent) : void
      {
         TipControl.hide();
      }
      
      private function getFlopClickData(param1:CommonEvent) : void
      {
         var _loc2_:Object = param1.data.data;
         if(_loc2_.hasOwnProperty("bonus"))
         {
            if(_loc2_["bonus"] != 0)
            {
               this._flopData.flopGetGift = _loc2_["days"];
            }
         }
         if(_loc2_.hasOwnProperty("days"))
         {
            this._flopData.flopDate = _loc2_["days"];
         }
         if(_loc2_.hasOwnProperty("number"))
         {
            this._flopControl.hasFlopToWin(_loc2_["number"]);
         }
      }
   }
}

