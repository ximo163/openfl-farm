package com.qzone.allianceActivity.arborDayActivity.view
{
   import com.qzone.allianceActivity.arborDayActivity.control.LoadAssetCommand;
   import com.qzone.allianceActivity.arborDayActivity.control.ShowWinCommand;
   import com.qzone.allianceActivity.arborDayActivity.model.ArborDayConsts;
   import com.qzone.allianceActivity.arborDayActivity.model.ArborDayDataModel;
   import com.qzone.allianceActivity.framewrok.MVCFacade;
   import com.qzone.allianceActivity.framewrok.command.CompositeCommand;
   import com.qzone.allianceActivity.framewrok.command.ICommand;
   import com.qzone.allianceActivity.framewrok.events.MVCEvent;
   import com.qzone.allianceActivity.framewrok.utils.ClassUtils;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.events.EventDispatcher;
   import flash.net.URLRequest;
   import flash.net.navigateToURL;
   import flash.utils.Dictionary;
   
   public class ArborDayMediator extends EventDispatcher
   {
      
      public var dataModel:ArborDayDataModel = MVCFacade.getInstance().getObj(ArborDayConsts.ARBORDAY_MODEL);
      
      private var _winCache:Dictionary = new Dictionary();
      
      private var _entranceIcon:ArborDayActivityEntranceIcon;
      
      public function ArborDayMediator()
      {
         super(null);
      }
      
      public function addEntranceIconTo(param1:DisplayObjectContainer, param2:Number = 0, param3:Number = 0, param4:int = -1) : DisplayObject
      {
         if(!this._entranceIcon)
         {
            this._entranceIcon = new ArborDayActivityEntranceIcon();
         }
         if(Boolean(param1) && Boolean(this._entranceIcon))
         {
            if(param4 >= 0)
            {
               param1.addChildAt(this._entranceIcon,param4);
            }
            else
            {
               param1.addChild(this._entranceIcon);
            }
            this._entranceIcon.x = param2;
            this._entranceIcon.y = param3;
         }
         return this._entranceIcon;
      }
      
      public function showActivityWin() : void
      {
         this.showWin(ArborDayActivityWin);
      }
      
      public function showDetailWin() : void
      {
         this.showWin(ArborDayActivityDetailWin);
      }
      
      public function showFinalPresentWin() : void
      {
         this.showWin(ArborDayActivityFinalPresentWin);
      }
      
      public function showRecordWin() : void
      {
         this.showWin(ArborDayActivityRecordWin);
      }
      
      public function showScoreNotEnoughtWin() : void
      {
         this.showWin(ScoreNotEnoughtAlertWin);
      }
      
      public function navigateToDetailLink() : void
      {
         var _loc1_:URLRequest = new URLRequest(this.dataModel.activityConfig.detailLinkUrl);
         navigateToURL(_loc1_,"_blank");
      }
      
      public function addWinToCache(param1:DisplayObject) : void
      {
         var _loc2_:String = ClassUtils.getInstanceClassName(param1);
         this._winCache[_loc2_] = param1;
      }
      
      public function removeWinCache(param1:DisplayObject) : void
      {
         var _loc2_:String = ClassUtils.getInstanceClassName(param1);
         if(this._winCache[_loc2_])
         {
            this._winCache[_loc2_] = null;
            delete this._winCache[_loc2_];
         }
      }
      
      public function getCacheWin(param1:String) : DisplayObject
      {
         return this._winCache[param1];
      }
      
      private function showWin(param1:Class) : void
      {
         var _loc2_:String = null;
         var _loc3_:MVCEvent = null;
         var _loc4_:ICommand = null;
         if(param1 == ArborDayActivityWin)
         {
            _loc2_ = this.dataModel.activityConfig.getAssetUrl(ArborDayConsts.VIEW_ASSET_ID1);
         }
         else
         {
            _loc2_ = this.dataModel.activityConfig.getAssetUrl(ArborDayConsts.VIEW_ASSET_ID2);
         }
         if(this.dataModel.isAssetReady(_loc2_))
         {
            _loc3_ = new MVCEvent(ArborDayConsts.SHOW_WIN_CMD);
            _loc3_.put("viewClz",param1);
            _loc4_ = new ShowWinCommand();
         }
         else
         {
            _loc3_ = new MVCEvent("loadAndShow");
            _loc3_.put("viewClz",param1);
            _loc3_.put("url",_loc2_);
            _loc4_ = new CompositeCommand();
            CompositeCommand(_loc4_).addSubCommand(new LoadAssetCommand());
            CompositeCommand(_loc4_).addSubCommand(new ShowWinCommand());
         }
         _loc4_.exec(_loc3_);
      }
      
      public function closeWin(param1:DisplayObject, param2:Boolean = true) : void
      {
         var _loc3_:MVCEvent = null;
         _loc3_ = new MVCEvent(ArborDayConsts.REMOVE_WIN_CMD);
         _loc3_.put("win",param1);
         _loc3_.put("destory",param2);
         MVCFacade.getInstance().commandController.executeCommand(_loc3_);
      }
   }
}

