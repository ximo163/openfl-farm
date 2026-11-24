package plugins.external.mailPromotion
{
   import com.qzone.farm.api.interfaces.IFarmAPI;
   import com.qzone.farm.api.interfaces.IPlugin;
   import common.Session;
   import flash.display.Sprite;
   import report.ClickReportManager;
   
   [SWF(width="500", height="375", backgroundColor="#869ca7", frameRate="24")]
   public class MailPromotionPlugin extends Sprite implements IPlugin
   {
      
      public static var APP_ID:String = "353";
      
      public static var GIFTBAG_ID:int = 305;
      
      private var _receiveSuccessView:ReceiveSuccessView;
      
      private var _receivedView:ReceivedView;
      
      private var _api:IFarmAPI;
      
      private var _getGiftView:GetGiftView;
      
      private var _id:int;
      
      private var _userStatus:int = 1;
      
      public function MailPromotionPlugin()
      {
         super();
      }
      
      private function onGetGiftBag(param1:Object) : void
      {
      }
      
      private function showGiftBag() : void
      {
         if(!this._getGiftView)
         {
            this._getGiftView = new GetGiftView(this._api.messageCenter,this);
         }
         this._api.showPopUp(this._getGiftView,true);
         ClickReportManager.reportClick("share.mailBackflow.present_window_show_nc");
      }
      
      public function showGiftBagHaveGot() : void
      {
         if(!this._receivedView)
         {
            this._receivedView = new ReceivedView(this._api.messageCenter);
         }
         this._api.showPopUp(this._receivedView,true);
      }
      
      public function showReceiveSuccess() : void
      {
         if(!this._receiveSuccessView)
         {
            this._receiveSuccessView = new ReceiveSuccessView(this._api.messageCenter);
         }
         this._api.showPopUp(this._receiveSuccessView,true);
      }
      
      public function executeCommand(param1:int, param2:Object) : Object
      {
         return null;
      }
      
      public function get api() : IFarmAPI
      {
         return this._api;
      }
      
      public function get id() : int
      {
         return this._id;
      }
      
      public function load(param1:int, param2:IFarmAPI) : Boolean
      {
         this._id = param1;
         this._api = param2;
         return true;
      }
      
      public function createMainUI(param1:Object) : Sprite
      {
         if(Session.getInstance().isFromMail)
         {
            this.showGiftBag();
         }
         return null;
      }
      
      public function set api(param1:IFarmAPI) : void
      {
         this._api = param1;
      }
      
      public function set id(param1:int) : void
      {
         this._id = param1;
      }
      
      public function unload() : void
      {
      }
   }
}

