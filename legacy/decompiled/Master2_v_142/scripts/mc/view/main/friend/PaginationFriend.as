package mc.view.main.friend
{
   import com.minutes.ui.collections.LipiCanvas;
   import com.minutes.ui.constant.ScrollPolicy;
   import com.minutes.ui.control.ToggleButton;
   import com.qzone.qui.makers.TipInputMaker;
   import common.LocalData;
   import common.MaterialLib;
   import flash.display.BitmapData;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.text.TextField;
   import flash.utils.Timer;
   import mc.control.Command;
   import mc.control.Version;
   import mc.model.MData;
   import mc.model.MainData;
   import mc.view.ViewEvent;
   import mc.view.common.DataLoading;
   import mc.view.main.cursor.Cursor;
   import mc.view.main.tip.TipControl;
   
   public class PaginationFriend extends Sprite
   {
      
      public static var NEXT:String = "next";
      
      public static var BACK:String = "back";
      
      public static var SEARCH:String = "search";
      
      public static var REFURBISH:String = "refurbish";
      
      public static var REFURBISH2:String = "refurbish2";
      
      public static var SHRINKAGE:String = "shrinkage";
      
      public static var FRIEND:String = "friend";
      
      public static var SORT_BY_GOLD:String = "sortByGold";
      
      public static var SORT_BY_EXP:String = "sortByExp";
      
      private var nextButton:MovieClip;
      
      private var level_me_skin:BitmapData;
      
      private var searchTextField:TextField;
      
      private var currentlyTimer:Timer = null;
      
      private var VipL1:BitmapData;
      
      private var VipL2:BitmapData;
      
      private var level_3_skin:BitmapData;
      
      private var VipL4:BitmapData;
      
      private var VipL5:BitmapData;
      
      private var VipL6:BitmapData;
      
      private var shrinkageButton:ToggleButton;
      
      private var VipL3:BitmapData;
      
      private var searchInputer:TipInputMaker;
      
      private var VipL7:BitmapData;
      
      private var _pageData:Array;
      
      private var leftContainer:LipiCanvas;
      
      private var loading:DataLoading;
      
      private var level_0_skin:BitmapData;
      
      private var refurbishButton2:MovieClip;
      
      private var _page:int = 0;
      
      private var pageTextShow:TextField;
      
      private var level_2_skin:BitmapData;
      
      private var close_btn:MovieClip;
      
      private var refurbishButton:MovieClip;
      
      private var listUI:Sprite;
      
      private var _countPage:int = 0;
      
      private var childContainer:LipiCanvas;
      
      private var childCache:Array;
      
      private var backEndButton:SimpleButton;
      
      private var ChildClass:Class;
      
      private var level_1_skin:BitmapData;
      
      private var open_btn:MovieClip;
      
      private var sortByExpButtonA:MovieClip;
      
      private var backButton:MovieClip;
      
      private var searchButton:MovieClip;
      
      private var _friendList:Array = [];
      
      public function PaginationFriend(param1:Class = null)
      {
         var _loc2_:int = 0;
         var _loc3_:Friend = null;
         super();
         if(param1 == null)
         {
            param1 = Friend;
         }
         this.childCache = new Array();
         if(param1 == Friend)
         {
            this.ChildClass = param1;
            _loc2_ = 0;
            while(_loc2_ < 10)
            {
               _loc3_ = new param1();
               this.childCache.push(_loc3_);
               _loc2_++;
            }
            this.UIinit();
            return;
         }
         throw new Error("参数错误，只能是 hf.view.main.Friend");
      }
      
      private function del() : void
      {
         if(this.currentlyTimer != null)
         {
            this.currentlyTimer.stop();
         }
         var _loc1_:int = this.childContainer.numChildren;
         var _loc2_:int = 0;
         while(_loc2_ < _loc1_)
         {
            if(this.childContainer.getChildAt(0) is Friend)
            {
               Friend(this.childContainer.getChildAt(0)).clear();
            }
            this.childContainer.removeChildAt(0);
            _loc2_++;
         }
      }
      
      private function rollOut_search(param1:Event) : void
      {
         TipControl.hide();
      }
      
      private function rollOut_refurbish(param1:Event) : void
      {
         TipControl.hide();
      }
      
      public function set page(param1:int) : void
      {
         this._page = param1;
         this.pageTextShow.text = this._page.toString() + " / " + this._countPage.toString();
         if(this._page == 1)
         {
            this.backButton.enabled = false;
            this.backButton.buttonMode = false;
            this.backEndButton.visible = false;
         }
         else
         {
            this.backButton.enabled = true;
            this.backButton.buttonMode = true;
            this.backEndButton.visible = true;
         }
      }
      
      private function eplay2(param1:Event) : void
      {
         this.sortByExpButtonA.gotoAndStop(2);
      }
      
      private function eplay1(param1:Event) : void
      {
         this.sortByExpButtonA.gotoAndStop(1);
      }
      
      private function eplay3(param1:Event) : void
      {
         this.sortByExpButtonA.gotoAndStop(3);
      }
      
      public function get countPage() : int
      {
         return this._countPage;
      }
      
      public function sortByExp(param1:Event) : void
      {
         this.sortByExpButtonA.selected = true;
         var _loc2_:ViewEvent = new ViewEvent("sortByExp");
         this.dispatchEvent(_loc2_);
         this.loading.visible = MData.getInstance().mainData.getFriendListLoading;
      }
      
      private function refurbish(param1:Event) : void
      {
         var _loc2_:ViewEvent = null;
         MData.getInstance().mainData.showFriendPage = 1;
         if(param1.target.name == "refresh_btn")
         {
            _loc2_ = new ViewEvent(PaginationFriend.REFURBISH);
         }
         else if(param1.target.name == "refresh2_btn")
         {
            _loc2_ = new ViewEvent(PaginationFriend.REFURBISH2);
         }
         this.dispatchEvent(_loc2_);
         this.loading.visible = MData.getInstance().mainData.getFriendListLoading;
      }
      
      private function dataLoaded(param1:Event) : void
      {
         this.loading.visible = MData.getInstance().mainData.getFriendListLoading;
      }
      
      private function shrinkage(param1:Event) : void
      {
         if(LocalData.friendListFlag == false)
         {
            Command.getInstance().mainCommand.alertWindow("error",LocalData.friendTxt);
            return;
         }
         var _loc2_:ViewEvent = new ViewEvent(PaginationFriend.SHRINKAGE);
         if(param1.target == this.open_btn)
         {
            this.open_btn.visible = false;
            this.close_btn.visible = true;
         }
         else
         {
            this.open_btn.visible = true;
            this.close_btn.visible = false;
         }
         _loc2_.data = this.close_btn.visible;
         this.dispatchEvent(_loc2_);
      }
      
      public function get seachText() : String
      {
         return this.searchTextField.text;
      }
      
      private function friendListErr(param1:Event) : void
      {
         this.loading.errorText = MData.getInstance().mainData.getFriendListErr;
      }
      
      public function backEnd(param1:Event) : void
      {
         if(this._page == 1)
         {
            return;
         }
         var _loc2_:ViewEvent = new ViewEvent("backEnd");
         _loc2_.data = this.searchInputer.text;
         this.dispatchEvent(_loc2_);
         this.loading.visible = MData.getInstance().mainData.getFriendListLoading;
      }
      
      private function rollOver_back(param1:Event) : void
      {
         TipControl.show("MouseTip","上一页");
      }
      
      public function set countPage(param1:int) : void
      {
         this._countPage = param1;
         this.pageTextShow.text = this._page.toString() + " / " + this._countPage.toString();
         if(this._page == this._countPage)
         {
            this.nextButton.enabled = false;
            this.nextButton.buttonMode = false;
         }
         else
         {
            this.nextButton.enabled = true;
            this.nextButton.buttonMode = true;
         }
      }
      
      private function rollOver_refurbish(param1:Event) : void
      {
         if(param1.target.name == "refresh_btn")
         {
            TipControl.show("MouseTip","刷新好友列表");
         }
         else if(param1.target.name == "refresh2_btn")
         {
            TipControl.show("MouseTip","点击即可快速显示好友列表中所有好友\n牧场的可收取、可赶去生产、可拍蚊子状态。");
         }
      }
      
      private function rollOver_next(param1:Event) : void
      {
         TipControl.show("MouseTip","下一页");
      }
      
      public function get page() : int
      {
         return this._page;
      }
      
      private function resetSeleted(param1:Event) : void
      {
         var _loc2_:int = this.childContainer.numChildren;
         var _loc3_:int = 0;
         while(_loc3_ < _loc2_)
         {
            (this.childContainer.getChildAt(_loc3_) as Friend).selected = MData.getInstance().mainData.currentUserId;
            _loc3_++;
         }
      }
      
      private function add(param1:TimerEvent) : void
      {
         var _loc2_:Friend = null;
         var _loc3_:Object = null;
         if(this.childCache.length > 0)
         {
            _loc2_ = this.childCache.pop() as Friend;
         }
         else
         {
            _loc2_ = new Friend();
         }
         _loc3_ = this._friendList[0];
         this._friendList = this._friendList.splice(1,this._friendList.length - 1);
         if(Boolean(_loc3_.me) && LocalData.mode == "qzone")
         {
            _loc3_.headPic = LocalData.getInstance().getObject("OwnerHead");
         }
         _loc2_.friendData = _loc3_;
         if(!_loc3_.me)
         {
            if(_loc3_.sort > 3)
            {
               _loc2_.levelBg = this.level_0_skin;
            }
            else if(_loc3_.sort == 1)
            {
               _loc2_.levelBg = this.level_1_skin;
            }
            else if(_loc3_.sort == 2)
            {
               _loc2_.levelBg = this.level_2_skin;
            }
            else if(_loc3_.sort == 3)
            {
               _loc2_.levelBg = this.level_3_skin;
            }
         }
         else
         {
            _loc2_.levelBg = this.level_me_skin;
         }
         _loc2_.selected = MData.getInstance().mainData.currentUserId;
         _loc2_.x = 0;
         _loc2_.y = this.childContainer.numChildren * 32;
         this.childContainer.addChildAt(_loc2_,0);
         this.resetSeleted(null);
      }
      
      private function UIinit() : void
      {
         this.childContainer = new LipiCanvas();
         this.loading = new DataLoading();
         var _loc1_:MaterialLib = MaterialLib.getInstance();
         this.listUI = _loc1_.getMaterial("List_UI") as Sprite;
         this.listUI.addEventListener(MouseEvent.ROLL_OVER,this.onRollOver);
         this.listUI.addEventListener(MouseEvent.ROLL_OUT,this.onRollOut);
         this.close_btn = this.listUI.getChildByName("close_btn") as MovieClip;
         this.open_btn = this.listUI.getChildByName("open_btn") as MovieClip;
         this.backButton = this.listUI.getChildByName("prev_btn") as MovieClip;
         this.nextButton = this.listUI.getChildByName("next_btn") as MovieClip;
         this.backEndButton = this.listUI.getChildByName("prev_end_btn") as SimpleButton;
         this.searchTextField = this.listUI.getChildByName("search_txt") as TextField;
         this.pageTextShow = this.listUI.getChildByName("page_txt") as TextField;
         this.sortByExpButtonA = this.listUI.getChildByName("sortA_btn") as MovieClip;
         this.refurbishButton = this.listUI.getChildByName("refresh_btn") as MovieClip;
         this.refurbishButton2 = this.listUI.getChildByName("refresh2_btn") as MovieClip;
         this.searchButton = this.listUI.getChildByName("search_btn") as MovieClip;
         this.close_btn.visible = false;
         addChild(this.listUI);
         this.childContainer.horizontalScrollPolicy = ScrollPolicy.OFF;
         this.childContainer.verticalScrollPolicy = ScrollPolicy.OFF;
         this.close_btn.addEventListener("mouseDown",this.shrinkage);
         this.open_btn.addEventListener("mouseDown",this.shrinkage);
         this.searchTextField.addEventListener("change",this.search);
         this.searchInputer = new TipInputMaker();
         if(Version.value == Version.QZONE)
         {
            this.searchInputer.tipText = "按昵称或号码查找";
         }
         else
         {
            this.searchInputer.tipText = "按好友名字查找";
         }
         this.searchInputer.target = this.searchTextField;
         this.searchTextField.maxChars = 10;
         this.searchButton.addEventListener("mouseDown",this.search);
         this.searchButton.addEventListener(MouseEvent.ROLL_OVER,this.rollOver_search);
         this.searchButton.addEventListener(MouseEvent.ROLL_OUT,this.rollOut_search);
         this.sortByExpButtonA.addEventListener(MouseEvent.MOUSE_UP,this.sortByExp);
         this.sortByExpButtonA.selected = true;
         this.refurbishButton.addEventListener("mouseDown",this.refurbish);
         this.refurbishButton.addEventListener(MouseEvent.ROLL_OVER,this.rollOver_refurbish);
         this.refurbishButton.addEventListener(MouseEvent.ROLL_OUT,this.rollOut_refurbish);
         this.refurbishButton2.addEventListener("mouseDown",this.refurbish);
         this.refurbishButton2.addEventListener(MouseEvent.ROLL_OVER,this.rollOver_refurbish);
         this.refurbishButton2.addEventListener(MouseEvent.ROLL_OUT,this.rollOut_refurbish);
         this.childContainer.x = 30;
         this.childContainer.y = 55;
         this.childContainer.width = 172;
         this.childContainer.height = 320;
         this.childContainer.bgAlpha = 0;
         addChild(this.childContainer);
         this.backButton.addEventListener(MouseEvent.CLICK,this.back);
         this.backEndButton.addEventListener(MouseEvent.CLICK,this.backEnd);
         this.pageTextShow.text = "0 / 0";
         this.nextButton.addEventListener(MouseEvent.CLICK,this.next);
         this.initSkin();
         this.loading.x = 110;
         this.loading.y = 200;
         this.loading.addEventListener(ViewEvent.LINK_CLICK,this.linkClick);
         this.loading.visible = MData.getInstance().mainData.getFriendListLoading;
         addChild(this.loading);
         MData.getInstance().mainData.addEventListener(MainData.CURRENT_USER_CHANGE,this.resetSeleted);
         MData.getInstance().mainData.addEventListener(MainData.GET_FRIEND_LIST_LOADING,this.dataLoaded);
         MData.getInstance().mainData.addEventListener(MainData.GET_FRIEND_LIST_ERR,this.friendListErr);
      }
      
      private function initSkin() : void
      {
         var _loc1_:MaterialLib = MaterialLib.getInstance();
         if(Version.value == Version.QZONE)
         {
            this.close_btn.gotoAndStop(2);
            this.open_btn.gotoAndStop(2);
         }
         this.VipL1 = _loc1_.getCachedBitmapData("VipL1",16,13);
         this.VipL2 = _loc1_.getCachedBitmapData("VipL2",16,13);
         this.VipL3 = _loc1_.getCachedBitmapData("VipL3",16,13);
         this.VipL4 = _loc1_.getCachedBitmapData("VipL4",16,13);
         this.VipL5 = _loc1_.getCachedBitmapData("VipL5",16,13);
         this.VipL6 = _loc1_.getCachedBitmapData("VipL6",16,13);
         this.VipL7 = _loc1_.getCachedBitmapData("VipL7",16,13);
         this.level_0_skin = _loc1_.getCachedBitmapData("Sort0",24,24);
         this.level_1_skin = _loc1_.getCachedBitmapData("Sort1",24,24);
         this.level_2_skin = _loc1_.getCachedBitmapData("Sort2",24,24);
         this.level_3_skin = _loc1_.getCachedBitmapData("Sort3",24,24);
         this.level_me_skin = _loc1_.getCachedBitmapData("SortMe",24,24);
      }
      
      private function linkClick(param1:ViewEvent) : void
      {
         var _loc2_:ViewEvent = null;
         if(param1.data == "reload")
         {
            _loc2_ = new ViewEvent("refurbish");
            dispatchEvent(_loc2_);
         }
      }
      
      private function search(param1:Event) : void
      {
         var _loc2_:ViewEvent = new ViewEvent("search");
         _loc2_.data = this.searchInputer.text;
         this.dispatchEvent(_loc2_);
         this.loading.visible = MData.getInstance().mainData.getFriendListLoading;
      }
      
      private function rollOver_search(param1:Event) : void
      {
         TipControl.show("MouseTip","查找");
      }
      
      private function onRollOut(param1:MouseEvent) : void
      {
         Cursor.useSystem(false);
      }
      
      public function set pageData(param1:Array) : void
      {
         this._pageData = param1;
      }
      
      public function get pageData() : Array
      {
         return this._pageData;
      }
      
      private function rollOut_next(param1:Event) : void
      {
         TipControl.hide();
      }
      
      private function rollOut_back(param1:Event) : void
      {
         TipControl.hide();
      }
      
      public function nextEnd(param1:Event) : void
      {
         if(this._page == this._countPage)
         {
            return;
         }
         var _loc2_:ViewEvent = new ViewEvent("nextEnd");
         _loc2_.data = this.searchInputer.text;
         this.dispatchEvent(_loc2_);
         this.loading.visible = MData.getInstance().mainData.getFriendListLoading;
      }
      
      private function onRollOver(param1:MouseEvent) : void
      {
         Cursor.useSystem();
      }
      
      public function next(param1:Event) : void
      {
         if(this._page == this._countPage)
         {
            return;
         }
         var _loc2_:ViewEvent = new ViewEvent("next");
         _loc2_.data = this.searchInputer.text;
         this.dispatchEvent(_loc2_);
         this.loading.visible = MData.getInstance().mainData.getFriendListLoading;
      }
      
      public function show(param1:Array, param2:int, param3:int) : void
      {
         this.page = param2;
         this.countPage = param3;
         if(param1 == null)
         {
            throw new Error("show(参数) --> 参数错误!");
         }
         this.del();
         this.childContainer.vScrollPosition = 0;
         this._friendList = [];
         var _loc4_:int = 0;
         while(_loc4_ < param1.length)
         {
            this._friendList.push(param1[_loc4_]);
            _loc4_++;
         }
         if(this.currentlyTimer != null)
         {
            this.currentlyTimer.stop();
            this.currentlyTimer = null;
         }
         var _loc5_:int = 10;
         if(this._friendList.length < 10)
         {
            _loc5_ = int(this._friendList.length);
         }
         var _loc6_:int = 0;
         while(_loc6_ < _loc5_)
         {
            this.add(null);
            _loc6_++;
         }
      }
      
      public function back(param1:Event) : void
      {
         if(this._page == 1)
         {
            return;
         }
         var _loc2_:ViewEvent = new ViewEvent("back");
         _loc2_.data = this.searchInputer.text;
         this.dispatchEvent(_loc2_);
         this.loading.visible = MData.getInstance().mainData.getFriendListLoading;
      }
   }
}

