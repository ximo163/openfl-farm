package module.levelup;

import common.Consts;
import events.CommonEvent;
import framework.base.Module;
import module.FarmApplication;
import shim.As3;

/**
 * module.levelup.LevelUpModule —— LevelUpModule.as 逐句对应（issue #43 真身，
 * 替换 #7 模块壳 stub）。升级触发壳：听 MSG_USER_LEVEL_UP（Session 账户更新
 * 时派发，Session.as:381），从 nowLevel 逐级往下补弹 LevelUpWindow（#18 已翻）
 * 直到 preLevel+1——跨多级时每级各一扇。原版不覆写 name，沿用 Module 基类
 * 的空名；FarmApplication.startup 里直接 load。
 */
@:keep
class LevelUpModule extends Module {
	// LevelUpModule.as:10
	private var _model:LevelUpModel;

	// LevelUpModule.as:12-17
	public function new(param1:FarmApplication) {
		super(param1);
		this._model = new LevelUpModel();
		param1.addEventListener(Consts.MSG_USER_LEVEL_UP, this.__onLevelUp);
	}

	// LevelUpModule.as:19-30
	private function __onLevelUp(param1:CommonEvent):Void {
		var _loc5_:LevelUpWindow = null;
		var _loc2_:Dynamic = param1.data;
		var _loc3_:Int = As3.intOf(Reflect.field(_loc2_, "preLevel"));
		var _loc4_:Int = As3.intOf(Reflect.field(_loc2_, "nowLevel"));
		while (_loc4_ > _loc3_) {
			_loc5_ = new LevelUpWindow(_loc4_, this._model, app);
			_loc4_--;
		}
	}
}
