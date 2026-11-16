package mc.view.main.window.warehouse
{
   import com.lipi.LipiUtil;
   import com.minutes.ui.control.JerryTabNavigation;
   import com.minutes.ui.core.UIEvent;
   import common.MaterialLib;
   import flash.events.Event;
   import flash.filters.GlowFilter;
   import mc.control.Command;
   import mc.control.ViewControl;
   import mc.events.CommonEvent;
   import mc.model.FarmData;
   import mc.model.MData;
   import mc.model.MainData;
   import mc.model.ModelEvent;
   import mc.view.ViewEvent;
   import mc.view.common.BaseWindow;
   
   public class WarehouseWindow extends BaseWindow
   {
      
      private var mainData:MainData;
      
      private var farmData:FarmData;
      
      private var warehouseCubsTile:WarehouseCubsTile;
      
      private var tabNav:JerryTabNavigation;
      
      private var warehouseMaterialTile:WarehouseMaterialTile;
      
      private var _firstOpen:Boolean = true;
      
      private var warehouseProductTile:WarehouseProductTile;
      
      public function WarehouseWindow()
      {
         super();
         width = 500;
         height = 380;
         titleIMG = MaterialLib.getInstance().getClass("WareHouseWindowTitle");
         windowName = "warehouse";
         mode = true;
      }
      
      private function userCropLoading(param1:Event) : void
      {
         if(this.mainData.userCropLoading == true)
         {
            if(this.warehouseProductTile != null)
            {
               this.warehouseProductTile.loadingVisible = true;
            }
         }
         else if(this.warehouseProductTile != null)
         {
            this.warehouseProductTile.loadingVisible = false;
         }
      }
      
      private function userMaterialErr(param1:Event) : void
      {
         this.warehouseMaterialTile.errText = MData.getInstance().mainData.userMaterialErr;
      }
      
      override public function addedToLayer() : void
      {
         super.addedToLayer();
         Command.getInstance().mainCommand.getUserCrop();
         if(!this._firstOpen)
         {
            Command.getInstance().mainCommand.getUserMaterial();
         }
         this._firstOpen = false;
      }
      
      private function onSellMaterialSuc(param1:CommonEvent) : void
      {
         var _loc4_:Array = null;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc2_:int = int(param1.data.post_data.cId);
         var _loc3_:int = int(param1.data.post_data.num);
         if(this.warehouseMaterialTile)
         {
            _loc4_ = this.warehouseMaterialTile.dataList;
            _loc5_ = int(_loc4_.length);
            _loc6_ = 0;
            while(_loc6_ < _loc5_)
            {
               if(_loc4_[_loc6_]["cId"] == _loc2_)
               {
                  _loc4_[_loc6_]["amount"] -= _loc3_;
                  break;
               }
               _loc6_++;
            }
            this.warehouseMaterialTile.updateMaterialItemNum(_loc2_,_loc3_);
         }
      }
      
      private function userMaterialLoading(param1:Event) : void
      {
         if(this.mainData.userMaterialLoading == true)
         {
            if(this.warehouseMaterialTile != null)
            {
               this.warehouseMaterialTile.loadingVisible = true;
            }
         }
         else if(this.warehouseMaterialTile != null)
         {
            this.warehouseMaterialTile.loadingVisible = false;
         }
      }
      
      private function onSellCropSuc(param1:CommonEvent) : void
      {
         var _loc4_:Array = null;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc2_:int = int(param1.data.post_data.cId);
         var _loc3_:int = int(param1.data.post_data.num);
         if(this.warehouseProductTile)
         {
            _loc4_ = this.warehouseProductTile.dataList;
            _loc5_ = int(_loc4_.length);
            _loc6_ = 0;
            while(_loc6_ < _loc5_)
            {
               if(_loc4_[_loc6_]["cId"] == _loc2_)
               {
                  _loc4_[_loc6_]["amount"] -= _loc3_;
                  break;
               }
               _loc6_++;
            }
            this.warehouseProductTile.updateProductNum(_loc2_,_loc3_);
         }
      }
      
      override public function init() : void
      {
         this.mainData = MData.getInstance().mainData;
         this.farmData = MData.getInstance().farmData;
         this.mainData.addEventListener(MainData.USER_CROP_LOADING,this.userCropLoading,false,0,true);
         this.mainData.addEventListener(MainData.USER_CROP,this.userCrop,false,0,true);
         this.mainData.addEventListener(MainData.USER_CROP_ERR,this.userCropErr,false,0,true);
         this.mainData.addEventListener(MainData.USER_CUB_LOADING,this.userCubLoading,false,0,true);
         this.mainData.addEventListener(MainData.USER_CUB,this.userCub,false,0,true);
         this.mainData.addEventListener(MainData.USER_CUB_ERR,this.userCubErr,false,0,true);
         this.mainData.addEventListener(MainData.USER_MATERIAL_LOADING,this.userMaterialLoading,false,0,true);
         this.mainData.addEventListener(MainData.USER_MATERIAL,this.userMaterial,false,0,true);
         this.mainData.addEventListener(MainData.USER_MATERIAL_ERR,this.userMaterialErr,false,0,true);
         Command.getInstance().mainCommand.addEventListener("sellMaterialSuccess",this.onSellMaterialSuc);
         Command.getInstance().mainCommand.addEventListener("sellCropSuccess",this.onSellCropSuc);
         ViewControl.getInstance().addEventListener("closeWareHouseWindow",this._closeHandler);
         ViewControl.getInstance().addEventListener("animal_change",this.reLoadUserSeed);
         this.addTab();
      }
      
      private function _closeHandler(param1:Event) : void
      {
         this.closeHandler();
      }
      
      private function userMaterial(param1:Event) : void
      {
         this.warehouseMaterialTile.dataList = MData.getInstance().mainData.userMaterial;
      }
      
      private function userCubLoading(param1:Event) : void
      {
         if(this.mainData.userCubLoading == true)
         {
            if(this.warehouseCubsTile != null)
            {
               this.warehouseCubsTile.loadingVisible = true;
            }
         }
         else if(this.warehouseCubsTile != null)
         {
            this.warehouseCubsTile.loadingVisible = false;
         }
      }
      
      private function materialLinkClick(param1:ViewEvent) : void
      {
         if(param1.data == "reload")
         {
            Command.getInstance().mainCommand.getUserMaterial();
            this.warehouseMaterialTile.loadingVisible = true;
         }
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
      
      private function userCubErr(param1:Event) : void
      {
         this.warehouseCubsTile.errText = MData.getInstance().mainData.userCubErr;
      }
      
      private function userCub(param1:Event) : void
      {
         this.warehouseCubsTile.dataList = MData.getInstance().mainData.userCub;
      }
      
      private function userCropErr(param1:Event) : void
      {
         this.warehouseProductTile.errText = this.mainData.userCropErr;
      }
      
      public function tabSelect(param1:UIEvent = null) : void
      {
         if(param1.data == 0)
         {
            Command.getInstance().mainCommand.getUserCrop();
         }
         else if(param1.data == 1)
         {
            Command.getInstance().mainCommand.getUserCub();
         }
         else if(param1.data == 2)
         {
            Command.getInstance().mainCommand.getUserMaterial();
         }
      }
      
      private function childLinkClick(param1:ViewEvent) : void
      {
         if(param1.data == "reload")
         {
            Command.getInstance().mainCommand.getUserCub();
            this.warehouseCubsTile.loadingVisible = true;
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
         this.warehouseProductTile = new WarehouseProductTile();
         this.warehouseProductTile.addEventListener(ViewEvent.LINK_CLICK,this.productLinkClick);
         if(this.mainData.userCrop != null)
         {
            this.warehouseProductTile.dataList = this.mainData.userCrop;
         }
         this.warehouseMaterialTile = new WarehouseMaterialTile();
         this.warehouseMaterialTile.addEventListener(ViewEvent.LINK_CLICK,this.materialLinkClick);
         this.warehouseCubsTile = new WarehouseCubsTile();
         this.warehouseCubsTile.addEventListener(ViewEvent.LINK_CLICK,this.childLinkClick);
         var _loc1_:GlowFilter = new GlowFilter(8541973,1,2,2,3,1);
         this.tabNav.addItem("动物产品",this.warehouseProductTile,this.getStringWidth("动物产品"),22,[_loc1_]);
         this.tabNav.addItem("回收幼仔",this.warehouseCubsTile,this.getStringWidth("回收幼仔"),22,[_loc1_]);
         this.tabNav.addItem("材料",this.warehouseMaterialTile,this.getStringWidth("材料"),22,[_loc1_]);
         addChild(this.tabNav);
         this.mainData.dispatchEvent(new ModelEvent("OkForWareHouse"));
      }
      
      private function reLoadUserSeed(param1:Event) : void
      {
         this.farmData.reloadUserSeed = true;
         Command.getInstance().mainCommand.getUserCub();
      }
      
      public function OkForWareHouse(param1:int) : void
      {
         this.tabNav.selectedIndex = param1;
         Command.getInstance().mainCommand.getUserCub();
      }
      
      private function userCrop(param1:Event) : void
      {
         this.warehouseProductTile.dataList = this.mainData.userCrop;
      }
      
      private function productLinkClick(param1:ViewEvent) : void
      {
         if(param1.data == "reload")
         {
            Command.getInstance().mainCommand.getUserCrop();
            this.warehouseProductTile.loadingVisible = true;
         }
      }
   }
}

