package module.task.welcome;

import common.Consts;
import entities.StartupData;
import entities.Task;
import events.CommonEvent;
import framework.base.Controller;
import interfaces.IModule;
import interfaces.IMsgCenter;

/**
 * module.task.welcome.WelcomeController —— WelcomeController.as（91 loc）
 * 逐句对应（issue #21）。任务模块装配层：initialze 挂 MSG_STARTUP_DATA（首发
 * 数据：_welcome 真播新手引导、否则装 StartupData._task）与 MSG_CHECK_TASK
 * （FarmLandModel 的动作应答逐键转发 taskComp 判完成）；startNewTask 造
 * {id:0, flag:2} 的空任务装进 model（引导结束、待领第一个任务）。
 */
class WelcomeController extends Controller {
	// WelcomeController.as:14-17
	public function new(param1:IModule) {
		super(param1);
	}

	// WelcomeController.as:19-25
	public function startNewTask():Void {
		var _loc1_:Task = new Task(null);
		_loc1_._taskId = 0;
		_loc1_._taskFlag = 2;
		this.model.currentTask = _loc1_;
	}

	// WelcomeController.as:27-39（for-in 遍历 data 键 → Reflect.fields，
	// 键=动作名、值=带 code 的服务端应答）
	private function onCheckTaskComplete(param1:CommonEvent):Void {
		var _loc3_:String = null;
		if (param1 == null || param1.data == null) {
			return;
		}
		var _loc2_:Dynamic = param1.data;
		for (_loc3_ in Reflect.fields(_loc2_)) {
			this.model.taskComp(_loc3_, Reflect.field(_loc2_, _loc3_));
		}
	}

	// WelcomeController.as:41-68
	private function onStartupData(param1:CommonEvent):Void {
		if (param1 == null || param1.data == null) {
			return;
		}
		// AS3 `as` 失配返回 null → Std.isOfType 门 + 直取
		var _loc2_:StartupData = Std.isOfType(param1.data, StartupData) ? cast(param1.data, StartupData) : null;
		if (_loc2_ == null) {
			return;
		}
		if (m_view == null) {
			m_view = new WelcomeView(this);
			if (super.module.container != null) {
				super.module.container.addChild(m_view);
			}
		}
		if (_loc2_._welcome == true) {
			m_view.showNewGuide();
		} else {
			this.model.currentTask = _loc2_._task;
		}
	}

	// WelcomeController.as:70-73（m_model as WelcomeModel）
	public var model(get, never):WelcomeModel;

	private function get_model():WelcomeModel {
		return cast(this.m_model, WelcomeModel);
	}

	// WelcomeController.as:75-87（`m_module.app as IMsgCenter` 的 as 门，
	// BackgroundController 同款）
	override public function initialze():Void {
		if (m_model == null) {
			m_model = new WelcomeModel();
		}
		var _loc1d:Dynamic = m_module.app;
		var _loc1_:IMsgCenter = Std.isOfType(_loc1d, IMsgCenter) ? cast _loc1d : null;
		if (_loc1_ != null) {
			_loc1_.addEventListener(Consts.MSG_STARTUP_DATA, this.onStartupData, false, 0, true);
			_loc1_.addEventListener(Consts.MSG_CHECK_TASK, this.onCheckTaskComplete, false, 0, true);
		}
	}
}
