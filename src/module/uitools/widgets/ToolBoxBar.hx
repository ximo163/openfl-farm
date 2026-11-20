package module.uitools.widgets;

import com.qzone.qui.containers.HBox;
import com.qzone.qui.controls.scrollClasses.ScrollPolicy;
import com.qzone.qui.core.Align;
import common.Consts;
import common.misc.Cookies;
import common.misc.QzoneJSAPI;
import common.misc.Utils;
import common.view.cursor.CursorControl;
import events.CommonEvent;
import framework.base.Module;
import module.uitools.UIController;
import openfl.display.DisplayObject;
import openfl.display.MovieClip;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.net.URLVariables;
import report.EventRecorder;
import shim.As3;

/**
 * module.uitools.widgets.ToolBoxBar —— ToolBoxBar.as 逐句对应（issue #9）。
 * 工具箱浮条：Hook/农药/浇水/拍照/健康模式/缩放按钮，PackBarBg 底皮，
 * 出场贴底部鼠标，300ms 滚出隐藏。ROLL_OVER/ROLL_OUT 照原样注册，触摸目标
 * 的悬停合成走 src/shim 输入适配层（spec/interaction-map.json）。
 */
class ToolBoxBar extends HBox {
	// ToolBoxBar.as:26
	private var _toolZoomOut:DisplayObject;

	// ToolBoxBar.as:28
	private var m_hideTimer:UInt;

	// ToolBoxBar.as:30
	private var m_controller:UIController;

	// ToolBoxBar.as:32
	private var _toolZoomIn:DisplayObject;

	// ToolBoxBar.as:34-68
	public function new(param1:UIController) {
		var _loc2_:Int = QzoneJSAPI.QPLUS == false && QzoneJSAPI.WB == false ? 356 : 310;
		super(_loc2_, 70);
		this.buttonMode = true;
		this.verticalScrollPolicy = ScrollPolicy.OFF;
		this.horizontalScrollPolicy = ScrollPolicy.OFF;
		this.alignH = Align.CENTER;
		this.alignV = Align.TOP;
		this.paddingH = 20;
		this.paddingV = 16;
		this.gapH = 12;
		this.defaultSkin = PackBarBg;
		this.m_hideTimer = 0;
		this.m_controller = param1;
		var _loc3_:DisplayObject = null;
		_loc3_ = this.addToolBtn("ToolHook", "清除地里的杂草(W)");
		_loc3_ = this.addToolBtn("ToolPesticide", "清除地里的害虫(E)");
		_loc3_ = this.addToolBtn("ToolWater", "用来浇水(Q)");
		if (QzoneJSAPI.QPLUS == false && QzoneJSAPI.WB == false) {
			_loc3_ = this.addToolBtn("CameraButton", "农场拍照留念");
		}
		_loc3_ = this.addToolBtn("newHealthModeIcon", "健康模式");
		cast(_loc3_, MovieClip).stop();
		if (Cookies.Get("bigmode") == "1") {
			this._toolZoomOut = this.addToolBtn("ToolZoomOut", "缩小");
		} else {
			this._toolZoomIn = this.addToolBtn("ToolZoomIn", "放大");
		}
		this.addEventListener(Event.ADDED_TO_STAGE, this.onAddedToStage, false, 0, true);
	}

	// ToolBoxBar.as:70-73
	private function hideThis():Void {
		this.visible = false;
	}

	// ToolBoxBar.as:75-89（addToolBtn：素材 + 动态 tipText 属性 + 三事件；
	// 素材缺位返回 null，后续 MovieClip(_loc3_).stop() 照原版照常走）
	private function addToolBtn(param1:String, param2:String):Dynamic {
		var _loc3_:Dynamic = Utils.getMaterial(param1);
		if (_loc3_ == null) {
			return null;
		}
		_loc3_.name = param1;
		Reflect.setField(_loc3_, "tipText", param2);
		_loc3_.addEventListener(MouseEvent.CLICK, this.onToolClick, false, 0, true);
		_loc3_.addEventListener(MouseEvent.ROLL_OVER, this.onToolRollOver, false, 0, true);
		_loc3_.addEventListener(MouseEvent.ROLL_OUT, this.onToolRollOut, false, 0, true);
		this.addElement(_loc3_);
		return _loc3_;
	}

