package module.task.welcome;

import com.qzone.qfa.events.CommandEvent;
import common.CommonData;
import common.Consts;
import common.Language;
import common.Session;
import common.Settings;
import common.misc.Utils;
import events.CommonEvent;
import framework.net.CommandDefs;
import framework.net.NetHelper;
import openfl.display.DisplayObject;
import openfl.display.Loader;
import openfl.display.MovieClip;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.events.MouseEvent;
import openfl.net.URLRequest;
import shim.As3;
import shim.LocalSwfLoader;

/**
 * module.task.welcome.WelcomeView —— WelcomeView.as（338 loc）逐句对应
 * （issue #21）。任务模块视图：监听 model 的 TaskChanged/TaskCompleted——
 * 装载任务时按 flag 建「领任务/进行中」书页按钮（taskAwokeButton/
 * taskingButton 素材经 fresherTask RSL），完成时开 TaskOverWindow 领奖并
 * addReward；showNewGuide 播新手引导（help.swf 经 Loader 装入、白罩压底、
 * 引导结束 onGuideFinished 上报 user&act=welcome 并 startNewTask）。
 * 原文的 `import module.messages.widgets.*` 无任何使用（FFDec 导出残留），
 * 不带入。PORT-NOTE(load-swf)：`new Loader()` → shim.LocalSwfLoader
 * （RSLManager 同款）：help.swf 的 URL 是 module/… 资产，映射进 Assets 库。
 */
class WelcomeView extends Sprite {
	// WelcomeView.as:26
	private var _newTask:MovieClip;

	// WelcomeView.as:28。原类型 flash.display.Loader；LocalSwfLoader 是其
	// 子类，调用形态不变
	private var _helpLoader:Loader;

	// WelcomeView.as:30
	private var _taskWin:WelcomeTaskWindow;

	// WelcomeView.as:32
	private var _completeWin:TaskOverWindow;

	// WelcomeView.as:34
	private var _controller:WelcomeController;

	// WelcomeView.as:36
	private var _tasking:Sprite;

	// WelcomeView.as:38-49
	public function new(param1:WelcomeController) {
		super();
		this._helpLoader = null;
		this._newTask = null;
		this._tasking = null;
		this._taskWin = null;
		this._completeWin = null;
		this._controller = param1;
		param1.model.addEventListener(WelcomeModel.EVENT_TASK_CHANGED, this.onTaskChanged, false, 0, true);
		param1.model.addEventListener(WelcomeModel.EVENT_TASK_COMPLETED, this.onTaskCompleted, false, 0, true);
	}

	// WelcomeView.as:51-54
	private function onWelcomeEnd(param1:CommandEvent):Void {
		trace("welcome guide is over.");
	}

	// WelcomeView.as:56-75
	private function onGuideFinished(param1:Event):Void {
		param1.currentTarget.removeEventListener("closeEvent", this.onGuideFinished);
		this.controller.module.app.dispatchEvent(new Event(Consts.MSG_ACCEPT_NEW_GIFT));
		NetHelper.sendRequest(CommandDefs.CMD_WELCOME_END, null, this.onWelcomeEnd, null);
		this.controller.startNewTask();
		this.showWindow(null);
		if (this._helpLoader != null) {
			removeChildAt(0);
			removeChild(this._helpLoader);
			this._helpLoader = null;
		}
		if (this._newTask != null) {
			this._newTask.mouseEnabled = true;
			this._newTask.mouseChildren = true;
		}
		removeEventListener(MouseEvent.ROLL_OVER, this.onMouseRollOver);
	}

	// WelcomeView.as:77-89
	private function showWindow(param1:Event):Void {
		var _loc2_:Int = this._controller.model.taskID;
		var _loc3_:Int = this._controller.model.taskFlag;
		if (_loc3_ == 2) {
			this.acceptNewTask(_loc2_);
		} else if (_loc3_ == 1) {
			this.activeTask(_loc2_);
		}
	}

	// WelcomeView.as:91-94
	private function onBtnRollOver(param1:MouseEvent):Void {
		this.controller.showTip(Consts.TIP_NAME_MOUSE, Reflect.field(Language.L, "查看当前任务"));
	}

