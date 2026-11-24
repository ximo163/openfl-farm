package com.qzone.allianceActivity.collectingActivity.view
{
   import com.qzone.allianceActivity.collectingActivity.model.CollectingConsts;
   import com.qzone.allianceActivity.collectingActivity.model.CollectingModel;
   import com.qzone.allianceActivity.collectingActivity.model.FriendData;
   import com.qzone.allianceActivity.framewrok.MVCFacade;
   import com.qzone.allianceActivity.framewrok.events.MVCEvent;
   import com.qzone.allianceActivity.framewrok.utils.ClassUtils;
   import com.qzone.allianceActivity.interfaces.IAllianceAppHelper;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.utils.Dictionary;
   import flash.utils.Timer;
   
   public class MainWindow
   {
      
      private var _st:SerialTabs;
      
      private var _loading:MovieClip;
      
      private var _showSerialTab:int;
      
      private var _win:MovieClip;
      
      private var _hideMouseTimer:Timer;
      
      private var _starEffect:MovieClip;
      
      private var _effCls:Class = MainWindow__effCls;
      
      private var _ts:TabSwitcher;
      
      private var _model:CollectingModel;
      
      private var _flp:FriendListPage;
      
      private var _pkp:PKAnimation;
      
      private var _holder:DisplayObjectContainer;
      
      private var _serialLevelTabs:TabButtonGroup;
      
      private var _api:IAllianceAppHelper;
      
      private var _tip:ItemTip;
      
      private var _cropSum:int;
      
      private var _clp:CropListPage;
      
      private var _class:Class = MainWindow__class;
      
      private var _sp:ScorePage;
      
      public function MainWindow(param1:IAllianceAppHelper)
      {
         super();
         this._api = param1;
         this._model = MVCFacade.getInstance().getObj(CollectingConsts.MODEL) as CollectingModel;
         this._model.addBinding("myProducts",this,"myProducts");
         this._model.addBinding("friendsCollection",this,"friendsCollection");
         this._model.addBinding("friendListStatus",this,"friendListStatus");
         this._cropSum = this._model.cropSum;
         this._showSerialTab = -1;
      }
      
      public function destroy() : void
      {
         this._api.execute("10002",false);
         if(this._hideMouseTimer != null)
         {
            this._hideMouseTimer.stop();
            this._hideMouseTimer = null;
         }
         this._api.removePopup(this._win);
         this.playStarEffect(false);
         this._win.stop();
         this._win = null;
         if(this._clp != null)
         {
            this._clp.destroy();
            this._clp = null;
         }
         if(this._sp != null)
         {
            this._sp.destroy();
            this._sp = null;
         }
         if(this._flp != null)
         {
            this._flp.destroy();
            this._flp = null;
         }
         if(this._st != null)
         {
            this._st.destroy();
            this._st = null;
         }
         if(this._serialLevelTabs != null)
         {
            this._serialLevelTabs.destroy();
            this._serialLevelTabs = null;
            TabButtonGroup.history = [0,0,0];
         }
         if(this._pkp != null)
         {
            this._pkp.destroy();
            this._pkp = null;
         }
         this._ts = null;
         this._holder = null;
         this._tip = null;
      }
      
      private function hideMouse(param1:TimerEvent) : void
      {
         this._api.execute("10002",true);
      }
      
      private function onLeftTabChanged(param1:MVCEvent) : void
      {
         var _loc2_:int = param1.getData("index") as int;
         if(_loc2_ == 2)
         {
            this._win.gotoAndStop(1);
            if(this._clp != null)
            {
               this._clp.visible = false;
               this._clp.unBindPager();
            }
            if(this._st != null)
            {
               this._st.destroy();
            }
            this.playStarEffect(false);
            this.createPage1();
            this.updateProgress();
         }
         else if(_loc2_ == 0 || _loc2_ == 1)
         {
            this.hidePage1();
            if(this._showSerialTab == -1)
            {
               if(TabButtonGroup.history[_loc2_] == 3)
               {
                  this._win.gotoAndStop(2);
               }
               else
               {
                  this._win.gotoAndStop(3);
               }
            }
            else
            {
               this._win.gotoAndStop(3);
            }
            this.createPage2(_loc2_);
            if(this._st != null)
            {
               this.updateCrops(this._st.selected,false);
            }
            else
            {
               this.updateCrops(-1,false);
            }
         }
         if(this._pkp != null)
         {
            this._pkp.destroy();
         }
      }
      
      private function onEnterFriendList(param1:Event) : void
      {
         this._win.gotoAndStop(4);
         this.hidePage1();
         this.createFriendListPage();
      }
      
      public function showSerialPage(param1:int) : void
      {
         var _loc2_:Dictionary = this._model.serialsData;
         if(_loc2_[param1] == undefined || _loc2_[param1]["visible"] == 0)
         {
            return;
         }
         if(param1 > 0)
         {
            this._showSerialTab = param1;
            if(this._ts != null)
            {
               this._ts.switchTab(param1 >= CollectingConsts.NORMAL_SERIAL_START ? 0 : 1);
            }
         }
      }
      
      private function onSerialTabChanged(param1:Event) : void
      {
         var _loc2_:int = int(param1.target["selected"]);
         if(_loc2_ <= 0)
         {
            return;
         }
         this.updateCrops(_loc2_,false);
      }
      
      private function updateCrops(param1:int, param2:Boolean) : void
      {
         var _loc3_:Array = null;
         var _loc4_:Array = null;
         var _loc5_:Boolean = false;
         if(this._clp != null)
         {
            if(param1 == -1)
            {
               this._clp.baseData = null;
               this._clp.hilight = null;
               this.playStarEffect(false);
               return;
            }
            if(param1 == 0)
            {
               if(this._ts.selected == 0)
               {
                  param1 = -2;
               }
               else if(this._ts.selected == 1)
               {
                  param1 = 0;
               }
               this._clp.y = 126;
               this._clp.MAX_ITEMS = 14 + 7;
            }
            else
            {
               this._clp.y = 232;
               this._clp.MAX_ITEMS = 14;
            }
            _loc3_ = this._model.getCropIDsBySerial(param1);
            _loc4_ = this._model.getMyProductIDsBySerial(param1);
            if(param2 == false)
            {
               this._clp.baseData = _loc3_;
            }
            this._clp.hilight = _loc4_;
            _loc5_ = false;
            if(_loc3_ != null && _loc4_ != null)
            {
               if(_loc3_.length == _loc4_.length)
               {
                  _loc5_ = true;
               }
            }
            this.playStarEffect(_loc5_);
         }
      }
      
      public function set friendsCollection(param1:Object) : void
      {
         this.waiting(false);
         if(param1 == null)
         {
            return;
         }
         if(this._sp != null)
         {
            this._sp.refreshFriendCollection(param1 as Dictionary);
         }
      }
      
      private function createFriendListPage() : void
      {
         if(this._flp == null)
         {
            this._flp = new FriendListPage(this._api);
            this._flp.x = 112;
            this._flp.y = 147;
            this._flp.rebind([this._win["tab0"],this._win["tab1"],this._win["tab2"]],this._win["pager"]);
            this._flp.sort = 0;
            this._holder.addChild(this._flp);
            this._flp.addEventListener(FriendListPage.MSG_ITEM_CLICKED,this.onCompareWithFriend,false,0,true);
            this.loadFriendPage();
         }
         else
         {
            this._flp.rebind([this._win["tab0"],this._win["tab1"],this._win["tab2"]],this._win["pager"]);
            this._flp.refreshPager();
            this._flp.visible = true;
         }
         this._win["btnReturnProfile"].addEventListener(MouseEvent.CLICK,this.onReturnMyProfile,false,0,true);
      }
      
      private function onCompareWithFriend(param1:MVCEvent) : void
      {
         var _loc2_:FriendData = param1.getData("friend") as FriendData;
         if(this._flp != null && _loc2_ != null)
         {
            this._flp.visible = false;
            this.hidePage1();
            this._win.gotoAndStop(5);
            if(this._pkp == null)
            {
               this._pkp = new PKAnimation(this._api);
               this._pkp.addEventListener(Event.CHANGE,this.onReturnFriendList,false,0,true);
               this._pkp.addEventListener(Event.OPEN,this.onOpenSerialPage,false,0,true);
            }
            this._pkp.play(_loc2_,this._win["holder"] as DisplayObjectContainer,this._win["btnReturnFriends"] as SimpleButton);
         }
      }
      
      private function onReturnFriendList(param1:Event) : void
      {
         this._win.gotoAndStop(4);
         if(this._pkp != null)
         {
            this._pkp.destroy();
         }
         this.createFriendListPage();
         if(this._flp != null && param1 != null)
         {
            this._flp.refreshSort();
         }
      }
      
      private function onReturnMyProfile(param1:MouseEvent) : void
      {
         this._win.gotoAndStop(1);
         if(this._flp != null)
         {
            this._flp.visible = false;
         }
         if(this._st != null)
         {
            this._st.destroy();
         }
         this.playStarEffect(false);
         this.createPage1();
         this.updateProgress();
      }
      
      private function loadSerialIcons() : void
      {
         var _loc1_:String = this._model.serialUrl;
         if(_loc1_ == null || _loc1_ == "")
         {
            return;
         }
         SerialsCache.getInstance().loadRes(_loc1_);
         SerialsCache.getInstance().addEventListener(SerialsCache.EVENT_SERIAL_DOWNLOADED,this.onSerialsDownloaded,false,0,true);
      }
      
      private function updateProgress() : void
      {
         if(this._sp == null)
         {
            return;
         }
         var _loc1_:Object = {"photo":this._api.execute("10007")};
         var _loc2_:Array = this._model.myCollectedSerials;
         _loc1_["serials"] = _loc2_ != null ? _loc2_.length : 0;
         _loc1_["stars"] = this._model.myNormalStars + this._model.myMysteriousStars;
         _loc1_["crops"] = this._model.myCollectedSum;
         _loc1_["cropSum"] = this._model.cropSum;
         _loc1_["serialSum"] = this._model.serialSum;
         _loc1_["name"] = this._api.execute("10014")["_userName"];
         this._sp.headerInfo = _loc1_;
      }
      
      private function startMouseHide() : void
      {
         if(this._hideMouseTimer == null)
         {
            this._hideMouseTimer = new Timer(1000,20);
            this._hideMouseTimer.addEventListener(TimerEvent.TIMER,this.hideMouse,false,0,true);
            this._hideMouseTimer.start();
         }
      }
      
      private function onOpenSerialPage(param1:MVCEvent) : void
      {
         var _loc2_:int = param1.getData("id") as int;
         if(_loc2_ > 0)
         {
            this.showSerialPage(_loc2_);
         }
      }
      
      public function waiting(param1:Boolean) : void
      {
         if(param1 == true)
         {
            if(this._loading == null)
            {
               this._loading = ClassUtils.getMc("DataLoading_mc");
               this._loading.x = 440;
               this._loading.y = 307;
            }
            this._holder.addChild(this._loading);
         }
         else if(this._loading != null && this._loading.parent != null)
         {
            this._loading.parent.removeChild(this._loading);
         }
      }
      
      private function loadFriendPage() : void
      {
         var _loc2_:Array = null;
         var _loc1_:Mediator = MVCFacade.getInstance().getObj(CollectingConsts.MEDIATOR) as Mediator;
         if(_loc1_.loadFriendList() == true)
         {
            if(this._flp != null && this._flp.length == 0)
            {
               _loc2_ = this._model.friendsList;
               this.friendListStatus = _loc2_;
            }
         }
      }
      
      public function showComparePage(param1:uint) : void
      {
      }
      
      public function playStarEffect(param1:Boolean) : void
      {
         if(param1 == true)
         {
            if(this._win.currentFrame != 1)
            {
               return;
            }
            if(this._st != null && this._st.selected == 0)
            {
               return;
            }
            if(this._starEffect == null)
            {
               this._starEffect = new this._effCls() as MovieClip;
               this._win.addChild(this._starEffect);
               this._starEffect.play();
            }
         }
         else if(this._starEffect != null)
         {
            this._win.removeChild(this._starEffect);
            this._starEffect = null;
         }
      }
      
      private function hidePage1() : void
      {
         if(this._sp != null)
         {
            this._sp.visible = false;
            this._sp.unBindPager();
         }
         if(this._flp != null)
         {
            this._flp.visible = false;
            this._flp.unBindPager();
         }
      }
      
      private function loadFriendsCollection() : void
      {
         var _loc1_:Mediator = MVCFacade.getInstance().getObj(CollectingConsts.MEDIATOR) as Mediator;
         var _loc2_:Dictionary = _loc1_.loadFriendsCollection();
         if(_loc2_ != null && this._sp != null)
         {
            this._sp.refreshFriendCollection(_loc2_);
         }
      }
      
      private function createPage1() : void
      {
         var _loc1_:Dictionary = this._model.countEachSerials(0);
         if(this._sp == null)
         {
            this._sp = new ScorePage(this._api);
            this._sp.rebind(this._win["myProfile"],this._win["pager"],this._tip);
            this._sp.x = 116;
            this._sp.y = 142;
            this._holder.addChild(this._sp);
            this.loadSerialIcons();
            this.loadFriendsCollection();
            this._sp.basedata = this._model.serialsData;
            this._sp.hilight = _loc1_;
         }
         else
         {
            this._sp.rebind(this._win["myProfile"],this._win["pager"],this._tip);
            this._sp.hilight = _loc1_;
            this._sp.visible = true;
         }
         this._win["btnFriends"].addEventListener(MouseEvent.CLICK,this.onEnterFriendList,false,0,true);
      }
      
      private function createPage2(param1:int) : void
      {
         var _loc3_:Dictionary = null;
         var _loc2_:int = 0;
         if(this._showSerialTab != -1)
         {
            _loc3_ = this._model.serialsData;
            _loc2_ = int(_loc3_[this._showSerialTab]["type"]);
         }
         if(this._serialLevelTabs == null)
         {
            this._serialLevelTabs = new TabButtonGroup([this._win["tab0"],this._win["tab1"],this._win["tab2"],this._win["tab3"]],_loc2_,param1);
            this._serialLevelTabs.addEventListener(Event.CHANGE,this.onSerialTypeChanged,false,0,true);
         }
         else
         {
            if(this._showSerialTab != -1)
            {
               TabButtonGroup.history[param1] = _loc2_;
            }
            this._serialLevelTabs.rebind([this._win["tab0"],this._win["tab1"],this._win["tab2"],this._win["tab3"]],param1);
         }
         this.createPage2Header(param1);
         if(this._clp == null)
         {
            this._clp = new CropListPage();
            this._clp.rebind(param1,this._win["pager"],this._tip);
            this._clp.x = 120;
            this._clp.y = 228;
            this._holder.addChild(this._clp);
         }
         else
         {
            this._clp.visible = true;
            this._clp.rebind(param1,this._win["pager"],this._tip);
         }
         if(this._st != null && this._showSerialTab != -1)
         {
            this._st.switch2Serial(this._showSerialTab);
            this._showSerialTab = -1;
         }
      }
      
      public function set friendListStatus(param1:Array) : void
      {
         this.waiting(false);
         if(this._flp != null)
         {
            this._flp.data = this._model.friendsList;
         }
      }
      
      private function createPage2Header(param1:int) : void
      {
         if(this._serialLevelTabs.currentSelected == 3)
         {
            if(this._st != null)
            {
               this._st.destroy();
            }
            return;
         }
         if(this._win["btnLeft"] == undefined || this._win["btnLeft"] == null)
         {
            return;
         }
         if(this._st == null)
         {
            this.loadSerialIcons();
            this._st = new SerialTabs(this._model.serialsConfig,this._win["holder"]);
            this._st.addEventListener(Event.CHANGE,this.onSerialTabChanged,false,0,true);
         }
         this._st.rebind(param1,this._win["btnLeft"],this._win["btnRight"],this._win["arrow"]);
         this._st.buildSerialsTab(this._serialLevelTabs.currentSelected);
         this._st.updateTabs();
      }
      
      private function onSerialTypeChanged(param1:Event) : void
      {
         var _loc3_:int = 0;
         var _loc2_:int = this._serialLevelTabs.currentSelected;
         if(_loc2_ == 3)
         {
            this._win.gotoAndStop(2);
            this.hidePage1();
            if(this._st != null)
            {
               this._st.destroy();
            }
            this.updateCrops(0,false);
         }
         else
         {
            this._win.gotoAndStop(3);
            if(this._st != null && this._ts != null)
            {
               _loc3_ = this._ts.selected == 0 ? 0 : 1;
               this._st.rebind(_loc3_,this._win["btnLeft"],this._win["btnRight"],this._win["arrow"]);
               this._st.buildSerialsTab(_loc2_);
               this._st.updateTabs();
               if(this._clp != null)
               {
                  this._clp.rebind(_loc3_,this._win["pager"],this._tip);
                  this.updateCrops(this._st.selected,false);
               }
            }
         }
      }
      
      public function set myProducts(param1:Array) : void
      {
         var _loc2_:Array = null;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         if(param1 != null)
         {
            if(this._win.currentFrame == 1)
            {
               if(this._sp != null)
               {
                  this._sp.hilight = this._model.countEachSerials(0);
               }
               this.updateProgress();
            }
            _loc2_ = this._model.getCropIDsBySerial(-3);
            _loc3_ = int(this._model.myNormalProducts.length);
            _loc4_ = int(this._model.cropSum);
            _loc5_ = int(param1.length);
            this._ts.refreshNumbers(_loc3_,_loc2_.length,_loc5_ - _loc3_,_loc4_ - _loc2_.length);
            if(this._win.currentFrame == 3)
            {
               this.updateCrops(0,true);
            }
            if(this._win.currentFrame == 2)
            {
               if(this._st != null)
               {
                  this.updateCrops(this._st.selected,true);
                  this._st.updateTabs();
               }
            }
         }
      }
      
      public function cancelPK() : void
      {
         this.onReturnFriendList(null);
      }
      
      private function onSerialsDownloaded(param1:Event) : void
      {
         if(this._st != null)
         {
            this._st.refreshSerialIcons();
         }
         if(this._sp != null)
         {
            this._sp.refreshSerialIcons();
         }
      }
      
      public function show() : MovieClip
      {
         if(this._win == null)
         {
            this._win = new this._class() as MovieClip;
            this._win.gotoAndStop(1);
            this._win["btnClose"].addEventListener(MouseEvent.CLICK,function(param1:MouseEvent):void
            {
               param1.stopImmediatePropagation();
               destroy();
            });
            this._holder = this._win["holder"] as DisplayObjectContainer;
            this._tip = new ItemTip(this._api,this._model,this._win);
         }
         if(this._ts == null)
         {
            this._ts = new TabSwitcher([this._win["tab1"],this._win["tab2"],this._win["tab3"]],2,this._api);
            this._ts.addEventListener(TabSwitcher.EVENT_TAB_CHANGED,this.onLeftTabChanged,false,0,true);
         }
         this.createPage1();
         this.updateProgress();
         this.startMouseHide();
         this._api.popupWindow(this._win);
         return this._win;
      }
   }
}

