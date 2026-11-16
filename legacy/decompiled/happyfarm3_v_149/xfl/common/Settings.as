package common
{
   import com.qzone.qfa.interfaces.IModel;
   import common.misc.QzoneJSAPI;
   import common.misc.Utils;
   import flash.display.LoaderInfo;
   import flash.utils.Dictionary;
   import flash.utils.getTimer;
   
   public class Settings
   {
      
      private static var _instance:Settings;
      
      public static const TIP_VALUE:String = "value";
      
      public static const TIP_URL:String = "url";
      
      private var m_initTime:int;
      
      private var m_params:Object;
      
      private var m_appImgPrefix:String;
      
      private var m_configDataModel:IModel;
      
      private var m_resolveUrl:String;
      
      private var m_mcCommUrl:String;
      
      private var m_ncCommUrl:String;
      
      public function Settings()
      {
         super();
         this.m_initTime = getTimer();
         this.m_params = null;
         this.m_appImgPrefix = "";
         this.m_resolveUrl = "";
      }
      
      public static function get isQZoneUinMode() : Boolean
      {
         if(_instance == null)
         {
            return false;
         }
         if(QzoneJSAPI.WB == true)
         {
            return false;
         }
         var _loc1_:String = _instance.getStringAttribute("uinMode");
         var _loc2_:String = _instance.mode;
         if(_loc1_ == "1" && _loc2_ == "qzone")
         {
            return true;
         }
         return false;
      }
      
      public static function getInstance() : Settings
      {
         if(_instance != null)
         {
            return _instance;
         }
         _instance = new Settings();
         return _instance;
      }
      
      public function getWildCfg() : XML
      {
         if(this.m_configDataModel == null)
         {
            return null;
         }
         return this.m_configDataModel.getData("wild") as XML;
      }
      
      public function getSeedName(param1:int) : String
      {
         return "Crop_" + param1 + "_Seed";
      }
      
      public function get appImgPrefix() : String
      {
         return this.m_appImgPrefix;
      }
      
      public function getFishByID(param1:String) : Object
      {
         var _loc3_:* = undefined;
         if(this.m_configDataModel == null)
         {
            return null;
         }
         var _loc2_:Array = this.m_configDataModel.getData("fish_info") as Array;
         if(_loc2_ == null)
         {
            return null;
         }
         for each(_loc3_ in _loc2_)
         {
            if(_loc3_["id"] == param1)
            {
               return _loc3_;
            }
         }
         return null;
      }
      
      public function get mode() : String
      {
         if(this.getStringAttribute("agent") == "qplus")
         {
            return "qzone";
         }
         if(this.getStringAttribute("agent") == "weibo")
         {
            return "qzone";
         }
         var _loc1_:String = this.getStringAttribute("mode");
         if(_loc1_ == "1")
         {
            _loc1_ = "qzone";
         }
         else
         {
            _loc1_ = "";
         }
         return _loc1_;
      }
      
      public function get xymode() : String
      {
         var _loc1_:String = this.getStringAttribute("pageDomain");
         if(_loc1_ == "")
         {
            _loc1_ = "";
         }
         else
         {
            _loc1_ = "";
         }
         return _loc1_;
      }
      
      public function getSecondUrl(param1:String) : String
      {
         var _loc3_:* = undefined;
         if(this.m_configDataModel == null)
         {
            return "";
         }
         var _loc2_:Array = this.m_configDataModel.getData("secondList") as Array;
         if(_loc2_ == null || _loc2_.length == 0)
         {
            return "";
         }
         for each(_loc3_ in _loc2_)
         {
            if(_loc3_["id"] == param1)
            {
               return this.replaceAppImg(_loc3_["src"]);
            }
         }
         return "";
      }
      
      public function getCardsGameRewardIDs() : Array
      {
         var _loc3_:Object = null;
         var _loc1_:Array = new Array();
         if(this.m_configDataModel == null)
         {
            return _loc1_;
         }
         var _loc2_:Object = this.m_configDataModel.getData("cardsGameRewards") as Object;
         if(_loc2_ == null)
         {
            return _loc1_;
         }
         for each(_loc3_ in _loc2_)
         {
            _loc1_.push(parseInt(_loc3_["bid"]));
         }
         return _loc1_.concat();
      }
      
      public function getCropName(param1:int) : String
      {
         return "Crop_" + param1;
      }
      
      public function getFreeGift(param1:String) : Object
      {
         if(this.m_configDataModel == null)
         {
            return "";
         }
         var _loc2_:Object = this.m_configDataModel.getData("freegifts") as Object;
         if(_loc2_ == null)
         {
            return "";
         }
         return _loc2_[param1] as Object;
      }
      
      public function replaceAppImg(param1:String) : String
      {
         if(this.appImgPrefix != "" && param1 != "")
         {
            if(param1.indexOf("" + this.appImgPrefix + ".") == 0 || param1.indexOf(this.appImgPrefix + ".") == 0)
            {
               return param1;
            }
            param1 = param1.replace("appimg.",this.appImgPrefix + ".appimg.");
            param1 = param1.replace("appimg1.",this.appImgPrefix + ".appimg1.");
            param1 = param1.replace("appimg3.",this.appImgPrefix + ".appimg3.");
         }
         return param1;
      }
      
      public function getDIYByID(param1:String) : Object
      {
         var _loc3_:* = undefined;
         if(this.m_configDataModel == null)
         {
            return null;
         }
         var _loc2_:Array = this.m_configDataModel.getData("item_info") as Array;
         if(_loc2_ == null)
         {
            return null;
         }
         for each(_loc3_ in _loc2_)
         {
            if(_loc3_["id"] == param1)
            {
               return _loc3_;
            }
         }
         return null;
      }
      
      public function getCardName(param1:int) : String
      {
         return "Card_" + param1;
      }
      
      public function getCrystalName(param1:String, param2:int) : String
      {
         return "Nc_Drop_" + param1 + "_" + param2;
      }
      
      public function setConfigDataModel(param1:IModel) : void
      {
         this.m_configDataModel = param1;
      }
      
      public function getWeaponName(param1:String, param2:int) : String
      {
         return "Weapon_Icon_" + param1 + "_" + param2;
      }
      
      public function get app_key() : String
      {
         var _loc1_:String = this.getStringAttribute("app_key");
         if(_loc1_ == "")
         {
            _loc1_ = "happyfarm";
         }
         return _loc1_;
      }
      
      public function getBillBoardData() : Array
      {
         if(this.m_configDataModel == null)
         {
            return null;
         }
         return this.m_configDataModel.getData("boards") as Array;
      }
      
      public function get dataConfigUrl() : String
      {
         return this.replaceAppImg(this.getStringAttribute("config_data"));
      }
      
      public function get domain() : String
      {
         if(this.mode == "qzone")
         {
            return this.getStringAttribute("domian_qz");
         }
         if(this.mode == "qplus")
         {
            return this.getStringAttribute("domian_qz");
         }
         return this.getStringAttribute("domian_xy");
      }
      
      public function getFreeGiftID() : Array
      {
         var _loc3_:Object = null;
         var _loc1_:Array = new Array();
         if(this.m_configDataModel == null)
         {
            return _loc1_;
         }
         var _loc2_:Object = this.m_configDataModel.getData("freegifts") as Object;
         if(_loc2_ == null)
         {
            return _loc1_;
         }
         for each(_loc3_ in _loc2_)
         {
            _loc1_.push(parseInt(_loc3_["bid"]));
         }
         return _loc1_.concat();
      }
      
      public function getCardsGameReward(param1:String) : Object
      {
         if(this.m_configDataModel == null)
         {
            return "";
         }
         var _loc2_:Object = this.m_configDataModel.getData("cardsGameRewards") as Object;
         if(_loc2_ == null)
         {
            return "";
         }
         return _loc2_[param1] as Object;
      }
      
      public function getDynamicTip(param1:String, param2:String = "value") : String
      {
         if(this.m_configDataModel == null)
         {
            return "";
         }
         var _loc3_:Object = this.m_configDataModel.getData("dynamicTips") as Object;
         if(_loc3_ == null)
         {
            return "";
         }
         if(_loc3_.hasOwnProperty(param1))
         {
            return _loc3_[param1][param2] as String;
         }
         return "";
      }
      
      public function get allCfgData() : Object
      {
         return this.m_params;
      }
      
      public function getStringAttribute(param1:String) : String
      {
         if(param1 == null || param1.length == 0)
         {
            return "";
         }
         if(this.m_params != null && this.m_params[param1] != undefined)
         {
            if(this.m_params[param1] is String)
            {
               return this.m_params[param1];
            }
         }
         return "";
      }
      
      public function getCropByID(param1:String) : Object
      {
         var _loc3_:* = undefined;
         if(this.m_configDataModel == null)
         {
            return null;
         }
         var _loc2_:Array = this.m_configDataModel.getData("crops") as Array;
         if(_loc2_ == null)
         {
            return null;
         }
         for each(_loc3_ in _loc2_)
         {
            if(_loc3_["id"] == param1)
            {
               return _loc3_;
            }
         }
         return null;
      }
      
      public function get mcCommUrl() : String
      {
         return this.m_mcCommUrl;
      }
      
      public function get ncCommUrl() : String
      {
         return this.m_ncCommUrl;
      }
      
      public function getUrlConfigByName(param1:String) : String
      {
         var _loc3_:* = undefined;
         var _loc2_:String = "";
         if(param1 == "")
         {
            return _loc2_;
         }
         if(this.m_configDataModel != null)
         {
            _loc3_ = this.m_configDataModel.getData("environment");
            if(_loc3_ != null && _loc3_[param1] != undefined && _loc3_[param1]["url"] != undefined)
            {
               _loc2_ = _loc3_[param1]["url"];
            }
         }
         return _loc2_;
      }
      
      public function getMonthEnds(param1:String, param2:String) : String
      {
         if(this.m_configDataModel == null)
         {
            return "";
         }
         var _loc3_:Object = this.m_configDataModel.getData("monthEnds") as Object;
         if(_loc3_ == null || _loc3_.length == 0)
         {
            return "";
         }
         if(_loc3_[param1] == null)
         {
            return "";
         }
         return _loc3_[param1][param2];
      }
      
      public function get resolveUrl() : String
      {
         return this.m_resolveUrl;
      }
      
      public function get wildCfgUrl() : String
      {
         return Utils.addPrefix(this.getStringAttribute("wildXML"));
      }
      
      public function openZhaoHui() : Boolean
      {
         return this.getStringAttribute("zhaohuiOpen") == "1" ? true : false;
      }
      
      public function isGiftTime() : Boolean
      {
         if(this.m_configDataModel == null)
         {
            return false;
         }
         var _loc1_:Object = this.m_configDataModel.getData("monthEnds") as Object;
         if(_loc1_ == null || _loc1_.length == 0 || _loc1_["0"] == undefined)
         {
            return false;
         }
         var _loc2_:String = _loc1_["0"]["start"];
         var _loc3_:String = _loc1_["0"]["end"];
         var _loc4_:Number = new Date(_loc2_).time;
         var _loc5_:Number = new Date(_loc3_).time;
         var _loc6_:Number = CommonData.serverTime * 1000;
         if(_loc4_ < _loc6_ && _loc6_ < _loc5_)
         {
            return true;
         }
         return false;
      }
      
      public function loadLocalSettings(param1:*) : void
      {
         this.m_params = param1;
         this.m_resolveUrl = "";
         this.m_appImgPrefix = "";
      }
      
      public function loadFromFlashVars(param1:LoaderInfo) : void
      {
         var _loc2_:Object = param1.parameters;
         if(_loc2_ == null)
         {
            throw new ArgumentError("Null parameters");
         }
         this.m_params = _loc2_;
         this.m_resolveUrl = this.getStringAttribute("resolveUrl");
         if(this.m_resolveUrl == "")
         {
            this.m_resolveUrl = "";
         }
         var _loc3_:String = param1.url;
         var _loc4_:Array = _loc3_.match("//(.+).appimg");
         if(_loc4_)
         {
            this.m_appImgPrefix = _loc4_[1] || "";
         }
         var _loc5_:String = "";
         if(this.mode == "qzone")
         {
            _loc5_ = "qzone.qq";
         }
         else if(this.mode == "")
         {
            _loc5_ = "";
         }
         this.m_mcCommUrl = "" + _loc5_ + "mod=";
         this.m_ncCommUrl = "" + _loc5_ + "mod=";
         QzoneJSAPI.QPLUS = param1.parameters["agent"] == "qplus";
         QzoneJSAPI.WB = param1.parameters["agent"] == "weibo";
         if(QzoneJSAPI.WB == true)
         {
            this.m_mcCommUrl = "";
            this.m_ncCommUrl = "";
         }
      }
      
      public function get addonConfigUrl() : String
      {
         return this.replaceAppImg(this.getStringAttribute("config_addon"));
      }
      
      public function collectCropBySerials() : Dictionary
      {
         var _loc4_:* = undefined;
         if(this.m_configDataModel == null)
         {
            return null;
         }
         var _loc1_:Array = this.m_configDataModel.getData("crops") as Array;
         if(_loc1_ == null)
         {
            return null;
         }
         var _loc2_:Dictionary = new Dictionary();
         _loc2_["other"] = new Array();
         _loc2_["normal"] = new Array();
         var _loc3_:int = 0;
         for each(_loc4_ in _loc1_)
         {
            if(_loc4_["type"] != 11)
            {
               if(_loc4_["qd"] == undefined || _loc4_["qd"] == 0)
               {
                  if(_loc4_["sr"] == undefined || _loc4_["sr"] == 0)
                  {
                     _loc2_["normal"].push(_loc4_["id"]);
                  }
                  else
                  {
                     _loc3_ = _loc4_["sr"] as int;
                     if(_loc2_[_loc3_] == undefined)
                     {
                        _loc2_[_loc3_] = new Array();
                     }
                     _loc2_[_loc3_].push(_loc4_["id"]);
                  }
               }
               else if(_loc4_["sr"] == undefined || _loc4_["sr"] == 0)
               {
                  _loc2_["other"].push(_loc4_["id"]);
               }
               else
               {
                  _loc3_ = _loc4_["sr"] as int;
                  if(_loc2_[_loc3_] == undefined)
                  {
                     _loc2_[_loc3_] = new Array();
                  }
                  _loc2_[_loc3_].push(_loc4_["id"]);
               }
            }
         }
         return _loc2_;
      }
      
      public function loadFromAddon(param1:XML) : void
      {
         var _loc3_:XML = null;
         if(param1 == null || param1..vars == undefined)
         {
            return;
         }
         if(this.m_params == null)
         {
            this.m_params = {};
         }
         var _loc2_:XMLList = param1..vars.children();
         for each(_loc3_ in _loc2_)
         {
            if(_loc3_.text() != undefined)
            {
               this.m_params[_loc3_.name()] = _loc3_.text().toString();
            }
         }
      }
      
      public function get snsAdAllowLvl() : int
      {
         return int(parseInt(this.getStringAttribute("snsAdAllowLvl")));
      }
      
      public function getFishName(param1:int) : String
      {
         return "Fish_" + param1;
      }
   }
}

