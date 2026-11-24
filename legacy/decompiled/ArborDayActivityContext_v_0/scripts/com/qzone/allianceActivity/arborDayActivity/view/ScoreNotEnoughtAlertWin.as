package com.qzone.allianceActivity.arborDayActivity.view
{
   import com.qzone.allianceActivity.ArborDayScoreAlertPanelView;
   import com.qzone.allianceActivity.arborDayActivity.model.ArborDayConsts;
   import com.qzone.allianceActivity.arborDayActivity.model.ArborDayDataModel;
   import com.qzone.allianceActivity.framewrok.MVCFacade;
   import com.qzone.allianceActivity.framewrok.controller.CommandController;
   import com.qzone.allianceActivity.framewrok.events.MVCEvent;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class ScoreNotEnoughtAlertWin extends Sprite
   {
      
      public var mediator:ArborDayMediator = MVCFacade.getInstance().getObj(ArborDayConsts.ARBORDAY_MEDIATOR);
      
      public var dataModel:ArborDayDataModel = MVCFacade.getInstance().getObj(ArborDayConsts.ARBORDAY_MODEL);
      
      public var cmdController:CommandController = MVCFacade.getInstance().commandController;
      
      private var _view:MovieClip;
      
      private var _closeBtn:SimpleButton;
      
      private var _buyPresentBtn:MovieClip;
      
      public function ScoreNotEnoughtAlertWin()
      {
         super();
         this.initialize();
      }
      
      private function initialize() : void
      {
         var _loc1_:MovieClipButtonInteraction = null;
         this._view = new ArborDayScoreAlertPanelView();
         if(this._view)
         {
            this._buyPresentBtn = this._view.buyPresentBtn;
            this._closeBtn = this._view.closeBtn;
            addChild(this._view);
            _loc1_ = new MovieClipButtonInteraction(this._buyPresentBtn);
            switch(this.dataModel.appId)
            {
               case ArborDayConsts.NC_APPID:
                  _loc1_.label = "购买农场礼包";
                  break;
               case ArborDayConsts.MC_APPID:
                  _loc1_.label = "购买牧场礼包";
                  break;
               case ArborDayConsts.CT_APPID:
                  _loc1_.label = "购买餐厅礼包";
                  break;
               case ArborDayConsts.QS_APPID:
                  _loc1_.label = "购买超市礼包";
            }
            this._buyPresentBtn.addEventListener(MouseEvent.CLICK,this.buyPresentBtnClickHandler);
            this._closeBtn.addEventListener(MouseEvent.CLICK,this.closeBtnClickHandler);
         }
      }
      
      private function buyPresentBtnClickHandler(param1:Event) : void
      {
         var _loc2_:MVCEvent = new MVCEvent(ArborDayConsts.BUY_PRESENT_CMD);
         this.cmdController.executeCommand(_loc2_);
         this.dataModel.reportClick(ArborDayConsts.BUY_GIFT_BTN + "_in_snaw");
         this.mediator.closeWin(this);
      }
      
      private function closeBtnClickHandler(param1:Event) : void
      {
         this.mediator.closeWin(this);
      }
   }
}