	// ToolBoxBar.as:91-98
	// PORT-NOTE: 原版 `_skin = new defaultSkin()` 是动态类直接构造，Haxe 无
	// 此形态，Type.createInstance 等价（Canvas.setSkin 同款）
	private override function setSkin():Void {
		if (this.defaultSkin != null) {
			this._skin = Type.createInstance(this.defaultSkin, []);
			this.addChildAt(this._skin, 0);
		}
	}

	// ToolBoxBar.as:100-108
	private function onOver(param1:MouseEvent):Void {
		this.m_controller.useSystemCursor(true);
		if (this.m_hideTimer != 0) {
			As3.clearTimeout(this.m_hideTimer);
		}
		this.m_hideTimer = 0;
	}

	// ToolBoxBar.as:110-114
	private function adjustPosition():Void {
		this.x = this.stage.mouseX - this.width * 0.5;
		this.y = this.stage.stageHeight - 66 - this.height;
	}

	// ToolBoxBar.as:116-131（原版按 "__health__" 名取子件，本类装的按钮名是
	// newHealthModeIcon——恒 null 直接 return，原文如此照抄）
	public function toggleHealthMode(param1:Bool):Void {
		var _loc2_:MovieClip = cast(this.content.getChildByName("__health__"), MovieClip);
		if (_loc2_ == null) {
			return;
		}
		if (param1 == true) {
			_loc2_.gotoAndStop(2);
		} else {
			_loc2_.gotoAndStop(1);
		}
	}

	// ToolBoxBar.as:133-162（点击同工具再点还原箭头）
	private function setCursor(param1:String, param2:Bool = false):Bool {
		var _loc4_:Module = null;
		var _loc5_:CursorControl = null;
		var _loc3_:Bool = false;
		if (this.m_controller != null) {
			_loc4_ = cast(this.m_controller.module, Module);
			if (_loc4_ != null && _loc4_.app != null) {
				_loc5_ = _loc4_.app.farmView.cursorCtrl;
				if (param2 == false) {
					_loc5_.setCursor(param1);
					_loc3_ = true;
				} else if (_loc5_.name != param1) {
					_loc5_.setCursor(param1);
					_loc3_ = true;
				} else {
					this.setCursor(Consts.CURSOR_STYLE_ARROW);
					_loc3_ = false;
				}
			}
		}
		return _loc3_;
	}

	// ToolBoxBar.as:164-172
	private function onToolRollOver(param1:MouseEvent):Void {
		var _loc2_:String = Reflect.field(param1.target, "tipText");
		if (_loc2_ == null || _loc2_ == "") {
			return;
		}
		this.m_controller.showTip(Consts.TIP_NAME_MOUSE, _loc2_);
	}

	// ToolBoxBar.as:174-177
	private function onStageClick(param1:MouseEvent):Void {
		this.close();
	}

	// ToolBoxBar.as:179-182
	private function onClick(param1:MouseEvent):Void {
		param1.stopPropagation();
	}

	// ToolBoxBar.as:184-192
	private function onAddedToStage(param1:Event):Void {
		param1.target.removeEventListener(Event.ADDED_TO_STAGE, this.onAddedToStage);
		this.adjustPosition();
		this.addEventListener(MouseEvent.ROLL_OVER, this.onOver, false, 0, true);
		this.addEventListener(MouseEvent.ROLL_OUT, this.onOut, false, 0, true);
		this.addEventListener(MouseEvent.CLICK, this.onClick, false, 0, true);
		this.stage.addEventListener(MouseEvent.CLICK, this.onStageClick, false, 999, true);
	}

