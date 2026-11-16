package mc.view.farm.land
{
   import com.qzone.corelib.net.RSLManager;
   import common.LocalData;
   import common.MaterialLib;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.ui.Mouse;
   import flash.utils.Timer;
   import mc.control.Command;
   import mc.control.DonateAnimalCommand;
   import mc.control.FarmCommand;
   import mc.control.MainCommand;
   import mc.control.ViewControl;
   import mc.events.TipEvent;
   import mc.model.FarmData;
   import mc.model.MData;
   import mc.model.MainData;
   import mc.model.ModelEvent;
   import mc.model.ToolData;
   import mc.view.ViewEvent;
   import mc.view.farm.GetCropID;
   import mc.view.farm.MPScene;
   import mc.view.farm.Research.ResearchModel;
   import mc.view.farm.WhistleManager;
   import mc.view.farm.animals.Animal;
   import mc.view.farm.animals.AnimalManager;
   import mc.view.farm.animals.Hunter;
   import mc.view.main.cursor.Cursor;
   import mc.view.main.floating.Float;
   import mc.view.main.tip.TipControl;
   
   public class Pasturelands extends Sprite
   {
      
      private var farmData:FarmData;
      
      private var mainData:MainData;
      
      private var animalOverEvent:Event;
      
      private var _animalFood:MovieClip;
      
      private var movRect:Rectangle;
      
      private var hunter:Hunter;
      
      private var _productContent:ProductContainer = new ProductContainer();
      
      private var dragArrow:MovieClip;
      
      private var _animalPos:Array = [{
         "x":270,
         "y":290
      },{
         "x":260,
         "y":295
      },{
         "x":250,
         "y":300
      },{
         "x":240,
         "y":305
      },{
         "x":230,
         "y":310
      },{
         "x":220,
         "y":315
      },{
         "x":210,
         "y":320
      },{
         "x":200,
         "y":325
      },{
         "x":190,
         "y":330
      },{
         "x":180,
         "y":335
      },{
         "x":170,
         "y":340
      }];
      
      private var animalArray:Array = [];
      
      private var _house1:House = new House("small");
      
      private var mouseE:MouseEvent;
      
      private var sortTimer:Timer;
      
      private var _targetAnimal:Animal;
      
      private var _shengchanAnimal:Animal;
      
      private var shengChanRect:Rectangle;
      
      private var dragArea:MovieClip;
      
      private var _animalData:Array = [];
      
      private var toolData:ToolData;
      
      private var _dragAnimal:Boolean = false;
      
      private var _hideMPTime:Timer;
      
      private var reclaimButton:Sprite;
      
      private var mpAnimal:Animal;
      
      public function Pasturelands()
      {
         super();
         this.movRect = new Rectangle(250,370,530,280);
         this.shengChanRect = new Rectangle(415,250,175,60);
         this.mouseEnabled = false;
         this.mainData = MData.getInstance().mainData;
         this.farmData = MData.getInstance().farmData;
         this.toolData = MData.getInstance().toolData;
         this.mainData.addEventListener(MainData.ANIMAL_CHANGE,this.animalChange,false,0,true);
         this.mainData.addEventListener(MainData.ANIMAL_SHOUHUO,this.animalShouHuo,false,0,true);
         this.mainData.addEventListener(MainData.ANIMAL_ADD,this.addNewAnimal,false,0,true);
         this.mainData.addEventListener(MainData.ANIMAL_SHENGCHAN,this.animalShengChan,false,0,true);
         this.mainData.addEventListener(MainData.ANIMAL_NEXTSTATUS,this.animalNextStatus,false,0,true);
         this.reclaimButton = MaterialLib.getInstance().getMaterial("Navigate") as Sprite;
         this.reclaimButton.x = 169;
         this.reclaimButton.y = 560;
         this.reclaimButton.name = "reclaim_btn";
         this.reclaimButton.buttonMode = true;
         this.reclaimButton.addEventListener(MouseEvent.CLICK,this.navigateClick);
         this.reclaimButton.addEventListener(MouseEvent.ROLL_OVER,this.onRollOver);
         this.reclaimButton.addEventListener(MouseEvent.ROLL_OUT,this.onRollOut);
         ViewControl.getInstance().addEventListener("upgrade_start",this.onUpgradeStart);
         ViewControl.getInstance().addEventListener("upgrade_end",this.onUpgradeEnd);
         ViewControl.getInstance().addEventListener(MPScene.MAO_PAO,this.onMPTimer);
         this.toolData.addEventListener(ToolData.VIEW_WHISTLE,this.onViewWhistle);
         this.mainData.addEventListener(MainData.HUNTER_CHANGE,this.onHunterChange);
         this.dragArea = MaterialLib.getInstance().getMaterial("DragArea") as MovieClip;
         addChild(this.dragArea);
         this.dragArea.gotoAndStop(1);
         this.dragArea.visible = false;
         this.dragArea.x = 496;
         this.dragArea.y = 295;
         AnimalManager.getInstance().moveRectagle = this.movRect;
      }
      
      private function addHunter() : void
      {
         var _loc1_:Object = this.mainData.hunter;
         if(MaterialLib.getInstance().getMaterial("Hunter_" + this.mainData.hunter["id"]) != null)
         {
            if(this.hunter != null)
            {
               this.hunter.skin = MaterialLib.getInstance().getMaterial("Hunter_" + this.mainData.hunter["id"]) as MovieClip;
               addChild(this.hunter);
               this.hunter.data = _loc1_;
               this.hunter.x = this.movRect.x + 50;
               this.hunter.y = this.movRect.y + this.movRect.height - 50;
               if(_loc1_.t > 0)
               {
                  this.hunter.work();
               }
               else
               {
                  this.hunter.stopWork();
               }
            }
         }
      }
      
      private function onUpgradeEnd(param1:Event) : void
      {
         var _loc3_:Animal = null;
         this._productContent.visible = true;
         var _loc2_:Number = 0;
         while(_loc2_ < this.animalArray.length)
         {
            _loc3_ = this.animalArray[_loc2_] as Animal;
            if(_loc3_.data)
            {
               _loc3_.visible = true;
            }
            _loc2_++;
         }
      }
      
      private function onAnimalClick(param1:MouseEvent) : void
      {
         var _loc3_:FarmCommand = null;
         var _loc4_:ViewEvent = null;
         if(Cursor.name == "")
         {
            return;
         }
         var _loc2_:TipEvent = new TipEvent(TipEvent.TIP_HIDE);
         ViewControl.getInstance().dispatchEvent(_loc2_);
         _loc3_ = Command.getInstance().farmCommand;
         this._shengchanAnimal = param1.currentTarget as Animal;
         switch(Cursor.name)
         {
            case "Cursor_ShengChan":
               if(this._shengchanAnimal.data.status == FarmData.ANIMAL_DAICHAN)
               {
                  this.startShengChanDrag();
                  return;
               }
               if(this._shengchanAnimal.data.status == FarmData.ANIMAL_SHOUHUO)
               {
                  if(_loc3_.playShouHuoAnimation)
                  {
                     return;
                  }
                  _loc3_.ShouHuo((param1.currentTarget as Animal).data["serial"],2);
                  return;
               }
               _loc3_.ShengChan(this._shengchanAnimal.data["serial"]);
               return;
               break;
            case "Cursor_ShouHuoAll":
               if(!this.mainData.me)
               {
                  return;
               }
               if(_loc3_.playShouHuoAnimation)
               {
                  return;
               }
               _loc3_.ShouHuo((param1.currentTarget as Animal).data["serial"],2,true);
               return;
               break;
            case "Cursor_Theft":
               if(this._shengchanAnimal.data.status == FarmData.ANIMAL_DAICHAN)
               {
                  this.startShengChanDrag();
                  return;
               }
               _loc3_.ShengChan(this._shengchanAnimal.data["serial"]);
               return;
               break;
            case "CursorTool":
               _loc3_.useTools(this._shengchanAnimal.data["serial"],Cursor.cursorArgument);
               break;
            case "Cursor_ClearBB":
               if(this._shengchanAnimal.data["status"] == FarmData.ANIMAL_SHENGCHAN)
               {
                  return;
               }
               _loc4_ = new ViewEvent(FarmData.BEAT_ANIMAL);
               _loc4_.data = this._shengchanAnimal.data["serial"];
               ViewControl.getInstance().dispatchEvent(_loc4_);
               break;
            case "Cursor_Donate":
               DonateAnimalCommand.getInstance().donateAnimal(this._shengchanAnimal);
         }
         param1.stopPropagation();
      }
      
      private function cleanFarmland() : void
      {
         var _loc2_:Animal = null;
         Debug.log(this.numChildren);
         var _loc1_:Number = 0;
         while(_loc1_ < this.animalArray.length)
         {
            _loc2_ = this.animalArray[_loc1_] as Animal;
            _loc2_.removeEventListener(MouseEvent.ROLL_OVER,this.onAnimalMouseOver);
            _loc2_.removeEventListener(MouseEvent.ROLL_OUT,this.onAnimalMouseOut);
            _loc2_.removeEventListener(MouseEvent.CLICK,this.onAnimalClick);
            _loc2_.destory();
            _loc1_++;
         }
         this.animalArray = [];
         Debug.log(this.numChildren);
         AnimalManager.getInstance().clearAll();
      }
      
      private function onViewWhistle(param1:Event) : void
      {
         var _loc2_:Object = this.toolData.viewWhistleData;
         var _loc3_:WhistleManager = WhistleManager.getInstance();
         if(_loc2_)
         {
            _loc3_.setWhistleData(_loc2_);
            _loc3_.setAnimal(this.animalArray);
            _loc3_.start();
         }
         else
         {
            _loc3_.clear();
         }
      }
      
      private function sortFunction(param1:Object, param2:Object) : Number
      {
         if(param1.y > param2.y)
         {
            return 1;
         }
         if(param1.y < param2.y)
         {
            return -1;
         }
         if(param1.y == param2.y)
         {
            return 0;
         }
         return 0;
      }
      
      private function navigateClick(param1:Event) : void
      {
         Command.getInstance().mainCommand.setExpressUser(this.mainData.currentUser);
      }
      
      private function closeMP(param1:TimerEvent) : void
      {
         this.mainData.mpData = null;
         this._hideMPTime.removeEventListener(TimerEvent.TIMER_COMPLETE,this.closeMP);
         this._hideMPTime.stop();
         if(this.mpAnimal)
         {
            if(Boolean(this.mpAnimal.data) && this.mpAnimal.data["status"] != FarmData.ANIMAL_SHENGCHAN)
            {
               this.mpAnimal.mov();
            }
            this.mpAnimal = null;
         }
         if(this.toolData.mpData)
         {
            this.toolData.mpData = null;
         }
      }
      
      private function onSort(param1:TimerEvent = null) : void
      {
         var _loc2_:Array = this.animalArray.concat(new Array());
         if(this.hunter)
         {
            _loc2_.push(this.hunter);
         }
         _loc2_.sortOn("y",Array.NUMERIC);
         var _loc3_:Number = 0;
         while(_loc3_ < _loc2_.length)
         {
            addChild(_loc2_[_loc3_]);
            _loc3_++;
         }
      }
      
      private function onAnimalMouseOver(param1:MouseEvent) : void
      {
         if(this._dragAnimal)
         {
            return;
         }
         this._targetAnimal = param1.currentTarget as Animal;
         var _loc2_:TipEvent = new TipEvent(TipEvent.TIP_SHOW);
         _loc2_.tipType = "AnimalInfo";
         _loc2_.tipArgument = this._targetAnimal;
         ViewControl.getInstance().dispatchEvent(_loc2_);
         param1.stopPropagation();
         if(Cursor.name == "CursorTool" || Cursor.name == "Cursor_Donate")
         {
            this._targetAnimal.filters = MainData.rollOverFilter;
         }
         if(Cursor.name == "Cursor_ShengChan" || Cursor.name == "Cursor_Theft")
         {
            if(this._targetAnimal.data["status"] == 3)
            {
               this._targetAnimal.filters = MainData.rollOverFilter;
               Cursor.currentCursor.setCursorFilter();
            }
         }
         if(Cursor.name == "Cursor_ClearBB")
         {
            return;
         }
         if(this._targetAnimal.waitingShengChan)
         {
            return;
         }
         if(this._targetAnimal.feeding)
         {
            return;
         }
         if(this._targetAnimal.data.status != FarmData.ANIMAL_SHENGCHAN)
         {
            this._targetAnimal.stopMov();
         }
      }
      
      public function removeAnimal(param1:Animal) : void
      {
         var _loc4_:Animal = null;
         if(param1 == null || param1.data == null)
         {
            return;
         }
         var _loc2_:Array = this.mainData.animalData;
         _loc2_[int(param1.data["serial"])] = null;
         if(GetCropID.getHouse(param1.data["cId"]) == "窝")
         {
            --this.mainData.host["animal1"];
         }
         else
         {
            --this.mainData.host["animal2"];
         }
         var _loc3_:int = 0;
         while(_loc3_ < this.animalArray.length)
         {
            _loc4_ = this.animalArray[_loc3_];
            if(Boolean(_loc4_.data) && _loc4_.data.serial == param1.data["serial"])
            {
               _loc4_.removeEventListener(MouseEvent.ROLL_OVER,this.onAnimalMouseOver);
               _loc4_.removeEventListener(MouseEvent.ROLL_OUT,this.onAnimalMouseOut);
               _loc4_.removeEventListener(MouseEvent.MOUSE_DOWN,this.onAnimalClick);
               _loc4_.delayDestory();
               _loc4_.data = null;
               break;
            }
            _loc3_++;
         }
      }
      
      private function onMPTimer(param1:Event) : void
      {
         var _loc2_:Number = NaN;
         var _loc3_:String = null;
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc7_:String = null;
         var _loc8_:Number = NaN;
         var _loc9_:Number = NaN;
         if(this.animalArray.length == 0)
         {
            return;
         }
         if(this.toolData.mpData != null)
         {
            _loc5_ = 0;
            _loc6_ = 0;
            while(_loc6_ < this.animalArray.length)
            {
               if(this.animalArray[_loc6_].data)
               {
                  _loc5_ = _loc6_;
                  break;
               }
               _loc6_++;
            }
            _loc2_ = _loc5_;
            _loc3_ = this.toolData.mpData["info"];
         }
         else
         {
            _loc2_ = Math.floor(Math.random() * this.animalArray.length);
         }
         if(!this.animalArray[_loc2_])
         {
            return;
         }
         var _loc4_:Animal = this.animalArray[_loc2_] as Animal;
         this.mpAnimal = _loc4_;
         if(Boolean(this.animalArray[_loc2_].data) && this.animalArray[_loc2_].data.status != 4)
         {
            _loc7_ = _loc3_ || GetCropID.getAnimalSound(this.animalArray[_loc2_].data["cId"]);
            _loc8_ = _loc4_.x;
            _loc9_ = _loc4_.y;
            if(_loc4_.numChildren > 0)
            {
               _loc9_ += _loc4_.getChildAt(0).getBounds(_loc4_).y - 10;
            }
            this.mainData.mpData = {
               "talkInfo":_loc7_,
               "vx":_loc8_,
               "vy":_loc9_
            };
            _loc4_.stopMov();
            if(this._hideMPTime)
            {
               this._hideMPTime.removeEventListener(TimerEvent.TIMER_COMPLETE,this.closeMP);
               this._hideMPTime.stop();
               this._hideMPTime = null;
            }
            this._hideMPTime = new Timer(5000,1);
            this._hideMPTime.addEventListener(TimerEvent.TIMER_COMPLETE,this.closeMP);
            this._hideMPTime.start();
         }
      }
      
      private function onUpgradeStart(param1:Event) : void
      {
         var _loc3_:Animal = null;
         ResearchModel.gi().getEnter = true;
         this._productContent.visible = false;
         var _loc2_:Number = 0;
         while(_loc2_ < this.animalArray.length)
         {
            _loc3_ = this.animalArray[_loc2_] as Animal;
            _loc3_.visible = false;
            _loc2_++;
         }
      }
      
      public function stopAnimalMouseMove() : void
      {
         var _loc1_:FarmCommand = null;
         var _loc2_:Point = null;
         if(Boolean(this._shengchanAnimal) && this._dragAnimal)
         {
            _loc1_ = Command.getInstance().farmCommand;
            _loc2_ = new Point(this._shengchanAnimal.x,this._shengchanAnimal.y);
            _loc2_ = this.localToGlobal(_loc2_);
            if(this._house1.hitTestPoint(_loc2_.x,_loc2_.y,true) && GetCropID.getHouse(this._shengchanAnimal.data["cId"]) == "窝")
            {
               _loc1_.ShengChan(this._shengchanAnimal.data["serial"]);
               LocalData.shengShanAnimal = this._shengchanAnimal;
               this._shengchanAnimal.delayMov();
               this._shengchanAnimal.waitingShengChan = true;
            }
            else if(this._house1.hitTestPoint(_loc2_.x,_loc2_.y,true) && GetCropID.getHouse(this._shengchanAnimal.data["cId"]) == "棚")
            {
               _loc1_.ShengChan(this._shengchanAnimal.data["serial"]);
               LocalData.shengShanAnimal = this._shengchanAnimal;
               this._shengchanAnimal.delayMov();
               this._shengchanAnimal.waitingShengChan = true;
            }
            else
            {
               this._shengchanAnimal.waitingShengChan = false;
               this._shengchanAnimal.mov();
            }
            this.stopShengChanDrag();
            this._dragAnimal = false;
         }
      }
      
      private function setFarmland() : void
      {
         addChild(this._productContent);
         addChild(this.reclaimButton);
         addChild(this._house1);
         this._house1.x = 326;
         this._house1.y = 253;
         this._house1.name = "house1";
         this._house1.mouseChildren = false;
         this._house1.mouseEnabled = false;
         this._animalData = this.mainData.animalData;
         this.animalArray = this.animalArray.concat(this.addAnimal(this._animalData));
         trace("动物数目：" + this.animalArray.length);
         this.onSort();
         if(!this.sortTimer)
         {
            this.sortTimer = new Timer(1000);
            this.sortTimer.addEventListener(TimerEvent.TIMER,this.onSort);
         }
         this.sortTimer.start();
         stage.addEventListener(MouseEvent.MOUSE_UP,this.onMouseUp);
         stage.addEventListener(MouseEvent.ROLL_OUT,this.onMouseUp);
      }
      
      private function onMouseUp(param1:MouseEvent) : void
      {
         this.stopAnimalMouseMove();
         param1.stopPropagation();
      }
      
      private function animalShengChan(param1:Event) : void
      {
         var _loc6_:Animal = null;
         var _loc2_:Object = this.mainData.animalShengChanData;
         var _loc3_:int = 0;
         while(_loc3_ < this.animalArray.length)
         {
            if(Boolean(this.animalArray[_loc3_].data) && this.animalArray[_loc3_].data.serial == _loc2_.serial)
            {
               _loc6_ = this.animalArray[_loc3_] as Animal;
               _loc6_.data = _loc2_;
               _loc6_.waitingShengChan = false;
               _loc6_.addEventListener(MouseEvent.ROLL_OVER,this.onAnimalMouseOver,false,0,true);
               _loc6_.addEventListener(MouseEvent.ROLL_OUT,this.onAnimalMouseOut,false,0,true);
               if(_loc6_.y > this.shengChanRect.y + this.shengChanRect.height)
               {
                  _loc6_.x = this.shengChanRect.x + Math.random() * this.shengChanRect.width;
                  _loc6_.y = this.shengChanRect.y + Math.random() * this.shengChanRect.height;
               }
               break;
            }
            _loc3_++;
         }
         var _loc4_:Array = this.mainData.animalData;
         var _loc5_:int = 0;
         while(_loc5_ < _loc4_.length)
         {
            if(Boolean(_loc4_[_loc5_]) && _loc4_[_loc5_].serial == _loc2_.serial)
            {
               _loc4_[_loc5_] = _loc2_;
               break;
            }
            _loc5_++;
         }
         ViewControl.getInstance().dispatchEvent(new Event("check_do"));
      }
      
      private function addNewAnimal(param1:Event) : void
      {
         var _loc2_:Array = this.mainData.animalAddArray;
         this.animalArray = this.animalArray.concat(this.addAnimal(_loc2_));
         AnimalManager.getInstance().animals = this.animalArray;
      }
      
      private function onAnimalMouseOut(param1:MouseEvent) : void
      {
         if(this._dragAnimal)
         {
            return;
         }
         this._targetAnimal = param1.currentTarget as Animal;
         this._targetAnimal.filters = null;
         Cursor.currentCursor.cancelCursorFilter();
         var _loc2_:TipEvent = new TipEvent(TipEvent.TIP_HIDE);
         ViewControl.getInstance().dispatchEvent(_loc2_);
         param1.stopPropagation();
         if(Cursor.name == "Cursor_ClearBB")
         {
            return;
         }
         if(this._targetAnimal.waitingShengChan)
         {
            return;
         }
         if(this._targetAnimal.feeding)
         {
            return;
         }
         if(this._targetAnimal.data.status != FarmData.ANIMAL_SHENGCHAN)
         {
            this._targetAnimal.mov();
         }
      }
      
      private function stopShengChanDrag() : void
      {
         var _loc1_:TipEvent = null;
         if(this._shengchanAnimal != null)
         {
            this._shengchanAnimal.stopDrag();
            this._shengchanAnimal = null;
            _loc1_ = new TipEvent(TipEvent.TIP_HIDE);
            ViewControl.getInstance().dispatchEvent(_loc1_);
            this.dragArea.visible = false;
            this.dragArea.gotoAndStop(1);
            this.dragArrow.gotoAndStop(1);
            removeChild(this.dragArrow);
            if(this.mainData.me)
            {
               Cursor.setCursor("Cursor_ShengChan");
            }
            else
            {
               Cursor.setCursor("Cursor_Theft");
            }
            Cursor.useDrag = false;
         }
      }
      
      private function onHunterChange(param1:Event) : void
      {
         var _loc2_:Object = this.mainData.hunter;
         if(_loc2_.used == 1)
         {
            if(!this.hunter)
            {
               this.hunter = new Hunter();
               if(GetCropID.mpXmlIsNull() && GetCropID._loading == false)
               {
                  GetCropID.getMPXMl();
               }
            }
            RSLManager.getInstance().requestClass("Hunter_" + this.mainData.hunter["id"],this.addHunter,MainCommand.getModule2Url("hunter")["url"] + "h_" + this.mainData.hunter["id"] + ".swf");
         }
         else if(Boolean(this.hunter) && contains(this.hunter))
         {
            removeChild(this.hunter);
            this.hunter.clear();
            this.hunter = null;
         }
      }
      
      private function animalChange(param1:ModelEvent) : void
      {
         this.cleanFarmland();
         this.setFarmland();
      }
      
      private function onRollOut(param1:MouseEvent) : void
      {
         Cursor.useSystem(false);
         TipControl.hide();
      }
      
      private function animalNextStatus(param1:Event) : void
      {
         var _loc4_:Animal = null;
         var _loc2_:Object = this.mainData.nextStatusAnimal;
         var _loc3_:int = 0;
         while(_loc3_ < this.animalArray.length)
         {
            if(Boolean(this.animalArray[_loc3_].data) && this.animalArray[_loc3_].data.serial == _loc2_.serial)
            {
               _loc4_ = this.animalArray[_loc3_] as Animal;
               _loc4_.data = _loc2_;
               if(_loc2_.status == FarmData.ANIMAL_SHENGCHAN)
               {
                  _loc4_.x = this.shengChanRect.x + Math.random() * this.shengChanRect.width;
                  _loc4_.y = this.shengChanRect.y + Math.random() * this.shengChanRect.height;
               }
               return;
            }
            _loc3_++;
         }
      }
      
      private function animalShouHuo(param1:Event) : void
      {
         var _loc5_:Animal = null;
         var _loc2_:Number = this.mainData.animalShouHuoIndex;
         var _loc3_:int = 0;
         while(_loc3_ < this.animalArray.length)
         {
            _loc5_ = this.animalArray[_loc3_];
            if(Boolean(_loc5_.data) && _loc5_.data.serial == _loc2_)
            {
               _loc5_.removeEventListener(MouseEvent.ROLL_OVER,this.onAnimalMouseOver);
               _loc5_.removeEventListener(MouseEvent.ROLL_OUT,this.onAnimalMouseOut);
               _loc5_.removeEventListener(MouseEvent.MOUSE_DOWN,this.onAnimalClick);
               this.farmData.farmOperate = {
                  "text":"收获成功",
                  "type":"animal",
                  "serial":_loc5_.data.serial,
                  "me":this.mainData.me,
                  "t":600
               };
               _loc5_.delayDestory();
               _loc5_.data = null;
               break;
            }
            _loc3_++;
         }
         var _loc4_:Array = this.mainData.animalData;
         _loc4_[_loc2_] = null;
      }
      
      private function startShengChanDrag() : void
      {
         this._shengchanAnimal.stopMov();
         this._shengchanAnimal.setState(5);
         this._shengchanAnimal.startDrag();
         Cursor.useSystem(true);
         Cursor.useDrag = true;
         if(!this.dragArrow)
         {
            this.dragArrow = MaterialLib.getInstance().getMaterial("HouseTip") as MovieClip;
            this.dragArrow.x = 488;
            this.dragArrow.y = 180;
         }
         this.dragArea.visible = true;
         this.dragArea.gotoAndPlay(1);
         this.dragArrow.gotoAndPlay(1);
         addChild(this.dragArrow);
         Mouse.hide();
         this._dragAnimal = true;
      }
      
      private function farmOperate(param1:String) : void
      {
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc2_:FarmOperateFloating = new FarmOperateFloating();
         _loc2_.text = param1;
         if(this.mouseE)
         {
            _loc3_ = this.mouseE.stageX;
            _loc4_ = this.mouseE.stageY;
            _loc2_.x = _loc3_;
            _loc2_.y = _loc4_;
            Float.open(_loc2_);
            this.mouseE = null;
         }
      }
      
      private function onRollOver(param1:MouseEvent) : void
      {
         Cursor.useSystem(true);
         if(param1.currentTarget.name == "reclaim_btn")
         {
            TipControl.show("MouseTip","转到农场");
         }
      }
      
      private function addAnimal(param1:Array) : Array
      {
         var _loc4_:Number = NaN;
         var _loc5_:Animal = null;
         var _loc2_:Array = [];
         var _loc3_:Number = 0;
         while(_loc3_ < param1.length)
         {
            if(param1[_loc3_])
            {
               _loc4_ = Number(param1[_loc3_].status);
               _loc5_ = new Animal();
               _loc5_.type = param1[_loc3_]["cId"];
               addChild(_loc5_);
               _loc5_.setMoveRect(this.movRect);
               if(_loc4_ != FarmData.ANIMAL_SHENGCHAN)
               {
                  if(MainData.addPackAnimal)
                  {
                     _loc5_.x = this.mouseX;
                     _loc5_.y = this.mouseY;
                     MainData.addPackAnimal = false;
                  }
                  else
                  {
                     _loc5_.x = this.movRect.x + Math.floor(Math.random() * this.movRect.width);
                     _loc5_.y = this.movRect.y + Math.floor(Math.random() * this.movRect.height);
                  }
               }
               else
               {
                  _loc5_.x = this.shengChanRect.x + Math.floor(Math.random() * this.shengChanRect.width);
                  _loc5_.y = this.shengChanRect.y + Math.floor(Math.random() * this.shengChanRect.height);
               }
               _loc5_.index = this.animalArray.length + _loc3_;
               _loc5_.data = param1[_loc3_];
               _loc5_.addEventListener(MouseEvent.ROLL_OVER,this.onAnimalMouseOver);
               _loc5_.addEventListener(MouseEvent.ROLL_OUT,this.onAnimalMouseOut);
               _loc5_.addEventListener(MouseEvent.MOUSE_DOWN,this.onAnimalClick);
               _loc2_.push(_loc5_);
            }
            _loc3_++;
         }
         AnimalManager.getInstance().animals = _loc2_;
         return _loc2_;
      }
   }
}

