package module.warehouse.bag
{
   import com.qzone.qui.controls.Button;
   import com.qzone.qui.controls.HList;
   import com.qzone.qui.controls.Label;
   import com.qzone.utils.AlignUtil;
   import common.CommonData;
   import common.Consts;
   import common.Language;
   import common.Session;
   import common.Settings;
   import common.misc.Utils;
   import common.view.DataLoading;
   import common.view.cursor.CursorControl;
   import entities.BagItem;
   import events.CommonEvent;
   import events.ViewEvent;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormat;
   import flash.text.TextFormatAlign;
   import flash.utils.setTimeout;
   import framework.api.beast.BeastAPI;
   import module.GameGuide;
   import report.UserActionRecorder;
   
   public class MyBagView extends Sprite
   {
      
      private var m_bLoading:Boolean;
      
      private var _showTipsEndTime:String = "7/26/2012 23:59:5";
      
      private var _closeBtnTipsBg:Sprite;
      
      private var m_controller:MyBagController;
      
      private var m_list:HList;
      
      private var m_notOpenText:TextField;
      
      private var m_switchBtn:MovieClip;
      
      private var m_emptyText:TextField;
      
      private var m_mgrLabel:Label;
      
      private var m_hideTimer:uint;
      
      private var _showCloseTips:Boolean = true;
      
      private var m_closeBtn:SimpleButton;
      
      private var m_model:MyBagModel;
      
      private var m_btnGoWarehouse:Button;
      
      private var _api:BeastAPI;
      
      private var m_bg:Sprite;
      
      private var m_dataLoading:DataLoading;
      
      private var _selectTab:String = "normal";
      
      public function MyBagView(param1:MyBagController)
      {
         var controller:MyBagController = param1;
         this._api = BeastAPI.getInstance();
         super();
         this.m_bg = Utils.getMaterial("PackBarBg") as Sprite;
         if(this.m_bg != null)
         {
            addChild(this.m_bg);
         }
         this.createButtons();
         this.createList();
         this.m_hideTimer = 0;
         this.m_bLoading = false;
         this.m_controller = controller;
         this.m_model = this.m_controller.model;
         addEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage);
         this._api.addEventListener(EvtAPI.SHOW_BEAST_PACK,this.hideThis);
         this.m_controller.module.app.addEventListener(Consts.MSG_POOL_OPEN,function():void
         {
            setVisible();
         });
      }
      
      private function hideThis(param1:EvtAPI) : void
      {
         this.show(false);
      }
      
      private function onLoadFailed(param1:CommonEvent) : void
      {
         var _loc2_:String = Language.L["请求超时，"] + "<a href=\'event:reload\'><u><font color=\'#ff6600\'>" + Language.L["点击重试"] + "</font></u></a>";
         this.m_dataLoading.errorText = _loc2_;
      }
      
      private function selectNormal(param1:Event = null) : void
      {
         this._selectTab = "normal";
         this.m_mgrLabel.visible = true;
         this.m_list.dataProvider = this.m_model.fillterType("normal");
         this.setVisible();
         UserActionRecorder.recordAction(UserActionRecorder.HF_BAG_NORAML_CLICKED);
      }
      
      private function onTimeout() : void
      {
         this.show(false);
      }
      
      private function onChildClick(param1:ViewEvent) : void
      {
         if(param1 == null || param1.data == null)
         {
            return;
         }
         var _loc2_:BagItem = param1.data as BagItem;
         if(_loc2_ == null)
         {
            return;
         }
         var _loc3_:String = _loc2_._type.toString();
         if(_loc3_ == Consts.ITEM_TYPE_SEED || _loc3_ == Consts.ITEM_TYPE_FISH)
         {
            this.m_controller.setCursor(Consts.CURSOR_STYLE_CROPSEED,_loc3_ + "," + _loc2_._cId);
         }
         else if(_loc3_ == Consts.ITEM_TYPE_TOOL || _loc3_ == Consts.ITEM_TYPE_FISHFEED)
         {
            this.m_controller.setCursor(Consts.CURSOR_STYLE_TOOL,_loc3_ + "," + _loc2_._cId);
            this.visible = false;
         }
         if(_loc3_ == Consts.ITEM_TYPE_FISH)
         {
            this.m_controller.module.app.dispatchEvent(new CommonEvent(Consts.MSG_FISH_GUIDE,{"step":GameGuide.WATER_POOL_CENTER}));
         }
      }
      
      private function onDataLoaded(param1:CommonEvent) : void
      {
         if(param1 == null || param1.data == null)
         {
            return;
         }
         this.m_bLoading = false;
         var _loc2_:int = 0;
         if(this.m_list.hScrollBar != null)
         {
            _loc2_ = int(this.m_list.hScrollBar.scrollPosition);
         }
         switch(this._selectTab)
         {
            case "normal":
               this.selectNormal();
               break;
            case "fish":
               this.selectFish();
               break;
            case "tool":
               this.selectTool();
         }
         if(_loc2_ > 0)
         {
            this.m_list.hScrollBar.scrollPosition = _loc2_;
         }
      }
      
      private function onChildOut(param1:ViewEvent) : void
      {
         this.m_controller.hideTip();
      }
      
      private function onAddedToStage(param1:Event) : void
      {
         param1.target.removeEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage);
         this.adjustPosition();
         addEventListener(MouseEvent.ROLL_OVER,this.onOver);
         addEventListener(MouseEvent.CLICK,this.onClick);
         var _loc2_:MyBagModel = this.m_controller.model;
         if(_loc2_ != null)
         {
            _loc2_.addEventListener(MyBagModel.EVENT_INITIALZED,this.onDataLoaded);
            _loc2_.addEventListener(MyBagModel.EVENT_LOAD_FAILED,this.onLoadFailed);
            _loc2_.addEventListener(MyBagModel.EVENT_LOADING,this.onDataLoading);
            _loc2_.addEventListener(MyBagModel.EVENT_UPDATED,this.onDataUpdated);
         }
      }
      
      private function setVisible() : void
      {
         this.m_notOpenText.visible = false;
         if(this.m_bLoading == true)
         {
            this.m_mgrLabel.visible = false;
            this.m_list.visible = false;
            this.m_dataLoading.visible = true;
            this.m_btnGoWarehouse.visible = false;
            this.m_emptyText.visible = false;
         }
         else if(this.m_list.dataProvider != null && this.m_list.dataProvider.length > 0)
         {
            this.m_list.visible = true;
            this.m_dataLoading.visible = false;
            this.m_btnGoWarehouse.visible = false;
            this.m_emptyText.visible = false;
         }
         else
         {
            this.m_list.visible = false;
            this.m_dataLoading.visible = false;
            this.m_btnGoWarehouse.visible = true;
            this.m_emptyText.visible = true;
         }
      }
      
      private function selectTool(param1:Event = null) : void
      {
         this._selectTab = "tool";
         this.m_mgrLabel.visible = false;
         this.m_list.dataProvider = this.m_model.fillterType("tool");
         this.setVisible();
         UserActionRecorder.recordAction(UserActionRecorder.HF_BAG_TOOL_CLICKED);
      }
      
      private function showCloseBtnTips() : void
      {
         var text:TextField = null;
         var now:Number = CommonData.serverTime * 1000;
         var end:Date = new Date(this._showTipsEndTime);
         if(now < end.time)
         {
            this._closeBtnTipsBg = new Sprite();
            this._closeBtnTipsBg.graphics.beginFill(16777215,0.8);
            this._closeBtnTipsBg.graphics.drawRoundRect(0,0,80,23,10,10);
            this._closeBtnTipsBg.graphics.endFill();
            text = new TextField();
            text.text = "点击这里关闭";
            text.height = 20;
            this._closeBtnTipsBg.addChild(text);
            text.y = 1;
            addChild(this._closeBtnTipsBg);
            this._closeBtnTipsBg.x = this.m_closeBtn.x - 37;
            this._closeBtnTipsBg.y = this.m_closeBtn.y - 40;
            setTimeout(function():void
            {
               if(_closeBtnTipsBg.parent)
               {
                  _closeBtnTipsBg.parent.removeChild(_closeBtnTipsBg);
                  _closeBtnTipsBg = null;
               }
            },3000);
         }
      }
      
      private function createList() : void
      {
         this.m_list = new HList();
         this.m_list.defaultSkin = null;
         this.m_list.itemRenderer = PackItem;
         this.m_list.x = 35;
         this.m_list.y = 25;
         this.m_list.rowCount = 6;
         this.m_list.rowHeight = 63;
         this.m_list.height = 80;
         addChild(this.m_list);
         addEventListener(ViewEvent.CHILD_CLICK,this.onChildClick);
         addEventListener(ViewEvent.CHILD_OVER,this.onChildOver);
         addEventListener(ViewEvent.CHILD_OUT,this.onChildOut);
      }
      
      private function onEmptyTextClicked(param1:MouseEvent) : void
      {
         var _loc2_:int = 0;
         this.show(false);
         switch(this._selectTab)
         {
            case "normal":
               _loc2_ = 0;
               break;
            case "fish":
               _loc2_ = 1;
               break;
            case "tool":
               _loc2_ = 2;
         }
         this.m_controller.module.app.dispatchEvent(new CommonEvent(Consts.MSG_SHOW_SHOP,{"tabIndex":_loc2_}));
      }
      
      private function onLoadingLinkClicked(param1:ViewEvent) : void
      {
         if(param1.data == "reload")
         {
            this.m_controller.model.reload();
            this.m_dataLoading.visible = true;
         }
      }
      
      public function switchTab(param1:int) : void
      {
         if(this.m_switchBtn == null)
         {
            return;
         }
         if(param1 < 0 || param1 >= this.m_switchBtn.totalFrames)
         {
            return;
         }
         if(param1 + 1 == this.m_switchBtn.currentFrame)
         {
            return;
         }
         if(param1 == 1)
         {
            this.m_switchBtn.gotoAndStop(3);
         }
         else if(param1 == 0)
         {
            this.m_switchBtn.gotoAndStop(1);
         }
         else
         {
            this.m_switchBtn.gotoAndStop(2);
         }
         if(param1 == 0)
         {
            this.selectNormal();
         }
         else if(param1 == 1)
         {
            this.selectFish();
         }
         else if(param1 == 2)
         {
            this.selectTool();
         }
      }
      
      public function onPoolOrLandIsFull(param1:Event) : void
      {
         this.show(false);
         var _loc2_:CursorControl = this.m_controller.module.app.farmView.cursorCtrl;
         _loc2_.setCursor(Consts.CURSOR_STYLE_ARROW);
      }
      
      private function onDataUpdated(param1:CommonEvent) : void
      {
         var _loc5_:Boolean = false;
         var _loc6_:int = 0;
         if(param1 == null || param1.data == null)
         {
            return;
         }
         var _loc2_:BagItem = param1.data["item"];
         if(_loc2_ == null)
         {
            return;
         }
         var _loc3_:int = 0;
         var _loc4_:PackItem = null;
         if(_loc2_._amount <= 0)
         {
            this.m_list.removeItem(_loc2_);
            if(this.m_list.dataProvider == null || this.m_list.dataProvider.length == 0)
            {
               this.setVisible();
            }
            this.m_controller.setCursor(Consts.CURSOR_STYLE_ARROW,"");
         }
         else
         {
            _loc5_ = false;
            _loc6_ = int(this.m_list.content.numChildren);
            _loc3_ = 0;
            while(_loc3_ < _loc6_)
            {
               _loc4_ = this.m_list.content.getChildAt(_loc3_) as PackItem;
               if(_loc4_ != null && _loc4_.data as BagItem == _loc2_)
               {
                  _loc5_ = true;
                  break;
               }
               _loc3_++;
            }
            if(_loc5_ == true && _loc4_ != null)
            {
               _loc4_.setAmount(_loc2_._amount);
            }
            else if(_loc2_._type.toString() == Consts.ITEM_TYPE_SEED)
            {
               this.m_list.addItemAt(0,_loc2_);
            }
            else
            {
               this.m_list.addItemAt(_loc6_,_loc2_);
            }
         }
      }
      
      private function onDataLoading(param1:CommonEvent) : void
      {
         if(param1 == null)
         {
            return;
         }
         this.m_bLoading = param1.data as Boolean;
         this.setVisible();
      }
      
      private function onClose(param1:MouseEvent) : void
      {
         this.onTimeout();
      }
      
      private function onOver(param1:MouseEvent) : void
      {
         this.m_controller.useSystemCursor(true);
      }
      
      private function adjustPosition() : void
      {
         if(this.m_bg != null)
         {
            this.m_bg.width = 450;
            this.m_bg.height = 110;
         }
         x = stage.mouseX - this.width * 0.5;
         y = stage.stageHeight - 58 - this.height;
      }
      
      private function onMgrLinkClicked(param1:Event) : void
      {
         this.show(false);
         this.m_controller.module.app.dispatchEvent(new CommonEvent(Consts.MSG_SHOW_WAREHOUSE,{"openWithSeeds":true}));
      }
      
      private function createButtons() : void
      {
         this.m_closeBtn = Utils.getMaterial("PackClose") as SimpleButton;
         this.m_closeBtn.addEventListener(MouseEvent.CLICK,this.onClose);
         addChild(this.m_closeBtn);
         this.m_closeBtn.x = 435;
         this.m_closeBtn.y = 16;
         this.m_mgrLabel = new Label("到仓库管理",this.onMgrLinkClicked);
         this.m_mgrLabel.textDefaultFormat.color = 30148;
         this.m_mgrLabel.x = AlignUtil.right(width,this.m_mgrLabel.width);
         this.m_mgrLabel.y = 5;
         this.m_mgrLabel.useHandCursor = true;
         addChild(this.m_mgrLabel);
         this.m_emptyText = new TextField();
         this.m_emptyText.autoSize = TextFieldAutoSize.LEFT;
         this.m_emptyText.visible = false;
         this.m_emptyText.defaultTextFormat = new TextFormat("Verdana",16,null,null,null,null,null,null,TextFormatAlign.CENTER);
         this.m_emptyText.height = 35;
         this.m_emptyText.x = 40;
         this.m_emptyText.y = 50;
         this.m_emptyText.htmlText = "<a href=\'event:1\'><font color=\'#FF6600\'>" + Language.L["包裹里什么都没有，去商店里逛逛吧！"] + "</font></a>";
         this.m_emptyText.addEventListener(MouseEvent.CLICK,this.onEmptyTextClicked);
         addChild(this.m_emptyText);
         this.m_notOpenText = new TextField();
         this.m_notOpenText.autoSize = TextFieldAutoSize.LEFT;
         this.m_notOpenText.visible = false;
         this.m_notOpenText.defaultTextFormat = new TextFormat("Verdana",16,null,null,null,null,null,null,TextFormatAlign.CENTER);
         this.m_notOpenText.height = 35;
         this.m_notOpenText.x = 40;
         this.m_notOpenText.y = 50;
         this.m_notOpenText.htmlText = "<a href=\'event:1\'><font color=\'#FF6600\'>" + Language.L["包裹里什么都没有，去商店里逛逛吧！"] + "</font></a>";
         addChild(this.m_notOpenText);
         this.m_btnGoWarehouse = new Button();
         this.m_btnGoWarehouse.visible = false;
         this.m_btnGoWarehouse.addEventListener(MouseEvent.CLICK,this.onEmptyTextClicked);
         this.m_btnGoWarehouse.defaultSkin = Utils.getClass("ButtonBlue");
         this.m_btnGoWarehouse.text = Language.L["去商店"];
         this.m_btnGoWarehouse.x = this.m_emptyText.x + this.m_emptyText.width + 5;
         this.m_btnGoWarehouse.y = 49;
         this.m_btnGoWarehouse.width = 60;
         this.m_btnGoWarehouse.height = 24;
         addChild(this.m_btnGoWarehouse);
         this.m_dataLoading = new DataLoading();
         this.m_dataLoading.addEventListener(ViewEvent.LINK_CLICK,this.onLoadingLinkClicked,false,0,true);
         this.m_dataLoading.x = (width - this.m_dataLoading.width) / 2;
         this.m_dataLoading.y = (height - this.m_dataLoading.height) / 2 + 20;
         this.m_dataLoading.visible = false;
         addChild(this.m_dataLoading);
         this.m_switchBtn = Utils.getMaterial("PackageTab") as MovieClip;
         this.m_switchBtn.x = 35;
         this.m_switchBtn.y = -2;
         this.m_switchBtn.addEventListener(Consts.MSG_SWITCH_TO_SEED,this.selectNormal);
         this.m_switchBtn.addEventListener(Consts.MSG_SWITCH_TO_TOOL,this.selectTool);
         this.m_switchBtn.addEventListener(Consts.MSG_SWITCH_TO_FISH,this.selectFish);
         addChild(this.m_switchBtn);
      }
      
      private function onClick(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      private function onChildOver(param1:ViewEvent) : void
      {
         var _loc5_:Object = null;
         if(param1 == null || param1.data == null)
         {
            return;
         }
         var _loc2_:BagItem = param1.data as BagItem;
         if(_loc2_ == null)
         {
            return;
         }
         var _loc3_:String = "";
         var _loc4_:String = _loc2_._type.toString();
         if(_loc4_ == Consts.ITEM_TYPE_SEED)
         {
            _loc3_ = _loc2_._name + "种子" + "\n";
            if(_loc2_._level >= 0)
            {
               _loc3_ += _loc2_._level + " 级作物，" + _loc2_._lifeCycle + " 小时成熟";
            }
         }
         else if(_loc4_ == Consts.ITEM_TYPE_TOOL || _loc4_ == Consts.ITEM_TYPE_FISHFEED || _loc4_ == Consts.ITEM_TYPE_WEAPON)
         {
            _loc3_ = _loc2_._name + "\n" + _loc2_._depict;
         }
         else if(_loc4_ == Consts.ITEM_TYPE_FISH)
         {
            _loc5_ = Settings.getInstance().getFishByID(_loc2_._cId.toString());
            if(_loc5_ == null)
            {
               return;
            }
            _loc3_ = _loc2_._name + "\n" + "占用容量" + _loc5_["pool_size"] + "，" + _loc2_._lifeCycle + " 小时成熟";
         }
         this.m_controller.showTip(Consts.TIP_NAME_MOUSE,_loc3_);
      }
      
      private function selectFish(param1:Event = null) : void
      {
         this._selectTab = "fish";
         this.m_mgrLabel.visible = false;
         this.m_list.dataProvider = this.m_model.fillterType("fish");
         if(Session.getInstance().m_waterPoolOpen == false)
         {
            this.m_list.visible = false;
            this.m_notOpenText.visible = true;
            this.m_notOpenText.htmlText = "<font color=\'#FF6600\'>您尚未开通池塘</font>";
            this.m_emptyText.visible = false;
            this.m_btnGoWarehouse.visible = false;
            return;
         }
         this.setVisible();
      }
      
      public function show(param1:Boolean) : void
      {
         if(param1 == true)
         {
            this.showCloseBtnTips();
            this.visible = true;
            this._api.hideBeastPack();
         }
         else
         {
            this.visible = false;
         }
      }
      
      public function toggleVisible() : void
      {
         if(this.visible == true)
         {
            this.show(false);
         }
         else
         {
            this.show(true);
         }
      }
      
      public function updateBag(param1:int) : void
      {
         var _loc2_:int = 0;
         if(this.m_list.hScrollBar != null)
         {
            _loc2_ = int(this.m_list.hScrollBar.scrollPosition);
         }
         if(param1.toString() == Consts.ITEM_TYPE_SEED)
         {
            this.m_list.dataProvider = this.m_model.fillterType("normal");
         }
         else if(param1.toString() == Consts.ITEM_TYPE_FISH)
         {
            this.m_list.dataProvider = this.m_model.fillterType("fish");
         }
         else
         {
            this.m_list.dataProvider = this.m_model.fillterType("tool");
         }
         if(_loc2_ > 0)
         {
            this.m_list.hScrollBar.scrollPosition = _loc2_;
         }
      }
   }
}

