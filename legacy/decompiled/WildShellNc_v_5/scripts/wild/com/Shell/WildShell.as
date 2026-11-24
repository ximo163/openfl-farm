package wild.com.Shell
{
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.net.URLLoader;
   import flash.net.URLRequest;
   import wild.com.Shell.business.analyzer.setup.ParserBeast;
   import wild.com.Shell.command.CmdAPI;
   import wild.com.Shell.command.CmdSetup;
   import wild.com.Shell.model.beast.BeastBase;
   import wild.com.Shell.model.beast.BeastInfo;
   import wild.com.comm.ModuleManager;
   
   [SWF(width="500", height="375", backgroundColor="#869ca7", frameRate="24")]
   public class WildShell extends Sprite
   {
      
      private static var _cmdSetup:CmdSetup;
      
      private static var _parser:ParserBeast;
      
      private var _dataShell:DataShell;
      
      private var _cmdAPI:CmdAPI;
      
      public function WildShell()
      {
         super();
      }
      
      public static function analyzerData(param1:Object, param2:Boolean = true) : BeastBase
      {
         if(!_parser)
         {
            _parser = new ParserBeast();
         }
         var _loc3_:BeastBase = _parser.parse(param1) as BeastBase;
         return CmdSetup.getInstance().checkUpdate(_loc3_,param2);
      }
      
      public static function loadWildScene() : void
      {
         var sceneCfg:XML = null;
         sceneCfg = DataShell.InIData.wildmodule.module.(@name == "scene")[0];
         ModuleManager.loadModule(sceneCfg);
      }
      
      private function showStage(param1:Event = null) : void
      {
         if(DataShell.sceneLoaded == 0)
         {
            DataShell.sceneLoaded = 1;
            loadWildScene();
         }
      }
      
      private function onShowBeastPack(param1:EvtAPI) : void
      {
         if(DataShell.toolLoaded == 0)
         {
            DataShell.toolLoaded = 1;
            this.loadToolScene();
         }
      }
      
      private function loadToolScene() : void
      {
         var toolCfg:XML = null;
         toolCfg = DataShell.InIData.wildmodule.module.(@name == "tool")[0];
         ModuleManager.loadModule(toolCfg);
      }
      
      private function updateAnimals(param1:Event) : void
      {
         this._dataShell.animals = this._dataShell.updateAnimal;
      }
      
      public function init() : void
      {
         this._cmdAPI.api.addEventListener(EvtAPI.SHOW_BEAST_PACK,this.onShowBeastPack);
         this._cmdAPI.api.addEventListener(EvtAPI.BEAST_DATA_CHANGE,this.onDataChange);
         this._cmdAPI.api.addEventListener(EvtAPI.SHOW_WILD_STAGE,this.showStage);
         this._cmdAPI.api.addEventListener(EvtAPI.SHOW_FARM_STAGE,this.hideStage);
         this._dataShell = DataShell.getInstance();
         this._dataShell.addEventListener(DataShell.ANIMAL_UPDATE,this.updateAnimals);
         _cmdSetup = CmdSetup.getInstance();
         this.setup(this._cmdAPI.api);
      }
      
      public function initConfig(param1:IBeastAPI) : void
      {
         if(loaderInfo != null)
         {
            if(loaderInfo.hasOwnProperty("uncaughtErrorEvents"))
            {
               loaderInfo["uncaughtErrorEvents"].addEventListener("uncaughtError",this.onUncaughtError);
            }
         }
         this._cmdAPI = CmdAPI.getInstance();
         this._cmdAPI.api = param1;
         var _loc2_:URLLoader = new URLLoader();
         _loc2_.addEventListener(Event.COMPLETE,this.onComplete);
         _loc2_.load(new URLRequest(this._cmdAPI.api.addPrefix(param1.beastConfigUrl)));
      }
      
      private function onUncaughtError(param1:*) : void
      {
         param1.preventDefault();
      }
      
      private function onHideBeastPack(param1:EvtAPI) : void
      {
      }
      
      private function onComplete(param1:Event) : void
      {
         var _loc2_:XML = XML(param1.target.data);
         this._cmdAPI.api.iniData = _loc2_;
         this.init();
      }
      
      private function onDataChange(param1:Event) : void
      {
         var _loc2_:BeastBase = analyzerData(this._cmdAPI.api.beastBase) as BeastBase;
         this._dataShell.animals = _loc2_.info || new BeastInfo();
      }
      
      private function hideStage(param1:Event = null) : void
      {
      }
      
      private function setup(param1:IBeastAPI) : void
      {
         var _loc2_:Boolean = false;
         DataShell.InIData = param1.iniData;
         if(this._cmdAPI)
         {
            _loc2_ = this._cmdAPI.api.ISFARM == 0;
         }
         _cmdSetup.setup(analyzerData(param1.beastBase),_loc2_);
      }
   }
}

