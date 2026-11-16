package module.uitools.widgets
{
   import com.qzone.allianceActivity.framewrok.manager.ClickReportManager;
   import com.qzone.qui.containers.boxClasses.Box;
   import com.qzone.qui.controls.scrollClasses.ScrollPolicy;
   import com.qzone.qui.core.Align;
   import com.qzone.qui.core.Direction;
   import com.qzone.qui.managers.PopUpManager;
   import common.CommonData;
   import common.Consts;
   import common.Language;
   import common.Session;
   import common.Settings;
   import common.misc.Cookies;
   import common.misc.QzoneJSAPI;
   import common.misc.Utils;
   import common.view.window.PostWindow;
   import entities.Player;
   import events.CommonEvent;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.Loader;
   import flash.display.LoaderInfo;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.IOErrorEvent;
   import flash.events.MouseEvent;
   import flash.external.ExternalInterface;
   import flash.net.URLRequest;
   import flash.system.ApplicationDomain;
   import flash.system.LoaderContext;
   import flash.system.SecurityDomain;
   import flash.utils.clearTimeout;
   import flash.utils.setTimeout;
   import framework.api.PluginManager;
   import framework.net.protocol.Protocol;
   import module.mainScene.npc.MonthEnd.MonthEndWin;
   import module.uitools.UIController;
   import module.uitools.UIToolsModel;
   import module.uitools.vo.OfflineData;
   import report.ClickReportManager;
   import report.EventRecorder;
   
   public class ShortcutBar extends Box
   {
      
      private var m_postWindow:PostWindow;
      
      private var _isNewUser:int;
      
      private var _gift:int = 0;
      
      private var monthend_timer:uint;
      
      private var _monthEndWin:MonthEndWin;
      
      private var m_controller:UIController;
      
      private var m_offlineMsg:int = 1;
      
      public function ShortcutBar(param1:UIController)
      {
         super(600,62);
         x = 5;
         y = 68;
         alignH = Align.LEFT;
         gapH = 0;
         gapV = 0;
         direction = Direction.HORIZONTAL;
         _vScrollPolicy = ScrollPolicy.OFF;
         backgroundAlpha = 0;
         defaultSkin = null;
         this.m_postWindow = null;
         this.m_controller = param1;
         this.createView();
         this.amountPlugins();
         addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver,false,0,true);
         addEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut,false,0,true);
         addEventListener(MouseEvent.CLICK,this.onClicked,false,0,true);
         this.m_controller.module.app.addEventListener(Consts.MY_FLOWER_LOADED,this.onMyFlowerLoaded,false,0,true);
         this.m_controller.module.app.addEventListener(Consts.DELEVE_NEW_ICON,this.removeNewIconTip,false,0,true);
         this.m_controller.module.app.addEventListener(Consts.MSG_REMOVE_SHORTCUT_ICON,this.onRemoveIcon,false,0,true);
         this.m_controller.module.app.addEventListener(Consts.ADD_ENTRANCE_ICON,this.addEntranceIcon,false,0,true);
         var _loc2_:EventDispatcher = this.m_controller.model as EventDispatcher;
         _loc2_.addEventListener(UIToolsModel.EVENT_OFFLINE_DATA_CHANGED,this.onDataChanged,false,0,true);
         _loc2_.addEventListener(UIToolsModel.EVENT_EVERYDAY_GIFT_LOADED,this.onEverydayGiftLoaded,false,0,true);
         _loc2_.addEventListener(UIToolsModel.EVENT_OFFLINE_DATA_MSG,this.onOfflineDataMessageLoaded,false,0,true);
         _loc2_.addEventListener(UIToolsModel.GET_VIPRETURN_GIFT,this.onGetVipReturnGift,false,0,true);
         _loc2_.addEventListener(UIToolsModel.EVENT_SHOW_WARNMSG,this.onShowWarnMsg,false,0,true);
         _loc2_.addEventListener(UIToolsModel.EVENT_LEVELUP_CHANGED,this.onLevelUp,false,0,true);
      }
      
      private function isNewUserToday() : Boolean
      {
         var _loc1_:Boolean = false;
         if(Cookies.getObject("new_user_" + Session.getInstance().host._uId) == null)
         {
            return false;
         }
         var _loc2_:Date = new Date(CommonData.serverTime * 1000);
         var _loc3_:Date = new Date(Number(Cookies.getObject("new_user_" + Session.getInstance().host._uId)) * 1000);
         if(_loc2_.getFullYear() == _loc3_.getFullYear())
         {
            if(_loc2_.getMonth() == _loc3_.getMonth())
            {
               if(_loc2_.getDate() == _loc3_.getDate())
               {
                  _loc1_ = true;
               }
            }
         }
         return _loc1_;
      }
      
      private function createView() : void
      {
         enableValidate = false;
         if(Settings.getInstance().mode != "" && QzoneJSAPI.QPLUS == false && QzoneJSAPI.WB == false)
         {
            this.m_controller.model.loadFreeData();
         }
         if(Settings.getInstance().isGiftTime())
         {
            this.monthend_timer = setTimeout(this.monthEndFn,1000);
         }
         enableValidate = true;
         validateNow();
      }
      
      private function onGetVipReturnGift(param1:CommonEvent) : void
      {
         this.gift = Session.getInstance().isVipReturn == true ? 1 : 0;
      }
      
      private function onTeBuCallback(param1:*) : void
      {
         if(param1 as Boolean == true)
         {
            this.m_controller.module.app.dispatchEvent(new CommonEvent(Consts.DATA_CROP_RELOAD_FLAG,null));
            this.m_controller.module.app.dispatchEvent(new CommonEvent(Consts.DATA_BAG_RELOAD_FLAG,null));
         }
      }
      
      private function giftWindowConfirmHandler() : void
      {
         if(Session.getInstance().isVipReturn)
         {
            this.m_controller.model.acceptGifts(true);
         }
         else
         {
            this.m_controller.model.acceptGifts(false);
         }
         this.gift = 2;
         this.adjustLayout();
      }
      
      private function onDataChanged(param1:CommonEvent) : void
      {
         if(param1 == null || param1.data == null)
         {
            return;
         }
         var _loc2_:OfflineData = param1.data as OfflineData;
         if(_loc2_ == null)
         {
            return;
         }
         this.msg = _loc2_.m_msgNum > 0 ? true : false;
         if(this.isNewUserToday())
         {
            this.gift = 2;
         }
         else
         {
            this.gift = _loc2_.m_giftNum > 0 || Session.getInstance().isVipReturn ? 1 : 0;
         }
         this._isNewUser = _loc2_.m_giftNum;
         this.flower = _loc2_.m_flowerNum > 0 ? true : false;
      }
      
      private function removeNewIconTip(param1:CommonEvent) : void
      {
         var _loc2_:MovieClip = this.getChildByName("__newicontip__") as MovieClip;
         if(_loc2_)
         {
            this.removeChild(_loc2_);
            _loc2_ = null;
         }
      }
      
      private function monthEndClick() : void
      {
         var _loc1_:MovieClip = null;
         if(!this._monthEndWin)
         {
            this._monthEndWin = new MonthEndWin(this.m_controller);
            _loc1_ = this.getChildByName("__monthendarrow__") as MovieClip;
            if(_loc1_)
            {
               removeChild(_loc1_);
               _loc1_ = null;
            }
            Cookies.setObject("monthend_" + Session.getInstance().host._uId,CommonData.serverTime);
         }
         PopUpManager.addPopUp(this._monthEndWin,true);
         this._monthEndWin.openWindows();
      }
      
      private function loadAdvertiseIcon(param1:String, param2:Function, param3:Function) : void
      {
         if(param1 == "" || param1 == null)
         {
            return;
         }
         param1 = Settings.getInstance().replaceAppImg(param1);
         var _loc4_:Loader = new Loader();
         _loc4_.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,param3);
         _loc4_.contentLoaderInfo.addEventListener(IOErrorEvent.NETWORK_ERROR,param3);
         _loc4_.contentLoaderInfo.addEventListener(Event.COMPLETE,param2);
         _loc4_.load(new URLRequest(param1),new LoaderContext(true,ApplicationDomain.currentDomain,SecurityDomain.currentDomain));
      }
      
      private function addEntranceIcon(param1:CommonEvent) : void
      {
         addElement(param1.data as DisplayObject);
      }
      
      private function onMyFlowerLoaded(param1:Event) : void
      {
         this.flower = false;
         this.adjustLayout();
      }
      
      private function onEverydayGiftLoaded(param1:CommonEvent) : void
      {
         if(param1 == null || param1.data == null)
         {
            return;
         }
         var _loc2_:Object = param1.data;
         _loc2_["big"] = false;
         _loc2_["confirmHandler"] = this.giftWindowConfirmHandler;
         this.m_controller.openWindow(Consts.WINDOW_NAME_GIFT,_loc2_);
      }
      
      private function onClicked(param1:MouseEvent) : void
      {
         var _loc3_:String = null;
         var _loc4_:* = undefined;
         var _loc5_:String = null;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc8_:String = null;
         if(param1 == null || param1.target == null)
         {
            return;
         }
         var _loc2_:String = param1.target.name;
         if(_loc2_ == "__gift__")
         {
            if(this._isNewUser == 2)
            {
               _loc4_ = this.m_controller.model.loadEveryDayGift();
               if(_loc4_ != null)
               {
                  _loc4_["big"] = false;
                  _loc4_["confirmHandler"] = this.giftWindowConfirmHandler;
                  this.m_controller.openWindow(Consts.WINDOW_NAME_GIFT,_loc4_);
               }
            }
            else
            {
               this.showYellowPackage(this._gift > 0);
            }
            report.ClickReportManager.reportClick("left.banner.icon_huang_zuan.click");
         }
         else if(_loc2_ == "__flower__")
         {
            this.m_controller.module.app.dispatchEvent(new CommonEvent(Consts.MSG_SHOW_WAREHOUSE,{"openWithFlower":true}));
         }
         else if(_loc2_ == "__levelup__")
         {
            if(this.m_controller.model.drawLevelUpGift() == true)
            {
               this.m_controller.model.addEventListener(UIToolsModel.EVENT_LEVELUP_GIFTS,this.onLevelUpGift,false,0,true);
            }
         }
         else if(_loc2_ == "__monthEnd__")
         {
            this.monthEndClick();
         }
         else if(_loc2_ == "__security__")
         {
            _loc5_ = Settings.getInstance().getStringAttribute("QQSecurity_CMD");
            if(_loc5_ != "" && ExternalInterface.available)
            {
               _loc6_ = 369;
               _loc7_ = 550;
               _loc6_ = parseInt(Settings.getInstance().getStringAttribute("QQSecurity_width"));
               _loc7_ = parseInt(Settings.getInstance().getStringAttribute("QQSecurity_height"));
               ExternalInterface.call("QZFL.dialog.create","电脑管家农牧场主题活动",_loc5_,{
                  "width":_loc6_,
                  "height":_loc7_
               });
               EventRecorder.recordSueecssEvent("160645",null,null);
            }
         }
         else if(_loc2_ == "__alarmClock__")
         {
            _loc8_ = Settings.getInstance().getStringAttribute("QQAlarmClock_CMD");
            if(_loc8_ != "" && ExternalInterface.available)
            {
               ExternalInterface.call(_loc8_);
               EventRecorder.recordSueecssEvent("160649",null,null);
               Session.getInstance().addReward([{
                  "type":"1",
                  "num":1
               }]);
            }
         }
         else if(_loc2_ == "__KFC__")
         {
            _loc3_ = "";
            if(Settings.getInstance().mode == "")
            {
               _loc3_ = "";
            }
            ExternalInterface.call("QZFL.dialog.create(\'\'," + "\'<iframe src=" + _loc3_ + "&id=0" + " style=\"width:434px; height:394px; border:0px\" scrolling=no border=0 frameBorder=no allowTransparency=true></iframe>\', {width:434,height:396,noBorder:true})");
            com.qzone.allianceActivity.framewrok.manager.ClickReportManager.reportClick("KFC_Click_Icon_NC");
         }
         else if(_loc2_ == "_teBu_")
         {
            if(Settings.getInstance().mode == "")
            {
               _loc3_ = "";
            }
            else
            {
               _loc3_ = "";
            }
            CommonData.addCallBackProxy("getGiftBack",this.onTeBuCallback);
            ExternalInterface.call("QZFL.dialog.create(\'\'," + "\'<iframe src=" + _loc3_ + "&id=1" + " style=\"width:630px; height:460.5px; border:0px\" scrolling=no border=0 frameBorder=no allowTransparency=true></iframe>\', {width:630,height:460.5,noBorder:true})");
            com.qzone.allianceActivity.framewrok.manager.ClickReportManager.reportClick("TeBu_Click_Icon_NC");
         }
      }
      
      private function adjustLayout() : void
      {
         var _loc3_:int = 0;
         if(content == null)
         {
            return;
         }
         var _loc1_:Array = [];
         var _loc2_:DisplayObject = null;
         while(_loc3_ < content.numChildren)
         {
            _loc2_ = content.getChildAt(_loc3_);
            _loc1_.push(_loc2_);
            _loc3_++;
         }
         enableValidate = false;
         removeAllElements();
         for each(_loc2_ in _loc1_)
         {
            addElement(_loc2_);
         }
         enableValidate = true;
         validateNow();
      }
      
      private function openPostWindow() : void
      {
         var _loc2_:MovieClip = null;
         var _loc3_:String = null;
         var _loc4_:String = null;
         var _loc1_:* = this.m_controller.model.loadPostData();
         if(_loc1_ != null)
         {
            if(_loc1_["content"] != undefined)
            {
               _loc3_ = _loc1_["content"] as String;
               if(_loc3_ == "" || _loc3_ == null)
               {
                  return;
               }
               if(this.m_postWindow == null)
               {
                  this.m_postWindow = new PostWindow(null,Language.L["确定"]);
                  this.m_postWindow.title = "";
                  this.m_postWindow.closeFn = this.onPostWindowClosed;
               }
               this.m_postWindow.text = _loc3_;
               this.m_controller.module.app.farmView.winCtrl.open(this.m_postWindow);
               this.m_controller.module.app.useSystemCursor(true);
               Cookies.setObject("postText",_loc3_);
               Cookies.setObject("postClicked",true);
            }
            else if(_loc1_["imageurl"] != undefined)
            {
               _loc4_ = _loc1_["imageurl"] as String;
               if(_loc4_ == "" || _loc4_ == null)
               {
                  return;
               }
               if(this.m_postWindow == null)
               {
                  this.m_postWindow = new PostWindow(null,Language.L["确定"]);
                  this.m_postWindow.title = "";
                  this.m_postWindow.closeFn = this.onPostWindowClosed;
               }
               this.m_postWindow.imgUrl = _loc4_;
               this.m_controller.module.app.farmView.winCtrl.open(this.m_postWindow);
               this.m_controller.module.app.useSystemCursor(true);
               Cookies.setObject("postImage",_loc4_);
               Cookies.setObject("postImageClicked",true);
            }
            EventRecorder.recordSueecssEvent(EventRecorder.HF_POSTVIEW,0);
            _loc2_ = content.getChildByName("__post__") as MovieClip;
            _loc2_.gotoAndStop(1);
         }
      }
      
      private function amountPlugins() : void
      {
         var self:ShortcutBar = null;
         var loadTeBu:Function = null;
         var teBuLoaded:Function = null;
         var loadComplete:Function = null;
         var errorHandler:Function = null;
         loadTeBu = function(param1:int, param2:*):void
         {
            if(Boolean(param2) && Boolean(param2["code"] == 1) && param2["ecode"] == 0)
            {
               loadAdvertiseIcon("module/ui/teBuRes.swf",teBuLoaded,errorHandler);
            }
         };
         teBuLoaded = function(param1:Event):void
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
            addElement(_loc2_);
         };
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
            addElement(_loc2_);
         };
         errorHandler = function(param1:IOErrorEvent):void
         {
         };
         self = this;
         setTimeout(function():void
         {
            var _loc1_:Settings = null;
            var _loc2_:String = null;
            var _loc3_:Array = null;
            var _loc4_:Date = null;
            var _loc5_:Date = null;
            var _loc6_:Number = NaN;
            var _loc7_:String = null;
            var _loc8_:Settings = null;
            var _loc9_:String = null;
            PluginManager.getInstance().amountPlugins(Consts.PLUGIN_AMOUNT_SHORTCUT,self,null);
            if(QzoneJSAPI.QPLUS == false && QzoneJSAPI.WB == false)
            {
               _loc1_ = Settings.getInstance();
               _loc2_ = _loc1_.getStringAttribute("kfc");
               if(_loc2_ == null || _loc2_ == "")
               {
                  return;
               }
               _loc3_ = _loc2_.split("-");
               _loc4_ = new Date(_loc3_[0]);
               _loc5_ = new Date(_loc3_[1]);
               _loc6_ = CommonData.serverTime * 1000;
               if(_loc6_ >= _loc4_.time && _loc6_ <= _loc5_.time)
               {
                  loadAdvertiseIcon("module/ui/kfc.swf",loadComplete,errorHandler);
               }
               _loc7_ = _loc1_.getStringAttribute("teBu");
               if(_loc7_ == null || _loc7_ == "")
               {
                  return;
               }
               _loc3_ = _loc7_.split("-");
               _loc4_ = new Date(_loc3_[0]);
               _loc5_ = new Date(_loc3_[1]);
               _loc6_ = CommonData.serverTime * 1000;
               if(_loc6_ >= _loc4_.time && _loc6_ <= _loc5_.time)
               {
                  _loc8_ = Settings.getInstance();
                  _loc9_ = _loc8_.mode;
                  if(_loc9_ == "qplus")
                  {
                     _loc9_ = "qzone";
                  }
                  if(!PluginManager.getInstance().api)
                  {
                     return;
                  }
                  PluginManager.getInstance().api.registerNetCommand(16001,"" + _loc9_ + "mod=cgi_farm_get_bit?bit=7",null);
                  PluginManager.getInstance().api.sendRequest(16001,{},loadTeBu,null);
               }
            }
         },3000);
      }
      
      public function set msg(param1:Boolean) : void
      {
      }
      
      private function onLevelUp(param1:CommonEvent) : void
      {
         if(param1 == null || param1.data == null)
         {
            return;
         }
         var _loc2_:MovieClip = content.getChildByName("__levelup__") as MovieClip;
         var _loc3_:Array = param1.data as Array;
         if(_loc3_ == null || _loc3_.length == 0)
         {
            if(_loc2_ == null)
            {
               return;
            }
            removeElement(_loc2_);
            this.adjustLayout();
         }
         else if(_loc2_ == null)
         {
            _loc2_ = Utils.getMaterial("LevelUpIcon") as MovieClip;
            _loc2_.name = "__levelup__";
            _loc2_.buttonMode = true;
            _loc2_.stop();
            addElement(_loc2_);
         }
      }
      
      private function onMouseOut(param1:MouseEvent) : void
      {
         this.m_controller.hideTip();
      }
      
      private function monthEndFn() : void
      {
         var monthEnd:MovieClip;
         var arrow:MovieClip = null;
         clearTimeout(this.monthend_timer);
         monthEnd = content.getChildByName("__monthEnd__") as MovieClip;
         if(monthEnd == null)
         {
            monthEnd = Utils.getMaterial("MonthEndIcon") as MovieClip;
            if(monthEnd != null)
            {
               monthEnd.name = "__monthEnd__";
               monthEnd.mouseChildren = false;
               monthEnd.buttonMode = true;
               addElement(monthEnd);
               if(CommonData.isMonthEndToday(Session.getInstance().host._uId))
               {
                  arrow = this.getChildByName("__monthendarrow__") as MovieClip;
                  if(arrow == null)
                  {
                     arrow = Utils.getMaterial("monthEndArrow") as MovieClip;
                     arrow.name = "__monthendarrow__";
                     if(Settings.getInstance().getMonthEnds("0","month"))
                     {
                        arrow.tipMc.tip.text = Settings.getInstance().getMonthEnds("0","month") + "礼包\n火热促销中";
                     }
                     else
                     {
                        arrow.tipMc.tip.text = "月末大礼包\n火热促销中";
                     }
                     addChild(arrow);
                  }
                  arrow.x = monthEnd.x + 35;
                  arrow.y = monthEnd.y + 30;
                  arrow.mouseEnabled = false;
                  setTimeout(function():void
                  {
                     if(Boolean(arrow) && Boolean(arrow.parent))
                     {
                        arrow.parent.removeChild(arrow);
                        arrow = null;
                     }
                  },5000);
               }
            }
         }
      }
      
      private function onRemoveIcon(param1:CommonEvent) : void
      {
         var _loc2_:DisplayObjectContainer = param1.data as DisplayObjectContainer;
         if(_loc2_ == null)
         {
            return;
         }
         removeElement(_loc2_);
         this.adjustLayout();
      }
      
      public function set gift(param1:int) : void
      {
         this._gift = param1;
         var _loc2_:MovieClip = null;
         if(QzoneJSAPI.QPLUS == true || QzoneJSAPI.WB == true)
         {
            return;
         }
         _loc2_ = content.getChildByName("__gift__") as MovieClip;
         if(_loc2_ == null)
         {
            _loc2_ = Utils.getMaterial("GiftIcon") as MovieClip;
            _loc2_.name = "__gift__";
            _loc2_.buttonMode = true;
            addElement(_loc2_);
         }
         if(param1 == 1)
         {
            if(Session.getInstance().host._yellowstatus.toString() != "0")
            {
               _loc2_.gotoAndPlay("GiftMove");
               return;
            }
            _loc2_.gotoAndStop(2);
         }
         else if(param1 == 2)
         {
            removeElement(_loc2_);
            this.adjustLayout();
         }
         else
         {
            if(Session.getInstance().host._yellowstatus.toString() != "0")
            {
               _loc2_.gotoAndStop(1);
               return;
            }
            _loc2_.gotoAndStop(2);
         }
      }
      
      private function showYellowPackage(param1:Boolean) : void
      {
         var _loc5_:String = null;
         var _loc6_:String = null;
         var _loc7_:String = null;
         var _loc2_:Session = Session.getInstance();
         var _loc3_:String = "";
         if(CommonData.getKey != null)
         {
            _loc3_ = CommonData.getKey();
         }
         var _loc4_:String = CommonData.serverTime.toString();
         if(Settings.getInstance().mode == "qzone")
         {
            _loc6_ = Protocol._userUin;
            _loc7_ = _loc2_.hostUin;
         }
         _loc5_ = "farmKey=" + _loc3_ + "&farmTime=" + _loc4_ + "&uIdx=" + _loc2_.hostId + "&uinX=" + _loc6_ + "&uinY=" + _loc7_;
         CommonData.addCallBackProxy("getGiftBack",this.setGiftData);
         var _loc8_:Player = _loc2_.host;
         if(_loc8_._yellowstatus != 0)
         {
            QzoneJSAPI.showVIPPackage(Consts.APP_ID,param1 == true ? false : true,_loc5_,_loc8_._yellowstatus,_loc8_._yellowlevel);
         }
         else
         {
            QzoneJSAPI.showVIPPackage(Consts.APP_ID,false,_loc5_,_loc8_._yellowstatus,_loc8_._yellowlevel);
         }
      }
      
      public function set flower(param1:Boolean) : void
      {
         var _loc2_:Sprite = content.getChildByName("__flower__") as Sprite;
         if(param1 == true)
         {
            if(_loc2_ == null)
            {
               _loc2_ = Utils.getMaterial("FlowerIcon") as Sprite;
               _loc2_.name = "__flower__";
               _loc2_.mouseChildren = false;
               _loc2_.buttonMode = true;
               addElement(_loc2_);
            }
         }
         else if(_loc2_ != null)
         {
            removeElement(_loc2_);
         }
      }
      
      private function onLevelUpGift(param1:CommonEvent) : void
      {
         if(param1 == null || param1.data == null)
         {
            return;
         }
         var _loc2_:* = param1.data;
         var _loc3_:Array = new Array();
         if(_loc2_.hasOwnProperty("item") == true)
         {
            _loc2_["big"] = false;
            this.m_controller.module.app.openWindowByName(Consts.WINDOW_NAME_GIFT,_loc2_);
            this.m_controller.module.app.hideTip();
            _loc3_ = _loc3_.concat(_loc2_["item"]);
         }
         if(_loc2_.hasOwnProperty("vipItem") == true && _loc2_["vipItem"] != false)
         {
            _loc3_ = _loc3_.concat(_loc2_["vipItem"]);
         }
         Session.getInstance().addReward(_loc3_);
      }
      
      private function onMouseOver(param1:MouseEvent) : void
      {
         if(param1 == null || param1.target == null)
         {
            return;
         }
         var _loc2_:String = param1.target.name;
         if(_loc2_ == "__gift__")
         {
            this.m_controller.showTip(Consts.TIP_NAME_MOUSE,"礼包");
         }
         else if(_loc2_ == "__flower__")
         {
            this.m_controller.showTip(Consts.TIP_NAME_MOUSE,"收到鲜花");
         }
         else if(_loc2_ == "__levelup__")
         {
            this.m_controller.showTip(Consts.TIP_NAME_MOUSE,"领取升级礼包");
         }
         else if(_loc2_ == "__monthEnd__")
         {
            if(Settings.getInstance().getMonthEnds("0","month"))
            {
               this.m_controller.showTip(Consts.TIP_NAME_MOUSE,Settings.getInstance().getMonthEnds("0","month") + "大礼包");
            }
            else
            {
               this.m_controller.showTip(Consts.TIP_NAME_MOUSE,"大礼包");
            }
         }
         else if(_loc2_ == "__security__")
         {
            this.m_controller.showTip(Consts.TIP_NAME_MOUSE,"安装管家送管家精灵狗");
         }
         else if(_loc2_ == "__alarmClock__")
         {
            this.m_controller.showTip(Consts.TIP_NAME_MOUSE,"安装QQ闹钟送大礼");
         }
         else if(_loc2_ == "__KFC__")
         {
            this.m_controller.showTip(Consts.TIP_NAME_MOUSE,"KFC有料同享 第二杯半价");
         }
         else if(_loc2_ == "_teBu_")
         {
            this.m_controller.showTip(Consts.TIP_NAME_MOUSE,"特步，趣跑无限");
         }
      }
      
      private function onPostWindowClosed(param1:Event) : void
      {
         this.m_controller.module.app.useSystemCursor(false);
      }
      
      public function setGiftData(param1:Object) : void
      {
         var _loc4_:Object = null;
         var _loc5_:String = null;
         this.gift = 0;
         var _loc2_:Array = [];
         var _loc3_:Array = [];
         if(param1["item"] != undefined && param1["item"] != null)
         {
            if(param1["item"] is Array)
            {
               _loc2_ = _loc2_.concat(param1["item"]);
            }
            else
            {
               _loc4_ = param1["item"];
               for(_loc5_ in _loc4_)
               {
                  _loc3_.push(_loc4_[_loc5_]);
               }
               _loc2_ = _loc2_.concat(_loc3_);
            }
         }
         if(param1.hasOwnProperty("vipItem") == true && param1["vipItem"] != undefined)
         {
            if(param1["vipItem"] is Array)
            {
               _loc2_ = _loc2_.concat(param1["vipItem"][0] != undefined ? param1["vipItem"][0] : param1["vipItem"]);
            }
            else
            {
               _loc4_ = param1["vipItem"];
               for(_loc5_ in _loc4_)
               {
                  _loc3_.push(_loc4_[_loc5_]);
               }
               _loc2_ = _loc2_.concat(_loc3_);
            }
         }
         Session.getInstance().addReward(_loc2_);
      }
      
      private function onOfflineDataMessageLoaded(param1:CommonEvent) : void
      {
         if(param1 == null || param1.data == null)
         {
            return;
         }
         this.m_offlineMsg = param1.data as int;
      }
      
      private function onShowWarnMsg(param1:CommonEvent) : void
      {
         this.openPostWindow();
         EventRecorder.recordErrorEvent(EventRecorder.CHEAT_FARM,0,EventRecorder.SUEECSS);
      }
   }
}

