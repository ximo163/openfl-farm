package mc.view.main.window.diy
{
   import com.lipi.LipiUtil;
   import com.minutes.ui.collections.LipiCanvas;
   import com.minutes.ui.control.JerryTabNavigation;
   import com.minutes.ui.core.UIEvent;
   import common.MaterialLib;
   import flash.events.*;
   import flash.filters.GlowFilter;
   import mc.control.Command;
   import mc.model.MData;
   import mc.model.MainData;
   import mc.view.ViewEvent;
   import mc.view.common.BaseWindow;
   import mc.view.common.DataLoading;
   import mc.view.main.cursor.Cursor;
   
   public class DiyWindow extends BaseWindow
   {
      
      private var mainData:MainData;
      
      private var hunterTile:HunterTile;
      
      private var tabNav:JerryTabNavigation;
      
      private var diyTile:DiyTile;
      
      private var divaCache:LipiCanvas = null;
      
      private var loading:DataLoading;
      
      public function DiyWindow()
      {
         super();
         width = 500;
         height = 410;
         titleIMG = MaterialLib.getInstance().getClass("DiyWindowTitle2");
         this.mode = true;
      }
      
      private function userItemErr(param1:Event) : void
      {
         this.loading.errorText = this.mainData.userItemErr;
      }
      
      private function dataLoaded(param1:Event) : void
      {
         this.diyTile.dataList = this.mainData.userItems;
      }
      
      override public function init() : void
      {
         this.mainData = MData.getInstance().mainData;
         this.mainData.addEventListener(MainData.USER_ITEM_LOADING,this.isLoading);
         this.mainData.addEventListener(MainData.USER_ITEMS,this.dataLoaded);
         this.mainData.addEventListener(MainData.USER_HUNTERS,this.dataLoaded_hunter);
         this.mainData.addEventListener(MainData.USER_ITEM_ERR,this.userItemErr);
         this.addTab();
         this.loading = new DataLoading();
         this.loading.addEventListener(ViewEvent.LINK_CLICK,this.linkClick);
         this.loading.x = (this.width - this.loading.width) * 0.5;
         this.loading.y = (this.height - this.loading.height) * 0.5;
         this.loading.visible = this.mainData.userItemLoading;
         addChild(this.loading);
         addEventListener(MouseEvent.MOUSE_MOVE,this.onMouseMove);
      }
      
      override public function set data(param1:Object) : void
      {
         super.data = param1;
         this.setData();
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
      
      private function linkClick(param1:ViewEvent) : void
      {
         if(param1.data == "reload")
         {
            Command.getInstance().mainCommand.getUserItems();
         }
         if(param1.data == "reload2")
         {
            Command.getInstance().mainCommand.getUserHunters();
         }
      }
      
      private function dataLoaded_hunter(param1:Event) : void
      {
         this.hunterTile.dataList = this.mainData.userHunters;
      }
      
      private function tabSelect(param1:UIEvent = null) : void
      {
         if(param1.data == 0)
         {
            Command.getInstance().mainCommand.getUserItems();
         }
         else if(param1.data == 1)
         {
            Command.getInstance().mainCommand.getUserHunters();
         }
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
         this.diyTile = new DiyTile();
         this.diyTile.addEventListener(ViewEvent.LINK_CLICK,this.diyLinkClick);
         if(this.mainData.diyInfo != null)
         {
            this.diyTile.dataList = this.mainData.diyInfo;
         }
         this.hunterTile = new HunterTile();
         this.hunterTile.addEventListener(ViewEvent.LINK_CLICK,this.diyLinkClick2);
         var _loc1_:GlowFilter = new GlowFilter(8541973,1,2,2,3,1);
         this.tabNav.addItem("装饰",this.diyTile,this.getStringWidth("装饰"),22,[_loc1_]);
         this.tabNav.addItem("看守员",this.hunterTile,this.getStringWidth("看守员"),22,[_loc1_]);
         addChild(this.tabNav);
      }
      
      override public function addedToLayer() : void
      {
         super.addedToLayer();
         Command.getInstance().mainCommand.getUserItems();
      }
      
      private function onMouseMove(param1:MouseEvent) : void
      {
         Cursor.useSystem(true);
      }
      
      private function isLoading(param1:Event) : void
      {
         this.loading.visible = this.mainData.userItemLoading;
      }
      
      private function diyLinkClick(param1:ViewEvent) : void
      {
         if(param1.data == "reload")
         {
            Command.getInstance().mainCommand.getUserItems();
         }
      }
      
      private function diyLinkClick2(param1:ViewEvent) : void
      {
         if(param1.data == "reload")
         {
            Command.getInstance().mainCommand.getUserHunters();
         }
      }
   }
}

