package mc.view.main
{
   import common.MaterialLib;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormat;
   import mc.control.Command;
   import mc.control.ViewControl;
   import mc.events.WindowEvent;
   import mc.model.TaskData;
   import mc.view.common.MaterialProxy;
   import mc.view.main.WindowControl.WControl;
   import mc.view.main.task.Task;
   import mc.view.main.tip.TipControl;
   
   public class TaskLayer extends Sprite
   {
      
      public static const TASK_REQUEST:String = "taskRequest";
      
      private var _newTask:MovieClip = null;
      
      private var task:Task = null;
      
      private var _tasking:Sprite = null;
      
      public function TaskLayer()
      {
         super();
         this.buttonMode = true;
         this.addEventListener(Event.ADDED_TO_STAGE,this.initPosition);
         TaskData.getInstance().addEventListener(TaskData.TASKDATA_CHANGE,this.currentTaskDataChange);
         TaskData.getInstance().addEventListener(TaskData.COMPLETE,this.currentTaskDataComplete);
      }
      
      private function rollOver2(param1:MouseEvent) : void
      {
         TipControl.show("MouseTip","查看当前任务");
      }
      
      private function coseTaskWindow() : void
      {
         this.task.closeWindow(null);
      }
      
      private function allTaskCompleted() : void
      {
         this.coseTaskWindow();
         WControl.openForName("AlertWindow",{
            "type":"success",
            "text":"恭喜您，您已经完成了全部的新手任务！"
         });
      }
      
      private function currentTaskDataChange(param1:Event) : void
      {
         if(TaskData.getInstance().currentTask.taskId > TaskData.TASK_MAX || TaskData.getInstance().currentTask.taskId == 0)
         {
            this.hidTaskButton();
         }
         else
         {
            this.initControlButton(TaskData.getInstance().currentTask.taskFlag);
         }
      }
      
      private function rollOut2(param1:MouseEvent) : void
      {
         TipControl.hide();
      }
      
      public function activeTask() : void
      {
         this.task = new Task();
         this.task.operationAction = this.coseTaskWindow;
         this.task.operationButtonLabel = "确定";
         this.task.addCancelButton = false;
         var _loc1_:TextField = new TextField();
         _loc1_.text = "(进行中)";
         _loc1_.selectable = false;
         _loc1_.mouseEnabled = false;
         _loc1_.width = 150;
         _loc1_.height = 25;
         _loc1_.setTextFormat(new TextFormat("Verdana",14,13369344,true));
         var _loc2_:Sprite = null;
         _loc2_ = MaterialLib.getInstance().getMaterial("task" + TaskData.getInstance().currentTask.taskId) as Sprite;
         if(_loc2_ != null)
         {
            _loc2_.y = 50;
            _loc2_.x = 20;
            this.task.taskAddChild(_loc2_);
            _loc2_.addChild(_loc1_);
            _loc1_.x = _loc2_.getChildAt(0).x + _loc2_.getChildAt(0).width;
            _loc1_.y = -4;
         }
         var _loc3_:WindowEvent = new WindowEvent(WindowEvent.OPEN);
         _loc3_.window = this.task;
         ViewControl.getInstance().dispatchEvent(_loc3_);
      }
      
      private function showWindow(param1:Event = null) : void
      {
         var _loc2_:TaskData = TaskData.getInstance();
         if(_loc2_.currentTask.taskFlag == 0)
         {
            this.acceptNewTask();
         }
         else if(_loc2_.currentTask.taskFlag == 1)
         {
            this.activeTask();
         }
         else if(TaskData.getInstance().currentTask.taskFlag == 0)
         {
         }
      }
      
      private function currentTaskDataComplete(param1:Event) : void
      {
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         var _loc10_:MaterialProxy = null;
         var _loc11_:TextFormat = null;
         var _loc12_:TextField = null;
         this.initControlButton(0);
         this.task = new Task();
         var _loc2_:Object = TaskData.getInstance().updata;
         if(TaskData.getInstance().updata["task"]["taskId"] <= TaskData.TASK_MAX)
         {
            if(_loc2_["task"]["taskId"] == 1)
            {
               this.task.operationButtonLabel = "开始做任务！";
               _loc2_["task"]["taskDesc"] = "完成新手帮助，赠送50经验和3000金币，可以开始做任务了！";
            }
            else
            {
               this.task.operationButtonLabel = "进行下一个任务";
            }
            this.task.operationButtonWidth = 120;
            this.task.operationAction = this.nextTask;
         }
         else
         {
            this.task.operationButtonLabel = "确定";
            this.task.operationAction = this.allTaskCompleted;
         }
         var _loc3_:TextField = new TextField();
         _loc3_.selectable = false;
         _loc3_.text = _loc2_["task"]["taskDesc"] || "";
         _loc3_.x = 22;
         _loc3_.y = 50;
         _loc3_.width = 315;
         _loc3_.height = 40;
         _loc3_.wordWrap = true;
         _loc3_.setTextFormat(new TextFormat("Verdana",12,8999699,true));
         this.task.taskAddChild(_loc3_);
         var _loc4_:int = int(_loc2_.item.length);
         if(_loc4_ > 0)
         {
            _loc6_ = 50;
            _loc7_ = 50;
            _loc8_ = (this.task.width - (_loc6_ * _loc4_ + _loc7_ * (_loc4_ - 1))) * 0.5;
            _loc9_ = 0;
            while(_loc9_ < _loc4_)
            {
               _loc10_ = new MaterialProxy();
               _loc10_.setContent(_loc2_.item[_loc9_]["type"] + "_" + _loc2_.item[_loc9_]["type"],_loc2_.item[_loc9_]["num"]);
               _loc10_.x = _loc8_;
               _loc10_.y = 100;
               _loc10_.scaleX = _loc6_ / _loc10_.width;
               _loc10_.scaleY = _loc6_ / _loc10_.width;
               this.task.taskAddChild(_loc10_);
               _loc11_ = new TextFormat();
               _loc12_ = new TextField();
               _loc12_.selectable = false;
               _loc12_.x = _loc8_ - _loc7_ * 0.5 + 5;
               _loc12_.y = _loc10_.y + 60;
               _loc12_.width = _loc6_ + _loc7_;
               _loc12_.height = 20;
               _loc12_.autoSize = TextFieldAutoSize.CENTER;
               _loc12_.textColor = 8999699;
               if(_loc2_.item[_loc9_]["type"] == 7)
               {
                  _loc12_.text = "经验+" + _loc2_.item[_loc9_]["num"];
               }
               if(_loc2_.item[_loc9_]["type"] == 6)
               {
                  _loc12_.text = "金币+" + _loc2_.item[_loc9_]["num"];
               }
               _loc12_.setTextFormat(new TextFormat("Verdana",14,8999699,true));
               this.task.taskAddChild(_loc12_);
               _loc8_ = _loc8_ + _loc6_ + _loc7_;
               _loc9_++;
            }
         }
         Command.getInstance().mainCommand.addExp(_loc2_);
         Command.getInstance().mainCommand.addMoney(_loc2_);
         var _loc5_:WindowEvent = new WindowEvent(WindowEvent.OPEN);
         _loc5_.window = this.task;
         ViewControl.getInstance().dispatchEvent(_loc5_);
      }
      
      private function rollOver(param1:MouseEvent) : void
      {
         TipControl.show("MouseTip","查看当前任务");
      }
      
      private function actionAccept() : void
      {
         this.coseTaskWindow();
         ViewControl.getInstance().dispatchEvent(new Event(TaskLayer.TASK_REQUEST));
         Command.getInstance().taskCommand.run();
      }
      
      private function rollOut(param1:MouseEvent) : void
      {
         TipControl.hide();
      }
      
      private function initPosition(param1:Event) : void
      {
         this.x = stage.stageWidth - 80;
         this.y = stage.stageHeight - 70;
         if(TaskData.getInstance().currentTask != null && TaskData.getInstance().currentTask.taskFlag != 0 && TaskData.getInstance().currentTask.taskId != 0)
         {
            this.initControlButton(TaskData.getInstance().currentTask.taskFlag);
         }
      }
      
      private function hidTaskButton() : void
      {
         if(this._newTask != null)
         {
            removeChild(this._newTask);
            this._newTask = null;
         }
         if(this._tasking != null)
         {
            removeChild(this._tasking);
            this._tasking = null;
         }
      }
      
      private function nextTask() : void
      {
         this.coseTaskWindow();
         this.showWindow(null);
      }
      
      public function acceptNewTask() : void
      {
         this.task = new Task();
         this.task.operationAction = this.actionAccept;
         var _loc1_:Sprite = null;
         _loc1_ = MaterialLib.getInstance().getMaterial("task" + TaskData.getInstance().currentTask.taskId) as Sprite;
         if(_loc1_ != null)
         {
            _loc1_.y = 50;
            _loc1_.x = 25;
            this.task.taskAddChild(_loc1_);
         }
         var _loc2_:WindowEvent = new WindowEvent(WindowEvent.OPEN);
         _loc2_.window = this.task;
         ViewControl.getInstance().dispatchEvent(_loc2_);
      }
      
      public function initControlButton(param1:int) : void
      {
         this.hidTaskButton();
         if(param1 == 0)
         {
            this._newTask = MaterialLib.getInstance().getMaterial("taskAwokeButton") as MovieClip;
            this._newTask.name = "newTask";
            this._newTask.addEventListener(MouseEvent.CLICK,this.showWindow);
            this._newTask.addEventListener(MouseEvent.ROLL_OVER,this.rollOver);
            this._newTask.addEventListener(MouseEvent.ROLL_OUT,this.rollOut);
            addChild(this._newTask);
         }
         if(param1 == 1)
         {
            this._tasking = MaterialLib.getInstance().getMaterial("taskingButton") as Sprite;
            this._tasking.name = "Tasking";
            this._tasking.addEventListener(MouseEvent.CLICK,this.showWindow);
            this._tasking.addEventListener(MouseEvent.ROLL_OVER,this.rollOver2);
            this._tasking.addEventListener(MouseEvent.ROLL_OUT,this.rollOut2);
            addChild(this._tasking);
         }
      }
   }
}

