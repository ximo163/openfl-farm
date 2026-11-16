package mc.view.main.window.shop
{
   import com.lipi.LipiUtil;
   import com.minutes.ui.control.JerryTabNavigation;
   import com.minutes.ui.core.UIEvent;
   import common.CommonData;
   import common.MaterialLib;
   import flash.display.*;
   import flash.events.Event;
   import flash.events.TextEvent;
   import flash.external.ExternalInterface;
   import flash.filters.GlowFilter;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormat;
   import mc.control.Command;
   import mc.control.ViewControl;
   import mc.events.CommonEvent;
   import mc.model.MData;
   import mc.model.MainData;
   import mc.model.OpenControl;
   import mc.model.TinItemsData;
   import mc.view.ViewEvent;
   import mc.view.common.BaseWindow;
   
   public class ShopWindow extends BaseWindow
   {
      
      private var mainData:MainData;
      
      private var tabNav:JerryTabNavigation;
      
      private var cropTile:ShopSeedTile;
      
      private var diyTile:ShopDiyTile;
      
      private var tinData:TinItemsData;
      
      private var toolTile:ShopToolTile;
      
      private var tinTile:ShopTinTile;
      
      public function ShopWindow()
      {
         super();
         width = 500;
         height = 440;
         titleIMG = MaterialLib.getInstance().getClass("ShopWindowTitle");
         windowName = "shop";
         mode = true;
      }
      
      private function toolLinkClick(param1:ViewEvent) : void
      {
         if(param1.data == "reload")
         {
            Command.getInstance().mainCommand.getToolsInfo();
            this.toolTile.loadingVisible = true;
         }
      }
      
      private function shopDiyErr(param1:Event) : void
      {
         this.diyTile.errText = this.mainData.shopDiyErr;
      }
      
      private function onGotUserItem(param1:Event) : void
      {
         if(this.diyTile)
         {
            this.diyTile.updateShopDiyTile(MData.getInstance().mainData.userItems);
         }
      }
      
      private function showWindow(param1:Event) : void
      {
         this.visible = true;
      }
      
      override public function init() : void
      {
         this.mainData = MData.getInstance().mainData;
         this.tinData = MData.getInstance().tinData;
         this.mainData.addEventListener(MainData.SEED_INFO,this.seedInfo,false,0,true);
         this.mainData.addEventListener(MainData.TOOL_INFO,this.toolInfo,false,0,true);
         this.mainData.addEventListener(MainData.DIY_INFO,this.diyInfo,false,0,true);
         this.mainData.addEventListener(MainData.SHOP_SEED_LOADING,this.shopSeedLoading,false,0,true);
         this.mainData.addEventListener(MainData.SHOP_TOOL_LOADING,this.shopToolLoading,false,0,true);
         this.mainData.addEventListener(MainData.SHOP_DIY_LOADING,this.shopDiyLoading,false,0,true);
         this.mainData.addEventListener(MainData.SHOP_SEED_ERR,this.shopSeedErr,false,0,true);
         this.mainData.addEventListener(MainData.SHOP_TOOL_ERR,this.shopToolErr,false,0,true);
         this.mainData.addEventListener(MainData.SHOP_DIY_ERR,this.shopDiyErr,false,0,true);
         this.mainData.addEventListener(MainData.USER_ITEMS,this.onGotUserItem,false,0,true);
         Command.getInstance().mainCommand.addEventListener("buyDiySuccess",this.onBuyDiySuccess,false,0,true);
         this.tinData.addEventListener(TinItemsData.LOAD_TINS_SUCCESS,this.tinInfo,false,0,true);
         this.tinData.addEventListener(TinItemsData.LOAD_TINS_ERROR,this.shopTinErr,false,0,true);
         this.tinData.addEventListener(TinItemsData.LOAD_STATUS_CHANGED,this.shopTinLoading,false,0,true);
         ViewControl.getInstance().addEventListener("hideWindow",this.hideWindow);
         ViewControl.getInstance().addEventListener("showWindow",this.showWindow);
         this.addTab();
         Command.getInstance().mainCommand.getSeedInfo();
         var _loc1_:TextFormat = new TextFormat("Verdana",12,8999699);
         var _loc2_:TextField = new TextField();
         _loc2_.htmlText = "";
         _loc2_.autoSize = TextFieldAutoSize.LEFT;
         _loc2_.selectable = false;
         addChild(_loc2_);
         _loc2_.x = 255;
         _loc2_.y = 54;
         _loc2_.addEventListener(TextEvent.LINK,this.linkHandler);
         _loc2_.setTextFormat(_loc1_);
         var _loc3_:Sprite = MaterialLib.getInstance().getMaterial("NewIcon") as Sprite;
         addChild(_loc3_);
         _loc3_.x = 180;
         _loc3_.y = 50;
         _loc3_.mouseChildren = false;
         _loc3_.mouseEnabled = false;
         this.setData();
      }
      
      private function hideWindow(param1:Event) : void
      {
         this.visible = false;
      }
      
      override public function set data(param1:Object) : void
      {
         super.data = param1;
         this.setData();
      }
      
      private function onBuyDiySuccess(param1:CommonEvent) : void
      {
         var _loc2_:int = param1.data;
         if(this.diyTile)
         {
            this.diyTile.updateShopDiyTile([{"itemId":_loc2_}]);
         }
      }
      
      private function shopToolErr(param1:Event) : void
      {
         this.toolTile.errText = this.mainData.shopToolErr;
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
      
      private function tinLinkClick(param1:ViewEvent) : void
      {
         if(param1.data == "reload")
         {
            Command.getInstance().tinCommand.getTinsInfo();
            this.tinTile.loadingVisible = true;
         }
      }
      
      private function shopDiyLoading(param1:Event) : void
      {
         if(this.mainData.shopDiyLoading == true)
         {
            if(this.diyTile != null)
            {
               this.diyTile.loadingVisible = true;
            }
         }
         else if(this.diyTile != null)
         {
            this.diyTile.loadingVisible = false;
         }
      }
      
      private function tinInfo(param1:Event) : void
      {
         if(this.tinTile != null)
         {
            this.tinTile.dataList = this.tinData.allTinItems;
         }
      }
      
      private function diyInfo(param1:Event) : void
      {
         this.diyTile.dataList = this.mainData.diyInfo;
         Command.getInstance().mainCommand.getUserItems();
      }
      
      private function setData() : void
      {
         var _loc1_:UIEvent = null;
         if(Boolean(data) && Boolean(data.tabSelected) && Boolean(this.tabNav))
         {
            this.tabNav.selectedIndex = data.tabSelected;
            _loc1_ = new UIEvent("JerryTabNavigation.TAB_SELECT");
            _loc1_.data = data.tabSelected;
            this.tabSelect(_loc1_);
         }
      }
      
      private function toolInfo(param1:Event) : void
      {
         this.toolTile.dataList = this.mainData.toolsInfo;
      }
      
      private function linkHandler(param1:TextEvent) : void
      {
         ExternalInterface.call("window.open",param1.text);
      }
      
      private function shopTinErr(param1:Event) : void
      {
         this.tinTile.errText = this.tinData.shopTinInfoErr;
      }
      
      private function addTab() : void
      {
         this.tabNav = new JerryTabNavigation();
         this.tabNav.selectedFontStyle(12,16777215,"",false);
         this.tabNav.defaultFontStyle(12,16777215);
         this.tabNav.menuLeftDistance = 16;
         this.tabNav.menuSpaceDistance = 3;
         this.tabNav.menuDefaultButtonWidth = 55;
         this.tabNav.menuDefaultButtonHeight = 22;
         this.tabNav.menuHeight = 27;
         this.tabNav.topHeight = 2;
         this.tabNav.x = 9;
         this.tabNav.y = 50;
         this.tabNav.menuBgClass = MaterialLib.getInstance().getClass("TabBg");
         this.tabNav.width = 491;
         this.tabNav.menuDefaultSkin = MaterialLib.getInstance().getClass("TabDefault");
         this.tabNav.menuSelectedSkin = MaterialLib.getInstance().getClass("TabSelected");
         this.tabNav.addEventListener(JerryTabNavigation.TAB_SELECT,this.tabSelect);
         this.cropTile = new ShopSeedTile();
         this.cropTile.addEventListener(ViewEvent.LINK_CLICK,this.cropLinkClick);
         if(this.mainData.seedInfo != null)
         {
            this.cropTile.dataList = this.mainData.seedInfo;
         }
         this.toolTile = new ShopToolTile();
         this.toolTile.addEventListener(ViewEvent.LINK_CLICK,this.toolLinkClick);
         if(this.mainData.toolsInfo != null)
         {
            this.toolTile.dataList = this.mainData.toolsInfo;
         }
         this.tinTile = new ShopTinTile();
         this.tinTile.addEventListener(ViewEvent.LINK_CLICK,this.tinLinkClick);
         this.diyTile = new ShopDiyTile();
         this.diyTile.addEventListener(ViewEvent.LINK_CLICK,this.diyLinkClick);
         if(this.mainData.diyInfo != null)
         {
            this.diyTile.dataList = this.mainData.diyInfo;
         }
         var _loc1_:GlowFilter = new GlowFilter(8541973,1,2,2,3,1);
         this.tabNav.addItem("幼仔",this.cropTile,this.getStringWidth("幼仔"),22,[_loc1_]);
         this.tabNav.addItem("食物",this.toolTile,this.getStringWidth("食物"),22,[_loc1_]);
         this.tabNav.addItem("道具",this.tinTile,this.getStringWidth("道具"),22,[_loc1_]);
         this.tabNav.addItem("装饰",this.diyTile,this.getStringWidth("装饰"),22,[_loc1_]);
         addChild(this.tabNav);
      }
      
      private function shopSeedLoading(param1:Event) : void
      {
         if(this.mainData.shopSeedLoading == true)
         {
            if(this.cropTile != null)
            {
               this.cropTile.loadingVisible = true;
            }
         }
         else if(this.cropTile != null)
         {
            this.cropTile.loadingVisible = false;
         }
      }
      
      private function shopSeedErr(param1:Event) : void
      {
         this.cropTile.errText = this.mainData.shopSeedErr;
      }
      
      private function tabSelect(param1:UIEvent = null) : void
      {
         if(param1.data == 0)
         {
            Command.getInstance().mainCommand.getSeedInfo();
         }
         else if(param1.data == 1)
         {
            if(OpenControl.open("tool") || true)
            {
               Command.getInstance().mainCommand.getToolsInfo();
            }
            else
            {
               Command.getInstance().mainCommand.getDiyInfo();
            }
         }
         else if(param1.data == 2)
         {
            if(this.tinTile != null)
            {
               Command.getInstance().tinCommand.getTinsInfo();
            }
            else
            {
               Command.getInstance().mainCommand.getDiyInfo();
            }
         }
         else if(param1.data == 3)
         {
            Command.getInstance().mainCommand.getDiyInfo();
         }
      }
      
      private function shopTinLoading(param1:Event) : void
      {
         if(this.tinData.loadingData == true)
         {
            if(this.tinTile != null)
            {
               this.tinTile.loadingVisible = true;
            }
         }
         else if(this.tinTile != null)
         {
            this.tinTile.loadingVisible = false;
         }
      }
      
      private function diyLinkClick(param1:ViewEvent) : void
      {
         if(param1.data == "reload")
         {
            Command.getInstance().mainCommand.getDiyInfo();
            this.diyTile.loadingVisible = true;
         }
      }
      
      private function shopToolLoading(param1:Event) : void
      {
         if(this.mainData.shopToolLoading == true)
         {
            if(this.toolTile != null)
            {
               this.toolTile.loadingVisible = true;
            }
         }
         else if(this.toolTile != null)
         {
            this.toolTile.loadingVisible = false;
         }
      }
      
      private function cropLinkClick(param1:ViewEvent) : void
      {
         if(param1.data == "reload")
         {
            Command.getInstance().mainCommand.getSeedInfo();
            this.cropTile.loadingVisible = true;
         }
      }
      
      private function seedInfo(param1:Event) : void
      {
         var _loc4_:Object = null;
         var _loc2_:Array = [];
         var _loc3_:Number = Number(CommonData.serverTime);
         for each(_loc4_ in this.mainData.seedInfo)
         {
            if(this.mainData.seedType == "vipAnimal")
            {
               if(_loc4_.hasOwnProperty("isvip") && _loc4_["isvip"].toString() == "1")
               {
                  _loc2_.push(_loc4_);
               }
            }
            else if(this.mainData.seedType == "limitSales")
            {
               if(_loc4_.hasOwnProperty("cType") && _loc4_["cType"] == 6)
               {
                  if(_loc4_.hasOwnProperty("deadline") && _loc4_["deadline"] > 0)
                  {
                     _loc2_.push(_loc4_);
                  }
               }
            }
            else if((_loc4_.hasOwnProperty("isvip") && _loc4_["isvip"] != 1 || !_loc4_.hasOwnProperty("isvip")) && (_loc4_.hasOwnProperty("cType") && _loc4_["cType"] != 6 || !_loc4_.hasOwnProperty("cType")))
            {
               if(this.mainData.seedType == "normal")
               {
                  if(_loc4_["cType"] != 4)
                  {
                     _loc2_.push(_loc4_);
                  }
               }
               else if(_loc4_["cType"] == 4)
               {
                  _loc2_.push(_loc4_);
               }
            }
         }
         if(this.mainData.seedType == "limitSales")
         {
            _loc2_.sortOn("deadline",Array.DESCENDING | Array.NUMERIC);
         }
         this.cropTile.dataList = _loc2_;
      }
   }
}

