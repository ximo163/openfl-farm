package module.messages;

import common.Consts;
import common.view.window.BaseWindow;
import entities.Player;
import events.CommonEvent;
import framework.base.Controller;
import interfaces.IModule;
import interfaces.IMsgCenter;
import shim.As3;

/**
 * module.messages.MessageController —— MessageController.as 逐句对应
 * （issue #19）。监听 MSG_SHOW_PROFILE 开个人信息窗（MessageView），按事件
 * 载荷的 index/player 选页与切换到访对象。
 * PORT-NOTE: `m_model as MessageModel` / `data["player"] as Player` →
 * Std.isOfType 门 + 直取（eval 裸 cast 不检查、吞不掉 as 的 null 回退）。
 */
class MessageController extends Controller {
	public function new(param1:IModule) {
		super(param1);
	}

	// MessageController.as:19-22
	public var model(get, never):MessageModel;

	private function get_model():MessageModel {
		if (Std.isOfType(m_model, MessageModel)) {
			return m_model;
		}
		return null;
	}

	// MessageController.as:24-48
	private function onOpenWindow(param1:CommonEvent):Void {
		if (m_view == null) {
			m_view = new MessageView(this);
		}
		module.app.farmView.winCtrl.open(cast(m_view, BaseWindow));
		var _loc2_:Int = 0;
		var _loc3_:Player = null;
		if (param1.data != null) {
			_loc2_ = As3.intOf(Reflect.field(param1.data, "index"));
			if (_loc2_ < 0) {
				_loc2_ = 0;
			}
			if (As3.hasProp(param1.data, "player")) {
				if (Std.isOfType(Reflect.field(param1.data, "player"), Player)) {
					_loc3_ = Reflect.field(param1.data, "player");
				}
			}
		}
		this.model.currentPlayer = _loc3_;
		this.model.loadData(_loc2_);
		cast(m_view, MessageView).switchPage(_loc2_, this.model.me);
	}

	// MessageController.as:50-61
	override public function initialze():Void {
		if (m_model == null) {
			m_model = new MessageModel();
		}
		// `m_module.app as IMsgCenter`：FarmApplication 静态实现该接口，直上转
		var _loc1_:IMsgCenter = cast(this.m_module.app, IMsgCenter);
		if (_loc1_ != null) {
			_loc1_.addEventListener(Consts.MSG_SHOW_PROFILE, this.onOpenWindow, false, 0, true);
		}
	}
}
