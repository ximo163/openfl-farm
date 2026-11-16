package common
{
   public class INI
   {
      
      private static var instance:INI;
      
      private var _data:XML;
      
      public function INI(param1:XML)
      {
         super();
         if(instance != null)
         {
            throw new Error("实例化单例类出错-INI");
         }
         this.data = param1;
      }
      
      public static function getInstance(param1:Object = null) : INI
      {
         var _loc2_:XML = XML(param1);
         if(instance == null)
         {
            instance = new INI(_loc2_);
         }
         return instance;
      }
      
      public function getPostUrl() : String
      {
         var _loc1_:String = "";
         if(this.data != null)
         {
            if(LocalData.mode == "qzone" || LocalData.xymode == "")
            {
               _loc1_ = this.data.postUrl.@url;
            }
            else
            {
               _loc1_ = this.data.postUrl.@url_pengyou;
            }
         }
         if(_loc1_ == "")
         {
         }
         return _loc1_;
      }
      
      public function getHost() : String
      {
         var _loc1_:String = "";
         if(this.data != null)
         {
            _loc1_ = this.data.security.@host;
         }
         return _loc1_;
      }
      
      public function get data() : XML
      {
         return this._data;
      }
      
      public function getModuleUrl(param1:String) : Object
      {
         var moduleName:String = param1;
         var returnValue:Object = new Object();
         if(this.data != null)
         {
            returnValue["url"] = this.data.moduleList.module.(@name == moduleName).@url;
            returnValue["statusText"] = this.data.moduleList.module.(@name == moduleName).@statusText;
            returnValue["size"] = this.data.moduleList.module.(@name == moduleName).@size;
         }
         if(returnValue == "")
         {
            throw new Error("模块地址出错" + moduleName);
         }
         return returnValue;
      }
      
      public function getCommonUrl() : String
      {
         var _loc1_:String = "";
         if(this.data != null)
         {
            _loc1_ = this.data.postUrl.@common;
         }
         if(_loc1_ == "")
         {
            trace("请求地址出错");
         }
         return _loc1_;
      }
      
      public function getMaterialUrl(param1:String) : Array
      {
         var _l:int = 0;
         var i:int = 0;
         var _n:String = null;
         var _t:String = null;
         var _s:String = null;
         var _o:Object = null;
         var moduleName:String = param1;
         var _a:Array = [];
         if(this.data != null)
         {
            _l = int(this.data.moduleList.module.(@name == moduleName).material.length());
            i = 0;
            while(i < _l)
            {
               _n = this.data.moduleList.module.(@name == moduleName).material[i].@url;
               _t = this.data.moduleList.module.(@name == moduleName).material[i].@statusText;
               _s = this.data.moduleList.module.(@name == moduleName).material[i].@size;
               _o = new Object();
               _o["url"] = _n;
               _o["statusText"] = _t;
               _o["size"] = _s;
               _a.push(_o);
               i++;
            }
         }
         return _a;
      }
      
      public function set data(param1:XML) : void
      {
         this._data = param1;
      }
      
      public function getPort() : int
      {
         var _loc1_:int = 9999;
         if(this.data != null)
         {
            _loc1_ = int(this.data.security.@port);
         }
         return _loc1_;
      }
      
      public function loadingUrl() : String
      {
         var _loc1_:String = "";
         if(this.data != null)
         {
            _loc1_ = this.data.loading.@url;
         }
         if(_loc1_ == "")
         {
            trace("请求地址出错");
         }
         return _loc1_;
      }
      
      public function getMaterialTip(param1:String) : String
      {
         var moduleName:String = param1;
         var resultStr:String = "";
         if(this.data != null)
         {
            resultStr = this.data.submodule.module.(@name == moduleName).@tip;
         }
         if(resultStr == "")
         {
            trace("请求地址出错");
         }
         return resultStr;
      }
   }
}

