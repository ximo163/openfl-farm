package module.uitools.widgets
{
   import common.Consts;
   import common.Session;
   import common.Settings;
   import common.misc.QzoneJSAPI;
   import common.misc.Utils;
   import common.view.MoneyIcon;
   import common.view.NumAnimation;
   import entities.Player;
   import events.CommonEvent;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.MouseEvent;
   import flash.net.URLRequest;
   import flash.net.navigateToURL;
   import flash.system.LoaderContext;
   import module.uitools.UIController;
   import module.uitools.UIToolsModel;
   import module.uitools.widgets.profile.ExpBar;
   import module.uitools.widgets.profile.Level;
   import module.uitools.widgets.profile.LevelAndExperience;
   import module.uitools.widgets.profile.NameText;
   import module.uitools.widgets.profile.PropertyText;
   import report.UserActionRecorder;
   
   public class PersonInfo extends Sprite
   {
      
      private var _propertyText:PropertyText;
      
      private var _level:Level;
      
      private var _animation:NumAnimation;
      
      private var _rpValue:Number = 0;
      
      private var _rpPropertyText:PropertyText;
      
      private var _levelAndExp:LevelAndExperience;
      
      private var m_controller:UIController;
      
      private var _url:String;
      
      private var _nameText:NameText;
      
      private var _loader:Loader;
      
      private var _isMe:Boolean;
      
      private var _expBar:ExpBar;
      
      private var _msgIcon:MovieClip;
      
      private var _exp:int;
      
      private var _fb:int;
      
      private var _goldValue:Number;
      
      private var _nextExp:int;
      
      public function PersonInfo(param1:UIController, param2:Boolean)
      {
         super();
         this._goldValue = 0;
         this._exp = 0;
         this._nextExp = 0;
         this._fb = 0;
         this._url = "";
         this._loader = null;
         this._levelAndExp = null;
         this._isMe = param2;
         this._animation = null;
         this.m_controller = param1;
         var _loc3_:int = param2 == true ? 65 : 60;
         this._expBar = new ExpBar();
         this._expBar.name = "__experience__";
         this._expBar.buttonMode = true;
         this._expBar.useHandCursor = true;
         this._expBar.x = _loc3_;
         this._expBar.y = 25;
         this._expBar.percent = 0;
         if(param2 == false)
         {
            this._expBar.scaleX = 0.9;
         }
         addChild(this._expBar);
         this._level = new Level();
         this._level.name = "__level__";
         this._level.buttonMode = true;
         this._level.useHandCursor = true;
         this._level.x = this._expBar.x + this._expBar.width + 3;
         this._level.y = 15;
         this._level.level = 0;
         if(param2 == false)
         {
            this._level.scaleX = 0.95;
            this._level.scaleY = 0.95;
         }
         addChild(this._level);
         this._propertyText = new PropertyText();
         this._propertyText.x = _loc3_;
         this._propertyText.y = 40;
         addChild(this._propertyText);
         this._nameText = new NameText();
         this._nameText.x = _loc3_;
         this._nameText.y = 5;
         addChild(this._nameText);
         this._rpPropertyText = new PropertyText(MoneyIcon.RP);
         this._rpPropertyText.y = 40;
         this._rpPropertyText.x = this._propertyText.width + this._propertyText.x - 10;
         addChild(this._rpPropertyText);
         if(param2 == false)
         {
            this._msgIcon = Utils.getMaterial("MsgIcon") as MovieClip;
            if(this._msgIcon != null)
            {
               this._msgIcon.name = "__msg__";
               this._msgIcon.x = this._level.x + this._level.width + 3;
               this._msgIcon.y = 20;
               this._msgIcon.scaleX = 0.8;
               this._msgIcon.scaleY = 0.8;
               this._msgIcon.mouseChildren = false;
               this._msgIcon.buttonMode = true;
               this._msgIcon.gotoAndStop(1);
               addChild(this._msgIcon);
            }
         }
         addEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage,false,0,true);
         addEventListener(Event.REMOVED_FROM_STAGE,this.onRemovedFromStage,false,0,true);
      }
      
      public function get goldValue() : Number
      {
         return this._goldValue;
      }
      
      private function gradeToExp(param1:int) : uint
      {
         return 100 * param1 * (param1 + 1);
      }
      
      public function set updateGold(param1:Number) : void
      {
         this._propertyText.goldValue = param1;
      }
      
      private function onPhotoClicked(param1:MouseEvent) : void
      {
         var _loc2_:Player = null;
         if(this._isMe == true)
         {
            _loc2_ = Session.getInstance().host;
            UserActionRecorder.recordAction(UserActionRecorder.HF_PERSONINFO_OPEN);
         }
         else
         {
            _loc2_ = Session.getInstance().currentUser;
         }
         var _loc3_:* = {
            "index":-1,
            "player":_loc2_
         };
         this.m_controller.module.app.dispatchEvent(new CommonEvent(Consts.MSG_SHOW_PROFILE,_loc3_));
      }
      
      public function get exp() : int
      {
         return this._exp;
      }
      
      private function onAddedToStage(param1:Event) : void
      {
         addEventListener(MouseEvent.ROLL_OVER,this.onRollOver,true,0,true);
         addEventListener(MouseEvent.ROLL_OUT,this.onRollOut,true,0,true);
         addEventListener(MouseEvent.CLICK,this.onClick,false,0,true);
         if(this._isMe == true && this.m_controller != null && this.m_controller.model != null)
         {
            this.m_controller.model.addEventListener(UIToolsModel.EVENT_PLAYER_BASEINFO_CHANGED,this.onPlayerBaseInfoChanged);
            this.m_controller.model.addEventListener(UIToolsModel.EVENT_PLAYER_ACCOUNT_CHANGED,this.onAccountInfoChanged);
         }
         var _loc2_:Player = null;
         if(this._isMe == true)
         {
            _loc2_ = Session.getInstance().host;
         }
         else
         {
            _loc2_ = Session.getInstance().currentUser;
         }
         if(_loc2_ == null || _loc2_._yellowstatus == 0)
         {
            this.color = Level.BLUE;
         }
         else
         {
            this.color = Level.YELLOW;
            if(_loc2_ != null)
            {
               this.vip = "VipL" + _loc2_._yellowlevel;
            }
         }
      }
      
      public function set rpValue(param1:Number) : void
      {
         if(!isNaN(param1))
         {
            this._rpValue = param1;
            this._rpPropertyText.goldValue = param1;
         }
      }
      
      private function onRollOut(param1:MouseEvent) : void
      {
         if(param1 == null && param1.target == null)
         {
            return;
         }
         if(param1.target.name == "__vip__" || param1.target.name == "__msg__")
         {
            this.m_controller.hideTip();
         }
      }
      
      public function set exp(param1:int) : void
      {
         this._exp = param1;
         this._level.level = this.expToGrade(param1);
         var _loc2_:int = int(this.gradeToExp(this._level.level));
         var _loc3_:int = int(this.gradeToExp(this._level.level + 1));
         this._nextExp = param1 - _loc2_;
         if(_loc3_ - _loc2_ != 0)
         {
            this._expBar.percent = (this._exp - _loc2_) / (_loc3_ - _loc2_) * 100;
         }
         this._expBar.exp = _loc3_ - _loc2_;
         this._expBar.nextExp = this._nextExp;
      }
      
      private function expToGrade(param1:uint) : int
      {
         return Math.sqrt((param1 + 25) / 100) - 0.5;
      }
      
      private function onLeftMessageClicked(param1:MouseEvent) : void
      {
         if(this._isMe == true)
         {
            return;
         }
         var _loc2_:Player = Session.getInstance().currentUser;
         var _loc3_:* = {
            "index":1,
            "player":_loc2_
         };
         this.m_controller.module.app.dispatchEvent(new CommonEvent(Consts.MSG_SHOW_PROFILE,_loc3_));
      }
      
      public function set vip(param1:String) : void
      {
         this._nameText.vip = param1;
      }
      
      public function set color(param1:String) : void
      {
         this._expBar.color = param1;
         this._level.color = param1;
      }
      
      public function get rpValue() : Number
      {
         return this._rpValue;
      }
      
      public function set url(param1:*) : void
      {
         var _loc2_:Sprite = null;
         var _loc3_:Sprite = null;
         if(this._loader == null)
         {
            this._loader = new Loader();
            this._loader.mouseEnabled = false;
            this._loader.x = 0;
            this._loader.y = 0;
            this._loader.contentLoaderInfo.addEventListener(Event.COMPLETE,this.onPhotoLoaded);
            this._loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,this.onPhotoLoadError);
            _loc2_ = new Sprite();
            _loc2_.x = 1;
            _loc2_.y = 8;
            _loc2_.graphics.clear();
            _loc2_.graphics.beginFill(15658734);
            _loc2_.graphics.drawRoundRect(0,0,50,50,10,10);
            _loc2_.graphics.endFill();
            addChild(_loc2_);
            _loc3_ = new Sprite();
            _loc3_.x = 1;
            _loc3_.y = 8;
            _loc3_.buttonMode = true;
            _loc3_.useHandCursor = true;
            _loc3_.graphics.clear();
            _loc3_.graphics.beginFill(15658734,1);
            _loc3_.graphics.drawRect(0,0,50,50);
            _loc3_.graphics.endFill();
            _loc3_.addEventListener(MouseEvent.CLICK,this.onPhotoClicked);
            _loc3_.mask = _loc2_;
            _loc3_.addChild(this._loader);
            addChildAt(_loc3_,0);
         }
         if(param1 != null && param1 != "")
         {
            this._loader.load(new URLRequest(param1),new LoaderContext(true));
         }
      }
      
      private function onClick(param1:MouseEvent) : void
      {
         var _loc2_:String = null;
         if(param1 == null && param1.target == null)
         {
            return;
         }
         if(param1.target.name == "__experience__" || param1.target.name == "__level__")
         {
            if(this._isMe == false)
            {
               return;
            }
            if(this._levelAndExp == null)
            {
               this._levelAndExp = new LevelAndExperience();
            }
            this.m_controller.module.app.farmView.winCtrl.open(this._levelAndExp);
         }
         else if(param1.target.name == "__vip__")
         {
            _loc2_ = Settings.getInstance().getUrlConfigByName("vipIntroduce");
            navigateToURL(new URLRequest(_loc2_));
         }
         else if(param1.target.name == "__msg__")
         {
            this.onLeftMessageClicked(null);
         }
      }
      
      public function set userName(param1:*) : void
      {
         this._nameText.text = param1 || "农场玩家";
      }
      
      private function onPlayerBaseInfoChanged(param1:Event) : void
      {
         if(param1 == null)
         {
            return;
         }
         var _loc2_:UIToolsModel = param1.target as UIToolsModel;
         if(_loc2_ == null)
         {
            return;
         }
         this.userName = _loc2_.myProfile.m_userName;
         var _loc3_:String = _loc2_.myProfile.m_photoUrl;
         if(QzoneJSAPI.WB == true)
         {
            if(_loc3_ == null || _loc3_ == "")
            {
               _loc3_ = "http://mat1.gtimg.com/www/mb/images/head_50.jpg";
            }
            else
            {
               _loc3_ += "/50";
            }
         }
         this.url = _loc3_;
      }
      
      public function setFriendInfo(param1:Player) : void
      {
         if(this._isMe == true)
         {
            return;
         }
         if(param1 == null)
         {
            return;
         }
         if(param1._yellowstatus == 0)
         {
            this.color = Level.BLUE;
            this.vip = "";
         }
         else
         {
            this.color = Level.YELLOW;
            if(param1 != null)
            {
               this.vip = "VipL" + param1._yellowlevel;
            }
         }
         this.userName = param1._userName;
         this.goldValue = param1._money;
         this.updateGold = param1._money;
         this.exp = param1._exp;
         this.rpValue = param1._moralExp;
         if(QzoneJSAPI.WB == true)
         {
            if(param1._headPic == null || param1._headPic == "")
            {
               this.url = "http://mat1.gtimg.com/www/mb/images/head_50.jpg";
            }
            else
            {
               this.url = param1._headPic + "/50";
            }
         }
         else
         {
            this.url = Utils.formatPhotoUrl50(param1.uin,param1._headPic);
         }
      }
      
      private function onPhotoLoadError(param1:IOErrorEvent) : void
      {
      }
      
      private function onRollOver(param1:MouseEvent) : void
      {
         if(param1 == null && param1.target == null)
         {
            return;
         }
         if(param1.target.name == "__vip__")
         {
            this.m_controller.showTip(Consts.TIP_NAME_MOUSE,"点击查看VIP特权详情");
         }
         else if(param1.target.name == "__msg__")
         {
            this.m_controller.showTip(Consts.TIP_NAME_MOUSE,"给TA留言");
         }
      }
      
      public function set goldValue(param1:Number) : void
      {
         if(param1 < 0)
         {
            param1 = 0;
         }
         this._goldValue = param1;
      }
      
      private function onRemovedFromStage(param1:Event) : void
      {
         removeEventListener(MouseEvent.ROLL_OVER,this.onRollOver);
         removeEventListener(MouseEvent.ROLL_OUT,this.onRollOut);
         removeEventListener(MouseEvent.CLICK,this.onClick);
         if(this._isMe == true && this.m_controller != null && this.m_controller.model != null)
         {
            this.m_controller.model.removeEventListener(UIToolsModel.EVENT_PLAYER_BASEINFO_CHANGED,this.onPlayerBaseInfoChanged);
            this.m_controller.model.removeEventListener(UIToolsModel.EVENT_PLAYER_ACCOUNT_CHANGED,this.onAccountInfoChanged);
         }
      }
      
      private function onPhotoLoaded(param1:Event) : void
      {
         this._loader.width = 50;
         this._loader.height = 50;
      }
      
      private function onAccountInfoChanged(param1:Event) : void
      {
         if(param1 == null)
         {
            return;
         }
         var _loc2_:UIToolsModel = param1.target as UIToolsModel;
         if(_loc2_ == null)
         {
            return;
         }
         var _loc3_:Number = _loc2_.myProfile.m_gold - this.goldValue;
         if(_loc3_ != 0)
         {
            if(this._goldValue == 0)
            {
               this.goldValue = _loc2_.myProfile.m_gold;
               this.updateGold = _loc2_.myProfile.m_gold;
            }
            else
            {
               if(this._animation == null)
               {
                  this._animation = new NumAnimation(this,"updateGold",this.goldValue,_loc2_.myProfile.m_gold);
                  this._animation.start();
               }
               else
               {
                  this._animation.end = _loc2_.myProfile.m_gold;
               }
               this.goldValue = _loc2_.myProfile.m_gold;
               this.m_controller.openFloat(Consts.FLOAT_TYPE_MONEY,{
                  "x":100,
                  "y":60,
                  "value":_loc3_
               });
            }
         }
         _loc3_ = _loc2_.myProfile.m_exp - this._exp;
         if(_loc3_ != 0)
         {
            if(this._exp != 0)
            {
               this.m_controller.openFloat(Consts.FLOAT_TYPE_EXP,{
                  "x":240,
                  "y":17,
                  "value":_loc3_
               });
            }
         }
         this.exp = _loc2_.myProfile.m_exp;
         this.rpValue = _loc2_.myProfile.m_moral;
      }
   }
}

