package mc.view.farm
{
   import com.minutes.ui.collections.SimpleCollection;
   import common.MaterialLib;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import mc.api.BeastAPI;
   import mc.control.Command;
   import mc.model.FarmData;
   import mc.model.MData;
   import mc.model.MainData;
   import mc.model.OpenControl;
   import mc.view.common.Tool_Wild;
   import mc.view.farm.land.FarmOperateFloating;
   import mc.view.farm.toolBar.ToolBase;
   import mc.view.farm.toolBar.Tool_Arrow;
   import mc.view.farm.toolBar.Tool_ClearBB;
   import mc.view.farm.toolBar.Tool_Flapper;
   import mc.view.farm.toolBar.Tool_Fly;
   import mc.view.farm.toolBar.Tool_Pack;
   import mc.view.farm.toolBar.Tool_ShengChan;
   import mc.view.farm.toolBar.Tool_ShouHuoAll;
   import mc.view.farm.toolBar.Tool_Theft;
   import mc.view.farm.toolBar.Tool_Tools;
   import mc.view.main.cursor.Cursor;
   import mc.view.main.floating.Float;
   import mc.view.main.tip.TipControl;
   
   public class ToolBar extends SimpleCollection
   {
      
      private var farmData:FarmData;
      
      private var aTool_Flapper:Tool_Flapper;
      
      private var aTool_Arrow:Tool_Arrow;
      
      private var lib:MaterialLib;
      
      private var aTool_Theft:Tool_Theft;
      
      private var aTool_ClearBB:Tool_ClearBB;
      
      private var _showMe:Boolean = true;
      
      private var aTool_ShengChan:Tool_ShengChan;
      
      private var aTool_Wild:Tool_Wild;
      
      private var aTool_Pack:Tool_Pack;
      
      private var aTool_ShouHuoAll:Tool_ShouHuoAll;
      
      private var maindata:MainData;
      
      private var aTool_Tools:Tool_Tools;
      
      private var aTool_Fly:Tool_Fly;
      
      private var wildOpen:Boolean = false;
      
      public function ToolBar()
      {
         super();
         this.lib = MaterialLib.getInstance();
         bg = this.lib.getMaterial("ToolBarBg") as Sprite;
         bg.height = 50;
         this.addTool();
         this.setPosition();
         this.showMe = true;
         addEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage,false,0,true);
         this.farmData = MData.getInstance().farmData;
         this.farmData.addEventListener(FarmData.FARM_OPERATE,this.farmOperate,false,0,true);
         this.maindata = MData.getInstance().mainData;
         this.maindata.addEventListener(MainData.HOST_CHANGE,this.onHostChange);
         BeastAPI.getInstance().addEventListener(EvtAPI.REWARD_CHANGE,this.onRewardChange);
      }
      
      private function toolClick(param1:MouseEvent) : void
      {
         if(param1.currentTarget == this.aTool_Arrow)
         {
            Cursor.setCursor("CursorArrow");
         }
         else if(param1.currentTarget == this.aTool_ShengChan)
         {
            if(Cursor.name != "Cursor_ShengChan")
            {
               Cursor.setCursor("Cursor_ShengChan");
            }
            else
            {
               Cursor.setCursor("CursorArrow");
            }
         }
         else if(param1.currentTarget == this.aTool_Theft)
         {
            if(Cursor.name != "Cursor_Theft")
            {
               Cursor.setCursor("Cursor_Theft");
            }
            else
            {
               Cursor.setCursor("CursorArrow");
            }
         }
         else if(param1.currentTarget == this.aTool_Pack)
         {
            Cursor.setCursor("CursorArrow");
            dispatchEvent(new Event("packClick"));
         }
         else if(param1.currentTarget == this.aTool_Fly)
         {
            if(Cursor.name != "Cursor_Fly")
            {
               Cursor.setCursor("Cursor_Fly");
            }
            else
            {
               Cursor.setCursor("CursorArrow");
            }
         }
         else if(param1.currentTarget == this.aTool_Flapper)
         {
            if(Cursor.name != "Cursor_Flapper")
            {
               Cursor.setCursor("Cursor_Flapper");
            }
            else
            {
               Cursor.setCursor("CursorArrow");
            }
         }
         else if(param1.currentTarget == this.aTool_ClearBB)
         {
            Cursor.setCursor("Cursor_ClearBB");
         }
         else if(param1.currentTarget == this.aTool_Tools)
         {
            dispatchEvent(new Event("toolsClick"));
         }
         else if(param1.currentTarget == this.aTool_ShouHuoAll)
         {
            Cursor.setCursor("Cursor_ShouHuoAll");
         }
         else if(param1.currentTarget == this.aTool_Wild)
         {
            if(this.checkWildOpen() == false)
            {
               return;
            }
            Cursor.setCursor("CursorArrow");
            dispatchEvent(new Event("beast"));
         }
         MainData.autoCursor = false;
         param1.stopPropagation();
      }
      
      private function toolRollOut(param1:MouseEvent) : void
      {
         TipControl.hide();
      }
      
      private function checkWildOpen() : Boolean
      {
         var _loc1_:int = OpenControl.getOpenExpLv("wild");
         var _loc2_:int = OpenControl.getOpenYellowLv("wild");
         if(this.wildOpen)
         {
            return true;
         }
         if(_loc1_ != 9999)
         {
            Command.getInstance().mainCommand.alertWindow("error","野生动物目前仅供农场" + _loc1_ + "级及以上用户优先体验");
         }
         else
         {
            Command.getInstance().mainCommand.alertWindow("error","放养野生动物功能正处于内测阶段，暂供VIP" + _loc2_ + "级及以上用户优先体验，后续逐步开放，敬请期待！<a href=\'event:wildInfo\'>点击查看详情 >></a>");
         }
         return false;
      }
      
      private function onAddedToStage(param1:Event) : void
      {
         removeEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage);
      }
      
      private function toolRollOver(param1:MouseEvent) : void
      {
         TipControl.show("MouseTip",(param1.currentTarget as ToolBase).tipText);
      }
      
      public function set showMe(param1:Boolean) : void
      {
         this._showMe = param1;
         this.aTool_Fly.visible = !param1;
         this.aTool_ShengChan.visible = param1;
         this.aTool_Theft.visible = !param1;
         this.setPosition();
      }
      
      private function setPosition() : void
      {
         var _loc6_:DisplayObject = null;
         var _loc1_:int = 15;
         var _loc2_:int = 52;
         var _loc3_:int = 5;
         var _loc4_:Array = [this.aTool_Arrow,this.aTool_Pack,this.aTool_Fly,this.aTool_Flapper,this.aTool_ClearBB,this.aTool_Tools,this.aTool_Wild,this.aTool_ShengChan,this.aTool_Theft,this.aTool_ShouHuoAll];
         var _loc5_:int = 0;
         while(_loc5_ < _loc4_.length)
         {
            _loc6_ = _loc4_[_loc5_] as DisplayObject;
            if(_loc6_.visible)
            {
               _loc6_.x = Math.floor(_loc1_);
               _loc6_.y = Math.floor(_loc3_);
               _loc1_ += _loc2_;
            }
            _loc5_++;
         }
         width = _loc1_ + 12;
         if(stage != null)
         {
            x = Math.floor((stage.stageWidth - width) / 2);
         }
      }
      
      private function farmOperate(param1:Event = null) : void
      {
         var _loc3_:FarmOperateFloating = null;
         var _loc4_:DisplayObject = null;
         var _loc5_:String = null;
         var _loc2_:String = this.farmData.farmOperate["type"];
         if(_loc2_ == "toolBar")
         {
            _loc3_ = new FarmOperateFloating(3000);
            _loc3_.text = this.farmData.farmOperate["text"];
            _loc5_ = this.farmData.farmOperate["toolName"];
            switch(_loc5_)
            {
               case "package":
                  _loc4_ = this.aTool_Pack;
            }
            _loc3_.x = _loc4_.localToGlobal(new Point(0,0)).x + _loc4_.width / 2;
            _loc3_.y = _loc4_.localToGlobal(new Point(0,0)).y + 30;
            Float.open(_loc3_);
         }
      }
      
      private function hideFn() : void
      {
         dispatchEvent(new Event("hidebeast"));
      }
      
      public function get showMe() : Boolean
      {
         return this._showMe;
      }
      
      public function changeBarVisible() : void
      {
         if(this.maindata.me)
         {
            this.aTool_ShouHuoAll.tipText = "一键收获";
            this.aTool_Pack.tipText = "我的物品包";
         }
         else
         {
            this.aTool_ShouHuoAll.tipText = "一键收取";
            this.aTool_Pack.tipText = "可对好友牧场使用的物品";
         }
         if(OpenControl.open("harvestall"))
         {
            this.aTool_ShouHuoAll.visible = true;
         }
         else if(this.maindata.host["yellowstatus"] >= 1 && this.maindata.host["yellowlevel"] >= OpenControl.getOpenYellowLv("harvestall"))
         {
            this.aTool_ShouHuoAll.visible = true;
         }
         else
         {
            this.aTool_ShouHuoAll.visible = false;
         }
         this.setPosition();
      }
      
      private function onHostChange(param1:Event) : void
      {
         var _loc2_:Boolean = this.maindata.host["yellowstatus"] >= 1 ? true : false;
         var _loc3_:int = OpenControl.getOpenExpLv("wild");
         var _loc4_:int = OpenControl.getOpenYellowLv("wild");
         if(OpenControl.open("wild"))
         {
            this.wildOpen = true;
         }
         else if(_loc2_ && this.maindata.host["yellowlevel"] >= _loc4_)
         {
            this.wildOpen = true;
         }
         else if(this.maindata.host["flv"] >= _loc3_)
         {
            this.wildOpen = true;
         }
         else
         {
            this.wildOpen = false;
         }
         var _loc5_:MovieClip = this.aTool_Wild.forbidden(true,MaterialLib.getInstance().getMaterial("Icon_No") as MovieClip) as MovieClip;
         if(this.wildOpen)
         {
            this.aTool_Wild.forbidden(false);
            this.aTool_Wild.tipText = "领养、放养野生动物";
         }
         else if(_loc3_ != 9999)
         {
            this.aTool_Wild.forbidden(true,_loc5_);
            this.aTool_Wild.tipText = "野生动物目前仅供农场" + _loc3_ + "级及以上用户优先体验";
         }
         else
         {
            this.aTool_Wild.forbidden(true,_loc5_);
            this.aTool_Wild.tipText = "野生动物正在内测，暂供VIP" + OpenControl.getOpenYellowLv("wild") + "级及以上用户优先体验";
         }
         this.setPosition();
      }
      
      private function addTool() : void
      {
         this.aTool_Arrow = new Tool_Arrow();
         this.aTool_Arrow.tipText = "可拖动屏幕";
         this.aTool_Arrow.addEventListener(MouseEvent.CLICK,this.toolClick);
         this.aTool_Arrow.addEventListener(MouseEvent.ROLL_OVER,this.toolRollOver);
         this.aTool_Arrow.addEventListener(MouseEvent.ROLL_OUT,this.toolRollOut);
         addChild(this.aTool_Arrow);
         this.aTool_Pack = new Tool_Pack();
         this.aTool_Pack.tipText = "我的物品包";
         this.aTool_Pack.addEventListener(MouseEvent.CLICK,this.toolClick);
         this.aTool_Pack.addEventListener(MouseEvent.ROLL_OVER,this.toolRollOver);
         this.aTool_Pack.addEventListener(MouseEvent.ROLL_OUT,this.toolRollOut);
         addChild(this.aTool_Pack);
         this.aTool_ShengChan = new Tool_ShengChan();
         this.aTool_ShengChan.tipText = "1抓去生产 2收获农副产品 3收获动物";
         this.aTool_ShengChan.addEventListener(MouseEvent.CLICK,this.toolClick);
         this.aTool_ShengChan.addEventListener(MouseEvent.ROLL_OVER,this.toolRollOver);
         this.aTool_ShengChan.addEventListener(MouseEvent.ROLL_OUT,this.toolRollOut);
         addChild(this.aTool_ShengChan);
         this.aTool_Theft = new Tool_Theft();
         this.aTool_Theft.tipText = "1帮好友抓去生产 2收取好友农副产品";
         this.aTool_Theft.addEventListener(MouseEvent.CLICK,this.toolClick);
         this.aTool_Theft.addEventListener(MouseEvent.ROLL_OVER,this.toolRollOver);
         this.aTool_Theft.addEventListener(MouseEvent.ROLL_OUT,this.toolRollOut);
         addChild(this.aTool_Theft);
         this.aTool_Fly = new Tool_Fly();
         this.aTool_Fly.tipText = "放蚊子";
         this.aTool_Fly.addEventListener(MouseEvent.CLICK,this.toolClick);
         this.aTool_Fly.addEventListener(MouseEvent.ROLL_OVER,this.toolRollOver);
         this.aTool_Fly.addEventListener(MouseEvent.ROLL_OUT,this.toolRollOut);
         addChild(this.aTool_Fly);
         this.aTool_Flapper = new Tool_Flapper();
         this.aTool_Flapper.tipText = "拍蚊子";
         this.aTool_Flapper.addEventListener(MouseEvent.CLICK,this.toolClick);
         this.aTool_Flapper.addEventListener(MouseEvent.ROLL_OVER,this.toolRollOver);
         this.aTool_Flapper.addEventListener(MouseEvent.ROLL_OUT,this.toolRollOut);
         addChild(this.aTool_Flapper);
         this.aTool_ShouHuoAll = new Tool_ShouHuoAll();
         this.aTool_ShouHuoAll.tipText = "一键收获";
         this.aTool_ShouHuoAll.addEventListener(MouseEvent.CLICK,this.toolClick);
         this.aTool_ShouHuoAll.addEventListener(MouseEvent.ROLL_OVER,this.toolRollOver);
         this.aTool_ShouHuoAll.addEventListener(MouseEvent.ROLL_OUT,this.toolRollOut);
         addChild(this.aTool_ShouHuoAll);
         this.aTool_ClearBB = new Tool_ClearBB();
         this.aTool_ClearBB.tipText = "1清理动物的便便 2赶走动物";
         this.aTool_ClearBB.addEventListener(MouseEvent.CLICK,this.toolClick);
         this.aTool_ClearBB.addEventListener(MouseEvent.ROLL_OVER,this.toolRollOver);
         this.aTool_ClearBB.addEventListener(MouseEvent.ROLL_OUT,this.toolRollOut);
         addChild(this.aTool_ClearBB);
         this.aTool_Tools = new Tool_Tools();
         this.aTool_Tools.tipText = "更多好玩";
         this.aTool_Tools.addEventListener(MouseEvent.CLICK,this.toolClick);
         this.aTool_Tools.addEventListener(MouseEvent.ROLL_OVER,this.toolRollOver);
         this.aTool_Tools.addEventListener(MouseEvent.ROLL_OUT,this.toolRollOut);
         addChild(this.aTool_Tools);
         this.aTool_Wild = new Tool_Wild();
         this.aTool_Wild.tipText = "领养、放养野生动物";
         this.aTool_Wild.addEventListener(MouseEvent.CLICK,this.toolClick);
         this.aTool_Wild.addEventListener(MouseEvent.ROLL_OVER,this.toolRollOver);
         this.aTool_Wild.addEventListener(MouseEvent.ROLL_OUT,this.toolRollOut);
         addChild(this.aTool_Wild);
      }
      
      private function onRewardChange(param1:EvtAPI) : void
      {
         this.aTool_Wild.actived = param1.data as String;
      }
   }
}

