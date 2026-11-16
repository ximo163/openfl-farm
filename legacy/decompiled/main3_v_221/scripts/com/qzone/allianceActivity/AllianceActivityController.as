package com.qzone.allianceActivity
{
   import com.adobe.serialization.json.JSON;
   import com.qzone.allianceActivity.interfaces.IAllianceActivityContext;
   import com.qzone.allianceActivity.interfaces.IAllianceAppHelper;
   import flash.display.DisplayObject;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.external.ExternalInterface;
   import flash.net.URLLoader;
   import flash.net.URLRequest;
   import flash.net.URLVariables;
   import flash.utils.Dictionary;
   import flash.utils.setTimeout;
   
   public class AllianceActivityController
   {
      
      protected var _config:XML;
      
      protected var _actServerData:Object = {};
      
      protected var _acManager:AllianceActivityManager;
      
      protected var _helperMap:Dictionary;
      
      public function AllianceActivityController()
      {
         super();
         this._acManager = AllianceActivityManager.getInstance();
         this.initActivityHelpers();
      }
      
      protected function onLoadCustomize(param1:IAllianceActivityContext, param2:XMLList) : void
      {
         var _loc3_:AllianceActivityAssetInfo = null;
         if(param1 != null && param1.appHelper != null)
         {
            _loc3_ = this._acManager.config.getActivityAsset(param1.activityId,"customize_icon");
            if(_loc3_ != null)
            {
               param1.appHelper.execute("addCustomizeEntrance",_loc3_.src);
            }
         }
      }
      
      protected function initActivityHelpers() : void
      {
         this._helperMap = new Dictionary();
      }
      
      public function loadConfig(param1:XML, param2:Number, param3:String, param4:String = "") : void
      {
         var _loc9_:String = null;
         var _loc10_:URLVariables = null;
         var _loc11_:URLRequest = null;
         var _loc12_:URLLoader = null;
         if(param1 == null)
         {
            return;
         }
         this._config = param1;
         this._acManager.initialize(this._config,param2,param3);
         var _loc5_:Array = [];
         var _loc6_:String = null;
         var _loc7_:int = 0;
         var _loc8_:int = this._config.activity.length();
         while(_loc7_ < _loc8_)
         {
            if(this._acManager.checkActivityAvaliable(this._config.activity[_loc7_].@id) == true)
            {
               if(this._config.activity[_loc7_].@standalone == "1")
               {
                  if(this.onPreloadCustomize(this._config.activity[_loc7_]) != false)
                  {
                     this._acManager.loadActivityModule(param1.activity[_loc7_].@id).addEventListener(Event.COMPLETE,this.activityModuleLoadComplete);
                  }
               }
               else
               {
                  _loc5_.push(this._config.activity[_loc7_].@act_id);
               }
            }
            _loc7_++;
         }
         if(_loc5_.length > 0)
         {
            _loc9_ = "mod=get_actinfo";
            if(param4 == "" || param4 == null)
            {
               _loc9_ = this.attachDefParam(_loc9_) + "&";
            }
            else
            {
               _loc9_ = "?gtk=" + param4 + "&";
            }
            _loc10_ = new URLVariables();
            _loc10_.actid = _loc5_.join("|");
            _loc10_.appid = this._config.@appId;
            _loc11_ = new URLRequest(_loc9_);
            _loc11_.data = _loc10_;
            _loc11_.method = "POST";
            _loc12_ = new URLLoader();
            _loc12_.addEventListener(Event.COMPLETE,this.onActivityData,false,0,true);
            _loc12_.load(_loc11_);
         }
      }
      
      private function addIconToStage(param1:IAllianceAppHelper, param2:MovieClip) : void
      {
         if(param2 == null || param1 == null)
         {
            return;
         }
         param1.addIconEntrance(param2);
      }
      
      private function attachDefParam(param1:String) : String
      {
         if(ExternalInterface.available)
         {
            param1 = String(ExternalInterface.call("SwfAppLib.method.attachDefParam",param1));
         }
         return param1;
      }
      
      private function openActivityWindow(param1:String) : void
      {
         if(param1 == null || param1 == "")
         {
            return;
         }
         var _loc2_:IAllianceActivityContext = this._acManager.getActivityContext(param1) as IAllianceActivityContext;
         if(_loc2_ != null)
         {
            _loc2_.execute("openActivityWin",this._actServerData[param1]);
         }
      }
      
      private function onEnterActivity(param1:MouseEvent) : void
      {
         this.openActivityWindow(param1.currentTarget.name);
      }
      
      private function onActivityData(param1:Event) : void
      {
         var act:Object = null;
         var config:XMLList = null;
         var e:Event = param1;
         var data:Object = com.adobe.serialization.json.JSON.decode(e.target.data);
         if(Boolean(data) && data["ret"] == 0)
         {
            if(data["actinfo"].length > 0)
            {
               for each(act in data["actinfo"])
               {
                  try
                  {
                     config = this._config.activity.(@act_id == act["actid"]);
                     if(act["comein"] == "yes" && act["valid"] == "yes")
                     {
                        this._acManager.loadActivityModule(config.@id).addEventListener(Event.COMPLETE,this.activityModuleLoadComplete);
                        this._actServerData[config.@id] = act;
                     }
                  }
                  catch(e:Error)
                  {
                     trace(e);
                  }
               }
            }
         }
      }
      
      protected function onPreloadCustomize(param1:XML) : Boolean
      {
         return true;
      }
      
      protected function activityModuleLoadComplete(param1:Event) : void
      {
         var helper:IAllianceAppHelper;
         var activityConfig:XMLList;
         var context:IAllianceActivityContext = null;
         var id:String = null;
         var delay:int = 0;
         var mouseTip:String = null;
         var bubbleTip:String = null;
         var enterIcon:DisplayObject = null;
         var npc:Sprite = null;
         var e:Event = param1;
         context = (e.target as Loader).content as IAllianceActivityContext;
         if(context == null)
         {
            return;
         }
         helper = this._helperMap[context.activityId] as IAllianceAppHelper;
         if(helper == null)
         {
            return;
         }
         context.appHelper = helper;
         activityConfig = this._config.activity.(@id == context.activityId);
         if(activityConfig == null)
         {
            return;
         }
         id = activityConfig.@id;
         delay = 0;
         mouseTip = "";
         bubbleTip = "";
         if(activityConfig.@delay_show)
         {
            delay = int(activityConfig.@delay_show);
         }
         if(activityConfig.@mouse_tip)
         {
            mouseTip = activityConfig.@mouse_tip;
         }
         if(activityConfig.@bubble_tip)
         {
            bubbleTip = activityConfig.@bubble_tip;
         }
         if(activityConfig.@enter_type == "icon")
         {
            enterIcon = context.execute("getEnterIcon") as DisplayObject;
            if(enterIcon)
            {
               MovieClip(enterIcon).buttonMode = true;
               enterIcon.name = activityConfig.@id;
               enterIcon.addEventListener(MouseEvent.CLICK,this.onEnterActivity,false,0,true);
               setTimeout(this.addIconToStage,delay * 1000,helper,enterIcon);
            }
         }
         else if(activityConfig.@enter_type == "npc")
         {
            npc = helper.addNpcEntrance(id,activityConfig.@npc_src,activityConfig.@x,activityConfig.@y,mouseTip,bubbleTip);
            if(npc != null)
            {
               npc.addEventListener(MouseEvent.CLICK,this.onEnterActivity);
            }
         }
         else if(activityConfig.@enter_type == "customize")
         {
            this.onLoadCustomize(context,activityConfig);
         }
         if(Boolean(this._actServerData) && Boolean(this._actServerData[id]) && this._actServerData[id]["ifqt"] == "yes")
         {
            setTimeout(this.openActivityWindow,delay,id);
         }
      }
   }
}

