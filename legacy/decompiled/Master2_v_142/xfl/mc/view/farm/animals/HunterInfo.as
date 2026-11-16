package mc.view.farm.animals
{
   import common.CatchError;
   import common.LocalData;
   import common.MaterialLib;
   import flash.display.*;
   import flash.net.URLRequest;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import mc.model.FarmData;
   import mc.model.MData;
   import mc.model.MainData;
   import mc.view.farm.GetCropID;
   import mc.view.main.tip.Tip;
   
   public class HunterInfo extends Tip
   {
      
      private var farmData:FarmData;
      
      private var mainData:MainData;
      
      private var _iconLoader:Loader;
      
      private var _dataLoadTotal:int = 3;
      
      private var _dataLoadNum:int;
      
      private var _icon:Sprite;
      
      private var pInfo:MovieClip;
      
      public function HunterInfo()
      {
         super();
         this.farmData = MData.getInstance().farmData;
         this.mainData = MData.getInstance().mainData;
      }
      
      private function onUncaughtError(param1:*) : void
      {
         param1.preventDefault();
      }
      
      private function addProductInfo() : void
      {
         if(this.pInfo == null)
         {
            this.pInfo = MaterialLib.getInstance().getMaterial("ProductInfo") as MovieClip;
            this.pInfo.cacheAsBitmap = true;
            this.pInfo.width = 170;
         }
         addChild(this.pInfo);
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
      
      override public function set data(param1:Object) : void
      {
         var _loc4_:String = null;
         var _loc5_:String = null;
         super.data = param1.data;
         this.x = param1.x - LocalData.rollCollection.scrollRect.x;
         this.y = param1.y - LocalData.rollCollection.scrollRect.y;
         this.addProductInfo();
         var _loc2_:TextField = this.pInfo.info as TextField;
         var _loc3_:Number = this.mainData.hunter.t / 3600;
         if(_loc3_ >= 1)
         {
            _loc4_ = "<font color=\'#FF6600\'><b>" + int(_loc3_ / 24) + "</b></font> 天 <font color=\'#FF6600\'><b>" + int(_loc3_ % 24) + "</b></font> 小时";
         }
         else
         {
            _loc4_ = "小于<font color=\'#FF6600\'><b>1</b></font>小时";
         }
         if(_loc3_ > 0)
         {
            _loc5_ = "工作";
         }
         else
         {
            _loc5_ = "<font color=\'#FF6600\'>罢工</font>";
         }
         var _loc6_:String = data["name"] + "<br>剩余工资可维持时间：<br>" + _loc4_ + "<br>状态：" + _loc5_;
         _loc2_.htmlText = _loc6_;
         var _loc7_:TextFormat = new TextFormat();
         _loc7_.leading = 4;
         _loc2_.setTextFormat(_loc7_);
         if(this._iconLoader)
         {
            this._iconLoader.unload();
            this._iconLoader = null;
         }
         this._iconLoader = new Loader();
         this._iconLoader.x = -70;
         this._iconLoader.y = -35;
         addChild(this._iconLoader);
         this._iconLoader.load(new URLRequest(GetCropID.getHunterPicUrl("Icon_" + data["id"],true)));
         CatchError.catchError(this.onUncaughtError,null,this.loaderInfo);
      }
      
      override public function set mX(param1:Number) : void
      {
         super.mX = param1;
         x = param1;
      }
      
      override public function set mY(param1:Number) : void
      {
         super.mY = param1;
         y = param1 - 70;
      }
   }
}