	// ToolBoxBar.as:194-197
	private function onOut(param1:MouseEvent):Void {
		this.m_hideTimer = As3.setTimeout(this.close, 300);
	}

	// ToolBoxBar.as:199-201（空覆写：HBox 链的背景重画不参与）
	private override function updateBackGround():Void {}

	// ToolBoxBar.as:203-274（工具点击分发；缩放档位切换带 1/500 采样上报）
	private function onToolClick(param1:MouseEvent):Void {
		var _loc3_:URLVariables = null;
		var _loc4_:URLVariables = null;
		var _loc2_:DisplayObject = cast(param1.target, DisplayObject);
		if (_loc2_ == null) {
			return;
		}
		if (_loc2_.name == "ToolHook") {
			this.setCursor(Consts.CURSOR_STYLE_HOOK);
		} else if (_loc2_.name == "ToolPesticide") {
			this.setCursor(Consts.CURSOR_STYLE_PESTICIDE);
		} else if (_loc2_.name == "ToolWater") {
			this.setCursor(Consts.CURSOR_STYLE_WATER);
		} else if (_loc2_.name == "CameraButton") {
			this.m_controller.openCameraShootWindow();
		} else if (_loc2_.name == "newHealthModeIcon") {
			this.m_controller.module.app.dispatchEvent(new CommonEvent(Consts.MSG_SHOW_HEALTHMODE, null));
		} else if (_loc2_.name == "ToolZoomIn") {
			if (this._toolZoomOut == null) {
				this._toolZoomOut = this.addToolBtn("ToolZoomOut", "缩小");
				this._toolZoomOut.x = this._toolZoomIn.x;
				this._toolZoomOut.y = this._toolZoomIn.y;
			}
			this.content.removeChild(this._toolZoomIn);
			this.content.addChild(this._toolZoomOut);
			this.m_controller.switchBigMode(true);
			if (Std.int(Math.random() * EventRecorder.successRecordProbability) == 0) {
				_loc3_ = new URLVariables();
				Reflect.setField(_loc3_, "flag1", EventRecorder.HF_ZOOMIN);
				Reflect.setField(_loc3_, "flag2", EventRecorder.SUEECSS);
				Reflect.setField(_loc3_, "1", EventRecorder.successRecordProbability);
				EventRecorder.record(_loc3_);
			}
		} else if (_loc2_.name == "ToolZoomOut") {
			if (this._toolZoomIn == null) {
				this._toolZoomIn = this.addToolBtn("ToolZoomIn", "放大");
				this._toolZoomIn.x = this._toolZoomOut.x;
				this._toolZoomIn.y = this._toolZoomOut.y;
			}
			this.content.removeChild(this._toolZoomOut);
			this.content.addChild(this._toolZoomIn);
			this.m_controller.switchBigMode(false);
			if (Std.int(Math.random() * EventRecorder.successRecordProbability) == 0) {
				_loc4_ = new URLVariables();
				Reflect.setField(_loc4_, "flag1", EventRecorder.HF_ZOOMOUT);
				Reflect.setField(_loc4_, "flag2", EventRecorder.SUEECSS);
				Reflect.setField(_loc4_, "1", EventRecorder.successRecordProbability);
				EventRecorder.record(_loc4_);
			}
		}
		param1.stopPropagation();
		this.hideThis();
	}

	// ToolBoxBar.as:276-279
	private function onToolRollOut(param1:MouseEvent):Void {
		this.m_controller.hideTip();
	}

	// ToolBoxBar.as:281-293
	public function toggleVisible():Void {
		if (this.visible == true) {
			this.close();
			return;
		}
		this.visible = true;
		if (this.stage != null) {
			this.stage.addEventListener(MouseEvent.CLICK, this.onStageClick, false, 999, true);
		}
	}

	// ToolBoxBar.as:295-299
	public function close():Void {
		this.visible = false;
		this.stage.removeEventListener(MouseEvent.CLICK, this.onStageClick);
	}
}
