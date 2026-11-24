package com.qzone.allianceActivity.arborDayActivity.view
{
   import com.qzone.allianceActivity.ArborDayRecordPanelView;
   import com.qzone.allianceActivity.arborDayActivity.model.ArborDayConsts;
   import com.qzone.allianceActivity.arborDayActivity.model.ArborDayDataModel;
   import com.qzone.allianceActivity.framewrok.MVCFacade;
   import com.qzone.allianceActivity.framewrok.events.MVCEvent;
   import com.qzone.corelib.controls.scrollers.EasyScrollBar;
   import com.qzone.corelib.controls.scrollviews.VScrollView;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   
   public class ArborDayActivityRecordWin extends Sprite
   {
      
      public var mediator:ArborDayMediator = MVCFacade.getInstance().getObj(ArborDayConsts.ARBORDAY_MEDIATOR);
      
      public var dataModel:ArborDayDataModel = MVCFacade.getInstance().getObj(ArborDayConsts.ARBORDAY_MODEL);
      
      private var _view:MovieClip;
      
      private var _listContainer:MovieClip;
      
      private var _scrollBarView:MovieClip;
      
      private var _scrollViewBarController:EasyScrollBar;
      
      private var _scrollView:VScrollView;
      
      private var _closeBtn:SimpleButton;
      
      private var _emptyTf:TextField;
      
      public function ArborDayActivityRecordWin()
      {
         super();
         this.initialize();
      }
      
      private function initialize() : void
      {
         this._view = new ArborDayRecordPanelView();
         if(this._view)
         {
            this._emptyTf = this._view.emptyTf;
            this._listContainer = this._view.listContainer;
            this._closeBtn = this._view.closeBtn;
            this._scrollBarView = this._view.scrollBarView;
            this._scrollView = new VScrollView(this._listContainer,5,1,0,5);
            this._scrollView.itemRenderClass = RecordListItemRenderer;
            this._scrollViewBarController = new EasyScrollBar(this._scrollBarView,5);
            this._scrollViewBarController.scrollArea = this._listContainer;
            this._scrollViewBarController.height = 140;
            this._scrollViewBarController.hideButtonMode = true;
            this._scrollViewBarController.wheelSpeed = 6;
            this._scrollView.scroller = this._scrollViewBarController;
            this._scrollView.x = 0;
            this._scrollView.y = 0;
            this._scrollView.enabled = true;
            this._closeBtn.addEventListener(MouseEvent.CLICK,this.closeBtnClickHandler);
            this.addEventListener(Event.ADDED_TO_STAGE,this.addToStageHandler);
            this.addEventListener(Event.REMOVED_FROM_STAGE,this.removeFromStageHandler);
            addChild(this._view);
         }
      }
      
      public function set records(param1:Array) : void
      {
         this._scrollView.dataProvider = param1;
         if(Boolean(param1) && param1.length > 0)
         {
            this._emptyTf.visible = false;
         }
         else
         {
            this._emptyTf.visible = true;
         }
      }
      
      private function addToStageHandler(param1:Event) : void
      {
         this.records = this.dataModel.scoreRecords;
         this.dataModel.addBinding("scoreRecords",this,"records");
         var _loc2_:MVCEvent = new MVCEvent(ArborDayConsts.GET_SCORERECORD_CMD);
         MVCFacade.getInstance().commandController.executeCommand(_loc2_);
      }
      
      private function removeFromStageHandler(param1:Event) : void
      {
         this.dataModel.removeBindedTarget(this);
      }
      
      private function closeBtnClickHandler(param1:Event) : void
      {
         this.mediator.closeWin(this);
      }
   }
}

