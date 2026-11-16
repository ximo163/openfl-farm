package mc.view.farm.packBar
{
   import com.minutes.ui.collections.SimpleCollection;
   import com.minutes.ui.control.LipiButton;
   import com.minutes.ui.core.LipiSkin;
   import com.qzone.qui.controls.HList;
   import com.qzone.qui.controls.Label;
   import com.qzone.qui.events.ScrollEvent;
   import com.qzone.utils.AlignUtil;
   import common.CommonData;
   import common.MaterialLib;
   import common.Utils;
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
   import mc.control.Command;
   import mc.control.FarmCommand;
   import mc.control.ViewControl;
   import mc.events.CommonEvent;
   import mc.events.TipEvent;
   import mc.events.WindowEvent;
   import mc.model.FarmData;
   import mc.model.MData;
   import mc.model.MainData;
   import mc.view.ViewEvent;
   import mc.view.common.DataLoading;
   import mc.view.farm.Research.ResearchModel;
   import mc.view.main.WindowControl.WControl;
   import mc.view.main.cursor.Cursor;
   
   public class PackBar extends SimpleCollection
   {
      
      private var farmData:FarmData;
      
      private var mainData:MainData;
      
      private var lib:MaterialLib = MaterialLib.getInstance();
      
      private var hlist:HList;
      
      private var _closeBtnTipsBg:Sprite;
      
      private var _closeBtn:SimpleButton;
      
      private var hideTimer:uint;
      
      private var dataLoading:DataLoading;
      
      private var lButton:SimpleButton;
      
      private var rButton:SimpleButton;
      
      private var m_mgrLabel:Label;
      
      private var nullText:TextField;
      
      private var _tab:MovieClip;
      
      private var childBar:Sprite;
      
      private var bakData:Array;
      
      private var _selectData:Array;
      
      private var _selectType:String = "normal";
      
      private var _scrollNum:int;
      
      private var _showTipsEndTime:String = "7/26/2012 23:59:5";
      
      private var gotoButton:LipiButton;
      
      public function PackBar()
      {
         super();
         bg = this.lib.getMaterial("PackBarBg") as Sprite;
         width = 390;
         height = 120;
         bg.y = -30;
         this.mainData = MData.getInstance().mainData;
         Command.getInstance().mainCommand.addEventListener(FarmData.USE_ANIMAL_CUB,this.onUseAnimalCub,false,0,true);
         ViewControl.getInstance().addEventListener("animal_change",this.onAnimalChange,false,0,true);
         this._closeBtn = this.lib.getMaterial("PackClose") as SimpleButton;
         this._closeBtn.addEventListener(MouseEvent.CLICK,this.onClose);
         addChild(this._closeBtn);
         this._closeBtn.x = 370;
         this._closeBtn.y = -10;
         this.m_mgrLabel = new Label("到仓库管理",this.onMgrLinkClicked);
         this.m_mgrLabel.textDefaultFormat.color = 30148;
         this.m_mgrLabel.x = AlignUtil.right(width,this.m_mgrLabel.width) - 10;
         this.m_mgrLabel.y = -20;
         this.m_mgrLabel.useHandCursor = true;
         addChild(this.m_mgrLabel);
         this.hlist = new HList();
         this.hlist.defaultSkin = null;
         this.hlist.itemRenderer = PackItem;
         this.hlist.x = 35;
         this.hlist.y = 5;
         this.hlist.rowCount = 5;
         this.hlist.rowHeight = 63;
         this.hlist.height = 80;
         addChild(this.hlist);
         this.nullText = new TextField();
         this.nullText.autoSize = TextFieldAutoSize.LEFT;
         this.nullText.visible = false;
         this.nullText.defaultTextFormat = new TextFormat("Verdana",16,null,null,null,null,null,null,TextFormatAlign.CENTER);
         this.nullText.height = 35;
         this.nullText.y = 25;
         this.nullText.x = 20;
         this.nullText.htmlText = "<a href=\'event:1\'><font color=\'#FF6600\'>包里什么都没有，赶快去商店吧</font></a>";
         this.nullText.addEventListener(MouseEvent.CLICK,this.nullTextClick);
         addChild(this.nullText);
         this.gotoButton = new LipiButton();
         this.gotoButton.visible = false;
         this.gotoButton.addEventListener(MouseEvent.CLICK,this.nullTextClick);
         this.gotoButton.bgAlpha = 0;
         this.gotoButton.bgSkin = new LipiSkin(MaterialLib.getInstance().getClass("ButtonBlue"));
         this.gotoButton.label = "去商店";
         this.gotoButton.textColor = 16777215;
         this.gotoButton.x = this.nullText.x + this.nullText.width + 5;
         this.gotoButton.y = 24;
         this.gotoButton.width = 60;
         this.gotoButton.height = 24;
         addChild(this.gotoButton);
         this.dataLoading = new DataLoading();
         this.dataLoading.addEventListener(ViewEvent.LINK_CLICK,this.linkClick);
         this.dataLoading.x = width / 2;
         this.dataLoading.y = height / 2;
         this.dataLoading.visible = false;
         addChild(this.dataLoading);
         this.farmData = MData.getInstance().farmData;
         if(this.farmData.userSeed != null)
         {
            this.hlist.dataProvider = this.farmData.userSeed;
         }
         this.farmData.addEventListener(FarmData.USER_SEED,this.userSeedChange,false,0,true);
         this.farmData.addEventListener(FarmData.USER_SEED_LOADING,this.userSeedLoading,false,0,true);
         this.farmData.addEventListener(FarmData.USER_SEED_ERR,this.userSeedErr,false,0,true);
         addEventListener(MouseEvent.ROLL_OVER,this.onOver);
         addEventListener(MouseEvent.CLICK,this.onClick);
         addEventListener(ViewEvent.CHILD_CLICK,this.childClick);
         addEventListener(ViewEvent.CHILD_OVER,this.childOver);
         addEventListener(ViewEvent.CHILD_OUT,this.childOut);
         this._tab = MaterialLib.getInstance().getMaterial("PackageTab") as MovieClip;
         this._tab.addEventListener("tool",this.selectNormal);
         this._tab.addEventListener("tool2",this.selectTool);
         this._tab.x = 35;
         this._tab.y = -28;
         addChild(this._tab);
         this.setVisible();
      }
      
      public function set scrollNum(param1:int) : void
      {
         if(this.hlist.hScrollBar != null)
         {
            this._scrollNum = param1;
         }
         else
         {
            this._scrollNum = 0;
         }
         trace("set _scrollNum:" + this._scrollNum);
      }
      
      private function hideThis() : void
      {
         this.visible = false;
      }
      
      private function childOver(param1:ViewEvent) : void
      {
         var _loc3_:String = null;
         var _loc2_:TipEvent = new TipEvent(TipEvent.TIP_SHOW);
         _loc2_.tipType = "MouseTip";
         if(param1.data.hasOwnProperty("type"))
         {
            _loc3_ = param1.data["tDesc"] ? param1.data["tDesc"] : "";
            if(param1.data.type == "10" && param1.data["appid"] == 3)
            {
               _loc3_ = "\n 驱赶武器，去扩展场景使用";
            }
            _loc2_.tipArgument = param1.data["tName"] + "\n" + _loc3_;
         }
         ViewControl.getInstance().dispatchEvent(_loc2_);
      }
      
      public function get scrollNum() : int
      {
         if(this.hlist.hScrollBar != null)
         {
            return this._scrollNum < this.hlist.hScrollBar.maxScrollPosition ? this._scrollNum : int(this.hlist.hScrollBar.maxScrollPosition);
         }
         return 0;
      }
      
      private function selectNormal(param1:Event = null) : void
      {
         if(this._selectType != "normal")
         {
            this.scrollNum = 0;
         }
         this._selectType = "normal";
         if(this.farmData.userSeed != null)
         {
            if(this.mainData.me)
            {
               this._selectData = this.fillterType(this.bakData,"normal");
            }
            else
            {
               this._selectData = this.fillterData(this.fillterType(this.bakData,"normal"));
            }
            this.hlist.dataProvider = this._selectData;
            if(this.hlist.hScrollBar != null)
            {
               this.hlist.hScrollBar.scrollPosition = this.scrollNum;
            }
         }
         this.m_mgrLabel.visible = true;
         this.setVisible();
         this.setButtonEnabled();
      }
      
      private function fillterDenShedData(param1:Array) : Array
      {
         var _loc2_:Number = 0;
         while(param1[_loc2_])
         {
            if(param1[_loc2_].type == "12")
            {
               param1[_loc2_]["tDesc"] = "点击9级以上的窝棚，在科研时使用。";
               param1[_loc2_]["lock"] = true;
            }
            _loc2_++;
         }
         return param1;
      }
      
      private function fillterData(param1:Array) : Array
      {
         var _loc2_:Number = 0;
         while(param1[_loc2_])
         {
            if(param1[_loc2_].type == "7")
            {
               param1[_loc2_]["tDesc"] = "只能在自己牧场使用";
               param1[_loc2_]["lock"] = true;
            }
            if(param1[_loc2_].type == "9")
            {
               param1[_loc2_]["tDesc"] = "只能放入自己牧场";
               param1[_loc2_]["lock"] = true;
            }
            if(param1[_loc2_].type == "2")
            {
               param1[_loc2_]["tDesc"] = "请在活动界面使用";
               param1[_loc2_]["lock"] = true;
            }
            _loc2_++;
         }
         return param1;
      }
      
      private function fillterType(param1:Array, param2:String = "normal") : Array
      {
         var _loc5_:Object = null;
         var _loc3_:Array = [];
         var _loc4_:Number = 0;
         while(param1[_loc4_])
         {
            _loc5_ = param1[_loc4_];
            if(param2 == "normal" && (_loc5_.type == "4" || _loc5_.type == "9"))
            {
               _loc3_.push(_loc5_);
            }
            else if(param2 == "tool" && (_loc5_.typeP == 1 || _loc5_.type == "12" || _loc5_.type == "7" || _loc5_.type == "10" || _loc5_.type == "2"))
            {
               _loc3_.push(_loc5_);
            }
            _loc4_++;
         }
         return _loc3_;
      }
      
      private function childOut(param1:ViewEvent) : void
      {
         var _loc2_:TipEvent = new TipEvent(TipEvent.TIP_HIDE);
         ViewControl.getInstance().dispatchEvent(_loc2_);
      }
      
      private function setButtonEnabled() : void
      {
      }
      
      private function nullTextClick(param1:Event) : void
      {
         if(this._selectType == "normal")
         {
            WControl.openForName("shop",{"tabSelected":1});
         }
         else
         {
            WControl.openForName("shop",{"tabSelected":2});
         }
      }
      
      private function ScrollHandler(param1:ScrollEvent) : void
      {
         this.scrollNum = param1.position;
      }
      
      private function userSeedChange(param1:Event = null) : void
      {
         if(this.farmData.userSeed != null)
         {
            this.bakData = Utils.objectCopy(this.farmData.userSeed) as Array;
         }
         if(this._selectType == "normal")
         {
            this._tab.gotoAndStop(1);
            this.selectNormal();
         }
         else
         {
            this._tab.gotoAndStop(2);
            this.selectTool();
         }
      }
      
      private function rButtonClick(param1:MouseEvent) : void
      {
         this.setButtonEnabled();
      }
      
      private function setVisible() : void
      {
         if(this.farmData.userSeedLoading == true)
         {
            this.hlist.visible = false;
            this.dataLoading.visible = true;
            this.gotoButton.visible = this.nullText.visible = false;
            if(this.hlist.hScrollBar != null)
            {
               this.hlist.hScrollBar.removeEventListener(ScrollEvent.SCROLL,this.ScrollHandler);
            }
         }
         else if(this._selectData != null && this._selectData.length > 0)
         {
            this.hlist.visible = true;
            this.dataLoading.visible = false;
            this.gotoButton.visible = this.nullText.visible = false;
            if(this.hlist.hScrollBar != null)
            {
               this.hlist.hScrollBar.removeEventListener(ScrollEvent.SCROLL,this.ScrollHandler);
               this.hlist.hScrollBar.addEventListener(ScrollEvent.SCROLL,this.ScrollHandler);
            }
         }
         else
         {
            this.hlist.visible = false;
            this.dataLoading.visible = false;
            this.gotoButton.visible = this.nullText.visible = true;
            if(this.hlist.hScrollBar != null)
            {
               this.hlist.hScrollBar.removeEventListener(ScrollEvent.SCROLL,this.ScrollHandler);
            }
         }
      }
      
      private function stageClick(param1:MouseEvent) : void
      {
         this.visible = false;
         if(stage)
         {
            stage.removeEventListener(MouseEvent.CLICK,this.stageClick);
         }
      }
      
      private function selectTool(param1:Event = null) : void
      {
         if(this._selectType != "tool")
         {
            this.scrollNum = 0;
         }
         this._selectType = "tool";
         this.m_mgrLabel.visible = false;
         if(this.farmData.userSeed != null)
         {
            if(this.mainData.me)
            {
               this._selectData = this.fillterType(this.bakData,"tool");
            }
            else
            {
               this._selectData = this.fillterData(this.fillterType(this.bakData,"tool"));
            }
            this._selectData = this.fillterDenShedData(this._selectData);
            this.hlist.dataProvider = this._selectData;
            if(this.hlist.hScrollBar != null)
            {
               this.hlist.hScrollBar.scrollPosition = this.scrollNum;
            }
         }
         this.setVisible();
         this.setButtonEnabled();
      }
      
      private function linkClick(param1:ViewEvent) : void
      {
         if(param1.data == "reload")
         {
            Command.getInstance().farmCommand.getUserSeed(true);
            this.dataLoading.visible = true;
         }
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
            this._closeBtnTipsBg.x = this._closeBtn.x - 37;
            this._closeBtnTipsBg.y = this._closeBtn.y - 40;
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
      
      private function userSeedLoading(param1:Event) : void
      {
         this.setVisible();
         this.setButtonEnabled();
      }
      
      private function onAnimalChange(param1:Event) : void
      {
         var _loc2_:Boolean = false;
         var _loc3_:ResearchModel = ResearchModel.gi();
         var _loc4_:int = int(_loc3_.DenShedLevel["den"]);
         var _loc5_:int = MData.getInstance().mainData.getAnimalNum(_loc4_,"窝");
         var _loc6_:int = int(MData.getInstance().mainData.host["animal1"]);
         if(_loc6_ == _loc5_)
         {
            _loc2_ = true;
         }
         _loc4_ = int(_loc3_.DenShedLevel["shed"]);
         _loc5_ = MData.getInstance().mainData.getAnimalNum(_loc4_,"棚");
         _loc6_ = int(MData.getInstance().mainData.host["animal2"]);
         if(_loc2_ && _loc6_ == _loc5_)
         {
            this.hideThis();
         }
      }
      
      private function onUseAnimalCub(param1:CommonEvent) : void
      {
         var _loc5_:Object = null;
         var _loc7_:PackItem = null;
         var _loc2_:String = param1.data["cId"];
         var _loc3_:Array = this.hlist.dataProvider;
         var _loc4_:int = int(_loc3_.length);
         var _loc6_:int = 0;
         while(_loc6_ < _loc4_)
         {
            if(_loc2_ == _loc3_[_loc6_]["tId"])
            {
               --_loc3_[_loc6_]["amount"];
               if(_loc3_[_loc6_]["amount"] == 0)
               {
                  _loc3_.splice(_loc6_,1);
                  this.hlist.dataProvider = _loc3_;
                  if(this.hlist.hScrollBar != null)
                  {
                     this.hlist.hScrollBar.scrollPosition = this.scrollNum;
                  }
               }
               break;
            }
            _loc6_++;
         }
         _loc4_ = (this.hlist.getChildAt(0) as Sprite).numChildren;
         _loc6_ = 0;
         while(_loc6_ < _loc4_)
         {
            _loc7_ = (this.hlist.getChildAt(0) as Sprite).getChildAt(_loc6_) as PackItem;
            if(_loc7_.data["tId"] == _loc2_)
            {
               _loc7_.data = _loc7_.data;
            }
            _loc6_++;
         }
      }
      
      private function childClick(param1:ViewEvent) : void
      {
         var _loc2_:SelectWindow = null;
         if(param1.data.hasOwnProperty("type"))
         {
            if(param1.data["type"] == "4" && param1.data["tId"] == "40")
            {
               _loc2_ = new SelectWindow();
               _loc2_.confirmFn = this.selectMuCao;
               WControl.open(_loc2_);
            }
            else if(param1.data["type"] == "4")
            {
               Cursor.setCursor("CursorTool",param1.data);
            }
            else if(param1.data["type"] == "7")
            {
               Cursor.setCursor("CursorTool",param1.data);
            }
            else if(param1.data["type"] == "9")
            {
               Cursor.setCursor("CursorTool",param1.data);
            }
         }
      }
      
      private function onClose(param1:MouseEvent) : void
      {
         this.hideThis();
      }
      
      private function onOver(param1:MouseEvent) : void
      {
         Cursor.useSystem(true);
      }
      
      private function onMgrLinkClicked(param1:Event) : void
      {
         var _loc2_:WindowEvent = new WindowEvent(WindowEvent.OPEN);
         _loc2_.windowName = "sellCub";
         ViewControl.getInstance().dispatchEvent(_loc2_);
      }
      
      private function userSeedErr(param1:Event) : void
      {
         this.dataLoading.errorText = this.farmData.userSeedErr;
      }
      
      override public function set visible(param1:Boolean) : void
      {
         if(param1)
         {
            this.showCloseBtnTips();
         }
         super.visible = param1;
      }
      
      private function selectMuCao(param1:Number) : void
      {
         var _loc2_:FarmCommand = null;
         _loc2_ = Command.getInstance().farmCommand;
         _loc2_.addFood(param1);
      }
      
      private function onClick(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      override public function get visible() : Boolean
      {
         return super.visible;
      }
      
      private function lButtonClick(param1:MouseEvent) : void
      {
         this.setButtonEnabled();
      }
   }
}

