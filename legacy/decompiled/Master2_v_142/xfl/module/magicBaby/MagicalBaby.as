package module.magicBaby
{
   import cn.snowkit.containers.Pane;
   import com.qzone.qfa.managers.LoadManager;
   import com.qzone.qfa.managers.events.LoaderEvent;
   import common.MaterialLib;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.utils.setTimeout;
   import mc.FBridge.FRequest;
   import mc.view.NewIconTip.NewIconTipController;
   import mc.view.NewIconTip.NewIconTipLayer;
   import mc.view.main.tip.TipControl;
   
   public class MagicalBaby
   {
      
      private static var _magicalBaby:MagicalBaby;
      
      private var _tipTimer:int;
      
      private var _model:MagicalBabyData;
      
      private var _reserchUILoaded:int = -1;
      
      private var _reserchWinObj:Object;
      
      private var _babyIcon:Sprite;
      
      private var _uiLoaded:int = -1;
      
      private var _leftPane:Pane;
      
      public function MagicalBaby()
      {
         super();
         this._model = new MagicalBabyData();
      }
      
      public static function gi() : MagicalBaby
      {
         if(!_magicalBaby)
         {
            _magicalBaby = new MagicalBaby();
         }
         return _magicalBaby;
      }
      
      private function __onOver(param1:MouseEvent) : void
      {
         TipControl.show("MouseTip",this._model.getTip());
      }
      
      private function __onUILoaded(param1:LoaderEvent) : void
      {
         var _loc2_:Class = MaterialLib.getInstance().getClass("MagicalBaby.Icon");
         if(_loc2_ != null)
         {
            this._babyIcon = new _loc2_() as Sprite;
            this._leftPane.appendChild(this._babyIcon);
            this._babyIcon.addEventListener(MouseEvent.CLICK,this.__onIconClicked);
            this._babyIcon.addEventListener(MouseEvent.ROLL_OVER,this.__onOver);
            this._babyIcon.addEventListener(MouseEvent.ROLL_OUT,this.__onOut);
            this._babyIcon.buttonMode = true;
            this._tipTimer = setTimeout(this.showNewTip,2000);
            FRequest.getInstance().postRequest("cgi_fetch_strategy_rules",{"bitpos":26},this.onForceOpen);
         }
      }
      
      private function __onIconClicked(param1:MouseEvent = null) : void
      {
         new MagicalBabyWindow();
      }
      
      public function addToLeft(param1:Pane) : void
      {
         var _loc2_:String = null;
         var _loc3_:LoadManager = null;
         this._leftPane = param1;
         if(this._uiLoaded == -1)
         {
            this._uiLoaded = 0;
            _loc2_ = this._model.getUIUrl();
            _loc3_ = new LoadManager();
            _loc3_.add(_loc2_);
            _loc3_.addEventListener(LoaderEvent.QUEUE_COMPLETE,this.__onUILoaded);
            _loc3_.start();
         }
      }
      
      private function onForceOpen(param1:Object) : void
      {
         if(param1["bit_flag"] != null && param1["bit_flag"] == true)
         {
            this.__onIconClicked();
         }
      }
      
      private function showNewTip() : void
      {
         var _loc1_:Point = this._leftPane.localToGlobal(new Point(this._babyIcon.x + 26,this._babyIcon.y + 40));
         NewIconTipController.show(_loc1_,"神奇宝宝大抽奖",NewIconTipLayer.NEW_ACTIVITY_TIP);
      }
      
      private function __onOut(param1:MouseEvent) : void
      {
         TipControl.hide();
      }
   }
}

