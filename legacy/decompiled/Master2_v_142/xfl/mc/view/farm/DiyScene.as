package mc.view.farm
{
   import com.adobe.utils.StringUtil;
   import com.minutes.net.FileLoader;
   import common.CommonData;
   import common.INI;
   import common.LocalData;
   import common.MaterialLib;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.utils.Timer;
   import flash.utils.clearTimeout;
   import flash.utils.setTimeout;
   import mc.FBridge.EventRecorder;
   import mc.FBridge.FRequest;
   import mc.control.Command;
   import mc.control.ViewControl;
   import mc.events.TipEvent;
   import mc.events.WindowEvent;
   import mc.model.MData;
   import mc.model.MainData;
   import mc.model.ModelEvent;
   import mc.view.common.BaseWindow;
   import mc.view.common.Language;
   import mc.view.farm.Research.ResearchController;
   import mc.view.farm.Research.ResearchEvent;
   import mc.view.farm.Research.ResearchModel;
   import mc.view.farm.Research.ResearchWin;
   import mc.view.main.WindowControl.WControl;
   import mc.view.main.cursor.Cursor;
   import mc.view.main.tip.TipControl;
   
   public class DiyScene extends Sprite
   {
      
      private var _btnArr:Array = [];
      
      private var _upgradeTimer:Timer;
      
      private var _endTime:Boolean = false;
      
      private var _houseD:Sprite;
      
      private var denFlag:MovieClip;
      
      private var _dogHouse:String;
      
      private var _loaded:Boolean = false;
      
      private var _house:String;
      
      private var _poolD:DisplayObject;
      
      private var _dogHouseD:Sprite;
      
      private var fileLoader:FileLoader;
      
      private var _postValue:Object;
      
      private var diyUrl:Array = [];
      
      private var _mirrorMCData:BitmapData;
      
      private var shedFlag:MovieClip;
      
      private var rollOverFilter:Array;
      
      private var _fence:String;
      
      private var reclaiming:Boolean = false;
      
      private var _fenceD:DisplayObject;
      
      private var _bgD:Sprite;
      
      private var _bg:String;
      
      private var _mirrorMC:Bitmap;
      
      private var _pool:String;
      
      public function DiyScene()
      {
         super();
         cacheAsBitmap = true;
         this.opaqueBackground = true;
         ResearchModel.gi().addEventListener(ResearchEvent.DENSHED_OPEN,this.denshedOpen,false,0,true);
         ResearchModel.gi().addEventListener(ResearchEvent.MUCH_CATCH_CGI,this.canCatchCGI,false,0,true);
         ResearchModel.gi().addEventListener(ResearchEvent.DENSHED_UPDATE,this.denshedUpdate,false,0,true);
         ViewControl.getInstance().addEventListener("animal_change",this.onUseAnimalCub,false,0,true);
      }
      
      private function showShengJiWo(param1:int) : void
      {
         if(!this._btnArr[1])
         {
            return;
         }
         this._btnArr[1]["woNongLiang"].visible = false;
         this._btnArr[1]["topNum"].text = "";
         this._btnArr[1]["kuoJian"].visible = false;
         this._btnArr[1]["shengJi"].visible = true;
         this._btnArr[1]["type"].text = "窝";
         this._btnArr[1]["kuoJianNum"].text = this.getWoNongLiang(param1);
      }
      
      private function confirmReclaim() : void
      {
         var _loc1_:int = 0;
         if(LocalData.reclaimType == 3 || LocalData.reclaimType == 1)
         {
            _loc1_ = 1;
         }
         else if(LocalData.reclaimType == 4 || LocalData.reclaimType == 2)
         {
            _loc1_ = 2;
         }
         Command.getInstance().farmCommand.reclaim({
            "type":_loc1_,
            "newitem":1
         });
         this.addUpgrageAnimation();
      }
      
      private function onComp(param1:Event) : void
      {
         var _loc6_:int = 0;
         var _loc8_:int = 0;
         var _loc9_:Sprite = null;
         var _loc10_:Sprite = null;
         var _loc2_:Object = this.fileLoader.contents;
         if(_loc2_[this._bg] != "" && _loc2_[this._bg] != "error")
         {
            if(this._bgD != null)
            {
               removeChild(this._bgD);
               this._bgD = null;
            }
            this._bgD = _loc2_[this._bg];
            if(this._bgD)
            {
               this._bgD.x = 0;
               this._bgD.y = 0;
               addChild(this._bgD);
               this._bgD.mouseChildren = false;
               this._bgD.mouseEnabled = false;
               this._bgD.cacheAsBitmap = true;
            }
         }
         if(_loc2_[this._house] != "" && _loc2_[this._house] != "error")
         {
            if(this._houseD != null)
            {
               removeChild(this._houseD);
               this._houseD = null;
            }
            if(_loc2_[this._house])
            {
               _loc9_ = new Sprite();
               _loc9_.graphics.beginFill(0,0);
               _loc9_.graphics.drawRect(-25,-30,220,200);
               _loc9_.graphics.endFill();
               _loc9_.name = "house2";
               this._houseD = new Sprite();
               this._houseD.addChild(_loc2_[this._house]);
               this._houseD.x = 149;
               this._houseD.y = 189;
               ResearchModel.gi().HouseStatus["shed"] = this._house.substr(this._house.lastIndexOf("/") + 1,this._house.length);
               this._houseD.addChild(_loc9_);
               addChild(this._houseD);
               this._houseD.name = "house2";
               if(MData.getInstance().mainData.me)
               {
                  _loc9_.addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver,false,0,true);
                  _loc9_.addEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut,false,0,true);
               }
               else
               {
                  _loc9_.removeEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver);
                  _loc9_.removeEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut);
                  _loc9_.removeEventListener(MouseEvent.CLICK,this.onMouseDown);
                  _loc9_.removeEventListener(MouseEvent.MOUSE_DOWN,this.down);
               }
            }
            this.showPengAnimaiton();
         }
         else if(_loc2_[this._house] == "error" && Boolean(LocalData.playingAnimation))
         {
            ViewControl.getInstance().dispatchEvent(new Event("removeAni"));
            this.alertWindow("error","加载棚装扮出错，请刷新。");
         }
         if(this._dogHouseD != null)
         {
            removeChild(this._dogHouseD);
            this._dogHouseD = null;
         }
         if(_loc2_[this._dogHouse] != "" && _loc2_[this._dogHouse] != "error")
         {
            if(_loc2_[this._dogHouse])
            {
               _loc10_ = new Sprite();
               _loc10_.graphics.beginFill(0,0);
               _loc10_.graphics.drawRect(-10,-50,220,200);
               _loc10_.graphics.endFill();
               _loc10_.name = "house1";
               this._dogHouseD = new Sprite();
               this._dogHouseD.addChild(_loc2_[this._dogHouse]);
               this._dogHouseD.x = 648;
               this._dogHouseD.y = 221;
               this._dogHouseD.addChild(_loc10_);
               ResearchModel.gi().HouseStatus["den"] = this._dogHouse.substr(this._dogHouse.lastIndexOf("/") + 1,this._dogHouse.length);
               addChild(this._dogHouseD);
               this._dogHouseD.name = "house1";
               if(MData.getInstance().mainData.me)
               {
                  _loc10_.addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver,false,0,true);
                  _loc10_.addEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut,false,0,true);
               }
               else
               {
                  _loc10_.removeEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver);
                  _loc10_.removeEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut);
                  _loc10_.removeEventListener(MouseEvent.CLICK,this.onMouseDown);
                  _loc10_.removeEventListener(MouseEvent.MOUSE_DOWN,this.down);
               }
            }
            this.showWoAnimation();
         }
         else if(_loc2_[this._house] == "error" && Boolean(LocalData.playingAnimation))
         {
            ViewControl.getInstance().dispatchEvent(new Event("removeAni"));
            this.alertWindow("error","加载窝装扮出错，请刷新。");
         }
         var _loc3_:Object = MData.getInstance().mainData.host;
         var _loc4_:int = MData.getInstance().mainData.expToGrade(_loc3_["exp"]);
         var _loc5_:ResearchModel = ResearchModel.gi();
         var _loc7_:Boolean = true;
         if(this._house)
         {
            _loc6_ = int(_loc5_.DenShedLevel["shed"]);
         }
         else
         {
            _loc6_ = 0;
         }
         if(MData.getInstance().mainData.me)
         {
            this.addReclaimButton(new Point(170,310),2,"peng");
         }
         if(_loc6_ < 8 && MData.getInstance().mainData.me)
         {
            this.showKuoJianPeng(_loc6_);
         }
         else if(_loc6_ >= 8 && _loc6_ <= 13 && MData.getInstance().mainData.me)
         {
            if(_loc6_ < 13)
            {
               this.showShengJiPeng(_loc6_);
            }
            else
            {
               this.showManJiPeng(_loc6_);
            }
            if(_loc4_ >= int(INI.getInstance().data.levels))
            {
               _loc5_.UpdataPLevel = _loc6_ - 7;
               if(_loc6_ > 8)
               {
                  if(_loc9_)
                  {
                     _loc9_.buttonMode = true;
                     _loc9_.addEventListener(MouseEvent.CLICK,this.onMouseDown,false,0,true);
                     _loc9_.addEventListener(MouseEvent.MOUSE_DOWN,this.down,false,0,true);
                  }
                  _loc7_ = true;
                  _loc8_ = 0;
                  while(_loc8_ < _loc5_.UpdataP2.length)
                  {
                     if(_loc5_.UpdataP2[_loc8_]["endtime"] != 0)
                     {
                        _loc7_ = false;
                        break;
                     }
                     _loc8_++;
                  }
               }
            }
         }
         if(this._dogHouse)
         {
            _loc6_ = int(_loc5_.DenShedLevel["den"]);
         }
         else
         {
            _loc6_ = 0;
         }
         if(MData.getInstance().mainData.me)
         {
            this.addReclaimButton(new Point(780,309),1,"wo");
         }
         if(_loc6_ < 8 && MData.getInstance().mainData.me)
         {
            this.showKuoJianWo(_loc6_);
         }
         else if(_loc6_ >= 8 && _loc6_ <= 13 && MData.getInstance().mainData.me)
         {
            if(_loc6_ < 13)
            {
               this.showShengJiWo(_loc6_);
            }
            else
            {
               this.showManJianWo(_loc6_);
            }
            if(_loc4_ >= int(INI.getInstance().data.levels))
            {
               _loc5_.UpdataWLevel = _loc6_ - 7;
               if(_loc6_ > 8)
               {
                  if(_loc10_)
                  {
                     _loc10_.buttonMode = true;
                     _loc10_.addEventListener(MouseEvent.CLICK,this.onMouseDown,false,0,true);
                     _loc10_.addEventListener(MouseEvent.MOUSE_DOWN,this.down,false,0,true);
                  }
                  _loc7_ = true;
                  _loc8_ = 0;
                  while(_loc8_ < _loc5_.UpdataW2.length)
                  {
                     if(_loc5_.UpdataW2[_loc8_]["endtime"] != 0)
                     {
                        _loc7_ = false;
                        break;
                     }
                     _loc8_++;
                  }
                  if(_loc7_)
                  {
                     this.speak(this.denFlag,_loc5_.speakingWord,this._dogHouseD);
                  }
               }
            }
         }
         this._loaded = true;
         if(!LocalData.playingAnimation)
         {
            ViewControl.getInstance().dispatchEvent(new Event("removeAni"));
         }
         this.endAnimation();
      }
      
      private function confirmUpDataDen(param1:String) : void
      {
         var _loc2_:int = 0;
         switch(param1)
         {
            case UpdataDen.GOLD_BUY:
               this.confirmReclaim();
               break;
            case UpdataDen.QD_BUY:
               _loc2_ = 0;
               if(LocalData.reclaimType == 3 || LocalData.reclaimType == 1)
               {
                  _loc2_ = 13;
               }
               else if(LocalData.reclaimType == 4 || LocalData.reclaimType == 2)
               {
                  _loc2_ = 14;
               }
               this.verifyQBRequest(LocalData.houseLevel + 1,"窝棚升级",_loc2_,1);
         }
      }
      
      private function diyBuyVerifyFn(param1:Object) : void
      {
         var _loc2_:Object = {};
         if(param1.hasOwnProperty("code"))
         {
            EventRecorder.recordSueecssEvent("160956",0);
            _loc2_["code"] = 1;
            _loc2_["postValue"] = this._postValue;
            if(param1.hasOwnProperty("open") && param1["open"] == "1")
            {
               _loc2_["open"] = param1["open"];
            }
         }
         else if(param1.hasOwnProperty("errorType"))
         {
            EventRecorder.recordErrorEvent("160956",0,14);
            _loc2_["code"] = 0;
            _loc2_["errorType"] = param1["errorType"];
            _loc2_["direction"] = param1["errorContent"];
         }
         this.returnFn(_loc2_);
      }
      
      private function returnFn(param1:Object) : void
      {
         var _loc2_:Object = null;
         var _loc3_:int = 0;
         if(param1["open"] == "1")
         {
            _loc2_ = new Object();
            if(LocalData.reclaimType == 3 || LocalData.reclaimType == 1)
            {
               _loc3_ = 13;
            }
            else if(LocalData.reclaimType == 4 || LocalData.reclaimType == 2)
            {
               _loc3_ = 14;
            }
            _loc2_["payitem"] = _loc3_ * 10000 + (LocalData.houseLevel + 1) + "-" + 1 + "-窝棚升级";
            _loc2_["payType"] = 1;
            FRequest.getInstance().postRequest2("cgi_pasture_shop_pay",_loc2_,Command.getInstance().mainCommand.onInGamePreCheckSuccess);
            MainData.inGameBuyType = "UpdateDenAndShed";
            MainData.inGameBuyObject["itemType"] = param1["postValue"]["type"];
            return;
         }
         if(param1["errorType"] == "logic" || param1["errorType"] == "system")
         {
            Command.getInstance().mainCommand.alertWindow("error",param1["direction"]);
         }
      }
      
      private function getPengNongLiang(param1:Number) : String
      {
         var _loc2_:int = MData.getInstance().mainData.getAnimalNum(param1,"棚");
         var _loc3_:int = int(MData.getInstance().mainData.host["animal2"]);
         return _loc3_ + "/" + _loc2_;
      }
      
      private function showManJianWo(param1:int) : void
      {
         if(!this._btnArr[1])
         {
            return;
         }
         this._btnArr[1]["woNongLiang"].visible = true;
         this._btnArr[1]["topNum"].text = this.getWoNongLiang(param1);
         this._btnArr[1]["kuoJian"].visible = false;
         this._btnArr[1]["shengJi"].visible = false;
         this._btnArr[1]["type"].text = "";
         this._btnArr[1]["kuoJianNum"].text = "";
      }
      
      private function down(param1:MouseEvent) : void
      {
         param1.stopImmediatePropagation();
      }
      
      private function reclaimClick(param1:MouseEvent) : void
      {
         var _loc4_:int = 0;
         ResearchModel.gi().denshedType["isIn"] = false;
         var _loc2_:Array = String(param1.currentTarget.name).split("_");
         var _loc3_:String = param1.currentTarget.name;
         if(_loc3_ == "wo")
         {
            LocalData.houseLevel = ResearchModel.gi().DenShedLevel["den"];
            if(LocalData.houseLevel < 8)
            {
               LocalData.reclaimType = 1;
            }
            else if(LocalData.houseLevel < 13)
            {
               LocalData.reclaimType = 3;
            }
         }
         else if(_loc3_ == "peng")
         {
            LocalData.houseLevel = ResearchModel.gi().DenShedLevel["shed"];
            if(LocalData.houseLevel < 8)
            {
               LocalData.reclaimType = 2;
            }
            else if(LocalData.houseLevel < 13)
            {
               LocalData.reclaimType = 4;
            }
         }
         if(!this.reclaiming)
         {
            this.reclaiming = true;
            if(LocalData.reclaimType == 3 || LocalData.reclaimType == 1)
            {
               _loc4_ = 1;
            }
            else if(LocalData.reclaimType == 4 || LocalData.reclaimType == 2)
            {
               _loc4_ = 2;
            }
            Command.getInstance().farmCommand.reclaimPay({
               "level":LocalData.houseLevel,
               "type":_loc4_,
               "act":"query",
               "newitem":1
            },this.reclaimPay);
         }
      }
      
      private function denshedOpen(param1:ResearchEvent) : void
      {
         var _loc2_:Object = param1.data;
         var _loc3_:ResearchWin = new ResearchWin(_loc2_.toString());
         WControl.open(_loc3_);
      }
      
      private function getAnimalNum(param1:Number, param2:String) : Number
      {
         if(param2 == "窝")
         {
            if(param1 == 2 || param1 == 0)
            {
               return 2;
            }
            return 1;
         }
         if(param2 == "棚")
         {
            if(param1 == 0)
            {
               return 3;
            }
            return 1;
         }
         return 2;
      }
      
      private function onRollOut(param1:MouseEvent) : void
      {
         Cursor.useSystem(false);
         TipControl.hide();
      }
      
      private function canCatchCGI(param1:ResearchEvent) : void
      {
         this.reclaiming = false;
         this.addUpgrageAnimation();
      }
      
      public function setDIYUrl(param1:String, param2:String, param3:String) : void
      {
         this.diyUrl = [];
         if(this._bg != param1)
         {
            this._bg = param1;
            this.diyUrl.push(param1);
         }
         if(this._house != param3)
         {
            this._house = param3;
            this.diyUrl.push(param3);
         }
         if(this._dogHouse != param2)
         {
            this._dogHouse = param2;
            this.diyUrl.push(param2);
         }
         if(this.fileLoader == null)
         {
            this.fileLoader = new FileLoader();
            this.fileLoader.addEventListener(Event.COMPLETE,this.onComp);
         }
         this.fileLoader.load(this.diyUrl);
         this._loaded = false;
      }
      
      private function researchFn(param1:Object) : void
      {
         var _loc2_:Array = null;
         var _loc3_:ResearchModel = null;
         var _loc4_:ResearchController = null;
         if(param1["ecode"] == 0)
         {
            _loc3_ = ResearchModel.gi();
            _loc3_.UpdataW2 = param1["researchext"]["den"];
            _loc3_.UpdataP2 = param1["researchext"]["shed"];
            _loc4_ = new ResearchController();
            _loc4_.shouComplete(param1["animals"]);
            MData.getInstance().farmData.reloadUserSeed = true;
            MData.getInstance().mainData.reloadUserCrop = true;
            MData.getInstance().mainData.dispatchEvent(new ModelEvent(MainData.ITEMS));
            EventRecorder.recordSueecssEvent("160963",0);
         }
         else
         {
            if(param1.hasOwnProperty("direction"))
            {
               Command.getInstance().mainCommand.floatWindow(param1["direction"]);
               return;
            }
            if(param1.hasOwnProperty("errorContent"))
            {
               Command.getInstance().mainCommand.floatWindow(param1["errorContent"]);
               return;
            }
            Command.getInstance().mainCommand.floatWindow("系统繁忙，请稍后再试");
            EventRecorder.recordErrorEvent("160963",0,14);
         }
      }
      
      private function onMouseDown(param1:MouseEvent) : void
      {
         var _loc4_:int = 0;
         var _loc5_:Array = null;
         var _loc7_:ResearchEvent = null;
         var _loc8_:MovieClip = null;
         var _loc2_:Boolean = true;
         var _loc3_:ResearchModel = ResearchModel.gi();
         if(param1.currentTarget.name == "house1")
         {
            _loc5_ = _loc3_.UpdataW2;
            _loc4_ = 0;
            _loc3_.isDen = true;
         }
         else
         {
            _loc5_ = _loc3_.UpdataP2;
            _loc4_ = 1;
            _loc3_.isDen = false;
         }
         var _loc6_:int = 0;
         while(_loc6_ < _loc5_.length)
         {
            if(_loc5_[_loc6_]["endtime"] != 0)
            {
               if(CommonData.serverTime >= _loc5_[_loc6_]["endtime"])
               {
                  _loc2_ = false;
                  break;
               }
            }
            _loc6_++;
         }
         if(_loc2_)
         {
            _loc7_ = new ResearchEvent(ResearchEvent.DENSHED_OPEN);
            _loc7_.data = param1.currentTarget.name;
            ResearchModel.gi().dispatchEvent(_loc7_);
            ViewControl.getInstance().dispatchEvent(new Event("removeFirstUpdateTip"));
         }
         else
         {
            if(_loc4_)
            {
               _loc3_.researchType = 1;
            }
            else
            {
               _loc3_.researchType = 0;
            }
            _loc3_.pastureResearchOK(1,0,_loc4_,_loc3_.DenShedLevel["den"],_loc3_.DenShedLevel["shed"],this.researchFn);
         }
         if(this.getChildByName("__houseTip__"))
         {
            _loc8_ = this.getChildByName("__houseTip__") as MovieClip;
            removeChild(_loc8_);
            _loc8_ = null;
         }
      }
      
      private function showManJiPeng(param1:int) : void
      {
         if(!this._btnArr[2])
         {
            return;
         }
         this._btnArr[2]["pengRongLiang"].visible = true;
         this._btnArr[2]["topNum"].text = this.getPengNongLiang(param1);
         this._btnArr[2]["kuoJian"].visible = false;
         this._btnArr[2]["shengJi"].visible = false;
         this._btnArr[2]["type"].text = "";
         this._btnArr[2]["kuoJianNum"].text = "";
      }
      
      private function onUseAnimalCub(param1:Event) : void
      {
         if(MData.getInstance().mainData.me)
         {
            if(this._btnArr[1])
            {
               if(this._btnArr[1]["topNum"].text != "")
               {
                  this._btnArr[1]["topNum"].text = this.getWoNongLiang(ResearchModel.gi().DenShedLevel["den"]);
               }
               else
               {
                  this._btnArr[1]["kuoJianNum"].text = this.getWoNongLiang(ResearchModel.gi().DenShedLevel["den"]);
               }
            }
            if(this._btnArr[2])
            {
               if(this._btnArr[2]["topNum"].text != "")
               {
                  this._btnArr[2]["topNum"].text = this.getPengNongLiang(ResearchModel.gi().DenShedLevel["shed"]);
               }
               else
               {
                  this._btnArr[2]["kuoJianNum"].text = this.getPengNongLiang(ResearchModel.gi().DenShedLevel["shed"]);
               }
            }
         }
      }
      
      private function makeMirror(param1:DisplayObject) : void
      {
         if(Boolean(this._mirrorMC) && contains(this._mirrorMC))
         {
            this._mirrorMCData.dispose();
            removeChild(this._mirrorMC);
         }
         this._mirrorMCData = new BitmapData(1000,768,true,16777215);
         this._mirrorMCData.draw(param1,null,null,null,new Rectangle(5,0,1000,768));
         this._mirrorMC = new Bitmap(this._mirrorMCData);
         this._mirrorMC.x = 10;
         this._mirrorMC.scaleX = -1;
         addChild(this._mirrorMC);
      }
      
      private function showWoAnimation() : void
      {
         var reModel:ResearchModel;
         var level:int;
         var index:int = 0;
         var clearWoAni:Function = null;
         var anima1:Sprite = null;
         var anima2:Sprite = null;
         clearWoAni = function():void
         {
            clearTimeout(index);
            if(_dogHouseD.numChildren == 4)
            {
               _dogHouseD.removeChildAt(3);
               _dogHouseD.removeChildAt(0);
            }
         };
         if(!MData.getInstance().mainData.me)
         {
            return;
         }
         reModel = ResearchModel.gi();
         level = int(reModel.DenShedLevel["den"]);
         if(Boolean(level >= 9) && Boolean(this._dogHouseD) && this._dogHouseD.numChildren == 2)
         {
            anima1 = MaterialLib.getInstance().getMaterial("researchAnimationFront") as Sprite;
            anima2 = MaterialLib.getInstance().getMaterial("researchAnimationBack") as Sprite;
            this._dogHouseD.addChild(anima1);
            this._dogHouseD.addChildAt(anima2,0);
            anima2.x = -13;
            index = int(setTimeout(clearWoAni,3000));
         }
      }
      
      private function speak(param1:MovieClip, param2:String, param3:Sprite) : void
      {
         if(param1)
         {
            removeChild(param1);
            param1 = null;
         }
         param1 = MaterialLib.getInstance().getMaterial("MaoPaoFlag") as MovieClip;
         param1.talkInfo = param2;
         param1.gotoAndPlay(2);
         param1.y = param3.y + 30;
         param1.x = param3.x + 20;
         addChild(param1);
         setTimeout(this.hideMP,4000,param1,param3);
      }
      
      private function showKuoJianWo(param1:int) : void
      {
         if(!this._btnArr[1])
         {
            return;
         }
         this._btnArr[1]["woNongLiang"].visible = false;
         this._btnArr[1]["topNum"].text = "";
         this._btnArr[1]["kuoJian"].visible = true;
         this._btnArr[1]["shengJi"].visible = false;
         this._btnArr[1]["type"].text = "窝";
         this._btnArr[1]["kuoJianNum"].text = this.getWoNongLiang(param1);
      }
      
      private function showShengJiPeng(param1:int) : void
      {
         if(!this._btnArr[2])
         {
            return;
         }
         this._btnArr[2]["pengRongLiang"].visible = false;
         this._btnArr[2]["topNum"].text = "";
         this._btnArr[2]["kuoJian"].visible = false;
         this._btnArr[2]["shengJi"].visible = true;
         this._btnArr[2]["type"].text = "棚";
         this._btnArr[2]["kuoJianNum"].text = this.getPengNongLiang(param1);
      }
      
      private function addReclaimButton(param1:Point, param2:Number, param3:String) : void
      {
         var _loc4_:Sprite = null;
         if(param2 == 1)
         {
            _loc4_ = MaterialLib.getInstance().getMaterial("woPaiZi") as Sprite;
            this._btnArr[param2] = _loc4_;
         }
         else if(param2 == 2)
         {
            _loc4_ = MaterialLib.getInstance().getMaterial("pengPaiZi") as Sprite;
            this._btnArr[param2] = _loc4_;
         }
         else if(param2 == 3)
         {
            _loc4_ = MaterialLib.getInstance().getMaterial("DenUpDate") as Sprite;
         }
         _loc4_.x = param1.x;
         _loc4_.y = param1.y;
         if(param3)
         {
            _loc4_.name = param3;
         }
         _loc4_.buttonMode = true;
         _loc4_.addEventListener(MouseEvent.CLICK,this.reclaimClick);
         _loc4_.addEventListener(MouseEvent.MOUSE_DOWN,this.down);
         _loc4_.addEventListener(MouseEvent.ROLL_OVER,this.onRollOver);
         _loc4_.addEventListener(MouseEvent.ROLL_OUT,this.onRollOut);
         this.addChild(_loc4_);
      }
      
      private function addUpgrageAnimation() : void
      {
         dispatchEvent(new Event("startanimation"));
         if(this._upgradeTimer)
         {
            this._upgradeTimer.removeEventListener(TimerEvent.TIMER_COMPLETE,this.endAnimation);
            this._upgradeTimer.stop();
            this._upgradeTimer = null;
         }
         this._upgradeTimer = new Timer(3000,1);
         this._upgradeTimer.addEventListener(TimerEvent.TIMER_COMPLETE,this.endAnimation);
         this._upgradeTimer.start();
         this._endTime = false;
         LocalData.playingAnimation = true;
      }
      
      private function showKuoJianPeng(param1:int) : void
      {
         if(!this._btnArr[2])
         {
            return;
         }
         this._btnArr[2]["pengRongLiang"].visible = false;
         this._btnArr[2]["topNum"].text = "";
         this._btnArr[2]["kuoJian"].visible = true;
         this._btnArr[2]["shengJi"].visible = false;
         this._btnArr[2]["type"].text = "棚";
         this._btnArr[2]["kuoJianNum"].text = this.getPengNongLiang(param1);
      }
      
      public function verifyQBRequest(param1:int, param2:String, param3:int, param4:int, param5:int = 358) : void
      {
         var _loc6_:String = "";
         _loc6_ = INI.getInstance().data.postUrl.@verifyRequest;
         this._postValue = {};
         this._postValue["payitem"] = param3 * 10000 + param1 + "-" + param4 + "-" + param2;
         FRequest.getInstance().postRequest2(_loc6_,this._postValue,this.diyBuyVerifyFn);
      }
      
      private function endAnimation(param1:TimerEvent = null) : void
      {
         if(Boolean(param1) && Boolean(this._upgradeTimer))
         {
            this._endTime = true;
            this._upgradeTimer.removeEventListener(TimerEvent.TIMER_COMPLETE,this.endAnimation);
            this._upgradeTimer = null;
         }
         if(this._loaded && this._endTime && Boolean(LocalData.playingAnimation))
         {
            dispatchEvent(new Event("endanimation"));
            LocalData.playingAnimation = false;
            this._endTime = false;
            this._loaded = false;
         }
      }
      
      private function denshedUpdate(param1:ResearchEvent) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:Object = null;
         if(!this.reclaiming)
         {
            this.reclaiming = true;
            _loc4_ = param1.data;
            if(_loc4_)
            {
               ResearchModel.gi().isDen = _loc4_.isDen;
            }
            if(ResearchModel.gi().isDen)
            {
               _loc2_ = 1;
               _loc3_ = int(ResearchModel.gi().DenShedLevel["den"]);
               LocalData.reclaimType = _loc3_ < 8 ? 1 : 3;
               LocalData.houseLevel = _loc3_;
            }
            else
            {
               _loc2_ = 2;
               _loc3_ = int(ResearchModel.gi().DenShedLevel["shed"]);
               LocalData.reclaimType = _loc3_ < 8 ? 2 : 4;
               LocalData.houseLevel = _loc3_;
            }
            Command.getInstance().farmCommand.reclaimPay({
               "level":_loc3_,
               "type":_loc2_,
               "act":"query",
               "newitem":1
            },this.reclaimPay);
         }
      }
      
      private function alertWindow(param1:String, param2:String) : void
      {
         var _loc3_:WindowEvent = null;
         if(StringUtil.trim(param2) != "")
         {
            _loc3_ = new WindowEvent(WindowEvent.OPEN);
            _loc3_.windowName = "AlertWindow";
            _loc3_.windowArgument = {
               "type":param1,
               "text":param2
            };
            ViewControl.getInstance().dispatchEvent(_loc3_);
         }
      }
      
      private function showPengAnimaiton() : void
      {
         var reModel:ResearchModel;
         var level:int;
         var index:int = 0;
         var clearPengAni:Function = null;
         var anima1:Sprite = null;
         var anima2:Sprite = null;
         clearPengAni = function():void
         {
            clearTimeout(index);
            if(_houseD.numChildren == 4)
            {
               _houseD.removeChildAt(3);
               _houseD.removeChildAt(0);
            }
         };
         if(!MData.getInstance().mainData.me)
         {
            return;
         }
         reModel = ResearchModel.gi();
         level = int(reModel.DenShedLevel["shed"]);
         if(Boolean(level >= 9) && Boolean(this._houseD) && this._houseD.numChildren == 2)
         {
            anima1 = MaterialLib.getInstance().getMaterial("researchAnimationFront") as Sprite;
            anima2 = MaterialLib.getInstance().getMaterial("researchAnimationBack") as Sprite;
            this._houseD.addChild(anima1);
            anima1.x = 20;
            this._houseD.addChildAt(anima2,0);
            anima2.x = 20;
            anima2.y = 15;
            index = int(setTimeout(clearPengAni,3000));
         }
      }
      
      private function onRollOver(param1:MouseEvent) : void
      {
         var _loc3_:int = 0;
         Cursor.useSystem(true);
         var _loc2_:String = param1.currentTarget.name;
         if(_loc2_ == "wo")
         {
            _loc3_ = int(ResearchModel.gi().DenShedLevel["den"]);
            if(_loc3_ < 8)
            {
               TipControl.show("MouseTip","扩建窝， 养更多动物！");
            }
            else if(_loc3_ < 13)
            {
               TipControl.show("MouseTip","升级窝，科研更多动物！");
            }
            else
            {
               TipControl.show("MouseTip","窝已是最高等级！");
            }
         }
         else if(_loc2_ == "peng")
         {
            _loc3_ = int(ResearchModel.gi().DenShedLevel["shed"]);
            if(_loc3_ < 8)
            {
               TipControl.show("MouseTip","扩建棚， 养更多动物！");
            }
            else if(_loc3_ < 13)
            {
               TipControl.show("MouseTip","升级棚，科研更多动物！");
            }
            else
            {
               TipControl.show("MouseTip","棚已是最高等级！");
            }
         }
      }
      
      private function getWoNongLiang(param1:Number) : String
      {
         var _loc2_:int = MData.getInstance().mainData.getAnimalNum(param1,"窝");
         var _loc3_:int = int(MData.getInstance().mainData.host["animal1"]);
         return _loc3_ + "/" + _loc2_;
      }
      
      private function onMouseOut(param1:MouseEvent) : void
      {
         Cursor.useSystem(false);
         var _loc2_:TipEvent = new TipEvent(TipEvent.TIP_HIDE);
         ViewControl.getInstance().dispatchEvent(_loc2_);
      }
      
      private function onMouseOver(param1:MouseEvent) : void
      {
         var _loc4_:Array = null;
         var _loc2_:Boolean = true;
         var _loc3_:ResearchModel = ResearchModel.gi();
         if(param1.currentTarget.name == "house1")
         {
            _loc4_ = _loc3_.UpdataW2;
         }
         else
         {
            _loc4_ = _loc3_.UpdataP2;
         }
         var _loc5_:int = 0;
         while(_loc5_ < _loc4_.length)
         {
            if(_loc4_[_loc5_]["endtime"] != 0)
            {
               if(CommonData.serverTime >= _loc4_[_loc5_]["endtime"])
               {
                  _loc2_ = false;
                  break;
               }
            }
            _loc5_++;
         }
         if(_loc2_)
         {
            Cursor.useSystem(true);
         }
         else
         {
            Cursor.delaySetCursor("Cursor_ShengChan");
         }
         var _loc6_:TipEvent = new TipEvent(TipEvent.TIP_SHOW);
         _loc6_.tipType = "ProductInfo";
         _loc6_.tipArgument = param1.currentTarget;
         ViewControl.getInstance().dispatchEvent(_loc6_);
      }
      
      private function hideMP(param1:MovieClip, param2:Sprite) : void
      {
         if(param1 != null && this.contains(param1))
         {
            removeChild(param1);
            param1 = null;
         }
      }
      
      private function reclaimPay(param1:Object) : void
      {
         var _loc9_:Array = null;
         var _loc10_:Object = null;
         var _loc11_:String = null;
         var _loc12_:String = null;
         var _loc13_:BaseWindow = null;
         var _loc14_:String = null;
         var _loc15_:String = null;
         var _loc16_:String = null;
         var _loc17_:ResearchModel = null;
         var _loc18_:int = 0;
         var _loc19_:String = null;
         var _loc20_:String = null;
         var _loc21_:String = null;
         this.reclaiming = false;
         if(param1.hasOwnProperty("errorType"))
         {
            _loc16_ = param1["errorType"];
            if(_loc16_ == "validateCode")
            {
               return;
            }
            if(_loc16_ == "IOError" || _loc16_ == "httpStatus" || _loc16_ == "timeOut")
            {
               this.alertWindow("error","请求超时，稍后再试");
               return;
            }
            if(_loc16_ != "session" && param1.hasOwnProperty("errorContent") && StringUtil.trim(param1["errorContent"]) != "")
            {
               this.alertWindow("error",param1["errorContent"]);
               return;
            }
            return;
         }
         var _loc2_:Object = MData.getInstance().mainData.host;
         var _loc3_:int = MData.getInstance().mainData.expToGrade(_loc2_["exp"]);
         var _loc4_:Number = Number(_loc2_["money"]);
         var _loc5_:int = int(param1["level"]);
         var _loc6_:int = int(param1["money"]);
         var _loc7_:String = "";
         if(_loc3_ < _loc5_ && _loc4_ < _loc6_)
         {
            _loc7_ = "对不起，您的金币和等级均不足。";
         }
         else if(_loc3_ < _loc5_)
         {
            _loc7_ = "对不起，您的等级不足。";
         }
         else if(_loc4_ < _loc6_)
         {
            _loc7_ = "对不起，您的金币不足。";
         }
         var _loc8_:Array = ["","窝","棚","窝","棚"];
         if(LocalData.houseLevel >= 8)
         {
            EventRecorder.pgvSendClick(EventRecorder.PGVID_UPDATEDENSHED);
            EventRecorder.recordSueecssEvent(EventRecorder.DENSHED_UPDATEBUTTON,0);
            _loc9_ = ["1","2","3","4","5"];
            _loc17_ = ResearchModel.gi();
            _loc17_.needMoney = _loc6_;
            _loc18_ = LocalData.houseLevel - 8;
            _loc11_ = "                      升级后：1.进行<font color=\'#EC640B\'>" + _loc9_[_loc18_] + "</font>级科研，科研" + _loc9_[_loc18_] + "级" + _loc8_[LocalData.reclaimType] + "专属动物";
            _loc12_ = _loc11_ + "\n                                  2.可同时至少科研" + _loc17_.openResearchSize[_loc18_] + "只动物";
            _loc12_ = _loc12_ + "\n                                  3.更加炫丽的" + _loc8_[LocalData.reclaimType] + "造型";
            _loc19_ = LocalData.reclaimType == 3 ? _loc17_.userConditionw[_loc18_].g : _loc17_.userConditionp[_loc18_].g;
            if(MData.getInstance().mainData.host["yellowstatus"] >= 1)
            {
               _loc20_ = LocalData.reclaimType == 3 ? _loc17_.userConditionw[_loc18_].yq : _loc17_.userConditionp[_loc18_].yq;
            }
            else
            {
               _loc20_ = LocalData.reclaimType == 3 ? _loc17_.userConditionw[_loc18_].q : _loc17_.userConditionp[_loc18_].q;
            }
            _loc11_ = "升级第" + (LocalData.houseLevel + 1) + "级" + _loc8_[LocalData.reclaimType];
            _loc11_ = _loc11_ + ("需要等级达到<font color=\'#008800\'>" + param1["level"] + "</font>级");
            _loc11_ = _loc11_ + ("和<font color=\'#EC640B\'>" + Math.floor(param1["money"] / 10000) + "万</font>金币");
            _loc11_ = _loc11_ + ("或<font color=\'#0179F0\'>" + param1["qd"] + "</font>元宝");
            _loc17_.needQb = param1["qd"];
            _loc13_ = new UpdataDen();
            if(LocalData.reclaimType == 3)
            {
               _loc14_ = "up_w" + Number(LocalData.houseLevel || 1);
               _loc15_ = "up_w" + Number(int(LocalData.houseLevel) + 1);
            }
            if(LocalData.reclaimType == 4)
            {
               if(LocalData.houseLevel == 0)
               {
                  _loc14_ = null;
               }
               else
               {
                  _loc14_ = "up_p" + LocalData.houseLevel;
               }
               _loc15_ = "up_p" + Number(int(LocalData.houseLevel) + 1);
            }
            if(_loc3_ < _loc5_)
            {
               _loc7_ = "对不起，您的等级不足。";
            }
            else
            {
               _loc7_ = "";
            }
            if(_loc7_ == "")
            {
               _loc13_.data = {
                  "text":_loc11_,
                  "text2":_loc12_,
                  "pic1":_loc14_,
                  "pic2":_loc15_,
                  "gold":param1["money"],
                  "qd":param1["qd"],
                  "iscold":param1["iscdtime"]
               };
            }
            else
            {
               _loc13_["confirmEnable"] = false;
               _loc13_.data = {
                  "text":_loc11_,
                  "text2":_loc12_,
                  "error":_loc7_,
                  "pic1":_loc14_,
                  "pic2":_loc15_,
                  "gold":param1["money"],
                  "qd":param1["qd"],
                  "iscold":param1["iscdtime"]
               };
            }
            _loc13_["confirmFn"] = this.confirmUpDataDen;
            WControl.open(_loc13_);
         }
         else
         {
            _loc21_ = "";
            _loc9_ = ["扩建一级","扩建第二级","扩建第三级","扩建第四级","扩建第五级","扩建第六级","扩建第七级","扩建第八级","扩建第九级"];
            _loc10_ = {
               "level":param1["level"],
               "money":param1["money"],
               "house":_loc8_[LocalData.reclaimType],
               "num":this.getAnimalNum(LocalData.houseLevel,_loc8_[LocalData.reclaimType])
            };
            _loc11_ = _loc9_[LocalData.houseLevel] + _loc8_[LocalData.reclaimType] + Language.replaceText("reclaimPayText",_loc10_);
            _loc12_ = Language.replaceText("reclaimPayText2",_loc10_);
            _loc13_ = new UpgradeWindow();
            if(LocalData.reclaimType == 1)
            {
               _loc14_ = "up_w" + Number(LocalData.houseLevel || 1);
               _loc15_ = "up_w" + Number(int(LocalData.houseLevel) + 1);
            }
            if(LocalData.reclaimType == 2)
            {
               if(LocalData.houseLevel == 0)
               {
                  _loc14_ = null;
               }
               else
               {
                  _loc14_ = "up_p" + LocalData.houseLevel;
               }
               _loc15_ = "up_p" + Number(int(LocalData.houseLevel) + 1);
            }
            if(_loc7_ == "")
            {
               _loc13_.data = {
                  "text":_loc11_,
                  "text2":_loc12_,
                  "pic1":_loc14_,
                  "pic2":_loc15_
               };
            }
            else
            {
               _loc13_["confirmEnable"] = false;
               _loc13_.data = {
                  "text":_loc11_,
                  "text2":_loc12_,
                  "error":_loc7_,
                  "pic1":_loc14_,
                  "pic2":_loc15_
               };
            }
            _loc13_["confirmFn"] = this.confirmReclaim;
            WControl.open(_loc13_);
         }
      }
   }
}

