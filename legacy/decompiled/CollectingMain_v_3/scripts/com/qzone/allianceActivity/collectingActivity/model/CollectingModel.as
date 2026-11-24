package com.qzone.allianceActivity.collectingActivity.model
{
   import com.qzone.allianceActivity.AllianceActivityAssetInfo;
   import com.qzone.allianceActivity.AllianceActivityInfo;
   import com.qzone.allianceActivity.framewrok.MVCFacade;
   import com.qzone.allianceActivity.framewrok.cache.DataCenter;
   import com.qzone.allianceActivity.interfaces.IAllianceAppHelper;
   import flash.utils.Dictionary;
   
   public class CollectingModel extends DataCenter
   {
      
      private var _friendsCollection:Dictionary;
      
      public var appId:String;
      
      private var _gotStatus:Boolean;
      
      private var _crop1:Array;
      
      private var _crop2:Array;
      
      public var activityConfig:AllianceActivityInfo;
      
      private var _serialConfig:XML;
      
      private var _serials:Array;
      
      private var _cropsConfig:Dictionary;
      
      public var serialMap:Dictionary;
      
      private var _myProducts:Array;
      
      private var _serialUrl:String;
      
      private var _myNormalStars:int;
      
      private var _myMysteriousStars:int;
      
      private var _friendList:Array;
      
      public function CollectingModel()
      {
         super();
         this._cropsConfig = new Dictionary();
         this._gotStatus = false;
      }
      
      public function countStar(param1:int, param2:int) : int
      {
         if(param2 == 0)
         {
            return 0;
         }
         var _loc3_:Object = this.getCropConfig(param1);
         if(_loc3_ == null || _loc3_["harvestNum"] == undefined || _loc3_["eo"] == undefined)
         {
            return 0;
         }
         var _loc4_:int = (_loc3_["harvestNum"] as int) * (_loc3_["eo"] as int);
         var _loc5_:int = Math.floor(param2 / _loc4_);
         if(_loc5_ >= 11)
         {
            return 3;
         }
         if(_loc5_ >= 7)
         {
            return 2;
         }
         if(_loc5_ >= 3)
         {
            return 1;
         }
         return 0;
      }
      
      public function harvestNumByStar(param1:int, param2:int) : int
      {
         if(param2 > 3)
         {
            param2 = 3;
         }
         var _loc3_:Object = this.getCropConfig(param1);
         if(_loc3_ == null || _loc3_["harvestNum"] == undefined || _loc3_["eo"] == undefined)
         {
            return 0;
         }
         var _loc4_:int = (_loc3_["harvestNum"] as int) * (_loc3_["eo"] as int);
         if(param2 == 3)
         {
            return 11 * _loc4_;
         }
         if(param2 == 2)
         {
            return 7 * _loc4_;
         }
         if(param2 == 1)
         {
            return 3 * _loc4_;
         }
         return 0;
      }
      
      public function get myMysteriousProducts() : Array
      {
         var _loc3_:* = undefined;
         if(this._myProducts == null)
         {
            return null;
         }
         var _loc1_:Array = this.getCropIDsBySerial(-1);
         if(_loc1_ == null)
         {
            return null;
         }
         var _loc2_:Array = new Array();
         for each(_loc3_ in this._myProducts)
         {
            if(_loc1_.indexOf(_loc3_["cId"]) != -1)
            {
               _loc2_.push(_loc3_);
            }
         }
         return _loc2_;
      }
      
      public function get friendsCollection() : Object
      {
         return this._friendsCollection;
      }
      
      public function get myCollectedSum() : uint
      {
         if(this._myProducts == null)
         {
            return 0;
         }
         return this._myProducts.length;
      }
      
      public function initialize(param1:Dictionary) : void
      {
         var _loc3_:* = undefined;
         this.serialMap = param1;
         var _loc2_:Array = null;
         for(_loc3_ in param1)
         {
            _loc2_ = param1[_loc3_] as Array;
            if(!(_loc2_ == null || _loc2_.length == 0))
            {
               _loc2_.sort(Array.NUMERIC | Array.DESCENDING);
               param1[_loc3_] = _loc2_;
            }
         }
      }
      
      public function get cropSum() : uint
      {
         var _loc3_:String = null;
         var _loc1_:uint = 0;
         var _loc2_:Array = null;
         for(_loc3_ in this.serialMap)
         {
            _loc2_ = this.serialMap[_loc3_] as Array;
            if(_loc2_ != null)
            {
               _loc1_ += _loc2_.length;
            }
         }
         return _loc1_;
      }
      
      public function get serialsConfig() : XML
      {
         if(this._serialConfig == null)
         {
            if(this.activityConfig != null && this.activityConfig.source != null)
            {
               this._serialConfig = this.activityConfig.source.crop_serieslist[0];
            }
         }
         return this._serialConfig;
      }
      
      public function addFriendProducts(param1:uint, param2:Array) : void
      {
         var _loc9_:* = undefined;
         var _loc10_:FriendData = null;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:Dictionary = new Dictionary();
         var _loc6_:Array = [];
         var _loc7_:Array = [];
         var _loc8_:int = 0;
         trace("friend uid=" + param1 + "== id ==== star === serial ==");
         for each(_loc9_ in param2)
         {
            if(_loc9_["scroungeNumber"] != undefined)
            {
               delete _loc9_["scroungeNumber"];
            }
            if(_loc9_["harvestNumber"] != 0)
            {
               _loc9_["star"] = this.countStar(_loc9_["cId"],_loc9_["harvestNumber"]);
               _loc4_ += _loc9_["star"];
               _loc3_++;
               _loc8_ = this.id2Serial(_loc9_["cId"]);
               if(_loc8_ > 0)
               {
                  if(_loc5_[_loc8_] == undefined)
                  {
                     _loc5_[_loc8_] = 1;
                  }
                  else
                  {
                     ++_loc5_[_loc8_];
                  }
                  if(_loc5_[_loc8_] == this.serialMap[_loc8_].length)
                  {
                     _loc6_.push(_loc8_);
                  }
               }
               _loc7_.push(_loc9_);
               trace(_loc9_["cId"] + " " + _loc9_["star"] + " " + _loc8_);
            }
         }
         for each(_loc10_ in this._friendList)
         {
            if(_loc10_.uId == param1)
            {
               _loc10_.collectSerials = _loc6_.length;
               _loc10_.lightedCrops = _loc3_;
               _loc10_.stars = _loc4_;
               _loc10_.products = _loc7_;
               _loc10_.updated = true;
               this.dispatchChangeEvent("friendProducts",_loc10_);
               break;
            }
         }
      }
      
      public function get gotStatus() : Boolean
      {
         return this._gotStatus;
      }
      
      public function set friendsCollection(param1:Object) : void
      {
         var _loc2_:* = undefined;
         if(param1 == null)
         {
            return;
         }
         this._friendsCollection = new Dictionary();
         for(_loc2_ in param1)
         {
            if(param1[_loc2_] != undefined)
            {
               this._friendsCollection[parseInt(_loc2_)] = param1[_loc2_];
            }
         }
         this.dispatchChangeEvent("friendsCollection",this.friendsCollection);
      }
      
      public function countEachSerials(param1:uint) : Dictionary
      {
         var _loc6_:* = undefined;
         var _loc7_:FriendData = null;
         var _loc2_:int = this.serialSum;
         if(_loc2_ == 0)
         {
            return null;
         }
         var _loc3_:Array = this._myProducts;
         if(param1 != 0)
         {
            _loc7_ = this.getFriendDataByUid(param1);
            if(_loc7_ != null && _loc7_.updated == true)
            {
               _loc3_ = _loc7_.products;
            }
         }
         var _loc4_:int = 0;
         var _loc5_:Dictionary = new Dictionary();
         for each(_loc6_ in _loc3_)
         {
            _loc4_ = this.id2Serial(_loc6_["cId"]);
            if(_loc4_ > 0)
            {
               if(_loc5_[_loc4_] == undefined)
               {
                  _loc5_[_loc4_] = 1;
               }
               else
               {
                  _loc5_[_loc4_] += 1;
               }
            }
         }
         return _loc5_;
      }
      
      public function loadFriendListFromCache() : Boolean
      {
         var _loc3_:FriendData = null;
         var _loc4_:* = undefined;
         if(this._friendList != null)
         {
            return true;
         }
         var _loc1_:IAllianceAppHelper = MVCFacade.getInstance().getObj(CollectingConsts.APPHELPER) as IAllianceAppHelper;
         var _loc2_:Array = _loc1_.execute("10010") as Array;
         if(_loc2_ != null)
         {
            this._friendList = new Array();
            _loc3_ = null;
            for each(_loc4_ in _loc2_)
            {
               _loc3_ = new FriendData();
               _loc3_.importFromCache(_loc4_);
               this._friendList.push(_loc3_);
               if(_loc3_.me == true)
               {
                  _loc3_.photo = _loc1_.execute("10007") as String;
               }
            }
            return true;
         }
         return false;
      }
      
      public function get serialSum() : int
      {
         var _loc3_:XML = null;
         var _loc1_:XML = this.serialsConfig;
         if(_loc1_ == null)
         {
            return 0;
         }
         var _loc2_:int = 0;
         for each(_loc3_ in _loc1_.crop_series)
         {
            if(_loc3_.@visible != undefined && _loc3_.@visible == 1)
            {
               _loc2_++;
            }
         }
         return _loc2_;
      }
      
      public function getFriendDataByUid(param1:uint) : FriendData
      {
         var _loc2_:FriendData = null;
         for each(_loc2_ in this._friendList)
         {
            if(_loc2_.uId == param1)
            {
               return _loc2_;
            }
         }
         return null;
      }
      
      public function getCropIDsBySerial(param1:int) : Array
      {
         if(this.serialMap == null)
         {
            return null;
         }
         var _loc2_:Array = [];
         var _loc3_:String = null;
         if(param1 == -1)
         {
            for(_loc3_ in this.serialMap)
            {
               if(_loc3_ == "other" || parseInt(_loc3_) < CollectingConsts.NORMAL_SERIAL_START)
               {
                  if(this.serialMap[_loc3_] is Array)
                  {
                     _loc2_ = _loc2_.concat(this.serialMap[_loc3_] as Array);
                  }
               }
            }
            _loc2_.sort(Array.DESCENDING | Array.NUMERIC);
            return _loc2_;
         }
         if(param1 == -3)
         {
            for(_loc3_ in this.serialMap)
            {
               if(_loc3_ == "normal" || parseInt(_loc3_) >= CollectingConsts.NORMAL_SERIAL_START)
               {
                  if(this.serialMap[_loc3_] is Array)
                  {
                     _loc2_ = _loc2_.concat(this.serialMap[_loc3_] as Array);
                  }
               }
            }
            _loc2_.sort(Array.DESCENDING | Array.NUMERIC);
            return _loc2_;
         }
         if(param1 == -2)
         {
            return this.serialMap["normal"] as Array;
         }
         if(param1 == 0)
         {
            return this.serialMap["other"] as Array;
         }
         return this.serialMap[param1] as Array;
      }
      
      public function get myCollectedSerials() : Array
      {
         var _loc3_:int = 0;
         var _loc4_:String = null;
         var _loc1_:Array = [];
         var _loc2_:Dictionary = this.countEachSerials(0);
         if(_loc2_ != null)
         {
            _loc3_ = 0;
            for(_loc4_ in _loc2_)
            {
               if(this.isVisible(_loc4_) != false)
               {
                  if(this.serialMap != null && this.serialMap[_loc4_] != undefined)
                  {
                     _loc3_ = int(this.serialMap[_loc4_].length);
                  }
                  else
                  {
                     _loc3_ = 0;
                  }
                  if(_loc2_[_loc4_] == _loc3_)
                  {
                     _loc1_.push(_loc4_);
                  }
               }
            }
         }
         return _loc1_;
      }
      
      public function get serialsData() : Dictionary
      {
         var _loc5_:XML = null;
         var _loc1_:XML = this.serialsConfig;
         if(_loc1_ == null)
         {
            return null;
         }
         var _loc2_:Dictionary = new Dictionary();
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         for each(_loc5_ in _loc1_.crop_series)
         {
            _loc4_ = parseInt(_loc5_.@id.toString());
            if(this.serialMap != null && this.serialMap[_loc4_] != undefined)
            {
               _loc3_ = int(this.serialMap[_loc4_].length);
            }
            _loc2_[_loc4_] = {
               "id":_loc4_,
               "type":parseInt(_loc5_.@type.toString()),
               "sum":_loc3_,
               "visible":parseInt(_loc5_.@visible.toString()),
               "name":_loc5_.@name.toString()
            };
         }
         return _loc2_;
      }
      
      public function id2Serial(param1:int) : int
      {
         var _loc3_:* = undefined;
         if(this.serialMap == null)
         {
            return -1;
         }
         var _loc2_:Array = null;
         for(_loc3_ in this.serialMap)
         {
            _loc2_ = this.serialMap[_loc3_] as Array;
            if(_loc2_.indexOf(param1) != -1)
            {
               if(_loc3_ == "normal")
               {
                  return -1;
               }
               if(_loc3_ == "other")
               {
                  return 0;
               }
               return _loc3_ as int;
            }
         }
         return -1;
      }
      
      public function mySerialFinished(param1:int) : Boolean
      {
         var _loc2_:Array = this.getCropIDsBySerial(param1);
         var _loc3_:Array = this.getMyProductIDsBySerial(param1);
         if(_loc2_ != null && _loc3_ != null)
         {
            return _loc2_.length == _loc3_.length ? true : false;
         }
         return false;
      }
      
      public function get friendsList() : Array
      {
         return this._friendList;
      }
      
      public function get myNormalProducts() : Array
      {
         var _loc3_:* = undefined;
         if(this._myProducts == null)
         {
            return null;
         }
         var _loc1_:Array = this.getCropIDsBySerial(-3);
         if(_loc1_ == null)
         {
            return null;
         }
         var _loc2_:Array = new Array();
         for each(_loc3_ in this._myProducts)
         {
            if(_loc1_.indexOf(_loc3_["cId"]) != -1)
            {
               _loc2_.push(_loc3_);
            }
         }
         return _loc2_;
      }
      
      public function get serialUrl() : String
      {
         var _loc1_:AllianceActivityInfo = null;
         var _loc2_:AllianceActivityAssetInfo = null;
         if(this._serialUrl == null || this._serialUrl == "")
         {
            _loc1_ = this.activityConfig;
            if(_loc1_ != null)
            {
               for each(_loc2_ in _loc1_.assets)
               {
                  if(_loc2_.id == "serials")
                  {
                     this._serialUrl = _loc2_.src;
                     break;
                  }
               }
            }
         }
         return this._serialUrl;
      }
      
      public function set myProducts(param1:Array) : void
      {
         var _loc2_:* = undefined;
         if(param1 == null)
         {
            return;
         }
         this._myNormalStars = this._myMysteriousStars = 0;
         this._myProducts = new Array();
         for each(_loc2_ in param1)
         {
            if(_loc2_["harvestNumber"] != 0)
            {
               if(_loc2_["scroungeNumber"] != undefined)
               {
                  delete _loc2_["scroungeNumber"];
               }
               _loc2_["star"] = this.countStar(_loc2_["cId"],_loc2_["harvestNumber"]);
               if(this.id2Serial(_loc2_["cId"]) == -1)
               {
                  this._myNormalStars += _loc2_["star"];
               }
               else
               {
                  this._myMysteriousStars += _loc2_["star"];
               }
               this._myProducts.push(_loc2_);
            }
         }
         this._myProducts.sortOn("cId",Array.NUMERIC | Array.DESCENDING);
         this.dispatchChangeEvent("myProducts",this._myProducts);
      }
      
      public function set friendListStatus(param1:Object) : void
      {
         var _loc5_:FriendData = null;
         if(param1 == null)
         {
            return;
         }
         var _loc2_:IAllianceAppHelper = MVCFacade.getInstance().getObj(CollectingConsts.APPHELPER) as IAllianceAppHelper;
         var _loc3_:Boolean = _loc2_.execute("10015") as Boolean;
         var _loc4_:uint = 0;
         for each(_loc5_ in this._friendList)
         {
            _loc4_ = _loc5_.uId;
            if(_loc3_ == true)
            {
               _loc4_ = _loc5_.uin;
            }
            if(param1[_loc4_] != undefined)
            {
               _loc5_.collectStatus = param1[_loc4_];
            }
            else
            {
               _loc5_.collectStatus = null;
            }
         }
         this._gotStatus = true;
         this.dispatchChangeEvent("friendListStatus",this._friendList);
      }
      
      public function getCropConfig(param1:int) : Object
      {
         if(this._cropsConfig[param1] != undefined)
         {
            return this._cropsConfig[param1];
         }
         var _loc2_:IAllianceAppHelper = MVCFacade.getInstance().getObj(CollectingConsts.APPHELPER) as IAllianceAppHelper;
         var _loc3_:Object = _loc2_.execute("10009",param1);
         if(_loc3_ != null)
         {
            this._cropsConfig[param1] = _loc3_;
         }
         return _loc3_;
      }
      
      public function loadFriendFromSvrData(param1:Array) : void
      {
         var _loc3_:String = null;
         var _loc4_:Boolean = false;
         var _loc5_:FriendData = null;
         var _loc6_:* = undefined;
         var _loc7_:Object = null;
         var _loc2_:IAllianceAppHelper = MVCFacade.getInstance().getObj(CollectingConsts.APPHELPER) as IAllianceAppHelper;
         if(param1 != null)
         {
            _loc3_ = _loc2_.execute("10003") as String;
            _loc4_ = false;
            this._friendList = new Array();
            _loc5_ = null;
            for each(_loc6_ in param1)
            {
               _loc5_ = new FriendData();
               _loc5_.importFromSvrData(_loc6_);
               this._friendList.push(_loc5_);
               if(_loc5_.uId.toString() == _loc3_ || _loc5_.userId.toString() == _loc3_)
               {
                  _loc4_ = true;
                  _loc5_.me = true;
               }
               else
               {
                  _loc5_.me = false;
               }
            }
            if(_loc4_ == false)
            {
               _loc7_ = _loc2_.execute("10014");
               if(_loc7_ != null)
               {
                  _loc5_ = new FriendData();
                  _loc5_.importFromPlayer(_loc7_);
                  _loc5_.me = true;
                  this._friendList.push(_loc5_);
               }
            }
         }
      }
      
      public function get myNormalStars() : int
      {
         return this._myNormalStars;
      }
      
      public function getMyProductIDsBySerial(param1:int) : Array
      {
         var _loc4_:* = undefined;
         var _loc2_:Array = this.getCropIDsBySerial(param1);
         if(_loc2_ == null || _loc2_.length == 0)
         {
            return null;
         }
         var _loc3_:Array = new Array();
         for each(_loc4_ in this._myProducts)
         {
            if(_loc2_.indexOf(_loc4_["cId"]) != -1)
            {
               _loc3_.push(_loc4_);
            }
         }
         return _loc3_;
      }
      
      public function isVisible(param1:String) : Boolean
      {
         var s:XMLList;
         var config:XML = null;
         var sid:String = param1;
         if(parseInt(sid) >= CollectingConsts.NORMAL_SERIAL_START)
         {
            return true;
         }
         config = this.serialsConfig;
         if(config == null)
         {
            return false;
         }
         s = config.crop_series.(@id == sid);
         if(s != null)
         {
            return s.@visible == 1;
         }
         return false;
      }
      
      public function get myMysteriousStars() : int
      {
         return this._myMysteriousStars;
      }
   }
}

