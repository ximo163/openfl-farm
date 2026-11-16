package module
{
   import com.greensock.TweenLite;
   import com.minutes.ui.collections.SimpleCollection;
   import common.LocalData;
   import common.MaterialLib;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.filters.GlowFilter;
   import flash.text.TextField;
   import flash.utils.setTimeout;
   import mc.api.BeastAPI;
   import mc.control.Command;
   import mc.control.ViewControl;
   import mc.model.MData;
   import mc.model.MainData;
   import mc.model.ModelEvent;
   import mc.view.farm.AniScene;
   import mc.view.farm.BBScene;
   import mc.view.farm.DiyScene;
   import mc.view.farm.GetCropID;
   import mc.view.farm.InsectScene;
   import mc.view.farm.MPScene;
   import mc.view.farm.Research.ResearchEvent;
   import mc.view.farm.Research.ResearchModel;
   import mc.view.farm.Research.ResearchShouH;
   import mc.view.farm.RollCollection;
   import mc.view.farm.ToolBar;
   import mc.view.farm.land.Pasturelands;
   import mc.view.farm.packBar.PackBar;
   import mc.view.farm.toolsPack.ToolsPack;
   import mc.view.main.WindowControl.WControl;
   import mc.view.main.cursor.Cursor;
   import mc.view.main.window.tool.WhistleToolWindow;
   
   public class Pasture extends Sprite
   {
      
      public var rollCollection:RollCollection;
      
      private var insectScene:InsectScene;
      
      private var aniScene:AniScene;
      
      private var toolsPack:ToolsPack;
      
      private var updateFilter:Array;
      
      private var mpScene:MPScene;
      
      private var bbScene:BBScene;
      
      private var wildAnimalStage:RollCollection;
      
      private var packBar:PackBar;
      
      private var toolBar:ToolBar;
      
      private var diyScene:DiyScene;
      
      private var plands:Pasturelands;
      
      private var packs:Array = [];
      
      public function Pasture()
      {
         super();
         addEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage);
      }
      
      private function tenSec() : void
      {
         ViewControl.getInstance().dispatchEvent(new Event("removeFirstUpdateTip"));
      }
      
      private function openPack(param1:SimpleCollection = null) : void
      {
         var _loc2_:int = 0;
         while(_loc2_ < this.packs.length)
         {
            if(Boolean(param1) && this.packs[_loc2_] == param1)
            {
               addChild(this.packs[_loc2_]);
               BeastAPI.getInstance().hideBeastPack();
            }
            else if(contains(this.packs[_loc2_]))
            {
               removeChild(this.packs[_loc2_]);
               this.packs[_loc2_].visible = false;
            }
            _loc2_++;
         }
      }
      
      public function updateView(param1:TimerEvent) : void
      {
         this.filters = this.updateFilter;
      }
      
      private function playAni(param1:Event) : void
      {
         this.aniScene.playAni();
      }
      
      private function noReg(param1:Event) : void
      {
         this.toolBar.mouseChildren = false;
         this.toolBar.mouseEnabled = false;
         this.toolBar.alpha = 0.5;
      }
      
      private function init() : void
      {
         this.diyScene = new DiyScene();
         this.diyScene.addEventListener("startanimation",this.addAni);
         this.diyScene.addEventListener("endanimation",this.playAni);
         ViewControl.getInstance().addEventListener("openFirstUpdateTip",this.openFirstUpdateTip,false,0,true);
         ResearchModel.gi().addEventListener(ResearchEvent.DENSHED_RESEARCH_SHOUCOMPLETE,this.denshedResearchShou,false,0,true);
         ResearchModel.gi().addEventListener(ResearchEvent.DENSHED_RESEARCH_SHOUCOMPLETE_OK,this.denshedResearchShouOK,false,0,true);
         ViewControl.getInstance().addEventListener("removeFirstUpdateTip",this.removeFirstUpdateTip,false,0,true);
         ViewControl.getInstance().addEventListener("removeAni",this.removeAni,false,0,true);
         var _loc1_:Object = MData.getInstance().mainData.items;
         MData.getInstance().mainData.addEventListener(MainData.ITEMS,this.itemsChange);
         MData.getInstance().mainData.addEventListener("no_reg",this.noReg);
         this.aniScene = new AniScene();
         this.insectScene = new InsectScene();
         this.bbScene = new BBScene();
         this.mpScene = new MPScene();
         this.plands = new Pasturelands();
         this.wildAnimalStage = new RollCollection();
         this.wildAnimalStage.maxWidth = 1024;
         this.wildAnimalStage.maxHeight = 900;
         this.wildAnimalStage.x = -stage.stageWidth;
         this.wildAnimalStage.width = stage.stageWidth;
         this.wildAnimalStage.height = stage.stageHeight;
         this.wildAnimalStage.left = Math.floor((this.wildAnimalStage.width - stage.stageWidth) / 2) + 80;
         this.wildAnimalStage.top = 100;
         this.wildAnimalStage.reRoll();
         addChild(this.wildAnimalStage);
         this.rollCollection = new RollCollection();
         this.rollCollection.maxWidth = 1024;
         this.rollCollection.maxHeight = 768;
         this.rollCollection.width = stage.stageWidth;
         this.rollCollection.height = stage.stageHeight;
         this.rollCollection.top = 100;
         this.rollCollection.left = Math.floor((1024 - stage.stageWidth) / 2) - 10;
         this.rollCollection.reRoll();
         this.rollCollection.addChild(this.diyScene);
         this.rollCollection.addChild(this.bbScene);
         this.rollCollection.addChild(this.plands);
         this.rollCollection.addChild(this.aniScene);
         this.rollCollection.addChild(this.insectScene);
         this.rollCollection.addChild(this.mpScene);
         LocalData.rollCollection = this.rollCollection;
         LocalData.plands = this.plands;
         addChild(this.rollCollection);
         this.rollCollection.reRoll();
         this.toolBar = new ToolBar();
         this.toolBar.width = 440;
         this.toolBar.height = 52;
         this.toolBar.x = (stage.stageWidth - this.toolBar.width) / 2;
         this.toolBar.y = stage.stageHeight - this.toolBar.height;
         this.toolBar.addEventListener(MouseEvent.ROLL_OVER,this.ToolBarRollOver,false,0,true);
         this.toolBar.addEventListener("packClick",this.packClickHandler,false,0,true);
         this.toolBar.addEventListener("toolsClick",this.toolsClickHandler,false,0,true);
         this.toolBar.addEventListener("beast",this.onBeast,false,0,true);
         this.toolBar.addEventListener("hidebeast",this.onHideBeast,false,0,true);
         addChild(this.toolBar);
         LocalData.updateView = this.updateView;
         MData.getInstance().mainData.addEventListener(MainData.CURRENT_USER_CHANGE,this.currentUserChange,false,0,true);
         this.updateFilter = [new GlowFilter(0,0,0,0,0,0)];
         ViewControl.getInstance().addEventListener(EvtAPI.SHOW_WILD_STAGE,this.showWildStage);
         ViewControl.getInstance().addEventListener(EvtAPI.SHOW_FARM_STAGE,this.showFarmStage);
         BeastAPI.getInstance().addEventListener(EvtAPI.SHOW_BEAST_PACK,this.hidepack);
         BeastAPI.getInstance().wildStageContainer = this.wildAnimalStage;
         BeastAPI.getInstance().animalContainer = this.rollCollection;
         BeastAPI.getInstance().wildToolBarContainer = this;
         BeastAPI.getInstance().beastPackContainer = this.toolBar;
      }
      
      private function whistleClickHandler(param1:Event) : void
      {
         var _loc2_:WhistleToolWindow = new WhistleToolWindow();
         WControl.open(_loc2_);
      }
      
      private function toolsClickHandler(param1:Event) : void
      {
         if(!this.toolsPack)
         {
            this.toolsPack = new ToolsPack();
            this.toolsPack.addEventListener("whistleClick",this.whistleClickHandler,false,0,true);
            this.toolsPack.visible = false;
            this.packs.push(this.toolsPack);
         }
         this.toolsPack.changeBarVisible(this.toolBar);
         this.toolsPack.visible = !this.toolsPack.visible;
         this.openPack(this.toolsPack);
      }
      
      private function createPackBar() : void
      {
         if(this.packBar == null)
         {
            this.packBar = new PackBar();
         }
         this.packBar.x = (stage.stageWidth - this.packBar.width) / 2;
         this.packBar.y = this.toolBar.y - this.packBar.height + 20;
         this.packBar.visible = false;
         this.packs.push(this.packBar);
      }
      
      private function itemsChange(param1:ModelEvent) : void
      {
         var _loc3_:String = null;
         var _loc4_:String = null;
         var _loc5_:String = null;
         var _loc6_:String = null;
         var _loc7_:String = null;
         var _loc2_:Object = MData.getInstance().mainData.items;
         if(_loc2_ != null)
         {
            _loc3_ = "";
            _loc4_ = "";
            _loc5_ = "";
            _loc6_ = "";
            _loc7_ = "";
            if(_loc2_.hasOwnProperty("1"))
            {
               _loc3_ = GetCropID.idToDiyUrl2(1,_loc2_["1"]);
            }
            if(_loc2_.hasOwnProperty("2") && _loc2_["2"]["lv"] != 0)
            {
               _loc4_ = GetCropID.idToDiyUrl2(2,_loc2_["2"]);
            }
            if(_loc2_.hasOwnProperty("3") && _loc2_["3"]["lv"] != 0)
            {
               _loc5_ = GetCropID.idToDiyUrl2(3,_loc2_["3"]);
            }
            this.diyScene.setDIYUrl(_loc3_,_loc4_,_loc5_);
         }
      }
      
      private function onAddedToStage(param1:Event) : void
      {
         removeEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage);
         this.init();
      }
      
      private function onHideBeast(param1:Event) : void
      {
         BeastAPI.getInstance().hideBeastPack();
      }
      
      private function denshedResearchShou(param1:ResearchEvent) : void
      {
         var _loc2_:ResearchShouH = new ResearchShouH(param1.data["animals"]);
         _loc2_.name = "__researchsh__";
         if(ResearchModel.gi().isDen == false)
         {
            _loc2_.x = 200;
            _loc2_.y = 280;
         }
         else
         {
            _loc2_.x = 648;
            _loc2_.y = 280;
         }
         this.rollCollection.addChild(_loc2_);
      }
      
      private function openFirstUpdateTip(param1:Event) : void
      {
         var _loc3_:TextField = null;
         var _loc2_:MovieClip = MaterialLib.getInstance().getMaterial("Arrow") as MovieClip;
         _loc2_.name = "__Arrow__";
         if(LocalData.reclaimType == 3)
         {
            _loc2_.tipMc.tip.text = "点击窝进行科研";
            _loc2_.tipMc.x = -1 * _loc2_.tipMc.width;
            _loc2_.bg.scaleX = -1;
            _loc2_.x = 580;
            _loc2_.y = 200;
            _loc2_.play();
         }
         else
         {
            _loc2_.tipMc.tip.text = "点击棚进行科研";
            _loc2_.bg.scaleX = 1;
            _loc2_.x = 450;
            _loc2_.y = 200;
            _loc2_.play();
         }
         this.rollCollection.addChild(_loc2_);
         setTimeout(this.tenSec,10000);
      }
      
      private function changeCursor() : void
      {
         Cursor.setAPICurosr("Cursor_Wild_Arrow",null,"CursorWildArrow");
      }
      
      private function denshedResearchShouOK(param1:ResearchEvent) : void
      {
         var _loc2_:ResearchShouH = this.rollCollection.getChildByName("__researchsh__") as ResearchShouH;
         if(_loc2_)
         {
            this.rollCollection.removeChild(_loc2_);
            _loc2_ = null;
         }
      }
      
      private function currentUserChange(param1:Event) : void
      {
         if(this.toolsPack)
         {
            this.toolsPack.changeBarVisible();
         }
         if(this.toolBar)
         {
            this.toolBar.changeBarVisible();
         }
         this.toolBar.showMe = MData.getInstance().mainData.me;
      }
      
      private function removeAni(param1:Event) : void
      {
         this.aniScene.removeAni();
      }
      
      private function onBeast(param1:Event) : void
      {
         BeastAPI.getInstance().showBeastPack();
      }
      
      private function ToolBarRollOver(param1:MouseEvent) : void
      {
         this.plands.stopAnimalMouseMove();
      }
      
      private function showWildStage(param1:Event) : void
      {
         TweenLite.to(this.wildAnimalStage,0.5,{"x":0});
         TweenLite.to(this.rollCollection,0.5,{
            "x":stage.stageWidth,
            "onComplete":this.changeCursor
         });
         this.toolBar.visible = false;
      }
      
      private function hidepack(param1:Event) : void
      {
         this.openPack(null);
      }
      
      private function removeFirstUpdateTip(param1:Event) : void
      {
         var _loc2_:MovieClip = this.rollCollection.getChildByName("__Arrow__") as MovieClip;
         if(_loc2_)
         {
            this.rollCollection.removeChild(_loc2_);
            _loc2_ = null;
         }
      }
      
      private function packClickHandler(param1:Event) : void
      {
         if(this.packBar == null)
         {
            this.createPackBar();
         }
         this.packBar.visible = !this.packBar.visible;
         if(this.packBar.visible)
         {
            Command.getInstance().farmCommand.getUserSeed();
         }
         this.openPack(this.packBar);
      }
      
      private function showFarmStage(param1:Event) : void
      {
         TweenLite.to(this.wildAnimalStage,0.5,{"x":-stage.stageWidth});
         TweenLite.to(this.rollCollection,0.5,{"x":0});
         this.toolBar.visible = true;
         Command.getInstance().mainCommand.checkStatus();
      }
      
      private function addAni(param1:Event) : void
      {
         this.aniScene.addAni();
      }
   }
}

