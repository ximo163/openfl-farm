package mc.view.main.head
{
   import com.qzone.corelib.js.JSProxy;
   import common.MaterialLib;
   import flash.display.Loader;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.MouseEvent;
   import flash.net.URLRequest;
   import flash.system.LoaderContext;
   import mc.control.Version;
   import mc.model.MData;
   import mc.model.MainData;
   import mc.view.common.MoneyIcon;
   import mc.view.main.WindowControl.WControl;
   import mc.view.main.task.LevelAndExperience;
   import mc.view.main.tip.TipControl;
   
   public class PersonInfo extends Sprite
   {
      
      private var rpPropertyText:PropertyText;
      
      private var mainData:MainData;
      
      private var level:Level;
      
      private var loader:Loader;
      
      private var nameText:NameText;
      
      private var _exp:int = 0;
      
      private var propertyText:PropertyText;
      
      private var _fbValue:Number = 0;
      
      private var _color:String = "blue";
      
      private var _nextExp:int = 0;
      
      private var _url:String = "";
      
      private var _goldValue:Number = 0;
      
      private var expBar:ExpBar;
      
      private var loaderBg:Sprite;
      
      public function PersonInfo()
      {
         super();
         this.expBar = new ExpBar();
         this.expBar.addEventListener(MouseEvent.ROLL_OUT,this.onRollOut);
         this.expBar.addEventListener(MouseEvent.CLICK,this.onClick);
         this.expBar.buttonMode = true;
         this.expBar.useHandCursor = true;
         this.expBar.x = 65;
         this.expBar.y = 25;
         this.expBar.percent = 50;
         addChild(this.expBar);
         this.level = new Level();
         this.level.addEventListener(MouseEvent.ROLL_OUT,this.onRollOut);
         this.level.addEventListener(MouseEvent.CLICK,this.onClick);
         this.level.buttonMode = true;
         this.level.useHandCursor = true;
         this.level.mouseChildren = false;
         this.level.x = 190;
         this.level.y = 15;
         addChild(this.level);
         this.propertyText = new PropertyText();
         addChild(this.propertyText);
         this.rpPropertyText = new PropertyText(MoneyIcon.RP);
         addChild(this.rpPropertyText);
         this.rpPropertyText.y = 43;
         this.propertyText.x = 65;
         this.propertyText.y = 43;
         this.nameText = new NameText();
         this.nameText.x = 65;
         this.nameText.y = 5;
         addChild(this.nameText);
         this.mainData = MData.getInstance().mainData;
      }
      
      public function set exp(param1:int) : void
      {
         this._exp = param1;
         this.level.level = MData.getInstance().mainData.expToGrade(param1);
         var _loc2_:int = int(MData.getInstance().mainData.gradeToExp(this.level.level));
         var _loc3_:int = int(MData.getInstance().mainData.gradeToExp(this.level.level + 1));
         this._nextExp = param1 - _loc2_;
         this.expBar.percent = (this._exp - _loc2_) / (_loc3_ - _loc2_) * 100;
         this.expBar.exp = _loc3_ - _loc2_;
         this.expBar.nextExp = this._nextExp;
      }
      
      private function ioError(param1:IOErrorEvent) : void
      {
         this.loaderBg.getChildAt(0).visible = true;
      }
      
      private function loaderComp(param1:Event) : void
      {
         this.loader.width = 50;
         this.loader.height = 50;
         this.loaderBg.getChildAt(0).visible = false;
      }
      
      public function set color(param1:String) : void
      {
         this._color = param1;
         this.expBar.color = param1;
         this.level.color = param1;
      }
      
      public function set url(param1:String) : void
      {
         var _loc2_:Sprite = null;
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
            this.loaderBg = MaterialLib.getInstance().getMaterial("DefaultHead") as Sprite;
            this.loaderBg.x = 1;
            this.loaderBg.y = 8;
            this.loaderBg.buttonMode = true;
            this.loaderBg.useHandCursor = true;
            this.loaderBg.addEventListener(MouseEvent.CLICK,this.loaderClick);
            this.loaderBg.mask = _loc2_;
            this.loaderBg.addChild(this.loader);
            addChildAt(this.loaderBg,0);
         }
         if(Version.value == "qzone")
         {
            param1 = JSProxy.getHead(this.mainData.host["uin"],50);
         }
         if(param1 != "" && param1 != null)
         {
            this.loader.unload();
            this.loader.load(new URLRequest(param1.replace(/\/30$/,"/50")),new LoaderContext(true));
            this.loaderBg.getChildAt(0).visible = true;
         }
      }
      
      public function get rpValue() : Number
      {
         return this._fbValue;
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
      
      private function onClick(param1:MouseEvent) : void
      {
         var _loc2_:LevelAndExperience = new LevelAndExperience();
         WControl.open(_loc2_);
      }
      
      public function set rpValue(param1:Number) : void
      {
         if(!isNaN(param1))
         {
            this._fbValue = param1;
            this.rpPropertyText.goldValue = param1;
         }
      }
      
      public function get url() : String
      {
         return this._url;
      }
      
      public function set goldValue(param1:Number) : void
      {
         this._goldValue = param1;
         this.propertyText.goldValue = param1;
         this.rpPropertyText.x = this.propertyText.width + this.propertyText.x + 5;
      }
      
      private function onRollOut(param1:MouseEvent) : void
      {
         TipControl.hide();
      }
      
      private function getAnimalNum(param1:Number) : Number
      {
         if(param1 == 0)
         {
            return 2;
         }
         if(param1 == 1)
         {
            return 3;
         }
         if(param1 == 2)
         {
            return 4;
         }
         if(param1 >= 3)
         {
            return 4 + Math.floor((param1 - 1) / 2);
         }
         return 0;
      }
      
      private function loaderClick(param1:MouseEvent) : void
      {
         WControl.openForName("profile",-1);
      }
      
      public function get userName() : String
      {
         return this.nameText.text;
      }
      
      public function get goldValue() : Number
      {
         return this._goldValue;
      }
      
      public function set vip(param1:String) : void
      {
         this.nameText.vip = param1;
      }
      
      public function set userName(param1:String) : void
      {
         this.nameText.text = param1 || "牧场玩家";
      }
   }
}

