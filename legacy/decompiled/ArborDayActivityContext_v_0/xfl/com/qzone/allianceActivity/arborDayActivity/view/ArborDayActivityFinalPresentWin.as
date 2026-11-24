package com.qzone.allianceActivity.arborDayActivity.view
{
   import com.qzone.allianceActivity.ArborDayFinalPresentPanelView;
   import com.qzone.allianceActivity.arborDayActivity.model.ArborDayConsts;
   import com.qzone.allianceActivity.arborDayActivity.model.ArborDayDataModel;
   import com.qzone.allianceActivity.framewrok.MVCFacade;
   import com.qzone.allianceActivity.framewrok.utils.TextFieldUtil;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   
   public class ArborDayActivityFinalPresentWin extends Sprite
   {
      
      public var mediator:ArborDayMediator = MVCFacade.getInstance().getObj(ArborDayConsts.ARBORDAY_MEDIATOR);
      
      public var dataModel:ArborDayDataModel = MVCFacade.getInstance().getObj(ArborDayConsts.ARBORDAY_MODEL);
      
      private var _view:MovieClip;
      
      private var _closeBtn:SimpleButton;
      
      private var _getScoreBtn:SimpleButton;
      
      public function ArborDayActivityFinalPresentWin()
      {
         super();
         this.initialize();
      }
      
      private function initialize() : void
      {
         this._view = new ArborDayFinalPresentPanelView();
         if(this._view)
         {
            this._view.stop();
            this._closeBtn = this._view.closeBtn;
            this._getScoreBtn = this._view.getScoreBtn;
            this._getScoreBtn.visible = false;
            addChild(this._view);
            this._getScoreBtn.addEventListener(MouseEvent.CLICK,this.getScoreBtnClickHandler);
            this._view.addEventListener(Event.ADDED_TO_STAGE,this.addToStageHandler);
            this._closeBtn.addEventListener(MouseEvent.CLICK,this.closeBtnClickHandler);
         }
      }
      
      private function addToStageHandler(param1:Event) : void
      {
         if(this.dataModel.alreadyGetFinalPresent)
         {
            this.showSuccessState();
         }
         else
         {
            this.showFaultState();
         }
      }
      
      private function closeBtnClickHandler(param1:Event) : void
      {
         this.mediator.closeWin(this);
      }
      
      private function getScoreBtnClickHandler(param1:Event) : void
      {
         this.mediator.closeWin(this);
         this.mediator.showDetailWin();
      }
      
      public function showSuccessState() : void
      {
         this._getScoreBtn.visible = false;
         this._view.gotoAndStop(2);
         this.dataModel.reportClick(ArborDayConsts.MORE_SCORE_BTN + "_in_fpw");
      }
      
      public function showFaultState() : void
      {
         this._getScoreBtn.visible = true;
         this._view.gotoAndPlay(1);
         var _loc1_:TextField = this._view.faultMsgTf;
         var _loc2_:Array = [];
         if(!this.dataModel.alreadyGetCtPresent)
         {
            _loc2_.push("餐厅");
         }
         if(!this.dataModel.alreadyGetMcPresent)
         {
            _loc2_.push("牧场");
         }
         if(!this.dataModel.alreadyGetNcPresent)
         {
            _loc2_.push("农场");
         }
         if(!this.dataModel.alreadyGetQsPresent)
         {
            _loc2_.push("超市");
         }
         var _loc3_:String = "对不起，您" + _loc2_.join("、") + "的“环保礼包”还未领取，请赚取积分或" + "直接购买“环保礼包”。";
         TextFieldUtil.refreshText(_loc1_,_loc3_);
      }
   }
}

