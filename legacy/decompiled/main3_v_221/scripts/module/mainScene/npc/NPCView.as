package module.mainScene.npc
{
   import com.qzone.allianceActivity.framewrok.manager.ClickReportManager;
   import com.qzone.utils.DisplayUtil;
   import common.CommonData;
   import common.Consts;
   import common.Session;
   import common.Settings;
   import common.misc.QzoneJSAPI;
   import common.view.window.WindowControl;
   import events.CommonEvent;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.Loader;
   import flash.display.LoaderInfo;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.MouseEvent;
   import flash.external.ExternalInterface;
   import flash.geom.Point;
   import flash.net.URLRequest;
   import flash.system.ApplicationDomain;
   import flash.system.LoaderContext;
   import flash.system.SecurityDomain;
   import flash.utils.setTimeout;
   import framework.base.BaseLayer;
   import module.mainScene.npc.widgets.DogBowl;
   import module.mainScene.npc.widgets.DogFoodWindow;
   import module.mainScene.npc.widgets.DogRender;
   
   public class NPCView extends Sprite
   {
      
      private var _activityHolder:Sprite;
      
      private var _activityNPCData:Object;
      
      private var m_farmDog:DogRender;
      
      private var m_middleLayer:DisplayObjectContainer;
      
      private var m_controller:NPCController;
      
      private var m_dogBowl:DogBowl;
      
      private var m_dogFoodWindow:DogFoodWindow;
      
      public function NPCView(param1:NPCController)
      {
         var _loc2_:Settings = null;
         var _loc3_:String = null;
         var _loc4_:Array = null;
         var _loc5_:Date = null;
         var _loc6_:Date = null;
         var _loc7_:Number = NaN;
         super();
         name = Consts.SCENE_ZINDEX_FOREGROUND;
         this.m_farmDog = null;
         this.m_dogBowl = null;
         this.m_dogFoodWindow = null;
         this.m_controller = param1;
         this.m_middleLayer = param1.module.container.getChildByName(Consts.SCENE_ZINDEX_MIDDLE) as DisplayObjectContainer;
         addEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage);
         if(QzoneJSAPI.QPLUS == false && QzoneJSAPI.WB == false)
         {
            _loc2_ = Settings.getInstance();
            _loc3_ = _loc2_.getStringAttribute("a361");
            if(_loc3_ == null || _loc3_ == "")
            {
               return;
            }
            _loc4_ = _loc3_.split("-");
            _loc5_ = new Date(_loc4_[0]);
            _loc6_ = new Date(_loc4_[1]);
            _loc7_ = CommonData.serverTime * 1000;
            if(_loc7_ >= _loc5_.time && _loc7_ <= _loc6_.time)
            {
               this.loadAdvertiseIcon("module/ui/361.swf");
            }
         }
      }
      
      private function onFoodLoaded(param1:CommonEvent) : void
      {
         var _loc2_:WindowControl = null;
         if(Session.getInstance().me == true)
         {
            if(this.m_dogFoodWindow == null)
            {
               this.m_dogFoodWindow = new DogFoodWindow(this);
            }
            _loc2_ = this.controller.module.app.farmView.winCtrl;
            if(_loc2_ == null)
            {
               return;
            }
            _loc2_.open(this.m_dogFoodWindow);
            this.m_dogFoodWindow.data = param1.data;
            this.updateFood();
         }
      }
      
      public function installNPC(param1:Object) : void
      {
         var container:DisplayObjectContainer = null;
         var removeBubble:Function = null;
         var mcTalk:MaoPaoFlag = null;
         var p:Point = null;
         var lyr:BaseLayer = null;
         var data:Object = param1;
         removeBubble = function():void
         {
            if(arguments[0] == null)
            {
               return;
            }
            var _loc2_:Sprite = arguments[0] as Sprite;
            if(_loc2_ == null && _loc2_.parent != null)
            {
               return;
            }
            _loc2_.parent.removeChild(_loc2_);
            _loc2_ = null;
         };
         var role:Sprite = data["role"] as Sprite;
         if(role == null)
         {
            return;
         }
         role.buttonMode = true;
         role.mouseEnabled = true;
         role.x = role.y = 0;
         container = this.activityHolder;
         container.x = data["x"] as int;
         container.y = data["y"] as int;
         container.addChild(role);
         this._activityNPCData = data;
         if(data["bubble"] != undefined && data["bubble"] != "")
         {
            mcTalk = new MaoPaoFlag();
            mcTalk.x = 0;
            mcTalk.y = -100;
            mcTalk.mouseChildren = false;
            mcTalk.mouseEnabled = false;
            mcTalk.gotoAndPlay(1);
            mcTalk.talkInfo = data["bubble"] as String;
            p = container.localToGlobal(new Point(role.x,role.y));
            lyr = this.controller.module.app.farmView.getLayerByName(Consts.LAYER_TOOLS);
            p = lyr.globalToLocal(p);
            lyr.addChild(mcTalk);
            mcTalk.x = p.x;
            mcTalk.y = p.y - 100;
            setTimeout(removeBubble,5000,mcTalk);
         }
      }
      
      public function updateFood() : void
      {
         if(this.m_dogBowl == null)
         {
            this.m_dogBowl = new DogBowl(this);
            if(this.m_middleLayer != null)
            {
               this.m_middleLayer.addChildAt(this.m_dogBowl,0);
            }
         }
         if(this.m_controller.model.dogID <= 0)
         {
            DisplayUtil.removeChild(this.m_middleLayer,this.m_dogBowl);
         }
         else
         {
            if(this.m_controller.model.dogHungry == 0)
            {
               this.m_dogBowl.food = false;
            }
            else
            {
               this.m_dogBowl.food = true;
            }
            if(this.m_dogBowl.parent == null)
            {
               if(this.m_middleLayer != null)
               {
                  this.m_middleLayer.addChildAt(this.m_dogBowl,0);
               }
            }
         }
      }
      
      private function loadAdvertiseIcon(param1:String) : void
      {
         var loader:Loader;
         var loadComplete:Function = null;
         var errorHandler:Function = null;
         var onClick361:Function = null;
         var onOver361:Function = null;
         var onOut361:Function = null;
         var url:String = param1;
         loadComplete = function(param1:Event):void
         {
            var _loc2_:DisplayObject = null;
            if(param1.target is LoaderInfo)
            {
               _loc2_ = (param1.target as LoaderInfo).content;
            }
            if(_loc2_ == null)
            {
               return;
            }
            _loc2_.x = 192;
            _loc2_.y = 680;
            _loc2_.addEventListener(MouseEvent.CLICK,onClick361,false,0,true);
            _loc2_.addEventListener(MouseEvent.MOUSE_OVER,onOver361,false,0,true);
            _loc2_.addEventListener(MouseEvent.MOUSE_OUT,onOut361,false,0,true);
            addChild(_loc2_);
         };
         errorHandler = function(param1:IOErrorEvent):void
         {
         };
         onClick361 = function(param1:MouseEvent):void
         {
            var _loc2_:String = "";
            if(Settings.getInstance().mode == "")
            {
               _loc2_ = "";
            }
            CommonData.addCallBackProxy("getGiftBack",on361Callback);
            ExternalInterface.call("QZFL.dialog.create(\'\'," + "\'<iframe src=" + _loc2_ + "&id=0" + " style=\"width:570px; height:460px; border:0px\" scrolling=no border=0 frameBorder=no allowTransparency=true></iframe>\', {width:570,height:460,noBorder:true})");
            ClickReportManager.reportClick("361_Click_Icon_NC");
         };
         onOver361 = function(param1:MouseEvent):void
         {
            m_controller.useSystemCursor(true);
         };
         onOut361 = function(param1:MouseEvent):void
         {
            m_controller.useSystemCursor(false);
         };
         if(url == "" || url == null)
         {
            return;
         }
         url = Settings.getInstance().replaceAppImg(url);
         loader = new Loader();
         loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,errorHandler);
         loader.contentLoaderInfo.addEventListener(IOErrorEvent.NETWORK_ERROR,errorHandler);
         loader.contentLoaderInfo.addEventListener(Event.COMPLETE,loadComplete);
         loader.load(new URLRequest(url),new LoaderContext(true,ApplicationDomain.currentDomain,SecurityDomain.currentDomain));
      }
      
      public function switchNPC() : void
      {
         if(Session.getInstance().me)
         {
            if(this._activityHolder != null)
            {
               this._activityHolder.visible = true;
            }
         }
         else if(this._activityHolder != null)
         {
            this._activityHolder.visible = false;
         }
      }
      
      private function on361Callback(param1:*) : void
      {
         if(param1 as Boolean == true)
         {
            this.m_controller.module.app.dispatchEvent(new CommonEvent(Consts.DATA_CROP_RELOAD_FLAG,null));
            this.m_controller.module.app.dispatchEvent(new CommonEvent(Consts.DATA_BAG_RELOAD_FLAG,null));
         }
      }
      
      public function get activityHolder() : DisplayObjectContainer
      {
         if(this._activityHolder == null)
         {
            this._activityHolder = new Sprite();
            this.m_middleLayer.addChild(this._activityHolder);
            this._activityHolder.addEventListener(MouseEvent.ROLL_OVER,this.onNPCOver,false,0,true);
            this._activityHolder.addEventListener(MouseEvent.ROLL_OUT,this.onNPCOut,false,0,true);
            this._activityHolder.buttonMode = true;
         }
         return this._activityHolder;
      }
      
      public function get controller() : NPCController
      {
         return this.m_controller;
      }
      
      private function onAddedToStage(param1:Event) : void
      {
         param1.target.removeEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage);
         this.m_controller.model.addEventListener(NPCModel.EVENT_DOG_LOADED,this.onDogInitialized,false,0,true);
         this.m_controller.model.addEventListener(NPCModel.EVENT_DOG_FOOD_LOADED,this.onFoodLoaded,false,0,true);
      }
      
      private function onNPCOut(param1:MouseEvent) : void
      {
         this.controller.useSystemCursor(false);
         this.controller.hideTip();
      }
      
      private function onNPCOver(param1:MouseEvent) : void
      {
         this.controller.useSystemCursor(true);
         if(this._activityNPCData != null && this._activityNPCData["tip"] != undefined)
         {
            this.controller.showTip(Consts.TIP_NAME_MOUSE,this._activityNPCData["tip"] as String);
         }
      }
      
      private function onDogInitialized(param1:CommonEvent) : void
      {
         this.updateFood();
         var _loc2_:int = this.m_controller.model.dogID;
         if(this.m_farmDog != null && this.m_farmDog.id != _loc2_.toString())
         {
            DisplayUtil.removeChild(this.m_middleLayer,this.m_farmDog);
            this.m_farmDog.stop();
            this.m_farmDog = null;
         }
         if(_loc2_ > 0)
         {
            if(this.m_farmDog == null)
            {
               this.m_farmDog = new DogRender(_loc2_);
               if(this.m_middleLayer != null)
               {
                  this.m_middleLayer.addChildAt(this.m_farmDog,this.m_middleLayer.getChildIndex(this.m_dogBowl) + 1);
               }
            }
         }
      }
   }
}

