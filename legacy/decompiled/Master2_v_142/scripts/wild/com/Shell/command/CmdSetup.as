package wild.com.Shell.command
{
   import flash.display.Sprite;
   import flash.events.EventDispatcher;
   import wild.com.Shell.DataShell;
   import wild.com.Shell.business.analyzer.setup.ParserBeast;
   import wild.com.Shell.model.beast.BeastBase;
   import wild.com.Shell.model.beast.BeastInfo;
   import wild.com.Shell.stage.FarmStage;
   import wild.com.Tools.DataTools;
   
   public class CmdSetup extends EventDispatcher
   {
      
      private static var _API:IBeastAPI;
      
      private static var instance:CmdSetup;
      
      private var _isHappyAnimals:Boolean = false;
      
      private var _dataShell:DataShell;
      
      private var _farmStage:FarmStage;
      
      private var _parser:ParserBeast;
      
      public function CmdSetup()
      {
         super();
         _API = CmdAPI.getInstance().api;
         CmdAPI.getInstance().addEventListener("ShowText",this.setShowText);
         CmdAPI.getInstance().addEventListener("RemoveText",this.setRemoveText);
      }
      
      public static function getWildIcon(param1:String, param2:int, param3:String) : String
      {
         var _loc4_:String = "";
         _loc4_ = _API.iniData.folder.@url;
         _loc4_ = _API.addPrefix(_loc4_);
         return _loc4_ + ("farm/wild/pic/" + param1 + "_" + param3 + "_" + param2 + ".jpg");
      }
      
      public static function getInstance() : CmdSetup
      {
         if(!instance)
         {
            instance = new CmdSetup();
         }
         return instance;
      }
      
      public static function getWildAnimalIcon(param1:String, param2:int) : String
      {
         var _loc3_:String = "";
         _loc3_ = _API.iniData.folder.@url;
         _loc3_ = _API.addPrefix(_loc3_);
         return _loc3_ + ("farm/wild/pic/" + param1 + "_" + param2 + ".jpg");
      }
      
      private function upFn(param1:Object) : void
      {
      }
      
      public function setWildAnimal() : void
      {
         var _loc1_:BeastInfo = this._dataShell.data.info;
         if(Boolean(_loc1_) && _loc1_.length > 0)
         {
            this._dataShell.animals = _loc1_;
         }
         else
         {
            this._dataShell.animals = new BeastInfo();
         }
      }
      
      public function showText(param1:Sprite, param2:String, param3:int = 0) : void
      {
         this._farmStage.showText(param1,param2,param3);
      }
      
      public function updateServer() : void
      {
         _API.postRequest("cgi_farm_hpage_beast",{
            "isfarm":_API.ISFARM,
            "ownerId":_API.currentUser["uId"]
         },this.upFn,null,"mc");
      }
      
      public function checkUpdate(param1:BeastBase, param2:Boolean = true) : BeastBase
      {
         var _loc3_:Array = param1.info;
         var _loc4_:BeastInfo = new BeastInfo();
         var _loc5_:Boolean = false;
         var _loc6_:int = 0;
         while(_loc6_ < _loc3_.length)
         {
            if(_loc3_[_loc6_]["returntime"] <= _API.serverTime)
            {
               _loc5_ = true;
            }
            else
            {
               _loc4_.push(_loc3_[_loc6_]);
            }
            if(_loc3_[_loc6_]["stealtime"] + 3600 <= _API.serverTime)
            {
               _loc5_ = true;
            }
            _loc6_++;
         }
         param1.info = _loc4_;
         if(_loc5_ && param2)
         {
            this.updateServer();
         }
         return param1;
      }
      
      private function render() : void
      {
         this._farmStage = new FarmStage(this._isHappyAnimals);
         _API.animalContainer.addChild(this._farmStage);
         this.setWildAnimal();
      }
      
      private function showErr(param1:Object) : void
      {
         if(param1.hasOwnProperty("direction"))
         {
            _API.alertWindow("error",param1["direction"]);
         }
         else
         {
            _API.alertWindow("error","系统繁忙,请重试。");
         }
      }
      
      public function removeText() : void
      {
         this._farmStage.removeText();
      }
      
      public function getNick() : void
      {
         var postValue:Object = {
            "ownerId":_API.currentUser["uId"],
            "isfarm":_API.ISFARM
         };
         _API.postRequest("cgi_farm_beast_getnick",postValue,function(param1:Object):void
         {
            if(param1["ecode"] == 0)
            {
               _dataShell.addNickList(_API.currentUser["uId"],param1["info"]);
            }
         },null,"mc");
      }
      
      private function setRemoveText(param1:EvtAPI) : void
      {
         this._farmStage.removeText();
      }
      
      private function setShowText(param1:EvtAPI) : void
      {
         var _loc2_:Object = param1.data;
         this._farmStage.showText(_loc2_.Parent,_loc2_.type,_loc2_.num);
      }
      
      public function setup(param1:BeastBase, param2:Boolean) : void
      {
         var _loc4_:String = null;
         var _loc5_:EvtAPI = null;
         var _loc6_:Boolean = false;
         this._isHappyAnimals = param2;
         if(!param1)
         {
            return;
         }
         this._dataShell = DataShell.getInstance();
         this._dataShell.data = param1;
         this.render();
         var _loc3_:Array = this._dataShell.data.bReturn;
         for(_loc4_ in _loc3_)
         {
            if(_loc3_[_loc4_]["status"] == 3)
            {
               _loc5_ = new EvtAPI(EvtAPI.REWARD_CHANGE);
               _loc5_.data = "3";
               CmdAPI.getInstance().api.dispatchEvent(_loc5_);
               return;
            }
         }
         _loc6_ = false;
         for(_loc4_ in _loc3_)
         {
            if(_loc3_[_loc4_]["status"] == 1)
            {
               ++DataTools.getInstance().canReleaseNum;
               _loc6_ = true;
            }
         }
         if(_loc6_)
         {
            _loc5_ = new EvtAPI(EvtAPI.REWARD_CHANGE);
            _loc5_.data = "1";
            CmdAPI.getInstance().api.dispatchEvent(_loc5_);
         }
      }
   }
}

