package mc.view.farm.land
{
   import common.LocalData;
   import common.MaterialLib;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.net.URLRequest;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import mc.model.FarmData;
   import mc.model.MData;
   import mc.model.MainData;
   import mc.model.ProductData;
   import mc.view.farm.GetCropID;
   import mc.view.farm.Research.ResearchModel;
   import mc.view.main.tip.Tip;
   
   public class ProductInfo extends Tip
   {
      
      private var farmData:FarmData;
      
      private var mainData:MainData;
      
      private var _dataLoadTotal:int = 3;
      
      private var _dataLoadNum:int;
      
      private var _icon:*;
      
      private var productData:ProductData;
      
      private var pInfo:MovieClip;
      
      public function ProductInfo()
      {
         super();
         this.productData = MData.getInstance().productData;
         this.farmData = MData.getInstance().farmData;
         this.mainData = MData.getInstance().mainData;
      }
      
      private function removeProductInfo() : void
      {
         if(this.pInfo == null)
         {
            return;
         }
         if(contains(this.pInfo))
         {
            removeChild(this.pInfo);
         }
      }
      
      private function addProductInfo() : void
      {
         if(this.pInfo == null)
         {
            this.pInfo = MaterialLib.getInstance().getMaterial("ProductInfo") as MovieClip;
            this.pInfo.cacheAsBitmap = true;
         }
         addChild(this.pInfo);
      }
      
      private function onUncaughtError(param1:*) : void
      {
         param1.preventDefault();
      }
      
      override public function set data(param1:Object) : void
      {
         var _loc4_:Object = null;
         var _loc5_:Number = NaN;
         var _loc6_:String = null;
         var _loc7_:int = 0;
         var _loc8_:String = null;
         var _loc11_:String = null;
         super.data = param1;
         this.x = param1.x - LocalData.rollCollection.scrollRect.x;
         this.y = param1.y - LocalData.rollCollection.scrollRect.y;
         this.addProductInfo();
         if(Boolean(this._icon) && this.pInfo.contains(this._icon))
         {
            this.pInfo.removeChild(this._icon);
            this._icon = null;
         }
         var _loc2_:TextField = this.pInfo.info as TextField;
         var _loc3_:TextFormat = new TextFormat();
         _loc3_.leading = 4;
         if(param1.name == "food")
         {
            _loc4_ = MData.getInstance().farmData.animalFood;
            _loc11_ = "饲料 剩余:" + _loc4_;
            this._icon = MaterialLib.getInstance().getMaterial("FoodTips") as Sprite;
            if(_loc4_ <= 10)
            {
               _loc11_ += "<br>动物饥饿会停止生长，请及时补充饲料。";
            }
            else if(_loc4_ == MainData.MAX_FOOD)
            {
               _loc11_ += "<br>饲料丰足，无需添加。";
            }
            _loc2_.htmlText = _loc11_;
         }
         else if(param1.name == "flyContent1")
         {
            _loc2_.htmlText = "蚊子" + "<br>数量：" + this.farmData.flyData["flyNum1"];
            this._icon = MaterialLib.getInstance().getMaterial("ITips1") as Sprite;
         }
         else if(param1.name == "flyContent2")
         {
            _loc2_.htmlText = "蚊子" + "<br>数量：" + this.farmData.flyData["flyNum2"];
            this._icon = MaterialLib.getInstance().getMaterial("ITips1") as Sprite;
         }
         else if(param1.name == "house1")
         {
            this._icon = MaterialLib.getInstance().getMaterial("HTips1") as Sprite;
            _loc8_ = ResearchModel.gi().HouseStatus["den"];
            _loc6_ = _loc8_.substring(_loc8_.lastIndexOf("_") + 1,_loc8_.lastIndexOf("."));
            _loc7_ = int(this.mainData.host["house1"]);
            _loc5_ = this.mainData.getAnimalNum(Number(_loc7_),"窝");
            if(_loc6_ == "ok")
            {
               _loc2_.htmlText = "窝<br>您当前的窝为" + _loc7_ + "级<br>最多能住" + _loc5_ + "只动物<br>点击收获动物。";
            }
            else if(_loc6_ == "ing")
            {
               _loc2_.htmlText = "窝<br>您当前的窝为" + _loc7_ + "级<br>最多能住" + _loc5_ + "只动物<br>点击查看结束时间";
            }
            else
            {
               _loc2_.htmlText = "窝<br>您当前的窝为" + _loc7_ + "级<br>最多能住" + _loc5_ + "只动物";
            }
         }
         else if(param1.name == "house2")
         {
            this._icon = MaterialLib.getInstance().getMaterial("HTips2") as Sprite;
            _loc8_ = ResearchModel.gi().HouseStatus["shed"];
            _loc6_ = _loc8_.substring(_loc8_.lastIndexOf("_") + 1,_loc8_.lastIndexOf("."));
            _loc7_ = int(this.mainData.host["house2"]);
            _loc5_ = this.mainData.getAnimalNum(Number(_loc7_),"棚");
            if(_loc6_ == "ok")
            {
               _loc2_.htmlText = "棚<br>您当前的棚为" + _loc7_ + "级<br>最多能住" + _loc5_ + "只动物<br>点击收获动物。";
            }
            else if(_loc6_ == "ing")
            {
               _loc2_.htmlText = "棚<br>您当前的棚为" + _loc7_ + "级<br>最多能住" + _loc5_ + "只动物<br>点击查看结束时间";
            }
            else
            {
               _loc2_.htmlText = "棚<br>您当前的棚为" + _loc7_ + "级<br>最多能住" + _loc5_ + "只动物";
            }
         }
         else
         {
            _loc4_ = this.productData.getProduct(param1.name);
            _loc2_.htmlText = _loc4_.cName + "<br>产量：" + _loc4_["amount"];
            this._icon = new Loader();
            this._icon.load(new URLRequest(GetCropID.getAnimalInfoIconUrl(param1.name,"p")));
         }
         var _loc9_:Array = this.mainData.animalData;
         var _loc10_:int = 0;
         while(_loc10_ < _loc9_.length)
         {
            if(Boolean(_loc9_[_loc10_]) && Boolean(_loc9_[_loc10_].status == FarmData.ANIMAL_SHENGCHAN) && _loc9_[_loc10_].cId == param1.name)
            {
               _loc2_.htmlText += "动物生产中，请稍后收获！";
               break;
            }
            _loc10_++;
         }
         if(this._icon)
         {
            this.pInfo.addChild(this._icon);
            this._icon.x = -70;
            this._icon.y = -37;
         }
         _loc2_.setTextFormat(_loc3_);
      }
      
      override public function set mX(param1:Number) : void
      {
         super.mX = param1;
         x = param1;
      }
      
      override public function set mY(param1:Number) : void
      {
         super.mY = param1;
         y = param1 - 50;
      }
   }
}

