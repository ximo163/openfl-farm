package module.levelup
{
   import com.qzone.corelib.net.RSLLoader;
   import com.qzone.qui.managers.PopUpManager;
   import common.CommonData;
   import common.Settings;
   import common.misc.QzoneJSAPI;
   import common.misc.Utils;
   import entities.Seed;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.external.ExternalInterface;
   import module.FarmApplication;
   import report.ClickReportManager;
   
   public class LevelUpWindow extends Sprite
   {
      
      private static const LAND_AND_SEEDS:int = 1;
      
      private static const ONLY_SEEDS:int = 2;
      
      private static const ONLY_LAND:int = 3;
      
      private static const ONLY_LAND_NEXT:int = 4;
      
      private static const ONLY_TEXT:int = 5;
      
      private var _shareType:int;
      
      private var _level:int;
      
      private var _newSeedsInfo:Array;
      
      private var _landInfo:Object;
      
      private var _panelUI:Sprite;
      
      private var _app:FarmApplication;
      
      private var _model:LevelUpModel;
      
      private var _panelClass:Class;
      
      public function LevelUpWindow(param1:int, param2:LevelUpModel, param3:FarmApplication)
      {
         super();
         this._level = param1;
         this._model = param2;
         this._app = param3;
         this.initData();
         this.initUI();
      }
      
      private function getLandTip() : String
      {
         var _loc1_:String = "<font color=\'#666666\'>升级后，可扩建";
         var _loc2_:String = "";
         if(this._landInfo.normal)
         {
            _loc2_ = this.addComma(_loc2_,"黄土地<font color=\'#FF6600\'>1</font>块");
         }
         if(this._landInfo.red)
         {
            _loc2_ = this.addComma(_loc2_,"红土地<font color=\'#FF6600\'>1</font>块");
         }
         if(this._landInfo.black)
         {
            _loc2_ = this.addComma(_loc2_,"黑土地<font color=\'#FF6600\'>1</font>块");
         }
         return _loc1_ + _loc2_ + "</font>";
      }
      
      private function createSeedsView(param1:Sprite, param2:Boolean) : void
      {
         var _loc4_:SeedItemRender = null;
         var _loc5_:int = 0;
         var _loc7_:Sprite = null;
         var _loc3_:Sprite = new Sprite();
         var _loc6_:Sprite = new Sprite();
         var _loc8_:int = param2 ? 5 : 6;
         var _loc9_:int = 0;
         var _loc10_:int = Math.min(this._newSeedsInfo.length,_loc8_);
         while(_loc9_ < _loc10_)
         {
            _loc4_ = new SeedItemRender(this._newSeedsInfo[_loc9_]);
            if(!param2 && _loc9_ >= 3)
            {
               _loc5_ = AlignUtils.getPositionX_ROW(_loc9_ - 3,SeedItemRender.ROW_GAP);
               _loc4_.x = _loc5_;
               if(!_loc7_)
               {
                  _loc7_ = new Sprite();
               }
               _loc7_.addChild(_loc4_);
            }
            else
            {
               _loc5_ = AlignUtils.getPositionX_ROW(_loc9_,SeedItemRender.ROW_GAP);
               _loc4_.x = _loc5_;
               _loc6_.addChild(_loc4_);
            }
            _loc9_++;
         }
         if(param2)
         {
            _loc3_.addChild(_loc6_);
            AlignUtils.align_TOP_CENTER(param1,_loc3_);
         }
         else
         {
            _loc3_.addChild(_loc6_);
            if(_loc7_)
            {
               _loc3_.addChild(_loc7_);
               AlignUtils.align_TOP_CENTER(_loc3_,_loc7_);
               _loc7_.y = SeedItemRender.COLUMN_GAP;
               _loc3_.addChild(_loc7_);
            }
            AlignUtils.align_CENTER(param1,_loc3_);
         }
         _loc3_.x += param1.x;
         _loc3_.y += param1.y;
         if(this._panelUI)
         {
            this._panelUI.addChild(_loc3_);
         }
      }
      
      private function createLandView(param1:Sprite, param2:Boolean) : void
      {
         var _loc3_:LandRender = null;
         var _loc4_:Sprite = new Sprite();
         var _loc5_:int = 0;
         if(this._landInfo.normal)
         {
            this.addLand(LandRender.NORMAL_LAND,_loc4_,_loc5_,param2);
            _loc5_++;
         }
         if(this._landInfo.red)
         {
            this.addLand(LandRender.RED_LAND,_loc4_,_loc5_,param2);
            _loc5_++;
         }
         if(Boolean(this._landInfo.black) || Boolean(this._landInfo.next))
         {
            this.addLand(LandRender.BLACK_LAND,_loc4_,_loc5_,param2);
            _loc5_++;
         }
         if(param2)
         {
            AlignUtils.align_TOP_CENTER(param1,_loc4_);
         }
         else
         {
            AlignUtils.align_LEFT_CENTER(param1,_loc4_);
         }
         if(!param2 && _loc5_ == 1)
         {
            this._panelUI["landTxt"].y = 230;
            _loc4_.y -= 18;
         }
         _loc4_.x += param1.x;
         _loc4_.y += param1.y;
         if(this._panelUI)
         {
            this._panelUI.addChild(_loc4_);
         }
      }
      
      public function onShareSuccess(param1:*) : void
      {
         ClickReportManager.reportClick("share.levelUp.page_share_btn_click_nc");
      }
      
      private function closeWin(param1:Event = null) : void
      {
         this._model.removeEventListener(LevelUpModel.EVENT_SEEDS_DATA_LOADED,this.__onSeedInfo);
         if(this._panelUI)
         {
            if(contains(this._panelUI))
            {
               removeChild(this._panelUI);
            }
            this._panelUI["isYellowBtn"].removeEventListener(MouseEvent.CLICK,this.gotoYellow);
            this._panelUI["notYellowBtn"].removeEventListener(MouseEvent.CLICK,this.gotoYellow);
            this._panelUI["shutBtn"].removeEventListener(MouseEvent.CLICK,this.closeWin);
            this._panelUI["shareBtn"].removeEventListener(MouseEvent.CLICK,this.share);
         }
         PopUpManager.removePopUp(this);
      }
      
      private function getLevelTxtY() : int
      {
         if(this._level < 10)
         {
            return -18;
         }
         if(this._level < 100)
         {
            return 0;
         }
         return 10;
      }
      
      private function initData() : void
      {
         var _loc1_:int = 0;
         if(this._level <= 60)
         {
            _loc1_ = LevelUpModel.NORMAL_LAND_UPDATE_INFO.indexOf(this._level);
            if(_loc1_ > -1)
            {
               if(!this._landInfo)
               {
                  this._landInfo = {};
               }
               this._landInfo.normal = true;
            }
            _loc1_ = LevelUpModel.RED_LAND_UPDATE_INFO.indexOf(this._level);
            if(_loc1_ > -1)
            {
               if(!this._landInfo)
               {
                  this._landInfo = {};
               }
               this._landInfo.red = true;
            }
            _loc1_ = LevelUpModel.BLACK_LAND_UPDATE_INFO_NUM.indexOf(this._level);
            if(_loc1_ > -1)
            {
               if(!this._landInfo)
               {
                  this._landInfo = {};
               }
               this._landInfo.black = true;
            }
         }
         else if(this._level < 70)
         {
            if(!this._landInfo)
            {
               this._landInfo = {};
            }
            _loc1_ = LevelUpModel.BLACK_LAND_UPDATE_INFO_NUM.indexOf(this._level);
            if(_loc1_ > -1)
            {
               this._landInfo.black = true;
            }
            else
            {
               this._landInfo.next = true;
               _loc1_ = LevelUpModel.BLACK_LAND_UPDATE_INFO_NUM.indexOf(this._level + 1);
               this._landInfo.index = _loc1_ + 1;
            }
         }
         this._newSeedsInfo = this._model.seeds;
         if(this._newSeedsInfo == null)
         {
            this._model.addEventListener(LevelUpModel.EVENT_SEEDS_DATA_LOADED,this.__onSeedInfo);
            this._model.loadSeedsInfo();
         }
         else
         {
            this.__onSeedInfo();
         }
      }
      
      private function __onSeedInfo(param1:Event = null) : void
      {
         var _loc3_:Seed = null;
         this._newSeedsInfo = [];
         var _loc2_:Array = this._model.seeds;
         for each(_loc3_ in _loc2_)
         {
            if(_loc3_._lvl == this._level)
            {
               this._newSeedsInfo.push(_loc3_);
            }
         }
         this.checkAllReady();
      }
      
      private function share(param1:MouseEvent) : void
      {
         var _loc8_:String = null;
         ClickReportManager.reportClick("share.levelUp.flash_share_btn_click_nc");
         var _loc2_:String = "";
         var _loc3_:String = "";
         var _loc4_:String = "叮咛啷当吖，咱老百姓呐，今儿真开心哇，我的农场又升一级啦!";
         if(this._level <= 27)
         {
            _loc3_ = "功夫不负苦心人，农场等级升升升，经过辛勤劳作，农场升到" + this._level + "级啦，还有丰富种子相赠，你也来看看吧！";
         }
         else if(this._level <= 69)
         {
            if(this._level == 62 || this._level == 64 || this._level == 66 || this._level == 68)
            {
               _loc3_ = "在山的那边有一块黑土地，它们肥沃又美丽，它们神秘又神奇，升到" + (this._level + 1) + "级就可以开启我第" + this._landInfo.index + "块黑土地啦！";
            }
            else
            {
               _loc3_ = "种菜那件小事，贵在坚持，功到自然成。轻松升到" + this._level + "级了，更广阔的土地、更新奇的作物等着我开垦和收获~";
            }
         }
         else
         {
            _loc3_ = "华丽丽的升到" + this._level + "级！种菜神技已被我练得出神入化、炉火纯青、登峰造极（以上省略一万字），来比试一下？";
         }
         var _loc5_:String = this._model.getLevelUpPicURL();
         var _loc6_:String = "";
         _loc6_ = _loc6_ + "%26from%3DlevelUpShare";
         var _loc7_:String = "炫耀一下！";
         CommonData.addCallBackProxy("onSuccess",this.onShareSuccess);
         if(ExternalInterface.available)
         {
            _loc8_ = "fusion2.dialog.share(" + "{title:\'" + _loc7_ + "\',summary:\'" + _loc4_ + "\',pics:\'" + _loc5_ + "\',desc:\'" + _loc3_ + "\',url:\'" + _loc6_ + "\',onSuccess:function (opt){swfAppObject.onSuccess(opt);}" + ",onCancel:function (opt){swfAppObject.onCancel(opt);}" + ",onClose:function (opt){swfAppObject.onClose(opt);}})";
            if(Settings.getInstance().getStringAttribute("agent") == "weibo")
            {
               _loc8_ = "fusion2.dialog.share(" + "{title:\'" + _loc7_ + "\',summary:\'" + _loc4_ + "\',pics:\'" + _loc5_ + "\',desc:\'" + _loc3_ + "\',onSuccess:function (opt){swfAppObject.onSuccess(opt);}" + ",onCancel:function (opt){swfAppObject.onCancel(opt);}" + ",onClose:function (opt){swfAppObject.onClose(opt);}})";
            }
            ExternalInterface.call(_loc8_);
         }
         this.closeWin();
      }
      
      private function __onLoadOK(param1:Event) : void
      {
         this._panelClass = Utils.getClass("Update.bigPanel");
         if(this._panelClass)
         {
            this.checkAllReady();
         }
      }
      
      private function getLevelTxtSize() : int
      {
         if(this._level < 10)
         {
            return 73;
         }
         if(this._level < 100)
         {
            return 55;
         }
         return 46;
      }
      
      private function initUI() : void
      {
         var _loc1_:String = null;
         var _loc2_:RSLLoader = null;
         this._panelClass = Utils.getClass("Update.bigPanel");
         if(this._panelClass)
         {
            this.checkAllReady();
         }
         else
         {
            _loc1_ = this._model.getPanelURL();
            _loc2_ = new RSLLoader();
            _loc2_.listCompleteFn = this.__onLoadOK;
            _loc2_.load([{"url":_loc1_}]);
         }
      }
      
      private function createPanel() : void
      {
         if(this._shareType == LAND_AND_SEEDS)
         {
            this._panelUI = Utils.getMaterial("Update.bigPanel") as Sprite;
         }
         else if(this._shareType == ONLY_SEEDS)
         {
            this._panelUI = Utils.getMaterial("Update.seedsPanel") as Sprite;
         }
         else if(this._shareType == ONLY_LAND)
         {
            this._panelUI = Utils.getMaterial("Update.landPanel") as Sprite;
         }
         else if(this._shareType == ONLY_LAND_NEXT)
         {
            this._panelUI = Utils.getMaterial("Update.nextLandPanel") as Sprite;
         }
         else if(this._shareType == ONLY_TEXT)
         {
            this._panelUI = Utils.getMaterial("Update.emptyPanel") as Sprite;
         }
         if(this._panelUI)
         {
            this._panelUI["levelTxt"].htmlText = "<font size=\'" + this.getLevelTxtSize() + "\'>" + String(this._level) + "</font>";
            this._panelUI["levelTxt"].y += this.getLevelTxtY();
            if(this._model.isYellow())
            {
               this._panelUI["isYellowBtn"].visible = true;
               this._panelUI["notYellowBtn"].visible = false;
               this._panelUI["isYellowBtn"].buttonMode = true;
               this._panelUI["isYellowBtn"].addEventListener(MouseEvent.CLICK,this.gotoYellow);
            }
            else
            {
               this._panelUI["isYellowBtn"].visible = false;
               this._panelUI["notYellowBtn"].visible = true;
               this._panelUI["notYellowBtn"].buttonMode = true;
               this._panelUI["notYellowBtn"].addEventListener(MouseEvent.CLICK,this.gotoYellow);
            }
            this._panelUI["shutBtn"].buttonMode = true;
            this._panelUI["shareBtn"].buttonMode = true;
            this._panelUI["shutBtn"].addEventListener(MouseEvent.CLICK,this.closeWin);
            this._panelUI["shareBtn"].addEventListener(MouseEvent.CLICK,this.share);
            if(this._shareType == LAND_AND_SEEDS)
            {
               this._panelUI["landTxt"].htmlText = this.getLandTip();
               this.createLandView(this._panelUI["landHoldr"],false);
               this.createSeedsView(this._panelUI["seedsHolder"],false);
            }
            else if(this._shareType == ONLY_SEEDS)
            {
               this.createSeedsView(this._panelUI["seedsHolder"],true);
            }
            else if(this._shareType == ONLY_LAND_NEXT)
            {
               this._panelUI["landTxt"].htmlText = "<font color=\'#714423\'>再升<font color=\'#FF6600\'>1</font>级，您就可以扩第<font color=\'#FF6600\'>" + this._landInfo.index + "</font>块黑土地了！</font>";
               this.createLandView(this._panelUI["landHoldr"],true);
            }
            else if(this._shareType == ONLY_LAND)
            {
               this._panelUI["landTxt"].htmlText = this.getLandTip();
               this.createLandView(this._panelUI["landHoldr"],true);
            }
            else if(this._shareType == ONLY_TEXT)
            {
               this._panelUI["tipTxt"].htmlText = "<font color=\'#714423\'>您升级到<font color=\'#FF6600\'>" + this._level + "</font>级了，快来分享给好友吧！</font>";
            }
         }
         addChild(this._panelUI);
         PopUpManager.addPopUp(this,true);
         ClickReportManager.reportClick("share.levelUp.level_up_window_show_nc");
      }
      
      private function checkAllReady() : void
      {
         if(this._newSeedsInfo != null && this._panelClass != null)
         {
            if(this._newSeedsInfo.length > 0 && this._landInfo != null)
            {
               this._shareType = LAND_AND_SEEDS;
            }
            else if(this._newSeedsInfo.length > 0)
            {
               this._shareType = ONLY_SEEDS;
            }
            else if(this._landInfo != null && Boolean(this._landInfo.next))
            {
               this._shareType = ONLY_LAND_NEXT;
            }
            else if(this._landInfo != null)
            {
               this._shareType = ONLY_LAND;
            }
            else
            {
               this._shareType = ONLY_TEXT;
            }
            this.createPanel();
         }
      }
      
      private function addLand(param1:int, param2:Sprite, param3:int, param4:Boolean) : void
      {
         var _loc5_:LandRender = null;
         if(param1 == LandRender.NORMAL_LAND)
         {
            _loc5_ = new LandRender({"landType":LandRender.NORMAL_LAND});
         }
         else if(param1 == LandRender.RED_LAND)
         {
            _loc5_ = new LandRender({"landType":LandRender.RED_LAND});
         }
         else if(param1 == LandRender.BLACK_LAND)
         {
            _loc5_ = new LandRender({"landType":LandRender.BLACK_LAND});
         }
         if(param4)
         {
            _loc5_.x = AlignUtils.getPositionX_ROW(param3,LandRender.ROW_GAP);
         }
         else
         {
            _loc5_.y = AlignUtils.getPositionY_COLUMN(param3,LandRender.COLUMN_GAP);
         }
         param2.addChild(_loc5_);
      }
      
      private function gotoYellow(param1:Event) : void
      {
         QzoneJSAPI.openWindow(this._model.getYellowURL());
      }
      
      private function addComma(param1:String, param2:String) : String
      {
         if(param1.length > 0)
         {
            param1 += "，";
         }
         return param1 + param2;
      }
      
      private function getCutName(param1:String, param2:int = 7) : String
      {
         if(param1.length > param2)
         {
            param1 = param1.substr(0,param2 - 1);
         }
         return param1;
      }
   }
}

