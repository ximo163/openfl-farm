package module.decorate;

import common.Consts;
import events.CommonEvent;
import framework.base.Controller;
import interfaces.IMsgCenter;
import shim.As3;

/**
 * module.decorate.DecorateController —— DecorateController.as 逐句对应
 * （issue #38 功能 swf 翻译：DIY 装饰）。app 上 MSG_SHOW_DIY 三入口（data
 * 空→开窗装货；openBillBoard→开窗装告示牌并切到页签 1；plugin_tab→按名切
 * 页签）→ DecorateView；model 的 NOTIFY_REFRESH_MAINSCENE 转发
 * MSG_REFRESH_SCENE 刷主场景；DATA_DECORATE_RELOAD_FLAG 置脏。base
 * Controller 的 m_view/m_model 是 Dynamic，本类自持 view/model 访问器
 * （as 判型，原样）。
 *
 * PORT-NOTE: `param1.data["openBillBoard"] == true` 是 AS3 对 Boolean 的
 * 松等（true/1/"1" 皆真，false/缺位/0 皆假）→ As3.floatOf == 1；`!= undefined`
 * → As3.hasProp。本类经 ModuleDecorate.onModuleLoadSuccess 的反射字符串构造
 * （编译期零引用），入 SymbolClass.dceAnchor 锚住 + @:keep 在 dce full 下保命
 * （LandTile 先例：零引用类不进产物，反射恒 null）；锚住后 html5 的
 * hasDefinition 即真，装配链按原版拉起链走通。
 *
 * AS3 internal static const（DecorateModel 的 EVENT_* 与 NOTIFY_*）译
 * private 后，同包跨类取用需 @:access（WaterController 先例）。
 */
@:keep
@:access(module.decorate.DecorateModel)
class DecorateController extends Controller {
	public function new() {
		super(null);
	}

	// DecorateController.as:16-23
	private function onNotifyRefreshMainScene(param1:CommonEvent):Void {
		if (param1 == null || param1.data == null) {
			return;
		}
		this.m_module.app.dispatchEvent(new CommonEvent(Consts.MSG_REFRESH_SCENE, param1.data));
	}

	// DecorateController.as:25-28
	public var view(get, never):DecorateView;

	private function get_view():DecorateView {
		return Std.isOfType(this.m_view, DecorateView) ? cast(this.m_view, DecorateView) : null;
	}

	// DecorateController.as:30-33
	override public function finalize():Void {
		super.finalize();
	}

	// DecorateController.as:35-38
	public var model(get, never):DecorateModel;

	private function get_model():DecorateModel {
		return Std.isOfType(this.m_model, DecorateModel) ? cast(this.m_model, DecorateModel) : null;
	}

	// DecorateController.as:40-64（switchTab(1)/switchTabByName 假定开窗后
	// init 已建好 tabNav——原版同样假设，WindowControl.open 仍是窗口片 stub）
	private function onShowDecorate(param1:CommonEvent):Void {
		var _loc2_:String = null;
		if (this.m_view == null) {
			this.m_view = new DecorateView(this);
		}
		if (param1.data == null) {
			this.m_module.app.farmView.winCtrl.open(this.m_view);
			this.model.loadItems();
		} else if (As3.floatOf(Reflect.field(param1.data, "openBillBoard")) == 1) {
			this.m_module.app.farmView.winCtrl.open(this.m_view);
			this.model.loadBoards();
			this.view.switchTab(1);
		} else if (As3.hasProp(param1.data, "plugin_tab")) {
			this.m_module.app.farmView.winCtrl.open(this.m_view);
			_loc2_ = Std.isOfType(Reflect.field(param1.data, "plugin_tab"), String) ? cast(Reflect.field(param1.data, "plugin_tab"), String) : null;
			this.view.switchTabByName(_loc2_);
		}
	}

	// DecorateController.as:66-82（m_model 上直接 addEventListener，原样）
	private function registerListeners():Void {
		if (this.m_module == null || this.m_module.app == null) {
			return;
		}
		if (this.m_model != null) {
			this.m_model.addEventListener(DecorateModel.NOTIFY_REFRESH_MAINSCENE, this.onNotifyRefreshMainScene, false, 0, true);
		}
		var _loc1_:IMsgCenter = Std.isOfType(this.m_module.app, IMsgCenter) ? cast(this.m_module.app, IMsgCenter) : null;
		if (_loc1_ != null) {
			_loc1_.addEventListener(Consts.MSG_SHOW_DIY, this.onShowDecorate, false, 0, true);
			_loc1_.addEventListener(Consts.DATA_DECORATE_RELOAD_FLAG, this.onNeedReload, false, 0, true);
		}
	}

	// DecorateController.as:84-90
	private function onNeedReload(param1:CommonEvent):Void {
		if (this.model != null) {
			this.model.dirty = true;
		}
	}

	// DecorateController.as:92-100
	override public function initialze():Void {
		super.initialze();
		if (this.m_model == null) {
			this.m_model = new DecorateModel();
		}
		this.registerListeners();
	}
}
