package wild.com.Shell.stage
{
   import com.adobe.serialization.json.JSON;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.utils.setTimeout;
   import wild.com.Shell.DataShell;
   import wild.com.Shell.command.CmdAPI;
   
   public class FarmStage extends Sprite
   {
      
      private static var _hasViewNum:int;
      
      private var _isHappyAnimals:Boolean = false;
      
      private var _dataShell:DataShell;
      
      private var _txtMc:MovieClip;
      
      private var _pos:Array;
      
      private var _animals:Array = [];
      
      private var _mpFlag:MovieClip;
      
      private var _cmdAPI:CmdAPI;
      
      public function FarmStage(param1:Boolean = false)
      {
         this._isHappyAnimals = param1;
         super();
         this._dataShell = DataShell.getInstance();
         this._dataShell.addEventListener(DataShell.ANIMAL_CHANGE,this.onChange);
         this._cmdAPI = CmdAPI.getInstance();
         this._mpFlag = this._cmdAPI.api.getMaterial("WildMaoPaoFlag") as MovieClip;
         if(CmdAPI.getInstance().api.ISFARM == 1)
         {
            this._pos = com.adobe.serialization.json.JSON.decode(DataShell.InIData.beast[0].@dy1);
         }
         else
         {
            this._pos = com.adobe.serialization.json.JSON.decode(DataShell.InIData.beast[0].@dy);
         }
      }
      
      private function hideFlag() : void
      {
         if(Boolean(this._mpFlag) && contains(this._mpFlag))
         {
            removeChild(this._mpFlag);
         }
      }
      
      private function onAnimalClick(param1:MouseEvent) : void
      {
         this._cmdAPI.api.showWildStage();
      }
      
      public function showText(param1:Sprite, param2:String, param3:int = 0) : void
      {
         if(_hasViewNum == param3 && param2 == "num")
         {
            return;
         }
         _hasViewNum = param3;
         if(this._txtMc != null)
         {
            stage.removeChild(this._txtMc);
            this._txtMc = null;
         }
         if(param2 == "num")
         {
            this._txtMc = this._cmdAPI.api.getMaterial("Wild_Animal_Num_txt") as MovieClip;
            this._txtMc.txt_mc.txt.text = param3.toString();
         }
         else if(param2 == "back")
         {
            this._txtMc = this._cmdAPI.api.getMaterial("Wild_Animal_Back_txt") as MovieClip;
         }
         stage.addChild(this._txtMc);
         var _loc4_:Point = param1.localToGlobal(new Point(stage.x,stage.y));
         this._txtMc.x = _loc4_.x + 10;
         this._txtMc.y = _loc4_.y - 5;
      }
      
      public function clear() : void
      {
         var _loc1_:int = 0;
         while(_loc1_ < this._animals.length)
         {
            removeChild(this._animals[_loc1_]);
            WildAnimal(this._animals[_loc1_]).clear();
            this._animals[_loc1_].removeEventListener(MouseEvent.CLICK,this.onAnimalClick);
            _loc1_++;
         }
         this._animals = [];
         if(Boolean(this._mpFlag) && contains(this._mpFlag))
         {
            removeChild(this._mpFlag);
         }
      }
      
      private function onChange(param1:Event) : void
      {
         var _loc4_:WildAnimal = null;
         var _loc5_:XML = null;
         var _loc6_:int = 0;
         var _loc7_:XML = null;
         this.clear();
         var _loc2_:Array = this._dataShell.animals;
         var _loc3_:int = 0;
         while(_loc3_ < _loc2_.length)
         {
            _loc4_ = new WildAnimal(_loc2_[_loc3_]["type"],false,true,this._cmdAPI.api.ISFARM == 0);
            _loc4_.addEventListener(MouseEvent.CLICK,this.onAnimalClick);
            _loc4_.setState("Stand");
            _loc4_.data = _loc2_[_loc3_];
            _loc5_ = DataShell.getAnimalInfo(_loc2_[_loc3_]["type"]);
            if(stage.stageWidth > 900)
            {
               if(CmdAPI.getInstance().api.ISFARM == 1)
               {
                  _loc4_.x = _loc5_.p.@sb1;
               }
               else
               {
                  _loc4_.x = _loc5_.p.@sb;
               }
            }
            else if(stage.stageWidth > 800)
            {
               if(CmdAPI.getInstance().api.ISFARM == 1)
               {
                  _loc4_.x = _loc5_.p.@ss1 - 20;
               }
               else
               {
                  _loc4_.x = _loc5_.p.@ss - 20;
               }
            }
            else if(CmdAPI.getInstance().api.ISFARM == 1)
            {
               _loc4_.x = _loc5_.p.@ss1;
            }
            else
            {
               _loc4_.x = _loc5_.p.@ss - 20;
            }
            if(this._isHappyAnimals)
            {
               _loc4_.y = this._pos[_loc3_];
            }
            else
            {
               _loc4_.x += 35;
               if(_loc4_.id == 4)
               {
                  _loc4_.y = this._pos[_loc3_] + 240;
               }
               else
               {
                  _loc4_.y = this._pos[_loc3_] + 250;
               }
            }
            this._animals.push(_loc4_);
            addChild(_loc4_);
            _loc3_++;
         }
         if(this._animals.length > 0)
         {
            _loc6_ = 0;
            _loc7_ = DataShell.InIData;
            this._mpFlag.x = this._animals[_loc6_].x;
            this._mpFlag.y = this._animals[_loc6_].y - (this._animals[_loc6_].height == 0 ? _loc7_.beast.info.@height : this._animals[_loc6_].height) + 50;
            this._mpFlag.talkInfo = "点我进入pk场";
            this._mpFlag.mouseEnabled = false;
            this._mpFlag.mouseChildren = false;
            this._mpFlag.enabled = false;
            this._mpFlag.gotoAndPlay(2);
            addChild(this._mpFlag);
            setTimeout(this.hideFlag,3000);
         }
      }
      
      public function removeText() : void
      {
         if(this._txtMc != null)
         {
            stage.removeChild(this._txtMc);
            this._txtMc = null;
         }
      }
   }
}

