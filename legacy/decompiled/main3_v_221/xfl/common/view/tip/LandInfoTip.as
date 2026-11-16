package common.view.tip
{
   import com.qzone.corelib.net.RSLManager;
   import common.CommonData;
   import common.Consts;
   import common.GetCropID;
   import common.Language;
   import common.Session;
   import common.Settings;
   import common.misc.Utils;
   import entities.FarmLand;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.text.TextFormat;
   import flash.utils.getTimer;
   
   public class LandInfoTip extends Tip
   {
      
      private var _frequence:int;
      
      private var _land:FarmLand;
      
      private var _preTime:int;
      
      private var _farmInfo:MovieClip;
      
      private var _seedIcon:Sprite;
      
      private var _seedClassName:String;
      
      public function LandInfoTip()
      {
         super();
         super._tipName = Consts.TIP_NAME_LAND_INFOR;
         this._frequence = 5000;
         this._farmInfo = null;
         this._seedClassName = "";
         this._seedIcon = null;
         this._land = null;
         this._preTime = -1;
         this.addEventListener(Event.REMOVED_FROM_STAGE,this.onRemovedFromStage);
      }
      
      private function addFarmInfo() : void
      {
         if(this._farmInfo == null)
         {
            this._farmInfo = Utils.getMaterial("FarmInfoPlus") as MovieClip;
            addChild(this._farmInfo);
         }
         else if(contains(this._farmInfo) == false)
         {
            addChild(this._farmInfo);
         }
      }
      
      private function countHealth(param1:int, param2:int, param3:int, param4:int, param5:int, param6:int, param7:Object) : int
      {
         var _loc14_:Array = null;
         var _loc15_:int = 0;
         var _loc8_:int = 0;
         var _loc9_:Number = 0;
         var _loc10_:int = 0;
         var _loc11_:int = 0;
         var _loc12_:Array = null;
         if(param7 is Array)
         {
            param7 = {"2228612959":null};
         }
         else
         {
            param7["2228612959"] = null;
         }
         _loc12_ = this.jsonToArray(param7);
         var _loc13_:int = 0;
         while(_loc13_ < _loc12_.length)
         {
            if(_loc12_[_loc13_]["action"] == null)
            {
               _loc8_ = int(CommonData.serverTime);
            }
            else
            {
               _loc8_ = int(_loc12_[_loc13_]["time"]);
            }
            _loc9_ = (param3 + param4) * 0.2;
            if(param5 == 0)
            {
               _loc9_ += 0.6;
            }
            _loc11_ = 100 - _loc9_ * 50;
            if(_loc9_ == 0)
            {
               param1 = 100;
            }
            else
            {
               _loc10_ = (param1 - _loc11_) * 60 / _loc9_;
               if(_loc10_ + param2 < _loc8_)
               {
                  param1 = _loc11_;
               }
               else
               {
                  param1 -= (_loc8_ - param2) * _loc9_ / 60;
               }
            }
            param2 = _loc8_;
            if(_loc12_[_loc13_]["action"] != null)
            {
               _loc14_ = new Array();
               _loc14_ = _loc14_.concat(_loc12_[_loc13_]["action"]);
               _loc15_ = 0;
               while(_loc15_ < _loc14_.length)
               {
                  if(int(_loc14_[_loc15_]) == 1)
                  {
                     param4 += 1;
                     if(param4 > 3)
                     {
                        param4 = 3;
                     }
                  }
                  else if(int(_loc14_[_loc15_]) == 2)
                  {
                     param3 += 1;
                     if(param3 > 3)
                     {
                        param3 = 3;
                     }
                  }
                  else if(int(_loc14_[_loc15_]) == 3)
                  {
                     param5 = 0;
                  }
                  else if(int(_loc14_[_loc15_]) == 4)
                  {
                     param5 = 1;
                     param1 += 30;
                  }
                  else if(int(_loc14_[_loc15_]) == 5)
                  {
                     if(--param4 < 0)
                     {
                        param4 = 0;
                     }
                     param1 += 10;
                  }
                  else if(int(_loc14_[_loc15_]) == 6)
                  {
                     param3--;
                     if(param3 < 0)
                     {
                        param3 = 0;
                     }
                     param1 += 10;
                  }
                  _loc15_++;
               }
            }
            if(param1 > 100)
            {
               param1 = 100;
            }
            _loc13_++;
         }
         return param1;
      }
      
      private function onFarmTimer() : void
      {
         var _loc20_:String = null;
         var _loc21_:Object = null;
         var _loc22_:* = undefined;
         var _loc23_:Object = null;
         var _loc24_:String = null;
         var _loc25_:Object = null;
         var _loc26_:int = 0;
         var _loc27_:int = 0;
         var _loc28_:String = null;
         var _loc29_:Object = null;
         var _loc30_:String = null;
         if(this._land == null || this._land._cId == 0)
         {
            this.removeFarmInfo();
            return;
         }
         var _loc1_:int = this._land._cId;
         var _loc2_:String = "";
         if(_loc1_ > 0)
         {
            _loc2_ = GetCropID.getSeedUrl(_loc1_);
            this._seedClassName = Settings.getInstance().getSeedName(_loc1_);
         }
         if(_loc2_ == "" || this._seedClassName == "")
         {
            this.removeFarmInfo();
            return;
         }
         var _loc3_:Object = Settings.getInstance().getCropByID(_loc1_.toString());
         if(_loc3_ == null)
         {
            this.removeFarmInfo();
            return;
         }
         this.addFarmInfo();
         var _loc4_:int = this._land._step;
         if(_loc4_ == 7)
         {
            this._farmInfo.setStep7(_loc3_["name"] + " (已枯萎)");
            CommonData.rslManager.requestClass(this._seedClassName,this.onOutputIconLoaded,_loc2_);
            return;
         }
         var _loc5_:Object = GetCropID.remainTime(_loc1_,this._land._plantTime,this._land._bitmap);
         if(_loc5_ == null)
         {
            return;
         }
         var _loc6_:int = int(_loc5_["remain"]);
         var _loc7_:int = Math.floor(_loc6_ / 3600);
         var _loc8_:int = Math.ceil(_loc6_ % 3600 / 60);
         var _loc9_:int = Math.ceil(_loc6_ % 3600 % 60);
         var _loc10_:String = "";
         var _loc11_:String = "";
         if(_loc7_ > 0)
         {
            _loc11_ = Language.replaceText("hrsText",{"hrs":_loc7_});
         }
         if(--_loc8_ > 1)
         {
            if(_loc9_ == 0)
            {
               _loc8_ += 1;
            }
            _loc8_ = _loc8_ == 60 ? 59 : _loc8_;
         }
         if(_loc8_ > 0)
         {
            _loc11_ += Language.replaceText("minsText",{"mins":_loc8_});
         }
         if(_loc7_ == 0 && _loc8_ < 10)
         {
            if(_loc8_ == 0)
            {
               _loc9_ = _loc9_ == 0 ? 60 : _loc9_;
            }
            _loc11_ += _loc9_ + "秒";
         }
         if(_loc7_ == 0)
         {
            this._frequence = 1000;
         }
         else
         {
            this._frequence = 5000;
         }
         if(_loc3_["isYouji"] == 1)
         {
            this._farmInfo["stepText"]["defaultTextFormat"] = new TextFormat("Tahoma",12,26112);
         }
         else
         {
            this._farmInfo["stepText"]["defaultTextFormat"] = new TextFormat("Tahoma",12,3355443);
         }
         var _loc12_:String = String(this._land._harvestTimes + 1);
         var _loc13_:String = _loc5_["text"];
         var _loc14_:Array = _loc3_["nextText"].split(",");
         var _loc15_:String = _loc14_[_loc4_] as String;
         var _loc16_:String = _loc3_["name"] + " (第" + _loc12_ + "季)";
         var _loc17_:Session = Session.getInstance();
         var _loc18_:String = "";
         var _loc19_:Boolean = _loc6_ == 0 ? true : false;
         if(_loc19_ == true)
         {
            _loc20_ = "";
            if(_loc17_.me == false)
            {
               _loc23_ = this._land._thief;
               _loc24_ = _loc17_.hostId;
               if(_loc23_ != null && _loc23_.hasOwnProperty(_loc24_) == true)
               {
                  _loc20_ = "-已摘取";
               }
            }
            _loc21_ = {};
            _loc21_["season"] = _loc12_;
            _loc21_["units"] = this._land._output.toString();
            _loc21_["left"] = this._land._left.toString();
            _loc21_["ups"] = "";
            _loc22_ = _loc3_["isRed"];
            if(this._land._bitmap == 1 && (_loc22_ == undefined || _loc22_ == "0"))
            {
               _loc21_["ups"] = "<font color=\"#FF6600\">增产10%</font>&nbsp;";
            }
            else if(this._land._bitmap == 2 && (_loc22_ == undefined || _loc22_ == "0" || _loc22_ == "1"))
            {
               _loc21_["ups"] = "<font color=\"#FF6600\">提速20%</font>&nbsp;";
            }
            _loc18_ = Language.replaceText("ripeText",_loc21_) + _loc20_;
            if(_loc17_.healthModeValid == true || _loc17_.currentFarmHealthModeValid == true)
            {
               _loc18_ = "健康模式保护中";
            }
            else if(_loc17_.healthModeTimeOut == true)
            {
               _loc18_ = "第" + _loc12_ + "季&nbsp;可收获";
            }
            this._farmInfo.setOutput(1,_loc18_,_loc16_);
            CommonData.rslManager.requestClass(this._seedClassName,this.onOutputIconLoaded,_loc2_);
         }
         else
         {
            _loc25_ = {
               "timeText":_loc11_,
               "section":_loc13_
            };
            _loc18_ = _loc15_ + Language.replaceText("growText",_loc25_);
            _loc26_ = int(CommonData.serverTime);
            _loc27_ = this.countHealth(this._land._health,this._land._updateTime,this._land._oldweed,this._land._oldpest,this._land._oldhumidity,_loc26_,this._land._action);
            _loc28_ = "";
            if(_loc27_ <= 60)
            {
               _loc28_ = "状态(可怕)";
            }
            else if(_loc27_ > 60 && _loc27_ <= 70)
            {
               _loc28_ = "状态(糟糕)";
            }
            else if(_loc27_ > 70 && _loc27_ <= 80)
            {
               _loc28_ = "状态(欠佳)";
            }
            else if(_loc27_ > 80 && _loc27_ <= 95)
            {
               _loc28_ = "状态(良好)";
            }
            else if(_loc27_ > 95)
            {
               _loc28_ = "状态(优秀)";
            }
            _loc29_ = _loc17_.sceneDecorates[Consts.ITEM_TYPE_FAIRY];
            if(_loc29_ != null && (_loc29_["itemId"] == Consts.FAIRY_LAND || _loc29_["itemId"] == Consts.FAIRY_GOD))
            {
               _loc30_ = _loc29_["rate"].toString();
               _loc28_ += "，产量加成" + _loc30_ + "%";
            }
            this._farmInfo.setInfo(_loc27_ / 100,_loc28_,_loc5_["progress"],_loc18_,_loc16_);
            CommonData.rslManager.requestClass(this._seedClassName,this.onInfoIconLoaded,_loc2_);
         }
      }
      
      override public function set data(param1:Object) : void
      {
         super.data = param1;
         this._land = param1 as FarmLand;
         if(this._land == null)
         {
            this.removeFarmInfo();
            this.onRemovedFromStage(null);
            return;
         }
         this._seedClassName = "";
         this._seedIcon = null;
         this.onFarmTimer();
         this._preTime = getTimer();
         addEventListener(Event.ENTER_FRAME,this.onEnterFrame,false,0,true);
      }
      
      private function jsonToArray(param1:Object) : Array
      {
         var _loc3_:String = null;
         var _loc4_:Object = null;
         var _loc2_:Array = [];
         for(_loc3_ in param1)
         {
            _loc4_ = new Object();
            _loc4_["time"] = _loc3_;
            _loc4_["action"] = param1[_loc3_];
            _loc2_.push(_loc4_);
         }
         _loc2_.sort(this.sortArray);
         return _loc2_;
      }
      
      override public function set mY(param1:Number) : void
      {
         super.mY = param1;
         y = param1 - 120;
      }
      
      override public function set mX(param1:Number) : void
      {
         super.mX = param1;
         x = param1 - 60;
      }
      
      private function removeFarmInfo() : void
      {
         if(this._farmInfo == null)
         {
            return;
         }
         if(contains(this._farmInfo) == true)
         {
            removeChild(this._farmInfo);
         }
         removeEventListener(Event.ENTER_FRAME,this.onEnterFrame);
         this._preTime = -1;
      }
      
      private function sortArray(param1:Object, param2:Object) : int
      {
         if(Number(param1["time"]) > Number(param2["time"]))
         {
            return 1;
         }
         return -1;
      }
      
      private function onInfoIconLoaded() : void
      {
         this._seedIcon = RSLManager.getMaterial(this._seedClassName) as Sprite;
         if(this._seedIcon)
         {
            this._seedIcon.scaleX = 0.6;
            this._seedIcon.scaleY = 0.6;
            this._farmInfo.setInfoIcon(this._seedIcon);
         }
      }
      
      private function onRemovedFromStage(param1:Event) : void
      {
         removeEventListener(Event.ENTER_FRAME,this.onEnterFrame);
         this._preTime = -1;
      }
      
      private function onEnterFrame(param1:Event) : void
      {
         if(this._preTime < 0)
         {
            return;
         }
         var _loc2_:int = getTimer();
         if(_loc2_ - this._preTime > this._frequence)
         {
            this._preTime = _loc2_;
            this.onFarmTimer();
         }
      }
      
      private function onOutputIconLoaded() : void
      {
         this._seedIcon = RSLManager.getMaterial(this._seedClassName) as Sprite;
         if(this._seedIcon)
         {
            this._seedIcon.scaleX = 0.6;
            this._seedIcon.scaleY = 0.6;
            this._farmInfo.setOutputIcon(this._seedIcon);
         }
      }
   }
}

