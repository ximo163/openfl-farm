package module.shop.widgets
{
   import com.qzone.qui.containers.HBox;
   import com.qzone.qui.containers.TileList;
   import com.qzone.qui.controls.Button;
   import com.qzone.qui.controls.Label;
   import com.qzone.qui.controls.scrollClasses.ScrollPolicy;
   import com.qzone.qui.core.Align;
   import com.qzone.qui.makers.RadioGroup;
   import com.qzone.qui.utils.TextFormatUtil;
   import common.Consts;
   import common.Language;
   import common.misc.Utils;
   import common.view.window.WindowLabelMaker;
   import entities.Item;
   import flash.display.DisplayObjectContainer;
   import flash.display.Shape;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import framework.base.BasePage;
   
   public class ItemsPage extends BasePage
   {
      
      private const _tile_top:int = 23;
      
      private var _weaponCache:Array;
      
      private var _filterType:String;
      
      private var _label:Label;
      
      private const _tile_height:int = 275;
      
      private var _normalCache:Array;
      
      public function ItemsPage(param1:DisplayObjectContainer, param2:int, param3:int)
      {
         var _loc4_:HBox = null;
         super(param1,param2,param3);
         this._filterType = "normal";
         this._normalCache = null;
         this._weaponCache = null;
         this._label = new Label(Language.L["toolTileDirection"]);
         this._label.x = 2;
         this._label.width = param2 - 5;
         WindowLabelMaker.addTarget(this._label);
         addChild(this._label);
         _loc4_ = new HBox(param2 - 2,27);
         _loc4_.verticalScrollPolicy = ScrollPolicy.OFF;
         _loc4_.horizontalScrollPolicy = ScrollPolicy.OFF;
         _loc4_.alignH = Align.LEFT;
         _loc4_.alignV = Align.TOP;
         _loc4_.paddingH = 10;
         _loc4_.paddingV = 0;
         _loc4_.defaultSkin = null;
         _loc4_.backgroundColor = 14219772;
         _loc4_.backgroundAlpha = 1;
         _loc4_.addEventListener(MouseEvent.CLICK,this.onToolTypeClicked);
         this.addChild(_loc4_);
         var _loc5_:Button = new Button("常规道具");
         _loc5_.name = "normal";
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
         var _loc6_:Button = new Button("武器");
         _loc6_.name = "weapon";
         _loc6_.defaultSkin = _loc5_.defaultSkin;
         _loc6_.selectedSkin = _loc5_.selectedSkin;
         _loc6_.textDefaultFormat = _loc5_.textDefaultFormat;
         _loc6_.textSelectedFormat = _loc5_.textSelectedFormat;
         _loc6_.textOverFormat = _loc5_.textOverFormat;
         _loc6_.toggle = true;
         _loc6_.useHandCursor = true;
         _loc6_.height = 25;
         var _loc7_:RadioGroup = new RadioGroup();
         _loc7_.addTarget(_loc5_);
         _loc4_.addElement(_loc5_);
         _loc7_.addTarget(_loc6_);
         _loc4_.addElement(_loc6_);
         this._label.y += _loc4_.height;
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
            _tile.itemRenderer = ToolItem;
            _tile.y = this._tile_top + this._label.height + 3;
            _tile.width = _preferedWidth - 5;
            _tile.height = this._tile_height;
         }
      }
      
      private function groupTools(param1:Array) : void
      {
         var _loc3_:Array = null;
         var _loc4_:Array = null;
         var _loc5_:Array = null;
         this._normalCache = [];
         this._weaponCache = [];
         var _loc2_:Item = null;
         for each(_loc2_ in param1)
         {
            if(_loc2_._type.toString() == Consts.ITEM_TYPE_WEAPON)
            {
               this._weaponCache.push(_loc2_);
            }
            else
            {
               this._normalCache.push(_loc2_);
            }
         }
         _loc3_ = [];
         _loc4_ = [];
         _loc5_ = [];
         for each(_loc2_ in this._normalCache)
         {
            if(_loc2_._id >= Consts.ORGANIC_FERTILIZER_ID && _loc2_._id < 100 || _loc2_._id >= 9104 && _loc2_._id <= 9106)
            {
               _loc3_.push(_loc2_);
            }
            else if(_loc2_._isQDDog)
            {
               _loc5_.push(_loc2_);
            }
            else
            {
               _loc4_.push(_loc2_);
            }
         }
         _loc3_.sortOn("_id",Array.DESCENDING);
         for each(_loc2_ in _loc5_)
         {
            _loc4_.unshift(_loc2_);
         }
         for each(_loc2_ in _loc3_)
         {
            _loc4_.unshift(_loc2_);
         }
         this._normalCache.splice(0,-1);
         this._normalCache = _loc4_;
      }
      
      override public function set dataList(param1:Array) : void
      {
         if(_tile == null)
         {
            _tile = new TileList();
            this.onCreateTile();
            addChild(_tile);
         }
         this.groupTools(param1);
         if(this._filterType == "normal")
         {
            _tile.dataProvider = this._normalCache;
         }
         else if(this._filterType == "weapon")
         {
            _tile.dataProvider = this._weaponCache;
         }
      }
      
      private function onToolTypeClicked(param1:Event) : void
      {
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
            if(this._filterType == "normal")
            {
               _tile.y = this._tile_top + this._label.height + 3;
               this._label.visible = true;
               _tile.itemRenderer = ToolItem;
               _tile.dataProvider = this._normalCache;
               _tile.height = this._tile_height;
               _tile.scrollVerticalReset();
            }
            else if(this._filterType == "weapon")
            {
               _tile.y = this._tile_top;
               this._label.visible = false;
               _tile.itemRenderer = ToolItem;
               _tile.dataProvider = this._weaponCache;
               _tile.height = this._tile_height - this._label.height - 3;
               _tile.scrollVerticalReset();
            }
         }
      }
   }
}

