package module.magicBaby
{
   import common.MaterialLib;
   import flash.display.InteractiveObject;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.utils.clearTimeout;
   import flash.utils.setTimeout;
   import mc.FBridge.EventRecorder;
   import mc.model.MData;
   import mc.view.common.BaseWindow;
   import mc.view.main.WindowControl.WControl;
   import mc.view.main.tip.TipControl;
   import module.missionActivity.MissionActivityHelper;
   
   public class MagicalBabyWindow extends BaseWindow
   {
      
      private var timeOut:Boolean;
      
      private var _helper:MissionActivityHelper;
      
      private var timerMark:int;
      
      private var exchangedObj:Object;
      
      private var _winSP:Sprite;
      
      public function MagicalBabyWindow()
      {
         super();
         var _loc1_:Class = MaterialLib.getInstance().getClass("MagicalBaby.Panel");
         if(_loc1_ != null)
         {
            this._winSP = new _loc1_() as Sprite;
         }
         if(this._winSP)
         {
            this.initWin();
            this.mode = true;
            this.width = 0;
            this.height = 0;
            this._winSP.x = -this._winSP.width / 2 + 60;
            this._winSP.y = -this._winSP.height / 2 + 80;
            addChild(this._winSP);
            closeVisible = false;
            WControl.open(this);
         }
      }
      
      private function __buyOK() : void
      {
         this._helper.getScoreHydra(358,MagicalBabyData.ACTIVITY_ID,this.__onScore);
      }
      
      private function __winClicked(param1:MouseEvent) : void
      {
         var _loc2_:InteractiveObject = param1.target as InteractiveObject;
         if(_loc2_ == this._winSP["shutBtn"])
         {
            this.clear();
            WControl.close(this);
         }
         else if(_loc2_ == this._winSP["spinBar"])
         {
            this.timerMark = setTimeout(this.__onTimeOut,2000);
            this.timeOut = false;
            this.exchangedObj = null;
            this._winSP["spinBar"].mouseEnabled = false;
            this._winSP["spinBar"].gotoAndPlay(1);
            this._winSP["babyMC"].gotoAndPlay(1);
            this._winSP["rollMC"].gotoAndPlay(1);
            this._winSP["rollMC"].visible = true;
            this._winSP["numMC"].visible = false;
            this._helper.exchangeForGiftHydra(358,MagicalBabyData.ACTIVITY_ID,MagicalBabyData.REWARD_PACK_ID,0,this.__onExchange);
         }
         else if(_loc2_ == this._winSP["buyBtn1"])
         {
            this._helper.buyActivityItemHydra(358,MagicalBabyData.PACK_ID_1,1,1,this.__buyOK);
         }
         else if(_loc2_ == this._winSP["buyBtn2"])
         {
            this._helper.buyActivityItemHydra(358,MagicalBabyData.PACK_ID_2,1,1,this.__buyOK);
         }
         else if(_loc2_ == this._winSP["buyBtn3"])
         {
            this._helper.buyActivityItemHydra(358,MagicalBabyData.PACK_ID_3,1,1,this.__buyOK);
         }
      }
      
      private function showRewards() : void
      {
         var _loc1_:String = null;
         var _loc2_:String = null;
         this._winSP["spinBar"].mouseEnabled = true;
         this._winSP["babyMC"].gotoAndStop(1);
         this._winSP["rollMC"].gotoAndStop(1);
         this._winSP["rollMC"].visible = false;
         this._winSP["numMC"].visible = true;
         this._winSP["numMC"]["numTxt"].text = this.exchangedObj.num + "";
         if(this.exchangedObj.isEXPBaby)
         {
            this._winSP["babyMC"].gotoAndStop(6);
            _loc1_ = "经验宝宝";
         }
         else
         {
            this._winSP["babyMC"].gotoAndStop(1);
            _loc1_ = "金币宝宝";
         }
         if(this.exchangedObj.num > 0)
         {
            _loc2_ = "恭喜！免费获得" + this.exchangedObj.num + "只" + _loc1_ + "，放入背包了呦~";
         }
         else
         {
            _loc2_ = "啊呕~米有抽到神奇宝宝，再接再厉哦！";
         }
         this._helper.showBubbleMessage(_loc2_);
         MData.getInstance().farmData.reloadUserSeed = true;
         this._helper.getScoreHydra(358,MagicalBabyData.ACTIVITY_ID,this.__onScore);
      }
      
      private function __onTimeOut() : void
      {
         clearTimeout(this.timerMark);
         this.timeOut = true;
         if(this.exchangedObj)
         {
            this.showRewards();
         }
      }
      
      private function __onScore(param1:Object) : void
      {
         if(param1.hasOwnProperty("ret") && param1.ret == 0)
         {
            this._winSP["spinTip"].visible = true;
            if(param1.score_1 > 0)
            {
               this._winSP["spinBar"].visible = true;
               this._winSP["spinBarGray"].visible = false;
               this._winSP["spinTip"].gotoAndStop(2);
            }
            else
            {
               this._winSP["spinBar"].visible = false;
               this._winSP["spinBarGray"].visible = true;
               this._winSP["spinTip"].gotoAndStop(1);
            }
            if(param1.hasOwnProperty("score_1"))
            {
               this._winSP["timesTxt"].text = param1.score_1;
            }
            else
            {
               this._winSP["timesTxt"].text = 0;
            }
            EventRecorder.recordSueecssEvent("160952",0);
         }
         else
         {
            this._winSP["spinTip"].visible = false;
            this._winSP["spinBar"].visible = false;
            this._winSP["spinBarGray"].visible = true;
            this._winSP["timesTxt"].text = "n";
            EventRecorder.recordErrorEvent("160952",0,14);
         }
      }
      
      private function initWin() : void
      {
         this._winSP["spinBar"].visible = false;
         this._winSP["spinBarGray"].visible = true;
         this._winSP["spinTip"].visible = false;
         this._winSP["spinTip"].gotoAndStop(1);
         this._winSP["babyMC"].gotoAndStop(1);
         this._winSP["rollMC"].gotoAndStop(1);
         this._winSP["rollMC"].visible = false;
         this._winSP["numMC"].visible = true;
         this._winSP["shutBtn"].buttonMode = this._winSP["spinBar"].buttonMode = this._winSP["buyBtn1"].buttonMode = this._winSP["buyBtn2"].buttonMode = this._winSP["buyBtn3"].buttonMode = true;
         this._winSP["shutBtn"].mouseChildren = this._winSP["spinBar"].mouseChildren = this._winSP["buyBtn1"].mouseChildren = this._winSP["buyBtn2"].mouseChildren = this._winSP["buyBtn3"].mouseChildren = false;
         this._winSP["shutBtn"].addEventListener(MouseEvent.CLICK,this.__winClicked);
         this._winSP["spinBar"].addEventListener(MouseEvent.CLICK,this.__winClicked);
         this._winSP["buyBtn1"].addEventListener(MouseEvent.CLICK,this.__winClicked);
         this._winSP["buyBtn2"].addEventListener(MouseEvent.CLICK,this.__winClicked);
         this._winSP["buyBtn3"].addEventListener(MouseEvent.CLICK,this.__winClicked);
         this._winSP["pack1"].addEventListener(MouseEvent.ROLL_OVER,this.__onOver);
         this._winSP["pack1"].addEventListener(MouseEvent.ROLL_OUT,this.__onOut);
         this._winSP["pack2"].addEventListener(MouseEvent.ROLL_OVER,this.__onOver);
         this._winSP["pack2"].addEventListener(MouseEvent.ROLL_OUT,this.__onOut);
         this._winSP["pack3"].addEventListener(MouseEvent.ROLL_OVER,this.__onOver);
         this._winSP["pack3"].addEventListener(MouseEvent.ROLL_OUT,this.__onOut);
         this._helper = MissionActivityHelper.gi();
         this._helper.getScoreHydra(358,MagicalBabyData.ACTIVITY_ID,this.__onScore);
      }
      
      private function __onExchange(param1:Object) : void
      {
         var _loc2_:Object = null;
         if(param1.hasOwnProperty("ret") && param1.ret == 0)
         {
            if(param1.hasOwnProperty("item") && param1.item.length > 0)
            {
               _loc2_ = param1.item[0];
               this.exchangedObj = {
                  "isEXPBaby":_loc2_.id == 1106,
                  "num":_loc2_.num,
                  "id":_loc2_.id,
                  "type":_loc2_.type - 100
               };
            }
         }
         if(!this.exchangedObj)
         {
            this.exchangedObj = {
               "isEXPBaby":false,
               "num":0
            };
         }
         if(this.timeOut)
         {
            this.showRewards();
         }
      }
      
      private function __onOver(param1:MouseEvent) : void
      {
         var _loc2_:String = null;
         if(param1.currentTarget == this._winSP["pack1"])
         {
            _loc2_ = "经验之王，收益不低于4.5经验/小时";
         }
         else if(param1.currentTarget == this._winSP["pack2"])
         {
            _loc2_ = "经验之王，收益不低于4.5经验/小时\n金币之王，收益约1081金币/小时";
         }
         else if(param1.currentTarget == this._winSP["pack3"])
         {
            _loc2_ = "金币之王，收益约1081金币/小时";
         }
         if(_loc2_ != null && _loc2_ != "")
         {
            TipControl.show("MouseTip",_loc2_);
         }
      }
      
      private function clear() : void
      {
         if(this._winSP)
         {
            removeChild(this._winSP);
            this._winSP["babyMC"].gotoAndStop(1);
            this._winSP["rollMC"].gotoAndStop(1);
            this._winSP["spinTip"].gotoAndStop(1);
            this._winSP["shutBtn"].removeEventListener(MouseEvent.CLICK,this.__winClicked);
            this._winSP["spinBar"].removeEventListener(MouseEvent.CLICK,this.__winClicked);
            this._winSP["buyBtn1"].removeEventListener(MouseEvent.CLICK,this.__winClicked);
            this._winSP["buyBtn2"].removeEventListener(MouseEvent.CLICK,this.__winClicked);
            this._winSP["buyBtn3"].removeEventListener(MouseEvent.CLICK,this.__winClicked);
            this._winSP["pack1"].removeEventListener(MouseEvent.ROLL_OVER,this.__onOver);
            this._winSP["pack1"].removeEventListener(MouseEvent.ROLL_OUT,this.__onOut);
            this._winSP["pack2"].removeEventListener(MouseEvent.ROLL_OVER,this.__onOver);
            this._winSP["pack2"].removeEventListener(MouseEvent.ROLL_OUT,this.__onOut);
            this._winSP["pack3"].removeEventListener(MouseEvent.ROLL_OVER,this.__onOver);
            this._winSP["pack3"].removeEventListener(MouseEvent.ROLL_OUT,this.__onOut);
            this._winSP = null;
         }
      }
      
      private function __onOut(param1:MouseEvent) : void
      {
         TipControl.hide();
      }
   }
}

