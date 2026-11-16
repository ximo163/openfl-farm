package module.uitools.widgets
{
   import com.qzone.qui.containers.HBox;
   import com.qzone.qui.controls.scrollClasses.ScrollPolicy;
   import com.qzone.qui.core.Align;
   import common.CommonData;
   import common.Consts;
   import common.Session;
   import common.Settings;
   import common.misc.Utils;
   import common.view.cursor.CursorControl;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import framework.api.beast.BeastAPI;
   import framework.base.Module;
   import module.uitools.UIController;
   import report.ClickReportManager;
   import report.UserActionRecorder;
   
   public class ToolBar extends HBox
   {
      
      public static const MODULE_EVENT_CLICK_PACK:String = "PackBtnClicked";
      
      public static const MODULE_EVENT_CLICK_TOOLBOX:String = "ToolBoxBtnClicked";
      
      private static const TOOL_ARROW:int = 0;
      
      private static const TOOL_HAND:int = 1;
      
      private static const TOOL_ONECLICK:int = 2;
      
      private static const TOOL_HOE:int = 3;
      
      private static const TOOL_INSECT:int = 4;
      
      private static const TOOL_PACK:int = 5;
      
      private static const TOOL_TOOLBOX:int = 6;
      
      private static const TOOL_THEFT:int = 7;
      
      private static const TOOL_UPRED:int = 8;
      
      private static const TOOL_WEED:int = 9;
      
      private static const TOOL_WILD:int = 10;
      
      private static const TOOL_FISHNET:int = 11;
      
      private static const TOOL_FISHNET_ALL:int = 12;
      
      private static const TOOL_MAX:int = 13;
      
      private const TOOLS_TIP:Array = ["可拖动屏幕","用来收获果实(R)","一键摘取(T)","可用来翻地","在地里放害虫","我的物品包","我的工具箱","摘取好友的果实(R)","升级土地","在地里放杂草","领养、放养野生动物","捞鱼","一键捞鱼"];
      
      private const TOOLS:Array = ["ToolArrow","ToolHand","OneClickHand","ToolHoe","ToolInsect","ToolPack","ToolBox","ToolTheft","ToolUpgradeNew","ToolWeed","Tool_Wild","ToolFishNet","ToolFishNetAll"];
      
      private var _redUpBtn:ToolBase;
      
      private var _API:BeastAPI;
      
      private var _showMe:Boolean;
      
      private var _isActived:String = "";
      
      private var _tools:Array;
      
      private var _controller:UIController;
      
      private var _wildTool:Tool_Wild;
      
      public function ToolBar(param1:UIController)
      {
         super(460,56);
         this._controller = param1;
         alignH = Align.LEFT;
         alignV = Align.MIDDLE;
         gapH = 10;
         gapV = 10;
         borderSizeH = 7;
         borderSizeV = 2;
         autoLayout = true;
         verticalScrollPolicy = ScrollPolicy.OFF;
         horizontalScrollPolicy = ScrollPolicy.OFF;
         defaultSkin = ToolBarBg;
         this._showMe = true;
         this._tools = new Array(TOOL_MAX);
         this.addTools();
         addEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage,false,0,true);
         this._API = BeastAPI.getInstance();
         this._API.addEventListener(EvtAPI.REWARD_CHANGE,this.onRewardChange);
      }
      
      public function updateGoldLandTime(param1:int) : void
      {
         (this._tools[TOOL_UPRED] as ToolBase).getChildAt(0)["updateTime"].text = param1.toString();
      }
      
      private function addToolBtn(param1:int) : *
      {
         var _loc2_:* = Utils.getMaterial(this.TOOLS[param1]);
         if(_loc2_ == null)
         {
            return null;
         }
         _loc2_.tipText = this.TOOLS_TIP[param1];
         _loc2_.addEventListener(MouseEvent.CLICK,this.onToolClick,false,0,true);
         _loc2_.addEventListener(MouseEvent.ROLL_OVER,this.onToolRollOver,false,0,true);
         _loc2_.addEventListener(MouseEvent.ROLL_OUT,this.onToolRollOut,false,0,true);
         addElement(_loc2_);
         return _loc2_;
      }
      
      private function onToolRollOut(param1:MouseEvent) : void
      {
         this._controller.hideTip();
      }
      
      private function addWildBtn() : Tool_Wild
      {
         if(this._wildTool == null)
         {
            this._wildTool = new Tool_Wild();
            this._wildTool.tipText = this.TOOLS_TIP[TOOL_WILD];
            this._wildTool.addEventListener(MouseEvent.CLICK,this.onToolClick,false,0,true);
            this._wildTool.addEventListener(MouseEvent.ROLL_OVER,this.onToolRollOver,false,0,true);
            this._wildTool.addEventListener(MouseEvent.ROLL_OUT,this.onToolRollOut,false,0,true);
         }
         addElement(this._wildTool);
         return this._wildTool;
      }
      
      public function set myHome(param1:Boolean) : void
      {
         if(this._showMe == param1)
         {
            return;
         }
         this._showMe = param1;
         this.refresh();
      }
      
      private function adjustPosition() : void
      {
         this.x = (stage.stageWidth - this.width) * 0.5;
         this.y = stage.stageHeight - this.height + 1;
      }
      
      public function refresh() : void
      {
         if(this._tools == null || this._tools.length == 0)
         {
            return;
         }
         removeAllElements();
         var _loc1_:Boolean = Session.getInstance().m_waterPoolOpen;
         if(this._showMe == true)
         {
            this.width = _loc1_ ? 566 : 460;
         }
         else
         {
            this.width = _loc1_ ? 518 : 416;
         }
         this.addTools();
         Tool_Wild(this._tools[TOOL_WILD]).actived = this._isActived;
         this.adjustPosition();
      }
      
      private function setCursor(param1:String, param2:Boolean = false) : Boolean
      {
         var _loc4_:Module = null;
         var _loc5_:CursorControl = null;
         var _loc3_:Boolean = false;
         if(this._controller != null)
         {
            _loc4_ = this._controller.module as Module;
            if(_loc4_ != null && _loc4_.app != null)
            {
               _loc5_ = _loc4_.app.farmView.cursorCtrl;
               if(param2 == false)
               {
                  _loc5_.setCursor(param1);
                  _loc3_ = true;
               }
               else if(_loc5_.name != param1)
               {
                  _loc5_.setCursor(param1);
                  _loc3_ = true;
               }
               else
               {
                  this.setCursor(Consts.CURSOR_STYLE_ARROW);
                  _loc3_ = false;
               }
            }
         }
         Session.getInstance().m_lockFishMouse = param1 == Consts.CURSOR_STYLE_FISHNET || param1 == Consts.CURSOR_STYLE_FISHNET_ALL;
         return _loc3_;
      }
      
      private function initRedUpBtn() : void
      {
         var _loc1_:MovieClip = null;
         var _loc2_:Settings = null;
         var _loc3_:String = null;
         var _loc4_:Array = null;
         var _loc5_:Date = null;
         var _loc6_:Date = null;
         var _loc7_:Number = NaN;
         if(!this._redUpBtn)
         {
            this._redUpBtn = new ToolBase();
            _loc1_ = Utils.getMaterial(this.TOOLS[TOOL_UPRED]) as MovieClip;
            this._redUpBtn.addChild(_loc1_);
            _loc2_ = Settings.getInstance();
            _loc3_ = _loc2_.getStringAttribute("jinPaiLand");
            if(_loc3_)
            {
               _loc4_ = _loc3_.split("-");
               _loc5_ = new Date(_loc4_[0]);
               _loc6_ = new Date(_loc4_[1]);
               _loc7_ = CommonData.serverTime * 1000;
               if(_loc7_ >= _loc5_.time && _loc7_ <= _loc6_.time)
               {
                  _loc1_["updateTime"].text = Session.getInstance().upGoldLandTime;
               }
               else
               {
                  _loc1_["updateTime"].text = "0";
               }
            }
            else
            {
               _loc1_["updateTime"].text = "0";
            }
         }
         this._redUpBtn.tipText = this.TOOLS_TIP[TOOL_UPRED];
         this._redUpBtn.addEventListener(MouseEvent.CLICK,this.onToolClick,false,0,true);
         this._redUpBtn.addEventListener(MouseEvent.ROLL_OVER,this.onToolRollOver,false,0,true);
         this._redUpBtn.addEventListener(MouseEvent.ROLL_OUT,this.onToolRollOut,false,0,true);
         addElement(this._redUpBtn);
         this._tools[TOOL_UPRED] = this._redUpBtn;
      }
      
      private function onAddedToStage(param1:Event) : void
      {
         removeEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage);
         stage.addEventListener(KeyboardEvent.KEY_UP,this.onKeyUp,false,0,true);
         this.adjustPosition();
      }
      
      public function get myHome() : Boolean
      {
         return this._showMe;
      }
      
      private function onToolRollOver(param1:MouseEvent) : void
      {
         this._controller.showTip(Consts.TIP_NAME_MOUSE,param1.currentTarget.tipText);
      }
      
      private function onToolClick(param1:MouseEvent) : void
      {
         Session.getInstance().m_lockFishMouse = false;
         if(param1.currentTarget == this._tools[TOOL_ARROW])
         {
            this.setCursor(Consts.CURSOR_STYLE_ARROW);
            if(Session.getInstance().me)
            {
               ClickReportManager.reportClick("down.banner.icon_move.click");
            }
            else
            {
               ClickReportManager.reportClick("friend.down.banner.icon_move.click");
            }
         }
         else if(param1.currentTarget == this._tools[TOOL_UPRED])
         {
            this._controller.module.app.dispatchEvent(new Event(Consts.MSG_SHOW_UPGRADE_RED));
            ClickReportManager.reportClick("down.banner.icon_upgrade.click");
         }
         else if(param1.currentTarget == this._tools[TOOL_WEED])
         {
            this.setCursor(Consts.CURSOR_STYLE_WEED,true);
            ClickReportManager.reportClick("friend.down.banner.icon_put_grass.click");
         }
         else if(param1.currentTarget == this._tools[TOOL_INSECT])
         {
            this.setCursor(Consts.CURSOR_STYLE_INSET,true);
            ClickReportManager.reportClick("friend.down.banner.icon_put_bug.click");
         }
         else if(param1.currentTarget == this._tools[TOOL_HOE])
         {
            this.setCursor(Consts.CURSOR_STYLE_HOE,true);
            UserActionRecorder.recordAction(UserActionRecorder.HF_TOOL_HOE_CLICKED);
            ClickReportManager.reportClick("down.banner.icon_shovel.click");
         }
         else if(param1.currentTarget == this._tools[TOOL_PACK])
         {
            this.setCursor(Consts.CURSOR_STYLE_ARROW);
            dispatchEvent(new Event(MODULE_EVENT_CLICK_PACK));
            UserActionRecorder.recordAction(UserActionRecorder.HF_TOOL_PACK_CLICKED);
            ClickReportManager.reportClick("down.banner.icon_backpack.click");
         }
         else if(param1.currentTarget == this._tools[TOOL_TOOLBOX])
         {
            this.setCursor(Consts.CURSOR_STYLE_ARROW);
            dispatchEvent(new Event(MODULE_EVENT_CLICK_TOOLBOX));
            BeastAPI.getInstance().hideBeastPack();
            UserActionRecorder.recordAction(UserActionRecorder.HF_TOOL_TOOLBOX_CLICKED);
            if(Session.getInstance().me)
            {
               ClickReportManager.reportClick("down.banner.icon_toolbox.click");
            }
            else
            {
               ClickReportManager.reportClick("friend.down.banner.icon_toolbox.click");
            }
         }
         else if(param1.currentTarget == this._tools[TOOL_HAND])
         {
            this.setCursor(Consts.CURSOR_STYLE_HAND,true);
            UserActionRecorder.recordAction(UserActionRecorder.HF_TOOL_HAND_CLICKED);
            ClickReportManager.reportClick("down.banner.icon_harvest.click");
         }
         else if(param1.currentTarget == this._tools[TOOL_ONECLICK])
         {
            this.setCursor(Consts.CURSOR_STYLE_ONEHAND,true);
            UserActionRecorder.recordAction(UserActionRecorder.HF_TOOL_ONECLICK_CLICKED);
            if(Session.getInstance().me)
            {
               ClickReportManager.reportClick("down.banner.icon_all_harvest.click");
            }
            else
            {
               ClickReportManager.reportClick("friend.down.banner.icon_all_harvest.click");
            }
         }
         else if(param1.currentTarget == this._tools[TOOL_THEFT])
         {
            this.setCursor(Consts.CURSOR_STYLE_HAND,true);
            ClickReportManager.reportClick("friend.down.banner.icon_harvest.click");
         }
         else if(param1.currentTarget == this._tools[TOOL_WILD])
         {
            this.setCursor(Consts.CURSOR_STYLE_ARROW);
            BeastAPI.getInstance().showBeastPack();
            UserActionRecorder.recordAction(UserActionRecorder.HF_TOOL_WILD_CLICKED);
            if(Session.getInstance().me)
            {
               ClickReportManager.reportClick("down.banner.icon_wild_animal.click");
            }
            else
            {
               ClickReportManager.reportClick("friend.down.banner.icon_wild_animal.click");
            }
         }
         else if(param1.currentTarget == this._tools[TOOL_FISHNET])
         {
            this.setCursor(Consts.CURSOR_STYLE_FISHNET);
            if(Session.getInstance().me)
            {
               ClickReportManager.reportClick("down.banner.icon_fishing.click");
            }
            else
            {
               ClickReportManager.reportClick("friend.down.banner.icon_fishing.click");
            }
         }
         else if(param1.currentTarget == this._tools[TOOL_FISHNET_ALL])
         {
            this.setCursor(Consts.CURSOR_STYLE_FISHNET_ALL);
            if(Session.getInstance().me)
            {
               ClickReportManager.reportClick("down.banner.icon_all_fishing.click");
            }
            else
            {
               ClickReportManager.reportClick("friend.down.banner.icon_all_fishing.click");
            }
         }
         param1.stopPropagation();
      }
      
      private function onKeyUp(param1:KeyboardEvent) : void
      {
         if(param1.target is TextField)
         {
            return;
         }
         switch(param1.keyCode)
         {
            case 81:
               this.setCursor(Consts.CURSOR_STYLE_WATER);
               break;
            case 87:
               this.setCursor(Consts.CURSOR_STYLE_HOOK);
               break;
            case 69:
               this.setCursor(Consts.CURSOR_STYLE_PESTICIDE);
               break;
            case 82:
               this.setCursor(Consts.CURSOR_STYLE_HAND);
               break;
            case 84:
               this.setCursor(Consts.CURSOR_STYLE_ONEHAND);
         }
      }
      
      override protected function updateBackGround() : void
      {
      }
      
      private function hideFn() : void
      {
         dispatchEvent(new Event("hidebeast"));
      }
      
      private function addTools() : void
      {
         enableValidate = false;
         this._tools[TOOL_ARROW] = this.addToolBtn(TOOL_ARROW);
         if(this._showMe == true)
         {
            this.initRedUpBtn();
            this._tools[TOOL_HOE] = this.addToolBtn(TOOL_HOE);
            this._tools[TOOL_PACK] = this.addToolBtn(TOOL_PACK);
         }
         else
         {
            this._tools[TOOL_INSECT] = this.addToolBtn(TOOL_INSECT);
            this._tools[TOOL_WEED] = this.addToolBtn(TOOL_WEED);
         }
         this._tools[TOOL_TOOLBOX] = this.addToolBtn(TOOL_TOOLBOX);
         this._tools[TOOL_WILD] = this.addWildBtn();
         if(this._showMe == true)
         {
            this._tools[TOOL_HAND] = this.addToolBtn(TOOL_HAND);
         }
         else
         {
            this._tools[TOOL_THEFT] = this.addToolBtn(TOOL_THEFT);
         }
         this._tools[TOOL_ONECLICK] = this.addToolBtn(TOOL_ONECLICK);
         if(Session.getInstance().m_waterPoolOpen == true)
         {
            this._tools[TOOL_FISHNET] = this.addToolBtn(TOOL_FISHNET);
            this._tools[TOOL_FISHNET_ALL] = this.addToolBtn(TOOL_FISHNET_ALL);
         }
         enableValidate = true;
         validateNow();
      }
      
      public function removeWildText() : void
      {
         var _loc1_:Tool_Wild = this._tools[TOOL_WILD] as Tool_Wild;
         if(_loc1_ != null)
         {
            _loc1_.removeText();
         }
      }
      
      private function onRewardChange(param1:EvtAPI) : void
      {
         this._isActived = param1.data as String;
         Tool_Wild(this._tools[TOOL_WILD]).actived = param1.data as String;
      }
      
      override protected function setSkin() : void
      {
         if(defaultSkin != null)
         {
            _skin = new defaultSkin();
            this.addChildAt(_skin,0);
         }
      }
   }
}

