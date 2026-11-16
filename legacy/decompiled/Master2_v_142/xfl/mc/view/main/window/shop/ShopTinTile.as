package mc.view.main.window.shop
{
   import com.minutes.ui.collections.LipiTile2;
   import com.qzone.qui.containers.HBox;
   import com.qzone.qui.controls.Button;
   import com.qzone.qui.controls.scrollClasses.ScrollPolicy;
   import com.qzone.qui.core.Align;
   import com.qzone.qui.makers.RadioGroup;
   import com.qzone.qui.utils.TextFormatUtil;
   import common.CommonData;
   import common.MaterialLib;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.utils.setTimeout;
   import mc.control.ViewControl;
   import mc.events.WindowEvent;
   import mc.view.ViewEvent;
   import mc.view.common.DataLoading;
   import mc.view.main.WindowControl.WindowClassLib;
   import module.missionActivity.MissionActivityHelper;
   
   public class ShopTinTile extends Sprite
   {
      
      private var hBox:HBox;
      
      private var _weaponCache:Array;
      
      private var _normalCache:Array;
      
      private var weaponBtn:Button;
      
      private var radioG:RadioGroup;
      
      private var tile:LipiTile2;
      
      private var _filterType:String;
      
      private var dataLoading:DataLoading;
      
      private var normalBtn:Button;
      
      public function ShopTinTile()
      {
         super();
         this._filterType = "normal";
         this._normalCache = null;
         this._weaponCache = null;
         this.drawTabView();
         this.tile = new LipiTile2(TinItem,5,90,98,23,10);
         this.tile.addEventListener(ViewEvent.CHILD_CLICK,this.tileChildClick);
         this.tile.y = this.hBox.height;
         this.tile.width = 480;
         this.tile.height = 300 + 20;
         this.tile.bgAlpha = 0;
         addChild(this.tile);
         this.dataLoading = new DataLoading();
         this.dataLoading.addEventListener(ViewEvent.LINK_CLICK,this.linkClick);
         this.dataLoading.x = this.tile.width / 2;
         this.dataLoading.y = this.tile.height / 2;
         addChild(this.dataLoading);
      }
      
      public function set dataList(param1:Array) : void
      {
         this.groupSeeds(param1);
         if(CommonData.shopTinPage)
         {
            this.normalBtn.selected = true;
            this.weaponBtn.selected = false;
            this._filterType = "normal";
            CommonData.shopTinPage = false;
         }
         if(this._filterType == "normal")
         {
            this.tile.removeAll();
            this.tile.dataList = this._normalCache;
         }
         else if(this._filterType == "weapon")
         {
            this.tile.removeAll();
            this.tile.dataList = this._weaponCache;
            this.tile.verticalScrollBar.scrollPosition = 0;
         }
         setTimeout(this.resetAll,200);
      }
      
      public function set errText(param1:String) : void
      {
         this.dataLoading.errorText = param1;
      }
      
      private function resetAll() : void
      {
         this.tile.resetSize();
         this.tile.verticalScrollBar.scrollPosition = CommonData.shopVScroll;
         CommonData.shopVScroll = 0;
      }
      
      private function filterTypeClick(param1:MouseEvent) : void
      {
         if(param1 == null)
         {
            return;
         }
         var _loc2_:Button = param1.target as Button;
         if(_loc2_ != null && this._filterType != _loc2_.name)
         {
            this._filterType = _loc2_.name;
            if(this.tile == null)
            {
               return;
            }
            if(this._filterType == "normal")
            {
               this.tile.removeAll();
               this.tile.dataList = this._normalCache;
            }
            else if(this._filterType == "weapon")
            {
               this.tile.removeAll();
               this.tile.dataList = this._weaponCache;
            }
         }
      }
      
      private function tileChildClick(param1:ViewEvent) : void
      {
         if(param1.data["tp"] == 1)
         {
            MissionActivityHelper.gi().buyActivityItemHydra(358,1,1,1);
            return;
         }
         WindowClassLib.register("ShopTinWindow",ShopTinWindow);
         var _loc2_:WindowEvent = new WindowEvent(WindowEvent.OPEN);
         _loc2_.windowName = "ShopTinWindow";
         _loc2_.windowArgument = param1.data;
         ViewControl.getInstance().dispatchEvent(_loc2_);
      }
      
      private function groupSeeds(param1:Array) : void
      {
         var _loc2_:* = undefined;
         this._normalCache = [];
         this._weaponCache = [];
         for each(_loc2_ in param1)
         {
            if(_loc2_.appid != undefined && _loc2_.appid == 353)
            {
               this._weaponCache.push(_loc2_);
            }
            else
            {
               this._normalCache.push(_loc2_);
            }
         }
      }
      
      public function get dataList() : Array
      {
         return this.tile.dataList;
      }
      
      private function linkClick(param1:ViewEvent) : void
      {
         var _loc2_:ViewEvent = new ViewEvent(ViewEvent.LINK_CLICK);
         _loc2_.data = param1.data;
         dispatchEvent(_loc2_);
      }
      
      private function drawTabView() : void
      {
         this.hBox = new HBox(482,30);
         this.hBox.verticalScrollPolicy = ScrollPolicy.OFF;
         this.hBox.horizontalScrollPolicy = ScrollPolicy.OFF;
         this.hBox.alignH = Align.LEFT;
         this.hBox.alignV = Align.TOP;
         this.hBox.paddingH = 10;
         this.hBox.paddingV = 5;
         this.hBox.defaultSkin = null;
         this.hBox.backgroundColor = 15651977;
         this.hBox.backgroundAlpha = 1;
         this.radioG = new RadioGroup();
         this.normalBtn = new Button("常规道具");
         this.normalBtn.name = "normal";
         this.normalBtn.defaultSkin = Shape;
         this.normalBtn.selectedSkin = MaterialLib.getInstance().getClass("SeedNormalBtnSelectedSkin");
         this.normalBtn.useHandCursor = true;
         this.normalBtn.textSelectedFormat = TextFormatUtil.clone(this.normalBtn.textSelectedFormat);
         this.normalBtn.textSelectedFormat.color = 16777215;
         this.normalBtn.textDefaultFormat = TextFormatUtil.clone(this.normalBtn.textDefaultFormat);
         this.normalBtn.textDefaultFormat.color = 10773568;
         this.normalBtn.textOverFormat = TextFormatUtil.clone(this.normalBtn.textOverFormat);
         this.normalBtn.textOverFormat.color = null;
         this.normalBtn.toggle = true;
         this.normalBtn.selected = true;
         this.radioG.addTarget(this.normalBtn);
         this.hBox.addElement(this.normalBtn);
         this.weaponBtn = new Button("武器");
         this.weaponBtn.name = "weapon";
         this.weaponBtn.defaultSkin = this.normalBtn.defaultSkin;
         this.weaponBtn.selectedSkin = this.normalBtn.selectedSkin;
         this.weaponBtn.textDefaultFormat = this.normalBtn.textDefaultFormat;
         this.weaponBtn.textSelectedFormat = this.normalBtn.textSelectedFormat;
         this.weaponBtn.textOverFormat = this.normalBtn.textOverFormat;
         this.weaponBtn.toggle = true;
         this.radioG.addTarget(this.weaponBtn);
         this.hBox.addElement(this.weaponBtn);
         this.normalBtn.useHandCursor = true;
         this.weaponBtn.useHandCursor = true;
         this.hBox.addEventListener(MouseEvent.CLICK,this.filterTypeClick);
         this.addChild(this.hBox);
      }
      
      public function set loadingVisible(param1:Boolean) : void
      {
         this.dataLoading.visible = param1;
         this.tile.visible = !param1;
      }
   }
}

