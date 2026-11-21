package module.mainScene.npc.widgets;

import common.Session;
import common.misc.Utils;
import module.mainScene.npc.NPCView;
import openfl.display.DisplayObject;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.MouseEvent;
import report.UserActionRecorder;

/**
 * module.mainScene.npc.widgets.DogBowl —— DogBowl.as 逐句对应（issue #29
 * 替换闭包 stub）。狗粮盆：food setter 按满/空换 DogFoodNull/DogFood 符号
 * （farmui_full_v_40 导出，shim 见 src/DogFood*.hx），主人侧挂鼠标事件。
 * legacy/decompiled/main3_v_221/scripts/module/mainScene/npc/widgets/DogBowl.as。
 */
class DogBowl extends Sprite {
	// DogBowl.as:15（宿主视图）
	private var m_parent:NPCView;

	// DogBowl.as:17-19（AS3 实例 const → static final，CLAUDE.md 规则）
	private static final salverX:Int = 400;
	private static final salverY:Int = 200;

	// DogBowl.as:21-25
	public function new(param1:NPCView) {
		super();
		this.m_parent = param1;
	}

	// DogBowl.as:27-30
	private function onMouseOut(param1:MouseEvent):Void {
		this.m_parent.controller.useSystemCursor(false);
	}

	// DogBowl.as:32-43（removeSalver：清空盆内全部子件）
	private function removeSalver():Void {
		var _loc3_:DisplayObject = null;
		var _loc1_:Int = this.numChildren;
		var _loc2_:Int = 0;
		while (_loc2_ < _loc1_) {
			_loc3_ = this.removeChildAt(0);
			_loc3_ = null;
			_loc2_++;
		}
	}

	// DogBowl.as:45-49（点盆：拉狗粮状态回包，NPCView.onFoodLoaded 开窗）
	private function onClicked(param1:Event):Void {
		this.m_parent.controller.model.loadDogFoodStatus();
		UserActionRecorder.recordAction(UserActionRecorder.HF_DOGBOWL_CLICKED);
	}

	// DogBowl.as:51-54
	private function onMouseOver(param1:MouseEvent):Void {
		this.m_parent.controller.useSystemCursor(true);
	}

	// DogBowl.as:56-103（set food：满/空两态换符号并按主人侧挂/摘鼠标事件。
	// `Utils.getMaterial(x) as Sprite` 单调进局部过类型门（lessons #18），
	// 失配落 null——openfl 下 DogFood/DogFoodNull shim 均为 MovieClip（Sprite
	// 子类），恒命中）
	public var food(never, set):Bool;

	private function set_food(param1:Bool):Bool {
		var _loc2_:Sprite = null;
		var _loc3_:Sprite = null;
		var _locm_:Dynamic = null;
		this.removeSalver();
		if (param1 == true) {
			_locm_ = Utils.getMaterial("DogFoodNull");
			_loc2_ = Std.isOfType(_locm_, Sprite) ? cast(_locm_, Sprite) : null;
			addChild(_loc2_);
			_loc2_.x = salverX;
			_loc2_.y = salverY;
			_loc2_.scaleX = 0.5;
			_loc2_.scaleY = 0.5;
			if (Session.getInstance().me == true) {
				_loc2_.addEventListener(MouseEvent.ROLL_OVER, this.onMouseOver);
				_loc2_.addEventListener(MouseEvent.ROLL_OUT, this.onMouseOut);
				_loc2_.addEventListener(MouseEvent.CLICK, this.onClicked);
				_loc2_.buttonMode = true;
				_loc2_.mouseEnabled = true;
			} else {
				_loc2_.buttonMode = false;
				_loc2_.mouseEnabled = false;
			}
		} else {
			_locm_ = Utils.getMaterial("DogFood");
			_loc3_ = Std.isOfType(_locm_, Sprite) ? cast(_locm_, Sprite) : null;
			addChild(_loc3_);
			_loc3_.x = salverX;
			_loc3_.y = salverY;
			_loc3_.scaleX = 0.5;
			_loc3_.scaleY = 0.5;
			if (Session.getInstance().me == true) {
				_loc3_.addEventListener(MouseEvent.ROLL_OVER, this.onMouseOver);
				_loc3_.addEventListener(MouseEvent.ROLL_OUT, this.onMouseOut);
				_loc3_.addEventListener(MouseEvent.CLICK, this.onClicked);
				_loc3_.buttonMode = true;
				_loc3_.mouseEnabled = true;
			} else {
				_loc3_.buttonMode = false;
				_loc3_.mouseEnabled = false;
			}
		}
		return param1;
	}
}
