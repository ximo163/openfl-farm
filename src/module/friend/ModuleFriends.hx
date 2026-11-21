package module.friend;

import common.Consts;
import framework.base.BaseLayer;
import framework.base.Module;
import module.FarmApplication;

/**
 * module.friend.ModuleFriends —— ModuleFriends.as 逐句对应。
 * 好友列表模块壳：load 时建 FriendsController 并 initialze（视图进
 * container、双向监听装配），unload 时 finalize 置空。字段名 m_firendsCtrl
 * 的拼写照抄原版（多了个 r）。
 */
@:keep
class ModuleFriends extends Module {
	// ModuleFriends.as:12
	private var m_firendsCtrl:FriendsController;

	public function new(param1:FarmApplication) {
		super(param1);
	}

	// ModuleFriends.as:20-23
	override private function get_name():String {
		return Consts.MODULE_FRIENDS;
	}

	// ModuleFriends.as:25-31
	override public function load(param1:BaseLayer):Void {
		super.load(param1);
		this.m_firendsCtrl = new FriendsController(this);
		this.m_firendsCtrl.initialze();
	}

	// ModuleFriends.as:33-40
	override public function unload():Void {
		if(this.m_firendsCtrl != null) {
			this.m_firendsCtrl.finalize();
			this.m_firendsCtrl = null;
		}
	}
}
