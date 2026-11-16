package mc.view.farm.land
{
   import common.CatchError;
   import common.INI;
   import common.LocalData;
   import common.MaterialLib;
   import flash.display.*;
   import flash.net.URLRequest;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormat;
   import mc.model.FarmData;
   import mc.model.MData;
   import mc.model.MainData;
   import mc.view.farm.GetCropID;
   import mc.view.main.tip.Tip;
   
   public class AnimalInfo extends Tip
   {
      
      private static var _xml:XML;
      
      private var mainData:MainData;
      
      private var animalInfo:MovieClip;
      
      private var _dataLoadTotal:int = 3;
      
      private var _dataLoadNum:int;
      
      private var _icon:Loader;
      
      public function AnimalInfo()
      {
         super();
         this.mainData = MData.getInstance().mainData;
      }
      
      private function addFarmInfo() : void
      {
         if(this.animalInfo == null)
         {
            this.animalInfo = MaterialLib.getInstance().getMaterial("Animalnfo") as MovieClip;
            this.animalInfo.cacheAsBitmap = true;
         }
         addChild(this.animalInfo);
      }
      
      private function removeFarmInfo() : void
      {
         if(this.animalInfo == null)
         {
            return;
         }
         if(contains(this.animalInfo))
         {
            removeChild(this.animalInfo);
         }
      }
      
      private function onUncaughtError(param1:*) : void
      {
         param1.preventDefault();
      }
      
      override public function set data(param1:Object) : void
      {
         var animalData:Object;
         var place:int;
         var animallist:Array;
         var str:String = null;
         var f:TextFormat = null;
         var timeStr:String = null;
         var timeList:Array = null;
         var growTimeNext:int = 0;
         var h:String = null;
         var m:String = null;
         var t:String = null;
         var hungry:String = null;
         var s:String = null;
         var value:Object = param1;
         super.data = value;
         if(!value.data)
         {
            return;
         }
         place = int(value.data["serial"]);
         animallist = this.mainData.animalData;
         animalData = this.mainData.animalData[place];
         this.x = value.x - LocalData.rollCollection.scrollRect.x;
         this.y = value.y - LocalData.rollCollection.scrollRect.y;
         if(animalData == null)
         {
            this.removeFarmInfo();
         }
         else
         {
            this.addFarmInfo();
         }
         try
         {
            if(Boolean(this._icon) && this.animalInfo.contains(this._icon))
            {
               this.animalInfo.removeChild(this._icon);
               this._icon.unload();
            }
            this._icon = new Loader();
            this._icon.load(new URLRequest(GetCropID.getAnimalInfoIconUrl(animalData["cId"],"a")));
            this.animalInfo.addChild(this._icon);
            str = GetCropID.idToName(animalData.cId) + " (" + GetCropID.numToNext(animalData.cId,animalData.status,animalData.statusNext) + ")";
            f = new TextFormat();
            f.leading = 4;
            if(animalData.status != FarmData.ANIMAL_SHOUHUO)
            {
               h = Math.floor(animalData.growTimeNext / 3600) > 0 ? Math.floor(animalData.growTimeNext / 3600) + "小时" : "";
               m = Math.floor(animalData.growTimeNext % 3600 / 60) > 0 ? Math.floor(animalData.growTimeNext % 3600 / 60) + "分" : "";
               if(h != "")
               {
                  t = h + m;
               }
               else
               {
                  s = Math.floor(animalData.growTimeNext % 3600 % 60) + "秒";
                  t = m + s;
               }
               if(animalData.status == 3)
               {
                  str += "<br>可以抓去生产";
               }
               else if(animalData.status == 5 && animalData.statusNext == 3)
               {
                  str += "<br>" + t + "后可以再次生产";
               }
               else if(animalData.status == 4)
               {
                  str += "<br>生产中，" + t + "后完成生产";
               }
               else
               {
                  str += "<br>" + t + "后到达" + GetCropID.numToNext(animalData.cId,animalData.statusNext);
               }
               hungry = animalData.hungry ? "<font color=\'#ff0000\'>饥饿</font>" : "优秀";
               str += "<br><br>" + "状态：" + hungry;
            }
            else if(this.mainData.me)
            {
               str += "<br>可以收进仓库";
            }
            TextField(this.animalInfo.info).autoSize = TextFieldAutoSize.LEFT;
            TextField(this.animalInfo.info).wordWrap = true;
            this.animalInfo.info.htmlText = str;
            this.animalInfo.info.setTextFormat(f);
            this.animalInfo.bg.width = this.animalInfo.info.width + 10;
            this.animalInfo.bg.height = this.animalInfo.info.height + 10 > 75 ? this.animalInfo.info.height + 10 : 75;
            this._icon.x = -70;
            this._icon.y = -67;
            if(_xml == null)
            {
               _xml = INI.getInstance().data;
            }
            timeStr = _xml.animals.animal.(@id == animalData.cId).nextTime.@value;
            timeList = timeStr.split(",");
            if(animalData.status == 1)
            {
               growTimeNext = int(timeList[0]);
            }
            else if(animalData.status == 2)
            {
               growTimeNext = int(timeList[1]);
            }
            else if(animalData.status == 5)
            {
               growTimeNext = int(timeList[4]);
            }
            else
            {
               growTimeNext = 0;
            }
            if(growTimeNext == 0)
            {
               this.animalInfo.growBar.width = 138;
            }
            else
            {
               this.animalInfo.growBar.width = 138 * (1 - animalData.growTimeNext / growTimeNext);
            }
            CatchError.catchError(this.onUncaughtError,null,this.loaderInfo);
         }
         catch(e:Error)
         {
         }
      }
      
      override public function set mX(param1:Number) : void
      {
         super.mX = param1;
         x = param1;
      }
      
      override public function set mY(param1:Number) : void
      {
         super.mY = param1;
         y = param1 - 30;
      }
   }
}

