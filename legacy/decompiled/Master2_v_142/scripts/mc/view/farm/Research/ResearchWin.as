package mc.view.farm.Research
{
   import com.adobe.utils.StringUtil;
   import common.CommonData;
   import common.INI;
   import common.LocalData;
   import common.MaterialLib;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.filters.GlowFilter;
   import flash.net.URLRequest;
   import flash.text.TextField;
   import flash.utils.clearInterval;
   import flash.utils.setInterval;
   import flash.utils.setTimeout;
   import mc.FBridge.EventRecorder;
   import mc.control.Command;
   import mc.control.ViewControl;
   import mc.events.WindowEvent;
   import mc.model.FarmData;
   import mc.model.MData;
   import mc.model.MainData;
   import mc.model.ModelEvent;
   import mc.view.common.BaseWindow;
   import mc.view.common.MaterialLoaderProxy;
   import mc.view.farm.GetCropID;
   import mc.view.main.WindowControl.WControl;
   import mc.view.main.WindowControl.WindowClassLib;
   import mc.view.main.cursor.Cursor;
   import mc.view.main.tip.TipControl;
   import mc.view.main.window.shop.ShopTinWindow;
   
   public class ResearchWin extends BaseWindow
   {
      
      private var _ItemMcAry:Array;
      
      private var researchingAry:Array;
      
      private var zuyongBtnVisible:Boolean = true;
      
      private var _denShed:String;
      
      private var addNum:int = 1;
      
      private var _speedType:int;
      
      private var _model:ResearchModel;
      
      private var _canResearchAnimalDate:Array;
      
      private var _theBox:MovieClip;
      
      private var hourglassID:int;
      
      private var _lib:MaterialLib;
      
      private var _speedBox:int;
      
      private var canResearchAnimal:Array;
      
      private var _speedID:int;
      
      private var blurs:int = 0;
      
      private var nowClickName:int;
      
      public function ResearchWin(param1:String)
      {
         var denShed:String = param1;
         this.researchingAry = new Array();
         if(ResearchModel.gi().getEnter)
         {
            Command.getInstance().mainCommand.setUser();
            ResearchModel.gi().getEnter = false;
         }
         super();
         windowName = MainData.UPDATADEN_WINDOW;
         this._denShed = denShed;
         this._model = ResearchModel.gi();
         this._lib = MaterialLib.getInstance();
         this.closeVisible = false;
         this.width = 0;
         this.height = 0;
         this.mode = true;
         this._model.addEventListener(ResearchEvent.UPDATA_DEN,this.updataDenHandler,false,0,true);
         this._model.addEventListener(ResearchEvent.UPDATA_SHED,this.updataShedHandler,false,0,true);
         this._model.addEventListener(ResearchEvent.UPDATA_HOUR_GLASS_NUM_0,this.removeHourGlass,false,0,true);
         this._model.addEventListener(ResearchEvent.UPDATA_HOUR_GLASS_NUM,this.updataHourGlassNumHandler,false,0,true);
         this._model.addEventListener(ResearchEvent.UPDATEDENSHED_SUCESS,this.updateDenShedSuccess,false,0,true);
         this._model.addEventListener(ResearchEvent.DENSHED_RESEARCH_CHANGE,this.researchItemButtonStatusm,false,0,true);
         this._model.addEventListener(ResearchEvent.DENSHED_RESEARCH_ANIMAL,this.getResearchAnimalDate,false,0,true);
         this.addEventListener(MouseEvent.ROLL_OVER,function(param1:MouseEvent):void
         {
            Cursor.useSystem(true);
         });
         this.addGiftWin();
         if(this._denShed == "house1")
         {
            EventRecorder.recordSueecssEvent(EventRecorder.OPEN_RESEARCH_WIN_WO,0,null,1);
         }
         else
         {
            EventRecorder.recordSueecssEvent(EventRecorder.OPEN_RESEARCH_WIN_PENG,0,null,1);
         }
      }
      
      private function setPrevNextBtn(param1:MovieClip) : void
      {
         var prevBtnHandler:Function = null;
         var nextBtnHandler:Function = null;
         var moveenterframe:Function = null;
         var _mc:MovieClip = param1;
         prevBtnHandler = function(param1:MouseEvent):void
         {
            _mc.prevBtn.mouseEnabled = false;
            _mc.nextBtn.mouseEnabled = false;
            _mc.prevBtn.gotoAndStop(2);
            _mc.nextBtn.gotoAndStop(2);
            _mc.contents.removeEventListener(Event.ENTER_FRAME,moveenterframe);
            _mc.contents.fx = _mc.contents.x + _mc.Mask_mc.width;
            _mc.contents.addEventListener(Event.ENTER_FRAME,moveenterframe);
         };
         nextBtnHandler = function(param1:MouseEvent):void
         {
            _mc.prevBtn.mouseEnabled = false;
            _mc.nextBtn.mouseEnabled = false;
            _mc.prevBtn.gotoAndStop(2);
            _mc.nextBtn.gotoAndStop(2);
            _mc.contents.removeEventListener(Event.ENTER_FRAME,moveenterframe);
            _mc.contents.fx = _mc.contents.x - _mc.Mask_mc.width;
            _mc.contents.addEventListener(Event.ENTER_FRAME,moveenterframe);
         };
         moveenterframe = function(param1:Event):void
         {
            var _loc2_:int = 0;
            _mc.contents.x += (_mc.contents.fx - _mc.contents.x) / 5;
            if(Math.abs(_mc.contents.fx - _mc.contents.x) <= 1)
            {
               _mc.contents.x = _mc.contents.fx;
               if(_mc.contents.x > 0)
               {
                  _mc.prevBtn.mouseEnabled = false;
                  _mc.nextBtn.mouseEnabled = true;
                  _mc.nextBtn.buttonMode = true;
                  _mc.prevBtn.gotoAndStop(2);
                  _mc.nextBtn.gotoAndStop(1);
               }
               else if(_mc.contents.x <= _mc.contents.width - _mc.Mask_mc.width)
               {
                  _mc.prevBtn.buttonMode = true;
                  _mc.prevBtn.mouseEnabled = true;
                  _mc.nextBtn.mouseEnabled = false;
                  _mc.prevBtn.gotoAndStop(1);
                  _mc.nextBtn.gotoAndStop(2);
               }
               else
               {
                  _mc.nextBtn.buttonMode = true;
                  _mc.prevBtn.buttonMode = true;
                  _mc.prevBtn.mouseEnabled = true;
                  _mc.nextBtn.mouseEnabled = true;
                  _mc.prevBtn.gotoAndStop(1);
                  _mc.nextBtn.gotoAndStop(1);
               }
               _mc.contents.removeEventListener(Event.ENTER_FRAME,moveenterframe);
               _loc2_ = 0;
               while(_loc2_ < researchingAry.length)
               {
                  if(researchingAry[_loc2_].lastTime > 0)
                  {
                     if(researchingAry[_loc2_].setTime == null)
                     {
                        researchingAry[_loc2_].setTime = 0;
                     }
                     if(researchingAry[_loc2_].setTime == 0)
                     {
                        researchingAry[_loc2_].setTime = setInterval(setTimeDown,1000,_loc2_);
                     }
                  }
                  _loc2_++;
               }
            }
         };
         if(_mc.contents.x > 12.6)
         {
            _mc.contents.x = 12.6;
         }
         _mc.contents.fx = 0;
         if(_mc.contents.width > _mc.Mask_mc.width)
         {
            _mc.nextBtn.buttonMode = true;
            _mc.prevBtn.mouseEnabled = true;
            _mc.nextBtn.gotoAndStop(1);
         }
         else
         {
            _mc.nextBtn.mouseEnabled = false;
            _mc.nextBtn.gotoAndStop(2);
            _mc.prevBtn.gotoAndStop(2);
            _mc.nextBtn.visible = false;
            _mc.prevBtn.visible = false;
         }
         if(_mc.contents.x < _mc.Mask_mc.x)
         {
            _mc.nextBtn.visible = true;
            _mc.prevBtn.visible = true;
            _mc.nextBtn.buttonMode = true;
            _mc.prevBtn.mouseEnabled = true;
            _mc.prevBtn.gotoAndStop(1);
         }
         else
         {
            _mc.prevBtn.mouseEnabled = false;
            _mc.prevBtn.gotoAndStop(2);
         }
         _mc.prevBtn.removeEventListener(MouseEvent.CLICK,prevBtnHandler);
         _mc.nextBtn.removeEventListener(MouseEvent.CLICK,nextBtnHandler);
         _mc.prevBtn.addEventListener(MouseEvent.CLICK,prevBtnHandler);
         _mc.nextBtn.addEventListener(MouseEvent.CLICK,nextBtnHandler);
      }
      
      private function beginResearchClick(param1:MouseEvent) : void
      {
         this.nowClickName = int(param1.currentTarget.ID);
         var _loc2_:XML = this.canResearchAnimal[this.nowClickName];
         if(!(_loc2_.@iscoinexp == 1 || _loc2_.@iscoinexp == 2))
         {
            this._model.pastureResearch(0,_loc2_.@id,this._model.researchIndex,this.pastureResearchBackFn);
         }
      }
      
      private function toolBoxCloseClick(param1:MouseEvent = null) : void
      {
         var _loc2_:MovieClip = this.getChildByName("__tool__") as MovieClip;
         if(_loc2_)
         {
            _loc2_.closeBtn.removeEventListener(MouseEvent.CLICK,this.toolBoxCloseClick);
            removeChild(_loc2_);
            _loc2_ = null;
         }
      }
      
      private function closeAll() : void
      {
         this.toolBoxCloseClick();
         this.closeHandler();
         var _loc1_:int = 0;
         while(_loc1_ < this.researchingAry.length)
         {
            clearInterval(this.researchingAry[_loc1_].setTime);
            _loc1_++;
         }
      }
      
      private function updateDenShedSuccess(param1:ResearchEvent) : void
      {
         this.closeHandler();
      }
      
      private function setAnimalStatus(param1:int) : void
      {
         var _loc2_:MaterialLoaderProxy = null;
         var _loc5_:MovieClip = null;
         var _loc6_:Object = null;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc9_:Array = null;
         var _loc10_:XML = null;
         var _loc11_:XML = null;
         var _loc12_:Object = null;
         var _loc13_:Object = null;
         var _loc14_:Array = null;
         var _loc15_:XML = null;
         var _loc16_:XML = null;
         var _loc17_:Object = null;
         var _loc18_:Object = null;
         var _loc19_:Number = NaN;
         var _loc20_:String = null;
         var _loc3_:XML = XML(INI.getInstance().data.animals);
         var _loc4_:Array = new Array();
         this.canResearchAnimal = new Array();
         this._canResearchAnimalDate = new Array();
         this._ItemMcAry = new Array();
         if(param1 == 1)
         {
            _loc9_ = new Array();
            for each(_loc11_ in _loc3_.animal)
            {
               if(_loc11_.@researchable == 1 && _loc11_.@house == "窝")
               {
                  for each(_loc12_ in this._model.getResearchAnimalDate)
                  {
                     if(_loc12_["cId"] == _loc11_.@id)
                     {
                        _loc11_.@cLevel = _loc12_["cLevel"];
                        _loc11_.@researchTime = _loc12_["researchtime"];
                        if(_loc11_.@iscoinexp == 1)
                        {
                           _loc12_["researchcost"] = _loc11_.@researchCost = 0;
                        }
                        else
                        {
                           _loc11_.@researchCost = _loc12_["researchcost"];
                        }
                        _loc12_["iscoinexp"] = _loc11_.@iscoinexp;
                        break;
                     }
                  }
                  if(_loc11_.@iscoinexp == 1)
                  {
                     _loc10_ = _loc11_;
                  }
                  else
                  {
                     _loc9_.push(_loc11_);
                  }
               }
            }
            _loc9_.sortOn("@houseLv",Array.NUMERIC);
            _loc9_.sortOn("@cLevel",Array.NUMERIC);
            _loc7_ = 0;
            while(_loc7_ < _loc9_.length)
            {
               for each(_loc13_ in this._model.getResearchAnimalDate)
               {
                  if(_loc13_["cId"] == _loc9_[_loc7_].@id)
                  {
                     _loc6_ = _loc13_;
                     break;
                  }
               }
               _loc5_ = this._lib.getMaterial("researchItem") as MovieClip;
               _loc5_.x = _loc7_ * _loc5_.width;
               _loc5_.y = 0;
               this._theBox.box.contents.addChild(_loc5_);
               this._ItemMcAry.push(_loc5_);
               if(_loc9_[_loc7_].@houseLv > this._model.DenShedLevel["den"])
               {
                  _loc5_.gotoAndStop(2);
               }
               if(_loc9_[_loc7_].@iscoinexp == 1)
               {
                  (_loc5_.moneyIcon as MovieClip).gotoAndStop(2);
                  (_loc5_.productTxt as TextField).text = "产物";
               }
               else
               {
                  (_loc5_.productTxt as TextField).text = "价值";
               }
               _loc2_ = new MaterialLoaderProxy();
               _loc2_.setContent("1",_loc9_[_loc7_].@id);
               _loc5_.animalBox.addChild(_loc2_);
               _loc2_.buttonMode = true;
               _loc2_.name = "w" + _loc7_;
               _loc2_.addEventListener(MouseEvent.CLICK,this.animalPages);
               _loc8_ = this._model.getAnimalNeedTime(Number(_loc9_[_loc7_].@researchTime));
               _loc5_.timeTxt.text = _loc8_ + "小时";
               _loc5_.goldTxt.htmlText = "<font color=\'#333333\'>" + _loc9_[_loc7_].@researchCost + "</font>";
               if(_loc5_.jiesuotxt)
               {
                  _loc5_.jiesuotxt.text = _loc9_[_loc7_].@houseLv + "级窝解锁";
               }
               if(_loc6_)
               {
                  _loc5_.levtxt.htmlText = "<font color=\'#666666\'><b>" + _loc6_["cLevel"] + "级</b></font>";
                  if(_loc9_[_loc7_].@iscoinexp == 1)
                  {
                     _loc5_.goldCutTxt.htmlText = "<font color=\'#333333\'>" + _loc6_["procreation"] * _loc6_["output"] * _loc6_["byproductprice"] / _loc6_["cycle"] + "经验</font>";
                  }
                  else
                  {
                     _loc5_.goldCutTxt.htmlText = "<font color=\'#333333\'>" + _loc6_["productprice"] + "</font>";
                  }
                  this._canResearchAnimalDate.push(_loc6_);
               }
               else
               {
                  this._canResearchAnimalDate.push(null);
               }
               this.canResearchAnimal.push(_loc9_[_loc7_]);
               _loc7_++;
            }
            this.setPrevNextBtn(this._theBox.box);
         }
         else
         {
            _loc14_ = new Array();
            for each(_loc16_ in _loc3_.animal)
            {
               if(_loc16_.@researchable == 1 && _loc16_.@house == "棚")
               {
                  for each(_loc17_ in this._model.getResearchAnimalDate)
                  {
                     if(_loc17_["cId"] == _loc16_.@id)
                     {
                        _loc16_.@cLevel = _loc17_["cLevel"];
                        _loc16_.@researchTime = _loc17_["researchtime"];
                        if(_loc16_.@iscoinexp == 2)
                        {
                           _loc17_["researchcost"] = _loc16_.@researchCost = 0;
                        }
                        else
                        {
                           _loc16_.@researchCost = _loc17_["researchcost"];
                        }
                        _loc17_["iscoinexp"] = _loc16_.@iscoinexp;
                        break;
                     }
                  }
                  if(_loc16_.@iscoinexp == 2)
                  {
                     _loc15_ = _loc16_;
                  }
                  else
                  {
                     _loc14_.push(_loc16_);
                  }
               }
            }
            _loc14_.sortOn("@houseLv",Array.NUMERIC);
            _loc14_.sortOn("@cLevel",Array.NUMERIC);
            _loc7_ = 0;
            while(_loc7_ < _loc14_.length)
            {
               for each(_loc18_ in this._model.getResearchAnimalDate)
               {
                  if(_loc18_["cId"] == _loc14_[_loc7_].@id)
                  {
                     _loc6_ = _loc18_;
                     break;
                  }
               }
               _loc5_ = this._lib.getMaterial("researchItem") as MovieClip;
               _loc5_.x = _loc7_ * _loc5_.width;
               _loc5_.y = 0;
               this._theBox.box.contents.addChild(_loc5_);
               this._ItemMcAry.push(_loc5_);
               if(_loc14_[_loc7_].@houseLv > this._model.DenShedLevel["shed"])
               {
                  _loc5_.gotoAndStop(2);
               }
               if(_loc14_[_loc7_].@iscoinexp == 2)
               {
                  (_loc5_.moneyIcon as MovieClip).gotoAndStop(2);
                  (_loc5_.productTxt as TextField).text = "产物";
               }
               else
               {
                  (_loc5_.productTxt as TextField).text = "价值";
               }
               _loc2_ = new MaterialLoaderProxy();
               _loc2_.setContent("1",_loc14_[_loc7_].@id,null,false,false,false);
               _loc5_.animalBox.addChild(_loc2_);
               _loc2_.buttonMode = true;
               _loc2_.name = "p" + _loc7_;
               _loc2_.addEventListener(MouseEvent.CLICK,this.animalPages);
               _loc8_ = this._model.getAnimalNeedTime(Number(_loc14_[_loc7_].@researchTime));
               _loc5_.timeTxt.text = _loc8_ + "小时";
               _loc5_.goldTxt.htmlText = "<font color=\'#333333\'>" + _loc14_[_loc7_].@researchCost + "</font>";
               if(_loc5_.jiesuotxt)
               {
                  _loc5_.jiesuotxt.text = _loc14_[_loc7_].@houseLv + "级棚解锁";
               }
               if(_loc6_)
               {
                  _loc5_.levtxt.htmlText = "<font color=\'#666666\'><b>" + _loc6_["cLevel"] + "级</b></font>";
                  if(_loc14_[_loc7_].@iscoinexp == 2)
                  {
                     _loc19_ = new Number(_loc6_["procreation"] * _loc6_["output"] * _loc6_["byproductprice"] * 0.0001 / _loc6_["cycle"]);
                     _loc20_ = _loc19_.toFixed(1);
                     _loc5_.goldCutTxt.htmlText = "<font color=\'#333333\'>" + _loc20_ + "万金币</font>";
                  }
                  else
                  {
                     _loc5_.goldCutTxt.htmlText = "<font color=\'#333333\'>" + _loc6_["productprice"] + "</font>";
                  }
                  this._canResearchAnimalDate.push(_loc6_);
               }
               else
               {
                  this._canResearchAnimalDate.push(null);
               }
               this.canResearchAnimal.push(_loc14_[_loc7_]);
               _loc7_++;
            }
            this.setPrevNextBtn(this._theBox.box);
         }
      }
      
      private function useToolHandler(param1:MouseEvent) : void
      {
         var _loc2_:int = 0;
         var _loc3_:MovieClip = null;
         var _loc4_:int = 0;
         if(param1.currentTarget.currentFrame == 2)
         {
            this.hourglassID = param1.currentTarget.hourglassID;
            this._model.useHourGlass({
               "id":param1.currentTarget.hourglassID,
               "type":this._speedType,
               "index":this._speedBox
            },this.useHourGlassHandler);
            _loc2_ = int(INI.getInstance().data.hourglass.item.length());
            _loc3_ = this.getChildByName("__tool__") as MovieClip;
            if(_loc3_ == null)
            {
               return;
            }
            _loc4_ = 1;
            while(_loc4_ <= _loc2_)
            {
               _loc3_["btn" + _loc4_].mouseEnabled = true;
               _loc3_["btn" + _loc4_].enabled = false;
               _loc4_++;
            }
         }
      }
      
      private function buyhgHandler(param1:MouseEvent) : void
      {
         var _loc2_:int = int(param1.currentTarget.ID);
         var _loc3_:Object = ResearchModel.gi().tinPro[_loc2_ - 1];
         WindowClassLib.register("ShopTinWindow",ShopTinWindow);
         var _loc4_:WindowEvent = new WindowEvent(WindowEvent.OPEN);
         _loc4_.windowName = "ShopTinWindow";
         _loc4_.windowArgument = _loc3_;
         ViewControl.getInstance().dispatchEvent(_loc4_);
         this.toolBoxCloseClick();
      }
      
      private function enterframe(param1:Event) : void
      {
         var _loc2_:GlowFilter = new GlowFilter(16777215,this.blurs,this.blurs,this.blurs,this.blurs);
         this.blurs += this.addNum;
         if(this.blurs >= 5)
         {
            this.addNum = -1;
         }
         else if(this.blurs <= 0)
         {
            this.addNum = 1;
         }
         this.researchingAry[this._speedID].timeTxt.filters = [_loc2_];
      }
      
      private function setTimeDown(param1:int) : void
      {
         if(this.researchingAry[param1].lastTime <= 0)
         {
            this.closeAll();
            this.setToCanGet();
         }
         else
         {
            --this.researchingAry[param1].lastTime;
         }
         if(this.researchingAry[param1].timeTxt)
         {
            this.researchingAry[param1].timeTxt.text = this._model.endTimeDate(this.researchingAry[param1].lastTime);
         }
      }
      
      private function needNextNum() : void
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         if(this._denShed == "house1")
         {
            _loc1_ = 1;
            _loc2_ = int(this._model.DenShedLevel["den"]);
         }
         else
         {
            _loc1_ = 2;
            _loc2_ = int(this._model.DenShedLevel["shed"]);
         }
         Command.getInstance().farmCommand.reclaimPay({
            "level":_loc2_,
            "type":_loc1_,
            "act":"query",
            "newitem":1
         },this.reclaimPay);
      }
      
      private function animalPages(param1:MouseEvent) : void
      {
         var _loc2_:String = param1.currentTarget.name;
         var _loc3_:String = _loc2_.substr(1,1);
         var _loc4_:Object = this._canResearchAnimalDate[int(_loc2_.substr(1,1))];
         WindowClassLib.register("ResearchAnimalWin",ResearchAnimalWin);
         var _loc5_:WindowEvent = new WindowEvent(WindowEvent.OPEN);
         _loc5_.windowName = "ResearchAnimalWin";
         _loc5_.windowArgument = _loc4_;
         ViewControl.getInstance().dispatchEvent(_loc5_);
      }
      
      private function addGiftWin() : void
      {
         var _loc1_:Loader = new Loader();
         _loc1_.contentLoaderInfo.addEventListener(Event.COMPLETE,this.winComplete);
         _loc1_.load(new URLRequest(GetCropID.addPrefix(String(INI.getInstance().data.updataDen.@url))));
      }
      
      private function updataDenHandler(param1:ResearchEvent) : void
      {
         this.setStatus(this._model.UpdataW2,"house1");
      }
      
      private function onRollOut(param1:MouseEvent) : void
      {
         TipControl.hide();
      }
      
      private function winComplete(param1:Event) : void
      {
         var _loc2_:int = 0;
         this._lib.push(param1.currentTarget.applicationDomain);
         this._theBox = this._lib.getMaterial("UpdataDenMainBox") as MovieClip;
         this._theBox.closeBtn.addEventListener(MouseEvent.CLICK,this.closeClick);
         this.setSecDate();
         if(this._denShed == "house1")
         {
            _loc2_ = this._model.UpdataWLevel - 1;
         }
         else
         {
            _loc2_ = this._model.UpdataPLevel - 1;
         }
         this._theBox.title.gotoAndStop(_loc2_);
         addChild(this._theBox);
         this._model.getAniamlDate();
      }
      
      private function getResearchAnimalDate(param1:ResearchEvent) : void
      {
         if(this._denShed == "house1")
         {
            this.setAnimalStatus(1);
            this.setStatus(this._model.UpdataW2,"house1");
         }
         else
         {
            this.setAnimalStatus(2);
            this.setStatus(this._model.UpdataP2,"house2");
         }
      }
      
      private function onRollOver1(param1:MouseEvent) : void
      {
         TipControl.show("MouseTip","您的等级不足");
      }
      
      private function onRollOver2(param1:MouseEvent) : void
      {
         TipControl.show("MouseTip","您的金币不足");
      }
      
      private function setNextDate(param1:Number) : void
      {
         var _loc2_:int = param1;
         var _loc3_:Object = MData.getInstance().mainData.host;
         var _loc4_:Number = Number(_loc3_["money"]);
         var _loc5_:int = MData.getInstance().mainData.expToGrade(_loc3_["exp"]);
         var _loc6_:String = "";
         if(_loc5_ < _loc2_)
         {
            this._theBox.nextMc.GoldBuyBtn.gotoAndStop(2);
            this._theBox.nextMc.GoldBuyBtn.buttonMode = false;
            this._theBox.nextMc.GoldBuyBtn.addEventListener(MouseEvent.ROLL_OVER,this.onRollOver1);
            this._theBox.nextMc.GoldBuyBtn.addEventListener(MouseEvent.ROLL_OUT,this.onRollOut);
         }
         else
         {
            this._theBox.nextMc.GoldBuyBtn.gotoAndStop(1);
            this._theBox.nextMc.GoldBuyBtn.buttonMode = true;
            this._theBox.nextMc.GoldBuyBtn.mouseEnabled = true;
            this._theBox.nextMc.GoldBuyBtn.addEventListener(MouseEvent.CLICK,this.updateNextByGold);
         }
      }
      
      private function pastureResearchBackFn(param1:Object) : void
      {
         var _loc2_:Object = null;
         var _loc3_:int = 0;
         var _loc4_:Array = null;
         var _loc5_:int = 0;
         if(param1["ecode"] == 0)
         {
            EventRecorder.recordSueecssEvent("160962",0);
            if(_loc5_ == 2)
            {
               _loc2_ = {"money":-1 * Number(this.canResearchAnimal[this.nowClickName].@cost)};
            }
            else
            {
               _loc2_ = {"money":-1 * Number(this.canResearchAnimal[this.nowClickName].@cost)};
            }
            Command.getInstance().mainCommand.addMoney(_loc2_);
            if(this._model.isDen)
            {
               _loc4_ = this._model.UpdataW2;
               _loc3_ = 0;
               while(_loc3_ < _loc4_.length)
               {
                  if(_loc4_[_loc3_]["endtime"] == 0)
                  {
                     this._model.UpdataW2[_loc3_] = {
                        "endtime":param1["endtime"],
                        "animalid":this.canResearchAnimal[this.nowClickName].@id.toString(),
                        "index":this._model.UpdataW2[_loc3_]["index"],
                        "type":this._model.UpdataW2[_loc3_]["type"]
                     };
                     break;
                  }
                  _loc3_++;
               }
               this._model.dispatchEvent(new ResearchEvent(ResearchEvent.UPDATA_DEN));
               _loc5_ = this._model.UpdataWLevel;
            }
            else
            {
               _loc4_ = this._model.UpdataP2;
               _loc3_ = 0;
               while(_loc3_ < _loc4_.length)
               {
                  if(_loc4_[_loc3_]["endtime"] == 0)
                  {
                     this._model.UpdataP2[_loc3_] = {
                        "endtime":param1["endtime"],
                        "animalid":this.canResearchAnimal[this.nowClickName].@id.toString(),
                        "index":this._model.UpdataP2[_loc3_]["index"],
                        "type":this._model.UpdataP2[_loc3_]["type"]
                     };
                     break;
                  }
                  _loc3_++;
               }
               this._model.dispatchEvent(new ResearchEvent(ResearchEvent.UPDATA_SHED));
               _loc5_ = this._model.UpdataPLevel;
            }
            this.setToCanGet();
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
            EventRecorder.recordErrorEvent("160962",0,14);
            Command.getInstance().mainCommand.floatWindow("系统繁忙，请稍后再试");
         }
      }
      
      private function beginResearchOut(param1:MouseEvent) : void
      {
         TipControl.hide();
      }
      
      private function getHourGlassFn(param1:Object) : void
      {
         var _loc2_:FarmData = null;
         var _loc3_:MainData = null;
         var _loc4_:Array = null;
         var _loc5_:Array = null;
         var _loc6_:int = 0;
         if(param1.length > 0)
         {
            _loc2_ = MData.getInstance().farmData;
            _loc3_ = MData.getInstance().mainData;
            _loc2_.reloadUserSeed = false;
            _loc3_.userCubLoading = false;
            _loc4_ = new Array();
            _loc5_ = new Array();
            _loc6_ = 0;
            while(_loc6_ < param1.length)
            {
               if(param1[_loc6_]["amount"] > 0)
               {
                  _loc4_.push(param1[_loc6_]);
               }
               if(param1[_loc6_]["tId"] == "40" && param1[_loc6_]["type"] == 4)
               {
                  _loc2_.animalPackFood = param1[_loc6_];
               }
               if(param1[_loc6_]["type"] == 12 && param1[_loc6_]["amount"] != 0)
               {
                  _loc5_.push(param1[_loc6_]);
               }
               _loc6_++;
            }
            ResearchModel.gi().MyHG = _loc5_;
            _loc2_.userSeed = _loc4_;
            _loc3_.userCub = _loc4_;
            EventRecorder.recordSueecssEvent("160964",0);
         }
         else
         {
            if(param1.hasOwnProperty("direction"))
            {
               Command.getInstance().mainCommand.floatWindow(param1["direction"]);
               return;
            }
            EventRecorder.recordErrorEvent("160964",0,14);
            Command.getInstance().mainCommand.floatWindow("系统繁忙，请稍后再试");
         }
      }
      
      private function setToCanGet() : void
      {
         MData.getInstance().mainData.dispatchEvent(new ModelEvent(MainData.ITEMS));
      }
      
      private function updateNextByGold(param1:MouseEvent) : void
      {
         var _loc2_:ResearchEvent = new ResearchEvent(ResearchEvent.DENSHED_UPDATE);
         ResearchModel.gi().dispatchEvent(_loc2_);
      }
      
      private function beginResearchOver(param1:MouseEvent) : void
      {
         if(param1.currentTarget.type == "no_research")
         {
            TipControl.show("MouseTip","您的金币不足");
         }
         else
         {
            TipControl.show("MouseTip","您的科研位不够");
         }
      }
      
      private function useHourGlassHandler(param1:Object) : void
      {
         var toTime:Number = NaN;
         var nowTime:Number = NaN;
         var toolNum:int = 0;
         var toolBox:MovieClip = null;
         var i:int = 0;
         var data:Object = param1;
         if(data["ecode"] == 0)
         {
            if(this._denShed == "house1")
            {
               this._model.UpdataW2[this._speedID]["endtime"] = data["endtime"];
               toTime = Number(data["endtime"]);
            }
            else
            {
               this._model.UpdataP2[this._speedID]["endtime"] = data["endtime"];
               toTime = Number(data["endtime"]);
            }
            switch(this.hourglassID)
            {
               case 40:
                  EventRecorder.recordSueecssEvent(EventRecorder.DENSHED_HOUSEGLASS_1,0,null,10);
                  break;
               case 41:
                  EventRecorder.recordSueecssEvent(EventRecorder.DENSHED_HOUSEGLASS_2,0,null,10);
                  break;
               case 42:
                  EventRecorder.recordSueecssEvent(EventRecorder.DENSHED_HOUSEGLASS_3,0,null,10);
                  break;
               case 43:
                  EventRecorder.recordSueecssEvent(EventRecorder.DENSHED_HOUSEGLASS_4,0,null,10);
            }
            nowTime = Number(CommonData.serverTime);
            this.researchingAry[this._speedID].lastTime = toTime - nowTime;
            if(this.researchingAry[this._speedID].lastTime <= 0)
            {
               this.closeAll();
               this.setToCanGet();
            }
            this._model.setHGNum(this.hourglassID,-1);
            this._theBox.doing.addEventListener(Event.ENTER_FRAME,this.enterframe);
            setTimeout(function():void
            {
               researchingAry[_speedID].timeTxt.filters = [];
               _theBox.doing.removeEventListener(Event.ENTER_FRAME,enterframe);
            },2500);
            toolNum = int(INI.getInstance().data.hourglass.item.length());
            toolBox = this.getChildByName("__tool__") as MovieClip;
            if(toolBox == null)
            {
               return;
            }
            if(this.researchingAry[this._speedID].lastTime > 0)
            {
               i = 1;
               while(i <= toolNum)
               {
                  toolBox["btn" + i].mouseEnabled = true;
                  toolBox["btn" + i].enabled = true;
                  i++;
               }
            }
            EventRecorder.recordSueecssEvent("160965",0);
         }
         else
         {
            if(data.hasOwnProperty("direction"))
            {
               Command.getInstance().mainCommand.floatWindow(data["direction"]);
               return;
            }
            EventRecorder.recordErrorEvent("160965",0,14);
            Command.getInstance().mainCommand.floatWindow("系统繁忙，请稍后再试");
         }
      }
      
      private function removeHourGlass(param1:ResearchEvent) : void
      {
         this._model.getHourGlass(this.getHourGlassFn);
      }
      
      private function buttonStatus(param1:Boolean) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:Number = NaN;
         if(param1)
         {
            _loc2_ = 0;
            while(_loc2_ < this._ItemMcAry.length)
            {
               if(this._ItemMcAry[_loc2_].beginBtn)
               {
                  this._ItemMcAry[_loc2_].beginBtn.type = "no_research";
               }
               if(this._model.isDen)
               {
                  _loc3_ = this._model.UpdataWLevel;
               }
               else
               {
                  _loc3_ = this._model.UpdataPLevel;
               }
               if(_loc3_ == 2)
               {
                  _loc4_ = Number(this.canResearchAnimal[_loc2_].@cost);
               }
               else
               {
                  _loc4_ = Number(this.canResearchAnimal[_loc2_].@cost);
               }
               if(MData.getInstance().mainData.host["money"] >= _loc4_ || (this.canResearchAnimal[_loc2_].@iscoinexp == 1 || this.canResearchAnimal[_loc2_].@iscoinexp == 2))
               {
                  if(this._ItemMcAry[_loc2_].beginBtn)
                  {
                     this._ItemMcAry[_loc2_].beginBtn.buttonMode = true;
                     this._ItemMcAry[_loc2_].beginBtn.gotoAndStop(1);
                     this._ItemMcAry[_loc2_].beginBtn.ID = _loc2_.toString();
                     this._ItemMcAry[_loc2_].beginBtn.addEventListener(MouseEvent.CLICK,this.beginResearchClick,false,0,true);
                  }
               }
               else if(this._ItemMcAry[_loc2_].beginBtn)
               {
                  this._ItemMcAry[_loc2_].beginBtn.gotoAndStop(2);
                  this._ItemMcAry[_loc2_].beginBtn.removeEventListener(MouseEvent.CLICK,this.beginResearchClick);
                  this._ItemMcAry[_loc2_].beginBtn.addEventListener(MouseEvent.ROLL_OVER,this.beginResearchOver);
                  this._ItemMcAry[_loc2_].beginBtn.addEventListener(MouseEvent.ROLL_OUT,this.beginResearchOut);
               }
               _loc2_++;
            }
         }
         else
         {
            _loc2_ = 0;
            while(_loc2_ < this._ItemMcAry.length)
            {
               if(this._ItemMcAry[_loc2_].beginBtn)
               {
                  this._ItemMcAry[_loc2_].beginBtn.type = "research";
                  this._ItemMcAry[_loc2_].beginBtn.buttonMode = false;
                  this._ItemMcAry[_loc2_].beginBtn.gotoAndStop(2);
                  this._ItemMcAry[_loc2_].beginBtn.removeEventListener(MouseEvent.CLICK,this.beginResearchClick);
                  this._ItemMcAry[_loc2_].beginBtn.addEventListener(MouseEvent.ROLL_OVER,this.beginResearchOver);
                  this._ItemMcAry[_loc2_].beginBtn.addEventListener(MouseEvent.ROLL_OUT,this.beginResearchOut);
               }
               _loc2_++;
            }
         }
      }
      
      private function setSecDate() : void
      {
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc1_:Array = ["9","10","11","12","13"];
         var _loc2_:Array = ["窝","棚"];
         if(this._denShed == "house1")
         {
            _loc4_ = 0;
            _loc3_ = this._model.UpdataWLevel - 1;
            LocalData.reclaimType = 3;
         }
         else
         {
            _loc4_ = 1;
            _loc3_ = this._model.UpdataPLevel - 1;
            LocalData.reclaimType = 4;
         }
         this._theBox.nowresearchNum.text = this._model.openResearchSize[_loc3_ - 1];
         if(_loc3_ < 5)
         {
            this._theBox.nextMc.gotoAndStop(1);
            this._theBox.nextMc.nextresearchNum.text = this._model.openResearchSize[_loc3_];
            this.needNextNum();
         }
         else
         {
            this._theBox.nextMc.gotoAndStop(2);
         }
         this._theBox.doing.contents.mask = this._theBox.doing.Mask_mc;
         this._theBox.box.contents.mask = this._theBox.box.Mask_mc;
         this._theBox.BuyHGBtn.addEventListener(MouseEvent.CLICK,this.toShopHandler);
      }
      
      override protected function closeHandler() : void
      {
         this._model.removeEventListener(ResearchEvent.UPDATA_DEN,this.updataDenHandler);
         this._model.removeEventListener(ResearchEvent.UPDATA_SHED,this.updataShedHandler);
         this._model.removeEventListener(ResearchEvent.UPDATA_HOUR_GLASS_NUM_0,this.removeHourGlass);
         this._model.removeEventListener(ResearchEvent.UPDATA_HOUR_GLASS_NUM,this.updataHourGlassNumHandler);
         this._model.removeEventListener(ResearchEvent.UPDATEDENSHED_SUCESS,this.updateDenShedSuccess);
         this._model.removeEventListener(ResearchEvent.DENSHED_RESEARCH_CHANGE,this.researchItemButtonStatusm);
         this._model.removeEventListener(ResearchEvent.DENSHED_RESEARCH_ANIMAL,this.getResearchAnimalDate);
         super.closeHandler();
      }
      
      private function zuyongHandler(param1:MouseEvent) : void
      {
         var _loc2_:ResearchController = new ResearchController();
         _loc2_.verifyQBRequest();
      }
      
      private function speedOKHandler(param1:MouseEvent) : void
      {
         var _loc2_:MovieClip = null;
         this._speedBox = param1.currentTarget.index;
         this._speedType = param1.currentTarget.type;
         this._speedID = param1.currentTarget.ID;
         if(this.getChildByName("__tool__"))
         {
            _loc2_ = this.getChildByName("__tool__") as MovieClip;
         }
         else
         {
            _loc2_ = this._lib.getMaterial("UpdataDenTool") as MovieClip;
            _loc2_.name = "__tool__";
         }
         addChild(_loc2_);
         this._model.getHourGlass(this.getHourGlassFn);
         _loc2_.closeBtn.addEventListener(MouseEvent.CLICK,this.toolBoxCloseClick,false,0,true);
      }
      
      private function closeClick(param1:MouseEvent) : void
      {
         this.closeHandler();
      }
      
      private function updataShedHandler(param1:ResearchEvent) : void
      {
         this.setStatus(this._model.UpdataP2,"house2");
      }
      
      private function setStatus(param1:Array, param2:String) : void
      {
         var _loc4_:int = 0;
         var _loc6_:MovieClip = null;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc9_:String = null;
         var _loc11_:MaterialLoaderProxy = null;
         var _loc12_:Number = NaN;
         var _loc13_:Number = NaN;
         if(param2 != this._denShed)
         {
            return;
         }
         var _loc3_:Boolean = true;
         var _loc5_:int = int(param1.length);
         this._model.zuyongNum = 0;
         _loc4_ = 0;
         while(_loc4_ < _loc5_)
         {
            if(this.researchingAry[_loc4_] == null)
            {
               _loc6_ = this._lib.getMaterial("researching") as MovieClip;
               _loc6_.x = _loc4_ * _loc6_.width;
               _loc6_.y = 0;
               this._theBox.doing.contents.addChild(_loc6_);
               this.researchingAry[_loc4_] = _loc6_;
               this.researchingAry[_loc4_].lastTime = 0;
               this.researchingAry[_loc4_].setTime = 0;
            }
            if(param1[_loc4_]["type"] > 1)
            {
               ++this._model.zuyongNum;
            }
            if(param1[_loc4_]["endtime"] == 0)
            {
               this.researchingAry[_loc4_].gotoAndStop(2);
               if(_loc3_)
               {
                  this._model.researchIndex = param1[_loc4_]["index"];
                  this._model.researchType = param1[_loc4_]["type"];
                  _loc3_ = false;
               }
            }
            else
            {
               this.researchingAry[_loc4_].gotoAndStop(1);
               _loc11_ = new MaterialLoaderProxy();
               this.researchingAry[_loc4_].animalBox.addChild(_loc11_);
               _loc11_.setContent("1",param1[_loc4_]["animalid"]);
               _loc12_ = Number(CommonData.serverTime);
               _loc13_ = Number(param1[_loc4_]["endtime"]);
               this.researchingAry[_loc4_].lastTime = _loc13_ - _loc12_;
               this.researchingAry[_loc4_].timeTxt.text = this._model.endTimeDate(this.researchingAry[_loc4_].lastTime);
               if(this.researchingAry[_loc4_].setTime != 0)
               {
                  clearInterval(this.researchingAry[_loc4_].setTime);
                  this.researchingAry[_loc4_].setTime = 0;
               }
               this.researchingAry[_loc4_].setTime = setInterval(this.setTimeDown,1000,_loc4_);
               this.researchingAry[_loc4_].speedBtn.type = param1[_loc4_]["type"];
               this.researchingAry[_loc4_].speedBtn.ID = _loc4_.toString();
               this.researchingAry[_loc4_].speedBtn.index = param1[_loc4_]["index"];
               this.researchingAry[_loc4_].speedBtn.buttonMode = true;
               this.researchingAry[_loc4_].speedBtn.addEventListener(MouseEvent.CLICK,this.speedOKHandler,false,0,true);
            }
            _loc4_++;
         }
         if(this._denShed == "house1")
         {
            _loc7_ = this._model.UpdataWLevel - 1;
            _loc8_ = int(this._model.DenShedLevel["den"]);
            _loc9_ = "窝";
         }
         else
         {
            _loc7_ = this._model.UpdataPLevel - 1;
            _loc8_ = int(this._model.DenShedLevel["shed"]);
            _loc9_ = "棚";
         }
         var _loc10_:int = _loc5_ + (this._model.contentNum - _loc7_);
         if(_loc5_ == _loc10_)
         {
            _loc4_ = _loc5_;
            while(_loc4_ < _loc5_ + this._model.contentNum - this._model.zuyongNum)
            {
               if(this.researchingAry[_loc4_] == null)
               {
                  _loc6_ = this._lib.getMaterial("researching") as MovieClip;
                  _loc6_.x = _loc4_ * _loc6_.width;
                  _loc6_.y = 0;
                  this._theBox.doing.contents.addChild(_loc6_);
                  this.researchingAry[_loc4_] = _loc6_;
               }
               if(this._model.zuyongNum < this._model.contentNum)
               {
                  this.researchingAry[_loc4_].gotoAndStop(3);
                  if(this.zuyongBtnVisible)
                  {
                     this.researchingAry[_loc4_].zuyong.visible = true;
                     this.researchingAry[_loc4_].zuyong.addEventListener(MouseEvent.CLICK,this.zuyongHandler,false,0,true);
                     this.zuyongBtnVisible = false;
                  }
                  else
                  {
                     this.researchingAry[_loc4_].zuyong.visible = false;
                  }
               }
               else
               {
                  this.researchingAry[_loc4_].gotoAndStop(4);
               }
               this.researchingAry[_loc4_].jiesuo.text = "";
               _loc4_++;
            }
            this.zuyongBtnVisible = true;
         }
         else
         {
            _loc4_ = _loc5_;
            while(_loc4_ < _loc10_)
            {
               if(this.researchingAry[_loc4_] == null)
               {
                  _loc6_ = this._lib.getMaterial("researching") as MovieClip;
                  _loc6_.x = _loc4_ * _loc6_.width;
                  _loc6_.y = 0;
                  this._theBox.doing.contents.addChild(_loc6_);
                  this.researchingAry[_loc4_] = _loc6_;
               }
               if(this._model.zuyongNum < this._model.contentNum)
               {
                  this.researchingAry[_loc4_].gotoAndStop(3);
                  if(this.zuyongBtnVisible)
                  {
                     this.researchingAry[_loc4_].zuyong.visible = true;
                     this.researchingAry[_loc4_].zuyong.addEventListener(MouseEvent.CLICK,this.zuyongHandler,false,0,true);
                     this.zuyongBtnVisible = false;
                  }
                  else
                  {
                     this.researchingAry[_loc4_].zuyong.visible = false;
                  }
               }
               else
               {
                  this.researchingAry[_loc4_].gotoAndStop(4);
               }
               this.researchingAry[_loc4_].jiesuo.text = _loc8_ + (_loc4_ - _loc5_) + 1 + "级" + _loc9_ + "解锁";
               _loc4_++;
            }
            this.zuyongBtnVisible = true;
         }
         this.setPrevNextBtn(this._theBox.doing);
         if(this._model.zuyongNum < this._model.contentNum)
         {
            this._theBox.zuyongStatus.gotoAndStop(1);
         }
         else
         {
            this._theBox.zuyongStatus.gotoAndStop(2);
            if(this._theBox.zuyongStatus.zuyong)
            {
               this._theBox.zuyongStatus.gotoAndStop(2);
            }
         }
         this._model.dispatchEvent(new ResearchEvent(ResearchEvent.DENSHED_RESEARCH_CHANGE));
      }
      
      private function updataHourGlassNumHandler(param1:ResearchEvent) : void
      {
         var _loc4_:int = 0;
         var _loc7_:Boolean = false;
         var _loc8_:int = 0;
         var _loc9_:XML = null;
         var _loc2_:Array = this._model.MyHG;
         var _loc3_:int = int(INI.getInstance().data.hourglass.item.length());
         var _loc5_:int = int(_loc2_.length);
         var _loc6_:MovieClip = this.getChildByName("__tool__") as MovieClip;
         if(_loc6_ == null)
         {
            return;
         }
         if(_loc5_ == 0)
         {
            _loc4_ = 1;
            while(_loc4_ <= _loc3_)
            {
               _loc6_["num" + _loc4_].text = "0";
               _loc6_["btn" + _loc4_].gotoAndStop(1);
               _loc6_["btn" + _loc4_].buttonMode = true;
               _loc6_["btn" + _loc4_].ID = _loc4_;
               _loc6_["btn" + _loc4_].addEventListener(MouseEvent.CLICK,this.buyhgHandler,false,0,true);
               _loc4_++;
            }
         }
         else
         {
            _loc4_ = 1;
            while(_loc4_ <= _loc3_)
            {
               _loc7_ = true;
               _loc8_ = 0;
               while(_loc8_ < _loc5_)
               {
                  _loc9_ = INI.getInstance().data;
                  if(_loc2_[_loc8_]["tId"] == INI.getInstance().data.hourglass.item[_loc4_ - 1].@id && _loc2_[_loc8_]["type"] == INI.getInstance().data.hourglass.item[_loc4_ - 1].@type)
                  {
                     _loc7_ = false;
                     _loc6_["btn" + _loc4_].hourglassID = _loc2_[_loc8_]["tId"];
                     _loc6_["num" + _loc4_].text = _loc2_[_loc8_]["amount"];
                     _loc6_["btn" + _loc4_].gotoAndStop(2);
                     _loc6_["btn" + _loc4_].buttonMode = true;
                     _loc6_["btn" + _loc4_].addEventListener(MouseEvent.CLICK,this.useToolHandler,false,0,true);
                     break;
                  }
                  _loc8_++;
               }
               if(_loc7_)
               {
                  _loc6_["num" + _loc4_].text = "0";
                  _loc6_["btn" + _loc4_].gotoAndStop(1);
                  _loc6_["btn" + _loc4_].buttonMode = true;
                  _loc6_["btn" + _loc4_].ID = _loc4_;
                  _loc6_["btn" + _loc4_].addEventListener(MouseEvent.CLICK,this.buyhgHandler,false,0,true);
               }
               _loc4_++;
            }
         }
      }
      
      private function toShopHandler(param1:MouseEvent) : void
      {
         CommonData.shopTinPage = true;
         CommonData.shopVScroll = 100;
         WControl.openForName("shop",{"tabSelected":2});
         this.toolBoxCloseClick();
      }
      
      private function researchItemButtonStatusm(param1:ResearchEvent) : void
      {
         var _loc2_:Array = null;
         var _loc3_:int = 0;
         if(this._denShed == "house1")
         {
            _loc2_ = this._model.UpdataW2;
         }
         else
         {
            _loc2_ = this._model.UpdataP2;
         }
         var _loc4_:int = int(_loc2_.length);
         var _loc5_:Boolean = false;
         _loc3_ = 0;
         while(_loc3_ < _loc4_)
         {
            if(_loc2_[_loc3_]["endtime"] == 0)
            {
               _loc5_ = true;
               break;
            }
            _loc3_++;
         }
         this.buttonStatus(_loc5_);
      }
      
      private function reclaimPay(param1:Object) : void
      {
         var _loc2_:String = null;
         if(param1.hasOwnProperty("errorType"))
         {
            _loc2_ = param1["errorType"];
            if(_loc2_ == "validateCode")
            {
               return;
            }
            if(_loc2_ == "IOError" || _loc2_ == "httpStatus" || _loc2_ == "timeOut")
            {
               Command.getInstance().mainCommand.alertWindow("error","请求超时，稍后再试");
               return;
            }
            if(_loc2_ != "session" && param1.hasOwnProperty("errorContent") && StringUtil.trim(param1["errorContent"]) != "")
            {
               Command.getInstance().mainCommand.alertWindow("error",param1["errorContent"]);
               return;
            }
            return;
         }
         this._model.needMoney = param1["money"];
         this._model.needQb = param1["qd"];
         this._model.needLev = param1["level"];
         this.setNextDate(this._model.needLev);
      }
   }
}

