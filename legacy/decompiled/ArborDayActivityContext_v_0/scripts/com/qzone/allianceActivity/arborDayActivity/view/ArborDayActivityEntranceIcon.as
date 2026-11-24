package com.qzone.allianceActivity.arborDayActivity.view
{
   import com.greensock.TweenLite;
   import com.qzone.allianceActivity.ArborDayEntranceIconView;
   import com.qzone.allianceActivity.ScoreTfMc;
   import com.qzone.allianceActivity.arborDayActivity.control.GetPresentInfoCommand;
   import com.qzone.allianceActivity.arborDayActivity.control.LoadCurrentScoreCommand;
   import com.qzone.allianceActivity.arborDayActivity.model.ArborDayConsts;
   import com.qzone.allianceActivity.arborDayActivity.model.ArborDayDataModel;
   import com.qzone.allianceActivity.arbordayEntranceTips;
   import com.qzone.allianceActivity.framewrok.MVCFacade;
   import com.qzone.allianceActivity.framewrok.command.CompositeCommand;
   import com.qzone.allianceActivity.framewrok.events.MVCEvent;
   import com.qzone.allianceActivity.framewrok.manager.LocalDataManager;
   import com.qzone.allianceActivity.framewrok.utils.TextFieldUtil;
   import com.qzone.allianceActivity.interfaces.arborDay.IArborDayActivityAppHelper;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import flash.utils.setTimeout;
   
   public class ArborDayActivityEntranceIcon extends Sprite
   {
      
      public var mediator:ArborDayMediator = MVCFacade.getInstance().getObj(ArborDayConsts.ARBORDAY_MEDIATOR);
      
      public var dataModel:ArborDayDataModel = MVCFacade.getInstance().getObj(ArborDayConsts.ARBORDAY_MODEL);
      
      public var appHelper:IArborDayActivityAppHelper = MVCFacade.getInstance().getObj(ArborDayConsts.ARBORDAY_APPHELPER);
      
      private var _tips:arbordayEntranceTips;
      
      private var _view:MovieClip;
      
      private var _scoreTf:TextField;
      
      private var _currentScore:int = -1;
      
      private var _blinkEffect:BlinkEffect;
      
      private var _blinkEffectFlagId:String = "arborDayActivity.blinkEffectFlag";
      
      private var _initialized:Boolean = false;
      
      public function ArborDayActivityEntranceIcon()
      {
         super();
         this._view = new ArborDayEntranceIconView();
         if(this._view)
         {
            this._view.buttonMode = true;
            this._view.stop();
            this._scoreTf = this._view.tfMc.scoreTf;
            this._scoreTf.mouseEnabled = false;
            this._view.addEventListener(Event.ADDED_TO_STAGE,this.addToStageHandler);
            this._view.addEventListener(Event.REMOVED_FROM_STAGE,this.removeFromStageHandler);
            addChild(this._view);
         }
      }
      
      public function set currentScore(param1:int) : void
      {
         var _loc2_:int = 0;
         if(this._currentScore >= 0)
         {
            _loc2_ = param1 - this._currentScore;
            this.addScoreEffect(_loc2_);
         }
         this._currentScore = param1;
         TextFieldUtil.refreshText(this._scoreTf,String(param1));
      }
      
      private function addToStageHandler(param1:Event) : void
      {
         var _loc2_:MVCEvent = null;
         var _loc3_:CompositeCommand = null;
         this._view.addEventListener(MouseEvent.CLICK,this.clickHandler);
         this._view.addEventListener(MouseEvent.MOUSE_OVER,this.mouseOverHandler);
         this._view.addEventListener(MouseEvent.MOUSE_OUT,this.mouseOutHandler);
         this.dataModel.addBinding("currentScore",this,"currentScore");
         if(!this._initialized)
         {
            _loc2_ = new MVCEvent("init");
            _loc3_ = new CompositeCommand();
            _loc3_.addSubCommand(new LoadCurrentScoreCommand());
            _loc3_.addSubCommand(new GetPresentInfoCommand());
            _loc3_.exec(_loc2_);
            this._initialized = true;
         }
         this.addBlinkEffect();
         if(this.dataModel.appId == ArborDayConsts.CT_APPID)
         {
            this.showTips();
         }
      }
      
      private function removeFromStageHandler(param1:Event) : void
      {
         this._view.removeEventListener(MouseEvent.CLICK,this.clickHandler);
         this._view.removeEventListener(MouseEvent.MOUSE_OVER,this.mouseOverHandler);
         this._view.removeEventListener(MouseEvent.MOUSE_OUT,this.mouseOutHandler);
         this.dataModel.removeBindedTarget(this);
         this.removeBlinkEffect();
      }
      
      private function mouseOverHandler(param1:Event) : void
      {
         this._view.gotoAndStop(2);
         this.appHelper.entranceIconShowTips(this,this.dataModel.activityConfig.iconTips);
      }
      
      private function mouseOutHandler(param1:Event) : void
      {
         this._view.gotoAndStop(1);
         this.appHelper.entranceIconHideTips(this);
      }
      
      private function clickHandler(param1:Event) : void
      {
         this.mediator.showActivityWin();
         this.removeBlinkEffect();
         this.hideTips();
         LocalDataManager.getInstance().save(this,this._blinkEffectFlagId,true);
         this.dataModel.reportClick(ArborDayConsts.ENTRANCE_ICON);
      }
      
      public function showTips() : void
      {
         if(!this._tips)
         {
            this._tips = new arbordayEntranceTips();
         }
         this._tips.x = this._view.x + this._view.width - 10;
         this._tips.y = this._view.y + this._view.height / 2;
         addChild(this._tips);
         setTimeout(this.hideTips,5000);
      }
      
      public function hideTips() : void
      {
         if(Boolean(this._tips) && Boolean(this._tips.parent))
         {
            this._tips.parent.removeChild(this._tips);
         }
         this._tips = null;
      }
      
      private function addScoreEffect(param1:int) : void
      {
         var _loc2_:ScoreTfMc = new ScoreTfMc();
         var _loc3_:String = param1 < 0 ? "-" + Math.abs(param1) : "+" + String(param1);
         TextFieldUtil.refreshText(_loc2_.scoreTf,_loc3_);
         _loc2_.x = 50;
         _loc2_.y = 40;
         addChild(_loc2_);
         var _loc4_:TweenLite = TweenLite.to(_loc2_,1,{
            "y":0,
            "alpha":0,
            "onComplete":this.addScoreEffectComplete,
            "onCompleteParams":[_loc2_]
         });
      }
      
      private function addScoreEffectComplete(param1:DisplayObject) : void
      {
         if(param1)
         {
            if(param1.parent)
            {
               param1.parent.removeChild(param1);
            }
            TweenLite.killTweensOf(param1);
         }
      }
      
      private function addBlinkEffect() : void
      {
         if(!this._blinkEffect)
         {
            this._blinkEffect = new BlinkEffect();
            this._blinkEffect.loop = 10000;
         }
         if(LocalDataManager.getInstance().loadToday(this,this._blinkEffectFlagId))
         {
            if(this._blinkEffect)
            {
               this._blinkEffect.kill();
            }
         }
         else
         {
            this._blinkEffect.apply(this._view);
         }
      }
      
      private function removeBlinkEffect() : void
      {
         if(this._blinkEffect)
         {
            this._blinkEffect.kill();
         }
         this._blinkEffect = null;
         this.hideTips();
      }
      
      public function get view() : MovieClip
      {
         return this._view;
      }
   }
}

