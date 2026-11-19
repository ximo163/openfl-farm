package module.mainScene.npc;

import common.Consts;
import common.Session;
import entities.Dog;
import entities.StartupData;
import events.CommonEvent;
import framework.base.Controller;
import interfaces.IModule;
import interfaces.IMsgCenter;
import shim.As3;

/**
 * module.mainScene.npc.NPCController —— V3b 翻译（issue #8）。
 * NPC 控制器：监听启动/重载/狗变更/场景刷新/活动 NPC 安装消息，驱动
 * NPCModel/NPCView。legacy/decompiled/main3_v_221/scripts/module/mainScene/
 * npc/NPCController.as 逐句对应。
 */
class NPCController extends Controller {
	// NPCController.as:11
	private var _session:Session;

	// NPCController.as:13-17
	public function new(param1:IModule) {
		super(param1);
	}

	// NPCController.as:19-31（onRefreshView：场景装饰刷新消息里只认狗）
	private function onRefreshView(param1:CommonEvent):Void {
		if (param1 == null || param1.data == null) {
			return;
		}
		var _loc2_:Int = As3.intOf(Reflect.field(param1.data, "type"));
		var _loc3_:Int = As3.intOf(Reflect.field(param1.data, "id"));
		if (_loc2_ != Consts.DECOR_DOG) {
			return;
		}
		this.model.changeDog(_loc3_);
	}

	// NPCController.as:33-38（finalize：模型置空；view/module 的清理由基类）
	override public function finalize():Void {
		if (this.m_model != null) {
			this.m_model = null;
		}
	}

	// NPCController.as:40-50（onStartupData：启动数据里的狗进模型）
	private function onStartupData(param1:CommonEvent):Void {
		if (param1 == null || param1.data == null) {
			return;
		}
		var _loc2_:StartupData = Std.isOfType(param1.data, StartupData) ? cast(param1.data, StartupData) : null;
		if (_loc2_ != null) {
			this.model.setDogData(_loc2_._dog);
		}
	}

	// NPCController.as:52-55（get model）
	public var model(get, never):NPCModel;

	private function get_model():NPCModel {
		return this.m_model;
	}

	// NPCController.as:57-60（get view）
	public var view(get, never):NPCView;

	private function get_view():NPCView {
		return this.m_view;
	}

	// NPCController.as:62-77（initialze：建模型/视图并挂进模块容器）
	override public function initialze():Void {
		if (this.m_model == null) {
			this.m_model = new NPCModel();
		}
		this.registerListeners();
		if (this.m_view == null) {
			this.m_view = new NPCView(this);
			if (this.m_module != null && this.m_module.container != null) {
				this.m_module.container.addChild(this.m_view);
			}
		}
		this._session = Session.getInstance();
	}

	// NPCController.as:79-88（onInstallActivityNPC）
	private function onInstallActivityNPC(param1:CommonEvent):Void {
		var _loc2_:Dynamic = param1.data;
		if (_loc2_ == null) {
			return;
		}
		this.view.installNPC(_loc2_);
	}

	// NPCController.as:90-102（onGameDataReloaded：整包重载后重建狗并按
	// 当前用户切换 NPC 显隐）
	private function onGameDataReloaded(param1:CommonEvent):Void {
		if (param1 == null || param1.data == null) {
			return;
		}
		var _loc2_:StartupData = Std.isOfType(param1.data, StartupData) ? cast(param1.data, StartupData) : null;
		if (_loc2_ != null) {
			this.model.setDogData(_loc2_._dog);
		}
		this.m_view.switchNPC();
	}

	// NPCController.as:104-114（registerListeners：经 IMsgCenter 订阅）
	private function registerListeners():Void {
		var _loc1_:IMsgCenter = Std.isOfType(this.m_module.app, IMsgCenter) ? cast(this.m_module.app, IMsgCenter) : null;
		if (_loc1_ != null) {
			_loc1_.addEventListener(Consts.MSG_STARTUP_DATA, this.onStartupData, false, 0, true);
			_loc1_.addEventListener(Consts.MSG_RELOAD_GAME_RESULT, this.onGameDataReloaded, false, 0, true);
			_loc1_.addEventListener(Consts.DATA_DOG_CHANGED, this.onDogUpdated, false, 0, true);
			_loc1_.addEventListener(Consts.MSG_REFRESH_SCENE, this.onRefreshView, false, 0, true);
			_loc1_.addEventListener(Consts.MSG_INSTALL_NPC, this.onInstallActivityNPC, false, 0, true);
		}
	}

	// NPCController.as:116-124（onDogUpdated）
	private function onDogUpdated(param1:CommonEvent):Void {
		var _loc2_:Dog = Std.isOfType(param1.data, Dog) ? cast(param1.data, Dog) : null;
		if (_loc2_ != null) {
			this.model.setDogData(_loc2_);
		}
	}
}
