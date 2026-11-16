package mc.view.farm
{
   import com.minutes.net.HTTPRequest;
   import com.qzone.corelib.js.JSProxy;
   import common.INI;
   import common.LocalData;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.net.URLLoader;
   import flash.net.URLRequest;
   import mc.FBridge.FRequest;
   import mc.model.MData;
   import mc.model.MainData;
   import mc.view.farm.Research.ResearchModel;
   
   public class GetCropID
   {
      
      private static var fr:FRequest;
      
      private static var _xml:XML;
      
      public static var _mpXml:XML;
      
      public static var _loading:Boolean = false;
      
      public function GetCropID()
      {
         super();
      }
      
      public static function getDiyMP(param1:int) : String
      {
         var _infos:XMLList = null;
         var i:int = 0;
         var id:int = param1;
         if(_mpXml == null)
         {
            if(_loading == false)
            {
               getMPXMl();
            }
            return null;
         }
         _infos = _mpXml.items.item.(@id == id).info.l;
         i = 0;
         i = Math.floor(_infos.length() * Math.random());
         return _infos[i];
      }
      
      public static function getSwfUrl() : String
      {
         var _loc1_:String = "";
         if(_xml == null)
         {
            _xml = INI.getInstance().data;
         }
         _loc1_ = String(_xml.folder.@url);
         return addPrefix(_loc1_);
      }
      
      public static function getWildAnimalIcon(param1:String, param2:int) : String
      {
         var _loc3_:String = "";
         _loc3_ = getSwfUrl();
         return _loc3_ + ("farm/wild/pic/" + param1 + "_" + param2 + ".jpg");
      }
      
      public static function getActivity(param1:String, param2:Boolean = false) : Boolean
      {
         var h:String = null;
         var val:String = param1;
         var checkProduct:Boolean = param2;
         if(_xml == null)
         {
            _xml = INI.getInstance().data;
         }
         if(!checkProduct)
         {
            h = _xml.animals.animal.(@id == val).@isActivity;
         }
         else
         {
            h = _xml.animals.animal.(@id == val).@isProductActivity;
         }
         if(h == "1")
         {
            return true;
         }
         return false;
      }
      
      public static function getWildIcon(param1:String, param2:int, param3:String) : String
      {
         var _loc4_:String = "";
         _loc4_ = getSwfUrl();
         return _loc4_ + ("farm/wild/pic/" + param1 + "_" + param3 + "_" + param2 + ".jpg");
      }
      
      public static function idToDiyUrl2(param1:Number, param2:Object) : String
      {
         var _loc4_:String = null;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc3_:String = "";
         if(_xml == null)
         {
            _xml = INI.getInstance().data;
         }
         if(String(param2["lv"]).indexOf("_") != -1)
         {
            _loc4_ = String(param2["lv"]).substr(0,int(param2["lv"].indexOf("_")));
         }
         else
         {
            _loc4_ = param2["lv"];
         }
         var _loc5_:ResearchModel = ResearchModel.gi();
         if(int(_loc4_) > 8)
         {
            _loc6_ = 0;
            if(param2["id"] == "102")
            {
               _loc7_ = 0;
               while(_loc7_ < _loc5_.UpdataW2.length)
               {
                  if(_loc5_.UpdataW2[_loc7_]["endtime"] != 0)
                  {
                     if(_loc5_.canGetDenAnimal(_loc7_))
                     {
                        _loc6_ = 2;
                        _loc4_ += "_ok";
                        break;
                     }
                     _loc6_ = 1;
                  }
                  _loc7_++;
               }
               if(_loc6_ == 1)
               {
                  _loc4_ += "_ing";
               }
            }
            else if(param2["id"] == "103")
            {
               _loc7_ = 0;
               while(_loc7_ < _loc5_.UpdataP2.length)
               {
                  if(_loc5_.UpdataP2[_loc7_]["endtime"] != 0)
                  {
                     if(_loc5_.canGetShedAnimal(_loc7_))
                     {
                        _loc6_ = 2;
                        _loc4_ += "_ok";
                        break;
                     }
                     _loc6_ = 1;
                  }
                  _loc7_++;
               }
               if(_loc6_ == 1)
               {
                  _loc4_ += "_ing";
               }
            }
         }
         param2 = "z" + param1 + "_" + param2["id"] + "_" + _loc4_ + ".swf";
         _loc3_ = getSwfUrl();
         return _loc3_ + ("farm/diy/" + param2);
      }
      
      public static function getWareHouseIconUrl(param1:Number) : String
      {
         var _loc3_:String = null;
         var _loc2_:String = "";
         if(_xml == null)
         {
            _xml = INI.getInstance().data;
         }
         if(param1 > 10000)
         {
            _loc3_ = "a" + (param1 - 10000) + ".jpg";
         }
         else
         {
            _loc3_ = "a" + param1 + "p.jpg";
         }
         _loc2_ = getSwfUrl();
         return _loc2_ + ("farm/animal/" + _loc3_);
      }
      
      public static function toolToAnimal(param1:String) : XML
      {
         var _animal:XML = null;
         var value:String = param1;
         if(_xml == null)
         {
            _xml = INI.getInstance().data;
         }
         _animal = _xml.animals.animal.(@sf == value)[0];
         return _animal;
      }
      
      public static function getFlopUrl() : String
      {
         var _loc1_:String = "";
         _loc1_ = getSwfUrl();
         return _loc1_ + "main/windows/flopGift.swf";
      }
      
      public static function addPrefix(param1:String) : String
      {
         if(Boolean(LocalData.parameters.appImgPrefix) && param1.indexOf(".appimg") == -1)
         {
            param1 = param1.replace("appimg.",LocalData.parameters.appImgPrefix + ".appimg.");
            param1 = param1.replace("appimg1.",LocalData.parameters.appImgPrefix + ".appimg1.");
            param1 = param1.replace("appimg3.",LocalData.parameters.appImgPrefix + ".appimg3.");
         }
         return param1;
      }
      
      public static function getHunterMP(param1:int, param2:String) : String
      {
         var _infos:XMLList = null;
         var i:int = 0;
         var id:int = param1;
         var value:String = param2;
         if(_mpXml == null)
         {
            if(_loading == false)
            {
               getMPXMl();
            }
            return null;
         }
         _infos = _mpXml.guard.info.(@id == id).l;
         i = 0;
         if(value == "work")
         {
            i = Math.floor(_infos.length() * Math.random()) + 1;
         }
         return _infos[i];
      }
      
      public static function getHunterPicUrl(param1:String, param2:Boolean = false) : String
      {
         var _loc3_:String = "";
         if(_xml == null)
         {
            _xml = INI.getInstance().data;
         }
         _loc3_ = getSwfUrl();
         _loc3_ += "farm/hunter/h_" + param1 + ".jpg";
         if(param2)
         {
            _loc3_ = _loc3_.replace("jpg","png");
         }
         return _loc3_;
      }
      
      public static function getAnimalURL(param1:String, param2:int) : String
      {
         var _loc4_:String = null;
         var _loc6_:String = null;
         var _loc3_:String = getSwfUrl() + "farm/aswf/";
         var _loc5_:String = getAnimalV(String(param1));
         if(param2 == 1 || param2 == 2)
         {
            _loc6_ = "_0";
         }
         else
         {
            _loc6_ = "_1";
         }
         if(_loc5_ != "")
         {
            _loc4_ = _loc3_ + "a" + param1 + _loc6_ + ".swf" + "?v=" + _loc5_;
         }
         else
         {
            _loc4_ = _loc3_ + "a" + param1 + _loc6_ + ".swf";
         }
         return _loc4_;
      }
      
      public static function getUpdataAnimalIconUrl(param1:Number, param2:Boolean = false, param3:Boolean = false) : String
      {
         var _loc5_:String = null;
         var _loc4_:String = "";
         if(_xml == null)
         {
            _xml = INI.getInstance().data;
         }
         if(param2)
         {
            _loc5_ = "a" + param1 + ".jpg";
         }
         else if(param3)
         {
            _loc5_ = "a" + param1 + "e_b.png";
         }
         else
         {
            _loc5_ = "a" + param1 + "e.png";
         }
         _loc4_ = getSwfUrl();
         return _loc4_ + ("farm/animal/" + _loc5_);
      }
      
      public static function idToName(param1:String) : String
      {
         var value:String = param1;
         var _name:String = "";
         if(_xml == null)
         {
            _xml = INI.getInstance().data;
         }
         _name = _xml.animals.animal.(@id == value).@name;
         return _name;
      }
      
      public static function getCommonUrlNc() : String
      {
         var _loc1_:XML = INI.getInstance().data;
         var _loc2_:String = "";
         if(_loc1_ != null)
         {
            if(LocalData.mode == "qzone" || LocalData.xymode == "qq.com")
            {
               _loc2_ = _loc1_.postUrl.@commonNc;
            }
            else
            {
               _loc2_ = _loc1_.postUrl.@commonNc_pengyou;
            }
         }
         if(_loc2_ == "")
         {
            trace("请求地址出错");
         }
         return _loc2_;
      }
      
      public static function getCommonUrlFarm() : String
      {
         var _loc1_:XML = INI.getInstance().data;
         var _loc2_:String = "";
         if(_loc1_ != null)
         {
            if(LocalData.mode == "qzone" || LocalData.xymode == "qq.com")
            {
               _loc2_ = _loc1_.postUrl.@commonFarm;
            }
            else
            {
               _loc2_ = _loc1_.postUrl.@commonFarm_pengyou;
            }
         }
         if(_loc2_ == "")
         {
            trace("请求地址出错");
         }
         return _loc2_;
      }
      
      public static function getProductTip(param1:String) : String
      {
         var value:String = param1;
         var _tip:String = "";
         if(_xml == null)
         {
            _xml = INI.getInstance().data;
         }
         _tip = _xml.warehouse.product.(@id == value).tip;
         return _tip;
      }
      
      public static function getShopIconUrl(param1:Number, param2:Boolean = false, param3:Boolean = false, param4:Boolean = false) : String
      {
         var _loc6_:String = null;
         var _loc5_:String = "";
         if(_xml == null)
         {
            _xml = INI.getInstance().data;
         }
         if(param2)
         {
            _loc6_ = "a" + param1 + "b.jpg";
         }
         else if(param3)
         {
            _loc6_ = "a" + param1 + "b.jpg";
         }
         else if(param4)
         {
            _loc6_ = "a" + param1 + "b_s.swf";
         }
         else
         {
            _loc6_ = "a" + param1 + ".jpg";
         }
         _loc5_ = getSwfUrl();
         return _loc5_ + ("farm/animal/" + _loc6_);
      }
      
      public static function getAnimalV(param1:String) : String
      {
         var n:String;
         var val:String = param1;
         if(_xml == null)
         {
            _xml = INI.getInstance().data;
         }
         n = _xml.animals.animal.(@id == val).@v || "";
         return n;
      }
      
      public static function getVipAnimalURL(param1:String) : String
      {
         var _loc2_:String = "";
         _loc2_ = getSwfUrl();
         return _loc2_ + ("farm/VipAnimal/" + param1);
      }
      
      public static function canSellCubTip() : Boolean
      {
         return false;
      }
      
      public static function getTipInfo(param1:String) : String
      {
         var t:String;
         var val:String = param1;
         if(_xml == null)
         {
            _xml = INI.getInstance().data;
         }
         t = _xml.animals.animal.(@id == val).tip;
         return t;
      }
      
      public static function numToNext(param1:Number, param2:Number, param3:Number = 0) : String
      {
         var str:String = null;
         var statusList:Array = null;
         var val:Number = param1;
         var num:Number = param2;
         var next:Number = param3;
         if(_xml == null)
         {
            _xml = INI.getInstance().data;
         }
         str = _xml.animals.animal.(@id == val).nextText.@value;
         statusList = str.split(",");
         if(next == 6 && num == 5)
         {
            return "待收获期";
         }
         return statusList[num - 1] as String;
      }
      
      public static function idToSound(param1:String) : Number
      {
         var _name:Number = NaN;
         var value:String = param1;
         if(_xml == null)
         {
            _xml = INI.getInstance().data;
         }
         _name = Number(_xml.animals.animal.(@id == value).@sound);
         return _name;
      }
      
      public static function hasDiyMP(param1:int) : Boolean
      {
         var _infos:XMLList = null;
         var id:int = param1;
         if(_mpXml == null)
         {
            if(_loading == false)
            {
               getMPXMl();
            }
            return false;
         }
         _infos = _mpXml.items.item.(@id == id).info.l;
         return _infos.length() > 0 ? true : false;
      }
      
      public static function idToWareName(param1:String) : String
      {
         return "p" + param1;
      }
      
      public static function getAnimalInfo(param1:String) : XML
      {
         var ai:XML;
         var val:String = param1;
         if(_xml == null)
         {
            _xml = INI.getInstance().data;
         }
         ai = _xml.animals.animal.(@id == val)[0];
         return ai;
      }
      
      public static function idToCardLockStatus(param1:String) : int
      {
         var value:String = param1;
         var _lock:String = "";
         if(_xml == null)
         {
            _xml = INI.getInstance().data;
         }
         _lock = _xml.cards.card.(@id == value).@isLock;
         return parseInt(_lock);
      }
      
      public static function getAnimalSound(param1:Number) : String
      {
         var info:XMLList = null;
         var i:Number = NaN;
         var id:Number = param1;
         if(_xml == null)
         {
            _xml = INI.getInstance().data;
         }
         info = _xml.animals.animal.(@id == id).info.l;
         i = Math.floor(info.length() * Math.random());
         return info[i];
      }
      
      public static function getShopDiyUrl(param1:String) : String
      {
         var _loc2_:String = "";
         if(_xml == null)
         {
            _xml = INI.getInstance().data;
         }
         _loc2_ = getSwfUrl();
         return _loc2_ + ("farm/diy/z1_" + param1 + "_1_shop.jpg");
      }
      
      private static function loadMPXml(param1:Event) : void
      {
         XML.ignoreWhitespace = true;
         XML.ignoreComments = true;
         _mpXml = XML(param1.target.data);
         MData.getInstance().mainData.dispatchEvent(new Event(MainData.LOAD_DIY_CONFIG_COMPLETE));
      }
      
      public static function idToCardName(param1:String) : String
      {
         var value:String = param1;
         var _name:String = "";
         if(_xml == null)
         {
            _xml = INI.getInstance().data;
         }
         _name = _xml.cards.card.(@id == value).@name;
         return _name;
      }
      
      public static function getProductName2(param1:Object) : String
      {
         var str2:String;
         var val:Object = param1;
         if(_xml == null)
         {
            _xml = INI.getInstance().data;
         }
         str2 = _xml.animals.animal.(@id == val).@product;
         return str2;
      }
      
      public static function getAnimalInfoIconUrl(param1:Number, param2:String) : String
      {
         var _loc3_:String = "";
         if(_xml == null)
         {
            _xml = INI.getInstance().data;
         }
         var _loc4_:String = param2 + param1 + ".png";
         _loc3_ = getSwfUrl();
         return _loc3_ + ("farm/icon/" + _loc4_);
      }
      
      public static function getGameRecord() : Number
      {
         if(_xml == null)
         {
            _xml = INI.getInstance().data;
         }
         var _loc1_:XML = _xml;
         return Number(_xml.game.record[0]);
      }
      
      public static function idToLibName(param1:String) : String
      {
         var value:String = param1;
         var _name:String = "";
         if(_xml == null)
         {
            _xml = INI.getInstance().data;
         }
         _name = _xml.animals.animal.(@id == value).@className;
         return _name;
      }
      
      public static function getDiyTip(param1:int) : String
      {
         var id:int = param1;
         var _tip:String = "";
         if(_mpXml == null)
         {
            if(_loading == false)
            {
               getMPXMl();
            }
            return null;
         }
         _tip = _mpXml.items.item.(@id == id).tip;
         return _tip;
      }
      
      public static function idToCardSrc(param1:String) : String
      {
         var value:String = param1;
         var _src:String = "";
         if(_xml == null)
         {
            _xml = INI.getInstance().data;
         }
         _src = addPrefix(_xml.cards.card.(@id == value).@src);
         return _src;
      }
      
      public static function idToToolName(param1:String, param2:String) : String
      {
         var _loc3_:String = "";
         return "Tool_" + param2 + "_" + param1;
      }
      
      public static function getProductName(param1:String) : String
      {
         var str1:String;
         var str2:String = null;
         var val:String = param1;
         if(_xml == null)
         {
            _xml = INI.getInstance().data;
         }
         str1 = _xml.animals.animal.(@id == val).@u;
         str2 = _xml.animals.animal.(@id == val).@product;
         return str1 + str2;
      }
      
      public static function mpXmlIsNull() : Boolean
      {
         return _mpXml == null ? true : false;
      }
      
      private static function ioErrorHandler(param1:IOErrorEvent) : void
      {
      }
      
      public static function formatString(param1:String) : String
      {
         var _loc2_:RegExp = null;
         var _loc3_:RegExp = null;
         var _loc4_:RegExp = null;
         if(param1.indexOf("<") != -1 || param1.indexOf(">") != -1)
         {
            _loc2_ = /&/g;
            param1 = param1.replace(_loc2_,"&amp;");
            _loc3_ = /</g;
            param1 = param1.replace(_loc3_,"&lt;");
            _loc4_ = />/g;
            param1 = param1.replace(_loc4_,"&gt;");
         }
         return param1;
      }
      
      public static function getChidNum(param1:String) : Number
      {
         var n:Number;
         var val:String = param1;
         if(_xml == null)
         {
            _xml = INI.getInstance().data;
         }
         n = Number(_xml.animals.animal.(@id == val).@childNum);
         return n;
      }
      
      public static function getHouse(param1:String) : String
      {
         var h:String;
         var val:String = param1;
         if(_xml == null)
         {
            _xml = INI.getInstance().data;
         }
         h = _xml.animals.animal.(@id == val).@house;
         return h;
      }
      
      public static function setNext(param1:Object) : void
      {
         var str:String = null;
         var timeList:Array = null;
         var n1:Number = NaN;
         var n2:Number = NaN;
         var n3:Number = NaN;
         var data:Object = param1;
         if(_xml == null)
         {
            _xml = INI.getInstance().data;
         }
         str = _xml.animals.animal.(@id == data.cId).nextTime.@value;
         timeList = str.split(",");
         if(data.status == 2)
         {
            data.statusNext = 3;
            data.growTimeNext = timeList[1];
         }
         if(data.status == 3)
         {
            data.statusNext = 6;
            data.growTimeNext = timeList[5] - data.growTime;
         }
         if(data.status == 5)
         {
            n1 = Number(data.growTime);
            n2 = Number(timeList[4]);
            n3 = Number(timeList[5]);
            if(n1 + n2 >= n3)
            {
               data.statusNext = 6;
               data.growTimeNext = Number(timeList[5] - data.growTime);
            }
            else
            {
               data.statusNext = 3;
               data.growTimeNext = timeList[4];
            }
         }
      }
      
      public static function getDiySkin(param1:int) : String
      {
         var id:int = param1;
         var _skin:String = "";
         if(_mpXml == null)
         {
            if(_loading == false)
            {
               getMPXMl();
            }
            return null;
         }
         _skin = _mpXml.items.item.(@id == id).@skin;
         return _skin;
      }
      
      public static function getMPXMl() : void
      {
         _loading = true;
         var _loc1_:String = JSProxy.addGToken(HTTPRequest.getInstance().httpUrl + "cgi_animal_tips");
         var _loc2_:URLLoader = new URLLoader();
         _loc2_.addEventListener(Event.COMPLETE,loadMPXml);
         _loc2_.addEventListener(IOErrorEvent.IO_ERROR,ioErrorHandler);
         _loc2_.load(new URLRequest(_loc1_));
      }
   }
}

