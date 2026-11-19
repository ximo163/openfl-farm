package module.mainScene;

import common.Consts;
import common.misc.Cookies;
import entities.FarmLand;
import events.CommonEvent;
import openfl.display.DisplayObject;
import openfl.display.Sprite;
import framework.api.PluginManager;
import framework.base.BaseLayer;
import framework.base.Module;
import framework.layers.FarmLayer;
import module.FarmApplication;
import module.mainScene.background.BackgroundController;
import module.mainScene.farmLand.FarmLandController;
import module.mainScene.farmLand.FarmLandModel;
import module.mainScene.npc.NPCController;

// module.mainScene.ModuleMainScene —— ModuleMainScene.as 逐句对应（主场景模块：
// 背景/农田/NPC 三控制器 + 大小场景切换）。视图族（BackgroundController 等）
// 是 V3b 的闭包 stub，本片保模型装载与 isAllBlack/onNetRequestStopped 链。
// PORT-NOTE: `super.container["maxWidth"]` 的动态下标写在 Haxe 里要类型化，
// LAYER_SCENE_CONTENT 挂的本来就是 FarmLayer（FarmStage.buildLayers），
// cast 后按属性写，语义不变。
class ModuleMainScene extends Module {
	// ModuleMainScene.as:22
	private var m_backgroundCtrl:BackgroundController;

	// ModuleMainScene.as:24
	private var _bigScaleMode:Bool;

	// ModuleMainScene.as:26
	private var m_npcCtrl:NPCController;

	// ModuleMainScene.as:28
	private var m_farmLandCtrl:FarmLandController;

	// ModuleMainScene.as:30-38
	public function new(param1:FarmApplication) {
		super(param1);
		this.m_backgroundCtrl = null;
		this.m_farmLandCtrl = null;
		this.m_npcCtrl = null;
		this._bigScaleMode = false;
		param1.addEventListener(Consts.MSG_ZOOM, this.onZoom, false, 0, true);
	}

	// ModuleMainScene.as:40-56
	override public function onNetRequestStopped():Void {
		if (this.m_farmLandCtrl != null) {
			if (this.m_farmLandCtrl.model != null) {
				this.m_farmLandCtrl.model.resetLoadingFlags();
			}
		}
		if (this.m_npcCtrl != null) {
			if (this.m_npcCtrl.model != null) {
				this.m_npcCtrl.model.resetLoadingFlags();
			}
		}
	}

	// ModuleMainScene.as:58-101
	public var bigMode(get, set):Bool;

	private function get_bigMode():Bool {
		return this._bigScaleMode;
	}

	private function set_bigMode(param1:Bool):Bool {
		var _loc4_:FarmLayer = null;
		this._bigScaleMode = param1;
		this.m_backgroundCtrl.switchMode(param1);
		this.m_farmLandCtrl.switchMode(param1);
		var _loc2_:Float = param1 == true ? 1.3 : 1;
		cast(super.container, FarmLayer).maxWidth = Consts.SCENE_WIDTH * _loc2_;
		cast(super.container, FarmLayer).maxHeight = Consts.SCENE_HEIGHT * _loc2_;
		var _loc3_:DisplayObject = super.container.getChildByName(Consts.SCENE_ZINDEX_MIDDLE);
		if (_loc3_ != null) {
			_loc3_.scaleX = _loc3_.scaleY = _loc2_;
		}
		_loc3_ = super.container.getChildByName(Consts.SCENE_ZINDEX_FOREGROUND);
		if (_loc3_ != null) {
			_loc3_.scaleX = _loc3_.scaleY = _loc2_;
		}
		if (param1 == false) {
			_loc4_ = cast super.container;
			if (_loc4_ != null) {
				if (_loc4_.top < 0) {
					_loc4_.top = 0;
				} else if (_loc4_.top + _loc4_.height > _loc4_.maxHeight) {
					_loc4_.top = _loc4_.maxHeight - _loc4_.height - 60;
				}
				if (_loc4_.left < 0) {
					_loc4_.left = 0;
				} else if (_loc4_.left + _loc4_.width > _loc4_.maxWidth) {
					_loc4_.left = _loc4_.maxWidth - _loc4_.width;
				}
				_loc4_.reRoll();
			}
		}
		return param1;
	}

	// ModuleMainScene.as:108-128
	override public function load(param1:BaseLayer):Void {
		super.load(param1);
		this.m_backgroundCtrl = new BackgroundController(this);
		this.m_backgroundCtrl.initialze();
		var _loc2_:Sprite = new Sprite();
		_loc2_.name = Consts.SCENE_ZINDEX_MIDDLE;
		if (param1 != null) {
			param1.addChild(_loc2_);
		}
		this.m_farmLandCtrl = new FarmLandController(this);
		this.m_farmLandCtrl.initialze();
		this.m_npcCtrl = new NPCController(this);
		this.m_npcCtrl.initialze();
		PluginManager.getInstance().amountPlugins(Consts.PLUGIN_AMOUNT_BG, param1, null);
		if (Cookies.Get("bigmode") == "1") {
			this.bigMode = true;
		}
	}

	// ModuleMainScene.as:130-133
	override private function get_name():String {
		return Consts.MODULE_MAINSCENE;
	}

	// ModuleMainScene.as:135-138
	private function onZoom(param1:CommonEvent):Void {
		this.bigMode = cast(param1.data, Bool);
	}

	// ModuleMainScene.as:140-146
	override public function onGameLoop(param1:Float):Void {
		if (this.m_farmLandCtrl != null) {
			this.m_farmLandCtrl.onGameLoop(param1);
		}
	}

	// ModuleMainScene.as:148-171
	public var isAllBlack(get, never):Bool;

	private function get_isAllBlack():Bool {
		var _loc1_:FarmLandModel = this.m_farmLandCtrl.model;
		if (_loc1_ == null) {
			return false;
		}
		var _loc2_:FarmLand = null;
		var _loc3_:Int = 0;
		while (_loc3_ < 24) {
			_loc2_ = _loc1_.getLandData(_loc3_);
			if (_loc2_ == null) {
				return false;
			}
			if (_loc2_._bitmap != 2) {
				return false;
			}
			_loc3_++;
		}
		return true;
	}

	// ModuleMainScene.as:173-190
	override public function unload():Void {
		if (this.m_backgroundCtrl != null) {
			this.m_backgroundCtrl.finalize();
			this.m_backgroundCtrl = null;
		}
		if (this.m_farmLandCtrl != null) {
			this.m_farmLandCtrl.finalize();
			this.m_farmLandCtrl = null;
		}
		if (this.m_npcCtrl != null) {
			this.m_npcCtrl.finalize();
			this.m_npcCtrl = null;
		}
	}
}
