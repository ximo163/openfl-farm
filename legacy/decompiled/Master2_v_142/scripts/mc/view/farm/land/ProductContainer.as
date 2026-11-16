package mc.view.farm.land
{
   import common.LocalData;
   import common.MaterialLib;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.utils.setTimeout;
   import mc.control.Command;
   import mc.control.FarmCommand;
   import mc.control.ViewControl;
   import mc.events.TipEvent;
   import mc.model.FarmData;
   import mc.model.MData;
   import mc.model.MainData;
   import mc.model.ModelEvent;
   import mc.model.ProductData;
   import mc.view.farm.GetCropID;
   import mc.view.main.cursor.Cursor;
   import mc.view.main.floating.Float;
   
   public class ProductContainer extends Sprite
   {
      
      public static var mouseE:MouseEvent;
      
      public static var _foodClick:Boolean = true;
      
      private var farmData:FarmData;
      
      private var mainData:MainData;
      
      private var lib:MaterialLib = MaterialLib.getInstance();
      
      private var timeoutId:Number;
      
      private var _candoFlag:MovieClip;
      
      private var _pList:Object = new Object();
      
      private var _grassCutter:GrassCutter;
      
      private var _npcContent:NPContainer = new NPContainer();
      
      private var productData:ProductData;
      
      public function ProductContainer()
      {
         super();
         this.farmData = MData.getInstance().farmData;
         this.productData = MData.getInstance().productData;
         this.mainData = MData.getInstance().mainData;
         addChild(this._npcContent);
         this._grassCutter = GrassCutter.getInstance();
         this.addChild(this._grassCutter);
         this._candoFlag = MaterialLib.getInstance().getMaterial("CandoMC") as MovieClip;
         this.farmData.addEventListener(FarmData.HARVEST_DATA,this.shouHuo,false,0,true);
         this.productData.addEventListener(ProductData.PRODUCT_CHANGES,this.changeProduct);
         this.productData.addEventListener(ProductData.PRODUCT_INIT,this.addProducts);
         this.productData.addEventListener(ProductData.PRODUCT_ADD,this.addProduct);
         this.mainData.addEventListener("no_reg",this.noReg);
         ViewControl.getInstance().addEventListener("check_do",this.changeDo);
         this.farmData.addEventListener(FarmData.FARM_OPERATE,this.farmOperate,false,0,true);
      }
      
      private function updateLayer() : void
      {
         addChild(this._grassCutter);
      }
      
      private function hideProduct() : void
      {
         var _loc1_:Object = null;
         for(_loc1_ in this.productData.products)
         {
            if(this.productData.products[_loc1_].amount <= 0)
            {
               if(this.contains(this._pList[String(_loc1_)]))
               {
                  removeChild(this._pList[String(_loc1_)]);
                  (this._pList[String(_loc1_)] as product).gotoAndStop(1);
               }
            }
            else
            {
               addChild(this._pList[String(_loc1_)]);
            }
         }
         this.changeDo();
      }
      
      private function addProduct(param1:ModelEvent) : void
      {
         var _loc2_:String = param1.data as String;
         var _loc3_:product = new product(_loc2_);
         if(GetCropID.getHouse(_loc2_) == "窝")
         {
            _loc3_.x = 580 + Math.floor(Math.random() * 60);
            _loc3_.y = 330;
         }
         else
         {
            _loc3_.x = 350 + Math.floor(Math.random() * 100);
            _loc3_.y = 330;
         }
         _loc3_.name = _loc2_;
         _loc3_.addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver,false,0,true);
         _loc3_.addEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut,false,0,true);
         _loc3_.addEventListener(MouseEvent.CLICK,this.onClick,false,0,true);
         _loc3_.mouseChildren = false;
         this._pList[_loc2_] = _loc3_;
         addChild(_loc3_);
         this.hideProduct();
         this.updateLayer();
      }
      
      private function noReg(param1:Event) : void
      {
         _foodClick = false;
      }
      
      private function onMouseOut(param1:MouseEvent) : void
      {
         var _loc2_:MovieClip = param1.currentTarget as MovieClip;
         _loc2_.filters = [];
         var _loc3_:TipEvent = new TipEvent(TipEvent.TIP_HIDE);
         ViewControl.getInstance().dispatchEvent(_loc3_);
      }
      
      private function shouHuo(param1:Event) : void
      {
         var _loc2_:Object = this.farmData.harvestData;
         var _loc3_:product = this.getChildByName(_loc2_.cId) as product;
         if(!_loc3_)
         {
            return;
         }
         _loc3_.num = _loc2_.harvestnum;
         _loc3_.play();
      }
      
      private function changeDo(param1:Event = null) : void
      {
         var _loc2_:String = null;
         var _loc3_:Boolean = false;
         var _loc4_:product = null;
         var _loc5_:Array = null;
         var _loc6_:int = 0;
         this.mainData = MData.getInstance().mainData;
         for(_loc2_ in this.productData.products)
         {
            _loc3_ = false;
            _loc4_ = this._pList[_loc2_] as product;
            _loc5_ = this.mainData.animalData;
            _loc6_ = 0;
            while(_loc6_ < _loc5_.length)
            {
               if(Boolean(_loc5_[_loc6_]) && Boolean(_loc5_[_loc6_].status == FarmData.ANIMAL_SHENGCHAN) && _loc5_[_loc6_].cId == _loc4_.name)
               {
                  _loc3_ = true;
                  break;
               }
               _loc6_++;
            }
            if(_loc3_)
            {
               if(_loc4_.contains(this._candoFlag))
               {
                  _loc4_.removeChild(this._candoFlag);
               }
               break;
            }
            if(this.productData.products[_loc2_].cando == 3 && this.productData.products[_loc2_].amount > 0)
            {
               addChild(_loc4_);
               _loc4_.addChild(this._candoFlag);
               _loc4_.flag = this._candoFlag;
               if(this.mainData.me)
               {
                  this._candoFlag.doTxt.text = "可收获";
               }
               else
               {
                  this._candoFlag.doTxt.text = "可收取";
               }
               this._candoFlag.y = -30;
            }
            else
            {
               if(_loc4_.flag)
               {
                  _loc4_.flag = null;
               }
               if(_loc4_.contains(this._candoFlag))
               {
                  _loc4_.removeChild(this._candoFlag);
               }
            }
         }
         this.updateLayer();
      }
      
      private function changeProduct(param1:Event) : void
      {
         var _loc2_:Number = Command.getInstance().farmCommand.isShouhuo ? 800 : 0;
         setTimeout(this.hideProduct,_loc2_);
      }
      
      private function addProducts(param1:Event) : void
      {
         var _loc2_:String = null;
         var _loc3_:ProductData = null;
         var _loc4_:Object = null;
         var _loc5_:product = null;
         for(_loc2_ in this._pList)
         {
            if(Boolean(this._pList[_loc2_]) && contains(this._pList[_loc2_]))
            {
               removeChild(this._pList[_loc2_]);
            }
         }
         this._pList = {};
         _loc3_ = MData.getInstance().productData;
         _loc4_ = _loc3_.products;
         for(_loc2_ in _loc4_)
         {
            _loc5_ = new product(_loc2_);
            if(GetCropID.getHouse(_loc2_) == "窝")
            {
               _loc5_.x = 580 + Math.floor(Math.random() * 60);
               _loc5_.y = 330;
            }
            else
            {
               _loc5_.x = 350 + Math.floor(Math.random() * 100);
               _loc5_.y = 330;
            }
            _loc5_.name = _loc2_;
            _loc5_.addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver,false,0,true);
            _loc5_.addEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut,false,0,true);
            _loc5_.addEventListener(MouseEvent.CLICK,this.onClick,false,0,true);
            _loc5_.mouseChildren = false;
            this._pList[_loc2_] = _loc5_;
         }
         this.updateLayer();
      }
      
      private function onClick(param1:MouseEvent) : void
      {
         var _loc3_:FarmCommand = null;
         if(Cursor.name == "")
         {
            return;
         }
         mouseE = param1;
         var _loc2_:TipEvent = new TipEvent(TipEvent.TIP_HIDE);
         ViewControl.getInstance().dispatchEvent(_loc2_);
         _loc3_ = Command.getInstance().farmCommand;
         if(Cursor.name == "Cursor_ShengChan")
         {
            if(_loc3_.playShouHuoAnimation)
            {
               return;
            }
            _loc3_.ShouHuo(param1.currentTarget.name,1);
         }
         if(Cursor.name == "Cursor_Theft")
         {
            if(LocalData.stealFlag == false)
            {
               Command.getInstance().mainCommand.alertWindow("error",LocalData.stealTxt);
            }
            else
            {
               _loc3_.Theft(param1.currentTarget.name);
            }
         }
         if(Cursor.name == "Cursor_ShouHuoAll")
         {
            if(!this.mainData.me)
            {
               _loc3_.Theft(param1.currentTarget.name,true);
            }
            else
            {
               if(_loc3_.playShouHuoAnimation)
               {
                  return;
               }
               _loc3_.ShouHuo(param1.currentTarget.name,1,true);
            }
         }
      }
      
      private function farmOperate(param1:Event = null) : void
      {
         var _loc4_:DisplayObject = null;
         var _loc2_:FarmOperateFloating = new FarmOperateFloating();
         _loc2_.text = this.farmData.farmOperate["text"];
         var _loc3_:String = this.farmData.farmOperate["type"];
         if(Boolean(mouseE) && _loc3_ == "product")
         {
            _loc2_.x = mouseE.stageX;
            _loc2_.y = mouseE.stageY;
            Float.open(_loc2_);
            mouseE = null;
         }
         if(_loc3_ == "food")
         {
            _loc4_ = this._grassCutter.getChildByName("food");
            _loc2_.x = _loc4_.x - LocalData.rollCollection.scrollRect.x + 60;
            _loc2_.y = _loc4_.y - LocalData.rollCollection.scrollRect.y;
            Float.open(_loc2_);
         }
      }
      
      private function onMouseOver(param1:MouseEvent) : void
      {
         var _loc2_:MovieClip = param1.currentTarget as MovieClip;
         if(Cursor.name == "Cursor_ShengChan" || Cursor.name == "Cursor_ShouHuoAll" || Cursor.name == "Cursor_Theft")
         {
            _loc2_.filters = MainData.rollOverFilter;
         }
         var _loc3_:TipEvent = new TipEvent(TipEvent.TIP_SHOW);
         _loc3_.tipType = "ProductInfo";
         _loc3_.tipArgument = _loc2_;
         ViewControl.getInstance().dispatchEvent(_loc3_);
      }
   }
}

