package module.friend
{
   import common.Consts;
   import common.Session;
   import common.misc.Cookies;
   import events.CommonEvent;
   import flash.events.Event;
   import flash.utils.getTimer;
   import framework.base.Controller;
   import interfaces.IModule;
   
   public class FriendsController extends Controller
   {
      
      private static const limitedTimes:int = 3;
      
      public static const getFriendListDelay:int = 3000;
      
      private var getFriend:Boolean;
      
      private var getFriendListClick:int;
      
      private var getFriendListTime:int;
      
      public function FriendsController(param1:IModule)
      {
         super(param1);
         this.getFriend = false;
         this.getFriendListTime = 0;
         this.getFriendListClick = 0;
      }
      
      private function onCurrentFarmCanPick(param1:CommonEvent) : void
      {
         if(param1 == null || param1.data == null)
         {
            return;
         }
         var _loc2_:uint = uint(param1.data["uId"]);
         var _loc3_:uint = param1.data["ownerId"] as uint;
         this.model.canPick(_loc2_,_loc3_);
      }
      
      private function onUpdataBack(param1:CommonEvent) : void
      {
         var _loc5_:String = null;
         if(param1 == null || param1.data == null)
         {
            return;
         }
         var _loc2_:uint = param1.data["uId"] as uint;
         var _loc3_:uint = param1.data["servertime"] as uint;
         this.model.updateBackStatus(_loc2_,_loc3_);
         var _loc4_:FriendItemRender = this.view.getRenderItemById(_loc2_);
         if(_loc4_ != null)
         {
            _loc4_.updateStatusFlag();
         }
         if(param1.data["leftQuota"] >= 0)
         {
            if(param1.data["leftQuota"] == 0)
            {
               _loc5_ = "金币<font color=\'#ff0000\'>+" + param1.data["money"] + "</font>，好友<font color=\'#ff0000\'>接受邀请后</font>，可获得稀有海芋种子<font color=\'#ff0000\'>1颗</font>。您今天不能再发送召回邀请信息了！";
               if(param1.data.hasOwnProperty("optime"))
               {
                  Cookies.setObject("setZhaohui_" + Session.getInstance().host._uId,{"time":param1.data["optime"]});
               }
               else
               {
                  Cookies.setObject("setZhaohui_" + Session.getInstance().host._uId,{"time":_loc3_});
               }
               this.model.reloadThisPage();
            }
            else
            {
               _loc5_ = "金币<font color=\'#ff0000\'>+" + param1.data["money"] + "</font>，好友<font color=\'#ff0000\'>接受邀请后</font>，可获得稀有海芋种子<font color=\'#ff0000\'>1颗</font>。您今天还能发<font color=\'#ff0000\'>" + param1.data["leftQuota"] + "</font>条邀请！";
            }
            this.openFloat(Consts.FLOAT_TYPE_TEXTTIP,{
               "text":_loc5_,
               "parent":m_view.stage,
               "stoptime":3000
            });
            m_module.app.dispatchEvent(new CommonEvent(Consts.DATA_BAG_RELOAD_FLAG,null));
            Session.getInstance().updateHostAccount(param1.data["money"]);
         }
         else
         {
            if(param1.data.hasOwnProperty("optime"))
            {
               Cookies.setObject("setZhaohui_" + Session.getInstance().host._uId,{"time":param1.data["optime"]});
            }
            else
            {
               Cookies.setObject("setZhaohui_" + Session.getInstance().host._uId,{"time":_loc3_});
            }
            if(param1.data["ecode"] == 0)
            {
               this.openFloat(Consts.FLOAT_TYPE_TEXTTIP,{
                  "text":"对不起，您今天不能再发送召回邀请信息了！",
                  "parent":m_view.stage
               });
            }
            else if(param1.data.hasOwnProperty("direction"))
            {
               this.model.reloadThisPage();
               if(param1.data["direction"] == "今天名额已满！")
               {
                  this.openFloat(Consts.FLOAT_TYPE_TEXTTIP,{
                     "text":"对不起，您今天不能再发送召回邀请信息了！",
                     "parent":m_view.stage
                  });
                  return;
               }
               this.openFloat(Consts.FLOAT_TYPE_TEXTTIP,{
                  "text":param1.data["direction"],
                  "parent":m_view.stage
               });
            }
            else
            {
               this.openFloat(Consts.FLOAT_TYPE_TEXTTIP,{
                  "text":"系统繁忙",
                  "parent":m_view.stage
               });
            }
         }
      }
      
      private function onUpdateFishFlag(param1:CommonEvent) : void
      {
         if(param1 == null || param1.data == null || param1.data["uId"] == undefined)
         {
            return;
         }
         var _loc2_:Boolean = param1.data["hasFish"] as Boolean;
         var _loc3_:Boolean = param1.data["remove"] as Boolean;
         var _loc4_:uint = param1.data["ownerId"] as uint;
         var _loc5_:Boolean = param1.data["check"] as Boolean;
         var _loc6_:Boolean = _loc2_;
         if(_loc3_ == true)
         {
            _loc6_ = false;
         }
         var _loc7_:uint = uint(param1.data["uId"]);
         this.model.updatePoolStatus(_loc7_,_loc4_,_loc6_,_loc5_);
         var _loc8_:FriendItemRender = this.view.getRenderItemById(_loc7_);
         if(_loc8_ != null)
         {
            _loc8_.updateStatusFlag();
         }
      }
      
      private function onAlertWindow(param1:CommonEvent) : void
      {
         if(param1 == null || param1.data == null)
         {
            return;
         }
         openWindow(Consts.WINDOW_NAME_ALERT,param1.data);
      }
      
      private function onRefreshStatus(param1:Event) : void
      {
         if(this.getFriendListTime + getFriendListDelay < getTimer())
         {
            if(this.getFriendListClick < limitedTimes)
            {
               this.model._showFriendPage = 1;
               this.model.refreshFriendStatus(true);
               ++this.getFriendListClick;
            }
            else
            {
               this.getFriendListTime = getTimer();
               this.getFriendListClick = 0;
            }
         }
         else
         {
            this.model._showFriendPage = 1;
            this.model.refreshFriendStatus(false);
         }
      }
      
      private function onRefreshLandStatus(param1:CommonEvent) : void
      {
         if(param1 == null || param1.data == null)
         {
            return;
         }
         var _loc2_:uint = param1.data["uId"] as uint;
         var _loc3_:uint = param1.data["ownerId"] as uint;
         var _loc4_:Boolean = param1.data["havest"] as Boolean;
         var _loc5_:Boolean = param1.data["bug"] as Boolean;
         var _loc6_:Boolean = param1.data["weed"] as Boolean;
         var _loc7_:Boolean = param1.data["check"] as Boolean;
         this.model.updateLandsStatus(_loc2_,_loc3_,_loc6_,_loc5_,_loc4_,_loc7_);
         var _loc8_:FriendItemRender = this.view.getRenderItemById(_loc2_);
         if(_loc8_ != null)
         {
            _loc8_.updateStatusFlag();
         }
      }
      
      private function onForbidden(param1:CommonEvent) : void
      {
         if(param1 == null || param1.data == null)
         {
            return;
         }
         openWindow(Consts.WINDOW_NAME_ALERT,param1.data);
      }
      
      private function onSortFriend(param1:CommonEvent) : void
      {
         if(param1 == null || param1.data == null)
         {
            return;
         }
         this.model.sortBy(param1.data);
      }
      
      private function registerListeners() : void
      {
         m_module.app.addEventListener(Consts.MSG_LAND_CAN_PICK,this.onCurrentFarmCanPick,false,0,true);
         m_module.app.addEventListener(Consts.MSG_REFRESH_FRIEND_STATUS,this.onRefreshLandStatus,false,0,true);
         m_module.app.addEventListener(Consts.MSG_CURRENT_USER_CHANGED,this.onCurrentUserChanged,false,0,true);
         m_module.app.addEventListener(Consts.MSG_WILD_UPDATE_STATUS,this.onUpdateWild,false,0,true);
         m_module.app.addEventListener(Consts.MSG_BACK_UPDATE_STATUS,this.onUpdataBack,false,0,true);
         m_module.app.addEventListener(Consts.MSG_REFRESH_FISH_FRIENDLIST,this.onUpdateFishFlag,false,0,true);
         m_module.app.addEventListener(Consts.MSG_FAIRY_DONATED,this.onUpdateFairyFlag,false,0,true);
         if(m_model != null)
         {
            m_model.addEventListener(FriendsModel.EVENT_ALERT_WINDOW,this.onAlertWindow,false,0,true);
            m_model.addEventListener(FriendsModel.EVENT_FUNCTION_FORBIDDEN,this.onForbidden,false,0,true);
         }
      }
      
      private function onReloadFriends(param1:Event) : void
      {
         if(this.getFriendListTime + getFriendListDelay < getTimer())
         {
            if(this.getFriendListClick < limitedTimes)
            {
               this.model._showFriendPage = 1;
               this.model.loadFriendsData(true,true);
               ++this.getFriendListClick;
            }
            else
            {
               this.getFriendListTime = getTimer();
               this.getFriendListClick = 0;
            }
         }
         else
         {
            this.model._showFriendPage = 1;
            this.model.loadFriendsData(false,true);
         }
      }
      
      override public function finalize() : void
      {
         super.finalize();
      }
      
      private function onPageAction(param1:Event) : void
      {
         if(param1 == null)
         {
            return;
         }
         var _loc2_:String = m_view.seachText;
         if(param1.type == FriendsView.VIEW_EVENT_FIRST_PAGE)
         {
            this.model.goFirstPage(_loc2_);
         }
         else if(param1.type == FriendsView.VIEW_EVENT_BACK_PAGE)
         {
            this.model.goBackPage(_loc2_);
         }
         else if(param1.type == FriendsView.VIEW_EVENT_NEXT_PAGE)
         {
            this.model.goNextPage(_loc2_);
         }
         else if(param1.type == FriendsView.VIEW_EVENT_LAST_PAGE)
         {
            this.model.goLastPage(_loc2_);
         }
      }
      
      private function onSearchFriend(param1:Event) : void
      {
         if(param1 == null)
         {
            return;
         }
         var _loc2_:String = m_view.seachText;
         this.model.searchFriend(_loc2_);
      }
      
      public function get model() : FriendsModel
      {
         return m_model as FriendsModel;
      }
      
      private function onCurrentUserChanged(param1:CommonEvent) : void
      {
         (m_view as FriendsView).updateCurrentSelect();
      }
      
      private function onCollapseView(param1:Event) : void
      {
         if(this.getFriend == false)
         {
            this.model.loadFriendsData(false,false);
            this.getFriend = true;
         }
      }
      
      private function onUpdateWild(param1:CommonEvent) : void
      {
         if(param1 == null || param1.data == null)
         {
            return;
         }
         var _loc2_:uint = param1.data["uId"] as uint;
         var _loc3_:Number = param1.data["t"] as Number;
         this.model.updateLandsStatus2(_loc2_,_loc3_);
         var _loc4_:FriendItemRender = this.view.getRenderItemById(_loc2_);
         if(_loc4_ != null)
         {
            _loc4_.updateStatusFlag();
         }
      }
      
      public function get view() : FriendsView
      {
         return m_view as FriendsView;
      }
      
      override public function initialze() : void
      {
         super.initialze();
         if(m_module.container == null)
         {
            return;
         }
         if(m_model == null)
         {
            m_model = FriendsModel.getInstance();
         }
         this.registerListeners();
         if(m_view == null)
         {
            m_view = new FriendsView(this);
            if(m_module != null && m_module.container != null)
            {
               m_module.container.addChild(m_view);
            }
            m_view.addEventListener(FriendsView.VIEW_EVENT_RELOAD_FRIENDS,this.onReloadFriends,false,0,true);
            m_view.addEventListener(FriendsView.VIEW_EVENT_REFRESH_STATUS,this.onRefreshStatus,false,0,true);
            m_view.addEventListener(FriendsView.VIEW_EVENT_FIRST_PAGE,this.onPageAction,false,0,true);
            m_view.addEventListener(FriendsView.VIEW_EVENT_BACK_PAGE,this.onPageAction,false,0,true);
            m_view.addEventListener(FriendsView.VIEW_EVENT_NEXT_PAGE,this.onPageAction,false,0,true);
            m_view.addEventListener(FriendsView.VIEW_EVENT_LAST_PAGE,this.onPageAction,false,0,true);
            m_view.addEventListener(FriendsView.VIEW_EVENT_SEARCH,this.onSearchFriend,false,0,true);
            m_view.addEventListener(FriendsView.VIEW_EVENT_SORT,this.onSortFriend,false,0,true);
            m_view.addEventListener(FriendsView.VIEW_EVENT_COLLAPSE,this.onCollapseView,false,0,true);
         }
      }
      
      private function onUpdateFairyFlag(param1:CommonEvent) : void
      {
         var _loc2_:uint = 0;
         var _loc3_:FriendItemRender = null;
         if(param1.data != null)
         {
            _loc2_ = param1.data as uint;
            this.model.removeFairyStatus(_loc2_);
            _loc3_ = this.view.getRenderItemById(_loc2_);
            if(_loc3_ != null)
            {
               _loc3_.updateStatusFlag();
            }
         }
      }
   }
}

