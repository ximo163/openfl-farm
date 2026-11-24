package com.qzone.allianceActivity.arborDayActivity.view
{
   import com.qzone.allianceActivity.ArborDayMainPanelView;
   import com.qzone.allianceActivity.arborDayActivity.model.ArborDayConsts;
   import com.qzone.allianceActivity.arborDayActivity.model.ArborDayDataModel;
   import com.qzone.allianceActivity.framewrok.MVCFacade;
   import com.qzone.allianceActivity.framewrok.controller.CommandController;
   import com.qzone.allianceActivity.framewrok.events.MVCEvent;
   import com.qzone.allianceActivity.framewrok.utils.StylesManager;
   import com.qzone.allianceActivity.framewrok.utils.TextFieldUtil;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import flash.utils.Dictionary;
   
   public class ArborDayActivityWin extends Sprite
   {
      
      public var mediator:ArborDayMediator = MVCFacade.getInstance().getObj(ArborDayConsts.ARBORDAY_MEDIATOR);
      
      public var dataModel:ArborDayDataModel = MVCFacade.getInstance().getObj(ArborDayConsts.ARBORDAY_MODEL);
      
      public var commandController:CommandController;
      
      private var _view:MovieClip;
      
      private var _detailLinkBtn:SimpleButton;
      
      private var _getMoreScoreBtn:SimpleButton;
      
      private var _getRecordBtn:SimpleButton;
      
      private var _ncBtns:MovieClip;
      
      private var _mcBtns:MovieClip;
      
      private var _ctBtns:MovieClip;
      
      private var _qsBtns:MovieClip;
      
      private var _appPanel:MovieClip;
      
      private var _getFinalPresentBtn:MovieClip;
      
      private var _currentScoreTf:TextField;
      
      private var _closeBtn:SimpleButton;
      
      private var _btnAppIdMap:Dictionary;
      
      private var _toAppBtnLabels:Object;
      
      private var _appPanelBtnLabel:Object;
      
      private var _presentContentTips:MovieClip;
      
      private var _appActionBtnInteraction:MovieClipButtonInteraction;
      
      public function ArborDayActivityWin()
      {
         this.commandController = MVCFacade.getInstance().commandController;
         super();
         this.initialize();
      }
      
      public function get view() : MovieClip
      {
         return this._view;
      }
      
      private function initialize() : void
      {
         var _loc1_:Array = null;
         var _loc2_:int = 0;
         var _loc3_:Array = null;
         var _loc4_:Array = null;
         var _loc5_:MovieClipButtonInteraction = null;
         var _loc6_:* = undefined;
         this._view = new ArborDayMainPanelView();
         if(this._view)
         {
            this._getMoreScoreBtn = this._view.getMoreScoreBtn;
            this._getRecordBtn = this._view.getRecordBtn;
            this._detailLinkBtn = this._view.detailLinkBtn;
            this._ncBtns = this._view.ncMc.ncBagBtns;
            this._mcBtns = this._view.mcMc.mcBagBtns;
            this._ctBtns = this._view.ctMc.ctBagBtns;
            this._qsBtns = this._view.qsMc.qsBagBtns;
            this._getFinalPresentBtn = this._view.getFinalPresentBtn;
            this._currentScoreTf = this._view.currentScoreTf;
            this._presentContentTips = this._view.presentContentTips;
            if(Boolean(this._presentContentTips) && Boolean(this._presentContentTips.parent))
            {
               this._presentContentTips.parent.removeChild(this._presentContentTips);
            }
            this._closeBtn = this._view.closeBtn;
            _loc1_ = [{
               "x":266.65,
               "y":183.4
            },{
               "x":386.65,
               "y":183.4
            },{
               "x":507.15,
               "y":183.4
            },{
               "x":625.65,
               "y":183.4
            }];
            _loc2_ = 0;
            _loc3_ = [ArborDayConsts.NC_APPID,ArborDayConsts.MC_APPID,ArborDayConsts.CT_APPID,ArborDayConsts.QS_APPID];
            _loc4_ = [this._view.ncMc,this._view.mcMc,this._view.ctMc,this._view.qsMc];
            _loc2_ = 0;
            while(_loc2_ < _loc3_.length)
            {
               if(this.dataModel.appId == _loc3_[_loc2_])
               {
                  _loc3_.splice(_loc2_,1);
                  _loc3_.unshift(this.dataModel.appId);
                  _loc4_ = (_loc4_.splice(_loc2_,1) as Array).concat(_loc4_);
                  break;
               }
               _loc2_++;
            }
            _loc2_ = 0;
            while(_loc2_ < _loc3_.length)
            {
               _loc4_[_loc2_].x = _loc1_[_loc2_].x;
               _loc4_[_loc2_].y = _loc1_[_loc2_].y;
               _loc2_++;
            }
            _loc5_ = new MovieClipButtonInteraction(this._getFinalPresentBtn);
            if(this.dataModel.alreadyGetFinalPresent)
            {
               _loc5_.enable = false;
               _loc5_.label = "已领取";
               this._getFinalPresentBtn.filters = StylesManager.getGrayFilter();
            }
            else
            {
               _loc5_.enable = true;
               _loc5_.label = "领取";
               this._getFinalPresentBtn.filters = null;
            }
            this._appPanel = this._view.appPanel;
            this._appPanel.stop();
            this._view.addEventListener(Event.ADDED_TO_STAGE,this.addToStageHandler);
            this._view.addEventListener(Event.REMOVED_FROM_STAGE,this.removeFromStageHandler);
            this._btnAppIdMap = new Dictionary();
            this._btnAppIdMap[this._ncBtns] = ArborDayConsts.NC_APPID;
            this._btnAppIdMap[this._mcBtns] = ArborDayConsts.MC_APPID;
            this._btnAppIdMap[this._ctBtns] = ArborDayConsts.CT_APPID;
            this._btnAppIdMap[this._qsBtns] = ArborDayConsts.QS_APPID;
            this._toAppBtnLabels = new Object();
            this._toAppBtnLabels[ArborDayConsts.NC_APPID] = "去农场";
            this._toAppBtnLabels[ArborDayConsts.MC_APPID] = "去牧场";
            this._toAppBtnLabels[ArborDayConsts.CT_APPID] = "去餐厅";
            this._toAppBtnLabels[ArborDayConsts.QS_APPID] = "去超市";
            this._appActionBtnInteraction = new MovieClipButtonInteraction(this._appPanel.activityActionBtn);
            this.refreshAppPanel(this.dataModel.appId);
            for(_loc6_ in this._btnAppIdMap)
            {
               new MovieClipButtonInteraction(_loc6_.toAppBtn);
               _loc6_.alreadyGetMask.visible = false;
               if(this._btnAppIdMap[_loc6_] == this.dataModel.appId)
               {
                  _loc6_.toAppBtn.visible = false;
                  _loc6_.exchangeBtn.visible = true;
                  _loc6_.buyPresentBtn.visible = true;
               }
               else
               {
                  _loc6_.exchangeBtn.visible = false;
                  _loc6_.buyPresentBtn.visible = false;
                  _loc6_.toAppBtn.visible = true;
                  _loc6_.toAppBtn.labelTf.text = this._toAppBtnLabels[this._btnAppIdMap[_loc6_]];
               }
            }
            addChild(this._view);
         }
      }
      
      private function refreshAppPanel(param1:String) : void
      {
         switch(param1)
         {
            case ArborDayConsts.NC_APPID:
               this._appPanel.gotoAndStop(1);
               this._appPanel.activityActionBtn.labelTf.text = "领取今日种子";
               break;
            case ArborDayConsts.MC_APPID:
               this._appPanel.gotoAndStop(2);
               this._appPanel.activityActionBtn.labelTf.text = "领取今日幼崽";
               break;
            case ArborDayConsts.CT_APPID:
               this._appPanel.gotoAndStop(3);
               this._appPanel.activityActionBtn.labelTf.text = "去答题";
               break;
            case ArborDayConsts.QS_APPID:
               this._appPanel.gotoAndStop(4);
               this._appPanel.activityActionBtn.labelTf.text = "去迎接大亨";
         }
      }
      
      private function addToStageHandler(param1:Event) : void
      {
         var _loc2_:* = undefined;
         this._detailLinkBtn.addEventListener(MouseEvent.CLICK,this.detailLinkBtnClickHandler);
         this._getMoreScoreBtn.addEventListener(MouseEvent.CLICK,this.getMoreScoreBtnClickHandler);
         this._getRecordBtn.addEventListener(MouseEvent.CLICK,this.getRecoreBtnClickHandler);
         for(_loc2_ in this._btnAppIdMap)
         {
            _loc2_.toAppBtn.addEventListener(MouseEvent.CLICK,this.getPresentBtnClickHandler);
            _loc2_.exchangeBtn.addEventListener(MouseEvent.CLICK,this.getPresentBtnClickHandler);
            _loc2_.buyPresentBtn.addEventListener(MouseEvent.CLICK,this.getPresentBtnClickHandler);
            _loc2_.parent.addEventListener(MouseEvent.MOUSE_MOVE,this.showTipsHandler);
            _loc2_.parent.addEventListener(MouseEvent.MOUSE_OUT,this.hideTipsHandler);
         }
         this._getFinalPresentBtn.addEventListener(MouseEvent.CLICK,this.getFinalPresentBtnClickHandler);
         this._appPanel.activityActionBtn.addEventListener(MouseEvent.CLICK,this.actionBtnClickHandler);
         this._closeBtn.addEventListener(MouseEvent.CLICK,this.closeBtnClickHandler);
         this.currentScore = this.dataModel.currentScore;
         this.actionBtnEnable = this.dataModel.appActionEnable;
         this.alreadyGetNcBag = this.dataModel.alreadyGetNcPresent;
         this.alreadyGetMcBag = this.dataModel.alreadyGetMcPresent;
         this.alreadyGetCtBag = this.dataModel.alreadyGetCtPresent;
         this.alreadyGetQsBag = this.dataModel.alreadyGetQsPresent;
         this.dataModel.addBinding("currentScore",this,"currentScore");
         this.dataModel.addBinding("appActionEnable",this,"actionBtnEnable");
         this.dataModel.addBinding("alreadyGetNcPresent",this,"alreadyGetNcBag");
         this.dataModel.addBinding("alreadyGetMcPresent",this,"alreadyGetMcBag");
         this.dataModel.addBinding("alreadyGetCtPresent",this,"alreadyGetCtBag");
         this.dataModel.addBinding("alreadyGetQsPresent",this,"alreadyGetQsBag");
      }
      
      private function removeFromStageHandler(param1:Event) : void
      {
         var _loc2_:* = undefined;
         this._detailLinkBtn.removeEventListener(MouseEvent.CLICK,this.detailLinkBtnClickHandler);
         this._getMoreScoreBtn.removeEventListener(MouseEvent.CLICK,this.getMoreScoreBtnClickHandler);
         this._getRecordBtn.removeEventListener(MouseEvent.CLICK,this.getRecoreBtnClickHandler);
         for(_loc2_ in this._btnAppIdMap)
         {
            _loc2_.toAppBtn.removeEventListener(MouseEvent.CLICK,this.getPresentBtnClickHandler);
            _loc2_.exchangeBtn.removeEventListener(MouseEvent.CLICK,this.getPresentBtnClickHandler);
            _loc2_.buyPresentBtn.removeEventListener(MouseEvent.CLICK,this.getPresentBtnClickHandler);
            _loc2_.parent.removeEventListener(MouseEvent.MOUSE_MOVE,this.showTipsHandler);
            _loc2_.parent.removeEventListener(MouseEvent.MOUSE_MOVE,this.hideTipsHandler);
         }
         this._getFinalPresentBtn.removeEventListener(MouseEvent.CLICK,this.getFinalPresentBtnClickHandler);
         this._appPanel.activityActionBtn.removeEventListener(MouseEvent.CLICK,this.actionBtnClickHandler);
         this._closeBtn.removeEventListener(MouseEvent.CLICK,this.closeBtnClickHandler);
         this.dataModel.removeBindedTarget(this);
      }
      
      private function showTipsHandler(param1:Event) : void
      {
         var event:Event = param1;
         var setPosition:Function = function(param1:DisplayObject):void
         {
            _presentContentTips.x = param1.x + param1.width / 2;
            _presentContentTips.y = param1.y + param1.height;
            if(param1.parent)
            {
               param1.parent.addChild(_presentContentTips);
            }
         };
         var target:DisplayObject = event.currentTarget as DisplayObject;
         if(target)
         {
            switch(target.name)
            {
               case "qsMc":
                  this._presentContentTips.gotoAndStop(4);
                  setPosition(target);
                  break;
               case "ncMc":
                  this._presentContentTips.gotoAndStop(1);
                  setPosition(target);
                  break;
               case "mcMc":
                  this._presentContentTips.gotoAndStop(2);
                  setPosition(target);
                  break;
               case "ctMc":
                  this._presentContentTips.gotoAndStop(3);
                  setPosition(target);
            }
         }
      }
      
      private function hideTipsHandler(param1:Event) : void
      {
         var _loc2_:DisplayObject = param1.currentTarget as DisplayObject;
         if(_loc2_)
         {
            if(Boolean(this._presentContentTips) && Boolean(this._presentContentTips.parent))
            {
               this._presentContentTips.parent.removeChild(this._presentContentTips);
            }
         }
      }
      
      private function detailLinkBtnClickHandler(param1:Event) : void
      {
         this.mediator.navigateToDetailLink();
         this.dataModel.reportClick(ArborDayConsts.DETAIL_LINK_BTN);
      }
      
      private function getMoreScoreBtnClickHandler(param1:Event) : void
      {
         this.mediator.showDetailWin();
         this.dataModel.reportClick(ArborDayConsts.MORE_SCORE_BTN);
      }
      
      private function getRecoreBtnClickHandler(param1:Event) : void
      {
         this.mediator.showRecordWin();
         this.dataModel.reportClick(ArborDayConsts.GET_RECORD_BTN);
      }
      
      private function getPresentBtnClickHandler(param1:Event) : void
      {
         var _loc4_:MVCEvent = null;
         var _loc2_:DisplayObject = param1.currentTarget as DisplayObject;
         var _loc3_:String = this._btnAppIdMap[_loc2_.parent];
         if(_loc2_.name == "toAppBtn")
         {
            _loc4_ = new MVCEvent(ArborDayConsts.REDIRECT_TOAPP_CMD);
            _loc4_.put("appId",_loc3_);
            this.commandController.executeCommand(_loc4_);
            this.dataModel.reportClick(ArborDayConsts.TO_APP_BTN + _loc3_);
         }
         else if(_loc2_.name == "exchangeBtn")
         {
            _loc4_ = new MVCEvent(ArborDayConsts.EXCHANGE_PRESENT_CMD);
            _loc4_.put("appId",_loc3_);
            MVCFacade.getInstance().commandController.executeCommand(_loc4_);
            this.dataModel.reportClick(ArborDayConsts.EXCHANGE_GIFT_BTN);
         }
         else if(_loc2_.name == "buyPresentBtn")
         {
            _loc4_ = new MVCEvent(ArborDayConsts.BUY_PRESENT_CMD);
            MVCFacade.getInstance().commandController.executeCommand(_loc4_);
            this.dataModel.reportClick(ArborDayConsts.BUY_GIFT_BTN);
         }
      }
      
      private function getFinalPresentBtnClickHandler(param1:Event) : void
      {
         var _loc2_:MVCEvent = new MVCEvent(ArborDayConsts.GET_FINALPRESENT_CMD);
         MVCFacade.getInstance().commandController.executeCommand(_loc2_);
         this.dataModel.reportClick(ArborDayConsts.GET_FINALGIFT_BTN);
      }
      
      private function actionBtnClickHandler(param1:Event) : void
      {
         var _loc2_:MVCEvent = null;
         if(param1.currentTarget.name == "activityActionBtn")
         {
            _loc2_ = new MVCEvent(ArborDayConsts.EXEC_ACTIVITYACTION_CMD);
            MVCFacade.getInstance().commandController.executeCommand(_loc2_);
            this.dataModel.reportClick(ArborDayConsts.APP_ACTION_BTN_CLICK);
         }
      }
      
      private function closeBtnClickHandler(param1:Event) : void
      {
         this.mediator.closeWin(this);
      }
      
      public function set currentScore(param1:int) : void
      {
         TextFieldUtil.refreshText(this._currentScoreTf,String(param1));
      }
      
      public function set actionBtnEnable(param1:Boolean) : void
      {
         if(param1)
         {
            if(this._appActionBtnInteraction)
            {
               this._appActionBtnInteraction.enable = true;
               this._appActionBtnInteraction.view.filters = null;
            }
            this.refreshAppPanel(this.dataModel.appId);
         }
         else if(this._appActionBtnInteraction)
         {
            this._appActionBtnInteraction.enable = false;
            if(this.dataModel.appId != ArborDayConsts.CT_APPID)
            {
               this._appActionBtnInteraction.label = "今天已领取";
            }
            else
            {
               this._appActionBtnInteraction.label = "今天已答题";
            }
            this._appActionBtnInteraction.view.filters = StylesManager.getGrayFilter();
         }
      }
      
      public function set alreadyGetNcBag(param1:Boolean) : void
      {
         this.setAppBuyBtnEnable(ArborDayConsts.NC_APPID,!param1);
      }
      
      public function set alreadyGetMcBag(param1:Boolean) : void
      {
         this.setAppBuyBtnEnable(ArborDayConsts.MC_APPID,!param1);
      }
      
      public function set alreadyGetCtBag(param1:Boolean) : void
      {
         this.setAppBuyBtnEnable(ArborDayConsts.CT_APPID,!param1);
      }
      
      public function set alreadyGetQsBag(param1:Boolean) : void
      {
         this.setAppBuyBtnEnable(ArborDayConsts.QS_APPID,!param1);
      }
      
      private function getExchangeBtn(param1:String) : SimpleButton
      {
         var _loc2_:* = undefined;
         for(_loc2_ in this._btnAppIdMap)
         {
            if(this._btnAppIdMap[_loc2_] == param1)
            {
               return _loc2_.exchangeBtn;
            }
         }
         return null;
      }
      
      private function getBuyPresentBtn(param1:String) : SimpleButton
      {
         var _loc2_:* = undefined;
         for(_loc2_ in this._btnAppIdMap)
         {
            if(this._btnAppIdMap[_loc2_] == param1)
            {
               return _loc2_.buyPresentBtn;
            }
         }
         return null;
      }
      
      private function getExchangedMask(param1:String) : MovieClip
      {
         var _loc2_:* = undefined;
         for(_loc2_ in this._btnAppIdMap)
         {
            if(this._btnAppIdMap[_loc2_] == param1)
            {
               return _loc2_.alreadyGetMask;
            }
         }
         return null;
      }
      
      private function setAppBuyBtnEnable(param1:String, param2:Boolean) : void
      {
         var _loc4_:SimpleButton = null;
         var _loc5_:SimpleButton = null;
         if(param1 == this.dataModel.appId)
         {
            _loc4_ = this.getExchangeBtn(param1);
            _loc5_ = this.getBuyPresentBtn(param1);
            if(_loc4_)
            {
               _loc4_.visible = param2;
            }
            if(_loc5_)
            {
               _loc5_.visible = param2;
            }
         }
         var _loc3_:MovieClip = this.getExchangedMask(param1);
         if(_loc3_)
         {
            _loc3_.visible = !param2;
         }
      }
   }
}

