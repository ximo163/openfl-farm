package module.messages
{
   import com.qzone.qui.containers.ViewStack;
   import com.qzone.qui.controls.TabBar;
   import common.Consts;
   import common.Language;
   import common.Session;
   import common.view.DataLoading;
   import common.view.window.BaseWindow;
   import common.view.window.WindowTabBarMaker;
   import events.CommonEvent;
   import events.ViewEvent;
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.events.Event;
   import framework.base.BaseTileItem;
   import interfaces.IMsgCenter;
   import module.messages.widgets.*;
   
   public class MessageView extends BaseWindow
   {
      
      private var _selected:int;
      
      private var _systemMsgPage:ProfileSystemMsg;
      
      private var _historyPage:ProfileHistory;
      
      private var _billPage:ProfileCost;
      
      private var _vs:ViewStack;
      
      private var _fishPage:ProfileHistory;
      
      private var _navbar:TabBar;
      
      private var _logPage:ProfileLog;
      
      private var _messagePage:ProfileMsg;
      
      private var _controller:MessageController;
      
      private var _loading:DataLoading;
      
      private var _head:ProfileHead;
      
      public function MessageView(param1:MessageController)
      {
         super(param1.module.app as IMsgCenter);
         title = Language.L["个人信息"];
         windowName = Consts.WINDOW_NAME_PROFILE;
         width = 500;
         height = 400;
         mode = true;
         this._selected = 0;
         this._controller = param1;
      }
      
      public function set selected(param1:int) : void
      {
         if(param1 < 0)
         {
            param1 = 0;
         }
         this._selected = param1;
         if(this._navbar != null)
         {
            this._navbar.selectedIndex = param1;
         }
         if(this._messagePage != null && this._selected == 1)
         {
            this._messagePage.reset();
         }
      }
      
      private function onHistoryItemOut(param1:ViewEvent) : void
      {
         this.controller.hideTip();
      }
      
      private function onLogCleared(param1:CommonEvent) : void
      {
         this.controller.model.reloadAll();
      }
      
      public function get controller() : MessageController
      {
         return this._controller;
      }
      
      private function showLoading(param1:Boolean) : void
      {
         if(this._loading.visible == param1)
         {
            return;
         }
         this._loading.visible = param1;
         this._head.visible = !param1;
         this._navbar.visible = !param1;
         this._vs.visible = !param1;
      }
      
      override protected function init() : void
      {
         this._head = new ProfileHead();
         this._head.x = 0;
         this._head.y = 25;
         this._head.visible = false;
         addChild(this._head);
         this._vs = new ViewStack();
         this._vs.width = width - 2;
         this._navbar = new TabBar();
         WindowTabBarMaker.addTarget(this._navbar);
         this._navbar.x = 0;
         this._navbar.y = 150;
         this._navbar.width = width - 2;
         this._navbar.viewStack = this._vs;
         this._vs.y = this._navbar.y + this._navbar.height;
         this._vs.height = height - this._vs.y;
         this._logPage = new ProfileLog(this);
         this._navbar.addTab(Language.L["消息"],NaN,24);
         this._vs.addView(this._logPage);
         this._messagePage = new ProfileMsg(this);
         this._navbar.addTab(Language.L["留言"],NaN,24);
         this._vs.addView(this._messagePage);
         this._historyPage = new ProfileHistory();
         this._navbar.addTab(Language.L["成果"],NaN,24);
         this._vs.addView(this._historyPage);
         this._historyPage.addEventListener(BaseTileItem.CHILD_OVER,this.onHistoryItemOver,false,0,true);
         this._historyPage.addEventListener(BaseTileItem.CHILD_OUT,this.onHistoryItemOut,false,0,true);
         this._fishPage = new ProfileHistory();
         this._navbar.addTab("成鱼",NaN,24);
         this._vs.addView(this._fishPage);
         this._fishPage.addEventListener(BaseTileItem.CHILD_OVER,this.onHistoryItemOver,false,0,true);
         this._fishPage.addEventListener(BaseTileItem.CHILD_OUT,this.onHistoryItemOut,false,0,true);
         this._billPage = new ProfileCost(this);
         this._navbar.addTab("消费",NaN,24);
         this._vs.addView(this._billPage);
         this._systemMsgPage = new ProfileSystemMsg(this);
         this._navbar.addTab("系统",NaN,24);
         this._vs.addView(this._systemMsgPage);
         this._loading = new DataLoading();
         this._loading.addEventListener(ViewEvent.LINK_CLICK,this.onLinkClicked);
         this._loading.visible = false;
         this._loading.x = width / 2;
         this._loading.y = height / 2 + 20;
         addChild(this._loading);
         this.controller.model.addEventListener(MessageModel.EVENT_DATA_CHANGED,this.onDataChanged,false,0,true);
         this.controller.model.addEventListener(MessageModel.EVENT_DATA_FAILED,this.onDataError,false,0,true);
         this.controller.model.addEventListener(MessageModel.EVENT_DATA_LOADING,this.onDataLoading,false,0,true);
         this.controller.model.addEventListener(MessageModel.EVENT_LOG_CLEARED,this.onLogCleared,false,0,true);
         this._navbar.visible = false;
         this._vs.visible = false;
         addChild(this._vs);
         addChild(this._navbar);
         this._navbar.addEventListener(Event.CHANGE,this.onTabSwitched);
      }
      
      private function onDataChanged(param1:CommonEvent) : void
      {
         if(param1 == null || param1.data == null)
         {
            return;
         }
         this.showLoading(false);
         var _loc2_:String = param1.data["index"] as String;
         var _loc3_:Object = param1.data["data"];
         if(_loc2_ == "user")
         {
            this._head.data = _loc3_["user"];
         }
         else if(_loc2_ == "log")
         {
            if(_loc3_["log"] is Array)
            {
               this._logPage.dataList = _loc3_["log"];
            }
            else
            {
               this._logPage.dataList = null;
            }
         }
         else if(_loc2_ == "chat")
         {
            if(_loc3_["chat"] is Array)
            {
               this._messagePage.dataList = _loc3_["chat"];
            }
            else
            {
               this._messagePage.dataList = null;
            }
         }
         else if(_loc2_ == "repertory")
         {
            if(_loc3_["repertory"] is Array)
            {
               this._historyPage.dataList = _loc3_["repertory"];
            }
            else
            {
               this._historyPage.dataList = null;
            }
         }
         else if(_loc2_ == "cost")
         {
            if(_loc3_["cost"] is Array)
            {
               this._billPage.dataList = _loc3_["cost"];
            }
            else
            {
               this._billPage.dataList = null;
            }
         }
         else if(_loc2_ == "systemMsg")
         {
            if(_loc3_["systemMsg"] is Array)
            {
               this._systemMsgPage.dataList = _loc3_["systemMsg"];
            }
            else
            {
               this._systemMsgPage.dataList = null;
            }
         }
         else if(_loc2_ == "fish")
         {
            if(_loc3_["fish"] is Array)
            {
               this._fishPage.dataList = _loc3_["fish"];
            }
            else
            {
               this._fishPage.dataList = null;
            }
         }
      }
      
      private function onDataLoading(param1:CommonEvent) : void
      {
         if(param1 == null || param1.data == null)
         {
            return;
         }
         this.showLoading(param1.data as Boolean);
      }
      
      public function get me() : Boolean
      {
         return this.controller.model.me;
      }
      
      override protected function onClose(param1:Event) : void
      {
         this._head.showPhotoPic(false);
         this.controller.model.reset();
         if(this._selected == 0)
         {
            this._logPage.dataList = null;
         }
         else if(this._selected == 1)
         {
            this._messagePage.dataList = null;
         }
         else if(this._selected == 2)
         {
            this._historyPage.dataList = null;
         }
         else if(this._selected == 3)
         {
            this._billPage.dataList = null;
         }
         else if(this._selected == 4)
         {
            this._systemMsgPage.dataList = null;
         }
         super.onClose(param1);
      }
      
      public function get selected() : int
      {
         return this._selected;
      }
      
      private function onDataError(param1:CommonEvent) : void
      {
         this.showLoading(true);
         if(param1 != null && param1.data != null)
         {
            this._loading.errorText = param1.data["error"];
         }
      }
      
      public function switchPage(param1:int, param2:Boolean) : void
      {
         if(this._navbar != null && this._vs != null)
         {
            if(param1 >= 0 && param1 < 5)
            {
               this.selected = param1;
            }
         }
         this._head.showPhotoPic(true);
         var _loc3_:DisplayObject = this._navbar.content.getChildAt(4);
         if(_loc3_ != null)
         {
            _loc3_.visible = param2 ? true : false;
         }
         this._billPage.visible = param2 ? true : false;
         _loc3_ = this._navbar.content.getChildAt(5);
         if(_loc3_ != null)
         {
            _loc3_.visible = param2 ? true : false;
         }
         this._systemMsgPage.visible = param2 ? true : false;
      }
      
      private function onTabSwitched(param1:Event) : void
      {
         this._selected = this._navbar.selectedIndex;
         this.controller.model.loadData(this._navbar.selectedIndex);
      }
      
      private function onHistoryItemOver(param1:ViewEvent) : void
      {
         this.controller.showTip(Consts.TIP_NAME_PROFILE_HISTORY,param1.data);
      }
      
      override protected function setData() : void
      {
         this.graphics.clear();
         if(this._messagePage != null)
         {
            this._messagePage.hideReply();
         }
         var _loc1_:Sprite = this._navbar.content.getChildAt(3) as Sprite;
         if(_loc1_ != null)
         {
            _loc1_.visible = Session.getInstance().me;
         }
         _loc1_ = this._navbar.content.getChildAt(4) as Sprite;
         if(_loc1_ != null)
         {
            _loc1_.visible = Session.getInstance().me;
         }
      }
      
      private function onLinkClicked(param1:ViewEvent) : void
      {
         if(param1.data == "reload")
         {
            this.controller.model.loadData(this.selected);
         }
      }
      
      public function get disableAnimation() : Boolean
      {
         return true;
      }
   }
}

