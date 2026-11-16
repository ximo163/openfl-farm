package mc.view.main.window.profile
{
   import com.lipi.LipiUtil;
   import com.minutes.ui.control.JerryTabNavigation;
   import com.minutes.ui.core.UIEvent;
   import common.LocalData;
   import common.MaterialLib;
   import flash.events.Event;
   import flash.filters.GlowFilter;
   import mc.control.Command;
   import mc.model.MData;
   import mc.model.MainData;
   import mc.model.ModelEvent;
   import mc.view.ViewEvent;
   import mc.view.common.BaseWindow;
   import mc.view.common.DataLoading;
   
   public class ProfileWindow extends BaseWindow
   {
      
      private var _selected:int = 0;
      
      private var mainData:MainData;
      
      private var profileCost:ProfileCost;
      
      private var profileMsg:ProfileMsg;
      
      private var profileLog:ProfileLog;
      
      private var profileSystemMsg:ProfileSystemMsg;
      
      private var profileHistory:ProfileHistory;
      
      private var profileHead:ProfileHead;
      
      private var dataLoading:DataLoading;
      
      private var profileNav:JerryTabNavigation;
      
      private var _me:Boolean = false;
      
      public function ProfileWindow()
      {
         super();
         titleIMG = MaterialLib.getInstance().getClass("ProfileWindowTitle");
         windowName = "profile";
         width = 512;
         height = 420;
         mode = true;
      }
      
      private function profileChange(param1:ModelEvent) : void
      {
         if(this.mainData.profile.hasOwnProperty("user"))
         {
            this.profileHead.data = this.mainData.profile["user"];
         }
         if(this.mainData.profile.hasOwnProperty("log"))
         {
            this.profileLog.dataList = this.mainData.profile["log"];
         }
         if(this.mainData.profile.hasOwnProperty("chat"))
         {
            this.profileMsg.dataList = this.mainData.profile["chat"];
         }
         if(this.mainData.profile.hasOwnProperty("repertory"))
         {
            this.profileHistory.dataList = this.mainData.profile["repertory"];
         }
         if(this.mainData.profile.hasOwnProperty("info"))
         {
            this.profileSystemMsg.dataList = this.mainData.profile["data"];
         }
      }
      
      public function set selected(param1:int) : void
      {
         if(param1 < 0)
         {
            this.me = true;
         }
         else
         {
            this.me = false;
         }
         if(this.profileNav != null)
         {
            this.profileNav.selectedIndex = param1;
         }
         this._selected = param1;
         if(Boolean(this.profileMsg) && this._selected == 1)
         {
            this.profileMsg.chatInput.text = "";
         }
      }
      
      public function set me(param1:Boolean) : void
      {
         this._me = param1;
         if(this.profileMsg != null)
         {
            this.profileMsg.me = param1;
         }
         ProfileHistory.me = param1;
      }
      
      override public function init() : void
      {
         this.mainData = MData.getInstance().mainData;
         this.profileHead = new ProfileHead();
         this.profileHead.visible = !this.mainData.profileLoading;
         this.profileHead.x = 0;
         this.profileHead.y = 25;
         addChild(this.profileHead);
         if(this.mainData.profile != null)
         {
            this.profileHead.data = this.mainData.profile["user"];
         }
         this.profileNav = new JerryTabNavigation();
         this.profileNav.visible = !this.mainData.profileLoading;
         this.profileNav.selectedFontStyle(12,16777215,"",false);
         this.profileNav.defaultFontStyle(12,16777215);
         this.profileNav.menuLeftDistance = 16;
         this.profileNav.menuSpaceDistance = 3;
         this.profileNav.menuDefaultButtonWidth = 55;
         this.profileNav.menuDefaultButtonHeight = 22;
         this.profileNav.menuHeight = 27;
         this.profileNav.topHeight = 2;
         this.profileNav.x = 9;
         this.profileNav.y = 150;
         this.profileNav.width = this.width - 8;
         this.profileNav.menuBgClass = MaterialLib.getInstance().getClass("TabBg");
         this.profileNav.menuDefaultSkin = MaterialLib.getInstance().getClass("TabDefault");
         this.profileNav.menuSelectedSkin = MaterialLib.getInstance().getClass("TabSelected");
         this.profileNav.addEventListener(JerryTabNavigation.TAB_SELECT,this.tabSelect);
         addChild(this.profileNav);
         var _loc1_:GlowFilter = new GlowFilter(8541973,1,2,2,3,1);
         this.profileLog = new ProfileLog();
         var _loc2_:String = "消息";
         var _loc3_:int = this.getStringWidth(_loc2_);
         this.profileNav.addItem(_loc2_,this.profileLog,_loc3_,22,[_loc1_]);
         this.profileMsg = new ProfileMsg();
         _loc2_ = "留言";
         _loc3_ = this.getStringWidth(_loc2_);
         this.profileNav.addItem(_loc2_,this.profileMsg,_loc3_,22,[_loc1_]);
         this.profileHistory = new ProfileHistory();
         _loc2_ = "成果";
         _loc3_ = this.getStringWidth(_loc2_);
         this.profileNav.addItem(_loc2_,this.profileHistory,_loc3_,22,[_loc1_]);
         this.profileCost = new ProfileCost();
         _loc2_ = "消费";
         _loc3_ = this.getStringWidth(_loc2_);
         this.profileNav.addItem(_loc2_,this.profileCost,_loc3_,22);
         this.profileSystemMsg = new ProfileSystemMsg();
         _loc2_ = "系统";
         _loc3_ = this.getStringWidth(_loc2_);
         this.profileNav.addItem(_loc2_,this.profileSystemMsg,_loc3_,22);
         this.dataLoading = new DataLoading();
         this.dataLoading.addEventListener(ViewEvent.LINK_CLICK,this.linkClick);
         this.dataLoading.visible = this.mainData.profileLoading;
         this.dataLoading.x = width / 2;
         this.dataLoading.y = height / 2;
         addChild(this.dataLoading);
         this.mainData.addEventListener(MainData.PROFILE,this.profileChange,false,0,true);
         this.mainData.addEventListener(MainData.PROFILE_LOADING,this.profileLoading,false,0,true);
         this.mainData.addEventListener(MainData.PROFILE_ERR,this.profileErr,false,0,true);
      }
      
      private function profileLoading(param1:Event) : void
      {
         this.dataLoading.visible = this.mainData.profileLoading;
         this.profileHead.visible = this.profileNav.visible = !this.mainData.profileLoading;
      }
      
      public function get me() : Boolean
      {
         return this._me;
      }
      
      public function get selected() : int
      {
         return this._selected;
      }
      
      private function linkClick(param1:ViewEvent) : void
      {
         if(param1.data == "reload")
         {
            Command.getInstance().mainCommand.getAllInfo(this.me,this.selected);
         }
      }
      
      private function tabSelect(param1:UIEvent = null) : void
      {
         if(param1.data == 0)
         {
            Command.getInstance().mainCommand.getAllInfo(this.me,0);
         }
         else if(param1.data == 1)
         {
            Command.getInstance().mainCommand.getAllInfo(this.me,1);
         }
         else if(param1.data == 4)
         {
            Command.getInstance().mainCommand.getAllInfo(this.me,4);
         }
      }
      
      override public function addedToLayer() : void
      {
         super.addedToLayer();
         this.profileNav.selectedIndex = this.selected;
         var _loc1_:int = 0;
         if(this.selected > 0)
         {
            _loc1_ = 1;
         }
         Command.getInstance().mainCommand.getAllInfo(this.me,_loc1_);
         if(this.profileMsg != null)
         {
            this.profileMsg.hideReply();
         }
         if(this.profileCost)
         {
            this.profileCost.requireReload = true;
         }
         this.profileNav.menu.getItem(3).visible = this.mainData.me || Boolean(LocalData.isMe);
         this.profileNav.menu.getItem(4).visible = this.mainData.me || Boolean(LocalData.isMe);
      }
      
      override protected function closeHandler() : void
      {
         super.closeHandler();
         this.profileNav.selectedIndex = 0;
         MainData.loadedProfile = false;
         MainData.loadedMsg = false;
         MainData.loadedSystemMsg = false;
      }
      
      private function profileErr(param1:Event) : void
      {
         this.dataLoading.errorText = this.mainData.profileErr;
      }
      
      private function getStringWidth(param1:String, param2:int = 55, param3:int = 10) : Number
      {
         var _loc4_:Number = LipiUtil.getTextLangth(param1);
         _loc4_ = _loc4_ + param3 * 2;
         if(_loc4_ < param2)
         {
            _loc4_ = param2;
         }
         return _loc4_;
      }
   }
}

