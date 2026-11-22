package module.shop
{
   import com.qzone.qui.containers.ViewStack;
   import com.qzone.qui.controls.Label;
   import com.qzone.qui.controls.TabBar;
   import com.qzone.qui.styles.Style;
   import com.qzone.utils.AlignUtil;
   import common.CommonData;
   import common.Consts;
   import common.Language;
   import common.Session;
   import common.Settings;
   import common.misc.Utils;
   import common.view.window.BaseWindow;
   import common.view.window.WindowTabBarMaker;
   import entities.AdItem;
   import entities.DIYDecor;
   import entities.Item;
   import entities.Seed;
   import entities.ShopFish;
   import events.CommonEvent;
   import events.ViewEvent;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.TextEvent;
   import flash.external.ExternalInterface;
   import flash.net.URLRequest;
   import flash.net.sendToURL;
   import flash.text.StyleSheet;
   import flash.text.TextFormat;
   import flash.utils.setTimeout;
   import framework.base.BasePage;
   import framework.base.BaseTileItem;
   import interfaces.IMsgCenter;
   import module.GameGuide;
   import module.shop.widgets.*;
   
   public class ShopView extends BaseWindow
   {
      
      private var m_viewStack:ViewStack;
      
      private var m_buyFishWin:BuyFishWindow;
      
      private var m_fishPage:FishPage;
      
      private var m_adSeedsPage:AdSeedsPage;
      
      public var showArrowOnClose:int;
      
      private var m_buyAdSeedWin:BuyAdSeedWindow;
      
      private var m_unlockFishWin:UnlockFishWindow;
      
      private var m_controller:ShopController;
      
      private var m_buyToolWin:BuyItemWindow;
      
      private var m_cropPage:ShopSeedsPage;
      
      private var m_buySeedWin:BuySeedWindow;
      
      private var fishTabNewIcon:MovieClip;
      
      private var m_toolPage:ItemsPage;
      
      private var m_advertisementPage:AdvertisementPage;
      
      private var m_tabNav:TabBar;
      
      private var m_diyPage:DiyPage;
      
      private var m_buyDiyWin:BuyDiyWindow;
      
      public function ShopView(param1:ShopController)
      {
         super(param1.module.app as IMsgCenter);
         title = Language.L["shopTitle"];
         windowName = Consts.WINDOW_NAME_SHOP;
         width = 500;
         height = 390;
         mode = true;
         this.m_buySeedWin = null;
         this.m_buyToolWin = null;
         this.m_buyDiyWin = null;
         this.m_advertisementPage = null;
         this.m_controller = param1;
         this.showArrowOnClose = 0;
      }
      
      private function onLoadFailed(param1:CommonEvent) : void
      {
         if(param1 == null || param1.data == null)
         {
            return;
         }
         var _loc2_:int = param1.data["index"] as int;
         var _loc3_:String = param1.data["error"] as String;
         if(_loc2_ == 0)
         {
            if(this.m_cropPage != null)
            {
               this.m_cropPage.errText = _loc3_;
            }
         }
         else if(_loc2_ == 2)
         {
            if(this.m_toolPage != null)
            {
               this.m_toolPage.errText = _loc3_;
            }
         }
         else if(_loc2_ == 3)
         {
            if(this.m_diyPage != null)
            {
               this.m_diyPage.errText = _loc3_;
            }
         }
         else if(_loc2_ == 4)
         {
            if(this.m_advertisementPage != null)
            {
               this.m_advertisementPage.loadingVisible = false;
               this.m_advertisementPage.errText = _loc3_;
            }
         }
         else if(_loc2_ == 1)
         {
            if(this.m_fishPage != null)
            {
               this.m_fishPage.errText = _loc3_;
            }
         }
         else if(_loc2_ == 5)
         {
            if(this.m_adSeedsPage != null)
            {
               this.m_adSeedsPage.errText = "系统繁忙，请稍后重试";
            }
         }
      }
      
      private function onTileItemClick(param1:ViewEvent) : void
      {
         var _loc3_:Seed = null;
         var _loc4_:DIYDecor = null;
         var _loc5_:AdItem = null;
         var _loc6_:ShopFish = null;
         if(param1 == null || param1.target == null)
         {
            return;
         }
         var _loc2_:* = param1.target;
         if(_loc2_ is CropItem || _loc2_ is CropItemVip)
         {
            _loc3_ = param1.data as Seed;
            if(_loc3_ == null)
            {
               return;
            }
            if(_loc3_._isAdSeed != 1)
            {
               if(this.m_buySeedWin == null)
               {
                  this.m_buySeedWin = new BuySeedWindow(this);
               }
               this.controller.module.app.farmView.winCtrl.open(this.m_buySeedWin);
               this.m_buySeedWin.data = _loc3_;
            }
            else
            {
               if(this.m_buyAdSeedWin == null)
               {
                  this.m_buyAdSeedWin = new BuyAdSeedWindow(this);
               }
               this.controller.module.app.farmView.winCtrl.open(this.m_buyAdSeedWin);
               this.m_buyAdSeedWin.data = _loc3_;
               setTimeout(this.onSendToURLTimeout,500,_loc3_._rl);
            }
         }
         else if(_loc2_ is ToolItem)
         {
            this.showBuyItemWindow(param1.data as Item,false);
         }
         else if(_loc2_ is DiyItem)
         {
            _loc4_ = param1.data as DIYDecor;
            if(_loc4_ == null)
            {
               return;
            }
            if(this.m_buyDiyWin == null)
            {
               this.m_buyDiyWin = new BuyDiyWindow(this);
            }
            this.controller.module.app.farmView.winCtrl.open(this.m_buyDiyWin);
            this.m_buyDiyWin.data = _loc4_;
         }
         else if(_loc2_ is AdvertisementItem)
         {
            _loc5_ = new AdItem(param1.data);
            if(_loc5_ == null)
            {
               return;
            }
            ExternalInterface.call("window.open",_loc5_._rl);
            setTimeout(this.onSendToURLTimeout,500,_loc5_._acurl);
         }
         else if(_loc2_ is FishItem)
         {
            _loc6_ = param1.data as ShopFish;
            if(_loc6_ == null)
            {
               return;
            }
            if(_loc6_._lock == 1)
            {
               if(this.m_buyFishWin == null)
               {
                  this.m_buyFishWin = new BuyFishWindow(this);
               }
               this.controller.module.app.farmView.winCtrl.open(this.m_buyFishWin);
               this.m_buyFishWin.data = _loc6_;
            }
            else
            {
               if(this.m_unlockFishWin == null)
               {
                  this.m_unlockFishWin = new UnlockFishWindow(this);
               }
               this.controller.module.app.farmView.winCtrl.open(this.m_unlockFishWin);
               this.m_unlockFishWin.data = _loc6_;
            }
         }
      }
      
      public function get currentPageIndex() : int
      {
         if(this.m_tabNav == null)
         {
            return -1;
         }
         return this.m_tabNav.selectedIndex;
      }
      
      public function showBuyItemWindow(param1:Item, param2:Boolean) : void
      {
         if(param1 == null)
         {
            return;
         }
         if(param1._type == 909090 && param2 == true)
         {
            this.controller.module.app.dispatchEvent(new Event(Consts.MSG_REFRSH_MY_DOG_FOOD));
         }
         if(this.m_buyToolWin == null)
         {
            this.m_buyToolWin = new BuyItemWindow(this);
         }
         this.controller.module.app.farmView.winCtrl.open(this.m_buyToolWin);
         this.m_buyToolWin.data = param1;
      }
      
      public function getTabPage(param1:int) : BasePage
      {
         if(param1 == 0)
         {
            return this.m_cropPage;
         }
         if(param1 == 2)
         {
            return this.m_toolPage;
         }
         if(param1 == 3)
         {
            return this.m_diyPage;
         }
         if(param1 == 4)
         {
            return this.m_advertisementPage;
         }
         if(param1 == 1)
         {
            return this.m_fishPage;
         }
         return null;
      }
      
      override protected function init() : void
      {
         super.init();
         this.createView();
         this.addAdvertiseLink();
         var _loc1_:ShopModel = this.m_controller.model;
         if(_loc1_ != null)
         {
            _loc1_.addEventListener(ShopModel.EVENT_SHOP_DATA_LOADED,this.onDataLoaded,false,0,true);
            _loc1_.addEventListener(ShopModel.EVENT_SHOP_DATA_FAILED,this.onLoadFailed,false,0,true);
            _loc1_.addEventListener(ShopModel.EVENT_SHOP_DATA_LOADING,this.onDataLoading,false,0,true);
            _loc1_.addEventListener(ShopModel.EVENT_SHOP_DIY_OWN_LOADED,this.onDiyDataLoaded,false,0,true);
         }
      }
      
      public function set currentPageIndex(param1:int) : void
      {
         if(this.m_tabNav)
         {
            this.m_tabNav.selectedIndex = param1;
         }
      }
      
      private function onDataLoaded(param1:CommonEvent) : void
      {
         var _loc4_:String = null;
         if(param1 == null || param1.data == null)
         {
            return;
         }
         var _loc2_:int = param1.data["index"] as int;
         var _loc3_:Array = param1.data["data"] as Array;
         if(_loc2_ == 0)
         {
            if(this.m_cropPage != null)
            {
               this.m_cropPage.loadingVisible = false;
               this.m_cropPage.dataList = _loc3_;
            }
         }
         else if(_loc2_ == 2)
         {
            if(this.m_toolPage != null)
            {
               this.m_toolPage.loadingVisible = false;
               this.m_toolPage.dataList = _loc3_;
            }
         }
         else if(_loc2_ == 3)
         {
            if(this.m_diyPage != null)
            {
               this.m_diyPage.loadingVisible = false;
               this.m_diyPage.dataList = _loc3_;
               this.m_controller.model.loadDecorsItemOwnInfo();
            }
         }
         else if(_loc2_ == 4)
         {
            if(this.m_advertisementPage != null)
            {
               this.m_advertisementPage.loadingVisible = false;
               this.m_advertisementPage.dataList = _loc3_;
            }
         }
         else if(_loc2_ == 1)
         {
            if(this.m_fishPage != null)
            {
               this.m_fishPage.loadingVisible = false;
               this.m_fishPage.dataList = _loc3_;
            }
            if(this.m_tabNav.selectedIndex == 1 && _loc3_ != null && _loc3_.length > 0)
            {
               _loc4_ = _loc3_[0]["_lock"] == 0 ? "点击查看解锁条件" : "";
               GameGuide.instance().showStep(GameGuide.WATER_FISH_ITEM,0,0,_loc4_);
               GameGuide.instance().autoHide(5);
            }
         }
         else if(_loc2_ == 5)
         {
            if(this.m_adSeedsPage != null)
            {
               this.m_adSeedsPage.dataList = _loc3_;
               if(!_loc3_ || _loc3_.length <= 0)
               {
                  this.m_adSeedsPage.loadingVisible = true;
                  this.m_adSeedsPage.errText = "暂未有合作物品，敬请期待";
               }
               else
               {
                  this.m_adSeedsPage.loadingVisible = false;
                  this.m_adSeedsPage.errText = "";
               }
            }
         }
      }
      
      private function onFishUILoaded(param1:Object) : void
      {
         var _loc2_:ShopModel = null;
         if(this.m_tabNav.selectedIndex == 1)
         {
            _loc2_ = this.m_controller.model;
            if(_loc2_.isEmpty(4) == false)
            {
               this.m_fishPage.dataList = _loc2_.fishs;
            }
         }
      }
      
      private function addAdvertiseLink() : void
      {
         var _loc2_:String = null;
         var _loc3_:Label = null;
         var _loc4_:StyleSheet = null;
         var _loc1_:String = Settings.getInstance().getDynamicTip("shopLinkTip");
         if(_loc1_ != "")
         {
            _loc2_ = Settings.getInstance().getDynamicTip("shopLinkTip",Settings.TIP_URL);
            _loc3_ = new Label();
            _loc3_.mouseChildren = true;
            if(_loc2_)
            {
               _loc3_.text = "<a target=\"_blank\" href=\"event:" + _loc2_ + "\">" + _loc1_ + "</a>";
            }
            else
            {
               _loc3_.textDefaultFormat = new TextFormat(Style.fontFace,Style.fontSize,16711680,null,null,null,null,null,"left");
               _loc3_.text = _loc1_;
            }
            _loc3_.y = 36;
            _loc3_.x = AlignUtil.right(this.width,_loc3_.width) - 6;
            _loc3_.textField.addEventListener(TextEvent.LINK,this.onNavigateToURL);
            this.addChild(_loc3_);
            _loc4_ = new StyleSheet();
            _loc4_.parseCSS("a:link {color:#FF0000;font-family:\"Arial Black\";} a:hover{text-decoration:underline;color:#FF0000;}");
            _loc3_.textField.styleSheet = _loc4_;
         }
      }
      
      public function get controller() : ShopController
      {
         return this.m_controller;
      }
      
      public function get currentPage() : BasePage
      {
         if(this.m_tabNav == null)
         {
            return null;
         }
         return this.getTabPage(this.m_tabNav.selectedIndex);
      }
      
      private function onTabSwitched(param1:Event) : void
      {
         if(param1 == null || param1.currentTarget == null)
         {
            return;
         }
         var _loc2_:ShopModel = this.m_controller.model;
         if(param1.currentTarget.selectedIndex == 0)
         {
            if(_loc2_.isEmpty(0) == true)
            {
               _loc2_.loadSeedsInfo();
            }
         }
         else if(param1.currentTarget.selectedIndex == 1)
         {
            if(!Session.getInstance().m_waterPoolOpen)
            {
               this.m_fishPage.errText = "您的池塘未开通，无法购买鱼苗，请开通池塘之后再来购买。";
               return;
            }
            this.m_fishPage.errText = "";
            if(_loc2_.isEmpty(4) == true)
            {
               _loc2_.loadFishInfo();
            }
         }
         else if(param1.currentTarget.selectedIndex == 2)
         {
            if(_loc2_.isEmpty(1) == true)
            {
               _loc2_.loadItemsInfo();
            }
         }
         else if(param1.currentTarget.selectedIndex == 3)
         {
            if(_loc2_.isEmpty(2) == true)
            {
               _loc2_.loadDecorsInfo();
            }
         }
         else if(param1.currentTarget.selectedIndex == 4)
         {
            _loc2_.loadAdvertisementInfo();
         }
         else if(param1.currentTarget.selectedIndex == 5)
         {
            _loc2_.loadAdvertisementSeedsList();
         }
      }
      
      private function fishLinkClick(param1:ViewEvent) : void
      {
         if(param1 == null || param1.data == null)
         {
            return;
         }
         if(param1.data == "reload")
         {
            this.m_controller.model.loadFishInfo();
         }
      }
      
      private function createView() : void
      {
         this.m_viewStack = new ViewStack();
         this.m_tabNav = new TabBar();
         this.m_tabNav.viewStack = this.m_viewStack;
         WindowTabBarMaker.addTarget(this.m_tabNav);
         this.m_tabNav.paddingH = 18;
         this.m_tabNav.x = 0;
         this.m_tabNav.y = 33;
         this.m_tabNav.width = width - 2;
         this.m_tabNav.addEventListener(Event.CHANGE,this.onTabSwitched);
         this.m_viewStack.y = this.m_tabNav.y + this.m_tabNav.height;
         this.m_viewStack.width = width - 2;
         this.m_viewStack.height = height - this.m_viewStack.y;
         var _loc1_:ShopModel = this.m_controller.model;
         if(_loc1_ == null)
         {
            return;
         }
         this.m_cropPage = new ShopSeedsPage(this,500,320);
         this.m_cropPage.addEventListener(ViewEvent.LINK_CLICK,this.cropLinkClick,false,0,true);
         this.m_cropPage.addEventListener(BaseTileItem.CHILD_CLICK,this.onTileItemClick,true,0,true);
         this.m_cropPage.addEventListener(BaseTileItem.CHILD_OVER,this.onTileItemOver,true,0,true);
         this.m_cropPage.addEventListener(BaseTileItem.CHILD_OUT,this.onTileItemOut,true,0,true);
         if(_loc1_.isEmpty(0) == false)
         {
            this.m_cropPage.dataList = _loc1_.seeds;
         }
         this.m_tabNav.addTab(Language.L["shopTagSell"],NaN,24);
         this.m_viewStack.addView(this.m_cropPage);
         this.m_fishPage = new FishPage(this,500,320);
         this.m_fishPage.addEventListener(ViewEvent.LINK_CLICK,this.fishLinkClick,false,0,true);
         this.m_fishPage.addEventListener(BaseTileItem.CHILD_CLICK,this.onTileItemClick,true,0,true);
         this.m_fishPage.addEventListener(BaseTileItem.CHILD_OVER,this.onTileItemOver,true,0,true);
         this.m_fishPage.addEventListener(BaseTileItem.CHILD_OUT,this.onTileItemOut,true,0,true);
         if(_loc1_.isEmpty(4) == false)
         {
            this.m_fishPage.dataList = _loc1_.fishs;
         }
         this.m_tabNav.addTab("鱼苗",NaN,24);
         this.m_viewStack.addView(this.m_fishPage);
         this.m_toolPage = new ItemsPage(this,500,320);
         this.m_toolPage.addEventListener(ViewEvent.LINK_CLICK,this.toolLinkClick,false,0,true);
         this.m_toolPage.addEventListener(BaseTileItem.CHILD_CLICK,this.onTileItemClick,true,0,true);
         this.m_toolPage.addEventListener(BaseTileItem.CHILD_OVER,this.onTileItemOver,true,0,true);
         this.m_toolPage.addEventListener(BaseTileItem.CHILD_OUT,this.onTileItemOut,true,0,true);
         if(_loc1_.isEmpty(1) == false)
         {
            this.m_toolPage.dataList = _loc1_.items;
         }
         this.m_tabNav.addTab(Language.L["shopTagFertilizer"],NaN,24);
         this.m_viewStack.addView(this.m_toolPage);
         this.m_diyPage = new DiyPage(this,500,320);
         this.m_diyPage.addEventListener(ViewEvent.LINK_CLICK,this.diyLinkClick,false,0,true);
         this.m_diyPage.addEventListener(BaseTileItem.CHILD_CLICK,this.onTileItemClick,true,0,true);
         this.m_diyPage.addEventListener(BaseTileItem.CHILD_OVER,this.onTileItemOver,true,0,true);
         this.m_diyPage.addEventListener(BaseTileItem.CHILD_OUT,this.onTileItemOut,true,0,true);
         if(_loc1_.isEmpty(2) == false)
         {
            this.m_diyPage.dataList = _loc1_.decors;
         }
         this.m_tabNav.addTab(Language.L["shopTagDecorate"],NaN,24);
         this.m_viewStack.addView(this.m_diyPage);
         if(Session.getInstance().host.level >= Settings.getInstance().snsAdAllowLvl)
         {
            this.m_advertisementPage = new AdvertisementPage(this,500,320);
            this.m_advertisementPage.addEventListener(ViewEvent.LINK_CLICK,this.toolLinkClick,false,0,true);
            this.m_advertisementPage.addEventListener(BaseTileItem.CHILD_CLICK,this.onTileItemClick,true,0,true);
            if(_loc1_.isEmpty(3) == false)
            {
               this.m_advertisementPage.dataList = _loc1_.advertisements;
            }
            this.m_tabNav.addTab(Language.L["shopTagAdvertisement"],NaN,24);
            this.m_viewStack.addView(this.m_advertisementPage);
         }
         if(Settings.getInstance().getStringAttribute("adSeedTabOpen") == "1")
         {
            this.m_adSeedsPage = new AdSeedsPage(this,500,320);
            this.m_adSeedsPage.addEventListener(ViewEvent.LINK_CLICK,this.diyLinkClick,false,0,true);
            this.m_adSeedsPage.addEventListener(BaseTileItem.CHILD_CLICK,this.onTileItemClick,true,0,true);
            this.m_adSeedsPage.addEventListener(BaseTileItem.CHILD_OVER,this.onTileItemOver,true,0,true);
            this.m_adSeedsPage.addEventListener(BaseTileItem.CHILD_OUT,this.onTileItemOut,true,0,true);
            this.m_tabNav.addTab("合作专区",NaN,24);
            this.m_viewStack.addView(this.m_adSeedsPage);
         }
         addChild(this.m_viewStack);
         addChild(this.m_tabNav);
         this.loadFishUIRes();
      }
      
      private function loadFishUIRes() : void
      {
         var _loc1_:String = Settings.getInstance().getSecondUrl("water_ui");
         if(_loc1_ == null || _loc1_ == "")
         {
            return;
         }
         CommonData.rslManager.requestFile(_loc1_,this.onFishUILoaded);
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
            if(this.m_cropPage != null)
            {
               this.m_cropPage.loadingVisible = _loc3_;
            }
         }
         else if(_loc2_ == 2)
         {
            if(this.m_toolPage != null)
            {
               this.m_toolPage.loadingVisible = _loc3_;
            }
         }
         else if(_loc2_ == 3)
         {
            if(this.m_diyPage != null)
            {
               this.m_diyPage.loadingVisible = _loc3_;
            }
         }
         else if(_loc2_ == 4)
         {
            if(this.m_advertisementPage != null)
            {
               this.m_advertisementPage.loadingVisible = _loc3_;
            }
         }
         else if(_loc2_ == 1)
         {
            if(this.m_fishPage != null)
            {
               this.m_fishPage.loadingVisible = _loc3_;
            }
         }
         else if(_loc2_ == 5)
         {
            if(this.m_adSeedsPage != null)
            {
               this.m_adSeedsPage.loadingVisible = _loc3_;
            }
         }
      }
      
      private function onTileItemOver(param1:ViewEvent) : void
      {
         var _loc3_:Seed = null;
         var _loc4_:Item = null;
         var _loc5_:DIYDecor = null;
         var _loc6_:ShopFish = null;
         if(param1 == null || param1.target == null)
         {
            return;
         }
         var _loc2_:* = param1.target;
         if(_loc2_ is CropItem || _loc2_ is CropItemVip)
         {
            _loc3_ = param1.data as Seed;
            if(_loc3_ == null)
            {
               return;
            }
            this.m_controller.showTip(Consts.TIP_NAME_MOUSE,_loc3_._name + "\n预计所得：" + _loc3_._expect);
         }
         else if(_loc2_ is ToolItem)
         {
            _loc4_ = param1.data as Item;
            if(_loc4_ == null)
            {
               return;
            }
            this.m_controller.showTip(Consts.TIP_NAME_MOUSE,_loc4_._name + "\n" + _loc4_._desc);
         }
         else if(_loc2_ is DiyItem)
         {
            _loc5_ = param1.data as DIYDecor;
            if(_loc5_ == null)
            {
               return;
            }
            this.m_controller.showTip(Consts.TIP_NAME_MOUSE,_loc5_._name + "\n可得经验：" + _loc5_._exp);
         }
         else if(_loc2_ is FishItem)
         {
            _loc6_ = param1.data as ShopFish;
            if(_loc6_._lock == 1)
            {
               this.m_controller.showTip(Consts.TIP_NAME_MOUSE,_loc6_._name + "\n预计所得：" + (_loc6_._output * _loc6_._sale).toString());
            }
            else if(_loc6_._lock == 0)
            {
               this.m_controller.showTip(Consts.TIP_NAME_MOUSE,"锁定中");
            }
            else if(_loc6_._lock == 2)
            {
               this.m_controller.showTip(Consts.TIP_NAME_MOUSE,"可解锁");
            }
         }
      }
      
      private function onTileItemOut(param1:ViewEvent) : void
      {
         if(param1 == null || param1.target == null)
         {
            return;
         }
         var _loc2_:* = param1.target;
         if(_loc2_ is CropItem || _loc2_ is CropItemVip)
         {
            this.m_controller.hideTip();
         }
         else if(_loc2_ is ToolItem)
         {
            this.m_controller.hideTip();
         }
         else if(_loc2_ is DiyItem)
         {
            this.m_controller.hideTip();
         }
         else if(_loc2_ is FishItem)
         {
            this.m_controller.hideTip();
         }
      }
      
      private function addNewIcon() : void
      {
         this.fishTabNewIcon = Utils.getMaterial("ShopTabNewIcon") as MovieClip;
         if(this.fishTabNewIcon == null)
         {
            return;
         }
         this.fishTabNewIcon.x = 128;
         this.fishTabNewIcon.y = 28;
         addChild(this.fishTabNewIcon);
      }
      
      override protected function onClose(param1:Event) : void
      {
         super.onClose(param1);
         GameGuide.instance().hide();
         if(this.showArrowOnClose == 1)
         {
            GameGuide.instance().showStep(GameGuide.WATER_BAG_ICON_FISH);
            GameGuide.instance().autoHide(5);
         }
      }
      
      public function setDiyBought(param1:int) : void
      {
         var _loc2_:Array = this.m_controller.model.decors;
         var _loc3_:int = int(_loc2_.length);
         var _loc4_:int = 0;
         while(_loc4_ < _loc3_)
         {
            if(_loc2_[_loc4_]["_id"] == param1)
            {
               _loc2_[_loc4_]["_alreadyOwn"] = true;
               break;
            }
            _loc4_++;
         }
         this.m_diyPage.dataList = _loc2_;
      }
      
      private function onDiyDataLoaded(param1:CommonEvent) : void
      {
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         if(param1 == null || param1.data == null)
         {
            return;
         }
         var _loc2_:Array = param1.data["data"] as Array;
         var _loc3_:Array = this.m_controller.model.decors;
         if(_loc2_ != null)
         {
            if(_loc3_ != null)
            {
               _loc4_ = int(_loc3_.length);
               _loc5_ = 0;
               while(_loc5_ < _loc4_)
               {
                  if(_loc3_[_loc5_] != null && _loc2_.indexOf(_loc3_[_loc5_]["_id"]) != -1)
                  {
                     _loc3_[_loc5_]["_alreadyOwn"] = true;
                  }
                  _loc5_++;
               }
            }
         }
         this.m_diyPage.dataList = _loc3_;
      }
      
      public function showBuySeedWindow(param1:Seed) : void
      {
         if(param1 == null)
         {
            return;
         }
         if(this.m_buySeedWin == null)
         {
            this.m_buySeedWin = new BuySeedWindow(this);
         }
         this.controller.module.app.farmView.winCtrl.open(this.m_buySeedWin);
         this.m_buySeedWin.data = param1;
      }
      
      private function onNavigateToURL(param1:TextEvent) : void
      {
         var _loc2_:String = param1.text;
         if(_loc2_ == "" || ExternalInterface.available == false)
         {
            return;
         }
         ExternalInterface.call("window.open",_loc2_);
      }
      
      private function toolLinkClick(param1:ViewEvent) : void
      {
         if(param1 == null || param1.data == null)
         {
            return;
         }
         if(param1.data == "reload")
         {
            this.m_controller.model.loadItemsInfo();
         }
      }
      
      private function diyLinkClick(param1:ViewEvent) : void
      {
         if(param1 == null || param1.data == null)
         {
            return;
         }
         if(param1.data == "reload")
         {
            this.m_controller.model.loadDecorsInfo();
         }
      }
      
      private function onSendToURLTimeout() : void
      {
         if(arguments[0] == null || arguments[0] == "")
         {
            return;
         }
         sendToURL(new URLRequest(arguments[0]));
      }
      
      private function cropLinkClick(param1:ViewEvent) : void
      {
         if(param1 == null || param1.data == null)
         {
            return;
         }
         if(param1.data == "reload")
         {
            this.m_controller.model.loadSeedsInfo();
         }
      }
   }
}

