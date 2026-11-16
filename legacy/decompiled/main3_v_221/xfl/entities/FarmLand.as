package entities
{
   import common.CommonData;
   import common.GetCropID;
   import common.Settings;
   import common.misc.Utils;
   
   public final class FarmLand
   {
      
      public var _humidity:int;
      
      public var _min:int;
      
      public var _oldhumidity:*;
      
      public var _cId:int;
      
      public var _output:int;
      
      public var _waste:Boolean;
      
      public var _step:int;
      
      public var _fertilize:Boolean;
      
      public var _harvestTimes:int;
      
      public var _cropStatus:int;
      
      public var _weed:int;
      
      public var _bitmap:uint;
      
      public var _action:*;
      
      public var _thief:*;
      
      public var _plantTime:int;
      
      public var _oldweed:*;
      
      public var _updateTime:int;
      
      public var _left:int;
      
      private var goldLand:int = 0;
      
      public var _pId:int;
      
      public var _pest:int;
      
      public var _health:int;
      
      public var _oldpest:*;
      
      public function FarmLand(param1:*)
      {
         super();
         this.importObject(param1);
      }
      
      public function set _goldLand(param1:int) : void
      {
         this.goldLand = param1;
      }
      
      public function get needWater() : Boolean
      {
         if(this._humidity == false && this._step < 5)
         {
            return true;
         }
         return false;
      }
      
      public function get hasWeed() : Boolean
      {
         if(this._cId > 0 && this._weed > 0 && this._step < 5)
         {
            return true;
         }
         return false;
      }
      
      public function copyFrom(param1:Object) : void
      {
         if(param1 == null)
         {
            return;
         }
         if(param1["cId"] != undefined)
         {
            this._cId = Utils.getIntAttribute(param1,"cId");
         }
         if(param1["cropStatus"] != undefined)
         {
            this._cropStatus = Utils.getIntAttribute(param1,"cropStatus");
         }
         if(param1["weed"] != undefined)
         {
            this._weed = Utils.getIntAttribute(param1,"weed");
         }
         if(param1["pest"] != undefined)
         {
            this._pest = Utils.getIntAttribute(param1,"pest");
         }
         if(param1["humidity"] != undefined)
         {
            this._humidity = Utils.getIntAttribute(param1,"humidity");
         }
         if(param1["health"] != undefined)
         {
            this._health = Utils.getIntAttribute(param1,"health");
         }
         if(param1["harvestTimes"] != undefined)
         {
            this._harvestTimes = Utils.getIntAttribute(param1,"harvestTimes");
         }
         if(param1["output"] != undefined)
         {
            this._output = Utils.getIntAttribute(param1,"output");
         }
         if(param1["min"] != undefined)
         {
            this._min = Utils.getIntAttribute(param1,"min");
         }
         if(param1["leavings"] != undefined)
         {
            this._left = Utils.getIntAttribute(param1,"leavings");
         }
         if(param1["thief"] != undefined)
         {
            this._thief = param1["thief"];
         }
         else
         {
            this._thief = {};
         }
         if(param1["action"] != undefined)
         {
            this._action = param1["action"];
         }
         if(param1["plantTime"] != undefined)
         {
            this._plantTime = Utils.getIntAttribute(param1,"plantTime");
         }
         if(param1["updateTime"] != undefined)
         {
            this._updateTime = Utils.getIntAttribute(param1,"updateTime") - 60 * 60;
         }
         if(param1["bitmap"] != undefined)
         {
            this._bitmap = Utils.getIntAttribute(param1,"bitmap");
         }
         if(this._bitmap > 2)
         {
            this._bitmap = 2;
         }
         if(param1["pId"] != undefined)
         {
            this._pId = Utils.getIntAttribute(param1,"pId");
         }
         this._step = GetCropID.idState(this._cId,this._plantTime,this._cropStatus,this._bitmap,this._harvestTimes);
         if(param1["fertilize"] != undefined)
         {
            this._fertilize = Utils.getIntAttribute(param1,"fertilize") == this._step + 1 ? true : false;
         }
         if(param1["oldweed"] != undefined)
         {
            this._oldweed = param1["oldweed"];
         }
         if(param1["oldpest"] != undefined)
         {
            this._oldpest = param1["oldpest"];
         }
         if(param1["oldhumidity"] != undefined)
         {
            this._oldhumidity = param1["oldhumidity"];
         }
         if(param1.hasOwnProperty("goldLand"))
         {
            this._goldLand = param1["goldLand"];
         }
      }
      
      public function importObject(param1:*) : void
      {
         if(param1 == null)
         {
            return;
         }
         this._cId = Utils.getIntAttribute(param1,"a");
         this._cropStatus = Utils.getIntAttribute(param1,"b");
         this._weed = Utils.getIntAttribute(param1,"f");
         this._pest = Utils.getIntAttribute(param1,"g");
         this._humidity = Utils.getIntAttribute(param1,"h");
         this._health = Utils.getIntAttribute(param1,"i");
         this._harvestTimes = Utils.getIntAttribute(param1,"j");
         this._output = Utils.getIntAttribute(param1,"k");
         this._min = Utils.getIntAttribute(param1,"l");
         this._left = Utils.getIntAttribute(param1,"m");
         this._thief = param1["n"] == undefined ? {} : param1["n"];
         this._action = param1["p"] == undefined ? null : param1["p"];
         this._plantTime = Utils.getIntAttribute(param1,"q");
         this._updateTime = Utils.getIntAttribute(param1,"r") - 60 * 60;
         if(param1["goldLand"] == true)
         {
            this._goldLand = 1;
         }
         this._waste = false;
         this._bitmap = Utils.getIntAttribute(param1,"bitmap");
         if(this._bitmap > 2)
         {
            this._bitmap = 2;
         }
         this._pId = Utils.getIntAttribute(param1,"pId");
         this._step = GetCropID.idState(this._cId,this._plantTime,this._cropStatus,this._bitmap,this._harvestTimes);
         this._fertilize = Utils.getIntAttribute(param1,"o") == this._step + 1 ? true : false;
         this._oldweed = param1["c"];
         this._oldpest = param1["d"];
         this._oldhumidity = param1["e"];
      }
      
      public function get _goldLand() : int
      {
         var _loc3_:Array = null;
         var _loc4_:Date = null;
         var _loc5_:Date = null;
         var _loc6_:Number = NaN;
         var _loc1_:Settings = Settings.getInstance();
         var _loc2_:String = _loc1_.getStringAttribute("jinPaiLand");
         if(_loc2_)
         {
            _loc3_ = _loc2_.split("-");
            _loc4_ = new Date(_loc3_[0]);
            _loc5_ = new Date(_loc3_[1]);
            _loc6_ = CommonData.serverTime * 1000;
            if(_loc6_ >= _loc4_.time && _loc6_ <= _loc5_.time && this.goldLand == 1)
            {
               return 1;
            }
         }
         return 0;
      }
      
      public function get hasPest() : Boolean
      {
         if(this._cId > 0 && this._pest > 0 && (this._step == 3 || this._step == 4))
         {
            return true;
         }
         return false;
      }
   }
}

