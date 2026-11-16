package mc.view.farm.Research
{
   import common.CommonData;
   import common.INI;
   import common.LocalData;
   import flash.events.EventDispatcher;
   import flash.events.IEventDispatcher;
   import flash.external.ExternalInterface;
   import mc.FBridge.EventRecorder;
   import mc.FBridge.FRequest;
   import mc.model.MData;
   
   public class ResearchModel extends EventDispatcher
   {
      
      private static var intence:ResearchModel;
      
      private var _denshed:Object;
      
      public const zuyong:Object = {
         "qd":69,
         "day":7
      };
      
      private var _updataPlevel:int;
      
      public var denshedType:Object = {
         "isIn":false,
         "useGold":true
      };
      
      public var zuyongNum:int;
      
      public const doubleAnimal:Array = ["5%","6%","7%","8%","10%"];
      
      private var _controller:ResearchController;
      
      private const speakingStr:Array = ["科研就这么停滞了吗？","科学道路永无止尽啊！回来研究吧~","一天不科研就手痒痒，点我来科研！"];
      
      private var _tempupdate:Object;
      
      public var needQb:Number = 0;
      
      private var _animaldate:Array;
      
      public const contentNum:int = 5;
      
      public const tinPro:Array = [{
         "d":"将科研时间缩短1小时,可连续使用。",
         "e":3600,
         "id":40,
         "l":100,
         "n":"迷你沙漏",
         "o":1,
         "qd":5,
         "t":12,
         "y":4,
         "p":0
      },{
         "d":"将科研时间缩短3小时,可连续使用。",
         "e":10800,
         "id":41,
         "l":100,
         "n":"普通沙漏",
         "o":2,
         "qd":12,
         "t":12,
         "y":9,
         "p":0
      },{
         "d":"将科研时间缩短8小时,可连续使用。",
         "e":28800,
         "id":42,
         "l":100,
         "n":"高速沙漏",
         "o":3,
         "qd":23,
         "t":12,
         "y":18,
         "p":0
      },{
         "d":"将科研时间缩短12小时,可连续使用。",
         "e":43200,
         "id":43,
         "l":100,
         "n":"极速沙漏",
         "o":4,
         "qd":36,
         "t":12,
         "y":28,
         "p":0
      }];
      
      public const upMoneyNum:Array = [0,8,7,6,5];
      
      public const openAnimalLev:Array = [38,46,54,57,64];
      
      private var _updataWlevel:int;
      
      private var _houseStatus:Object = {
         "den":"",
         "shed":""
      };
      
      public var researchType:int = 0;
      
      private var _getEnter:Boolean = false;
      
      private var _myhg:Array = new Array();
      
      private var _updataW2:Array;
      
      private var _isden:Boolean;
      
      public const openResearchSize:Array = [1,2,3,4,5];
      
      public var needLev:Number = 0;
      
      public var bgLv:Object;
      
      private var _updataP2:Array;
      
      public var needMoney:Number = 0;
      
      private var fr:FRequest = FRequest.getInstance();
      
      public const userConditionp:Array = [{
         "l":"32",
         "g":"85w",
         "q":"50",
         "yq":"40"
      },{
         "l":"36",
         "g":"95w",
         "q":"200",
         "yq":"160"
      },{
         "l":"40",
         "g":"120w",
         "q":"300",
         "yq":"240"
      },{
         "l":"46",
         "g":"140w",
         "q":"400",
         "yq":"320"
      },{
         "l":"52",
         "g":"160w",
         "q":"500",
         "yq":"400"
      }];
      
      public const userConditionw:Array = [{
         "l":"30",
         "g":"80w",
         "q":"50",
         "yq":"40"
      },{
         "l":"34",
         "g":"90w",
         "q":"200",
         "yq":"160"
      },{
         "l":"38",
         "g":"110w",
         "q":"300",
         "yq":"240"
      },{
         "l":"43",
         "g":"130w",
         "q":"400",
         "yq":"320"
      },{
         "l":"49",
         "g":"150w",
         "q":"500",
         "yq":"400"
      }];
      
      private var _updataP:Object;
      
      private var _updataW:Object;
      
      public const upMoney:Array = ["无","8折","7折","6折","5折"];
      
      public var researchIndex:int = 0;
      
      public function ResearchModel(param1:IEventDispatcher = null)
      {
         super(param1);
         this._controller = new ResearchController();
      }
      
      public static function gi() : ResearchModel
      {
         if(intence == null)
         {
            intence = new ResearchModel();
         }
         return intence;
      }
      
      public function set isDen(param1:Boolean) : void
      {
         this._isden = param1;
      }
      
      public function get UpdataP() : Object
      {
         return this._updataP;
      }
      
      public function set UpdataP2(param1:Array) : void
      {
         this._updataP2 = param1;
         dispatchEvent(new ResearchEvent(ResearchEvent.UPDATA_SHED));
      }
      
      public function get UpdataW() : Object
      {
         return this._updataW;
      }
      
      public function isDenUpdateToTop() : Boolean
      {
         if(this.DenShedLevel["den"] == 13)
         {
            return true;
         }
         return false;
      }
      
      public function set UpdataP(param1:Object) : void
      {
         this._updataP = param1;
         dispatchEvent(new ResearchEvent(ResearchEvent.UPDATA_SHED));
      }
      
      public function get HouseStatus() : Object
      {
         return this._houseStatus;
      }
      
      public function isDenCanShouhuo() : Boolean
      {
         var _loc1_:int = 0;
         var _loc2_:int = int(this._updataW2.length);
         while(_loc1_ < _loc2_)
         {
            if(this.canGetDenAnimal(_loc1_))
            {
               return true;
            }
            _loc1_++;
         }
         return false;
      }
      
      public function endTimeDate(param1:Number, param2:String = "all") : String
      {
         var _loc3_:int = 0;
         var _loc6_:String = null;
         var _loc7_:int = 0;
         var _loc8_:String = null;
         var _loc9_:String = null;
         _loc3_ = Math.floor(param1 / 60 / 60);
         var _loc4_:int = Math.floor(param1 / 60) - _loc3_ * 60;
         var _loc5_:int = param1 - _loc3_ * 60 * 60 - _loc4_ * 60;
         switch(param2)
         {
            case "hour":
               _loc6_ = _loc3_ + "小时";
               break;
            case "min":
               _loc7_ = Math.ceil(Math.ceil(param1 / 60) - _loc3_ * 60);
               if(_loc7_ == 60)
               {
                  _loc7_ = 0;
                  _loc3_ += 1;
               }
               if(_loc7_ < 10)
               {
                  _loc6_ = _loc3_ + "小时0" + _loc7_ + "分";
               }
               else
               {
                  _loc6_ = _loc3_ + "小时" + _loc7_ + "分";
               }
               break;
            default:
               if(_loc4_ < 10)
               {
                  _loc8_ = "0" + _loc4_;
               }
               else
               {
                  _loc8_ = _loc4_.toString();
               }
               if(_loc5_ < 10)
               {
                  _loc9_ = "0" + _loc5_;
               }
               else
               {
                  _loc9_ = _loc5_.toString();
               }
               _loc6_ = _loc3_ + ":" + _loc8_ + ":" + _loc9_;
         }
         return _loc6_;
      }
      
      public function get getEnter() : Boolean
      {
         return this._getEnter;
      }
      
      public function set UpdataWLevel(param1:int) : void
      {
         this._updataWlevel = param1;
      }
      
      public function getAniamlDate() : void
      {
         var _loc1_:FRequest = null;
         var _loc2_:ResearchEvent = null;
         if(this._animaldate == null)
         {
            _loc1_ = FRequest.getInstance();
            _loc1_.postRequest2("cgi_get_animals",{"op":1},this.getAnimalHandler);
         }
         else
         {
            _loc2_ = new ResearchEvent(ResearchEvent.DENSHED_RESEARCH_ANIMAL);
            _loc2_.data = {"animals":this._animaldate};
            dispatchEvent(_loc2_);
         }
      }
      
      public function set UpdataW(param1:Object) : void
      {
         this._updataW = param1;
         dispatchEvent(new ResearchEvent(ResearchEvent.UPDATA_DEN));
      }
      
      public function useHourGlass(param1:Object, param2:Function) : void
      {
         this.fr.postRequest2("cgi_pasture_hourglass",param1,param2);
      }
      
      public function get UpdataPLevel() : int
      {
         return this._updataPlevel;
      }
      
      public function set HouseStatus(param1:Object) : void
      {
         this._houseStatus = param1;
      }
      
      public function getHourGlass(param1:Function) : void
      {
         if(MData.getInstance().farmData.reloadUserSeed)
         {
            this.fr.postRequest2("cgi_get_package",null,param1);
         }
         else
         {
            param1(MData.getInstance().farmData.userSeed);
         }
      }
      
      public function set getEnter(param1:Boolean) : void
      {
         this._getEnter = param1;
      }
      
      public function shouComplete(param1:Array) : void
      {
         var _loc2_:ResearchEvent = new ResearchEvent(ResearchEvent.DENSHED_RESEARCH_SHOUCOMPLETE);
         _loc2_.data = {"animals":param1};
         dispatchEvent(_loc2_);
      }
      
      private function strategyHandler(param1:Object) : void
      {
         if(param1["bit_flag"])
         {
            this._controller.openFirstWindow();
            EventRecorder.recordSueecssEvent("160955",0);
         }
         else
         {
            EventRecorder.recordErrorEvent("160955",0,14);
         }
      }
      
      public function get UpdataW2() : Array
      {
         return this._updataW2;
      }
      
      public function openFirstBox() : void
      {
         var _loc1_:Object = MData.getInstance().mainData.host;
         var _loc2_:int = MData.getInstance().mainData.expToGrade(_loc1_["exp"]);
         if(_loc2_ >= int(INI.getInstance().data.levels))
         {
            if(MData.getInstance().mainData.expToGrade(_loc1_["exp"]) >= 24 && (MData.getInstance().mainData.host["house1"] <= 8 && MData.getInstance().mainData.host["house2"] <= 8))
            {
               this.fr.postRequest2("cgi_fetch_strategy_rules",{"bitpos":12},this.strategyHandler);
            }
         }
      }
      
      public function shareHandler(param1:String, param2:String, param3:String, param4:String, param5:String) : void
      {
         var _loc6_:String = "cgi_qzshare_onekey";
         _loc6_ = _loc6_ + ("url=" + encodeURIComponent(param1));
         _loc6_ = _loc6_ + ("&desc=" + encodeURIComponent(""));
         _loc6_ = _loc6_ + ("&summary=" + encodeURIComponent(param2));
         _loc6_ = _loc6_ + ("&title=" + encodeURIComponent(param3));
         _loc6_ = _loc6_ + ("&site=" + encodeURIComponent(param4));
         _loc6_ = _loc6_ + ("&pics=" + encodeURIComponent(param5));
         ExternalInterface.call("window.open",_loc6_);
      }
      
      public function pastureResearchOK(param1:int, param2:int, param3:int, param4:int, param5:int, param6:Function) : void
      {
         this.fr.postRequest2("cgi_pasture_research",{
            "action":param1,
            "aid":param2,
            "target":this.researchType,
            "index":param3,
            "denlv":param4,
            "shedlv":param5
         },param6);
      }
      
      public function set UpdataPLevel(param1:int) : void
      {
         this._updataPlevel = param1;
      }
      
      public function set getResearchAnimalDate(param1:Array) : void
      {
         this._animaldate = param1;
      }
      
      public function set tempUpdate(param1:Object) : void
      {
         this._tempupdate = param1;
      }
      
      public function get isDen() : Boolean
      {
         return this._isden;
      }
      
      public function set DenShedLevel(param1:Object) : void
      {
         this._denshed = param1;
      }
      
      public function get UpdataP2() : Array
      {
         return this._updataP2;
      }
      
      public function get UpdataWLevel() : int
      {
         return this._updataWlevel;
      }
      
      public function getAnimalNeedTime(param1:Number) : int
      {
         return int(param1 / 60 / 60);
      }
      
      public function set MyHG(param1:Array) : void
      {
         this._myhg = param1;
         dispatchEvent(new ResearchEvent(ResearchEvent.UPDATA_HOUR_GLASS_NUM));
      }
      
      public function canGetDenAnimal(param1:int) : Boolean
      {
         if(this._updataW2[param1]["endtime"] != 0)
         {
            if(CommonData.serverTime >= this._updataW2[param1]["endtime"])
            {
               return true;
            }
         }
         return false;
      }
      
      public function isShedUpdateToTop() : Boolean
      {
         if(this.DenShedLevel["shed"] == 13)
         {
            return true;
         }
         return false;
      }
      
      public function get getResearchAnimalDate() : Array
      {
         return this._animaldate;
      }
      
      public function get tempUpdate() : Object
      {
         return this._tempupdate;
      }
      
      public function set UpdataW2(param1:Array) : void
      {
         this._updataW2 = param1;
         dispatchEvent(new ResearchEvent(ResearchEvent.UPDATA_DEN));
      }
      
      public function get DenShedLevel() : Object
      {
         return this._denshed;
      }
      
      public function get MyHG() : Array
      {
         return this._myhg;
      }
      
      public function pastureResearch(param1:int, param2:int, param3:int, param4:Function) : void
      {
         this.fr.postRequest2("cgi_pasture_research",{
            "action":param1,
            "aid":param2,
            "target":this.researchType,
            "index":param3
         },param4);
      }
      
      public function isShedCanShouhuo() : Boolean
      {
         var _loc1_:int = 0;
         var _loc2_:int = int(this._updataP2.length);
         while(_loc1_ < _loc2_)
         {
            if(this.canGetShedAnimal(_loc1_))
            {
               return true;
            }
            _loc1_++;
         }
         return false;
      }
      
      public function canGetShedAnimal(param1:int) : Boolean
      {
         if(this._updataP2[param1]["endtime"] != 0)
         {
            if(CommonData.serverTime >= this._updataP2[param1]["endtime"])
            {
               return true;
            }
         }
         return false;
      }
      
      public function setHGNum(param1:int, param2:int) : void
      {
         var _loc3_:int = 0;
         while(_loc3_ < this._myhg.length)
         {
            if(this._myhg[_loc3_]["tId"] == param1)
            {
               this._myhg[_loc3_]["amount"] += param2;
               if(this._myhg[_loc3_]["amount"] == 0)
               {
                  dispatchEvent(new ResearchEvent(ResearchEvent.UPDATA_HOUR_GLASS_NUM_0));
               }
               break;
            }
            _loc3_++;
         }
         dispatchEvent(new ResearchEvent(ResearchEvent.UPDATA_HOUR_GLASS_NUM));
      }
      
      public function isOpenFirstUpdateTip() : Boolean
      {
         if(this.DenShedLevel["den"] == 9 && LocalData.reclaimType == 3 || this.DenShedLevel["shed"] == 9 && LocalData.reclaimType == 4)
         {
            return true;
         }
         return false;
      }
      
      private function getAnimalHandler(param1:Object) : void
      {
         if(param1.hasOwnProperty("errorType"))
         {
            EventRecorder.recordErrorEvent("160954",0,14);
         }
         EventRecorder.recordSueecssEvent("160954",0);
         var _loc2_:Array = new Array();
         this._animaldate = _loc2_.concat(param1);
         var _loc3_:ResearchEvent = new ResearchEvent(ResearchEvent.DENSHED_RESEARCH_ANIMAL);
         _loc3_.data = {"animals":this._animaldate};
         dispatchEvent(_loc3_);
      }
      
      public function get speakingWord() : String
      {
         var _loc1_:int = Math.floor(Math.random() * 3);
         return this.speakingStr[_loc1_];
      }
   }
}

