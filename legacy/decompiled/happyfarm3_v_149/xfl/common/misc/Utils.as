package common.misc
{
   import com.qzone.qfa.data.Resource;
   import com.qzone.qfa.data.ResourceType;
   import com.qzone.qfa.managers.ResourceManager;
   import common.CommonData;
   import common.Settings;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.external.ExternalInterface;
   import flash.filters.GlowFilter;
   
   public class Utils
   {
      
      private static var _textGlowFilter:Array;
      
      private static var default_glow_filter:GlowFilter = new GlowFilter(16776960,1,6,6,4,1,false,false);
      
      private static var _cachedBitmapData:Object = {};
      
      private static var _nameMap:Object = null;
      
      public function Utils()
      {
         super();
      }
      
      public static function buildRequest(param1:uint, param2:*, param3:String = "POST", param4:String = "text") : Object
      {
         if(param1 == 0)
         {
            throw new ArgumentError("Invalid parameter");
         }
         return {
            "cmdID":param1,
            "__body":param2,
            "__method":param3,
            "__format":param4
         };
      }
      
      public static function getClass(param1:String) : Class
      {
         if(param1 == null || param1.length == 0)
         {
            return null;
         }
         return ResourceManager.gi().getClass(param1);
      }
      
      public static function getBrowserVersion() : Object
      {
         var _loc1_:XML =  <![CDATA[
			     function() { 
			         return { "appName" : navigator.appName, "version" : navigator.appVersion }; 
			     }
			    ]]>;
         return ExternalInterface.call(_loc1_);
      }
      
      public static function shareWithCallBack(param1:String, param2:String, param3:String, param4:String, param5:Function = null, param6:Function = null, param7:Function = null) : void
      {
         var _loc8_:String = null;
         if(param5 != null)
         {
            CommonData.addCallBackProxy("onSuccess",param5);
         }
         if(param6 != null)
         {
            CommonData.addCallBackProxy("onCancel",param6);
         }
         if(param7 != null)
         {
            CommonData.addCallBackProxy("onClose",param7);
         }
         if(ExternalInterface.available)
         {
            _loc8_ = "fusion2.dialog.share(" + "{title:\'" + param1 + "\',summary:\'" + param2 + "\',pics:\'" + param3 + "\',desc:\'" + param4 + "\',onSuccess:function (opt){swfAppObject.onSuccess(opt);}" + ",onCancel:function (opt){swfAppObject.onCancel(opt);}" + ",onClose:function (opt){swfAppObject.onClose(opt);}})";
            ExternalInterface.call(_loc8_);
         }
      }
      
      public static function isSafariOnMac() : Boolean
      {
         var _loc1_:Object = getBrowserVersion();
         if(_loc1_ == null)
         {
            return false;
         }
         var _loc2_:String = _loc1_["version"] as String;
         if(_loc2_ == null || _loc2_ == "")
         {
            return false;
         }
         if(_loc2_.indexOf("Macintosh") == -1)
         {
            return false;
         }
         if(_loc2_.indexOf("Safari/") == -1)
         {
            return false;
         }
         return true;
      }
      
      public static function formatPhotoUrl50(param1:uint, param2:String) : String
      {
         var _loc5_:int = 0;
         var _loc3_:String = param2;
         var _loc4_:int = _loc3_.lastIndexOf("/30/30");
         if(_loc3_ == "")
         {
            _loc3_ = QzoneJSAPI.getHead(param1.toString(),50);
         }
         else if(_loc4_ == -1)
         {
            _loc5_ = _loc3_.lastIndexOf("/30");
            if(_loc5_ != -1)
            {
               _loc3_ = _loc3_.substring(0,_loc5_) + "ht" + _loc3_.substring(_loc5_ + 3,_loc3_.length);
            }
         }
         else
         {
            _loc3_ = _loc3_.substring(0,_loc4_) + "/50/30" + _loc3_.substring(_loc4_ + 6,_loc3_.length);
         }
         return _loc3_;
      }
      
      public static function addPrefix(param1:String) : String
      {
         if(param1 == null || param1 == "")
         {
            return param1;
         }
         var _loc2_:String = Settings.getInstance().appImgPrefix;
         if(_loc2_ != "" && param1.indexOf(".appimg") == -1)
         {
            param1 = param1.replace("appimg.",_loc2_ + ".appimg.");
            param1 = param1.replace("appimg1.",_loc2_ + ".appimg1.");
            param1 = param1.replace("appimg3.",_loc2_ + ".appimg3.");
         }
         return param1;
      }
      
      public static function loadXMLData(param1:Object) : XML
      {
         var xml:XML = null;
         var e_target_data:Object = param1;
         if(e_target_data == null)
         {
            return null;
         }
         try
         {
            xml = new XML(e_target_data);
         }
         catch(e:TypeError)
         {
            trace("ERROR: invalid XML file:" + e.message);
         }
         finally
         {
            if(xml != null)
            {
               return xml;
            }
            return null;
         }
      }
      
      public static function getMaterial(param1:String) : Object
      {
         if(param1 == null || param1.length == 0)
         {
            return null;
         }
         return ResourceManager.gi().getClassInstance(param1);
      }
      
      public static function formatNumber(param1:int, param2:uint) : String
      {
         if(param2 == 0)
         {
            return "";
         }
         param1 += Math.pow(10,param2);
         return param1.toString().substr(1,param2);
      }
      
      public static function getStrAttribute(param1:*, param2:String) : String
      {
         if(param1 == null)
         {
            return "";
         }
         if(param2 == null || param2.length == 0)
         {
            return "";
         }
         if(param1[param2] == undefined)
         {
            return "";
         }
         return param1[param2] as String;
      }
      
      public static function getIntAttribute(param1:*, param2:String) : Number
      {
         if(param1 == null)
         {
            return 0;
         }
         if(param2 == null || param2.length == 0)
         {
            return 0;
         }
         if(param1[param2] == undefined)
         {
            return 0;
         }
         return parseInt(param1[param2]);
      }
      
      public static function getCachedBitmapData(param1:String, param2:int, param3:int) : BitmapData
      {
         var _loc5_:BitmapData = null;
         if(_cachedBitmapData.hasOwnProperty(param1))
         {
            return _cachedBitmapData[param1];
         }
         var _loc4_:Class = getClass(param1);
         if(_loc4_ != null)
         {
            _loc5_ = new _loc4_(param2,param3) as BitmapData;
            if(_loc5_ is BitmapData)
            {
               _cachedBitmapData[param1] = _loc5_;
            }
            return _loc5_;
         }
         return null;
      }
      
      public static function get textGlowFilter() : Array
      {
         if(_textGlowFilter == null)
         {
            _textGlowFilter = [new GlowFilter(16777215,1,3,3,7)];
         }
         return _textGlowFilter;
      }
      
      public static function getNameById(param1:int) : String
      {
         var _loc2_:String = null;
         var _loc3_:String = null;
         if(_nameMap == null)
         {
            _nameMap = Cookies.getObject("nameMap",1);
         }
         if(_nameMap != null && _nameMap[param1] != undefined)
         {
            _loc2_ = _nameMap[param1]["qz"];
            _loc3_ = _nameMap[param1]["xy"];
            if(Settings.getInstance().mode == "qzone" || Settings.getInstance().mode == "qplus")
            {
               if(_loc2_ != "")
               {
                  return _loc2_;
               }
               return _loc3_;
            }
            if(_loc3_ != "")
            {
               return _loc3_;
            }
            return _loc2_;
         }
         return "";
      }
      
      public static function unStroke(param1:DisplayObject) : void
      {
         if(param1 == null)
         {
            return;
         }
         if(param1.filters == null)
         {
            return;
         }
         param1.filters = [];
      }
      
      public static function addResToManager(param1:String, param2:*) : Boolean
      {
         if(param2 == null)
         {
            return false;
         }
         if(param1 == null || param1.length == 0)
         {
            return false;
         }
         var _loc3_:String = ResourceType.getType(param1);
         if(_loc3_ == "")
         {
            return false;
         }
         var _loc4_:Resource = new Resource();
         _loc4_.type = _loc3_;
         _loc4_.url = param1;
         _loc4_.data = param2;
         ResourceManager.gi().addResource(_loc4_);
         return true;
      }
      
      public static function stroke(param1:DisplayObject) : void
      {
         if(param1 == null)
         {
            return;
         }
         param1.filters = [default_glow_filter];
      }
   }
}

