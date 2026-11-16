package mc.view.common
{
   import common.CommonData;
   import common.MaterialLib;
   import flash.display.DisplayObject;
   import flash.display.Loader;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.SecurityErrorEvent;
   import flash.net.URLRequest;
   import flash.system.ApplicationDomain;
   import mc.view.CropLoader;
   import mc.view.farm.GetCropID;
   
   public class MaterialLoaderProxy extends Sprite
   {
      
      private var _cardID:String;
      
      private var childObject:DisplayObject;
      
      private var cropsLoader:CropLoader;
      
      protected var _type:String;
      
      protected var _addOn:Object;
      
      private var _bg:Sprite;
      
      private var _h:int = 61;
      
      public var smallBg:Boolean;
      
      private var _loader:Loader;
      
      private var _w:int = 61;
      
      protected var _id:int;
      
      public function MaterialLoaderProxy()
      {
         super();
         this._w = this._h = 61;
         this._loader = new Loader();
         this._bg = MaterialLib.getInstance().getMaterial("MaterialLoading") as Sprite;
         this.smallBg = false;
      }
      
      private function setMaterial() : void
      {
         if(this.childObject)
         {
            removeChild(this.childObject);
            this.childObject = null;
         }
         this.childObject = MaterialLib.getInstance().getMaterial(this._cardID) as DisplayObject;
         addChild(this.childObject);
         this.childObject.width = this._w;
         this.childObject.height = this._h;
      }
      
      public function loadWare() : void
      {
         var _loc1_:String = GetCropID.getWareHouseIconUrl(this._id);
         this.load(_loc1_);
      }
      
      private function onLoadComplete(param1:Event) : void
      {
         if(this.smallBg == true)
         {
            this._loader.width = this._w;
            this._loader.height = this._h;
         }
         addChild(this._loader);
         this.hideBg();
         dispatchEvent(new Event(Event.COMPLETE));
      }
      
      private function loadHunter(param1:String) : void
      {
         var _loc2_:String = GetCropID.getSwfUrl();
         _loc2_ += "farm/hunter/h_" + param1 + ".jpg";
         this.load(_loc2_);
      }
      
      public function loadAnimal() : void
      {
         var _loc1_:Array = null;
         var _loc2_:String = null;
         if(!MaterialLib.getInstance().getMaterial("Animal_" + this._id + "_1"))
         {
            _loc1_ = [];
            _loc2_ = GetCropID.getAnimalURL(String(this._id),1);
            _loc1_.push(_loc2_);
            this.cropsLoader = new CropLoader();
            this.cropsLoader.addEventListener(Event.COMPLETE,this.compFn);
            this.cropsLoader.load(_loc1_,true);
         }
         else
         {
            this.loadPack();
         }
      }
      
      public function loadBg(param1:String) : void
      {
         var _loc2_:String = GetCropID.getShopDiyUrl(param1);
         this.load(_loc2_);
      }
      
      public function getWildIcon(param1:String, param2:int, param3:String) : String
      {
         var _loc4_:String = "";
         _loc4_ = GetCropID.getSwfUrl();
         return _loc4_ + ("farm/wild/pic/" + param1 + "_" + param3 + "_" + param2 + ".jpg");
      }
      
      public function loadAnimalIcon(param1:Boolean = false, param2:Boolean = false) : void
      {
         var _loc3_:String = GetCropID.getShopIconUrl(this._id,false,param1,param2);
         this.load(_loc3_);
      }
      
      private function onLoaderError(param1:IOErrorEvent = null) : void
      {
         var _loc2_:Sprite = MaterialLib.getInstance().getMaterial("MaterialLoadError") as Sprite;
         addChild(_loc2_);
         dispatchEvent(new Event("error"));
      }
      
      private function loadPack() : void
      {
         var _loc1_:String = GetCropID.getShopIconUrl(this._id);
         this.load(_loc1_);
      }
      
      private function showBg() : void
      {
         if(this._bg)
         {
            addChild(this._bg);
         }
         this._bg.visible = true;
      }
      
      protected function load(param1:String) : void
      {
         this._loader.unload();
         this._loader.contentLoaderInfo.addEventListener(Event.COMPLETE,this.onLoadComplete);
         this._loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,this.onLoaderError);
         this._loader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR,this.onLoaderSecError);
         this._loader.load(new URLRequest(param1));
      }
      
      public function hideBg() : void
      {
         if(Boolean(this._bg) && contains(this._bg))
         {
            removeChild(this._bg);
         }
         this._bg.visible = false;
      }
      
      public function loadMaterial() : void
      {
         this._cardID = "Card_" + this._id.toString();
         trace(GetCropID.idToCardSrc(this._id.toString()));
         CommonData.rslManager.requestClass(this._cardID,this.setMaterial,GetCropID.idToCardSrc(this._id.toString()));
      }
      
      private function onLoaderSecError(param1:SecurityErrorEvent = null) : void
      {
         var _loc2_:Sprite = MaterialLib.getInstance().getMaterial("MaterialLoadError") as Sprite;
         addChild(_loc2_);
         dispatchEvent(new Event("error"));
      }
      
      private function loadOk(param1:Event) : void
      {
         addChild(this._loader);
      }
      
      private function laodWild() : void
      {
         var _loc1_:String = this.getWildIcon(this._type,this._id,this._addOn["type"]);
         this.load(_loc1_);
      }
      
      public function setContent(param1:String, param2:int, param3:Object = null, param4:Boolean = false, param5:Boolean = false, param6:Boolean = false, param7:Boolean = false) : void
      {
         this._type = param1;
         this._id = param2;
         this._addOn = param3;
         if(param1 == "1")
         {
            this.loadAnimalIcon(param4,param7);
         }
         if(param1 == "2")
         {
            this.loadWare();
         }
         if(param1 == "9")
         {
            this.loadAnimal();
         }
         if(param1 == "11")
         {
            this.loadMaterial();
         }
         if(param1 == "wild_drop")
         {
            this.laodWild();
         }
         if(param1 == "hunter")
         {
            this.loadHunter(param2.toString());
         }
         if(param1 == "3")
         {
            this.loadBg(param2.toString());
         }
         this.showBg();
      }
      
      private function compFn(param1:Event) : void
      {
         var _loc3_:* = undefined;
         var _loc2_:Object = this.cropsLoader.contents;
         for each(_loc3_ in _loc2_)
         {
            if(!(_loc3_ is ApplicationDomain))
            {
               dispatchEvent(new Event("animal_error"));
               this.onLoaderError();
               return;
            }
            MaterialLib.getInstance().push(_loc3_);
         }
         this.loadPack();
      }
   }
}

