package mc.view.main.levelup
{
   import com.qzone.allianceActivity.framewrok.manager.ClickReportManager;
   import com.qzone.corelib.js.JSProxy;
   import com.qzone.corelib.net.RSLLoader;
   import common.MaterialLib;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import mc.control.Command;
   import mc.model.MData;
   import mc.model.MainData;
   import mc.view.common.BaseWindow;
   import mc.view.main.WindowControl.WControl;
   
   public class LevelUpWindow extends BaseWindow
   {
      
      private static const DEN_SHED_AND_SEEDS:int = 1;
      
      private static const ONLY_SEEDS:int = 2;
      
      private static const ONLY_DEN_SHED:int = 3;
      
      private static const ONLY_TEXT:int = 4;
      
      private var _shareType:int;
      
      private var _level:int;
      
      private var _newSeedsInfo:Array;
      
      private var _panelUI:Sprite;
      
      private var _model:LevelUpModel;
      
      private var _denShedInfo:Object;
      
      private var _panelClass:Class;
      
      public function LevelUpWindow(param1:int, param2:LevelUpModel)
      {
         super();
         mode = true;
         this.width = 0;
         this.height = 0;
         closeVisible = false;
         this._level = param1;
         this._model = param2;
         this.initData();
         this.initUI();
      }
      
      private function closeWin(param1:Event = null) : void
      {
         MData.getInstance().mainData.removeEventListener(MainData.SEED_INFO,this.__onSeedInfo);
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
         WControl.close(this);
      }
      
      private function createDenShedView(param1:Sprite) : void
      {
         var _loc2_:DenShedItemRender = null;
         _loc2_ = new DenShedItemRender({
            "isDen":this._denShedInfo.isDen,
            "level":this._denShedInfo.level,
            "addNum":this._denShedInfo.addNum
         });
         _loc2_.x += param1.x;
         _loc2_.y += param1.y;
         if(this._panelUI)
         {
            this._panelUI.addChildAt(_loc2_,this._panelUI.getChildIndex(param1));
         }
      }
      
      private function createSeedsView(param1:Sprite) : void
      {
         var _loc3_:SeedItemRender = null;
         var _loc4_:int = 0;
         var _loc2_:Sprite = new Sprite();
         var _loc5_:int = 0;
         var _loc6_:int = Math.min(5,this._newSeedsInfo.length);
         while(_loc5_ < _loc6_)
         {
            _loc3_ = new SeedItemRender(this._newSeedsInfo[_loc5_]);
            _loc4_ = AlignUtils.getPositionX_Line(_loc5_,SeedItemRender.GAP_ROW);
            _loc3_.x = _loc4_;
            _loc2_.addChild(_loc3_);
            _loc5_++;
         }
         AlignUtils.align_CENTER(param1,_loc2_);
         _loc2_.x += param1.x;
         _loc2_.y += param1.y;
         if(this._panelUI)
         {
            this._panelUI.addChild(_loc2_);
         }
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
         var _loc1_:int = LevelUpModel.DEN_UPDATE_INFO.indexOf(this._level);
         if(_loc1_ > -1)
         {
            this._denShedInfo = {
               "isDen":true,
               "level":_loc1_ + 1,
               "addNum":LevelUpModel.DEN_UPDATE_INFO_NUM[_loc1_]
            };
         }
         else
         {
            _loc1_ = LevelUpModel.SHED_UPDATE_INFO.indexOf(this._level);
            if(_loc1_ > -1)
            {
               this._denShedInfo = {
                  "isDen":false,
                  "level":_loc1_ + 1,
                  "addNum":LevelUpModel.SHED_UPDATE_INFO_NUM[_loc1_]
               };
            }
         }
         MData.getInstance().mainData.addEventListener(MainData.SEED_INFO,this.__onSeedInfo,false,0,true);
         Command.getInstance().mainCommand.getSeedInfo();
      }
      
      private function onPageShareBtnClick(param1:*) : void
      {
         ClickReportManager.reportClick("share.levelup.page_share_btn_click_mc");
      }
      
      private function __onSeedInfo(param1:Event) : void
      {
         var _loc3_:Object = null;
         this._newSeedsInfo = [];
         var _loc2_:Array = MData.getInstance().mainData.seedInfo;
         for each(_loc3_ in _loc2_)
         {
            if((!_loc3_.hasOwnProperty("isvip") || _loc3_.hasOwnProperty("isvip") && _loc3_["isvip"] != 1) && (!_loc3_.hasOwnProperty("cType") || _loc3_.hasOwnProperty("cType") && _loc3_["cType"] != 6) && _loc3_["cType"] != 4 && _loc3_["cLevel"] == this._level)
            {
               this._newSeedsInfo.push(_loc3_);
            }
         }
         this.checkAllReady();
      }
      
      private function share(param1:Event) : void
      {
         ClickReportManager.reportClick("share.levelup.flash_share_btn_click_mc");
         var _loc2_:String = "";
         var _loc3_:String = "又一次升级光束亮起，照亮了方圆十里，亮出我家的动物肥又壮，我家的窝棚高又靓！";
         if(this._level <= 28)
         {
            _loc2_ = "不知不觉牧场升到" + this._level + "级啦！盖新窝，建新棚，每天快乐多一点；新幼仔，被解锁，幸福相随，so easy！";
         }
         else if(this._level <= 56)
         {
            _loc2_ = "牧场欢乐多，各种幼仔来卖萌，皇天不负有心人，我的牧场顺利升到" + this._level + "级了，又有更多可养育的幼仔啦！";
         }
         else
         {
            _loc2_ = "牧林江湖，级高者为王。我独步牧林好多年，今朝喜升" + this._level + "级，各位牧林高手，尔等可敢一较高下？";
         }
         var _loc4_:String = "";
         _loc4_ = _loc4_ + "%26from%3DlevelUpShare";
         Command.getInstance().mainCommand.shareWithCallBack("炫耀一下！",_loc3_,this._model.getLevelUpPicURL(),_loc2_,_loc4_,this.onPageShareBtnClick);
         this.closeWin();
      }
      
      private function __onLoadOK(param1:Event) : void
      {
         this._panelClass = MaterialLib.getInstance().getClass("Update.bigPanel");
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
         this._panelClass = MaterialLib.getInstance().getClass("Update.bigPanel");
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
         if(this._shareType == DEN_SHED_AND_SEEDS)
         {
            this._panelUI = MaterialLib.getInstance().getMaterial("Update.bigPanel") as Sprite;
         }
         else if(this._shareType == ONLY_SEEDS)
         {
            this._panelUI = MaterialLib.getInstance().getMaterial("Update.seedsPanel") as Sprite;
         }
         else if(this._shareType == ONLY_DEN_SHED)
         {
            this._panelUI = MaterialLib.getInstance().getMaterial("Update.denShedPanel") as Sprite;
         }
         else if(this._shareType == ONLY_TEXT)
         {
            this._panelUI = MaterialLib.getInstance().getMaterial("Update.emptyPanel") as Sprite;
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
            if(this._shareType == DEN_SHED_AND_SEEDS)
            {
               this.createDenShedView(this._panelUI["denShedHolder"]);
               this.createSeedsView(this._panelUI["seedsHolder"]);
            }
            else if(this._shareType == ONLY_SEEDS)
            {
               this.createSeedsView(this._panelUI["seedsHolder"]);
            }
            else if(this._shareType == ONLY_DEN_SHED)
            {
               this.createDenShedView(this._panelUI["denShedHolder"]);
            }
            else if(this._shareType == ONLY_TEXT)
            {
               this._panelUI["tipTxt"].htmlText = "<font color=\'#714423\'>您升级到<font color=\'#FF781E\'>" + this._level + "</font>级了，快来分享给好友吧！</font>";
            }
         }
         this._panelUI.x = -this._panelUI.width / 2;
         this._panelUI.y = -this._panelUI.height / 2;
         addChild(this._panelUI);
         WControl.open(this);
         ClickReportManager.reportClick("share.levelup.level_up_window_show_mc");
      }
      
      private function checkAllReady() : void
      {
         if(this._newSeedsInfo != null && this._panelClass != null)
         {
            if(this._newSeedsInfo.length > 0 && this._denShedInfo != null)
            {
               this._shareType = DEN_SHED_AND_SEEDS;
            }
            else if(this._newSeedsInfo.length > 0)
            {
               this._shareType = ONLY_SEEDS;
            }
            else if(this._denShedInfo != null)
            {
               this._shareType = ONLY_DEN_SHED;
            }
            else
            {
               this._shareType = ONLY_TEXT;
            }
            this.createPanel();
         }
      }
      
      private function gotoYellow(param1:Event) : void
      {
         JSProxy.openWindow(this._model.getYellowURL());
      }
   }
}

