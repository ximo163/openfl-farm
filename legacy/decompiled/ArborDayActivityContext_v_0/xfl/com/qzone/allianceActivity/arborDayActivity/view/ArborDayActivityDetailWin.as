package com.qzone.allianceActivity.arborDayActivity.view
{
   import com.qzone.allianceActivity.ArborDayDetailPanelView;
   import com.qzone.allianceActivity.arborDayActivity.model.ArborDayConsts;
   import com.qzone.allianceActivity.arborDayActivity.model.ArborDayDataModel;
   import com.qzone.allianceActivity.framewrok.MVCFacade;
   import com.qzone.allianceActivity.framewrok.controller.CommandController;
   import com.qzone.allianceActivity.framewrok.events.MVCEvent;
   import com.qzone.allianceActivity.framewrok.utils.StylesManager;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.utils.Dictionary;
   
   public class ArborDayActivityDetailWin extends Sprite
   {
      
      public var mediator:ArborDayMediator = MVCFacade.getInstance().getObj(ArborDayConsts.ARBORDAY_MEDIATOR);
      
      public var dataModel:ArborDayDataModel = MVCFacade.getInstance().getObj(ArborDayConsts.ARBORDAY_MODEL);
      
      public var commandController:CommandController;
      
      private var _view:MovieClip;
      
      private var _ncBtn:MovieClip;
      
      private var _mcBtn:MovieClip;
      
      private var _ctBtn:MovieClip;
      
      private var _qsBtn:MovieClip;
      
      private var _btns:MovieClip;
      
      private var _closeBtn:SimpleButton;
      
      private var _btnIdMap:Dictionary = new Dictionary();
      
      public function ArborDayActivityDetailWin()
      {
         this.commandController = MVCFacade.getInstance().commandController;
         super();
         this.initialize();
      }
      
      private function initialize() : void
      {
         var _loc1_:* = undefined;
         var _loc2_:String = null;
         var _loc3_:MovieClipButtonInteraction = null;
         var _loc4_:String = null;
         var _loc5_:String = null;
         this._view = new ArborDayDetailPanelView();
         if(this._view)
         {
            this._btns = this._view.btns;
            this._btns.stop();
            switch(this.dataModel.appId)
            {
               case ArborDayConsts.NC_APPID:
                  this._btns.gotoAndStop(2);
                  break;
               case ArborDayConsts.MC_APPID:
                  this._btns.gotoAndStop(3);
                  break;
               case ArborDayConsts.CT_APPID:
                  this._btns.gotoAndStop(4);
                  break;
               case ArborDayConsts.QS_APPID:
                  this._btns.gotoAndStop(5);
            }
            this._ncBtn = this._btns.ncBtn;
            this._mcBtn = this._btns.mcBtn;
            this._ctBtn = this._btns.ctBtn;
            this._qsBtn = this._btns.qsBtn;
            this._closeBtn = this._view.closeBtn;
            this._btnIdMap = new Dictionary();
            this._btnIdMap[this._ncBtn] = ArborDayConsts.NC_APPID;
            this._btnIdMap[this._mcBtn] = ArborDayConsts.MC_APPID;
            this._btnIdMap[this._ctBtn] = ArborDayConsts.CT_APPID;
            this._btnIdMap[this._qsBtn] = ArborDayConsts.QS_APPID;
            for(_loc1_ in this._btnIdMap)
            {
               _loc2_ = this._btnIdMap[_loc1_];
               _loc3_ = new MovieClipButtonInteraction(_loc1_);
               _loc4_ = "";
               _loc3_.view.filters = null;
               switch(_loc2_)
               {
                  case ArborDayConsts.NC_APPID:
                     _loc4_ = "农场";
                     if(this.dataModel.alreadyGetNcPresent && this.dataModel.appId == _loc2_)
                     {
                        _loc3_.enable = false;
                        _loc3_.view.filters = StylesManager.getGrayFilter();
                     }
                     break;
                  case ArborDayConsts.MC_APPID:
                     _loc4_ = "牧场";
                     if(this.dataModel.alreadyGetMcPresent && this.dataModel.appId == _loc2_)
                     {
                        _loc3_.enable = false;
                        _loc3_.view.filters = StylesManager.getGrayFilter();
                     }
                     break;
                  case ArborDayConsts.CT_APPID:
                     _loc4_ = "餐厅";
                     if(this.dataModel.alreadyGetCtPresent && this.dataModel.appId == _loc2_)
                     {
                        _loc3_.enable = false;
                        _loc3_.view.filters = StylesManager.getGrayFilter();
                     }
                     break;
                  case ArborDayConsts.QS_APPID:
                     _loc4_ = "超市";
                     if(this.dataModel.alreadyGetQsPresent && this.dataModel.appId == _loc2_)
                     {
                        _loc3_.enable = false;
                        _loc3_.view.filters = StylesManager.getGrayFilter();
                     }
               }
               _loc5_ = "";
               if(this.dataModel.appId == _loc2_)
               {
                  _loc5_ = "购买" + _loc4_ + "礼包";
               }
               else
               {
                  _loc5_ = "去" + _loc4_;
               }
               _loc3_.label = _loc5_;
               _loc1_.addEventListener(MouseEvent.CLICK,this.appBtnClickHandler);
            }
            this._closeBtn.addEventListener(MouseEvent.CLICK,this.closeBtnClickHandler);
            addChild(this._view);
         }
      }
      
      private function closeBtnClickHandler(param1:Event) : void
      {
         this.mediator.closeWin(this);
      }
      
      private function appBtnClickHandler(param1:Event) : void
      {
         var _loc4_:MVCEvent = null;
         var _loc2_:Object = param1.currentTarget;
         var _loc3_:String = this._btnIdMap[_loc2_];
         if(this.dataModel.appId == _loc3_)
         {
            _loc4_ = new MVCEvent(ArborDayConsts.BUY_PRESENT_CMD);
            this.commandController.executeCommand(_loc4_);
            this.dataModel.reportClick(ArborDayConsts.BUY_GIFT_BTN + "_in_dw");
         }
         else
         {
            _loc4_ = new MVCEvent(ArborDayConsts.REDIRECT_TOAPP_CMD);
            _loc4_.put("appId",_loc3_);
            this.commandController.executeCommand(_loc4_);
            this.dataModel.reportClick(ArborDayConsts.TO_APP_BTN + _loc3_ + "_in_dw");
         }
      }
   }
}

