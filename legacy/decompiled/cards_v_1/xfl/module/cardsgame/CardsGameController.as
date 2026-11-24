package module.cardsgame
{
   import common.CommonData;
   import common.Consts;
   import common.Session;
   import common.Settings;
   import entities.Player;
   import events.CommonEvent;
   import flash.utils.clearTimeout;
   import flash.utils.setTimeout;
   import framework.base.Controller;
   
   public class CardsGameController extends Controller
   {
      
      private static const E_SUCCEED:int = 1;
      
      private var _timer:int = -1;
      
      public function CardsGameController()
      {
         super(null);
         if(m_model == null)
         {
            m_model = new CardsGameModel();
         }
      }
      
      public function isCardGameActivity() : Boolean
      {
         var _loc1_:String = Settings.getInstance().getStringAttribute("cardActivityStart");
         var _loc2_:String = Settings.getInstance().getStringAttribute("cardActivityEnd");
         var _loc3_:Number = new Date(_loc1_).time;
         var _loc4_:Number = new Date(_loc2_).time;
         var _loc5_:Number = CommonData.serverTime * 1000;
         if(_loc3_ < _loc5_ && _loc5_ < _loc4_)
         {
            return true;
         }
         return false;
      }
      
      private function refreshCardsGameData(param1:CommonEvent) : void
      {
         this.module.app.removeEventListener(Consts.MSG_SHOW_CARDSGAMEWINDOW,this.refreshCardsGameData);
         this.model.addEventListener(CardsGameModel.CARDSGAME_REFRESHED,this.openCardsGameWindow);
         this.model.refreshCardsGameData();
      }
      
      public function get model() : CardsGameModel
      {
         return m_model as CardsGameModel;
      }
      
      private function onDataInitialized(param1:CommonEvent) : void
      {
         if(param1 != null && param1.data != null)
         {
            module.app.dispatchEvent(new CommonEvent(Consts.MSG_REFRESH_CARDSGAME,param1.data));
         }
      }
      
      override public function initialze() : void
      {
         if(super.module != null)
         {
            super.module.app.addEventListener(Consts.MSG_SHOW_CARDSGAMEWINDOW,this.refreshCardsGameData);
         }
         m_model.addEventListener(CardsGameModel.GET_CARDSGAME_DATA,this.onDataInitialized,false,0,true);
         m_model.cardsGameQuery();
      }
      
      private function openCardsGameWindow2(param1:CommonEvent) : void
      {
         var _loc4_:CardsGameWindow = null;
         var _loc5_:String = null;
         var _loc6_:String = null;
         var _loc7_:String = null;
         var _loc8_:String = null;
         var _loc9_:Object = null;
         var _loc10_:Object = null;
         if(this.model.remainPlays > 0)
         {
            _loc4_ = new CardsGameWindow(this);
            this.module.app.farmView.winCtrl.open(_loc4_);
         }
         var _loc2_:Object = param1.data;
         var _loc3_:int = int(_loc2_["code"]);
         if(_loc3_ == E_SUCCEED)
         {
            this.model.cardGameBonus = 0;
            _loc5_ = _loc2_["id"];
            _loc6_ = Settings.getInstance().getCardsGameReward(_loc5_)["name"];
            _loc7_ = Settings.getInstance().getCardsGameReward(_loc5_)["num"];
            _loc8_ = "您已连续登录" + this.model.loginDays + "天，农场村委会特向您赠送" + _loc6_ + _loc7_ + "个，以资鼓励!";
            _loc9_ = Settings.getInstance().getCardsGameReward(_loc5_);
            _loc10_ = {
               "item":[{
                  "eType":_loc9_["type"],
                  "eNum":_loc9_["num"],
                  "eParam":_loc9_["cId"]
               }],
               "title":"温馨提示",
               "direction":_loc8_,
               "cardsGameGift":true,
               "giftID":_loc5_,
               "confirmHandler":this.removeIcon
            };
            this.module.app.openWindowByName(Consts.WINDOW_NAME_GIFT,_loc10_);
         }
      }
      
      private function openCardsGameWindow(param1:CommonEvent) : void
      {
         var _loc4_:Player = null;
         var _loc5_:CardsGameWindow = null;
         var _loc2_:Object = param1.data;
         var _loc3_:int = int(_loc2_["code"]);
         if(_loc3_ == E_SUCCEED)
         {
            this.model.loginDays = _loc2_["days"];
            this.model.isGetDraw = [_loc2_["draw1"],_loc2_["draw2"],_loc2_["draw3"]];
            _loc4_ = Session.getInstance().host;
            if(_loc4_._yellowstatus != 0)
            {
               this.model.remainPlays = 2 - int(_loc2_["number"]);
            }
            else
            {
               this.model.remainPlays = 1 - int(_loc2_["number"]);
            }
            if(int(_loc2_["bonus"]) > 0)
            {
               this.model.addEventListener(CardsGameModel.CARDSGAME_BONUS,this.openCardsGameWindow2);
               this.model.getBonusGift();
               this._timer = setTimeout(this.iconAddListener,500);
               return;
            }
            this.model.cardGameBonus = 0;
            if(this.model.remainPlays > 0)
            {
               _loc5_ = new CardsGameWindow(this);
               this.module.app.farmView.winCtrl.open(_loc5_);
               this._timer = setTimeout(this.iconAddListener,500);
            }
            else
            {
               this.removeIcon();
            }
         }
         else
         {
            this._timer = setTimeout(this.iconAddListener,500);
         }
      }
      
      private function iconAddListener() : void
      {
         if(this._timer != -1)
         {
            clearTimeout(this._timer);
         }
         this.module.app.addEventListener(Consts.MSG_SHOW_CARDSGAMEWINDOW,this.refreshCardsGameData);
      }
      
      public function removeIcon() : void
      {
         if(this.model.remainPlays <= 0)
         {
            this.module.app.dispatchEvent(new CommonEvent(Consts.MSG_REFRESH_CARDSGAME,false));
         }
      }
      
      override public function finalize() : void
      {
         m_model = null;
         super.finalize();
      }
   }
}

