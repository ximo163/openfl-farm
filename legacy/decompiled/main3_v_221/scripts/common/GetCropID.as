package common
{
   import com.qzone.qfa.control.Application;
   import common.misc.Utils;
   import entities.StartupData;
   
   public class GetCropID
   {
      
      public static var theApp:Application;
      
      public static const SG_PUBLIC_SEED_PUBLIC_DEAD:int = 0;
      
      public static const SG_SPECIAL_SEED:int = 1;
      
      public static const SG_SPECIAL_DEAD:int = 2;
      
      public static const SG_SPECIAL_SEED_SPECIAL_DEAD:int = 3;
      
      private static var _toolList:Object = {
         "1":"Fertilizer",
         "2":"FertilizerFast",
         "3":"FertilizerVeryFast",
         "4":"FriendManure",
         "5":"HitDogStick",
         "6":"BetterSpraying",
         "7":"FertilizerVeryVeryFast",
         "8":"FertilizerMagic",
         "30":"OrganicFertilizer1",
         "31":"OrganicFertilizer2",
         "32":"OrganicFertilizer3",
         "33":"OrganicFertilizer4",
         "34":"DoubleCardItem",
         "9001":"ShopDogFood",
         "9002":"ShopDogFood7Days",
         "9101":"FertilizerFastP",
         "9102":"FertilizerVeryFastP",
         "9103":"FertilizerVeryVeryFastP",
         "9104":"OrganicFertilizer2Ex",
         "9105":"OrganicFertilizer3Ex",
         "9106":"OrganicFertilizer4Ex"
      };
      
      private static var _toolNameMap:Object = {
         "1":"化肥",
         "2":"高速化肥",
         "3":"极速化肥",
         "7":"飞速化肥",
         "30":"普通有机肥",
         "31":"高级有机肥",
         "32":"极速有机肥",
         "33":"飞速有机肥",
         "34":"翻倍卡",
         "9001":"狗粮",
         "9104":"高级有机肥(特惠)",
         "9105":"极速有机肥(特惠)",
         "9106":"飞速有机肥(特惠)"
      };
      
      private static var _weaponNameMap:Object = {
         "1":"青铜箭矢",
         "2":"银羽箭矢",
         "3":"黄金箭矢",
         "4":"水拔子",
         "5":"青铜飞刀",
         "6":"白银飞刀",
         "7":"黄金飞刀"
      };
      
      private static var _fishToolNameMap:Object = {
         "1":"普通鱼食",
         "2":"高级鱼食",
         "3":"超级鱼食"
      };
      
      public function GetCropID()
      {
         super();
      }
      
      public static function idToDiyUrl2(param1:String) : String
      {
         var _loc4_:* = undefined;
         var _loc2_:String = "";
         if(theApp.model == null || param1 == "" || param1 == null)
         {
            return _loc2_;
         }
         var _loc3_:Array = theApp.model.getData("item_info") as Array;
         if(_loc3_ == null)
         {
            return _loc2_;
         }
         for each(_loc4_ in _loc3_)
         {
            if(_loc4_["id"] == param1)
            {
               if(_loc4_["asset_id"] == undefined || _loc4_["asset_id"]["m"] == undefined)
               {
                  break;
               }
               _loc2_ = getAssetUrl(_loc4_["asset_id"]["m"]);
               return Utils.addPrefix(_loc2_);
            }
         }
         return _loc2_;
      }
      
      public static function getSeedUrl(param1:int, param2:String = null) : String
      {
         var _loc3_:String = "";
         if(theApp.model == null || param1 <= 0)
         {
            return _loc3_;
         }
         var _loc4_:* = getCropByID(param1.toString());
         if(param2 == Consts.ITEM_TYPE_CARD || param2 == Consts.ITEM_TYPE_CRYSTAL)
         {
            if(_loc4_ == null || _loc4_["asset_id"] == undefined || _loc4_["asset_id"]["m"] == undefined)
            {
               return _loc3_;
            }
            _loc3_ = getAssetUrl(_loc4_["asset_id"]["m"]);
         }
         else
         {
            if(_loc4_ == null || _loc4_["asset_id"] == undefined || _loc4_["asset_id"]["s"] == undefined)
            {
               return _loc3_;
            }
            _loc3_ = getAssetUrl(_loc4_["asset_id"]["s"]);
         }
         var _loc5_:String = Settings.getInstance().appImgPrefix;
         if(_loc3_ != "" && _loc5_ != "")
         {
            _loc3_ = Utils.addPrefix(_loc3_);
            _loc3_ += "?domain=" + _loc5_ + ".appimg";
         }
         return _loc3_;
      }
      
      public static function getCropUrl(param1:int, param2:int) : String
      {
         var _loc3_:String = null;
         var _loc6_:String = null;
         var _loc7_:String = null;
         if(theApp.model == null || param1 <= 0)
         {
            return _loc3_;
         }
         var _loc4_:* = getCropByID(param1.toString());
         if(_loc4_ == null || _loc4_["asset_id"] == undefined)
         {
            return _loc3_;
         }
         if(param2 > 2 && param2 < 6)
         {
            param2 = 3;
         }
         else if(param2 == 6)
         {
            param2 = 4;
         }
         _loc3_ = getAssetUrl(_loc4_["asset_id"]["m" + param2]);
         if(!_loc3_)
         {
            _loc6_ = Settings.getInstance().getStringAttribute("cropUrl");
            _loc7_ = Settings.getInstance().getStringAttribute("publicCropPrefix");
            _loc3_ = _loc6_ + _loc7_ + param2 + ".swf";
         }
         var _loc5_:String = Settings.getInstance().appImgPrefix;
         if(_loc3_ != "" && _loc5_ != "")
         {
            _loc3_ = Utils.addPrefix(_loc3_);
            _loc3_ += "?domain=" + _loc5_ + ".appimg";
         }
         return _loc3_;
      }
      
      public static function getHarvrstUrl(param1:int) : String
      {
         var _loc2_:String = "";
         if(theApp.model == null || param1 <= 0)
         {
            return _loc2_;
         }
         var _loc3_:* = getCropByID(param1.toString());
         if(_loc3_ == null || _loc3_["asset_id"] == undefined || _loc3_["asset_id"]["h"] == undefined)
         {
            return _loc2_;
         }
         _loc2_ = getAssetUrl(_loc3_["asset_id"]["h"]);
         var _loc4_:String = Settings.getInstance().appImgPrefix;
         if(_loc2_ != "" && _loc4_ != "")
         {
            return _loc2_ + ("?domain=" + _loc4_ + ".appimg");
         }
         return _loc2_;
      }
      
      public static function timeToMature(param1:Number, param2:int, param3:Number, param4:int) : Number
      {
         var _loc8_:Array = null;
         var _loc5_:* = getCropByID(param2.toString());
         if(_loc5_ == null)
         {
            return -1;
         }
         var _loc6_:Boolean = _loc5_["isRed"] == 2 ? true : false;
         var _loc7_:String = _loc5_["cropGrow"];
         if(_loc7_ == "")
         {
            return -1;
         }
         _loc8_ = _loc7_.split(",");
         var _loc9_:uint = _loc8_.length;
         var _loc10_:Number = Number(_loc8_[_loc9_ - 2]);
         if(param4 == 2 && _loc6_ == false)
         {
            _loc10_ = _loc10_ * 0.8 - _loc10_ % 600;
         }
         var _loc11_:Number = _loc10_ - (param1 - param3);
         if(_loc11_ < 0)
         {
            return -1;
         }
         return _loc11_;
      }
      
      public static function idToDiyUrl(param1:String, param2:Boolean) : String
      {
         var _loc5_:* = undefined;
         var _loc3_:String = "";
         if(theApp.model == null || param1 == "" || param1 == null)
         {
            return _loc3_;
         }
         var _loc4_:Array = theApp.model.getData("item_info") as Array;
         if(_loc4_ == null)
         {
            return _loc3_;
         }
         for each(_loc5_ in _loc4_)
         {
            if(_loc5_["id"] == param1)
            {
               if(_loc5_["asset_id"] == undefined)
               {
                  break;
               }
               if(param2 == true && _loc5_["asset_id"]["s"] != undefined)
               {
                  _loc3_ = getAssetUrl(_loc5_["asset_id"]["s"]);
                  return Utils.addPrefix(_loc3_);
               }
               if(param2 == false && _loc5_["asset_id"]["b"] != undefined)
               {
                  _loc3_ = getAssetUrl(_loc5_["asset_id"]["b"]);
                  return Utils.addPrefix(_loc3_);
               }
               break;
            }
         }
         return _loc3_;
      }
      
      private static function getCropByID(param1:String) : Object
      {
         var _loc3_:* = undefined;
         if(theApp.model == null)
         {
            return null;
         }
         var _loc2_:Array = theApp.model.getData("crops") as Array;
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
      
      public static function idToToolName(param1:String) : String
      {
         var _loc2_:String = "";
         if(_toolList.hasOwnProperty(param1))
         {
            _loc2_ = _toolList[param1];
         }
         return _loc2_;
      }
      
      private static function getAssetUrl(param1:String) : String
      {
         if(param1 == null || param1.length == 0)
         {
            return "";
         }
         if(theApp.model == null)
         {
            return "";
         }
         var _loc2_:Object = theApp.model.getData("assets");
         if(_loc2_ == null || _loc2_[param1] == undefined)
         {
            return "";
         }
         var _loc3_:String = _loc2_[param1]["src"] as String;
         if(_loc3_ == null || _loc3_ == "")
         {
            return "";
         }
         if(_loc3_.indexOf("") != -1)
         {
            return _loc3_;
         }
         if(_loc3_.indexOf("/diy/") != -1 || _loc3_.indexOf("/fish/") != -1)
         {
            _loc3_ = "module/ui/farm" + _loc3_;
         }
         if(_loc3_.indexOf("/Card") != -1)
         {
            _loc3_ = "module/ui/allcards" + _loc3_;
         }
         if(_loc3_.indexOf("/Crop") != -1)
         {
            _loc3_ = "module/ui/allcrops" + _loc3_;
         }
         if(_loc3_.indexOf("/Dog") != -1 || _loc3_.indexOf("/FDog") != -1)
         {
            _loc3_ = "module/ui/dogs" + _loc3_;
         }
         return _loc3_;
      }
      
      public static function fishTip(param1:String) : String
      {
         if(param1 == "0")
         {
            return "";
         }
         var _loc2_:* = getFishByID(param1);
         if(_loc2_ == null)
         {
            return "";
         }
         return _loc2_["tip"];
      }
      
      public static function getInsectPosition(param1:String, param2:int = 1) : Array
      {
         var _loc4_:String = null;
         var _loc5_:Array = null;
         var _loc6_:Array = null;
         var _loc3_:* = getCropByID(param1);
         if(_loc3_ == null)
         {
            return null;
         }
         _loc4_ = _loc3_["insect"];
         if(_loc4_ == "")
         {
            return null;
         }
         _loc5_ = _loc4_.split("|")[param2].split(",");
         return [[_loc5_[0],_loc5_[1]],[_loc5_[2],_loc5_[3]],[_loc5_[4],_loc5_[5]]];
      }
      
      public static function remainTime(param1:int, param2:Number, param3:int) : Object
      {
         var _loc7_:Array = null;
         var _loc16_:int = 0;
         var _loc17_:int = 0;
         if(param1 == 0)
         {
            return {
               "remain":0,
               "text":"",
               "progress":1
            };
         }
         var _loc4_:* = getCropByID(param1.toString());
         if(_loc4_ == null)
         {
            return null;
         }
         var _loc5_:String = _loc4_["cropGrow"];
         if(_loc5_ == "")
         {
            return null;
         }
         var _loc6_:String = _loc4_["nextText"];
         if(_loc6_ == "")
         {
            return null;
         }
         _loc7_ = _loc5_.split(",");
         var _loc8_:Array = _loc6_.split(",");
         var _loc9_:uint = _loc7_.length;
         var _loc10_:Number = Number(_loc7_[_loc9_ - 2]);
         var _loc11_:Number = Number(CommonData.serverTime);
         var _loc12_:Number = _loc11_ - param2;
         var _loc13_:Number = _loc12_ / _loc10_;
         if(_loc13_ > 1)
         {
            _loc13_ = 1;
         }
         var _loc14_:int = 0;
         var _loc15_:int = 0;
         while(_loc15_ < _loc9_)
         {
            if(param3 != 2)
            {
               _loc14_ = int(_loc7_[_loc15_]);
            }
            else if(_loc4_["isRed"] == "2")
            {
               _loc14_ = int(_loc7_[_loc15_]);
            }
            else if(_loc15_ < _loc9_ - 2)
            {
               _loc14_ = Math.floor(_loc7_[_loc15_] * 0.8) as int;
            }
            else
            {
               _loc14_ = Math.floor(_loc7_[_loc15_] * 0.8) as int;
               _loc16_ = _loc14_ % 600;
               if(_loc14_ > _loc16_)
               {
                  _loc14_ -= _loc16_;
               }
            }
            if(_loc12_ < _loc14_)
            {
               _loc17_ = _loc14_ - _loc12_;
               if(_loc15_ == _loc9_ - 1)
               {
                  _loc17_ = 0;
               }
               return {
                  "remain":_loc17_,
                  "text":_loc8_[_loc15_ + 1],
                  "progress":_loc13_
               };
            }
            _loc15_++;
         }
         return {
            "remain":0,
            "text":"",
            "progress":1
         };
      }
      
      public static function cropTip(param1:String) : String
      {
         if(param1 == "0")
         {
            return "";
         }
         var _loc2_:* = getCropByID(param1);
         if(_loc2_ == null)
         {
            return "";
         }
         return _loc2_["tip"];
      }
      
      public static function getNameByIDType(param1:String, param2:String) : String
      {
         var _loc3_:* = undefined;
         var _loc4_:* = undefined;
         if(param1 == Consts.ITEM_TYPE_DOG)
         {
            return "农场狗";
         }
         if(param1 == Consts.ITEM_TYPE_DECORATE)
         {
            return "装饰";
         }
         if(param1 == Consts.ITEM_TYPE_EXP)
         {
            return "经验";
         }
         if(param1 == Consts.ITEM_TYPE_MONEY)
         {
            return "金币";
         }
         if(param2 == null || param2 == "")
         {
            return "未知物品";
         }
         if(param2 == "9001")
         {
            return "狗粮";
         }
         if(param1 == Consts.ITEM_TYPE_SEED)
         {
            _loc3_ = getCropByID(param2);
            if(_loc3_ != null)
            {
               return _loc3_["name"];
            }
         }
         if(param1 == Consts.ITEM_TYPE_FISH)
         {
            _loc4_ = getFishByID(param2);
            if(_loc4_ != null)
            {
               return _loc4_["crop_name"];
            }
         }
         else
         {
            if(param1 == Consts.ITEM_TYPE_TOOL)
            {
               return _toolNameMap[param2];
            }
            if(param1 == Consts.ITEM_TYPE_WEAPON)
            {
               return _weaponNameMap[param2];
            }
            if(param1 == Consts.ITEM_TYPE_FISHFEED)
            {
               return _fishToolNameMap[param2];
            }
         }
         return "未知物品";
      }
      
      private static function getFishByID(param1:String) : Object
      {
         var _loc3_:* = undefined;
         if(theApp.model == null)
         {
            return null;
         }
         var _loc2_:Array = theApp.model.getData("fish_info") as Array;
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
      
      public static function specialGrow(param1:String) : int
      {
         if(param1 == "0")
         {
            return SG_PUBLIC_SEED_PUBLIC_DEAD;
         }
         var _loc2_:* = getCropByID(param1);
         if(_loc2_ == null)
         {
            return SG_PUBLIC_SEED_PUBLIC_DEAD;
         }
         if(!getAssetUrl(_loc2_["asset_id"]["m0"]) && !getAssetUrl(_loc2_["asset_id"]["m4"]))
         {
            return SG_PUBLIC_SEED_PUBLIC_DEAD;
         }
         if(Boolean(getAssetUrl(_loc2_["asset_id"]["m0"])) && !getAssetUrl(_loc2_["asset_id"]["m4"]))
         {
            return SG_SPECIAL_SEED;
         }
         if(!getAssetUrl(_loc2_["asset_id"]["m0"]) && Boolean(getAssetUrl(_loc2_["asset_id"]["m4"])))
         {
            return SG_SPECIAL_DEAD;
         }
         if(Boolean(getAssetUrl(_loc2_["asset_id"]["m0"])) && Boolean(getAssetUrl(_loc2_["asset_id"]["m4"])))
         {
            return SG_SPECIAL_SEED_SPECIAL_DEAD;
         }
         return SG_PUBLIC_SEED_PUBLIC_DEAD;
      }
      
      public static function idState(param1:int, param2:Number, param3:int, param4:int, param5:int) : int
      {
         var _loc9_:Number = NaN;
         var _loc15_:int = 0;
         var _loc16_:int = 0;
         if(param1 == 0)
         {
            return 0;
         }
         if(param3 == 7)
         {
            return 7;
         }
         var _loc6_:* = getCropByID(param1.toString());
         if(_loc6_ == null)
         {
            return 0;
         }
         var _loc7_:String = _loc6_["cropGrow"];
         if(_loc7_ == "")
         {
            return 0;
         }
         var _loc8_:Array = _loc7_.split(",");
         if(CommonData.serverTime)
         {
            _loc9_ = Number(CommonData.serverTime);
         }
         else
         {
            _loc9_ = StartupData.serverTime;
         }
         var _loc10_:Number = _loc9_;
         var _loc11_:Number = _loc10_ - param2;
         var _loc12_:int = int(_loc8_.length);
         var _loc13_:int = 0;
         var _loc14_:* = int(_loc12_ - 1);
         while(_loc14_ >= 0)
         {
            if(param4 != 2)
            {
               _loc13_ = int(_loc8_[_loc14_]);
            }
            else if(_loc6_["isRed"] == "2")
            {
               _loc13_ = int(_loc8_[_loc14_]);
            }
            else if(_loc14_ < _loc12_ - 2)
            {
               _loc13_ = Math.floor(_loc8_[_loc14_] * 0.8) as int;
            }
            else
            {
               _loc13_ = Math.floor(_loc8_[_loc14_] * 0.8) as int;
               _loc15_ = _loc13_ % 600;
               if(_loc13_ > _loc15_)
               {
                  _loc13_ -= _loc15_;
               }
            }
            if(_loc11_ >= _loc13_)
            {
               _loc16_ = _loc14_ + 1;
               if(param5 > 0)
               {
                  if(_loc16_ < 3)
                  {
                     return 3;
                  }
               }
               return _loc16_;
            }
            _loc14_--;
         }
         return 0;
      }
      
      public static function idToDogUrl(param1:String, param2:Boolean) : String
      {
         var _loc5_:* = undefined;
         var _loc3_:String = "";
         if(theApp.model == null || param1 == "" || param1 == null)
         {
            return _loc3_;
         }
         var _loc4_:Array = theApp.model.getData("dog_info") as Array;
         if(_loc4_ == null)
         {
            return _loc3_;
         }
         for each(_loc5_ in _loc4_)
         {
            if(_loc5_["id"] == param1)
            {
               if(_loc5_["asset_id"] == undefined)
               {
                  break;
               }
               if(param2 == true && _loc5_["asset_id"]["s"] != undefined)
               {
                  _loc3_ = getAssetUrl(_loc5_["asset_id"]["s"]);
                  return Utils.addPrefix(_loc3_);
               }
               if(param2 == false && _loc5_["asset_id"]["b"] != undefined)
               {
                  _loc3_ = getAssetUrl(_loc5_["asset_id"]["b"]);
                  return Utils.addPrefix(_loc3_);
               }
               break;
            }
         }
         return _loc3_;
      }
      
      public static function getFishUrl(param1:int, param2:Boolean = true) : String
      {
         var _loc3_:String = "";
         if(theApp.model == null || param1 <= 0)
         {
            return _loc3_;
         }
         var _loc4_:* = getFishByID(param1.toString());
         if(_loc4_ == null || _loc4_["asset_id"] == undefined)
         {
            return _loc3_;
         }
         _loc3_ = getAssetUrl(param2 ? _loc4_["asset_id"]["s"] : _loc4_["asset_id"]["m"]);
         var _loc5_:String = Settings.getInstance().appImgPrefix;
         if(_loc3_ != "" && _loc5_ != "")
         {
            _loc3_ = Utils.addPrefix(_loc3_);
            _loc3_ += "?domain=" + _loc5_ + ".appimg";
         }
         return _loc3_;
      }
      
      public static function cropTime(param1:String) : String
      {
         if(param1 == "0")
         {
            return "";
         }
         var _loc2_:* = getCropByID(param1);
         if(_loc2_ == null)
         {
            return "";
         }
         return _loc2_["cropGrow"];
      }
      
      public static function idToBoardUrl(param1:String) : String
      {
         var _loc4_:* = undefined;
         if(theApp.model == null)
         {
            return "";
         }
         var _loc2_:Array = theApp.model.getData("boards") as Array;
         if(_loc2_ == null)
         {
            return "";
         }
         var _loc3_:String = "";
         for each(_loc4_ in _loc2_)
         {
            if(_loc4_["id"] == param1)
            {
               if(_loc4_["asset_id"] != undefined && _loc4_["asset_id"] != "")
               {
                  _loc3_ = getAssetUrl(_loc4_["asset_id"]);
                  break;
               }
            }
         }
         if(_loc3_ != "")
         {
            _loc3_ = Utils.addPrefix(_loc3_);
         }
         return _loc3_;
      }
   }
}

