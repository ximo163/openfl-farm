package module.friend
{
   import com.qzone.allianceActivity.AllianceActivityManager;
   import com.qzone.allianceActivity.interfaces.IAllianceActivityContext;
   import com.qzone.farm.api.interfaces.IPluginProxy;
   import com.qzone.qfa.events.CommandEvent;
   import com.qzone.qui.makers.ButtonMaker;
   import com.qzone.qui.makers.TipInputMaker;
   import common.CommonData;
   import common.Consts;
   import common.FeartureManager;
   import common.Session;
   import common.Settings;
   import common.misc.Cookies;
   import common.misc.QzoneJSAPI;
   import common.misc.Utils;
   import common.view.DataLoading;
   import entities.Friend;
   import events.CommonEvent;
   import events.ViewEvent;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.FocusEvent;
   import flash.events.MouseEvent;
   import flash.events.TextEvent;
   import flash.external.ExternalInterface;
   import flash.text.TextField;
   import flash.utils.Timer;
   import flash.utils.setTimeout;
   import framework.api.PluginManager;
   import framework.api.beast.BeastAPI;
   import framework.net.CommandDefs;
   import framework.net.NetHelper;
   import report.ClickReportManager;
   import report.UserActionRecorder;
   
   public class FriendsView extends Sprite
   {
      
      internal static const VIEW_EVENT_RELOAD_FRIENDS:String = "ReloadFriends";
      
      internal static const VIEW_EVENT_REFRESH_STATUS:String = "RefreshStatus";
      
      internal static const VIEW_EVENT_FIRST_PAGE:String = "FirstPage";
      
      internal static const VIEW_EVENT_BACK_PAGE:String = "BackPage";
      
      internal static const VIEW_EVENT_NEXT_PAGE:String = "NextPage";
      
      internal static const VIEW_EVENT_LAST_PAGE:String = "LastPage";
      
      internal static const VIEW_EVENT_SEARCH:String = "Search";
      
      internal static const VIEW_EVENT_SORT:String = "Sort";
      
      internal static const VIEW_EVENT_COLLAPSE:String = "Collapse";
      
      private const hideRight:Number = 24;
      
      private var nextButton:MovieClip;
      
      private var searchTextField:TextField;
      
      private var sortByGoldButtonA:MovieClip;
      
      private const showRight:Number = 206;
      
      private var searchInputer:TipInputMaker;
      
      private var _controller:FriendsController;
      
      private var loading:DataLoading;
      
      private var _currentlyTimer:Timer;
      
      private var _fid:uint;
      
      private var _friendListFilter:Object;
      
      private var refurbishButton2:MovieClip;
      
      private var _page:int = 0;
      
      private var pageTextShow:TextField;
      
      private var close_btn:MovieClip;
      
      private var _uin:uint;
      
      private var refurbishButton:MovieClip;
      
      private var _levelSkin:Array;
      
      private var _itemContainer:Sprite;
      
      private var _itemCache:Array;
      
      private var listUI:Sprite;
      
      private var _filterUserId:int;
      
      private var _countPage:int = 0;
      
      private var backEndButton:MovieClip;
      
      private var _offsetValue:int;
      
      private var sortByExpButtonA:MovieClip;
      
      private var open_btn:MovieClip;
      
      private var backButton:MovieClip;
      
      private var searchButton:MovieClip;
      
      private var _friendList:Array = [];
      
      public function FriendsView(param1:FriendsController)
      {
         var _loc3_:FriendItemRender = null;
         super();
         this._controller = param1;
         this._itemContainer = null;
         this._currentlyTimer = null;
         this._levelSkin = null;
         this._offsetValue = 0;
         this._filterUserId = -1;
         this._itemCache = new Array();
         var _loc2_:int = 0;
         while(_loc2_ < 10)
         {
            _loc3_ = this.createItem();
            this._itemCache.push(_loc3_);
            _loc2_++;
         }
         this.createView();
         addEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage);
         this._controller.model.addEventListener(FriendsModel.EVENT_DATA_LOAD_FAILED,this.onDataLoadFailed,false,0,true);
         this._controller.model.addEventListener(FriendsModel.EVENT_DATA_LOADING,this.onDataLoading,false,0,true);
         this._controller.model.addEventListener(FriendsModel.EVENT_REFRESH_PAGE,this.onRefreshCurrentPage,false,0,true);
         this._controller.model.addEventListener(FriendsModel.EVENT_HEAD_PIC_LOADED,this.onHeadPicLoaded,false,0,true);
      }
      
      private function onMouseOver(param1:MouseEvent) : void
      {
         if(param1 == null || param1.target == null)
         {
            return;
         }
         if(param1.target == this.backButton)
         {
            this._controller.showTip(Consts.TIP_NAME_MOUSE,"上一页");
         }
         else if(param1.target == this.nextButton)
         {
            this._controller.showTip(Consts.TIP_NAME_MOUSE,"下一页");
         }
         else if(param1.target == this.refurbishButton)
         {
            this._controller.showTip(Consts.TIP_NAME_MOUSE,"刷新好友列表");
         }
         else if(param1.target == this.refurbishButton2)
         {
            this._controller.showTip(Consts.TIP_NAME_MOUSE,"点击即可快速显示好友列表中所有好友\n农田的可摘、可除草、可除虫状态。");
         }
         else if(param1.target == this.searchButton)
         {
            this._controller.showTip(Consts.TIP_NAME_MOUSE,"查找");
         }
      }
      
      private function del() : void
      {
         if(this._currentlyTimer != null)
         {
            this._currentlyTimer.stop();
         }
         var _loc1_:int = this._itemContainer.numChildren;
         var _loc2_:int = 0;
         while(_loc2_ < _loc1_)
         {
            if(this._itemContainer.getChildAt(0) is FriendItemRender)
            {
               (this._itemContainer.getChildAt(0) as FriendItemRender).clear();
            }
            this._itemContainer.removeChildAt(0);
            _loc2_++;
         }
      }
      
      private function onRefreshCurrentPage(param1:CommonEvent) : void
      {
         if(param1 == null || param1.data == null)
         {
            return;
         }
         var _loc2_:int = param1.data["index"] as int;
         var _loc3_:int = param1.data["total"] as int;
         this.buildPage(param1.data["friends"],_loc2_,_loc3_);
      }
      
      private function onSearchBtnClicked(param1:Event) : void
      {
         param1.stopImmediatePropagation();
         dispatchEvent(new Event(VIEW_EVENT_SEARCH));
         UserActionRecorder.recordAction(UserActionRecorder.HF_FRIENDLIST_SEARCH);
      }
      
      private function onItemMouseOut(param1:MouseEvent) : void
      {
         if(param1 == null || param1.currentTarget == null)
         {
            return;
         }
         var _loc2_:FriendItemRender = param1.currentTarget as FriendItemRender;
         if(_loc2_ == null)
         {
            return;
         }
         _loc2_.backBg();
         this._controller.hideTip();
      }
      
      private function buildPage(param1:Array, param2:int, param3:int) : void
      {
         var _loc5_:int = 0;
         this.page = param2;
         this.countPage = param3;
         this._friendListFilter = this._controller.model.friendListFilter;
         this.del();
         this._friendList = [];
         if(param1 != null)
         {
            _loc5_ = 0;
            while(_loc5_ < param1.length)
            {
               this._friendList.push(param1[_loc5_]);
               _loc5_++;
            }
         }
         if(this._currentlyTimer != null)
         {
            this._currentlyTimer.stop();
            this._currentlyTimer = null;
         }
         var _loc4_:int = 10;
         if(this._friendList.length < 10)
         {
            _loc4_ = int(this._friendList.length);
         }
         _loc5_ = 0;
         while(_loc5_ < _loc4_)
         {
            this.add();
            _loc5_++;
         }
         this.resetSeleted(Session.getInstance().currentUser._uId);
      }
      
      public function set page(param1:int) : void
      {
         this._page = param1;
         this.pageTextShow.text = this._page.toString() + " / " + this._countPage.toString();
         var _loc2_:Boolean = this._page == 1 ? false : true;
         this.backEndButton.visible = _loc2_;
         ButtonMaker.setEnabled(this.backButton,_loc2_);
      }
      
      private function onSortBtnClicked(param1:Event) : void
      {
         if(param1 == null || param1.target == null)
         {
            return;
         }
         if(param1.target == this.sortByExpButtonA)
         {
            ButtonMaker.setSelected(this.sortByGoldButtonA,false);
            ButtonMaker.setSelected(this.sortByExpButtonA,true);
            dispatchEvent(new CommonEvent(VIEW_EVENT_SORT,"exp"));
            UserActionRecorder.recordAction(UserActionRecorder.HF_FRIENDLIST_SORT_EXP);
         }
         else if(param1.target == this.sortByGoldButtonA)
         {
            ButtonMaker.setSelected(this.sortByGoldButtonA,true);
            ButtonMaker.setSelected(this.sortByExpButtonA,false);
            dispatchEvent(new CommonEvent(VIEW_EVENT_SORT,"money"));
            UserActionRecorder.recordAction(UserActionRecorder.HF_FRIENDLIST_SORT_GOLD);
         }
      }
      
      private function onAppRequestFail(param1:CommandEvent) : void
      {
         if(param1.result.m_extra.hasOwnProperty("direction"))
         {
            this._controller.module.app.dispatchEvent(new CommonEvent(Consts.MSG_BACK_UPDATE_STATUS,{
               "ecode":(param1.result.m_extra["ecode"] == null ? 0 : param1.result.m_extra["ecode"]),
               "direction":(param1.result.m_extra["direction"] == null ? "" : param1.result.m_extra["direction"]),
               "t":0,
               "uId":this._uin,
               "money":param1.result.m_extra["money"],
               "leftQuota":param1.result.m_extra["left_quota"],
               "servertime":(param1.result.m_extra["optime"] == null ? CommonData.serverTime : param1.result.m_extra["optime"])
            }));
         }
         else
         {
            this._controller.openFloat(Consts.FLOAT_TYPE_TEXTTIP,{
               "text":"系统繁忙",
               "parent":this.stage
            });
         }
      }
      
      public function getRenderItemById(param1:uint) : FriendItemRender
      {
         if(this._itemContainer == null)
         {
            return null;
         }
         var _loc2_:FriendItemRender = null;
         var _loc3_:int = 0;
         while(_loc3_ < this._itemContainer.numChildren)
         {
            _loc2_ = this._itemContainer.getChildAt(_loc3_) as FriendItemRender;
            if(_loc2_.fiendData._uId == param1 || _loc2_.fiendData._uin == param1)
            {
               return _loc2_;
            }
            _loc3_++;
         }
         return null;
      }
      
      private function onItemClicked(param1:MouseEvent) : void
      {
         var _loc4_:IAllianceActivityContext = null;
         var _loc5_:uint = 0;
         var _loc6_:String = null;
         var _loc7_:String = null;
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         var _loc10_:String = null;
         var _loc11_:String = null;
         var _loc12_:* = undefined;
         var _loc13_:IPluginProxy = null;
         if(Session.getInstance().harvestAnimationPlaying == true)
         {
            return;
         }
         param1.stopImmediatePropagation();
         var _loc2_:String = "";
         var _loc3_:FriendItemRender = null;
         if(param1 != null && param1.target != null)
         {
            _loc2_ = param1.target.name;
         }
         if(_loc2_ == "vip_mc")
         {
            ExternalInterface.call("window.open","tools.php?mod=vip");
            return;
         }
         if(_loc2_ == "tujian")
         {
            ClickReportManager.reportClick("FRIENDLIST_TUJIAN");
            _loc4_ = AllianceActivityManager.getInstance().getActivityContext("collecting");
            if(_loc4_ != null)
            {
               _loc3_ = param1.target.parent as FriendItemRender;
               if(_loc3_ == null)
               {
                  return;
               }
               _loc5_ = 0;
               if(Settings.getInstance().mode == "")
               {
                  _loc5_ = _loc3_.fiendData._uId;
               }
               else
               {
                  _loc5_ = _loc3_.fiendData._uin;
               }
               _loc4_.execute("10002",_loc5_);
            }
            return;
         }
         if(param1.target["s_name"] == "Status_z")
         {
            if(this.backTimeIsToday() == false)
            {
               this._fid = param1.currentTarget.fiendData._uId;
               if(Settings.getInstance().mode == "")
               {
                  this._uin = param1.currentTarget.fiendData._uId;
               }
               else
               {
                  this._uin = param1.currentTarget.fiendData._uin;
                  if(Settings.getInstance().getStringAttribute("sendRequest") == "1")
                  {
                     _loc6_ = "亲爱的" + param1.currentTarget.fiendData._userName + "，你不在摘菜都没动力了！快来吧，还有惊喜等着你！";
                     _loc7_ = "module/ui/happyfarmGiftIcon50.jpg";
                     QzoneJSAPI.sendGameRequest(this._uin,_loc7_,"接受",null,null,"",_loc6_);
                  }
               }
               NetHelper.sendRequest(CommandDefs.CMD_REQUEST_ZHAO,{"fuid":this._fid},this.onGetRequestSuccess,this.onRequestFail);
            }
            else
            {
               if(Cookies.getObject("setZhaohui_" + Session.getInstance().host._uId) == null)
               {
                  Cookies.setObject("setZhaohui_" + Session.getInstance().host._uId,{"time":CommonData.serverTime});
               }
               this._controller.openFloat(Consts.FLOAT_TYPE_TEXTTIP,{
                  "text":"对不起，您今天不能再发送召回邀请信息了！",
                  "parent":this.stage
               });
            }
            return;
         }
         _loc3_ = param1.currentTarget as FriendItemRender;
         if(_loc3_ == null || _loc3_.fiendData == null)
         {
            return;
         }
         if(_loc2_ == "mc_btn")
         {
            if(Session.getInstance().host._pf > 0)
            {
               this._controller.module.app.setExpressUser(_loc3_.fiendData.exportObject(),2);
            }
            else
            {
               this._controller.module.app.dispatchEvent(new CommonEvent(Consts.MSG_ENTER_MC,2));
            }
         }
         else
         {
            _loc8_ = int(_loc3_.fiendData._uin);
            if(this._friendListFilter != null && this._friendListFilter.hasOwnProperty(_loc8_) == true)
            {
               _loc9_ = int(_loc3_.fiendData._uId);
               _loc10_ = Utils.getNameById(_loc9_) || _loc8_.toString();
               _loc11_ = "<font color=\'#009900\'><b>" + _loc10_ + "</b></font> 说您不是他的好友，不允许进入其农场。确认对方加您为好友后，即可点击<font color=\'#0000FF\'><a href=\'event:del\'>申请进入</a></font>农场。";
               _loc12_ = {
                  "type":Consts.ALERT_TYPE_TIP,
                  "title":"温馨提示",
                  "width":380,
                  "height":220,
                  "text":_loc11_,
                  "textLinkHandle":this.confirmRemoveFilter
               };
               this._filterUserId = _loc8_;
               this._controller.openWindow(Consts.WINDOW_NAME_ALERT,_loc12_);
               return;
            }
            if(param1.target["s_name"] == "Status_u")
            {
               BeastAPI.getInstance().showWildStage();
            }
            else if(param1.target["s_name"] == "Status_7")
            {
               _loc13_ = PluginManager.getInstance().getPluginByID(2);
               if(_loc13_ != null)
               {
                  _loc13_.executeCommand(2100,_loc3_.fiendData._uId);
               }
            }
            else
            {
               BeastAPI.getInstance().showFarmStage();
            }
            this._controller.module.app.dispatchEvent(new CommonEvent(Consts.MSG_SWITCH_USER,_loc3_.fiendData));
         }
         this._controller.module.app.dispatchEvent(new CommonEvent(Consts.DELEVE_NEW_ICON,null));
      }
      
      private function createItem() : FriendItemRender
      {
         var _loc1_:FriendItemRender = new FriendItemRender();
         _loc1_.addEventListener(MouseEvent.MOUSE_OVER,this.onItemMouseOver,false,0,true);
         _loc1_.addEventListener(MouseEvent.MOUSE_OUT,this.onItemMouseOut,false,0,true);
         _loc1_.addEventListener(MouseEvent.CLICK,this.onItemClicked,false,0,true);
         return _loc1_;
      }
      
      public function get seachText() : String
      {
         return this.searchInputer.text;
      }
      
      private function backTimeIsToday() : Boolean
      {
         var _loc1_:Boolean = false;
         if(Cookies.getObject("setZhaohui_" + Session.getInstance().host._uId) == null)
         {
            return false;
         }
         var _loc2_:Date = new Date(CommonData.serverTime * 1000);
         var _loc3_:Date = new Date(Cookies.getObject("setZhaohui_" + Session.getInstance().host._uId)["time"] * 1000);
         if(_loc2_.getFullYear() == _loc3_.getFullYear())
         {
            if(_loc2_.getMonth() == _loc3_.getMonth())
            {
               if(_loc2_.getDate() == _loc3_.getDate())
               {
                  _loc1_ = true;
               }
            }
         }
         return _loc1_;
      }
      
      private function onGetRequestSuccess(param1:CommandEvent) : void
      {
         this._controller.module.app.dispatchEvent(new CommonEvent(Consts.MSG_BACK_UPDATE_STATUS,{
            "ecode":(param1.result.m_extra["ecode"] == null ? 0 : param1.result.m_extra["ecode"]),
            "direction":(param1.result.m_extra["direction"] == null ? "" : param1.result.m_extra["direction"]),
            "t":0,
            "uId":this._uin,
            "money":param1.result.m_extra["money"],
            "leftQuota":param1.result.m_extra["left_quota"],
            "servertime":(param1.result.m_extra["optime"] == null ? CommonData.serverTime : param1.result.m_extra["optime"])
         }));
      }
      
      public function get countPage() : int
      {
         return this._countPage;
      }
      
      private function onResized(param1:Event) : void
      {
         this.x = stage.stageWidth - this.hideRight;
      }
      
      private function onMouseOut(param1:MouseEvent) : void
      {
         if(param1 == null || param1.target == null)
         {
            return;
         }
         this._controller.hideTip();
      }
      
      private function onCollapseView(param1:Event) : void
      {
         var _loc2_:* = undefined;
         if(param1.target == this.open_btn)
         {
            this.open_btn.visible = false;
            this.close_btn.visible = true;
            this._offsetValue = -1;
            addEventListener(Event.ENTER_FRAME,this.effHandler,false,0,true);
            _loc2_ = FeartureManager.friendListMod();
            if(_loc2_ != false)
            {
               this._controller.openWindow(Consts.WINDOW_NAME_ALERT,{
                  "type":Consts.ALERT_TYPE_TIP,
                  "text":_loc2_
               });
               return;
            }
            UserActionRecorder.recordAction(UserActionRecorder.HF_FRIENDLIST_OPEN);
            ClickReportManager.reportClick("right.banner.icon_qq_friend.click");
         }
         else
         {
            this.open_btn.visible = true;
            this.close_btn.visible = false;
            this._offsetValue = 1;
            addEventListener(Event.ENTER_FRAME,this.effHandler,false,0,true);
            UserActionRecorder.recordAction(UserActionRecorder.HF_FRIENDLIST_CLOSE);
         }
      }
      
      private function backEnd(param1:Event) : void
      {
         if(this._page == 1)
         {
            return;
         }
         dispatchEvent(new Event(VIEW_EVENT_FIRST_PAGE));
      }
      
      private function delayConfirmRemoveFilter() : void
      {
         this._controller.model.removeFriendListFilter(this._filterUserId);
      }
      
      public function set countPage(param1:int) : void
      {
         this._countPage = param1;
         this.pageTextShow.text = this._page.toString() + " / " + this._countPage.toString();
         var _loc2_:Boolean = this._page == this._countPage ? false : true;
         ButtonMaker.setEnabled(this.nextButton,_loc2_);
      }
      
      private function onRefreshClicked(param1:Event) : void
      {
         if(param1.target.name == "refresh_btn")
         {
            dispatchEvent(new Event(VIEW_EVENT_RELOAD_FRIENDS));
         }
         else if(param1.target.name == "refresh2_btn")
         {
            dispatchEvent(new Event(VIEW_EVENT_REFRESH_STATUS));
            UserActionRecorder.recordAction(UserActionRecorder.HF_FRIENDLIST_REFRESH_STATUS);
         }
      }
      
      private function onLinkClick(param1:ViewEvent) : void
      {
         if(param1.data == "reload")
         {
            dispatchEvent(new Event(VIEW_EVENT_RELOAD_FRIENDS));
         }
      }
      
      private function onHeadPicLoaded(param1:CommonEvent) : void
      {
         var _loc2_:Boolean = Boolean(QzoneJSAPI.WB);
         var _loc3_:FriendItemRender = null;
         var _loc4_:int = 0;
         while(_loc4_ < this._itemContainer.numChildren)
         {
            _loc3_ = this._itemContainer.getChildAt(_loc4_) as FriendItemRender;
            if(_loc3_ != null)
            {
               _loc3_.updateIcon();
               if(_loc2_ == true)
               {
                  _loc3_.updateName();
               }
            }
            _loc4_++;
         }
      }
      
      public function updateCurrentSelect() : void
      {
         if(this._itemContainer == null)
         {
            return;
         }
         var _loc1_:uint = Session.getInstance().currentUser._uId;
         var _loc2_:FriendItemRender = null;
         var _loc3_:int = 0;
         while(_loc3_ < this._itemContainer.numChildren)
         {
            _loc2_ = this._itemContainer.getChildAt(_loc3_) as FriendItemRender;
            if(_loc2_.isSelected() == true && _loc2_.fiendData._uId == _loc1_)
            {
               return;
            }
            if(_loc2_.fiendData._uId == _loc1_)
            {
               _loc2_.selected = _loc1_;
            }
            else
            {
               _loc2_.selected = 0;
            }
            _loc3_++;
         }
      }
      
      public function get page() : int
      {
         return this._page;
      }
      
      private function resetSeleted(param1:uint) : void
      {
         if(this._itemContainer == null)
         {
            return;
         }
         var _loc2_:int = this._itemContainer.numChildren;
         var _loc3_:int = 0;
         while(_loc3_ < _loc2_)
         {
            (this._itemContainer.getChildAt(_loc3_) as FriendItemRender).selected = param1;
            _loc3_++;
         }
      }
      
      private function add() : void
      {
         var _loc1_:FriendItemRender = null;
         if(this._itemCache.length > 0)
         {
            _loc1_ = this._itemCache.pop() as FriendItemRender;
         }
         else
         {
            _loc1_ = this.createItem();
         }
         var _loc2_:Friend = this._friendList[0];
         this._friendList = this._friendList.splice(1,this._friendList.length - 1);
         if(_loc2_ == null)
         {
            return;
         }
         if(_loc2_["me"] == true && Settings.getInstance().mode == "qzone")
         {
            if(Cookies.getObject("OwnerHead") != null)
            {
               _loc2_._headPic = Cookies.getObject("OwnerHead") as String;
            }
         }
         _loc1_.fiendData = _loc2_;
         if(_loc2_["me"] == false)
         {
            if(_loc2_["sort"] == 1)
            {
               _loc1_.levelBg = this._levelSkin[1];
            }
            else if(_loc2_["sort"] == 2)
            {
               _loc1_.levelBg = this._levelSkin[2];
            }
            else if(_loc2_["sort"] == 3)
            {
               _loc1_.levelBg = this._levelSkin[3];
            }
            else
            {
               _loc1_.levelBg = this._levelSkin[0];
            }
         }
         else
         {
            _loc1_.levelBg = this._levelSkin[4];
         }
         if(this._friendListFilter != null && this._friendListFilter.hasOwnProperty(_loc2_._uin))
         {
            _loc1_.setGray();
         }
         _loc1_.selected = Session.getInstance().currentUserIdByUinMode;
         _loc1_.x = 0;
         _loc1_.y = this._itemContainer.numChildren * 32;
         this._itemContainer.addChildAt(_loc1_,0);
         this.resetSeleted(0);
      }
      
      private function effHandler(param1:Event) : void
      {
         var _loc2_:Number = 0.4;
         var _loc3_:Number = 0;
         if(this._offsetValue > 0)
         {
            _loc3_ = stage.stageWidth - this.hideRight;
         }
         else
         {
            _loc3_ = stage.stageWidth - this.showRight;
         }
         var _loc4_:Number = Math.floor((_loc3_ - this.x) * _loc2_);
         this.x += _loc4_;
         if(_loc4_ == 0)
         {
            removeEventListener(Event.ENTER_FRAME,this.effHandler);
            dispatchEvent(new Event(VIEW_EVENT_COLLAPSE));
         }
      }
      
      private function onItemMouseOver(param1:MouseEvent) : void
      {
         var _loc4_:int = 0;
         var _loc5_:IAllianceActivityContext = null;
         var _loc6_:String = null;
         var _loc7_:String = null;
         var _loc8_:Number = NaN;
         if(param1 == null || param1.target == null || param1.currentTarget == null)
         {
            return;
         }
         var _loc2_:FriendItemRender = param1.currentTarget as FriendItemRender;
         if(_loc2_ == null)
         {
            return;
         }
         _loc2_.changBg();
         var _loc3_:String = param1.target.name;
         if(_loc3_ == "vip_mc")
         {
            this._controller.showTip(Consts.TIP_NAME_MOUSE,"点击查看VIP特权详情");
         }
         else if(_loc3_ == "mc_btn")
         {
            this._controller.showTip(Consts.TIP_NAME_MOUSE,"该用户已开通牧场");
         }
         else if(_loc3_ == "tujian")
         {
            _loc4_ = _loc2_.tujian;
            if(_loc4_ > 0)
            {
               _loc5_ = AllianceActivityManager.getInstance().getActivityContext("collecting");
               if(_loc5_ == null)
               {
                  return;
               }
               _loc6_ = _loc5_.execute("10003",_loc4_) as String;
               this._controller.showTip(Consts.TIP_NAME_MOUSE,"该用户集齐了" + _loc6_ + "系列");
            }
         }
         else if(_loc3_ == "status_mc")
         {
            _loc7_ = "";
            if(param1.target["s_name"] == "Status_u")
            {
               _loc7_ = "驱赶野生动物";
            }
            else if(param1.target["s_name"] == "Status_z")
            {
               _loc7_ = "点击召回好友，获得超值奖励";
            }
            else if(param1.target["s_name"] == "Status_6")
            {
               _loc7_ = "该用户池塘可以操作";
            }
            else if(param1.target["s_name"] == "Status_7")
            {
               _loc7_ = "该用户小仙可以供奉";
            }
            else
            {
               _loc7_ = "该用户田地可以操作";
            }
            if(_loc2_.preMode == true)
            {
               _loc8_ = Math.ceil((_loc2_.preTime - CommonData.serverTime) / 60);
               if(_loc8_ > 0)
               {
                  _loc7_ = "该用户有作物" + _loc8_ + "分钟内成熟";
               }
            }
            this._controller.showTip(Consts.TIP_NAME_MOUSE,_loc7_);
         }
      }
      
      private function onAddedToStage(param1:Event) : void
      {
         removeEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage);
         if(this.stage != null)
         {
            this.stage.addEventListener(Event.RESIZE,this.onResized,false,0,true);
         }
         this.x = stage.stageWidth - this.hideRight;
         this.y = 80;
      }
      
      private function initSkin() : void
      {
         if(Settings.getInstance().mode == "qzone")
         {
            this.close_btn.gotoAndStop(2);
            this.open_btn.gotoAndStop(2);
         }
         var _loc1_:int = 1;
         while(_loc1_ < 8)
         {
            Utils.getCachedBitmapData("VipL" + _loc1_,16,13);
            _loc1_++;
         }
         this._levelSkin = new Array(5);
         this._levelSkin[0] = Utils.getCachedBitmapData("Sort0",24,24);
         this._levelSkin[1] = Utils.getCachedBitmapData("Sort1",24,24);
         this._levelSkin[2] = Utils.getCachedBitmapData("Sort2",24,24);
         this._levelSkin[3] = Utils.getCachedBitmapData("Sort3",24,24);
         this._levelSkin[4] = Utils.getCachedBitmapData("SortMe",24,24);
      }
      
      private function createView() : void
      {
         var _loc1_:MovieClip = null;
         this._itemContainer = new Sprite();
         this.listUI = Utils.getMaterial("List_UI") as Sprite;
         this.close_btn = this.listUI.getChildByName("close_btn") as MovieClip;
         this.open_btn = this.listUI.getChildByName("open_btn") as MovieClip;
         this.backButton = this.listUI.getChildByName("prev_btn") as MovieClip;
         this.nextButton = this.listUI.getChildByName("next_btn") as MovieClip;
         this.backEndButton = this.listUI.getChildByName("prev_end_btn") as MovieClip;
         this.backEndButton.visible = false;
         this.searchTextField = this.listUI.getChildByName("search_txt") as TextField;
         this.pageTextShow = this.listUI.getChildByName("page_txt") as TextField;
         this.sortByExpButtonA = this.listUI.getChildByName("sortA_btn") as MovieClip;
         this.sortByGoldButtonA = this.listUI.getChildByName("sortB_btn") as MovieClip;
         this.refurbishButton = this.listUI.getChildByName("refresh_btn") as MovieClip;
         this.refurbishButton2 = this.listUI.getChildByName("refresh2_btn") as MovieClip;
         this.searchButton = this.listUI.getChildByName("search_btn") as MovieClip;
         ButtonMaker.addTarget(this.sortByExpButtonA,true,true);
         ButtonMaker.addTarget(this.sortByGoldButtonA);
         if(QzoneJSAPI.WB == true)
         {
            _loc1_ = Utils.getMaterial("List_Close_WB") as MovieClip;
            if(_loc1_ != null)
            {
               _loc1_.x = this.close_btn.x;
               _loc1_.y = this.close_btn.y;
               this.listUI.removeChild(this.close_btn);
               this.listUI.addChild(_loc1_);
               this.close_btn = _loc1_;
            }
            _loc1_ = Utils.getMaterial("List_Open_WB") as MovieClip;
            if(_loc1_ != null)
            {
               _loc1_.x = this.open_btn.x;
               _loc1_.y = this.open_btn.y;
               this.listUI.removeChild(this.open_btn);
               this.listUI.addChild(_loc1_);
               this.open_btn = _loc1_;
            }
         }
         ButtonMaker.addTarget(this.close_btn);
         ButtonMaker.addTarget(this.open_btn);
         ButtonMaker.addTarget(this.refurbishButton);
         ButtonMaker.addTarget(this.refurbishButton2);
         ButtonMaker.addTarget(this.searchButton);
         ButtonMaker.addTarget(this.backButton);
         ButtonMaker.addTarget(this.nextButton);
         ButtonMaker.addTarget(this.backEndButton);
         this.searchInputer = new TipInputMaker();
         if(QzoneJSAPI.WB == true)
         {
            this.searchInputer.tipText = "按微博昵称查找";
         }
         else if(Settings.getInstance().mode == "qzone")
         {
            this.searchInputer.tipText = "按昵称或号码查找";
         }
         else
         {
            this.searchInputer.tipText = "按好友名字查找";
         }
         this.searchInputer.target = this.searchTextField;
         this.searchTextField.maxChars = 10;
         this.searchTextField.dispatchEvent(new FocusEvent(FocusEvent.FOCUS_OUT));
         this.close_btn.visible = false;
         this.close_btn.addEventListener("mouseDown",this.onCollapseView);
         this.open_btn.addEventListener("mouseDown",this.onCollapseView);
         this.searchButton.addEventListener(MouseEvent.ROLL_OVER,this.onMouseOver);
         this.searchButton.addEventListener(MouseEvent.ROLL_OUT,this.onMouseOut);
         this.refurbishButton.addEventListener(MouseEvent.ROLL_OVER,this.onMouseOver);
         this.refurbishButton.addEventListener(MouseEvent.ROLL_OUT,this.onMouseOut);
         this.refurbishButton2.addEventListener(MouseEvent.ROLL_OVER,this.onMouseOver);
         this.refurbishButton2.addEventListener(MouseEvent.ROLL_OUT,this.onMouseOut);
         addChild(this.listUI);
         if(Settings.getInstance().getStringAttribute("xb") == "")
         {
            this.searchTextField.addEventListener("change",this.onSearchBtnClicked);
            this.searchButton.addEventListener("mouseDown",this.onSearchBtnClicked);
            this.sortByGoldButtonA.addEventListener(MouseEvent.MOUSE_UP,this.onSortBtnClicked);
            this.sortByExpButtonA.addEventListener(MouseEvent.MOUSE_UP,this.onSortBtnClicked);
            this.backButton.addEventListener(MouseEvent.CLICK,this.back);
            this.backEndButton.addEventListener(MouseEvent.CLICK,this.backEnd);
            this.nextButton.addEventListener(MouseEvent.CLICK,this.next);
            this.refurbishButton.addEventListener("mouseDown",this.onRefreshClicked);
            this.refurbishButton2.addEventListener("mouseDown",this.onRefreshClicked);
         }
         this._itemContainer.x = 30;
         this._itemContainer.y = 55;
         addChild(this._itemContainer);
         this.pageTextShow.text = "0 / 0";
         this.loading = new DataLoading();
         this.loading.x = 110;
         this.loading.y = 200;
         this.loading.addEventListener(ViewEvent.LINK_CLICK,this.onLinkClick);
         this.loading.visible = true;
         addChild(this.loading);
         this.initSkin();
      }
      
      private function onGetAppRequestSuccess(param1:CommandEvent) : void
      {
      }
      
      private function onDataLoadFailed(param1:CommonEvent) : void
      {
         if(param1 == null || param1.data == null)
         {
            return;
         }
         this.loading.visible = true;
         this.loading.errorText = param1.data["error"];
      }
      
      private function onDataLoading(param1:CommonEvent) : void
      {
         if(param1 == null || param1.data == null)
         {
            return;
         }
         this.loading.visible = param1.data["show"] as Boolean;
      }
      
      private function nextEnd(param1:Event) : void
      {
         if(this._page == this._countPage)
         {
            return;
         }
         dispatchEvent(new Event(VIEW_EVENT_LAST_PAGE));
      }
      
      private function onRequestFail(param1:CommandEvent) : void
      {
         if(param1.result.m_extra.hasOwnProperty("direction"))
         {
            this._controller.module.app.dispatchEvent(new CommonEvent(Consts.MSG_BACK_UPDATE_STATUS,{
               "ecode":(param1.result.m_extra["ecode"] == null ? 0 : param1.result.m_extra["ecode"]),
               "direction":(param1.result.m_extra["direction"] == null ? "" : param1.result.m_extra["direction"]),
               "t":0,
               "uId":this._uin,
               "money":param1.result.m_extra["money"],
               "leftQuota":param1.result.m_extra["left_quota"],
               "servertime":(param1.result.m_extra["optime"] == null ? CommonData.serverTime : param1.result.m_extra["optime"])
            }));
         }
         else
         {
            this._controller.openFloat(Consts.FLOAT_TYPE_TEXTTIP,{
               "text":"系统繁忙",
               "parent":this.stage
            });
         }
      }
      
      private function next(param1:Event) : void
      {
         if(this._page == this._countPage)
         {
            return;
         }
         dispatchEvent(new Event(VIEW_EVENT_NEXT_PAGE));
         UserActionRecorder.recordAction(UserActionRecorder.HF_FRIENDLIST_NEXT);
      }
      
      private function confirmRemoveFilter(param1:TextEvent) : void
      {
         setTimeout(this.delayConfirmRemoveFilter,800);
      }
      
      private function back(param1:Event) : void
      {
         if(this._page == 1)
         {
            return;
         }
         dispatchEvent(new Event(VIEW_EVENT_BACK_PAGE));
         UserActionRecorder.recordAction(UserActionRecorder.HF_FRIENDLIST_BACK);
      }
   }
}

