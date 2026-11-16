package com.qzone.allianceActivity.advertisement
{
   public class ADConfig
   {
      
      public var mouse_tip:String;
      
      public var npc_src:String = null;
      
      public var start_time:String;
      
      public var autoPopTime:String = null;
      
      public var id:String;
      
      public var icon_src:String;
      
      public var pyLink:String;
      
      public var grayScaleParam:String = null;
      
      public var grayScale:Boolean = false;
      
      public var strongGuide:String = null;
      
      public var bitpos:String = null;
      
      public var npcPos:Array;
      
      public var clickIconReport:String = "";
      
      public var qzoneLink:String;
      
      public var delay_show:int = 1000;
      
      public var windowData:Object;
      
      public var enter_type:String;
      
      public var windowH:int;
      
      private var _autoPopFunction:Function;
      
      public var wbLink:String;
      
      public var whiteList:Boolean = false;
      
      public var bubble_tip:String;
      
      public var callBack:Object;
      
      public var strongGuidePos:Array = [0,0];
      
      public var expire_time:String;
      
      public var whiteListParam:String = null;
      
      public var windowW:int;
      
      private var _appid:String;
      
      public function ADConfig(param1:Object, param2:String, param3:Function)
      {
         super();
         this._appid = param2;
         this._autoPopFunction = param3;
         this.id = param1.id;
         this.enter_type = param1.enter_type;
         if(param1.hasOwnProperty("bitpos"))
         {
            this.bitpos = param1.bitpos;
         }
         if(param1.hasOwnProperty("mouse_tip"))
         {
            this.mouse_tip = param1.mouse_tip;
         }
         if(param1.hasOwnProperty("bubble_tip"))
         {
            this.bubble_tip = param1.bubble_tip;
         }
         if(param1.hasOwnProperty("start_time"))
         {
            this.start_time = param1.start_time;
         }
         if(param1.hasOwnProperty("expire_time"))
         {
            this.expire_time = param1.expire_time;
         }
         if(param1.hasOwnProperty("autoPopTime"))
         {
            this.autoPopTime = param1.autoPopTime;
         }
         if(param1.hasOwnProperty("npc_src"))
         {
            this.npc_src = param1.npc_src;
         }
         if(param1.hasOwnProperty("npcPos"))
         {
            this.npcPos = param1.npcPos;
         }
         if(param1.hasOwnProperty("windowData"))
         {
            this.windowData = param1.windowData;
         }
         if(param1.hasOwnProperty("npcPos"))
         {
            this.npcPos = param1.npcPos;
         }
         if(param1.hasOwnProperty("icon_src"))
         {
            this.icon_src = param1.icon_src;
         }
         if(param1.hasOwnProperty("delay_show"))
         {
            this.delay_show = param1.delay_show;
         }
         if(param1.hasOwnProperty("qzoneLink"))
         {
            this.qzoneLink = param1.qzoneLink;
         }
         if(param1.hasOwnProperty("pyLink"))
         {
            this.pyLink = param1.pyLink;
         }
         if(param1.hasOwnProperty("wbLink"))
         {
            this.wbLink = param1.wbLink;
         }
         if(param1.hasOwnProperty("windowW"))
         {
            this.windowW = param1.windowW;
         }
         if(param1.hasOwnProperty("windowH"))
         {
            this.windowH = param1.windowH;
         }
         if(param1.hasOwnProperty("callBack"))
         {
            this.callBack = param1.callBack;
         }
         if(param1.hasOwnProperty("grayScale"))
         {
            this.grayScale = param1.grayScale;
         }
         if(param1.hasOwnProperty("whiteList"))
         {
            this.whiteList = param1.whiteList;
         }
         if(param1.hasOwnProperty("grayScaleParam"))
         {
            this.grayScaleParam = param1.grayScaleParam;
         }
         if(param1.hasOwnProperty("whiteListParam"))
         {
            this.whiteListParam = param1.whiteListParam;
         }
         if(param1.hasOwnProperty("clickIconReport"))
         {
            this.clickIconReport = param1.clickIconReport;
         }
         if(param1.hasOwnProperty("strongGuide"))
         {
            this.strongGuide = param1.strongGuide;
         }
         if(param1.hasOwnProperty("strongGuidePos"))
         {
            this.strongGuidePos = param1.strongGuidePos;
         }
      }
      
      public function isOutTime(param1:Number) : Boolean
      {
         var _loc2_:Boolean = false;
         var _loc3_:Date = new Date(this.start_time);
         var _loc4_:Date = new Date(this.expire_time);
         if(param1 < _loc3_.time || param1 > _loc4_.time)
         {
            _loc2_ = true;
         }
         return _loc2_;
      }
      
      public function autoPopCallBack(param1:Object) : void
      {
         if(Boolean(param1) && Boolean(param1["bit_flag"] != null) && param1["bit_flag"] == true)
         {
            if(this._autoPopFunction != null)
            {
               this._autoPopFunction(this.id);
            }
         }
      }
   }
}

