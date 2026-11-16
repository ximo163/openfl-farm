package mc.view.main.head
{
   import com.minutes.ui.collections.SimpleCollection;
   import common.LocalData;
   import common.MaterialLib;
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.geom.Point;
   import mc.api.BeastAPI;
   import mc.control.Command;
   import mc.control.ViewControl;
   import mc.events.WindowEvent;
   import mc.model.MData;
   import mc.model.MainData;
   import mc.view.ViewEvent;
   import mc.view.main.floating.Float;
   
   public class HeadBar extends SimpleCollection
   {
      
      private var _personInfo:PersonInfo;
      
      private var mainData:MainData;
      
      private var na:NumAnimation;
      
      public var headToolBar:HeadToolBar;
      
      public function HeadBar()
      {
         super();
         bg = MaterialLib.getInstance().getMaterial("HeadBg") as Sprite;
         this.mouseEnabled = false;
         addEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage);
      }
      
      private function setPersonInfo() : void
      {
         if(this.mainData.host != null)
         {
            this._personInfo.userName = this.mainData.host["userName"];
            if(!this.mainData.host.hasOwnProperty("yellowstatus") || this.mainData.host["yellowstatus"] == 0)
            {
               this._personInfo.color = Level.BLUE;
            }
            else
            {
               this._personInfo.color = Level.YELLOW;
               this._personInfo.vip = "VipL" + this.mainData.host["yellowlevel"];
            }
            if(this.mainData.me == true && LocalData.mode == "qzone")
            {
               this.mainData.host["headPic"] = LocalData.getInstance().getObject("OwnerHead");
            }
            this._personInfo.url = this.mainData.host["headPic"];
            this._personInfo.goldValue = this.mainData.host["money"];
            this._personInfo.rpValue = this.mainData.host["moralexp"];
            this._personInfo.exp = this.mainData.host["exp"];
         }
      }
      
      private function headToolBarChildClick(param1:ViewEvent) : void
      {
         var _loc3_:DisplayObject = null;
         var _loc4_:Point = null;
         var _loc5_:WindowEvent = null;
         var _loc2_:Object = param1.data;
         if(_loc2_ == null)
         {
            return;
         }
         if(_loc2_["name"] == "warehouse")
         {
            _loc5_ = new WindowEvent(WindowEvent.OPEN);
            _loc5_.windowName = "warehouse";
            if(_loc2_["target"] is DisplayObject)
            {
               _loc3_ = _loc2_["target"] as DisplayObject;
               _loc4_ = this.headToolBar.localToGlobal(new Point(_loc3_.x,_loc3_.y));
               _loc5_.startX = _loc4_.x;
               _loc5_.startY = _loc4_.y;
            }
            ViewControl.getInstance().dispatchEvent(_loc5_);
         }
         else if(_loc2_["name"] == "shop")
         {
            _loc5_ = new WindowEvent(WindowEvent.OPEN);
            _loc5_.windowName = "shop";
            ViewControl.getInstance().dispatchEvent(_loc5_);
         }
         else if(_loc2_["name"] == "farm")
         {
            this.navigateClick();
         }
         else if(_loc2_["name"] == "MC")
         {
            Command.getInstance().mainCommand.setUser();
            BeastAPI.getInstance().showFarmStage();
         }
         else
         {
            if(_loc2_["name"] == "mill")
            {
               Command.getInstance().mainCommand.gotoPlayMill();
               return;
            }
            if(_loc2_["name"] == "decorate")
            {
               if(!this.mainData.me)
               {
                  Command.getInstance().mainCommand.setUser();
               }
               _loc5_ = new WindowEvent(WindowEvent.OPEN);
               _loc5_.windowName = "diy";
               ViewControl.getInstance().dispatchEvent(_loc5_);
            }
            else if(_loc2_["name"] == "dial")
            {
               _loc5_ = new WindowEvent(WindowEvent.OPEN);
               _loc5_.windowName = "dial";
               ViewControl.getInstance().dispatchEvent(_loc5_);
            }
         }
      }
      
      private function onAddedToStage(param1:Event) : void
      {
         removeEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage);
         this.init();
      }
      
      private function init() : void
      {
         this.mainData = MData.getInstance().mainData;
         this.mainData.addEventListener(MainData.HOST_CHANGE,this.hostChange,false,0,true);
         this.mainData.addEventListener(MainData.ADD_EXP,this.addExp,false,0,true);
         this.mainData.addEventListener(MainData.ADD_MONEY,this.addMoney,false,0,true);
         this.mainData.addEventListener("no_reg",this.noReg);
         this._personInfo = new PersonInfo();
         this._personInfo.x = 15;
         addChild(this._personInfo);
         this.setPersonInfo();
         this.headToolBar = new HeadToolBar();
         var _loc1_:int = 8;
         if(stage.stageWidth < 700)
         {
            _loc1_ = 3;
         }
         else if(stage.stageWidth >= 700 && stage.stageWidth < 800)
         {
            _loc1_ = 8;
         }
         else
         {
            _loc1_ = 11;
         }
         this.headToolBar.setPosition(_loc1_);
         this.headToolBar.x = stage.stageWidth - this.headToolBar.width - _loc1_;
         this.headToolBar.addEventListener(ViewEvent.CHILD_CLICK,this.headToolBarChildClick);
         addChild(this.headToolBar);
      }
      
      private function navigateClick() : void
      {
         Command.getInstance().mainCommand.setExpressUser(this.mainData.currentUser,true);
      }
      
      private function hostChange(param1:Event) : void
      {
         this.setPersonInfo();
      }
      
      private function noReg(param1:Event) : void
      {
         this.mouseChildren = false;
         this.mouseEnabled = false;
         this.alpha = 0.7;
      }
      
      private function addExp(param1:Event) : void
      {
         var _loc2_:AddMoneyFloating = null;
         this._personInfo.exp = this.mainData.host["exp"];
         if(this.mainData.addExp != 0)
         {
            _loc2_ = new AddMoneyFloating();
            _loc2_.fid = 1;
            _loc2_.x = 240;
            _loc2_.y = 17;
            _loc2_.data = String(this.mainData.addExp);
            Float.open(_loc2_);
         }
      }
      
      private function addMoney(param1:Event) : void
      {
         var _loc2_:AddMoneyFloating = null;
         if(this.na)
         {
            this.na.distory();
         }
         this.na = new NumAnimation(this._personInfo,"goldValue",this._personInfo.goldValue,this.mainData.host["money"]);
         if(this._personInfo.goldValue < 0)
         {
            this._personInfo.goldValue = 0;
         }
         if(this.mainData.addMoney != 0)
         {
            _loc2_ = new AddMoneyFloating();
            _loc2_.fid = 2;
            _loc2_.x = 100;
            _loc2_.y = 65;
            _loc2_.data = String(this.mainData.addMoney);
            Float.open(_loc2_);
         }
      }
   }
}

