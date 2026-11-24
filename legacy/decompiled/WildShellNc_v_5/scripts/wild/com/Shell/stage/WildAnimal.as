package wild.com.Shell.stage
{
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Rectangle;
   import flash.utils.clearTimeout;
   import flash.utils.setTimeout;
   import wild.com.Scene.DataScene;
   import wild.com.Shell.DataShell;
   import wild.com.Shell.command.CmdAPI;
   import wild.com.Shell.command.CmdSetup;
   
   public class WildAnimal extends Sprite
   {
      
      private var _dataScene:DataScene;
      
      private var _changeCursor:Boolean = false;
      
      private var _data:Object;
      
      private var _nickInfo:Object;
      
      private var _showWeapon:Boolean = false;
      
      private var _state:String = "Stand";
      
      private var _weapons:Array = [];
      
      private var _isEntrance:Boolean = false;
      
      private var _dataShell:DataShell;
      
      private var _powerBar:MovieClip;
      
      private var _API:IBeastAPI;
      
      private var _id:int;
      
      private var _rect:Rectangle;
      
      private var _getNickTimer:uint;
      
      public var index:int;
      
      private var _loadEnd:Boolean = false;
      
      private var _isHappyAnimals:Boolean = false;
      
      private var _flag:MovieClip;
      
      private var isWeapon:Boolean = false;
      
      private var _animalMC:MovieClip = new MovieClip();
      
      public function WildAnimal(param1:int, param2:Boolean, param3:Boolean = false, param4:Boolean = false)
      {
         super();
         this._isHappyAnimals = param4;
         this._isEntrance = param3;
         this._id = param1;
         this._API = CmdAPI.getInstance().api;
         var _loc5_:String = this._API.getURL("wildanimal",{"id":this._id});
         this._API.requestClass("Wild_Animal_" + this._id,this.init,_loc5_);
         cacheAsBitmap = true;
         this._showWeapon = param2;
         this._dataShell = DataShell.getInstance();
         this._dataScene = DataScene.getInstance();
         this._dataShell.addEventListener(DataShell.NICK_CHANGE,this.showNick);
         this.cacheAsBitmap = true;
      }
      
      private function showNick(param1:Event) : void
      {
         var _loc2_:int = 0;
         var _loc3_:Weapon = null;
         if(!this._data)
         {
            return;
         }
         this._nickInfo = this._dataShell.getNickData(this._API.currentUser["uId"],this._data["fid"]);
         if(!this._nickInfo)
         {
            return;
         }
         if(this._nickInfo["attack"] != "")
         {
            _loc2_ = 0;
            while(_loc2_ < this._weapons.length)
            {
               _loc3_ = this._weapons[_loc2_];
               _loc3_.attackInfo = this._nickInfo["attack"][_loc3_.data["fid"]];
               _loc2_++;
            }
         }
         this.showName(this._nickInfo.nick);
      }
      
      private function addPowerBar() : void
      {
         if(this._powerBar)
         {
            addChild(this._powerBar);
         }
      }
      
      private function init() : void
      {
         this._loadEnd = true;
         this._animalMC = this._API.getMaterial("Wild_Animal_" + this._id) as MovieClip;
         addChild(this._animalMC);
         this._animalMC.gotoAndStop("Stand");
         this.zoomTheAnimal();
         this.mouseEnabled = false;
         this.addEventListener(MouseEvent.MOUSE_OVER,this.onRollOver,true,0,true);
         this.addEventListener(MouseEvent.MOUSE_DOWN,this.clearNick,false,0,true);
         this.addEventListener(MouseEvent.ROLL_OUT,this.onRollOut,false,0,true);
         this._animalMC.addEventListener("end",this.onEnd);
         this.setState(this._state);
         if(this._powerBar)
         {
            addChild(this._powerBar);
         }
      }
      
      private function showWeapons() : void
      {
         var _loc1_:int = 0;
         while(_loc1_ < this._weapons.length)
         {
            this._weapons[_loc1_].visible = true;
            _loc1_++;
         }
      }
      
      public function get id() : int
      {
         return this._id;
      }
      
      private function addWeapon() : void
      {
         var _loc3_:Object = null;
         var _loc4_:String = null;
         var _loc5_:Weapon = null;
         this._nickInfo = this._dataShell.getNickData(this._API.currentUser["uId"],this._data["fid"]);
         var _loc1_:Array = this.data["attack"] || [];
         var _loc2_:int = 0;
         while(_loc2_ < _loc1_.length)
         {
            _loc3_ = _loc1_[_loc2_];
            if(_loc3_["flag"] == 8 && _loc3_["issucc"] == true)
            {
               _loc4_ = this._API.getURL("wildaweapon",{"id":_loc3_["id"]});
               this._API.requestClass("Weapon_Over_" + _loc3_["id"],this.addWeaponOnMaterial,_loc4_,_loc3_);
            }
            if(_loc3_["flag"] == 1 && _loc3_["issucc"] == true)
            {
               _loc3_.id = 1;
               _loc5_ = new Weapon("Fight",_loc3_);
               _loc5_.x = this._rect.x + Math.random() * this._rect.width;
               _loc5_.y = this._rect.y + Math.random() * this._rect.height;
               addChild(_loc5_);
               _loc5_.addEventListener(MouseEvent.ROLL_OVER,this.onWeaponRollOver,false,0,true);
               _loc5_.addEventListener(MouseEvent.ROLL_OUT,this.onWeaponRollOut,false,0,true);
               this._weapons.push(_loc5_);
               if(Boolean(this._nickInfo) && Boolean(this._nickInfo["attack"]))
               {
                  _loc5_.attackInfo = this._nickInfo["attack"][_loc5_.data["fid"]];
               }
            }
            _loc2_++;
         }
         this.addPowerBar();
      }
      
      private function addWeaponOnMaterial(param1:Object) : void
      {
         var _loc2_:Weapon = new Weapon("Weapon",param1);
         _loc2_.name = DataShell.getWeaponInfo(String(param1["id"])).@name;
         _loc2_.x = this._rect.x + Math.random() * this._rect.width;
         _loc2_.y = this._rect.y + Math.random() * this._rect.height;
         addChild(_loc2_);
         if(Boolean(this._nickInfo) && Boolean(this._nickInfo["attack"]))
         {
            _loc2_.attackInfo = this._nickInfo["attack"][param1["fid"]];
         }
         _loc2_.addEventListener(MouseEvent.ROLL_OVER,this.onWeaponRollOver,false,0,true);
         _loc2_.addEventListener(MouseEvent.ROLL_OUT,this.onWeaponRollOut,false,0,true);
         this._weapons.push(_loc2_);
         this.addPowerBar();
      }
      
      private function showName(param1:String) : void
      {
         if(this.data["fid"] == this._API.hostFid)
         {
            if(this._data["status"] != 6)
            {
               this._API.showTip("MouseTip","自己的动物不能驱赶");
            }
            else
            {
               this._API.showTip("MouseTip","动物已经昏迷。");
            }
         }
         else if(this._data["status"] != 6)
         {
            this._API.showTip("MouseTip",param1 + "投放的" + DataShell.getAnimalName(this.data["type"]) + "，赶紧驱赶吧。");
         }
         else
         {
            this._API.showTip("MouseTip","动物已经昏迷。");
         }
      }
      
      public function get data() : Object
      {
         return this._data;
      }
      
      private function onRollOut(param1:MouseEvent) : void
      {
         if(this._animalMC.animal != null)
         {
            this._animalMC.animal.gotoAndStop(1);
         }
         this._API.hideTip();
         if(this._changeCursor)
         {
            this._changeCursor = false;
            this._API.setCursor("CursorArrow",null,"CursorArrow");
            if(Boolean(this._flag) && contains(this._flag))
            {
               removeChild(this._flag);
            }
         }
         this.filters = [];
         param1.stopPropagation();
      }
      
      private function hideWeapons() : void
      {
         var _loc1_:int = 0;
         while(_loc1_ < this._weapons.length)
         {
            this._weapons[_loc1_].visible = false;
            _loc1_++;
         }
      }
      
      private function onWeaponRollOut(param1:MouseEvent) : void
      {
         this.isWeapon = false;
         this.clearNick(null);
      }
      
      private function getnick() : void
      {
         CmdSetup.getInstance().getNick();
      }
      
      private function zoomTheAnimal() : void
      {
         if(this._isEntrance && !this._isHappyAnimals)
         {
            if(this._id == 4)
            {
               this._animalMC.scaleX = 0.65;
               this._animalMC.scaleY = 0.65;
            }
            else
            {
               this._animalMC.scaleX = 0.85;
               this._animalMC.scaleY = 0.85;
            }
         }
      }
      
      public function clear() : void
      {
         this._dataShell.removeEventListener(DataShell.NICK_CHANGE,this.showNick);
      }
      
      public function setState(param1:String) : void
      {
         var _loc2_:int = 0;
         this._state = param1;
         if(this._animalMC.hasOwnProperty(param1))
         {
            this._animalMC.gotoAndStop(this._state);
         }
         else if(this._loadEnd)
         {
            _loc2_ = 0;
            if(Boolean(this._animalMC) && this._animalMC.parent == this)
            {
               _loc2_ = this.getChildIndex(this._animalMC);
               removeChild(this._animalMC);
            }
            this._animalMC = this._API.getMaterial("Wild_Animal_" + this._id) as MovieClip;
            addChildAt(this._animalMC,_loc2_);
            this._animalMC.gotoAndStop(this._state);
            this.zoomTheAnimal();
         }
         if(this._state != "Stand")
         {
            this.hideWeapons();
         }
         else
         {
            this.showWeapons();
         }
      }
      
      private function clearNick(param1:MouseEvent) : void
      {
         clearTimeout(this._getNickTimer);
         this._API.hideTip();
      }
      
      public function set data(param1:Object) : void
      {
         var _loc2_:XML = null;
         var _loc3_:int = 0;
         var _loc4_:Array = null;
         this._data = param1;
         this._weapons = [];
         if(this._showWeapon)
         {
            if(!this._powerBar)
            {
               this._powerBar = this._API.getMaterial("WildPowerBar2") as MovieClip;
               addChild(this._powerBar);
            }
            _loc2_ = DataShell.getAnimalInfo(this._data["type"]);
            this._powerBar.x = 0;
            this._powerBar.y = _loc2_.p.@by;
            this._powerBar.powerTxt.text = this._data["blood"] + "/" + _loc2_.@blood;
            _loc3_ = 100 * this._data["blood"] / _loc2_.@blood;
            this._powerBar.gotoAndStop(_loc3_);
            _loc4_ = this._API.jsonDecode(_loc2_.p.weapon.text()) as Array;
            this._rect = new Rectangle(_loc4_[0],_loc4_[1],_loc4_[2],_loc4_[3]);
            if(this._data["status"] != 6)
            {
               this.addWeapon();
            }
            else
            {
               this.setState("Faint");
            }
         }
      }
      
      private function onWeaponRollOver(param1:MouseEvent) : void
      {
         if(param1.currentTarget.attackInfo)
         {
            this.isWeapon = true;
            this._API.showTip("MouseTip",param1.currentTarget.attackInfo + "造成的伤痕 ");
         }
      }
      
      private function onRollOver(param1:MouseEvent) : void
      {
         var _loc2_:XML = null;
         if(this.isWeapon)
         {
            return;
         }
         if(this._animalMC.animal != null)
         {
            this._animalMC.animal.gotoAndStop(2);
         }
         if(this._showWeapon)
         {
            this._nickInfo = this._dataShell.getNickData(this._API.currentUser["uId"],this._data["fid"]);
            if(this._nickInfo)
            {
               this.showName(this._nickInfo.nick);
            }
            else
            {
               clearTimeout(this._getNickTimer);
               this._getNickTimer = setTimeout(this.getnick,300);
            }
         }
         else if(this._API.ISFARM == 1 || this._API.cursorName == "CursorArrow")
         {
            this._changeCursor = true;
            this._API.setCursor("Wild_Cursor",null,"CursorWild");
            if(!this._flag)
            {
               this._flag = this._API.getMaterial("FightFlag") as MovieClip;
            }
            addChild(this._flag);
            this._flag.mouseEnabled = false;
            this._flag.mouseChildren = false;
            this._flag.enabled = false;
            _loc2_ = DataShell.getAnimalInfo(this._data["type"]);
            this._flag.x = _loc2_.p.@bx;
            this._flag.y = _loc2_.p.@by;
         }
         this.filters = DataShell.rollOverFilter;
         param1.stopPropagation();
      }
      
      public function get showWeapon() : Boolean
      {
         return this._showWeapon;
      }
      
      private function onEnd(param1:Event) : void
      {
         dispatchEvent(param1);
      }
      
      public function showBlood(param1:Boolean) : void
      {
         if(this._powerBar)
         {
            this._powerBar.visible = param1;
         }
      }
   }
}

