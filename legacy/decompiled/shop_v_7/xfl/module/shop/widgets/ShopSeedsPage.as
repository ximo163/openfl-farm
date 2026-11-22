package module.shop.widgets
{
   import com.qzone.corelib.controls.ExtLoader;
   import com.qzone.qui.containers.HBox;
   import com.qzone.qui.containers.TileList;
   import com.qzone.qui.controls.Button;
   import com.qzone.qui.controls.Label;
   import com.qzone.qui.controls.scrollClasses.ScrollPolicy;
   import com.qzone.qui.core.Align;
   import com.qzone.qui.makers.RadioGroup;
   import com.qzone.qui.utils.TextFormatUtil;
   import common.Session;
   import common.Settings;
   import common.misc.Utils;
   import common.view.window.WindowLabelMaker;
   import entities.Seed;
   import flash.display.DisplayObjectContainer;
   import flash.display.Shape;
   import flash.display.SimpleButton;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.external.ExternalInterface;
   import flash.text.TextFieldAutoSize;
   import framework.base.BasePage;
   
   public class ShopSeedsPage extends BasePage
   {
      
      private var _loader2:ExtLoader;
      
      private var _advancedCache:Array;
      
      private var _vipCache:Array;
      
      private var _isVip:Boolean;
      
      private var _btnOpenVIP:SimpleButton;
      
      private const _tile_height:int = 300;
      
      private var _normalCache:Array;
      
      private var _greenCache:Array;
      
      private const _tile_top:int = 23;
      
      private var _blackCache:Array;
      
      private var _filterType:String;
      
      private var _label:Label;
      
      private var _loader:ExtLoader;
      
      private var _excludes:Array;
      
      public function ShopSeedsPage(param1:DisplayObjectContainer, param2:int, param3:int)
      {
         var _loc4_:HBox = null;
         super(param1,param2,param3);
         this._filterType = "green";
         this._normalCache = null;
         this._advancedCache = null;
         _loc4_ = new HBox(param2 - 2,27);
         _loc4_.verticalScrollPolicy = ScrollPolicy.OFF;
         _loc4_.horizontalScrollPolicy = ScrollPolicy.OFF;
         _loc4_.alignH = Align.LEFT;
         _loc4_.alignV = Align.TOP;
         _loc4_.paddingH = 3;
         _loc4_.paddingV = 0;
         _loc4_.defaultSkin = null;
         _loc4_.backgroundColor = 14219772;
         _loc4_.backgroundAlpha = 1;
         _loc4_.addEventListener(MouseEvent.CLICK,this.onSeedTypeClicked);
         this.addChild(_loc4_);
         var _loc5_:Button = new Button("有机种子");
         _loc5_.name = "green";
         _loc5_.defaultSkin = Shape;
         _loc5_.selectedSkin = Utils.getClass("SeedTypeBtnSelectedSkin");
         _loc5_.useHandCursor = true;
         _loc5_.textSelectedFormat = TextFormatUtil.clone(_loc5_.textSelectedFormat);
         _loc5_.textSelectedFormat.color = 16777215;
         _loc5_.textSelectedFormat.bold = true;
         _loc5_.textDefaultFormat = TextFormatUtil.clone(_loc5_.textDefaultFormat);
         _loc5_.textDefaultFormat.color = 3785720;
         _loc5_.textOverFormat = TextFormatUtil.clone(_loc5_.textOverFormat);
         _loc5_.textOverFormat.color = null;
         _loc5_.toggle = true;
         _loc5_.selected = true;
         _loc5_.useHandCursor = true;
         _loc5_.height = 25;
         _loc5_.width = 80;
         var _loc6_:Button = new Button("普通种子");
         _loc6_.name = "normal";
         _loc6_.defaultSkin = Shape;
         _loc6_.selectedSkin = Utils.getClass("SeedTypeBtnSelectedSkin");
         _loc6_.useHandCursor = true;
         _loc6_.textSelectedFormat = TextFormatUtil.clone(_loc6_.textSelectedFormat);
         _loc6_.textSelectedFormat.color = 16777215;
         _loc6_.textSelectedFormat.bold = true;
         _loc6_.textDefaultFormat = TextFormatUtil.clone(_loc6_.textDefaultFormat);
         _loc6_.textDefaultFormat.color = 3785720;
         _loc6_.textOverFormat = TextFormatUtil.clone(_loc6_.textOverFormat);
         _loc6_.textOverFormat.color = null;
         _loc6_.toggle = true;
         _loc6_.useHandCursor = true;
         _loc6_.height = 25;
         _loc6_.width = 80;
         var _loc7_:Button = new Button("红土地种子");
         _loc7_.name = "advanced";
         _loc7_.defaultSkin = _loc6_.defaultSkin;
         _loc7_.selectedSkin = _loc6_.selectedSkin;
         _loc7_.textDefaultFormat = _loc6_.textDefaultFormat;
         _loc7_.textSelectedFormat = _loc6_.textSelectedFormat;
         _loc7_.textOverFormat = _loc6_.textOverFormat;
         _loc7_.toggle = true;
         _loc7_.useHandCursor = true;
         _loc7_.height = 25;
         var _loc8_:Button = new Button("黑土地种子");
         _loc8_.name = "black";
         _loc8_.defaultSkin = _loc6_.defaultSkin;
         _loc8_.selectedSkin = _loc6_.selectedSkin;
         _loc8_.textDefaultFormat = _loc6_.textDefaultFormat;
         _loc8_.textSelectedFormat = _loc6_.textSelectedFormat;
         _loc8_.textOverFormat = _loc6_.textOverFormat;
         _loc8_.toggle = true;
         _loc8_.useHandCursor = true;
         _loc8_.height = 25;
         var _loc9_:Button = new Button("VIP专属种子");
         _loc9_.name = "vip";
         _loc9_.defaultSkin = _loc6_.defaultSkin;
         _loc9_.selectedSkin = Utils.getClass("SeedTypeVipBtnSelectedSkin");
         _loc9_.textDefaultFormat = TextFormatUtil.clone(_loc6_.textDefaultFormat);
         _loc9_.textDefaultFormat.color = 16618254;
         _loc9_.textSelectedFormat = TextFormatUtil.clone(_loc6_.textSelectedFormat);
         _loc9_.textSelectedFormat.color = 16618254;
         _loc9_.textOverFormat = _loc6_.textOverFormat;
         _loc9_.toggle = true;
         _loc9_.useHandCursor = true;
         _loc9_.height = 25;
         var _loc10_:RadioGroup = new RadioGroup();
         _loc10_.addTarget(_loc5_);
         _loc4_.addElement(_loc5_);
         _loc10_.addTarget(_loc6_);
         _loc4_.addElement(_loc6_);
         _loc10_.addTarget(_loc7_);
         _loc4_.addElement(_loc7_);
         _loc10_.addTarget(_loc8_);
         _loc4_.addElement(_loc8_);
         _loc10_.addTarget(_loc9_);
         _loc4_.addElement(_loc9_);
         this._label = new Label(null,null,TextFieldAutoSize.LEFT);
         this._label.padingH = 35;
         this._label.padingV = 5;
         this._label.x = 2;
         this._label.width = param2 - 5;
         this._label.y += _loc4_.height;
         this._label.height = 30;
         WindowLabelMaker.addTarget(this._label);
         this._label.visible = false;
         addChild(this._label);
         this._isVip = Boolean(Session.getInstance().host._yellowstatus);
         var _loc11_:String = Settings.getInstance().getStringAttribute("exclude_seeds");
         if(_loc11_ != null && _loc11_ != "")
         {
            this._excludes = _loc11_.split(",");
         }
      }
      
      private function seedSort2(param1:Seed, param2:Seed) : int
      {
         if(param1 == null || param2 == null)
         {
            return 0;
         }
         var _loc3_:int = param1._lvl >= param2._lvl ? 1 : -1;
         if(param1._lvl == param2._lvl && !param1._isRed && Boolean(param2._isRed))
         {
            _loc3_ = -1;
         }
         return _loc3_;
      }
      
      override protected function onCreateTile() : void
      {
         if(_tile != null)
         {
            _tile.paddingH = 23;
            _tile.paddingV = 10;
            _tile.gapH = 0;
            _tile.gapV = 0;
            _tile.tileWidth = 90;
            _tile.tileHeight = 98;
            _tile.defaultSkin = null;
            _tile.horizontalScrollPolicy = ScrollPolicy.OFF;
            _tile.itemRenderer = CropItem;
            _tile.y = this._tile_top;
            _tile.width = _preferedWidth - 5;
            _tile.height = this._tile_height;
         }
      }
      
      override public function set dataList(param1:Array) : void
      {
         if(_tile == null)
         {
            _tile = new TileList();
            this.onCreateTile();
            addChild(_tile);
         }
         this.groupSeeds(param1);
         if(this._filterType == "green")
         {
            _tile.dataProvider = this._greenCache;
         }
         else if(this._filterType == "normal")
         {
            _tile.dataProvider = this._normalCache;
         }
         else if(this._filterType == "advanced")
         {
            _tile.dataProvider = this._advancedCache;
         }
         else if(this._filterType == "vip")
         {
            _tile.dataProvider = this._vipCache;
         }
         else if(this._filterType == "black")
         {
            _tile.dataProvider = this._blackCache;
         }
      }
      
      private function onNavigateToURL(param1:MouseEvent) : void
      {
         var _loc2_:String = Settings.getInstance().getStringAttribute("vipSeedLink");
         ExternalInterface.call("window.open",_loc2_);
      }
      
      private function seedSort(param1:Seed, param2:Seed) : int
      {
         if(param1 == null || param2 == null)
         {
            return 0;
         }
         var _loc3_:int = param1._lvl > param2._lvl ? 1 : -1;
         if(param1._lvl == param2._lvl)
         {
            _loc3_ = param1._id > param2._id ? 1 : -1;
         }
         return _loc3_;
      }
      
      private function groupSeeds(param1:Array) : void
      {
         var _loc2_:Seed = null;
         this._normalCache = [];
         this._advancedCache = [];
         this._vipCache = [];
         this._blackCache = [];
         this._greenCache = [];
         for each(_loc2_ in param1)
         {
            if(_loc2_._isMill != true)
            {
               if(!(this._excludes != null && this._excludes.indexOf(_loc2_._id.toString()) != -1))
               {
                  if(_loc2_._isGreen == true)
                  {
                     this._greenCache.push(_loc2_);
                  }
                  else if(_loc2_._isVip == 1)
                  {
                     this._vipCache.push(_loc2_);
                  }
                  else if(_loc2_._isRed == true)
                  {
                     this._advancedCache.push(_loc2_);
                  }
                  else if(_loc2_._isBlack == true)
                  {
                     this._blackCache.push(_loc2_);
                  }
                  else
                  {
                     this._normalCache.push(_loc2_);
                  }
               }
            }
         }
         this._normalCache.sort(this.seedSort);
         this._advancedCache.sort(this.seedSort);
         this._vipCache.sort(this.seedSort);
      }
      
      private function onSeedTypeClicked(param1:Event) : void
      {
         var _loc3_:Array = null;
         var _loc4_:String = null;
         if(param1 == null)
         {
            return;
         }
         var _loc2_:Button = param1.target as Button;
         if(_loc2_ != null && this._filterType != _loc2_.name)
         {
            this._filterType = _loc2_.name;
            if(_tile == null)
            {
               return;
            }
            _loc3_ = null;
            if(this._filterType == "green")
            {
               _loc3_ = this._greenCache;
            }
            else if(this._filterType == "normal")
            {
               _loc3_ = this._normalCache;
            }
            else if(this._filterType == "advanced")
            {
               _loc3_ = this._advancedCache;
            }
            else if(this._filterType == "black")
            {
               _loc3_ = this._blackCache;
            }
            if(this._filterType == "green" || this._filterType == "normal" || this._filterType == "advanced" || this._filterType == "black")
            {
               _tile.tileWidth = 90;
               _tile.tileHeight = 98;
               _tile.y = this._tile_top;
               this._label.visible = false;
               _tile.itemRenderer = CropItem;
               _tile.dataProvider = _loc3_;
               _tile.height = this._tile_height;
               if(this._loader)
               {
                  this._loader.visible = false;
               }
               if(this._btnOpenVIP)
               {
                  this._btnOpenVIP.visible = false;
               }
               _tile.scrollVerticalReset();
            }
            else if(this._filterType == "vip")
            {
               _tile.tileWidth = 149;
               _tile.tileHeight = 170;
               _tile.y = this._tile_top;
               _tile.itemRenderer = CropItemVip;
               _tile.dataProvider = this._vipCache;
               _tile.height = this._tile_height - this._label.height - 3;
               _tile.y = this._tile_top + this._label.height + 3;
               if(this._isVip)
               {
                  this._label.text = Settings.getInstance().getDynamicTip("shopVipTip");
               }
               else
               {
                  this._label.text = Settings.getInstance().getDynamicTip("shopUnvipTip");
               }
               this._label.visible = true;
               if(this._loader == null)
               {
                  this._loader = new ExtLoader();
                  this._loader.y = 29;
                  this._loader.x = 1;
                  this._loader.load(Settings.getInstance().getSecondUrl("VipSeedTabBg"));
                  addChildAt(this._loader,0);
               }
               else
               {
                  this._loader.visible = true;
               }
               if(this._loader2 == null)
               {
                  _loc4_ = this._isVip ? Settings.getInstance().getSecondUrl("VipSeedButtonVip") : Settings.getInstance().getSecondUrl("VipSeedButtonNonVip");
                  this._loader2 = new ExtLoader();
                  this._loader2.load(Utils.addPrefix(_loc4_));
               }
               if(this._btnOpenVIP == null)
               {
                  this._btnOpenVIP = new SimpleButton();
                  this._btnOpenVIP.hitTestState = this._loader2;
                  this._btnOpenVIP.upState = this._loader2;
                  this._btnOpenVIP.downState = this._loader2;
                  this._btnOpenVIP.overState = this._loader2;
                  this._btnOpenVIP.x = 355;
                  this._btnOpenVIP.y = this._tile_top;
                  this._btnOpenVIP.addEventListener(MouseEvent.CLICK,this.onNavigateToURL);
                  addChild(this._btnOpenVIP);
               }
               else
               {
                  this._btnOpenVIP.visible = true;
               }
               _tile.scrollVerticalReset();
            }
         }
      }
   }
}

