package common.view
{
   import com.qzone.corelib.net.RSLManager;
   import com.qzone.farm.api.interfaces.IPluginProxy;
   import com.qzone.qui.styles.Style;
   import com.qzone.utils.DisplayUtil;
   import common.Consts;
   import common.GetCropID;
   import common.Settings;
   import common.misc.Utils;
   import flash.display.DisplayObject;
   import flash.display.Loader;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.net.URLRequest;
   import framework.api.PluginManager;
   
   public class MaterialProxy extends Sprite
   {
      
      public static const BIG:String = "big";
      
      public static const SMALL:String = "small";
      
      public static const CARDSGAME:String = "CardsGame";
      
      protected var currentType:String;
      
      protected var _size:String;
      
      protected var _enable:Boolean;
      
      protected var _loaded:Boolean;
      
      protected var itemLoading:Sprite;
      
      protected var _h:int;
      
      protected var currentId:int = 0;
      
      protected var _w:int;
      
      protected var childObjcet:DisplayObject;
      
      public function MaterialProxy(param1:String = "small")
      {
         super();
         mouseChildren = false;
         cacheAsBitmap = true;
         this._enable = true;
         this._size = param1;
         if(this._size == SMALL)
         {
            this._w = this._h = 60;
         }
         else if(this._size == CARDSGAME)
         {
            this._w = this._h = 80;
         }
         else
         {
            this._w = this._h = 120;
         }
         this.currentType = "";
         this.itemLoading = null;
         this._loaded = false;
      }
      
      private function setDog() : void
      {
         var _loc1_:int = this.currentId;
         var _loc2_:String = "Dog" + _loc1_.toString();
         this.remove();
         if(_loc2_ == "")
         {
            return;
         }
         this.hideLoading();
         this.childObjcet = Utils.getMaterial(_loc2_) as DisplayObject;
         if(this.childObjcet == null)
         {
            return;
         }
         if(this._size == SMALL)
         {
            this.childObjcet.scaleX = 0.5;
            this.childObjcet.scaleY = 0.5;
         }
         else if(this._size == BIG)
         {
            this.childObjcet.scaleX = 1;
            this.childObjcet.scaleY = 1;
         }
         this.childObjcet.x = (this._w - this.childObjcet.width) / 2;
         this.childObjcet.y = (this._h - this.childObjcet.height) / 2;
         this.enableChild(this._enable);
         addChild(this.childObjcet);
         this._loaded = true;
      }
      
      public function get loaded() : Boolean
      {
         return this._loaded;
      }
      
      public function setContent(param1:String, param2:int, param3:Boolean = true) : void
      {
         var _loc6_:String = null;
         var _loc7_:String = null;
         var _loc8_:String = null;
         var _loc9_:String = null;
         var _loc10_:String = null;
         var _loc11_:String = null;
         var _loc12_:String = null;
         var _loc13_:String = null;
         var _loc14_:IPluginProxy = null;
         var _loc15_:Class = null;
         if(this.currentType == param1 && this.currentId == param2 && param3 == this._enable)
         {
            return;
         }
         this._enable = param3;
         this.currentType = param1;
         var _loc4_:RSLManager = RSLManager.getInstance();
         var _loc5_:Settings = Settings.getInstance();
         if(param1 == Consts.ITEM_TYPE_SEED)
         {
            this.currentId = param2;
            _loc6_ = GetCropID.getSeedUrl(this.currentId);
            _loc4_.requestClass(_loc5_.getSeedName(this.currentId),this.setCrop,_loc6_);
         }
         else if(param1 == Consts.ITEM_TYPE_CRYSTAL)
         {
            this.currentId = param2;
            _loc7_ = _loc5_.getStringAttribute("NcDrop9");
            _loc4_.requestClass(_loc5_.getCrystalName(param1,this.currentId),this.setCrystal,_loc7_);
         }
         else if(param1 == Consts.ITEM_TYPE_WEAPON)
         {
            this.currentId = param2;
            _loc8_ = _loc5_.getStringAttribute("wildaweapon") + "weapon" + this.currentId + ".swf";
            _loc4_.requestClass(_loc5_.getWeaponName("Small",this.currentId),this.setWeapon,_loc8_,{"id":param2});
         }
         else if(param1 == Consts.ITEM_TYPE_CARD)
         {
            this.currentId = param2;
            _loc9_ = GetCropID.getSeedUrl(this.currentId,Consts.ITEM_TYPE_CARD);
            _loc4_.requestClass(_loc5_.getCardName(this.currentId),this.setCard,_loc9_);
         }
         else if(param1 == Consts.ITEM_TYPE_TOOL || param1 == Consts.ITEM_TYPE_STICK || param1 == Consts.ITEM_TYPE_PESTICIDE || param1 == Consts.ITEM_TYPE_DOGFOOD)
         {
            this.currentId = param2;
            _loc10_ = GetCropID.idToToolName(param2.toString());
            _loc11_ = "";
            if(_loc10_ == "FertilizerMagic")
            {
               _loc11_ = _loc5_.getSecondUrl("tvShowIcon");
            }
            else
            {
               _loc11_ = _loc5_.getSecondUrl("Fertilizer");
            }
            _loc4_.requestClass(_loc10_,this.setTool,_loc11_);
         }
         else if(param1 == Consts.ITEM_TYPE_FISHFEED)
         {
            this.currentId = param2;
            _loc4_.requestClass("FishFood_" + param2,this.setFishFood,_loc5_.getSecondUrl("Fertilizer"));
         }
         else if(param1 == Consts.ITEM_TYPE_DECORATE)
         {
            this.setDiy(param2);
         }
         else if(param1 == Consts.ITEM_TYPE_DOG)
         {
            this.currentId = param2;
            _loc12_ = "FDog" + this.currentId.toString();
            _loc10_ = "Dog" + param2.toString();
            _loc11_ = GetCropID.idToDogUrl(_loc12_,true);
            _loc4_.requestClass(_loc10_,this.setDog,_loc11_);
         }
         else if(param1 != "5")
         {
            if(param1 == "6")
            {
               this.setGold(param2);
            }
            else if(param1 == "7")
            {
               this.setExp(param2);
            }
            else if(param1 == Consts.DECOR_BILLBOARD.toString())
            {
               this.enableChild(this._enable);
            }
            else if(param1 == Consts.ITEM_TYPE_FISH)
            {
               this.currentId = param2;
               _loc13_ = GetCropID.getFishUrl(this.currentId);
               _loc4_.requestClass(_loc5_.getFishName(this.currentId),this.setFish,_loc13_);
            }
            else if(param1 == Consts.ITEM_TYPE_FAIRY)
            {
               _loc14_ = PluginManager.getInstance().getPluginByID(2);
               if(_loc14_)
               {
                  _loc15_ = _loc14_.executeCommand(2102,null) as Class;
                  if(_loc15_)
                  {
                     this.setChildObject(new _loc15_());
                     this.childObjcet.scaleX = this.childObjcet.scaleY = 1.5;
                     this.childObjcet.x = (this._w - this.childObjcet.width * this.childObjcet.scaleX) / 2;
                     this.childObjcet.y = (this._h - this.childObjcet.height) / 2;
                  }
               }
            }
         }
         this.currentId = param2;
      }
      
      protected function remove() : void
      {
         if(this.childObjcet != null)
         {
            if(this.childObjcet.parent)
            {
               this.childObjcet.parent.removeChild(this.childObjcet);
            }
            this.childObjcet = null;
         }
         this._loaded = false;
      }
      
      private function setGold(param1:int) : void
      {
         this.setChildObjectByMaterialName("GoldCardsGame");
         this._loaded = true;
      }
      
      public function get size() : String
      {
         return this._size;
      }
      
      private function setCard() : void
      {
         var _loc1_:String = "";
         var _loc2_:int = this.currentId;
         if(_loc2_ > 0)
         {
            _loc1_ = Settings.getInstance().getCardName(this.currentId);
         }
         this.remove();
         this.setMaterialByName(_loc1_);
      }
      
      public function loadBillBoard(param1:String) : void
      {
         var ld:Loader;
         var url:String = param1;
         this.remove();
         this._w = this._h = 100;
         ld = new Loader();
         ld.mouseChildren = false;
         ld.mouseEnabled = false;
         ld.contentLoaderInfo.addEventListener(Event.COMPLETE,function():void
         {
            childObjcet.width = childObjcet.height = 94;
            childObjcet.x = (_w - childObjcet.width) / 2;
            childObjcet.y = (_h - childObjcet.height) / 2;
            arguments[0].target.removeEventListener(Event.COMPLETE,arguments.callee);
            _loaded = true;
            hideLoading();
         });
         ld.load(new URLRequest(url));
         this.childObjcet = ld;
         this.enableChild(this._enable);
         addChild(this.childObjcet);
      }
      
      public function hideLoading() : void
      {
         if(this.itemLoading == null)
         {
            return;
         }
         DisplayUtil.removeChild(this,this.itemLoading);
         this.itemLoading = null;
      }
      
      private function setExp(param1:int) : void
      {
         this.setChildObjectByMaterialName("ExpIcon");
         this._loaded = true;
      }
      
      private function setWeapon(param1:Object) : void
      {
         var _loc2_:String = "";
         var _loc3_:int = param1["id"] as int;
         if(_loc3_ > 0)
         {
            _loc2_ = Settings.getInstance().getWeaponName("Small",_loc3_);
         }
         this.remove();
         this.setMaterialByName(_loc2_);
      }
      
      private function setFishFood() : void
      {
         var _loc1_:int = this.currentId;
         this.remove();
         var _loc2_:String = "FishFood_" + _loc1_;
         this.childObjcet = Utils.getMaterial(_loc2_) as DisplayObject;
         if(!this.childObjcet)
         {
            this.childObjcet = new Sprite();
         }
         this.hideLoading();
         if(this._size == SMALL)
         {
            this.childObjcet.scaleX = 1;
            this.childObjcet.scaleY = 1;
         }
         else if(this._size == BIG)
         {
            this.childObjcet.scaleX = 2;
            this.childObjcet.scaleY = 2;
         }
         this.childObjcet.x = (this._w - this.childObjcet.width) / 2;
         this.childObjcet.y = (this._h - this.childObjcet.height) / 2;
         this.enableChild(this._enable);
         addChild(this.childObjcet);
         this._loaded = true;
      }
      
      private function setMaterialByName(param1:String) : void
      {
         if(param1 == "")
         {
            return;
         }
         this.childObjcet = Utils.getMaterial(param1) as DisplayObject;
         if(this.childObjcet)
         {
            this.hideLoading();
            this._loaded = true;
            if(this._size == SMALL)
            {
               this.childObjcet.scaleX = 1;
               this.childObjcet.scaleY = 1;
            }
            else if(this._size == BIG)
            {
               this.childObjcet.scaleX = 2;
               this.childObjcet.scaleY = 2;
            }
            else if(this._size == CARDSGAME)
            {
               this.childObjcet.scaleX = 1.3;
               this.childObjcet.scaleY = 1.3;
            }
            this.childObjcet.x = (this._w - this.childObjcet.width) / 2;
            this.childObjcet.y = (this._h - this.childObjcet.height) / 2;
            this.enableChild(this._enable);
            addChild(this.childObjcet);
         }
      }
      
      private function setCrop() : void
      {
         var _loc1_:String = "";
         var _loc2_:int = this.currentId;
         if(_loc2_ > 0)
         {
            _loc1_ = Settings.getInstance().getSeedName(this.currentId);
         }
         this.remove();
         this.setMaterialByName(_loc1_);
      }
      
      protected function enableChild(param1:Boolean) : void
      {
         if(param1 == true)
         {
            this.childObjcet.filters = null;
            mouseEnabled = true;
         }
         else
         {
            this.childObjcet.filters = Style.getDisableFilter();
            mouseEnabled = false;
         }
      }
      
      private function setFish() : void
      {
         var _loc1_:String = "";
         var _loc2_:int = this.currentId;
         if(_loc2_ > 0)
         {
            _loc1_ = Settings.getInstance().getFishName(this.currentId);
         }
         this.remove();
         this.setMaterialByName(_loc1_);
      }
      
      private function setDiy(param1:int) : void
      {
         var _loc2_:String = GetCropID.idToDiyUrl(param1.toString(),this._size == SMALL);
         if(_loc2_ == "")
         {
            _loc2_ = Settings.getInstance().getSecondUrl(param1.toString() + (this._size == SMALL ? "" : "b"));
         }
         if(_loc2_ == "")
         {
            return;
         }
         if(param1 != this.currentId)
         {
            this.remove();
            this.childObjcet = new Loader();
            (this.childObjcet as Loader).load(new URLRequest(_loc2_));
            addChild(this.childObjcet);
         }
         if(this.childObjcet == null)
         {
            return;
         }
         this._loaded = true;
         if(this._enable)
         {
            this.childObjcet.filters = [];
         }
         else
         {
            this.childObjcet.filters = Style.getDisableFilter();
         }
      }
      
      private function setChildObject(param1:DisplayObject) : void
      {
         this.remove();
         this.childObjcet = param1;
         if(this.childObjcet == null)
         {
            return;
         }
         if(this._size == SMALL)
         {
            this.childObjcet.scaleX = 1;
            this.childObjcet.scaleY = 1;
         }
         else if(this._size == BIG)
         {
            this.childObjcet.scaleX = 1.5;
            this.childObjcet.scaleY = 1.5;
         }
         else if(this._size == CARDSGAME)
         {
            this.childObjcet.scaleX = 1.1;
            this.childObjcet.scaleY = 1.1;
         }
         this.childObjcet.x = (this._w - this.childObjcet.width) / 2;
         this.childObjcet.y = (this._h - this.childObjcet.height) / 2;
         this.enableChild(this._enable);
         addChild(this.childObjcet);
      }
      
      private function setChildObjectByMaterialName(param1:String) : void
      {
         var _loc2_:DisplayObject = Utils.getMaterial(param1) as DisplayObject;
         this.setChildObject(_loc2_);
      }
      
      private function setCrystal() : void
      {
         var _loc1_:String = "";
         var _loc2_:int = this.currentId;
         if(_loc2_ > 0)
         {
            _loc1_ = Settings.getInstance().getCrystalName(this.currentType,this.currentId);
         }
         this.remove();
         this.setMaterialByName(_loc1_);
      }
      
      private function setTool() : void
      {
         var _loc1_:int = this.currentId;
         var _loc2_:String = GetCropID.idToToolName(_loc1_.toString());
         this.remove();
         if(_loc2_ == "")
         {
            return;
         }
         this.childObjcet = Utils.getMaterial(_loc2_) as DisplayObject;
         if(!this.childObjcet)
         {
            this.childObjcet = new Sprite();
         }
         this.hideLoading();
         if(this._size == SMALL)
         {
            this.childObjcet.scaleX = 1;
            this.childObjcet.scaleY = 1;
         }
         else if(this._size == BIG)
         {
            this.childObjcet.scaleX = 2;
            this.childObjcet.scaleY = 2;
         }
         this.childObjcet.x = (this._w - this.childObjcet.width) / 2;
         this.childObjcet.y = (this._h - this.childObjcet.height) / 2;
         this.enableChild(this._enable);
         addChild(this.childObjcet);
         this._loaded = true;
      }
      
      public function showLoading() : void
      {
         if(this.itemLoading == null)
         {
            this.itemLoading = new ItemLoading();
            this.addChild(this.itemLoading);
         }
         if(this._w > 60)
         {
            this.itemLoading.x = (this._w - this.itemLoading.width) * 0.5;
            this.itemLoading.y = (this._h - this.itemLoading.height) * 0.5;
         }
      }
   }
}

