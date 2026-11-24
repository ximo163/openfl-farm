package com.qzone.allianceActivity.collectingActivity.view
{
   import com.qzone.allianceActivity.collectingActivity.model.CollectingConsts;
   import com.qzone.allianceActivity.collectingActivity.model.CollectingModel;
   import com.qzone.allianceActivity.collectingActivity.model.FriendData;
   import com.qzone.allianceActivity.framewrok.MVCFacade;
   import com.qzone.allianceActivity.framewrok.controller.CommandController;
   import com.qzone.allianceActivity.framewrok.events.MVCEvent;
   import com.qzone.allianceActivity.interfaces.IAllianceAppHelper;
   import flash.display.MovieClip;
   import flash.utils.Dictionary;
   import flash.utils.setTimeout;
   
   public class Mediator
   {
      
      private var _mainWndUI:MovieClip;
      
      private var _forceOpen:Boolean;
      
      private var _api:IAllianceAppHelper;
      
      private var _buyWnd:BuyItemQDWindow;
      
      private var _shareWnd:ShareWindow;
      
      private var _mainWnd:MainWindow;
      
      private var _cc:CommandController;
      
      public function Mediator()
      {
         super();
         this._forceOpen = false;
         this._api = MVCFacade.getInstance().getObj(CollectingConsts.APPHELPER) as IAllianceAppHelper;
         this._cc = MVCFacade.getInstance().commandController as CommandController;
      }
      
      public function showSerialPage(param1:int) : void
      {
         if(this._mainWnd != null)
         {
            this._mainWnd.showSerialPage(param1);
         }
      }
      
      public function cancelWaiting() : void
      {
         if(this._mainWnd != null)
         {
            this._mainWnd.waiting(false);
         }
      }
      
      public function loadFriendsCollection() : Dictionary
      {
         var _loc1_:CollectingModel = MVCFacade.getInstance().getObj(CollectingConsts.MODEL) as CollectingModel;
         if(_loc1_.friendsCollection != null)
         {
            return _loc1_.friendsCollection as Dictionary;
         }
         var _loc2_:MVCEvent = new MVCEvent(CollectingConsts.CMD_PULL_FRIEND_COLLECT);
         this._cc.executeCommand(_loc2_);
         return null;
      }
      
      public function buySeed(param1:int, param2:int) : void
      {
         if(param1 == 0 || param2 <= 0)
         {
            return;
         }
         this._api.execute("10017",{
            "id":param1,
            "num":param2
         });
      }
      
      public function loadFriendCrops(param1:uint) : FriendData
      {
         var _loc4_:MVCEvent = null;
         var _loc2_:CollectingModel = MVCFacade.getInstance().getObj(CollectingConsts.MODEL) as CollectingModel;
         var _loc3_:FriendData = _loc2_.getFriendDataByUid(param1);
         if(_loc3_ == null)
         {
            return _loc3_;
         }
         if(_loc3_.updated == false)
         {
            _loc4_ = new MVCEvent(CollectingConsts.CMD_PULL_HISTORY);
            _loc4_.put("uId",param1);
            this._cc.executeCommand(_loc4_);
         }
         return _loc3_;
      }
      
      public function loadFriendList() : Boolean
      {
         var _loc2_:MVCEvent = null;
         var _loc1_:CollectingModel = MVCFacade.getInstance().getObj(CollectingConsts.MODEL) as CollectingModel;
         if(_loc1_.gotStatus == false)
         {
            _loc2_ = new MVCEvent(CollectingConsts.CMD_PULL_FRIEND_LIST);
            this._cc.executeCommand(_loc2_);
            if(this._mainWnd != null)
            {
               this._mainWnd.waiting(true);
            }
            return false;
         }
         return true;
      }
      
      public function fatalError(param1:String = "", param2:Boolean = false) : void
      {
         if(param1 == "")
         {
            param1 = "系统繁忙，请您稍后再试！";
         }
         this._api.alert(param1);
         if(param2 == true)
         {
            this._mainWnd.destroy();
         }
      }
      
      public function openBuyWindow(param1:int) : void
      {
         var _loc4_:Object = null;
         var _loc2_:CollectingModel = MVCFacade.getInstance().getObj(CollectingConsts.MODEL) as CollectingModel;
         var _loc3_:int = _loc2_.id2Serial(param1);
         if(_loc3_ == -1 || _loc3_ >= CollectingConsts.NORMAL_SERIAL_START)
         {
            this._api.execute("10008",param1);
         }
         else
         {
            if(this._buyWnd == null)
            {
               this._buyWnd = new BuyItemQDWindow(this._api);
            }
            _loc4_ = _loc2_.getCropConfig(param1);
            if(_loc4_ != null && _loc4_["qd"] != undefined && _loc4_["qd"] > 0)
            {
               this._buyWnd.show(param1,_loc4_["qd"],_loc4_["qd"] * 0.8);
            }
         }
      }
      
      public function get mainWnd() : MovieClip
      {
         return this._mainWndUI;
      }
      
      public function openMainWindow(param1:uint) : void
      {
         var friendID:uint = param1;
         var cmdEvent:MVCEvent = new MVCEvent(CollectingConsts.CMD_PULL_HISTORY);
         this._cc.executeCommand(cmdEvent);
         if(this._mainWnd == null)
         {
            this._mainWnd = new MainWindow(this._api);
         }
         this._mainWndUI = this._mainWnd.show();
         if(friendID != 0)
         {
            setTimeout(function():void
            {
               _mainWnd.showComparePage(friendID);
            },500);
         }
      }
      
      public function cancelPK() : void
      {
         if(this._mainWnd != null)
         {
            this._mainWnd.cancelPK();
         }
      }
   }
}

