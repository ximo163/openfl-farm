package module.mainScene.farmLand
{
   import com.greensock.TweenLite;
   import common.Consts;
   import common.GetCropID;
   import common.Session;
   import common.Settings;
   import common.misc.QzoneJSAPI;
   import common.misc.Utils;
   import common.view.cursor.CursorControl;
   import entities.FarmLand;
   import events.CommonEvent;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.filters.ColorMatrixFilter;
   import flash.geom.Point;
   import flash.utils.Timer;
   import framework.base.BaseLayer;
   import module.mainScene.farmLand.widgets.LandItemRender;
   import module.mainScene.farmLand.widgets.LandPickIcon;
   import module.mainScene.farmLand.widgets.LandTalkTip;
   
   public class FarmLandsView extends Sprite
   {
      
      public static var SCALE:Number = 0.75;
      
      public static const ITEM_WIDTH:Number = 204 * SCALE;
      
      public static const ITEM_HEIGHT:Number = 102 * SCALE;
      
      private const ITEM_TIP_OFFSET:Number = 20 * SCALE;
      
      private var m_pickIcon:LandPickIcon;
      
      private var m_currentItem:LandItemRender;
      
      private var _planeAnimation:MovieClip;
      
      private var m_tipDelayTimer:Timer;
      
      private var m_items:Array;
      
      private var m_overFilters:Array;
      
      private var m_controller:FarmLandController;
      
      private var m_talk:LandTalkTip;
      
      public function FarmLandsView(param1:FarmLandController)
      {
         super();
         name = Consts.SCENE_ZINDEX_LAND;
         this.m_controller = param1;
         this.m_tipDelayTimer = null;
         this.m_currentItem = null;
         this.m_overFilters = [new ColorMatrixFilter([1.6,0,0,0,-21.59,0,1.6,0,0,-21.59,0,0,1.6,0,-21.59,0,0,0,1,0])];
         this.m_items = null;
         this.m_talk = null;
         this.m_pickIcon = null;
         addEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage);
      }
      
      private function onOperateFailed(param1:CommonEvent) : void
      {
         if(param1 == null || param1.data == null)
         {
            return;
         }
         var _loc2_:int = param1.data["money"] as int;
         if(_loc2_ == 0)
         {
            return;
         }
         var _loc3_:int = param1.data["index"] as int;
         if(_loc3_ < 0 || _loc3_ >= this.m_items.length)
         {
            return;
         }
         var _loc4_:Number = Number(this.m_items[_loc3_].x);
         var _loc5_:Number = this.m_items[_loc3_].y + this.ITEM_TIP_OFFSET;
         var _loc6_:Point = localToGlobal(new Point(_loc4_,_loc5_));
         var _loc7_:String = "- " + Math.abs(_loc2_);
         var _loc8_:Object = {
            "text":_loc7_,
            "type":"4",
            "cId":1,
            "x":_loc6_.x,
            "y":_loc6_.y
         };
         this.m_controller.openFloat(Consts.FLOAT_TYPE_HA,_loc8_);
      }
      
      private function onReclaimClicked(param1:LandItemRender) : void
      {
         if(Session.getInstance().harvestAnimationPlaying == true)
         {
            return;
         }
         this.m_currentItem = null;
         this.m_controller.model.nextReclaimCondition();
      }
      
      private function createLandTiles(param1:int, param2:int) : void
      {
         var _loc6_:int = 0;
         var _loc7_:LandItemRender = null;
         var _loc8_:LandItemRender = null;
         if(param1 == 0 || param2 == 0)
         {
            return;
         }
         var _loc3_:Number = 46 + param2 * (ITEM_WIDTH / 2);
         var _loc4_:Number = 320 - ITEM_HEIGHT / 2;
         this.m_items = new Array();
         var _loc5_:int = 0;
         while(_loc5_ < param1)
         {
            _loc6_ = 0;
            while(_loc6_ < param2)
            {
               _loc7_ = new LandItemRender();
               _loc7_.name = "__FarmlandItem__" + _loc5_ + "." + _loc6_;
               _loc7_.x = _loc3_ + _loc5_ * ITEM_WIDTH / 2 - _loc6_ * ITEM_WIDTH / 2;
               _loc7_.y = _loc4_ + _loc5_ * ITEM_HEIGHT / 2 + _loc6_ * ITEM_HEIGHT / 2;
               addChild(_loc7_);
               this.m_items.push(_loc7_);
               _loc7_.addEventListener(MouseEvent.CLICK,this.onMouseEvent,true,0,true);
               _loc6_++;
            }
            _loc5_++;
         }
         _loc3_ = 46;
         _loc4_ = 320 + ITEM_HEIGHT;
         _loc5_ = 0;
         while(_loc5_ < param1)
         {
            _loc8_ = new LandItemRender();
            _loc8_.name = "__FarmlandItem__" + _loc5_ + "." + _loc6_;
            _loc8_.x = _loc3_ + _loc5_ * ITEM_WIDTH / 2;
            _loc8_.y = _loc4_ + _loc5_ * ITEM_HEIGHT / 2;
            addChild(_loc8_);
            this.m_items.push(_loc8_);
            _loc8_.addEventListener(MouseEvent.CLICK,this.onMouseEvent,true,0,true);
            _loc5_++;
         }
      }
      
      private function updateLandItem(param1:LandItemRender, param2:FarmLand) : void
      {
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         if(param1 == null || param2 == null)
         {
            return;
         }
         var _loc3_:uint = uint(param2._cId);
         var _loc4_:String = "";
         if(_loc3_ > 0)
         {
            _loc4_ = Settings.getInstance().getCropName(_loc3_);
         }
         if(_loc4_ != "")
         {
            _loc5_ = param2._step;
            if(param2._cropStatus >= 7)
            {
               _loc5_ = 7 - 1;
            }
            param1.setGrowStep(_loc5_,_loc3_);
            if(_loc5_ == 5 || _loc5_ == 6)
            {
               param1.createByproduct(0,0);
               param1.updateLandStatus(param2._bitmap,true,false,param2._goldLand);
            }
            else
            {
               _loc6_ = 0;
               if(_loc5_ != 3 && _loc5_ != 4)
               {
                  _loc6_ = 0;
               }
               else
               {
                  _loc6_ = param2._pest;
               }
               param1.createByproduct(_loc6_,param2._weed);
               param1.updateLandStatus(param2._bitmap,param2._humidity > 0,param2._fertilize > 0,param2._goldLand);
            }
            param1.createCrop(_loc3_,_loc4_,GetCropID.getCropUrl(_loc3_,_loc5_));
         }
         else
         {
            param1.clearAll();
            param1.updateLandStatus(param2._bitmap,param2._humidity > 0,param2._fertilize > 0,param2._goldLand);
         }
      }
      
      private function onPlayPlaneAnimation(param1:Event) : void
      {
         var _loc2_:MovieClip = Utils.getMaterial("PlaneAnimation") as MovieClip;
         if(_loc2_ == null)
         {
            this.m_controller.model.reloadAllLands(false);
            return;
         }
         this.stage.addChild(_loc2_);
         var _loc3_:int = stage.stageWidth * stage.stageWidth + stage.stageHeight * stage.stageHeight;
         _loc3_ = Math.sqrt(_loc3_);
         _loc3_ *= 0.5;
         var _loc4_:Number = 26.6 * Math.PI / 180;
         var _loc5_:int = stage.stageWidth * 0.5 + _loc3_ * Math.cos(_loc4_);
         var _loc6_:int = stage.stageHeight * 0.5 + _loc3_ * Math.sin(_loc4_) - 50;
         _loc2_.x = stage.stageWidth * 0.5;
         _loc2_.y = stage.stageHeight * 0.5 - 20;
         TweenLite.from(_loc2_,0.5,{
            "x":_loc5_,
            "y":_loc6_,
            "scaleX":3,
            "scaleY":3,
            "delay":1.5,
            "onComplete":this.onPlaneMoveIn
         });
         this._planeAnimation = _loc2_;
         this._planeAnimation.mouseChildren = false;
         this._planeAnimation.mouseEnabled = false;
      }
      
      private function registerListeners() : void
      {
         var _loc1_:FarmLandModel = this.m_controller.model;
         if(_loc1_ == null)
         {
            return;
         }
         _loc1_.addEventListener(FarmLandModel.EVENT_INITIALZED,this.onDataInitialized,false,0,true);
         _loc1_.addEventListener(FarmLandModel.EVENT_HARVEST_DATA,this.onHarvestData,false,0,true);
         _loc1_.addEventListener(FarmLandModel.EVENT_OPERATE_INVALID,this.onOperateInvalid,false,0,true);
         _loc1_.addEventListener(FarmLandModel.EVENT_OPERATE_FAILED,this.onOperateFailed,false,0,true);
         _loc1_.addEventListener(FarmLandModel.EVENT_ADD_HEALTH,this.onAddHealth,false,0,true);
         _loc1_.addEventListener(FarmLandModel.EVENT_LAND_CHANGED,this.onFarmLandChanged,false,0,true);
         _loc1_.addEventListener(FarmLandModel.EVENT_SHOW_PICK_ICON,this.onShowPickIcon,false,0,true);
         _loc1_.addEventListener(FarmLandModel.EVENT_CHECK_STATUS,this.onCheckStatus,false,0,true);
         _loc1_.addEventListener(FarmLandModel.EVENT_PLAY_PLANE,this.onPlayPlaneAnimation,false,0,true);
         addEventListener(MouseEvent.ROLL_OVER,this.onMouseEvent,true,0,true);
         addEventListener(MouseEvent.ROLL_OUT,this.onMouseEvent,true,0,true);
      }
      
      private function onCheckStatus(param1:Event) : void
      {
         var _loc2_:Session = Session.getInstance();
         var _loc3_:Boolean = false;
         var _loc4_:Boolean = false;
         var _loc5_:Boolean = false;
         var _loc6_:LandItemRender = null;
         var _loc7_:FarmLand = null;
         var _loc8_:int = 0;
         while(_loc8_ < this.m_items.length)
         {
            _loc6_ = this.m_items[_loc8_] as LandItemRender;
            _loc7_ = this.m_controller.model.getLandData(_loc6_.index);
            if(_loc7_ != null)
            {
               if(_loc3_ == false)
               {
                  _loc3_ = _loc7_.hasWeed;
               }
               if(_loc4_ == false)
               {
                  _loc4_ = _loc7_.hasPest;
               }
               if(_loc5_ == false)
               {
                  _loc5_ = _loc7_.needWater;
               }
            }
            _loc8_++;
         }
         this.m_controller.setNextAction(_loc3_,_loc4_,_loc5_);
         var _loc9_:uint = _loc2_.currentUserIdByUinMode;
         var _loc10_:uint = _loc2_.currentUser._uId;
         this.m_controller.module.app.dispatchEvent(new CommonEvent(Consts.MSG_REFRESH_FRIEND_STATUS,{
            "uId":_loc9_,
            "ownerId":_loc10_,
            "havest":false,
            "weed":_loc3_,
            "bug":_loc4_
         }));
      }
      
      private function onPlaneMoveIn() : void
      {
         var _loc1_:int = 0;
         var _loc2_:Number = NaN;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         this.m_controller.model.reloadAllLands(false);
         if(this._planeAnimation != null)
         {
            _loc1_ = stage.stageWidth * stage.stageWidth + stage.stageHeight * stage.stageHeight;
            _loc1_ = Math.sqrt(_loc1_);
            _loc1_ *= 0.5;
            _loc2_ = 26.6 * Math.PI / 180;
            _loc3_ = stage.stageWidth * 0.5 - _loc1_ * Math.cos(_loc2_);
            _loc4_ = stage.stageHeight * 0.5 - _loc1_ * Math.sin(_loc2_) - 50;
            TweenLite.to(this._planeAnimation,0.6,{
               "x":_loc3_,
               "y":_loc4_,
               "scaleX":0.3,
               "scaleY":0.3,
               "alpha":0.2,
               "delay":2.5,
               "onStart":this.onPlaneLeaving,
               "onComplete":this.onPlaneLeft
            });
         }
      }
      
      private function onAddHealth(param1:CommonEvent) : void
      {
         if(param1 == null || param1.data == null)
         {
            return;
         }
         var _loc2_:int = param1.data["index"] as int;
         if(_loc2_ < 0)
         {
            return;
         }
         var _loc3_:Number = Number(this.m_items[_loc2_].x);
         var _loc4_:Number = this.m_items[_loc2_].y + this.ITEM_TIP_OFFSET;
         var _loc5_:Point = localToGlobal(new Point(_loc3_,_loc4_));
         var _loc6_:Object = {
            "x":_loc5_.x,
            "y":_loc5_.y
         };
         this.m_controller.openFloat(Consts.FLOAT_TYPE_HEALTH,_loc6_);
      }
      
      public function talkRandom() : void
      {
         var _loc2_:int = 0;
         var _loc3_:LandItemRender = null;
         var _loc4_:FarmLand = null;
         var _loc5_:int = 0;
         var _loc6_:Object = null;
         var _loc7_:Boolean = false;
         var _loc8_:String = null;
         var _loc9_:Point = null;
         if(this.m_talk != null && this.m_talk.visible == true)
         {
            return;
         }
         var _loc1_:Number = Math.random();
         if(_loc1_ < 0.5)
         {
            return;
         }
         if(this.m_items != null && this.m_items.length > 0)
         {
            _loc2_ = int(Math.random() * this.m_items.length);
            _loc3_ = this.m_items[_loc2_] as LandItemRender;
            if(_loc3_ == null)
            {
               return;
            }
            _loc4_ = this.m_controller.model.getLandData(_loc3_.index);
            if(_loc4_ == null || _loc4_._step >= 7)
            {
               return;
            }
            _loc5_ = _loc4_._cId;
            _loc6_ = Settings.getInstance().getCropByID(_loc5_.toString());
            if(_loc6_ == null)
            {
               return;
            }
            _loc7_ = Boolean(_loc6_["isRed"]);
            if(_loc7_ == true && _loc6_["gossip"] != undefined)
            {
               _loc8_ = _loc6_["gossip"];
               if(_loc8_ != "")
               {
                  if(this.m_talk == null)
                  {
                     this.m_talk = new LandTalkTip(_loc3_);
                  }
                  else
                  {
                     this.m_talk.parent = _loc3_;
                  }
                  _loc9_ = new Point(60 * SCALE,10 * SCALE);
                  this.m_talk.startTalk(_loc8_,_loc9_,_loc3_.scaleX);
               }
            }
         }
      }
      
      public function loseMouse() : void
      {
         if(this.m_currentItem != null)
         {
            this.m_currentItem.filters = [];
         }
         this.m_currentItem = null;
         this.m_tipDelayTimer.stop();
         this.m_controller.hideTip();
      }
      
      private function onPlaneLeft() : void
      {
         if(this._planeAnimation != null)
         {
            this.stage.removeChild(this._planeAnimation);
            this._planeAnimation.stop();
            this._planeAnimation = null;
         }
         this.askSharePlane();
      }
      
      private function onOperateInvalid(param1:CommonEvent) : void
      {
         if(param1 == null || param1.data == null)
         {
            return;
         }
         var _loc2_:String = param1.data["text"] as String;
         var _loc3_:int = param1.data["index"] as int;
         var _loc4_:int = param1.data["yAdjust"] as int;
         this.openLandFloatTip(_loc2_,_loc3_,_loc4_);
      }
      
      public function openLandFloatTip(param1:String, param2:int, param3:int = 0) : void
      {
         if(param1 == "" || param2 < 0 || param2 >= this.m_items.length)
         {
            return;
         }
         var _loc4_:Number = this.m_items[param2].x + this.m_items[param2].width * 0.5;
         var _loc5_:Number = this.m_items[param2].y + this.ITEM_TIP_OFFSET;
         var _loc6_:Point = localToGlobal(new Point(_loc4_,_loc5_));
         var _loc7_:Boolean = Session.getInstance().me;
         var _loc8_:Object = {
            "text":param1,
            "me":_loc7_,
            "x":_loc6_.x,
            "y":_loc6_.y,
            "yAdjust":param3
         };
         this.m_controller.openFloat(Consts.FLOAT_TYPE_OPERATE,_loc8_);
      }
      
      public function showPickIcon(param1:Boolean, param2:Boolean = false) : void
      {
         var _loc15_:Object = null;
         var _loc3_:Session = Session.getInstance();
         if(param1 == true)
         {
            if(_loc3_.healthModeValid == true || _loc3_.currentFarmHealthModeValid == true)
            {
               if(this.m_pickIcon != null)
               {
                  this.m_pickIcon.remove();
               }
            }
         }
         var _loc4_:Boolean = false;
         var _loc5_:Boolean = false;
         var _loc6_:Boolean = false;
         var _loc7_:Boolean = false;
         var _loc8_:uint = _loc3_.currentUserIdByUinMode;
         var _loc9_:uint = _loc3_.currentUser._uId;
         var _loc10_:String = _loc3_.hostId;
         var _loc11_:LandItemRender = null;
         var _loc12_:FarmLand = null;
         var _loc13_:Array = [0,3,6,9,12,15,1,4,7,10,13,16,2,5,8,11,14,17,18,19,20,21,22,23];
         var _loc14_:int = 0;
         while(_loc14_ < _loc13_.length)
         {
            _loc11_ = this.m_items[_loc13_[_loc14_]] as LandItemRender;
            _loc12_ = this.m_controller.model.getLandData(_loc11_.index);
            if(_loc12_ != null)
            {
               if(_loc12_._step == 5 && !(_loc3_.healthModeValid == true || _loc3_.currentFarmHealthModeValid == true))
               {
                  _loc15_ = _loc12_._thief;
                  if(_loc15_ != null && _loc15_.hasOwnProperty(_loc10_) == false)
                  {
                     if(_loc12_._left > 0 && (_loc12_._left > _loc12_._min || _loc3_.me == true))
                     {
                        this.m_pickIcon.moveTo(_loc11_);
                        this.m_pickIcon.play();
                        _loc7_ = true;
                        if(_loc3_.m_welcomeMode == false)
                        {
                           this.m_controller.setHandCursor();
                        }
                        this.m_controller.module.app.dispatchEvent(new CommonEvent(Consts.MSG_LAND_CAN_PICK,{
                           "uId":_loc8_,
                           "ownerId":_loc9_
                        }));
                        return;
                     }
                  }
               }
               if(_loc4_ == false)
               {
                  _loc4_ = _loc12_.hasWeed;
               }
               if(_loc5_ == false)
               {
                  _loc5_ = _loc12_.hasPest;
               }
               if(_loc6_ == false)
               {
                  _loc6_ = _loc12_.needWater;
               }
            }
            _loc14_++;
         }
         if(this.m_pickIcon != null && _loc7_ == false)
         {
            this.m_pickIcon.stop();
         }
         this.m_controller.setNextAction(_loc4_,_loc5_,_loc6_);
         if(param2 == false)
         {
            this.m_controller.module.app.dispatchEvent(new CommonEvent(Consts.MSG_REFRESH_FRIEND_STATUS,{
               "uId":_loc8_,
               "ownerId":_loc9_,
               "havest":_loc7_,
               "weed":_loc4_,
               "bug":_loc5_,
               "check":true
            }));
         }
      }
      
      private function onHarvestData(param1:CommonEvent) : void
      {
         if(param1 == null || param1.data == null)
         {
            return;
         }
         var _loc2_:Object = param1.data;
         var _loc3_:int = int(_loc2_["index"]);
         if(_loc3_ < 0 || _loc3_ >= this.m_items.length)
         {
            return;
         }
         var _loc4_:FarmLand = this.m_controller.model.getLandData(_loc3_);
         if(_loc4_ == null)
         {
            return;
         }
         var _loc5_:int = _loc4_._cId;
         var _loc6_:Boolean = _loc4_._bitmap > 0 ? true : false;
         var _loc7_:String = "";
         var _loc8_:Object = Settings.getInstance().getCropByID(_loc5_.toString());
         if(_loc8_ != null && _loc8_["isAnimation"] == "1")
         {
            _loc7_ = Consts.FLOAT_TYPE_HAC;
         }
         else if(_loc2_["plus"] != undefined && _loc5_ > 0 && _loc6_ == true)
         {
            _loc7_ = Consts.FLOAT_TYPE_HAP;
         }
         else
         {
            _loc7_ = Consts.FLOAT_TYPE_HA;
         }
         var _loc9_:Number = Number(this.m_items[_loc3_].x);
         var _loc10_:Number = this.m_items[_loc3_].y + this.ITEM_TIP_OFFSET;
         var _loc11_:Point = localToGlobal(new Point(_loc9_,_loc10_));
         var _loc12_:Object = {
            "text":_loc2_["text"],
            "type":"1",
            "cId":_loc2_["cId"],
            "x":_loc11_.x,
            "y":_loc11_.y
         };
         this.m_controller.openFloat(_loc7_,_loc12_);
         this.showPickIcon(true);
      }
      
      public function checkCropLoaded() : Boolean
      {
         if(this.m_items == null || this.m_items.length == 0)
         {
            return true;
         }
         var _loc1_:LandItemRender = null;
         var _loc2_:uint = this.m_items.length;
         var _loc3_:int = 0;
         while(_loc3_ < _loc2_)
         {
            _loc1_ = this.m_items[_loc3_] as LandItemRender;
            if(_loc1_ != null && _loc1_.cropLoaded == false)
            {
               return false;
            }
            _loc3_++;
         }
         return true;
      }
      
      public function get landNum() : int
      {
         if(this.m_items == null)
         {
            return 0;
         }
         return this.m_items.length;
      }
      
      private function onAddedToStage(param1:Event) : void
      {
         removeEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage);
         this.registerListeners();
         this.createLandTiles(6,3);
         var _loc2_:LandItemRender = this.m_items[0];
         this.m_pickIcon = new LandPickIcon(this,_loc2_.x + 100,_loc2_.y - 70);
         this.m_tipDelayTimer = new Timer(100,1);
         this.m_tipDelayTimer.addEventListener(TimerEvent.TIMER,this.onMouseOverTimer,false,0,true);
      }
      
      private function onLandClicked() : void
      {
         if(this.m_currentItem == null || this.m_currentItem.waste == true)
         {
            return;
         }
         this.m_controller.clickOnLand(this.m_currentItem);
      }
      
      private function onShowPickIcon(param1:CommonEvent) : void
      {
         var _loc2_:Boolean = true;
         if(param1 != null && param1.data != null && param1.data["healthMode"] != undefined)
         {
            _loc2_ = param1.data["healthMode"] as Boolean;
         }
         this.showPickIcon(_loc2_);
      }
      
      public function playUpgradeRed(param1:int, param2:Sprite, param3:Object) : void
      {
         var fi:LandItemRender;
         var parent:DisplayObjectContainer = null;
         var index:int = param1;
         var animation:Sprite = param2;
         var data:Object = param3;
         if(animation == null || data == null)
         {
            return;
         }
         if(index < 0 || index >= this.m_items.length)
         {
            return;
         }
         fi = this.m_items[index] as LandItemRender;
         if(fi == null)
         {
            return;
         }
         animation.x = 100;
         animation.y = -70;
         animation.mouseChildren = false;
         animation.mouseEnabled = false;
         fi.addChild(animation);
         parent = this.stage;
         animation.addEventListener("end",function(param1:Event):void
         {
            var _loc5_:FarmLand = null;
            var _loc6_:int = 0;
            var _loc7_:Object = null;
            var _loc2_:LandItemRender = param1.currentTarget.parent as LandItemRender;
            param1.currentTarget.stop();
            _loc2_.removeChild(param1.currentTarget as DisplayObject);
            var _loc3_:int = data["red"] == true ? 1 : 0;
            _loc3_ = data["black"] == true ? 2 : _loc3_;
            var _loc4_:String = _loc3_ == 1 ? "红土地升级成功!" : "";
            _loc4_ = _loc3_ == 2 ? "黑土地升级成功!" : _loc4_;
            if(data["gold"] == true)
            {
               _loc4_ = "金牌土地升级成功!";
            }
            m_controller.openFloat(Consts.FLOAT_TYPE_TEXTTIP,{
               "text":_loc4_,
               "parent":parent
            });
            if(data["gold"] != true)
            {
               _loc5_ = m_controller.model.getLandData(index);
               if(_loc5_ != null)
               {
                  _loc6_ = _loc5_._cId;
                  _loc7_ = Settings.getInstance().getCropByID(_loc6_.toString());
                  if(_loc7_ != null)
                  {
                     if(_loc7_["isRed"] == "1")
                     {
                        openLandFloatTip("红土地,普通作物将增产10%!",index);
                     }
                     else if(_loc7_["isRed"] == "2")
                     {
                        openLandFloatTip("黑土地,普通和高级作物将提速20%!",index);
                     }
                  }
               }
            }
            if(data["gold"] == undefined)
            {
               m_controller.model.updateLandData(data["place"] as int,data["output"] as int,data["leavings"] as int,data["min"] as int,_loc3_,-1);
            }
            else
            {
               m_controller.model.updateLandData(data["place"] as int,data["output"] as int,data["leavings"] as int,data["min"] as int,_loc3_,data["gold"] == true ? 1 : 0);
            }
         });
      }
      
      private function onFarmLandChanged(param1:CommonEvent) : void
      {
         if(param1 == null || param1.data == null)
         {
            return;
         }
         if(this.m_items == null)
         {
            return;
         }
         var _loc2_:int = param1.data["index"] as int;
         if(_loc2_ < 0 || _loc2_ >= this.m_items.length)
         {
            return;
         }
         var _loc3_:LandItemRender = this.m_items[_loc2_] as LandItemRender;
         var _loc4_:FarmLand = this.m_controller.model.getLandData(_loc2_);
         this.updateLandItem(_loc3_,_loc4_);
         if(param1.data["animation"] == true)
         {
            this.playLandEffect(_loc3_);
         }
      }
      
      public function hideTalkTip() : void
      {
         if(this.m_talk == null)
         {
            return;
         }
         this.m_talk.stopTalk();
      }
      
      private function playLandEffect(param1:LandItemRender) : void
      {
         if(param1 == null)
         {
            return;
         }
         var _loc2_:MovieClip = Utils.getMaterial("LandCropEffect") as MovieClip;
         if(_loc2_ == null)
         {
            return;
         }
         _loc2_.x = 20 * scaleX;
         _loc2_.y = -17 * scaleY;
         param1.addChild(_loc2_);
         _loc2_.play();
      }
      
      private function onDataInitialized(param1:CommonEvent) : void
      {
         var _loc9_:Boolean = false;
         var _loc10_:String = null;
         if(param1 == null || param1.data == null)
         {
            return;
         }
         if(this.m_items == null || this.m_items.length == 0)
         {
            return;
         }
         var _loc2_:Boolean = Session.getInstance().me;
         var _loc3_:Array = param1.data as Array;
         var _loc4_:LandItemRender = null;
         var _loc5_:FarmLand = null;
         var _loc6_:int = 0;
         while(_loc6_ < this.m_items.length)
         {
            _loc4_ = this.m_items[_loc6_] as LandItemRender;
            _loc5_ = _loc3_[_loc6_] as FarmLand;
            _loc4_.index = _loc6_;
            if(_loc6_ < _loc3_.length)
            {
               _loc4_.waste = false;
               this.updateLandItem(_loc4_,_loc5_);
            }
            else
            {
               _loc4_.waste = true;
               _loc9_ = false;
               if(_loc3_.length == _loc6_)
               {
                  if(_loc2_ == true)
                  {
                     _loc9_ = true;
                  }
               }
               _loc4_.reclaim = _loc9_;
            }
            _loc6_++;
         }
         var _loc7_:Boolean = true;
         var _loc8_:BaseLayer = this.m_controller.module.app.farmView.getLayerByName(Consts.LAYER_TOOLS);
         if(_loc8_ != null && _loc8_.hitTestPoint(mouseX,mouseY) == true)
         {
            _loc7_ = false;
         }
         if(_loc7_ == true && Session.getInstance().isInWildStage == false)
         {
            this.showPickIcon(true);
            _loc10_ = this.m_controller.module.app.farmView.cursorCtrl.name;
            if(_loc10_ == null || _loc10_ == "")
            {
               this.m_controller.module.app.farmView.cursorCtrl.setCursor(Consts.CURSOR_STYLE_ARROW);
            }
         }
      }
      
      private function onPlaneLeaving() : void
      {
      }
      
      private function askSharePlane() : void
      {
         var onPlaneShareConfirmed:Function = null;
         onPlaneShareConfirmed = function():void
         {
            var _loc1_:String = "mod=cgi_qzshare_onekey";
            _loc1_ += "url=" + encodeURIComponent("");
            _loc1_ += "&desc=" + encodeURIComponent("");
            _loc1_ += "&summary=" + encodeURIComponent("我已经使用了飞机施肥，真的一下子全熟了！感觉爽翻~你也快来体验呐！");
            _loc1_ += "&title=" + encodeURIComponent("飞机施肥，一键全熟！");
            _loc1_ += "&site=" + encodeURIComponent("QQ农场");
            _loc1_ += "&pics=" + encodeURIComponent("module/ui/icons/planeshare.jpg");
            QzoneJSAPI.openWindow(_loc1_);
         };
         this.m_controller.openWindow(Consts.WINDOW_NAME_CONFIRM,{
            "title":"分享喜悦？",
            "width":320,
            "height":310,
            "customIcon":"PlaneConfirmIcon",
            "text":"我已经使用了飞机施肥，一键全熟！<BR/>一下子成熟的感觉好极了！",
            "confirmFn":onPlaneShareConfirmed
         });
      }
      
      private function onMouseOverTimer(param1:TimerEvent) : void
      {
         if(param1 == null || this.m_currentItem == null)
         {
            return;
         }
         if(this.m_currentItem.waste == true)
         {
            return;
         }
         this.m_currentItem.filters = this.m_overFilters;
         var _loc2_:int = this.m_currentItem.index;
         var _loc3_:FarmLand = this.m_controller.model.getLandData(_loc2_);
         if(_loc3_ != null)
         {
            this.m_controller.showTip(Consts.TIP_NAME_LAND_INFOR,_loc3_);
         }
      }
      
      private function onMouseEvent(param1:MouseEvent) : void
      {
         var _loc4_:LandItemRender = null;
         if(param1 == null || param1.target == null)
         {
            return;
         }
         var _loc2_:CursorControl = null;
         if(this.m_controller.module != null && this.m_controller.module.app != null)
         {
            _loc2_ = this.m_controller.module.app.farmView.cursorCtrl;
         }
         if(_loc2_ == null || _loc2_.name == Consts.CURSOR_STYLE_FISHNET)
         {
            return;
         }
         if(_loc2_.name == Consts.CURSOR_STYLE_TOOL)
         {
            if(_loc2_.cursorArgument.indexOf(Consts.ITEM_TYPE_FISHFEED + ",") != -1)
            {
               return;
            }
         }
         else if(_loc2_.name == Consts.CURSOR_STYLE_CROPSEED)
         {
            if(_loc2_.cursorArgument.indexOf(Consts.ITEM_TYPE_FISH + ",") != -1)
            {
               return;
            }
         }
         var _loc3_:String = param1.target.name;
         if(param1.type == MouseEvent.ROLL_OVER)
         {
            if(_loc3_ == "__reclaim__")
            {
               this.m_controller.useSystemCursor(true);
            }
            else if(_loc3_.indexOf("__FarmlandItem__") != -1)
            {
               this.m_currentItem = param1.target as LandItemRender;
               this.m_tipDelayTimer.reset();
               this.m_tipDelayTimer.start();
            }
         }
         else if(param1.type == MouseEvent.ROLL_OUT)
         {
            if(_loc3_ == "__reclaim__")
            {
               this.m_controller.useSystemCursor(false);
            }
            else if(_loc3_.indexOf("__FarmlandItem__") != -1)
            {
               this.loseMouse();
            }
         }
         else if(param1.type == MouseEvent.CLICK)
         {
            _loc3_ = param1.target.name;
            if(_loc3_ == "__reclaim__")
            {
               _loc4_ = param1.target.parent as LandItemRender;
               this.onReclaimClicked(_loc4_);
            }
            else
            {
               _loc3_ = param1.currentTarget.name;
               if(_loc3_.indexOf("__FarmlandItem__") != -1)
               {
                  this.m_currentItem = param1.currentTarget as LandItemRender;
                  this.onLandClicked();
               }
            }
         }
      }
   }
}

