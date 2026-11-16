package module.lite
{
   import com.adobe.serialization.json.JSON;
   import com.qzone.qfa.commands.CmdHttpRequest;
   import com.qzone.qfa.data.Resource;
   import com.qzone.qfa.events.QFAEvent;
   import com.qzone.qfa.managers.CommandManager;
   import com.qzone.qfa.managers.ResourceManager;
   import common.Settings;
   import common.misc.QzoneJSAPI;
   import flash.events.DataEvent;
   import flash.events.EventDispatcher;
   import flash.xml.XMLDocument;
   import flash.xml.XMLNode;
   
   public class FarmLiteModel extends EventDispatcher
   {
      
      public static const EVENT_HARVEST:String = "HarvestResult";
      
      public static const EVENT_HARVEST_ERROR:String = "HarvestError";
      
      private var _config:String;
      
      private var _seedConfig:Object;
      
      private var _requesting:Boolean;
      
      private var _farmJson:Object;
      
      public function FarmLiteModel(param1:Object)
      {
         super(null);
         this._farmJson = param1;
         var _loc2_:String = Settings.getInstance().getStringAttribute("config_data");
         var _loc3_:Resource = ResourceManager.gi().getResource(_loc2_);
         if(_loc3_ != null && _loc3_.loaded == true)
         {
            this._config = _loc3_.data;
         }
         if(this._farmJson != null && this._farmJson["user"] != undefined)
         {
            if(this._farmJson["user"]["userName"] == null || this._farmJson["user"]["userName"] == "")
            {
               this._farmJson["user"]["userName"] = QzoneJSAPI.getNickname();
            }
         }
      }
      
      private function updateLandStatus(param1:*, param2:*) : void
      {
         var _loc4_:String = null;
         if(param1 == null || param2 == null)
         {
            return;
         }
         var _loc3_:Object = {
            "a":"cId",
            "b":"cropStatus",
            "f":"weed",
            "g":"pest",
            "h":"humidity",
            "i":"health",
            "j":"harvestTimes",
            "k":"output",
            "l":"min",
            "m":"leavings",
            "n":"thief",
            "p":"action",
            "q":"plantTime",
            "r":"updateTime",
            "bitmap":"bitmap",
            "pId":"pId",
            "o":"fertilize",
            "c":"oldweed",
            "d":"oldpest",
            "e":"oldhumidity"
         };
         for(_loc4_ in _loc3_)
         {
            if(param2[_loc3_[_loc4_]] != undefined)
            {
               param1[_loc4_] = param2[_loc3_[_loc4_]];
            }
         }
      }
      
      public function harvest(param1:int) : void
      {
         var st:Settings;
         var mode:String;
         var harvest:CmdHttpRequest;
         var url:String;
         var postValue:*;
         var me:Object;
         var version:String;
         var onSuccess:Function = null;
         var onFailed:Function = null;
         var index:int = param1;
         onSuccess = function(param1:QFAEvent):void
         {
            var _loc6_:int = 0;
            var _loc7_:* = undefined;
            _requesting = false;
            var _loc2_:String = param1.data as String;
            if(_loc2_ == null || _loc2_ == "")
            {
               return;
            }
            var _loc3_:Object = com.adobe.serialization.json.JSON.decode(_loc2_);
            var _loc4_:DataEvent = null;
            if(_loc3_ == null || _loc3_["code"] == 0)
            {
               _loc4_ = new DataEvent(EVENT_HARVEST_ERROR);
               if(_loc3_["farmlandIndex"] != undefined)
               {
                  _loc4_.data = _loc3_["farmlandIndex"].toString();
               }
               dispatchEvent(_loc4_);
               return;
            }
            if(_loc3_["status"] != undefined)
            {
               _loc6_ = _loc3_["farmlandIndex"] as int;
               if(_loc6_ < 0 || _loc6_ >= _farmJson["farmlandStatus"]["length"])
               {
                  return;
               }
               _loc7_ = _farmJson["farmlandStatus"][_loc6_];
               updateLandStatus(_loc7_,_loc3_["status"]);
               _loc4_ = new DataEvent(EVENT_HARVEST);
               _loc4_.data = _loc6_.toString() + "," + _loc3_["harvest"].toString();
               dispatchEvent(_loc4_);
            }
            var _loc5_:Object = _farmJson["user"] as Object;
            if(_loc3_["money"] != undefined)
            {
               _loc5_["money"] += _loc3_["money"];
            }
            if(_loc3_["exp"] != undefined)
            {
               _loc5_["exp"] += _loc3_["exp"];
            }
         };
         onFailed = function(param1:QFAEvent):void
         {
            _requesting = false;
         };
         if(index < 0 || index >= 24)
         {
            return;
         }
         if(this._farmJson == null || this._requesting == true)
         {
            return;
         }
         me = this._farmJson["user"] as Object;
         if(me == null)
         {
            return;
         }
         harvest = new CmdHttpRequest();
         postValue = {
            "ownerId":me["uId"],
            "place":index,
            "tName":me["userName"],
            "fName":me["userName"]
         };
         url = "";
         st = Settings.getInstance();
         mode = st.mode;
         if(mode == "qplus")
         {
            mode = "qzone";
         }
         version = mode;
         if(version == "qzone")
         {
            version = "qzone.qq";
         }
         else if(version == "")
         {
            version = st.xymode;
         }
         url = "" + version + "mync.php?mod=farmlandstatus&act=harvest";
         url = QzoneJSAPI.addGToken(url);
         CommandManager.getInstance().run(harvest,{
            "url":url,
            "method":"post",
            "params":postValue,
            "complete":onSuccess,
            "error":onFailed
         });
         this._requesting = true;
      }
      
      public function get background() : String
      {
         var _loc2_:Object = null;
         var _loc3_:XMLDocument = null;
         var _loc4_:Array = null;
         var _loc5_:Object = null;
         var _loc6_:Object = null;
         var _loc7_:XMLNode = null;
         var _loc8_:String = null;
         var _loc9_:Object = null;
         var _loc1_:String = "module/ui/farm/diy/1.swf";
         if(this._farmJson["items"] != undefined && this._farmJson["items"] != null)
         {
            _loc2_ = this._farmJson["items"]["1"];
            if(_loc2_ != null && _loc2_["itemId"] != undefined && this._config != null && this._config != "")
            {
               _loc1_ = "module/ui/farm/diy/" + _loc2_["itemId"] + ".swf";
               _loc3_ = new XMLDocument();
               _loc3_.ignoreWhite = true;
               _loc3_.parseXML(this._config);
               _loc4_ = _loc3_.firstChild.childNodes;
               _loc5_ = null;
               _loc7_ = null;
               for each(_loc7_ in _loc4_)
               {
                  if(_loc7_.localName == "item_info")
                  {
                     _loc5_ = com.adobe.serialization.json.JSON.decode(_loc7_.firstChild.nodeValue);
                     if(_loc5_ != null)
                     {
                        _loc6_ = _loc5_["crops"];
                     }
                     break;
                  }
               }
               _loc8_ = "";
               for each(_loc9_ in _loc6_)
               {
                  if(_loc9_["id"] == _loc2_["itemId"] && _loc9_["asset_id"]["m"] != undefined)
                  {
                     _loc8_ = _loc9_["asset_id"]["m"];
                     break;
                  }
               }
               for each(_loc7_ in _loc4_)
               {
                  if(_loc7_.localName == "assets")
                  {
                     _loc4_ = _loc7_.childNodes;
                     for each(_loc7_ in _loc4_)
                     {
                        if(_loc7_.attributes.id == _loc8_)
                        {
                           _loc1_ = _loc7_.attributes.url;
                           break;
                        }
                     }
                     break;
                  }
               }
            }
         }
         return Settings.getInstance().replaceAppImg(_loc1_);
      }
      
      public function get landCount() : int
      {
         if(this._farmJson == null || this._farmJson["farmlandStatus"] == undefined)
         {
            return 0;
         }
         if(this._farmJson["farmlandStatus"] is Array)
         {
            return this._farmJson["farmlandStatus"]["length"];
         }
         return 0;
      }
      
      public function idState(param1:int, param2:Number, param3:int, param4:int, param5:int) : int
      {
         var _loc8_:Array = null;
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
         var _loc6_:* = this.getCropByID(param1.toString());
         if(_loc6_ == null)
         {
            return 0;
         }
         var _loc7_:String = _loc6_["cropGrow"];
         if(_loc7_ == "")
         {
            return 0;
         }
         _loc8_ = _loc7_.split(",");
         var _loc9_:Number;
         var _loc10_:Number = _loc9_ = parseFloat(this._farmJson["serverTime"]["time"]);
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
               return _loc14_ + 1;
            }
            _loc14_--;
         }
         return 0;
      }
      
      private function getCropByID(param1:String) : Object
      {
         var _loc2_:* = undefined;
         var _loc3_:XMLDocument = null;
         var _loc4_:Array = null;
         var _loc5_:Object = null;
         var _loc6_:XMLNode = null;
         if(this._config == null || this._config == "")
         {
            return null;
         }
         if(this._seedConfig == null)
         {
            _loc3_ = new XMLDocument();
            _loc3_.ignoreWhite = true;
            _loc3_.parseXML(this._config);
            _loc4_ = _loc3_.firstChild.childNodes;
            for each(_loc6_ in _loc4_)
            {
               if(_loc6_.localName == "crops")
               {
                  _loc5_ = com.adobe.serialization.json.JSON.decode(_loc6_.firstChild.nodeValue);
                  if(_loc5_ != null)
                  {
                     this._seedConfig = _loc5_["crops"];
                  }
                  break;
               }
            }
         }
         if(this._seedConfig == null)
         {
            return null;
         }
         for each(_loc2_ in this._seedConfig)
         {
            if(_loc2_["id"] == param1)
            {
               return _loc2_;
            }
         }
         return null;
      }
      
      public function getLandByIndex(param1:int) : Object
      {
         var _loc2_:Array = this._farmJson["farmlandStatus"] as Array;
         if(_loc2_ == null || param1 >= _loc2_.length)
         {
            return null;
         }
         return _loc2_[param1];
      }
      
      public function finalize() : void
      {
         this._farmJson = null;
         this._config = null;
         this._seedConfig = null;
      }
   }
}

