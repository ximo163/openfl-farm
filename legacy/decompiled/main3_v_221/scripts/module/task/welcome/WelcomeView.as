package module.task.welcome
{
   import com.qzone.qfa.events.CommandEvent;
   import common.CommonData;
   import common.Consts;
   import common.Language;
   import common.Session;
   import common.Settings;
   import common.misc.Utils;
   import events.CommonEvent;
   import flash.display.DisplayObject;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.MouseEvent;
   import flash.net.URLRequest;
   import framework.net.CommandDefs;
   import framework.net.NetHelper;
   import module.messages.widgets.*;
   
   public class WelcomeView extends Sprite
   {
      
      private var _newTask:MovieClip;
      
      private var _helpLoader:Loader;
      
      private var _taskWin:WelcomeTaskWindow;
      
      private var _completeWin:TaskOverWindow;
      
      private var _controller:WelcomeController;
      
      private var _tasking:Sprite;
      
      public function WelcomeView(param1:WelcomeController)
      {
         super();
         this._helpLoader = null;
         this._newTask = null;
         this._tasking = null;
         this._taskWin = null;
         this._completeWin = null;
         this._controller = param1;
         param1.model.addEventListener(WelcomeModel.EVENT_TASK_CHANGED,this.onTaskChanged,false,0,true);
         param1.model.addEventListener(WelcomeModel.EVENT_TASK_COMPLETED,this.onTaskCompleted,false,0,true);
      }
      
      private function onWelcomeEnd(param1:CommandEvent) : void
      {
         trace("welcome guide is over.");
      }
      
      private function onGuideFinished(param1:Event) : void
      {
         param1.currentTarget.removeEventListener("closeEvent",this.onGuideFinished);
         this.controller.module.app.dispatchEvent(new Event(Consts.MSG_ACCEPT_NEW_GIFT));
         NetHelper.sendRequest(CommandDefs.CMD_WELCOME_END,null,this.onWelcomeEnd,null);
         this.controller.startNewTask();
         this.showWindow(null);
         if(this._helpLoader != null)
         {
            removeChildAt(0);
            removeChild(this._helpLoader);
            this._helpLoader = null;
         }
         if(this._newTask != null)
         {
            this._newTask.mouseEnabled = true;
            this._newTask.mouseChildren = true;
         }
         removeEventListener(MouseEvent.ROLL_OVER,this.onMouseRollOver);
      }
      
      private function showWindow(param1:Event) : void
      {
         var _loc2_:int = this._controller.model.taskID;
         var _loc3_:int = this._controller.model.taskFlag;
         if(_loc3_ == 2)
         {
            this.acceptNewTask(_loc2_);
         }
         else if(_loc3_ == 1)
         {
            this.activeTask(_loc2_);
         }
      }
      
      private function onBtnRollOver(param1:MouseEvent) : void
      {
         this.controller.showTip(Consts.TIP_NAME_MOUSE,Language.L["查看当前任务"]);
      }
      
      private function onTaskChanged(param1:CommonEvent) : void
      {
         if(param1 == null || param1.data == null)
         {
            return;
         }
         var _loc2_:* = param1.data;
         var _loc3_:int = _loc2_["taskFlag"] as int;
         if(_loc3_ == 0)
         {
            this.hidTaskButton();
         }
         else
         {
            this.checkTaskResource();
         }
      }
      
      private function onBtnRollOut(param1:MouseEvent) : void
      {
         this.controller.hideTip();
      }
      
      private function onNextTask() : void
      {
         this.showWindow(null);
      }
      
      public function showNewGuide() : void
      {
         var _loc2_:Sprite = null;
         var _loc1_:String = Settings.getInstance().getSecondUrl("help");
         if(_loc1_ == "")
         {
            return;
         }
         this._helpLoader = new Loader();
         this._helpLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,this.onLoadHelpError);
         this._helpLoader.contentLoaderInfo.addEventListener(Event.COMPLETE,this.onLoadHelpCompleted);
         this._helpLoader.load(new URLRequest(_loc1_));
         addChild(this._helpLoader);
         if(stage != null)
         {
            _loc2_ = new Sprite();
            _loc2_.graphics.beginFill(16777215,0.3);
            _loc2_.graphics.drawRect(0,0,stage.stageWidth,stage.stageHeight);
            _loc2_.graphics.endFill();
            addChildAt(_loc2_,0);
         }
         addEventListener(MouseEvent.ROLL_OVER,this.onMouseRollOver,false,0,true);
         this._controller.model.preSetTaskFlag();
         this.checkTaskResource();
      }
      
      private function checkTaskResource() : void
      {
         var _loc1_:String = Settings.getInstance().getSecondUrl("fresherTask");
         if(_loc1_ != "")
         {
            CommonData.rslManager.requestClass("taskAwokeButton",this.rslCallBack,_loc1_);
         }
      }
      
      public function get controller() : WelcomeController
      {
         return this._controller;
      }
      
      private function acceptNewTask(param1:int) : void
      {
         var _loc2_:int = 0;
         var _loc3_:Array = null;
         if(this._taskWin == null)
         {
            this._taskWin = new WelcomeTaskWindow(this.controller.module.app);
         }
         this.controller.module.app.farmView.winCtrl.open(this._taskWin);
         if(Session.getInstance().isNewGuideTask)
         {
            _loc3_ = this.controller.model.newIDToOldIDArray;
            _loc2_ = _loc3_.indexOf(_loc3_[param1] + 1);
         }
         else
         {
            _loc2_ = param1 + 1;
         }
         this._taskWin.data = {
            "mode":0,
            "title":Language.L["领取任务"],
            "id":_loc2_,
            "confirmFn":this.onAcceptTask
         };
      }
      
      private function createBookButton(param1:int) : void
      {
         this.hidTaskButton();
         if(param1 == 2)
         {
            if(this._newTask == null)
            {
               this._newTask = Utils.getMaterial("taskAwokeButton") as MovieClip;
               if(this._newTask == null)
               {
                  return;
               }
               this._newTask.width = 64;
               this._newTask.height = 49;
               this._newTask.buttonMode = true;
               this._newTask.x = 105;
               this._newTask.y = 500;
               this._newTask.addEventListener(MouseEvent.CLICK,this.showWindow);
               this._newTask.addEventListener(MouseEvent.ROLL_OVER,this.onBtnRollOver,false,0,true);
               this._newTask.addEventListener(MouseEvent.ROLL_OUT,this.onBtnRollOut,false,0,true);
            }
            addChild(this._newTask);
         }
         else if(param1 == 1)
         {
            if(this._tasking == null)
            {
               this._tasking = Utils.getMaterial("taskingButton") as Sprite;
               if(this._tasking == null)
               {
                  return;
               }
               this._tasking.buttonMode = true;
               this._tasking.width = 46;
               this._tasking.height = 36;
               this._tasking.x = 105;
               this._tasking.y = 506;
               this._tasking.addEventListener(MouseEvent.CLICK,this.showWindow);
               this._tasking.addEventListener(MouseEvent.ROLL_OVER,this.onBtnRollOver,false,0,true);
               this._tasking.addEventListener(MouseEvent.ROLL_OUT,this.onBtnRollOut,false,0,true);
            }
            addChild(this._tasking);
         }
      }
      
      private function rslCallBack() : void
      {
         this.createBookButton(this.controller.model.taskFlag);
         if(this._helpLoader != null && this._newTask != null)
         {
            this._newTask.mouseEnabled = false;
            this._newTask.mouseChildren = false;
         }
      }
      
      private function onLoadHelpError(param1:IOErrorEvent) : void
      {
         trace("加载新手帮助文件失败");
      }
      
      private function onLoadHelpCompleted(param1:Event) : void
      {
         var _loc2_:DisplayObject = param1.currentTarget.content;
         _loc2_.x = (stage.stageWidth - _loc2_.width) / 2;
         _loc2_.y = (stage.stageHeight - _loc2_.height) / 2;
         _loc2_.addEventListener("closeEvent",this.onGuideFinished);
      }
      
      private function onTaskCompleted(param1:CommonEvent) : void
      {
         if(param1 == null || param1.data == null)
         {
            return;
         }
         if(this._completeWin == null)
         {
            this._completeWin = new TaskOverWindow(this._controller.module.app);
         }
         var _loc2_:* = param1.data;
         var _loc3_:Boolean = false;
         if(_loc2_["task"] != undefined && _loc2_["task"]["taskId"] != 0)
         {
            this.createBookButton(2);
            _loc2_["confirmFn"] = this.onNextTask;
         }
         else
         {
            this.hidTaskButton();
            _loc2_["confirmFn"] = this.onTaskAllOver;
            _loc3_ = true;
         }
         this._controller.module.app.farmView.winCtrl.open(this._completeWin);
         this._completeWin.data = _loc2_;
         if(_loc3_)
         {
            this._completeWin.confirmBtnText = Language.L["确定"];
         }
         Session.getInstance().addReward(_loc2_["item"]);
         this._controller.module.app.dispatchEvent(new CommonEvent(Consts.MSG_LEVELUP,_loc2_));
      }
      
      private function activeTask(param1:int) : void
      {
         if(this._taskWin == null)
         {
            this._taskWin = new WelcomeTaskWindow(this.controller.module.app);
         }
         this.controller.module.app.farmView.winCtrl.open(this._taskWin);
         this._taskWin.data = {
            "mode":1,
            "title":Language.L["任 务"],
            "id":param1,
            "confirmFn":null
         };
      }
      
      private function onAcceptTask() : void
      {
         this.controller.model.acceptTask();
      }
      
      private function onMouseRollOver(param1:Event) : void
      {
         this.controller.useSystemCursor(true);
      }
      
      private function onTaskAllOver() : void
      {
         this.controller.openWindow(Consts.WINDOW_NAME_ALERT,{
            "type":Consts.ALERT_TYPE_SUCCESS,
            "text":Language.L["您已完成全部新手任务！"]
         });
      }
      
      private function hidTaskButton() : void
      {
         if(this._newTask != null && contains(this._newTask) == true)
         {
            removeChild(this._newTask);
         }
         if(this._tasking != null && contains(this._tasking) == true)
         {
            removeChild(this._tasking);
         }
      }
   }
}

