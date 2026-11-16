package module.recall
{
   import com.qzone.corelib.net.RSLManager;
   import com.qzone.qfa.events.CommandEvent;
   import com.qzone.qui.containers.ViewStack;
   import com.qzone.qui.controls.TabBar;
   import com.qzone.utils.DisplayUtil;
   import common.Consts;
   import common.Language;
   import common.Settings;
   import common.misc.Utils;
   import common.view.window.BaseWindow;
   import common.view.window.WindowTabBarMaker;
   import events.CommonEvent;
   import events.ViewEvent;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.utils.clearTimeout;
   import flash.utils.setTimeout;
   import framework.base.BaseTileItem;
   import framework.net.CommandDefs;
   import framework.net.NetHelper;
   import interfaces.IMsgCenter;
   import module.recall.widgets.BackOKPage;
   import module.recall.widgets.BackPage;
   
   public class RecallView extends BaseWindow
   {
      
      private var _timer:int = -1;
      
      private var m_recallOkPage:BackOKPage;
      
      private var _window:MovieClip;
      
      private var m_viewStack:ViewStack;
      
      private var m_recallPage:BackPage;
      
      private var recallData:Array;
      
      private var m_tabNav:TabBar;
      
      private var m_controller:RecallController;
      
      private var m_nick:String;
      
      public function RecallView(param1:RecallController)
      {
         super(param1.module.app as IMsgCenter);
         param1.module.app.useSystemCursor(true);
         windowName = Consts.WINDOW_NAME_RECALL;
         this.title = "";
         width = 0;
         height = 0;
         mode = true;
         showCloseButton = false;
         this.m_controller = param1;
      }
      
      private function createView() : void
      {
         var _loc1_:RSLManager = RSLManager.getInstance();
         var _loc2_:String = Settings.getInstance().getSecondUrl("recall");
         _loc1_.requestClass(this.m_controller.model.RECALL_BG,this.addWindowTimer,_loc2_);
      }
      
      private function onLoadFailed(param1:CommonEvent) : void
      {
         if(param1 == null || param1.data == null)
         {
            return;
         }
         var _loc2_:int = param1.data["index"] as int;
         var _loc3_:String = param1.data["error"] as String;
         if(_loc2_ <= 0)
         {
            if(this.m_recallPage != null)
            {
               this.m_recallPage.errText = _loc3_;
            }
         }
      }
      
      private function closeWinFun() : void
      {
         if(this.m_recallPage)
         {
            this.m_recallPage.dataList = null;
            this.m_recallPage.removeEventListener(BaseTileItem.CHILD_CLICK,this.cropLinkClick);
            DisplayUtil.removeChild(this._window.tipBox,this.m_recallPage);
            this.m_recallPage = null;
         }
         if(this.m_recallOkPage)
         {
            this.m_recallOkPage.dataList = null;
            DisplayUtil.removeChild(this._window.tipBox,this.m_recallOkPage);
            this.m_recallOkPage = null;
         }
         removeChild(this._window);
         this.m_controller.module.app.dispatchEvent(new CommandEvent(Consts.CLOSE_RECALL_WINDOW));
         this._window = null;
         close();
      }
      
      public function get currentPageIndex() : int
      {
         if(this.m_tabNav == null)
         {
            return -1;
         }
         return this.m_tabNav.selectedIndex;
      }
      
      private function onRequestSuccess(param1:CommandEvent) : void
      {
         this.m_controller.openFloat(Consts.FLOAT_TYPE_TEXTTIP,{
            "text":"您接受了好友" + this.m_nick + "的召回邀请赠送<font color=\'#ff0000\'>稀有海芋种子5个</font>",
            "parent":this
         });
         this.m_controller.module.app.dispatchEvent(new CommonEvent(Consts.DATA_BAG_RELOAD_FLAG,null));
         this.closeWinFun();
      }
      
      override protected function init() : void
      {
         super.init();
         this.createView();
         var _loc1_:RecallModel = this.m_controller.model;
         if(_loc1_ != null)
         {
            _loc1_.addEventListener(RecallModel.EVENT_RECALL_DATA_LOADED,this.onDataLoaded,false,0,true);
            _loc1_.addEventListener(RecallModel.EVENT_RECALL_DATA_FAILED,this.onLoadFailed,false,0,true);
            _loc1_.addEventListener(RecallModel.EVENT_RECALL_DATA_LOADING,this.onDataLoading,false,0,true);
         }
      }
      
      private function onDataLoading(param1:CommonEvent) : void
      {
         if(param1 == null || param1.data == null)
         {
            return;
         }
         var _loc2_:int = param1.data["index"] as int;
         var _loc3_:Boolean = param1.data["show"] as Boolean;
         if(_loc2_ == 0)
         {
            if(this.m_recallPage != null)
            {
               this.m_recallPage.loadingVisible = _loc3_;
            }
         }
      }
      
      private function addWindowTimer() : void
      {
         this._timer = setTimeout(this.addWindow,10);
      }
      
      private function onDataLoaded(param1:CommonEvent) : void
      {
         if(param1 == null || param1.data == null)
         {
            return;
         }
         this.recallData = param1.data;
         if(this.m_recallPage != null)
         {
            this.m_recallPage.loadingVisible = false;
            this.m_recallPage.dataList = param1.data;
         }
      }
      
      private function onAppRequestSuccess(param1:CommandEvent) : void
      {
         var _loc2_:Object = NetHelper.getVOData(param1);
         if(_loc2_ == null)
         {
            return;
         }
      }
      
      private function BackWindow() : void
      {
         this._window.tipBox.txt2.visible = false;
         this._window.tipBox.txt1.visible = true;
         this.m_recallPage = new BackPage(this,455,220);
         this._window.tipBox.addChild(this.m_recallPage);
         this.m_recallPage.addEventListener(BaseTileItem.CHILD_CLICK,this.cropLinkClick,false,0,true);
         this._window.bg.gotoAndStop(2);
         this._window.bg.OkBtn.visible = false;
         if(this.m_recallPage.dataList == null)
         {
            this.m_recallPage.loadingVisible = false;
            this.m_recallPage.dataList = this.recallData;
         }
      }
      
      override protected function onClose(param1:Event) : void
      {
         if(this.m_recallPage != null)
         {
            this.m_recallPage.dataList = null;
         }
         super.onClose(param1);
      }
      
      private function BackOKHandler(param1:MouseEvent) : void
      {
      }
      
      private function clearAllInWindow() : void
      {
         if(this.m_recallPage)
         {
            this.m_recallPage.removeEventListener(BaseTileItem.CHILD_CLICK,this.cropLinkClick);
            this._window.tipBox.removeChild(this.m_recallPage);
            this.m_recallPage = null;
         }
         if(this.m_recallOkPage)
         {
            this._window.tipBox.removeChild(this.m_recallOkPage);
            this.m_recallOkPage = null;
         }
      }
      
      private function onAppRequestFail(param1:CommandEvent) : void
      {
      }
      
      public function set currentPageIndex(param1:int) : void
      {
         if(this.m_tabNav)
         {
            this.m_tabNav.selectedIndex = param1;
         }
      }
      
      private function onTabSwitched(param1:Event) : void
      {
         if(param1 == null || param1.currentTarget == null)
         {
            return;
         }
         var _loc2_:RecallModel = this.m_controller.model;
         if(param1.currentTarget.selectedIndex == 0)
         {
            this.clearAllInWindow();
            this.BackOKWindow();
         }
         else
         {
            this.clearAllInWindow();
            this.BackWindow();
         }
      }
      
      private function addWindow() : void
      {
         var _loc1_:MovieClip = null;
         if(this._timer != -1)
         {
            clearTimeout(this._timer);
         }
         this._window = Utils.getMaterial(this.m_controller.model.RECALL_BG) as MovieClip;
         if(this._window != null)
         {
            addChildAt(this._window,0);
         }
         this.BackWindow();
         this._window.closeBtn.addEventListener(MouseEvent.CLICK,this.closeWindows);
         this.m_viewStack = new ViewStack();
         this.m_tabNav = new TabBar();
         this.m_tabNav.viewStack = this.m_viewStack;
         WindowTabBarMaker.addTarget(this.m_tabNav);
         this.m_tabNav.x = -this._window.width / 2 + 17;
         this.m_tabNav.y = -this._window.height / 2 + 65;
         this.m_tabNav.width = this._window.width - 20;
         this.m_tabNav.addEventListener(Event.CHANGE,this.onTabSwitched);
         this.m_viewStack.y = this.m_tabNav.y + this.m_tabNav.height;
         this.m_viewStack.width = this._window.width - 20;
         this.m_viewStack.height = this._window.height - this.m_viewStack.y;
         this.m_tabNav.addTab(Language.L["BackTitle"],80,24);
         this._window.bg.OkBtn.addEventListener(MouseEvent.CLICK,this.BackOKHandler,false,0,true);
         addChild(this.m_viewStack);
         addChild(this.m_tabNav);
         _loc1_ = Utils.getMaterial(this.m_controller.model.REQUEST_NUM) as MovieClip;
         _loc1_.x = this.m_tabNav.x + 85;
         _loc1_.y = this.m_tabNav.y - 5;
         _loc1_.num_txt.text = RecallModel.m_backNum.toString();
         addChild(_loc1_);
      }
      
      private function closeWindows(param1:MouseEvent) : void
      {
         this.closeWinFun();
      }
      
      public function get controller() : RecallController
      {
         return this.m_controller;
      }
      
      private function closeRecallWindow(param1:CommonEvent) : void
      {
         this.closeWinFun();
      }
      
      private function BackOKWindow() : void
      {
         this._window.tipBox.txt2.visible = true;
         this._window.tipBox.txt1.visible = false;
         this.m_recallOkPage = new BackOKPage(this,455,220);
         this._window.tipBox.addChild(this.m_recallOkPage);
         this._window.bg.gotoAndStop(1);
         this._window.bg.OkBtn.visible = true;
         if(this.m_recallOkPage.dataList == null)
         {
            this.m_recallOkPage.loadingVisible = false;
            this.m_recallOkPage.dataList = this.recallData;
         }
      }
      
      private function onRequestFail(param1:CommandEvent) : void
      {
         this.m_controller.openFloat(Consts.FLOAT_TYPE_TEXTTIP,{
            "text":"系统繁忙",
            "parent":this
         });
      }
      
      private function cropLinkClick(param1:ViewEvent) : void
      {
         var _loc5_:int = 0;
         var _loc2_:Array = this.m_controller.model.backs;
         var _loc3_:int = int(_loc2_.length);
         var _loc4_:String = "";
         this.m_nick = param1.data["nick"];
         _loc5_ = 0;
         while(_loc5_ < _loc3_)
         {
            if(_loc2_[_loc5_]["request_id"] != param1.data["request_id"])
            {
               if(_loc5_ != 0)
               {
                  _loc4_ += "_";
               }
               _loc4_ += _loc2_[_loc5_]["request_id"];
            }
            _loc5_++;
         }
         NetHelper.sendRequest(CommandDefs.CMD_REQUEST_SELECT,{
            "yesid":Number(param1.data["request_id"]),
            "noids":_loc4_
         },this.onRequestSuccess,this.onRequestFail);
      }
   }
}

