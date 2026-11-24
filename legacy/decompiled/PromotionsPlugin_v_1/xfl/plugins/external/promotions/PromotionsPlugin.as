package plugins.external.promotions
{
   import com.qzone.farm.api.interfaces.IFarmAPI;
   import com.qzone.farm.api.interfaces.IPlugin;
   import flash.display.DisplayObjectContainer;
   import flash.display.InteractiveObject;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.system.ApplicationDomain;
   import flash.system.Security;
   import flash.text.TextFieldAutoSize;
   import flash.utils.setTimeout;
   import promotions.EntranceIcon;
   
   [SWF(width="500", height="375", backgroundColor="#869ca7", frameRate="24")]
   public class PromotionsPlugin extends Sprite implements IPlugin
   {
      
      private var _newIcon:MovieClip;
      
      private var _api:IFarmAPI;
      
      private var _config:Object;
      
      private var _iconEntrance:EntranceIcon;
      
      private var _model:PromotionsModel;
      
      private var _mainWnd:MainWindowWrapper;
      
      private var _discountIcon:Boolean;
      
      private var _id:int;
      
      public function PromotionsPlugin()
      {
         super();
         Security.allowDomain("happyfarm.qzone.qq.com");
         Security.allowDomain("happyfarm.xiaoyou.qq.com");
         Security.allowDomain("appimg1.qq.com");
         Security.allowDomain("appimg.qq.com");
         Security.allowDomain("imgcache.qq.com");
      }
      
      private function onMouseEvent(param1:Event) : void
      {
         var _loc2_:InteractiveObject = param1.currentTarget as InteractiveObject;
         var _loc3_:String = param1.type;
         switch(_loc3_)
         {
            case MouseEvent.CLICK:
               if(_loc2_ == this._iconEntrance.normalIcon)
               {
                  if(this._model.getPromotionsData() == true)
                  {
                     this.openMainWindow(false);
                  }
                  else
                  {
                     this._model.addEventListener(PromotionsModel.DATA_INITIALIZED1,this.onInitialized,false,0,true);
                  }
                  this._api.reportReturnCode(PromotionsModel.CLICK_REPORT_CODE,PromotionsModel.REPORT_VALUE1);
                  this.hideNewIcon();
               }
               else if(_loc2_ == this._iconEntrance.yellowIcon)
               {
                  if(this._model.getYellowPromotionsData() == true)
                  {
                     this.openMainWindow(true);
                  }
                  else
                  {
                     this._model.addEventListener(PromotionsModel.DATA_INITIALIZED2,this.onInitialized,false,0,true);
                  }
                  this._api.reportReturnCode(PromotionsModel.CLICK_REPORT_CODE,PromotionsModel.REPORT_VALUE2);
                  this.hideNewIcon();
               }
               break;
            case MouseEvent.MOUSE_OVER:
               if(_loc2_ == this._iconEntrance.normalIcon)
               {
                  this._api.popMouseTip("点击拿折扣促销礼包！");
               }
               else if(_loc2_ == this._iconEntrance.yellowIcon)
               {
                  this._api.popMouseTip("跳楼价，点击来拿！");
               }
               break;
            case MouseEvent.MOUSE_OUT:
               if(_loc2_ == this._iconEntrance.normalIcon)
               {
                  this._api.hideMouseTip();
               }
               else if(_loc2_ == this._iconEntrance.yellowIcon)
               {
                  this._api.hideMouseTip();
               }
         }
      }
      
      public function unload() : void
      {
      }
      
      private function openMainWindow(param1:Boolean) : void
      {
         if(!param1 && !this._model.dataInitialized1)
         {
            return;
         }
         if(param1 && !this._model.dataInitialized2)
         {
            return;
         }
         if(this._mainWnd == null)
         {
            this._mainWnd = new MainWindowWrapper(this);
         }
         this._mainWnd.show(param1);
      }
      
      private function hideNewIcon() : void
      {
         if(this._newIcon != null && this._newIcon.parent != null)
         {
            this._newIcon.stop();
            this._newIcon.parent.removeChild(this._newIcon);
            this._newIcon = null;
         }
      }
      
      public function get api() : IFarmAPI
      {
         return this._api;
      }
      
      public function executeCommand(param1:int, param2:Object) : Object
      {
         var _loc3_:int = param1;
         switch(0)
         {
         }
         return null;
      }
      
      private function processDiscountIcon(param1:String) : void
      {
         var _loc2_:Class = null;
         var _loc3_:DisplayObjectContainer = null;
         var _loc4_:Point = null;
         if(this._iconEntrance != null && this._model.showTipsFlag)
         {
            if(this._discountIcon == true)
            {
               return;
            }
            this._discountIcon = true;
            _loc2_ = ApplicationDomain.currentDomain.getDefinition("monthEndArrow") as Class;
            if(_loc2_ != null)
            {
               _loc3_ = this._iconEntrance.parent;
               if(Boolean(_loc3_) && Boolean(_loc3_.stage))
               {
                  this._newIcon = new _loc2_() as MovieClip;
                  this._newIcon["tipMc"]["tip"].text = param1;
                  this._newIcon["tipMc"]["tip"].autoSize = TextFieldAutoSize.LEFT;
                  this._newIcon["tipMc"]["tip"].y = 17;
                  _loc4_ = new Point(50,30);
                  _loc4_ = _loc3_.localToGlobal(_loc4_);
                  this._newIcon.x = _loc4_.x;
                  this._newIcon.y = _loc4_.y;
                  _loc3_.stage.addChild(this._newIcon);
                  this._newIcon.play();
                  setTimeout(this.hideNewIcon,5000);
               }
            }
         }
      }
      
      public function load(param1:int, param2:IFarmAPI) : Boolean
      {
         this._id = param1;
         this._api = param2;
         return true;
      }
      
      public function createMainUI(param1:Object) : Sprite
      {
         this._config = param1["config"];
         this._model = new PromotionsModel(this.api,this._config);
         var _loc2_:DisplayObjectContainer = param1["container"] as DisplayObjectContainer;
         if(_loc2_ != null)
         {
            this._iconEntrance = new EntranceIcon();
            this._iconEntrance.buttonMode = true;
            if(_loc2_ != null)
            {
               while(_loc2_.numChildren > 0)
               {
                  _loc2_.removeChildAt(0);
               }
            }
            _loc2_.addChild(this._iconEntrance);
            this._iconEntrance.normalIcon.addEventListener(MouseEvent.CLICK,this.onMouseEvent,false,0,true);
            this._iconEntrance.normalIcon.addEventListener(MouseEvent.MOUSE_OUT,this.onMouseEvent,false,0,true);
            this._iconEntrance.normalIcon.addEventListener(MouseEvent.MOUSE_OVER,this.onMouseEvent,false,0,true);
            this._iconEntrance.yellowIcon.addEventListener(MouseEvent.CLICK,this.onMouseEvent,false,0,true);
            this._iconEntrance.yellowIcon.addEventListener(MouseEvent.MOUSE_OUT,this.onMouseEvent,false,0,true);
            this._iconEntrance.yellowIcon.addEventListener(MouseEvent.MOUSE_OVER,this.onMouseEvent,false,0,true);
            this.processDiscountIcon("超值礼包更新啦");
         }
         return null;
      }
      
      public function callProxy(param1:int, param2:*) : Object
      {
         return this._api.executeCommand(this._id,param1,param2);
      }
      
      public function get model() : PromotionsModel
      {
         return this._model;
      }
      
      private function onInitialized(param1:Event) : void
      {
         if(param1.type == PromotionsModel.DATA_INITIALIZED1)
         {
            this.openMainWindow(false);
         }
         else if(param1.type == PromotionsModel.DATA_INITIALIZED2)
         {
            this.openMainWindow(true);
         }
      }
   }
}

