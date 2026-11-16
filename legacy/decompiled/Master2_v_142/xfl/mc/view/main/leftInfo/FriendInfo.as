package mc.view.main.leftInfo
{
   import com.qzone.corelib.js.JSProxy;
   import flash.display.Loader;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.MouseEvent;
   import flash.net.URLRequest;
   import flash.system.LoaderContext;
   import mc.control.Command;
   import mc.control.Version;
   import mc.model.MData;
   import mc.model.MainData;
   import mc.view.common.MoneyIcon;
   import mc.view.farm.toolBar.ToolBase;
   import mc.view.main.WindowControl.WControl;
   import mc.view.main.head.ExpBar;
   import mc.view.main.head.Level;
   import mc.view.main.head.NameText;
   import mc.view.main.head.PropertyText;
   import mc.view.main.tip.TipControl;
   
   public class FriendInfo extends Sprite
   {
      
      private var rpPropertyText:PropertyText;
      
      private var _nextExp:int = 0;
      
      private var level:Level;
      
      private var _color:String = "blue";
      
      private var loader:Loader;
      
      private var nameText:NameText;
      
      private var msgIcon:MsgIcon;
      
      private var _exp:int = 0;
      
      private var propertyText:PropertyText;
      
      private var _fbValue:Number = 0;
      
      private var _goldValue:Number = 0;
      
      private var expBar:ExpBar;
      
      private var _url:String = "";
      
      public function FriendInfo()
      {
         super();
         this.expBar = new ExpBar();
         this.expBar.addEventListener(MouseEvent.ROLL_OVER,this.onRollOver);
         this.expBar.addEventListener(MouseEvent.ROLL_OUT,this.onRollOut);
         this.expBar.scaleX = 0.9;
         this.expBar.scaleY = 1;
         this.expBar.x = 0 + 60;
         this.expBar.y = 25 + 45 - 43;
         this.expBar.percent = 50;
         addChild(this.expBar);
         this.level = new Level();
         this.level.addEventListener(MouseEvent.ROLL_OVER,this.onRollOver);
         this.level.addEventListener(MouseEvent.ROLL_OUT,this.onRollOut);
         this.level.scaleX = 0.9;
         this.level.scaleY = 0.9;
         this.level.x = 190 - 80 + 60;
         this.level.y = 15 + 47 - 43;
         this.level.level = 9;
         addChild(this.level);
         this.nameText = new NameText();
         this.nameText.x = 0 + 60;
         this.nameText.y = 5 + 45 - 43;
         addChild(this.nameText);
         this.msgIcon = new MsgIcon();
         this.msgIcon.tipText = "给TA留言";
         this.msgIcon.addEventListener(MouseEvent.CLICK,this.msgIconClick);
         this.msgIcon.addEventListener(MouseEvent.ROLL_OVER,this.onOver);
         this.msgIcon.addEventListener(MouseEvent.ROLL_OUT,this.onOut);
         this.msgIcon.x = 50 + 50 + 100;
         this.msgIcon.y = 20;
         this.msgIcon.scaleX = this.msgIcon.scaleY = 0.8;
         addChild(this.msgIcon);
         this.propertyText = new PropertyText();
         this.propertyText.x = 60;
         this.propertyText.y = 40;
         addChild(this.propertyText);
         this.rpPropertyText = new PropertyText(MoneyIcon.RP);
         addChild(this.rpPropertyText);
         this.rpPropertyText.y = 40;
      }
      
      public function set exp(param1:int) : void
      {
         this._exp = param1;
         this.level.level = MData.getInstance().mainData.expToGrade(param1);
         var _loc2_:int = int(MData.getInstance().mainData.gradeToExp(this.level.level));
         var _loc3_:int = int(MData.getInstance().mainData.gradeToExp(this.level.level + 1));
         this._nextExp = param1 - _loc2_;
         this.expBar.exp = _loc3_ - _loc2_;
         this.expBar.nextExp = this._nextExp;
         this.expBar.percent = (this._exp - _loc2_) / (_loc3_ - _loc2_) * 100;
      }
      
      private function ioError(param1:IOErrorEvent) : void
      {
      }
      
      private function loaderComp(param1:Event) : void
      {
         this.loader.width = 50;
         this.loader.height = 50;
      }
      
      public function get rpValue() : Number
      {
         return this._fbValue;
      }
      
      public function set color(param1:String) : void
      {
         this._color = param1;
         this.expBar.color = param1;
         this.level.color = param1;
      }
      
      private function msgIconClick(param1:MouseEvent) : void
      {
         WControl.openForName("profile",1);
      }
      
      public function set url(param1:String) : void
      {
         var _loc2_:Sprite = null;
         var _loc3_:Sprite = null;
         var _loc4_:MainData = null;
         if(this.loader == null)
         {
            this.loader = new Loader();
            this.loader.mouseEnabled = false;
            this.loader.x = 0;
            this.loader.y = 0;
            this.loader.contentLoaderInfo.addEventListener(Event.COMPLETE,this.loaderComp);
            this.loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,this.ioError);
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
            _loc3_.addEventListener(MouseEvent.CLICK,this.loaderClick);
            _loc3_.mask = _loc2_;
            _loc3_.addChild(this.loader);
            addChildAt(_loc3_,0);
         }
         if(Version.value == "qzone")
         {
            _loc4_ = MData.getInstance().mainData;
            param1 = JSProxy.getHead(_loc4_.currentUserUin,50);
         }
         if(param1 != null && param1 != "")
         {
            this.loader.load(new URLRequest(param1.replace(/\/30$/,"/50")),new LoaderContext(true));
         }
      }
      
      public function get vip() : String
      {
         return this.nameText.vip;
      }
      
      public function get color() : String
      {
         return this._color;
      }
      
      public function get exp() : int
      {
         return this._exp;
      }
      
      public function set goldValue(param1:Number) : void
      {
         this._goldValue = param1;
         this.propertyText.goldValue = param1;
         this.rpPropertyText.x = this.propertyText.width + this.propertyText.x + 5;
      }
      
      private function onOver(param1:MouseEvent) : void
      {
         TipControl.show("MouseTip",(param1.currentTarget as ToolBase).tipText);
      }
      
      public function set rpValue(param1:Number) : void
      {
         if(!isNaN(param1))
         {
            this._fbValue = param1;
            this.rpPropertyText.goldValue = param1;
         }
      }
      
      private function setMyHead(param1:String) : void
      {
         var url:String = param1;
         try
         {
            if(url)
            {
               this.loader.unload();
               this.loader.load(new URLRequest(url),new LoaderContext(true));
            }
         }
         catch(e:Error)
         {
         }
      }
      
      private function onOut(param1:MouseEvent) : void
      {
         TipControl.hide();
      }
      
      private function onRollOver(param1:MouseEvent) : void
      {
      }
      
      public function get goldValue() : Number
      {
         return this._goldValue;
      }
      
      private function onRollOut(param1:MouseEvent) : void
      {
      }
      
      private function loaderClick(param1:MouseEvent) : void
      {
         WControl.openForName("profile",0);
      }
      
      public function get userName() : String
      {
         return this.nameText.text;
      }
      
      public function set vip(param1:String) : void
      {
         this.nameText.vip = param1;
      }
      
      public function set userName(param1:String) : void
      {
         var value:String = param1;
         this.nameText.text = value;
         Command.getInstance().mainCommand.getMarkListFromJs(function(param1:String):void
         {
            nameText.text = param1;
         },MData.getInstance().mainData.currentUserUin);
      }
      
      public function get url() : String
      {
         return this._url;
      }
   }
}