	// WelcomeView.as:96-112（`_loc2_["taskFlag"] as int` → As3.intOf）
	private function onTaskChanged(param1:CommonEvent):Void {
		if (param1 == null || param1.data == null) {
			return;
		}
		var _loc2_:Dynamic = param1.data;
		var _loc3_:Int = As3.intOf(Reflect.field(_loc2_, "taskFlag"));
		if (_loc3_ == 0) {
			this.hidTaskButton();
		} else {
			this.checkTaskResource();
		}
	}

	// WelcomeView.as:114-117
	private function onBtnRollOut(param1:MouseEvent):Void {
		this.controller.hideTip();
	}

	// WelcomeView.as:119-122
	private function onNextTask():Void {
		this.showWindow(null);
	}

	// WelcomeView.as:124-148
	public function showNewGuide():Void {
		var _loc2_:Sprite = null;
		var _loc1_:String = Settings.getInstance().getSecondUrl("help");
		if (_loc1_ == "") {
			return;
		}
		// PORT-NOTE(load-swf)：原版 `new Loader()` 网络拉 help.swf；本地化后
		// 走 Assets 库（LocalSwfLoader 包同名 load，URL → 库 "help"）
		this._helpLoader = new LocalSwfLoader();
		this._helpLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, this.onLoadHelpError);
		this._helpLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, this.onLoadHelpCompleted);
		this._helpLoader.load(new URLRequest(_loc1_));
		addChild(this._helpLoader);
		if (stage != null) {
			_loc2_ = new Sprite();
			_loc2_.graphics.beginFill(16777215, 0.3);
			_loc2_.graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
			_loc2_.graphics.endFill();
			addChildAt(_loc2_, 0);
		}
		addEventListener(MouseEvent.ROLL_OVER, this.onMouseRollOver, false, 0, true);
		this._controller.model.preSetTaskFlag();
		this.checkTaskResource();
	}

	// WelcomeView.as:150-157
	private function checkTaskResource():Void {
		var _loc1_:String = Settings.getInstance().getSecondUrl("fresherTask");
		if (_loc1_ != "") {
			CommonData.rslManager.requestClass("taskAwokeButton", this.rslCallBack, _loc1_);
		}
	}

	// WelcomeView.as:159-162
	public var controller(get, never):WelcomeController;

	private function get_controller():WelcomeController {
		return this._controller;
	}

	// WelcomeView.as:164-188
	private function acceptNewTask(param1:Int):Void {
		var _loc2_:Int = 0;
		var _loc3_:Array<Dynamic> = null;
		if (this._taskWin == null) {
			this._taskWin = new WelcomeTaskWindow(this.controller.module.app);
		}
		this.controller.module.app.farmView.winCtrl.open(this._taskWin);
		if (Session.getInstance().isNewGuideTask) {
			_loc3_ = this.controller.model.newIDToOldIDArray;
			_loc2_ = _loc3_.indexOf(_loc3_[param1] + 1);
		} else {
			_loc2_ = param1 + 1;
		}
		this._taskWin.data = {
			"mode": 0,
			"title": Reflect.field(Language.L, "领取任务"),
			"id": _loc2_,
			"confirmFn": this.onAcceptTask
		};
	}

	// WelcomeView.as:190-233
	private function createBookButton(param1:Int):Void {
		this.hidTaskButton();
		if (param1 == 2) {
			if (this._newTask == null) {
				this._newTask = cast(Utils.getMaterial("taskAwokeButton"), MovieClip);
				if (this._newTask == null) {
					return;
				}
				this._newTask.width = 64;
				this._newTask.height = 49;
				this._newTask.buttonMode = true;
				this._newTask.x = 105;
				this._newTask.y = 500;
				this._newTask.addEventListener(MouseEvent.CLICK, this.showWindow);
				this._newTask.addEventListener(MouseEvent.ROLL_OVER, this.onBtnRollOver, false, 0, true);
				this._newTask.addEventListener(MouseEvent.ROLL_OUT, this.onBtnRollOut, false, 0, true);
			}
			addChild(this._newTask);
		} else if (param1 == 1) {
			if (this._tasking == null) {
				this._tasking = cast(Utils.getMaterial("taskingButton"), Sprite);
				if (this._tasking == null) {
					return;
				}
				this._tasking.buttonMode = true;
				this._tasking.width = 46;
				this._tasking.height = 36;
				this._tasking.x = 105;
				this._tasking.y = 506;
				this._tasking.addEventListener(MouseEvent.CLICK, this.showWindow);
				this._tasking.addEventListener(MouseEvent.ROLL_OVER, this.onBtnRollOver, false, 0, true);
				this._tasking.addEventListener(MouseEvent.ROLL_OUT, this.onBtnRollOut, false, 0, true);
			}
			addChild(this._tasking);
		}
	}

	// WelcomeView.as:235-243
	private function rslCallBack():Void {
		this.createBookButton(this.controller.model.taskFlag);
		if (this._helpLoader != null && this._newTask != null) {
			this._newTask.mouseEnabled = false;
			this._newTask.mouseChildren = false;
		}
	}

	// WelcomeView.as:245-248
	private function onLoadHelpError(param1:IOErrorEvent):Void {
		trace("加载新手帮助文件失败");
	}

	// WelcomeView.as:250-256
	private function onLoadHelpCompleted(param1:Event):Void {
		var _loc2_:DisplayObject = param1.currentTarget.content;
		_loc2_.x = (stage.stageWidth - _loc2_.width) / 2;
		_loc2_.y = (stage.stageHeight - _loc2_.height) / 2;
		_loc2_.addEventListener("closeEvent", this.onGuideFinished);
	}

	// WelcomeView.as:258-289。`_loc2_["task"] != undefined` → Reflect 判空
	//（task 键缺位/显式 null 同落 null；taskId 的 null != 0 与 AS3
	// undefined != 0 一致为真）
	private function onTaskCompleted(param1:CommonEvent):Void {
		if (param1 == null || param1.data == null) {
			return;
		}
		if (this._completeWin == null) {
			this._completeWin = new TaskOverWindow(this._controller.module.app);
		}
		var _loc2_:Dynamic = param1.data;
		var _loc3_:Bool = false;
		if (Reflect.field(_loc2_, "task") != null && Reflect.field(Reflect.field(_loc2_, "task"), "taskId") != 0) {
			this.createBookButton(2);
			Reflect.setField(_loc2_, "confirmFn", this.onNextTask);
		} else {
			this.hidTaskButton();
			Reflect.setField(_loc2_, "confirmFn", this.onTaskAllOver);
			_loc3_ = true;
		}
		this._controller.module.app.farmView.winCtrl.open(this._completeWin);
		this._completeWin.data = _loc2_;
		if (_loc3_) {
			this._completeWin.confirmBtnText = Reflect.field(Language.L, "确定");
		}
		Session.getInstance().addReward(Reflect.field(_loc2_, "item"));
		this._controller.module.app.dispatchEvent(new CommonEvent(Consts.MSG_LEVELUP, _loc2_));
	}

	// WelcomeView.as:291-304
	private function activeTask(param1:Int):Void {
		if (this._taskWin == null) {
			this._taskWin = new WelcomeTaskWindow(this.controller.module.app);
		}
		this.controller.module.app.farmView.winCtrl.open(this._taskWin);
		this._taskWin.data = {
			"mode": 1,
			"title": Reflect.field(Language.L, "任 务"),
			"id": param1,
			"confirmFn": null
		};
	}

	// WelcomeView.as:306-309
	private function onAcceptTask():Void {
		this.controller.model.acceptTask();
	}

	// WelcomeView.as:311-314
	private function onMouseRollOver(param1:Event):Void {
		this.controller.useSystemCursor(true);
	}

	// WelcomeView.as:316-322
	private function onTaskAllOver():Void {
		this.controller.openWindow(Consts.WINDOW_NAME_ALERT, {
			"type": Consts.ALERT_TYPE_SUCCESS,
			"text": Reflect.field(Language.L, "您已完成全部新手任务！")
		});
	}

	// WelcomeView.as:324-334
	private function hidTaskButton():Void {
		if (this._newTask != null && contains(this._newTask) == true) {
			removeChild(this._newTask);
		}
		if (this._tasking != null && contains(this._tasking) == true) {
			removeChild(this._tasking);
		}
	}
}