import common.CommonData;
import common.MaterialLib;
import flash.display.*;
import mc.view.farm.GetCropID;

class product extends MovieClip
{
   
   private var content:MovieClip = new MovieClip();
   
   private var _id:String;
   
   public var flag:MovieClip;
   
   public function product(param1:String)
   {
      super();
      this._id = param1;
      var _loc2_:String = GetCropID.getSwfUrl() + "farm/product/p" + this._id + ".swf";
      CommonData.rslManager.requestClass("Product" + this._id,this.getMaterial,_loc2_);
   }
   
   override public function stop() : void
   {
      this.content.stop();
   }
   
   override public function play() : void
   {
      this.content.play();
      if(Boolean(this.flag) && Boolean(contains(this.flag)))
      {
         removeChild(this.flag);
      }
   }
   
   override public function gotoAndPlay(param1:Object, param2:String = null) : void
   {
      this.content.gotoAndPlay(param1);
   }
   
   public function set num(param1:int) : void
   {
      this.content.num = param1;
   }
   
   override public function gotoAndStop(param1:Object, param2:String = null) : void
   {
      this.content.gotoAndStop(param1);
   }
   
   private function getMaterial() : void
   {
      this.content = MaterialLib.getInstance().getMaterial("Product" + this._id) as MovieClip;
      addChild(this.content);
      if(Boolean(this.flag) && Boolean(contains(this.flag)))
      {
         addChild(this.flag);
      }
   }
}
