package module.warehouse.house
{
   import com.qzone.qui.containers.ViewStack;
   import com.qzone.qui.controls.Label;
   import com.qzone.qui.controls.TabBar;
   import com.qzone.utils.AlignUtil;
   import common.Consts;
   import common.Language;
   import common.misc.QzoneJSAPI;
   import common.view.window.BaseWindow;
   import common.view.window.WindowControl;
   import common.view.window.WindowTabBarMaker;
   import entities.WarehouseCrop;
   import entities.WarehouseFish;
   import entities.WarehouseSeed;
   import events.CommonEvent;
   import events.ViewEvent;
   import flash.events.Event;
   import flash.events.TextEvent;
   import flash.text.TextFormat;
   import framework.base.BasePage;
   import framework.base.BaseTileItem;
   import interfaces.IMsgCenter;
   import module.warehouse.house.widgets.*;
   
   public class WarehouseView extends BaseWindow
   {
      
      private var m_viewStack:ViewStack;
      
      private var m_fishPage:WarehouseFishPage;
      
      private var m_flowerPage:PlantsPage;
      
      private var m_sellSeedWin:SellToolWindow;
      
      private var m_sellCropWin:SellPlantWindow;
      
      private var m_recvFlowerPage:RecvFlowersPage;
      
      private var m_controller:WarehouseController;
      
      private var m_seedPage:WarehouseSeedsPage;
      
      private var m_sellMaterialWin:SellPlantWindow;
      
      private var m_txtSendFlower:Label;
      
      private var m_cardPage:CardsPage;
      
      private var m_cropPage:PlantsPage;
      
      private var m_tabNav:TabBar;
      
      private var m_sellFishWin:SellFishWindow;
      
      public function WarehouseView(param1:WarehouseController)
      {
         super(param1.module.app as IMsgCenter);
         width = 500;
         height = 392;
         title = Language.L["warehouseTitle"];
         windowName = Consts.WINDOW_NAME_WAREHOUSE;
         mode = true;
         titleDefautFormat = new TextFormat("Verdana",16,16777215,true);
         this.m_sellCropWin = null;
         this.m_sellMaterialWin = null;
         this.m_sellSeedWin = null;
         this.m_sellFishWin = null;
         this.m_controller = param1;
         m_msgCenter.addEventListener(EvtAPI.REFRESH_CRYSTAL,this.onCrystalDataChanged,false,0,true);
         m_msgCenter.addEventListener(Consts.MSG_HIDE_WAREHOUSE,this.closeHandler,false,0,true);
         param1.model.addEventListener(EvtAPI.REFRESH_CRYSTAL,this.onCrystalDataChanged);
         param1.model.addEventListener(WarehouseModel.EVENT_UPDATELOCK_SUCCESS,this.onUpdateLock);
         param1.model.addEventListener(WarehouseModel.EVENT_UPDATEFISHLOCK_SUCCESS,this.onUpdateFishLock);
      }
      
      private function onTileItemClick(param1:ViewEvent) : void
      {
         if(param1 == null || param1.data == null)
         {
            return;
         }
         var _loc2_:WindowControl = this.controller.module.app.farmView.winCtrl;
         if(_loc2_ == null)
         {
            return;
         }
         if(param1.data is WarehouseCrop)
         {
            if(WarehouseCrop(param1.data)._type.toString() == Consts.ITEM_TYPE_CARD || WarehouseCrop(param1.data)._type.toString() == Consts.ITEM_TYPE_CRYSTAL)
            {
               if(this.m_sellMaterialWin == null)
               {
                  this.m_sellMaterialWin = new SellPlantWindow(this,true);
               }
               _loc2_.open(this.m_sellMaterialWin);
               this.m_sellMaterialWin.data = param1.data;
            }
            else
            {
               if(this.m_sellCropWin == null)
               {
                  this.m_sellCropWin = new SellPlantWindow(this);
               }
               _loc2_.open(this.m_sellCropWin);
               this.m_sellCropWin.data = param1.data;
            }
         }
         else if(param1.data is WarehouseFish)
         {
            if(this.m_sellFishWin == null)
            {
               this.m_sellFishWin = new SellFishWindow(this);
            }
            _loc2_.open(this.m_sellFishWin);
            this.m_sellFishWin.data = param1.data;
         }
         else
         {
            if(this.m_sellSeedWin == null)
            {
               this.m_sellSeedWin = new SellToolWindow(this);
            }
            _loc2_.open(this.m_sellSeedWin);
            this.m_sellSeedWin.data = param1.data;
         }
      }
      
      private function onLoadFailed(param1:CommonEvent) : void
      {
         if(param1 == null || param1.data == null)
         {
            return;
         }
         var _loc2_:int = int(param1.data["index"]);
         var _loc3_:String = param1.data["error"];
         var _loc4_:int = int(this.m_tabNav.selectedIndex);
         if(_loc2_ == 0 || _loc2_ == 1)
         {
            if(_loc4_ == 0)
            {
               this.m_cropPage.errText = _loc3_;
            }
            else if(_loc4_ == 1)
            {
               this.m_flowerPage.errText = _loc3_;
            }
         }
         else if(_loc4_ == 2)
         {
            this.m_seedPage.errText = _loc3_;
         }
      }
      
      public function getTabPage(param1:int) : BasePage
      {
         if(param1 == 0)
         {
            return this.m_cropPage;
         }
         if(param1 == 1)
         {
            return this.m_flowerPage;
         }
         if(param1 == 2)
         {
            return this.m_fishPage;
         }
         if(param1 == 3)
         {
            return this.m_recvFlowerPage;
         }
         if(param1 == 4)
         {
            return this.m_seedPage;
         }
         return this.m_cardPage;
      }
      
      private function onLinkClick(param1:ViewEvent) : void
      {
         if(param1 == null || param1.data == null)
         {
            return;
         }
         if(param1.data == "reload")
         {
            if(param1.target == this.m_cropPage)
            {
               this.m_controller.model.loadCrops();
            }
            else if(param1.target == this.m_flowerPage)
            {
               this.m_controller.model.loadCrops();
            }
            else if(param1.target == this.m_seedPage)
            {
               this.m_controller.model.loadSeeds();
            }
         }
      }
      
      public function showSellSeedWindow(param1:WarehouseCrop) : void
      {
         var _loc2_:WindowControl = this.controller.module.app.farmView.winCtrl;
         if(this.m_sellCropWin == null)
         {
            this.m_sellCropWin = new SellPlantWindow(this);
         }
         _loc2_.open(this.m_sellCropWin);
         this.m_sellCropWin.data = param1;
      }
      
      override protected function init() : void
      {
         super.init();
         this.createTabs();
         if(QzoneJSAPI.WB == false && QzoneJSAPI.QPLUS == false)
         {
            this.m_txtSendFlower = new Label();
            this.m_txtSendFlower.text = "<a href=\'event:give\'>将鲜花包装成花束送给好友吧！</a>";
            this.m_txtSendFlower.x = AlignUtil.right(this.width,this.m_txtSendFlower.width);
            this.m_txtSendFlower.y = 35;
            this.m_txtSendFlower.mouseChildren = true;
            this.m_txtSendFlower.addEventListener(TextEvent.LINK,this.onSendFlowerLink);
            addChild(this.m_txtSendFlower);
         }
         var _loc1_:WarehouseModel = this.m_controller.model;
         if(_loc1_ != null)
         {
            _loc1_.addEventListener(WarehouseModel.EVENT_DATA_CHANGED,this.onDataChanged);
            _loc1_.addEventListener(WarehouseModel.EVENT_DATA_FAILED,this.onLoadFailed);
            _loc1_.addEventListener(WarehouseModel.EVENT_DATA_LOADING,this.onDataLoading);
            _loc1_.addEventListener(WarehouseModel.EVENT_SENDFLOWER_SUCCESS,this.onFlowerSendout);
         }
      }
      
      private function createTabs() : void
      {
         this.m_viewStack = new ViewStack();
         this.m_tabNav = new TabBar();
         this.m_tabNav.viewStack = this.m_viewStack;
         WindowTabBarMaker.addTarget(this.m_tabNav);
         this.m_tabNav.height = 25;
         this.m_tabNav.paddingH = 20;
         this.m_tabNav.gapH = 3;
         this.m_tabNav.x = 0;
         this.m_tabNav.y = 33;
         this.m_tabNav.width = width - 2;
         this.m_viewStack.y = this.m_tabNav.y + this.m_tabNav.height;
         this.m_viewStack.width = width - 2;
         this.m_viewStack.height = height - this.m_viewStack.y;
         this.m_tabNav.addEventListener(Event.CHANGE,this.onTabSwitched);
         var _loc1_:WarehouseModel = this.m_controller.model;
         if(_loc1_ == null)
         {
            return;
         }
         this.m_cropPage = new PlantsPage(this,496,324,false);
         this.m_cropPage.addEventListener(ViewEvent.LINK_CLICK,this.onLinkClick,false,0,true);
         this.m_cropPage.addEventListener(PlantRenderItem.LOCK_ICON_CLICKED,this.onLockClicked,false,0,true);
         this.m_cropPage.addEventListener(BaseTileItem.CHILD_CLICK,this.onTileItemClick,false,0,true);
         this.m_cropPage.addEventListener(BaseTileItem.CHILD_OVER,this.onTileItemOver,false,0,true);
         this.m_cropPage.addEventListener(BaseTileItem.CHILD_OUT,this.onTileItemOut,false,0,true);
         this.m_tabNav.addTab("蔬果",NaN,24);
         this.m_viewStack.addView(this.m_cropPage);
         this.m_flowerPage = new PlantsPage(this,496,324,true);
         this.m_flowerPage.addEventListener(ViewEvent.LINK_CLICK,this.onLinkClick,false,0,true);
         this.m_flowerPage.addEventListener(PlantRenderItem.LOCK_ICON_CLICKED,this.onLockClicked,false,0,true);
         this.m_flowerPage.addEventListener(BaseTileItem.CHILD_CLICK,this.onTileItemClick,false,0,true);
         this.m_flowerPage.addEventListener(BaseTileItem.CHILD_OVER,this.onTileItemOver,false,0,true);
         this.m_flowerPage.addEventListener(BaseTileItem.CHILD_OUT,this.onTileItemOut,false,0,true);
         this.m_tabNav.addTab("鲜花",NaN,24);
         this.m_viewStack.addView(this.m_flowerPage);
         this.m_fishPage = new WarehouseFishPage(this,496,324);
         this.m_fishPage.addEventListener(ViewEvent.LINK_CLICK,this.onLinkClick,false,0,true);
         this.m_fishPage.addEventListener(PlantRenderItem.LOCK_ICON_CLICKED,this.onLockClicked,false,0,true);
         this.m_fishPage.addEventListener(BaseTileItem.CHILD_CLICK,this.onTileItemClick,false,0,true);
         this.m_fishPage.addEventListener(BaseTileItem.CHILD_OVER,this.onTileItemOver,false,0,true);
         this.m_fishPage.addEventListener(BaseTileItem.CHILD_OUT,this.onTileItemOut,false,0,true);
         this.m_tabNav.addTab("成鱼",NaN,24);
         this.m_viewStack.addView(this.m_fishPage);
         if(QzoneJSAPI.QPLUS == false && QzoneJSAPI.WB == false)
         {
            this.m_recvFlowerPage = new RecvFlowersPage(this,496,324);
            this.m_recvFlowerPage.addEventListener(FlowerRenderItem.CHILD_OVER,this.onTileItemOver,false,0,true);
            this.m_recvFlowerPage.addEventListener(FlowerRenderItem.CHILD_OUT,this.onTileItemOut,false,0,true);
            this.m_tabNav.addTab("收到的花束",NaN,24);
            this.m_viewStack.addView(this.m_recvFlowerPage);
         }
         this.m_seedPage = new WarehouseSeedsPage(this,496,324);
         this.m_seedPage.addEventListener(ViewEvent.LINK_CLICK,this.onLinkClick,false,0,true);
         this.m_seedPage.addEventListener(BaseTileItem.CHILD_CLICK,this.onTileItemClick,false,0,true);
         this.m_seedPage.addEventListener(BaseTileItem.CHILD_OVER,this.onTileItemOver,false,0,true);
         this.m_seedPage.addEventListener(BaseTileItem.CHILD_OUT,this.onTileItemOut,false,0,true);
         this.m_tabNav.addTab("种子",NaN,24);
         this.m_viewStack.addView(this.m_seedPage);
         this.m_cardPage = new CardsPage(this,496,324);
         this.m_cardPage.addEventListener(ViewEvent.LINK_CLICK,this.onLinkClick,false,0,true);
         this.m_cardPage.addEventListener(PlantRenderItem.LOCK_ICON_CLICKED,this.onLockClicked,false,0,true);
         this.m_cardPage.addEventListener(BaseTileItem.CHILD_CLICK,this.onTileItemClick,false,0,true);
         this.m_cardPage.addEventListener(BaseTileItem.CHILD_OVER,this.onTileItemOver,false,0,true);
         this.m_cardPage.addEventListener(BaseTileItem.CHILD_OUT,this.onTileItemOut,false,0,true);
         this.m_tabNav.addTab("材料",NaN,24);
         this.m_viewStack.addView(this.m_cardPage);
         addChild(this.m_viewStack);
         addChild(this.m_tabNav);
      }
      
      private function onLockClicked(param1:CommonEvent) : void
      {
         if(param1 == null || param1.data == null)
         {
            return;
         }
         var _loc2_:WarehouseCrop = param1.data["data"] as WarehouseCrop;
         var _loc3_:Boolean = param1.data["lock"] as Boolean;
         if(_loc2_ == null)
         {
            return;
         }
         this.m_controller.model.storeUserCropLockInfo(_loc2_,_loc3_);
      }
      
      public function get controller() : WarehouseController
      {
         return this.m_controller;
      }
      
      public function refreshItemLockStatus(param1:WarehouseCrop, param2:Boolean) : void
      {
         if(param1 == null)
         {
            return;
         }
         this.m_controller.model.storeUserCropLockInfo(param1,param2);
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
         if(this.m_tabNav == null)
         {
            return;
         }
         var _loc2_:int = int(this.m_tabNav.selectedIndex);
         if(_loc2_ == 0)
         {
            this.m_controller.model.loadCrops();
            if(this.m_txtSendFlower != null)
            {
               this.m_txtSendFlower.text = "<a href=\'event:give\'>将鲜花包装成花束送给好友吧！</a>";
            }
         }
         else if(_loc2_ == 1)
         {
            this.m_controller.model.loadCrops();
            if(this.m_txtSendFlower != null)
            {
               this.m_txtSendFlower.text = "";
            }
         }
         else if(_loc2_ == 2)
         {
            this.m_controller.model.loadFishs();
            if(this.m_txtSendFlower != null)
            {
               this.m_txtSendFlower.text = "";
            }
         }
         else
         {
            if((QzoneJSAPI.QPLUS == true || QzoneJSAPI.WB == true) && (_loc2_ == 3 || _loc2_ == 4))
            {
               _loc2_ += 1;
            }
            if(_loc2_ == 3)
            {
               this.m_controller.model.loadMyFlowers();
               if(this.m_txtSendFlower != null)
               {
                  this.m_txtSendFlower.text = "";
               }
            }
            else if(_loc2_ == 4)
            {
               this.m_controller.model.loadSeeds();
               if(this.m_txtSendFlower != null)
               {
                  this.m_txtSendFlower.text = "";
               }
            }
            else if(_loc2_ == 5)
            {
               this.m_controller.model.loadCrops();
               this.m_controller.model.loadCrystal();
               if(this.m_txtSendFlower != null)
               {
                  this.m_txtSendFlower.text = "";
               }
            }
         }
      }
      
      public function refreshFishLockStatus(param1:WarehouseFish, param2:Boolean) : void
      {
         if(param1 == null)
         {
            return;
         }
         this.m_controller.model.storeUserFishLockInfo(param1,param2);
      }
      
      public function gotoSendFlower() : void
      {
         this.switchTab(1);
         this.m_flowerPage.switchSendFlowerView(true);
      }
      
      public function switchTab(param1:int) : void
      {
         if(param1 < 0 || param1 > this.m_tabNav.tabNum)
         {
            param1 = 0;
         }
         this.m_tabNav.selectedIndex = param1;
      }
      
      private function closeHandler(param1:CommonEvent) : void
      {
         this.visible = false;
         this.close();
      }
      
      private function onDataChanged(param1:CommonEvent) : void
      {
         if(param1 == null || param1.data == null)
         {
            return;
         }
         var _loc2_:int = int(param1.data["index"]);
         if(_loc2_ == 0)
         {
            this.m_cropPage.dataList = this.controller.model.crops;
            this.m_flowerPage.dataList = this.controller.model.flowers;
            this.m_cardPage.dataList = this.controller.model.cards;
         }
         else if(_loc2_ == 1)
         {
            this.m_seedPage.dataList = this.controller.model.seeds;
         }
         else if(_loc2_ == 2)
         {
            if(this.m_recvFlowerPage != null)
            {
               this.m_recvFlowerPage.dataList = this.controller.model.myFlowers;
            }
         }
         else if(_loc2_ == 3)
         {
            this.m_cardPage.dataList = this.controller.model.cards;
         }
         else if(_loc2_ == 5)
         {
            this.m_fishPage.dataList = this.controller.model.fishs;
         }
      }
      
      private function onFlowerSendout(param1:CommonEvent) : void
      {
         if(param1 == null || param1.data == null)
         {
            return;
         }
         this.controller.openWindow(Consts.WINDOW_NAME_ALERT,{
            "type":Consts.ALERT_TYPE_SUCCESS,
            "text":param1.data["msg"]
         });
         this.m_flowerPage.dataList = this.controller.model.flowers;
         this.m_flowerPage.showAllFlowers();
         this.m_controller.hideTip();
      }
      
      private function onUpdateFishLock(param1:CommonEvent) : void
      {
         if(param1 == null || param1.data == null)
         {
            return;
         }
         var _loc2_:WarehouseFish = param1.data as WarehouseFish;
         if(_loc2_ == null)
         {
            return;
         }
         this.m_fishPage.refreshLock(_loc2_);
         this.m_sellFishWin.updateLock();
      }
      
      private function onDataLoading(param1:CommonEvent) : void
      {
         if(param1 == null || param1.data == null)
         {
            return;
         }
         var _loc2_:int = int(param1.data["index"]);
         var _loc3_:Boolean = Boolean(param1.data["show"]);
         if(_loc2_ == 0)
         {
            this.m_cropPage.loadingVisible = _loc3_;
         }
         else if(_loc2_ == 1)
         {
            if(this.m_seedPage != null)
            {
               this.m_seedPage.loadingVisible = _loc3_;
            }
            else if(_loc2_ == 2)
            {
               if(this.m_recvFlowerPage != null)
               {
                  this.m_recvFlowerPage.loadingVisible = _loc3_;
               }
               else if(_loc2_ == 5)
               {
                  this.m_fishPage.loadingVisible = _loc3_;
               }
            }
         }
      }
      
      private function onTileItemOver(param1:ViewEvent) : void
      {
         var _loc3_:WarehouseCrop = null;
         var _loc4_:WarehouseSeed = null;
         var _loc5_:WarehouseFish = null;
         var _loc6_:* = undefined;
         var _loc7_:Object = null;
         if(param1 == null || param1.data == null)
         {
            return;
         }
         var _loc2_:String = "";
         if(param1.data is WarehouseCrop)
         {
            _loc3_ = param1.data as WarehouseCrop;
            _loc2_ = _loc3_._isLock == true ? Language.L["该果实已锁定不能卖出"] : _loc3_._name;
            this.m_controller.showTip(Consts.TIP_NAME_MOUSE,_loc2_);
         }
         else if(param1.data is WarehouseSeed)
         {
            _loc4_ = param1.data as WarehouseSeed;
            _loc2_ = _loc4_._name;
            this.m_controller.showTip(Consts.TIP_NAME_MOUSE,_loc2_);
         }
         else if(param1.data is WarehouseFish)
         {
            _loc5_ = param1.data as WarehouseFish;
            _loc2_ = _loc5_._name;
            this.m_controller.showTip(Consts.TIP_NAME_MOUSE,_loc2_);
         }
         else
         {
            _loc6_ = param1.data;
            if(_loc6_ == null || _loc6_["need"] == undefined || _loc6_["fName"] == undefined)
            {
               return;
            }
            for each(_loc7_ in _loc6_["need"])
            {
               _loc2_ += _loc7_["cName"] + _loc7_["amount"] + "朵，";
            }
            _loc2_ = _loc2_.substr(0,_loc2_.length - 1);
            _loc2_ = "<b>" + _loc6_["fName"] + "</b><br/>花语：" + _loc6_["desc"] + "<br/>需要：" + _loc2_;
            this.m_controller.showTip(Consts.TIP_NAME_CROPINFO_MOUSE,_loc2_);
         }
      }
      
      private function onTileItemOut(param1:ViewEvent) : void
      {
         this.m_controller.hideTip();
      }
      
      private function onUpdateLock(param1:CommonEvent) : void
      {
         if(param1 == null || param1.data == null)
         {
            return;
         }
         var _loc2_:WarehouseCrop = param1.data as WarehouseCrop;
         if(_loc2_ == null)
         {
            return;
         }
         if(_loc2_._isFlower != 1)
         {
            if(_loc2_._type.toString() == Consts.ITEM_TYPE_CARD)
            {
               if(this.m_cardPage != null)
               {
                  this.m_cardPage.refreshLock(_loc2_);
               }
            }
            else if(this.m_cropPage != null)
            {
               this.m_cropPage.refreshLock(_loc2_);
            }
         }
         else if(this.m_flowerPage != null)
         {
            this.m_flowerPage.refreshLock(_loc2_);
         }
         this.m_sellCropWin.updateLock();
      }
      
      private function onSendFlowerLink(param1:TextEvent) : void
      {
         param1.stopPropagation();
         this.m_tabNav.selectedIndex = 1;
         this.m_flowerPage.switchSendFlowerView(true);
         if(this.m_txtSendFlower != null)
         {
            this.m_txtSendFlower.text = "";
         }
      }
      
      override public function onEffectEnd() : void
      {
         super.onEffectEnd();
         if(this.currentPage == this.m_seedPage)
         {
            this.controller.model.loadSeeds();
         }
      }
      
      private function onCrystalDataChanged(param1:Event) : void
      {
         this.m_controller.model.loadCrystal();
      }
   }
}

