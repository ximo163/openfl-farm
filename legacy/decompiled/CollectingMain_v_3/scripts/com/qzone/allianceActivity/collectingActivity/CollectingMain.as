package com.qzone.allianceActivity.collectingActivity
{
   import com.qzone.allianceActivity.AbstractAllianceActivityContext;
   import com.qzone.allianceActivity.AllianceActivityInfo;
   import com.qzone.allianceActivity.collectingActivity.control.FriendListInit;
   import com.qzone.allianceActivity.collectingActivity.control.PullFriendCollection;
   import com.qzone.allianceActivity.collectingActivity.control.PullHistoryCommand;
   import com.qzone.allianceActivity.collectingActivity.model.CollectingConsts;
   import com.qzone.allianceActivity.collectingActivity.model.CollectingModel;
   import com.qzone.allianceActivity.collectingActivity.service.CollectingService;
   import com.qzone.allianceActivity.collectingActivity.view.Mediator;
   import com.qzone.allianceActivity.collectingActivity.view.SerialsCache;
   import com.qzone.allianceActivity.framewrok.MVCFacade;
   import com.qzone.allianceActivity.framewrok.controller.CommandController;
   import com.qzone.allianceActivity.framewrok.manager.ClickReportManager;
   import com.qzone.allianceActivity.interfaces.IAllianceAppHelper;
   import flash.system.Security;
   import flash.utils.Dictionary;
   
   [SWF(width="500", height="375", backgroundColor="#869ca7", frameRate="24")]
   public class CollectingMain extends AbstractAllianceActivityContext
   {
      
      public function CollectingMain()
      {
         super();
         Security.allowDomain("*.appimg.qq.com");
         Security.allowDomain("*.appimg1.qq.com");
         Security.allowDomain("*.appimg2.qq.com");
         Security.allowDomain("*.appimg3.qq.com");
         Security.allowDomain("appimg.qq.com");
         Security.allowDomain("appimg1.qq.com");
         Security.allowDomain("appimg2.qq.com");
         Security.allowDomain("appimg3.qq.com");
      }
      
      override public function initialize(param1:AllianceActivityInfo) : void
      {
         var _loc2_:CollectingModel = new CollectingModel();
         _loc2_.activityConfig = param1;
         _loc2_.appId = super.appId;
         MVCFacade.getInstance().regObj(CollectingConsts.MODEL,_loc2_);
         MVCFacade.getInstance().regObj(CollectingConsts.MEDIATOR,Mediator);
         var _loc3_:CommandController = MVCFacade.getInstance().commandController;
         _loc3_.registerCommand(CollectingConsts.CMD_PULL_HISTORY,PullHistoryCommand);
         _loc3_.registerCommand(CollectingConsts.CMD_PULL_FRIEND_COLLECT,FriendListInit);
         _loc3_.registerCommand(CollectingConsts.CMD_PULL_FRIEND_LIST,PullFriendCollection);
      }
      
      override public function execute(param1:String, param2:Object = null) : Object
      {
         var _loc5_:String = null;
         var _loc6_:int = 0;
         var _loc7_:Dictionary = null;
         var _loc3_:Mediator = MVCFacade.getInstance().getObj(CollectingConsts.MEDIATOR) as Mediator;
         var _loc4_:CollectingModel = MVCFacade.getInstance().getObj(CollectingConsts.MODEL) as CollectingModel;
         switch(param1)
         {
            case "getEnterIcon":
               return null;
            case "openActivityWin":
               _loc3_.openMainWindow(0);
               if(_loc4_.appId == "353")
               {
                  ClickReportManager.reportClick("TJ.NC.ENTRANCE_CLICK");
               }
               else
               {
                  ClickReportManager.reportClick("TJ.MC.ENTRANCE_CLICK");
               }
               break;
            case "10000":
               return _loc3_.mainWnd;
            case "10001":
               if(param2 == null)
               {
                  break;
               }
               _loc5_ = _loc4_.serialUrl;
               if(_loc5_ == null || _loc5_ == "")
               {
                  break;
               }
               SerialsCache.getInstance().loadRes(_loc5_);
               return SerialsCache.getInstance().getSerialIconFromCache(param2 as int);
               break;
            case "10002":
               _loc3_.openMainWindow(param2 as int);
               if(_loc4_.appId == "353")
               {
                  ClickReportManager.reportClick("TJ.NC.FRIENDLIST_CLICK");
               }
               else
               {
                  ClickReportManager.reportClick("TJ.MC.FRIENDLIST_CLICK");
               }
               break;
            case "10003":
               if(param2 == null)
               {
                  return "";
               }
               _loc6_ = param2 as int;
               if(_loc6_ == 0)
               {
                  return "";
               }
               _loc7_ = _loc4_.serialsData;
               if(_loc7_ != null && _loc7_[_loc6_] != undefined)
               {
                  return _loc7_[_loc6_]["name"];
               }
               return "";
         }
         return null;
      }
      
      override public function set appHelper(param1:IAllianceAppHelper) : void
      {
         super.appHelper = param1;
         MVCFacade.getInstance().regObj(CollectingConsts.APPHELPER,param1);
         var _loc2_:String = param1.execute("10001",null) as String;
         MVCFacade.getInstance().serviceLocator.addTextService(CollectingConsts.SERVICE,new CollectingService(_loc2_));
         var _loc3_:CollectingModel = MVCFacade.getInstance().getObj(CollectingConsts.MODEL) as CollectingModel;
         _loc3_.initialize(super.appHelper.execute("10005") as Dictionary);
      }
   }
}

