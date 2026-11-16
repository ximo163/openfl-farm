package mc.view.farm.land
{
   import com.qzone.corelib.net.RSLManager;
   import common.MaterialLib;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   import flash.utils.clearTimeout;
   import flash.utils.setTimeout;
   import mc.control.Command;
   import mc.control.FarmCommand;
   import mc.control.MainCommand;
   import mc.control.ViewControl;
   import mc.events.TipEvent;
   import mc.model.FarmData;
   import mc.model.MData;
   import mc.model.MainData;
   import mc.model.ProductData;
   import mc.view.farm.GetCropID;
   import mc.view.farm.packBar.SelectWindow;
   import mc.view.main.WindowControl.WControl;
   import mc.view.main.cursor.Cursor;
   
   public class GrassCutter extends Sprite
   {
      
      private static var _instance:GrassCutter;
      
      private var farmData:FarmData;
      
      private var mainData:MainData;
      
      private var lib:MaterialLib = MaterialLib.getInstance();
      
      private var _mpFlag:MovieClip;
      
      private var _grassPoint:MovieClip;
      
      private var mpContainer:DisplayObjectContainer;
      
      private var _animalFood:MovieClip;
      
      private var _mpTimer:Timer = new Timer(60 * 1000);
      
      private var timeoutId:Number;
      
      private var productData:ProductData;
      
      public function GrassCutter()
      {
         if(_instance == null)
         {
            super();
            this.init();
            return;
         }
         throw new Error("实例化单例类出错 - GrassCutter");
      }
      
      public static function getInstance() : GrassCutter
      {
         if(_instance == null)
         {
            _instance = new GrassCutter();
         }
         return _instance;
      }
      
      private function loadGrassMpComplete(param1:Event) : void
      {
         this.mp();
      }
      
      private function init() : void
      {
         this.farmData = MData.getInstance().farmData;
         this.productData = MData.getInstance().productData;
         this.mainData = MData.getInstance().mainData;
         this.mainData.addEventListener(MainData.LOAD_DIY_CONFIG_COMPLETE,this.loadGrassMpComplete);
         this._mpTimer.addEventListener(TimerEvent.TIMER,this.mpHandler);
         if(this._animalFood == null)
         {
            this._animalFood = this.lib.getMaterial("Grass") as MovieClip;
            this._animalFood.movie.gotoAndStop(1);
            addChild(this._animalFood);
         }
         this._grassPoint = this.lib.getMaterial("GrassPointNew") as MovieClip;
         this._animalFood.mouseChildren = false;
         this._grassPoint.x = 50;
         this._grassPoint.y = -70;
         this.farmData.addEventListener(FarmData.ANIMAL_FOOD,this.addFood,false,0,true);
         ViewControl.getInstance().addEventListener("addFoodOk",this.addFoodOk);
         this.mainData.addEventListener(MainData.CURRENT_USER_CHANGE,this.currentUserChange,false,0,true);
      }
      
      private function setGrassSkin(param1:String) : void
      {
         var _loc2_:String = null;
         this.removeChild(this._animalFood);
         this._animalFood = null;
         if(param1 == "1")
         {
            if(!this.lib.getClass("Grass_" + this.mainData.userMCBg))
            {
               _loc2_ = MainCommand.getModule2Url("intel")["url"];
               RSLManager.getInstance().requestClass("Grass_" + this.mainData.userMCBg,this.setSkin,_loc2_);
               this._animalFood = this.lib.getMaterial("Grass") as MovieClip;
            }
            else
            {
               this._animalFood = this.lib.getMaterial("Grass_" + this.mainData.userMCBg) as MovieClip;
            }
         }
         else
         {
            this._animalFood = this.lib.getMaterial("Grass") as MovieClip;
            this._mpTimer.stop();
         }
         this.addChild(this._animalFood);
      }
      
      private function speak(param1:String) : void
      {
         this.mpContainer = this.parent.parent.parent;
         if(this._mpFlag)
         {
            this.mpContainer.removeChild(this._mpFlag);
            this._mpFlag = null;
         }
         this._mpFlag = MaterialLib.getInstance().getMaterial("MaoPaoFlag") as MovieClip;
         this._mpFlag.talkInfo = param1;
         this._mpFlag.gotoAndPlay(2);
         this._mpFlag.y = this._animalFood.y - 40;
         this._mpFlag.x = this._animalFood.x + 20;
         this.mpContainer.addChild(this._mpFlag);
         setTimeout(this.hideMP,4000);
      }
      
      private function onFoodTimeOk() : void
      {
         clearTimeout(this.timeoutId);
         this._animalFood.bg.visible = true;
         this._animalFood.movie.gotoAndStop(1);
         this._grassPoint.visible = true;
      }
      
      private function addFoodOk(param1:Event) : void
      {
         this._animalFood.bg.visible = false;
         this._animalFood.movie.gotoAndPlay(2);
         this.timeoutId = setTimeout(this.onFoodTimeOk,4000);
         this._grassPoint.visible = false;
      }
      
      public function addFood(param1:Event = null) : void
      {
         this.updateGrassCutter();
         if(this._animalFood.contains(this._grassPoint))
         {
            this._animalFood.removeChild(this._grassPoint);
         }
         if(this.farmData.animalFood == 0)
         {
            this._animalFood.gotoAndStop(1);
            this._animalFood.addChild(this._grassPoint);
         }
         if(this.farmData.animalFood > 0 && this.farmData.animalFood < 100)
         {
            this._animalFood.gotoAndStop(2);
            this._animalFood.addChild(this._grassPoint);
         }
         if(this.farmData.animalFood >= 100 && this.farmData.animalFood < MainData.MAX_FOOD)
         {
            this._animalFood.gotoAndStop(3);
         }
         if(this.farmData.animalFood >= MainData.MAX_FOOD)
         {
            this._animalFood.gotoAndStop(4);
         }
         this._animalFood.name = "food";
         this._animalFood.addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver);
         this._animalFood.addEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut);
         if(ProductContainer._foodClick)
         {
            this._animalFood.addEventListener(MouseEvent.CLICK,this.onClick);
         }
         this._animalFood.x = 160;
         this._animalFood.y = 460;
      }
      
      private function hideMP() : void
      {
         if(this._mpFlag != null && this.mpContainer.contains(this._mpFlag))
         {
            this.mpContainer.removeChild(this._mpFlag);
            this._mpFlag = null;
         }
      }
      
      private function mpHandler(param1:TimerEvent) : void
      {
         var _loc2_:String = GetCropID.getDiyMP(this.mainData.userMCBg);
         if(_loc2_ != null && _loc2_ != "")
         {
            this.speak(_loc2_);
         }
      }
      
      private function onMouseOut(param1:MouseEvent) : void
      {
         var _loc2_:MovieClip = param1.currentTarget as MovieClip;
         _loc2_.filters = [];
         var _loc3_:TipEvent = new TipEvent(TipEvent.TIP_HIDE);
         ViewControl.getInstance().dispatchEvent(_loc3_);
         if(this.farmData.animalFood >= 10 && _loc2_.name == "food" && (Cursor.name == "CursorArrow" || Cursor.name == "Cursor_ShouHuoAll" || Cursor.name == "Cursor_ShengChan" || Cursor.name == "Cursor_Theft"))
         {
            if(this._animalFood.contains(this._grassPoint))
            {
               this._animalFood.removeChild(this._grassPoint);
            }
         }
      }
      
      private function onClick(param1:MouseEvent) : void
      {
         var _loc3_:SelectWindow = null;
         var _loc4_:MainData = null;
         var _loc5_:String = null;
         if(Cursor.name == "")
         {
            return;
         }
         ProductContainer.mouseE = param1;
         var _loc2_:TipEvent = new TipEvent(TipEvent.TIP_HIDE);
         ViewControl.getInstance().dispatchEvent(_loc2_);
         if(Cursor.name == "CursorArrow" || Cursor.name == "Cursor_ShengChan" || Cursor.name == "Cursor_ShouHuoAll" || Cursor.name == "Cursor_Theft")
         {
            _loc3_ = new SelectWindow();
            _loc4_ = MData.getInstance().mainData;
            if(_loc4_.me)
            {
               _loc5_ = "请选择给自己添加牧草的数量";
            }
            else
            {
               _loc5_ = "请选择赠送给【" + _loc4_.currentUser.userName + "】的牧草数量";
            }
            _loc3_.data = {
               "text":_loc5_,
               "data":null
            };
            _loc3_.confirmFn = this.selectMuCao;
            WControl.open(_loc3_);
         }
      }
      
      private function mp() : void
      {
         if(this.mainData.grassMp == "1")
         {
            this._mpTimer.start();
         }
      }
      
      private function updateGrassCutter() : void
      {
         this.hideMP();
         this.setGrassSkin(this.mainData.grassSkin);
         this.mp();
      }
      
      private function selectMuCao(param1:Number) : void
      {
         var _loc2_:FarmCommand = null;
         _loc2_ = Command.getInstance().farmCommand;
         _loc2_.addFood(param1);
      }
      
      private function currentUserChange(param1:Event) : void
      {
         this.onFoodTimeOk();
      }
      
      private function onMouseOver(param1:MouseEvent) : void
      {
         var _loc2_:MovieClip = param1.currentTarget as MovieClip;
         if(Cursor.name == "CursorArrow" || Cursor.name == "Cursor_ShengChan" || Cursor.name == "Cursor_ShouHuoAll" || Cursor.name == "Cursor_Theft")
         {
            this._animalFood.addChild(this._grassPoint);
            _loc2_.filters = MainData.rollOverFilter;
         }
         var _loc3_:TipEvent = new TipEvent(TipEvent.TIP_SHOW);
         _loc3_.tipType = "ProductInfo";
         _loc3_.tipArgument = _loc2_;
         ViewControl.getInstance().dispatchEvent(_loc3_);
      }
      
      private function setSkin() : void
      {
         this.addFood();
      }
   }
}

