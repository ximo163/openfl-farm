package module.shop.widgets
{
   import com.qzone.qui.styles.Style;
   import com.qzone.utils.AlignUtil;
   import common.Consts;
   import common.misc.Utils;
   import common.view.MaterialProxy;
   import common.view.MaterialProxyBig;
   import common.view.window.BaseWindow;
   import entities.ShopFish;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import framework.api.beast.BeastAPI;
   import interfaces.IMsgCenter;
   import module.GameGuide;
   import module.shop.ShopView;
   
   public class UnlockFishWindow extends BaseWindow
   {
      
      private var _materialGold:MaterialProxy;
      
      private var _parent:ShopView;
      
      private var _material:MaterialProxyBig;
      
      private var _materialCrystal:MaterialProxy;
      
      private var _shopFishUnlockBg:MovieClip;
      
      private var _materialLvl:MaterialProxy;
      
      public function UnlockFishWindow(param1:ShopView)
      {
         super(param1.controller.module.app as IMsgCenter);
         width = 390;
         height = 320;
         title = "解锁";
         windowName = Consts.WINDOW_NAME_UNLOCKFISH;
         mode = true;
         this._parent = param1;
      }
      
      private function onMaterialGoldOver(param1:MouseEvent) : void
      {
         var _loc2_:ShopFish = super.data as ShopFish;
         if(_loc2_._lock_gold > 0)
         {
            this._parent.controller.showTip(Consts.TIP_NAME_MOUSE,"金币");
         }
      }
      
      override protected function setSize() : void
      {
         super.setSize();
         panelTitle.x = AlignUtil.middle(_width,panelTitle.width);
      }
      
      override protected function setData() : void
      {
         this.graphics.clear();
         this._materialCrystal.visible = false;
         this._materialGold.visible = false;
         this._shopFishUnlockBg.crystalBg.visible = false;
         this._shopFishUnlockBg.crystalText.htmlText = "";
         this._shopFishUnlockBg.goldBg.visible = false;
         this._shopFishUnlockBg.goldText.htmlText = "";
         if(super.isInit == false)
         {
            return;
         }
         var _loc1_:ShopFish = super.data as ShopFish;
         if(_loc1_ == null)
         {
            return;
         }
         if(_loc1_._lock == 0)
         {
            this._shopFishUnlockBg.unlockBtn.filters = Style.getDisableFilter();
         }
         else
         {
            this._shopFishUnlockBg.unlockBtn.filters = null;
         }
         this._shopFishUnlockBg.fishName.htmlText = _loc1_._name;
         this._shopFishUnlockBg.fishDetail.htmlText = this.buildContent();
         this._material.setContent(Consts.ITEM_TYPE_FISH,_loc1_._id);
         var _loc2_:Array = _loc1_._lock_crystal.split(",");
         if(_loc2_.length > 0 && int(_loc2_[1]) > 0)
         {
            this._materialCrystal.visible = true;
            this._materialCrystal.setContent(Consts.ITEM_TYPE_CRYSTAL,int(_loc2_[0]));
            this._shopFishUnlockBg.crystalBg.visible = true;
            this._shopFishUnlockBg.crystalText.htmlText = _loc2_[1].toString();
         }
         if(_loc1_._lock_gold > 0)
         {
            this._materialGold.visible = true;
            this._materialGold.setContent(Consts.ITEM_TYPE_MONEY,0);
            this._shopFishUnlockBg.goldBg.visible = true;
            this._shopFishUnlockBg.goldText.htmlText = _loc1_._lock_gold.toString();
         }
         GameGuide.instance().showStep(GameGuide.WATER_UNLOCK_FISH);
         GameGuide.instance().autoHide(5);
      }
      
      private function onMaterialOut(param1:MouseEvent) : void
      {
         this._parent.controller.hideTip();
      }
      
      private function onUnlock(param1:MouseEvent) : void
      {
         var _loc2_:ShopFish = super.data as ShopFish;
         if(_loc2_._lock != 2)
         {
            return;
         }
         this._parent.controller.model.unlockFish(_loc2_._id);
         this.close();
      }
      
      private function buildContent() : String
      {
         var _loc1_:String = "";
         var _loc2_:ShopFish = data as ShopFish;
         if(_loc2_ == null)
         {
            return _loc1_;
         }
         _loc1_ += "成熟时间：<font color=\"#0099FF\">" + _loc2_._mature + "</font> 小时";
         _loc1_ += "<br>鱼苗售价：<font color=\"#CC3300\">金币</font><font color=\"#FF6600\">" + _loc2_._price + "</font>";
         _loc1_ += "<br>收获经验：<font color=\"#0099FF\">" + _loc2_._exp + "</font>";
         return _loc1_ + ("<br>占用容量：<font color=\"#FF6600\">" + _loc2_._pool_size + "</font>");
      }
      
      private function onMaterialCrystalOver(param1:MouseEvent) : void
      {
         var xml:XML = null;
         var crystalName:String = null;
         var e:MouseEvent = param1;
         var fish:ShopFish = super.data as ShopFish;
         var unlockCrystal:Array = fish._lock_crystal.split(",");
         if(unlockCrystal.length > 0 && int(unlockCrystal[1]) > 0)
         {
            xml = BeastAPI.getInstance().iniData;
            crystalName = xml.crystal.info.(@id == unlockCrystal[0].toString()).@name;
            this._parent.controller.showTip(Consts.TIP_NAME_MOUSE,crystalName);
         }
      }
      
      override protected function addedToLayer() : void
      {
         super.addedToLayer();
         this._material = new MaterialProxyBig();
         this._material.x = 29;
         this._material.y = 40;
         addChild(this._material);
         this._shopFishUnlockBg = Utils.getMaterial("FishUnlockBg") as MovieClip;
         this._shopFishUnlockBg.x = 29;
         this._shopFishUnlockBg.y = 170;
         addChild(this._shopFishUnlockBg);
         this._materialCrystal = new MaterialProxy();
         this._materialCrystal.x = 119;
         this._materialCrystal.y = 209;
         addChild(this._materialCrystal);
         this._materialGold = new MaterialProxy();
         this._materialGold.x = 49;
         this._materialGold.y = 209;
         addChild(this._materialGold);
         this._shopFishUnlockBg.unlockBtn.addEventListener(MouseEvent.CLICK,this.onUnlock);
         this._shopFishUnlockBg.goldBg.visible = false;
         this._shopFishUnlockBg.crystalBg.visible = false;
         this._shopFishUnlockBg.lvlBg.visible = false;
         this._shopFishUnlockBg.crystalText.htmlText = "";
         this._shopFishUnlockBg.goldText.htmlText = "";
         this._shopFishUnlockBg.lvlText.htmlText = "";
         this._materialCrystal.addEventListener(MouseEvent.ROLL_OVER,this.onMaterialCrystalOver);
         this._materialGold.addEventListener(MouseEvent.ROLL_OVER,this.onMaterialGoldOver);
         this._materialCrystal.addEventListener(MouseEvent.ROLL_OUT,this.onMaterialOut);
         this._materialGold.addEventListener(MouseEvent.ROLL_OUT,this.onMaterialOut);
      }
      
      override protected function close() : void
      {
         super.close();
         GameGuide.instance().hide();
      }
   }
}

