package module.allianceActivitys.olympicGames
{
   import common.LocalData;
   import flash.display.DisplayObject;
   import flash.display.Loader;
   import flash.display.LoaderInfo;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.MouseEvent;
   import flash.external.ExternalInterface;
   import flash.net.URLRequest;
   import flash.system.ApplicationDomain;
   import flash.system.LoaderContext;
   import flash.system.SecurityDomain;
   import mc.FBridge.FRequest;
   import mc.api.AllianceAppHelper;
   import mc.api.AppHelper;
   import mc.control.Command;
   import mc.control.MainCommand;
   import mc.control.Version;
   import mc.model.MData;
   import mc.view.farm.land.NPContainer;
   import mc.view.main.tip.TipControl;
   import mc.view.proxy.GameProxy;
   import module.allianceActivitys.NpcbubbleManager;
   
   public class OlympicGamesActivityHelper extends AllianceAppHelper
   {
      
      public static const get_actdetail:uint = 170001;
      
      public static const getGoldNum:uint = 170002;
      
      public static const get_score:uint = 170003;
      
      private var _param1:Object;
      
      private var _param2:Object;
      
      private var _olympicContext:*;
      
      private var _hasRegister2:Boolean = false;
      
      private var _hasRegister3:Boolean = false;
      
      private var _api:AppHelper;
      
      private var _hasRegister:Boolean = false;
      
      public function OlympicGamesActivityHelper()
      {
         super();
         this._api = new AppHelper();
      }
      
      override public function addNpcEntrance(param1:String, param2:String, param3:int, param4:int, param5:String, param6:String) : Sprite
      {
         var loader:Loader;
         var npc:Sprite = null;
         var loadComplete:Function = null;
         var onOver:Function = null;
         var onOut:Function = null;
         var errorHandler:Function = null;
         var id:String = param1;
         var url:String = param2;
         var x:int = param3;
         var y:int = param4;
         var mouseTip:String = param5;
         var bubbleTip:String = param6;
         loadComplete = function(param1:Event):void
         {
            if((param1.target as LoaderInfo).content is DisplayObject == false)
            {
               return;
            }
            npc.addChild((param1.target as LoaderInfo).content as Sprite);
            NPContainer(GameProxy.npcLand).addNPC(npc,x,y);
            npc.buttonMode = true;
            npc.addEventListener(MouseEvent.ROLL_OVER,onOver);
            npc.addEventListener(MouseEvent.ROLL_OUT,onOut);
            NpcbubbleManager.showBubble(GameProxy.npcLand,6000,bubbleTip,x - 15,y - 140);
         };
         onOver = function(param1:MouseEvent):void
         {
            switchSystemCusror(true);
            TipControl.show("MouseTip",mouseTip);
         };
         onOut = function(param1:MouseEvent):void
         {
            TipControl.hide();
            switchSystemCusror(false);
         };
         errorHandler = function(param1:IOErrorEvent):void
         {
         };
         if(LocalData.mode == Version.)
         {
            return null;
         }
         if(id == "" || id == null)
         {
            return null;
         }
         if(url == "" || url == null)
         {
            return null;
         }
         loader = new Loader();
         loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,errorHandler);
         loader.contentLoaderInfo.addEventListener(IOErrorEvent.NETWORK_ERROR,errorHandler);
         loader.contentLoaderInfo.addEventListener(Event.COMPLETE,loadComplete);
         loader.load(new URLRequest(url),new LoaderContext(false,ApplicationDomain.currentDomain,SecurityDomain.currentDomain));
         npc = new Sprite();
         npc.name = id;
         npc.mouseChildren = false;
         return npc;
      }
      
      override public function execute(param1:String, param2:Object = null) : Object
      {
         var callSuccess:Function = null;
         var callSuccess1:Function = null;
         var callGetScoreSuccess:Function = null;
         var host:Object = null;
         var mcd:MainCommand = null;
         var cmd:String = param1;
         var params:Object = param2;
         callSuccess = function(param1:*):void
         {
            ExternalInterface.call(_param1["callback"],param1);
         };
         callSuccess1 = function(param1:*):void
         {
            ExternalInterface.call(_param2["callback"],param1);
         };
         callGetScoreSuccess = function(param1:*):void
         {
            ExternalInterface.call(params["callback"],param1);
         };
         var mode:String = Version.value;
         switch(cmd)
         {
            case "buy":
               payActivityByPlatform(358,params["id"],1,params["num"],function success(param1:Object):void
               {
               });
               break;
            case "get_actdetail":
               if(!this._hasRegister)
               {
                  this._api.registerNetCommand(get_actdetail,"" + mode + "get_actdetail");
                  this._hasRegister = true;
               }
               this._param1 = params;
               this._api.sendRequest(get_actdetail,params["param"],callSuccess);
               break;
            case "cgi_farm_olympic_game":
               if(!this._hasRegister2)
               {
                  this._api.registerNetCommand(getGoldNum,"" + mode + "cgi_farm_olympic_game");
                  this._hasRegister2 = true;
               }
               this._param2 = params;
               this._api.sendRequest(getGoldNum,params["param"],callSuccess1);
               break;
            case "getGold":
               host = MData.getInstance().mainData.host;
               ExternalInterface.call(params["callback"],host["money"]);
               break;
            case "updateGold":
               mcd = Command.getInstance().mainCommand;
               mcd.addMoney({"money":parseInt(params["param"]["num"])});
               break;
            case "get_score":
               if(!this._hasRegister3)
               {
                  this._api.registerNetCommand(get_score,"" + mode + "get_score");
                  this._hasRegister3 = true;
               }
               this._api.sendRequest(get_score,params["param"],callGetScoreSuccess);
               break;
            case "autoPop":
               this._olympicContext = params;
               FRequest.getInstance().postRequest("cgi_fetch_strategy_rules",{"bitpos":28},this.onForceOpen);
         }
         MData.getInstance().farmData.reloadUserSeed = true;
         return null;
      }
      
      private function onForceOpen(param1:Object) : void
      {
         if(Boolean(param1) && Boolean(param1["bit_flag"] != null) && param1["bit_flag"] == true)
         {
            if(this._olympicContext)
            {
               this._olympicContext.openWindow(true);
            }
         }
      }
   }
}

