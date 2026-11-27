package mc.view.main.floating;

import common.LocalData;
import mc.control.ViewControl;
import mc.events.FloatingEvent;
import mc.model.MData;
import mc.model.MainData;
import mc.view.farm.land.ClockOperateFloating;
import openfl.display.DisplayObject;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.MouseEvent;

/**
 * mc.view.main.floating.FloatingLayer —— FloatingLayer.as 逐句对应（issue
 * #87「飘字」片）。飘字层：FLOATING_OPEN 收飘字 start+挂树（wild 场景直接
 * 隐），FLOATING_CLOSE 摘；drag 跟手——onMouseMove 按
 * LocalData.rollCollection.scrollRect 的位移差平移全部子件；
 * SHOW_WILD_STAGE/SHOW_FARM_STAGE 整层显隐并拨 MainData.Stage。
 * legacy/decompiled/Master2_v_142/scripts/mc/view/main/floating/FloatingLayer.as。
 *
 * PORT-NOTE(跨片依赖)：ClockOperateFloating（mc/view/farm/land，牧场地块
 * 片）与 MainData.UPDATE_ANIMAL_MATERIAL（mc/model 数据片）在本片开工时
 * 尚无签名面——按原样直引，签名面由所属片补全后编译链闭合（本轮并行片
 * 既定做法，FRequest 直引 MainCommand.showWin 同款）。
 */
@:keep
class FloatingLayer extends Sprite {
	// FloatingLayer.as:17-21（left/top 原文 Number 未赋初值——AS3 默认 NaN，
	// Haxe Float 零初始化会成 0.0，显式 NaN（lessons #18 实现返工条）；实际
	// 读取前 init 必赋值，初值本不可观测，照抄保语义）
	private var left:Float = Math.NaN;
	private var drag:Bool = false;
	private var top:Float = Math.NaN;

	// FloatingLayer.as:23-29
	public function new() {
		super();
		mouseEnabled = false;
		mouseChildren = false;
		addEventListener(Event.ADDED_TO_STAGE, this.addedToStage);
	}

	// FloatingLayer.as:31-34
	private function onDown(param1:MouseEvent):Void {
		this.drag = true;
	}

	// FloatingLayer.as:36-49（逐子件挑 ClockOperateFloating 调 updatePos）
	private function updateAnimalSkin(param1:Event):Void {
		var _loc3_:DisplayObject = null;
		var _loc2_:Int = 0;
		while (_loc2_ < this.numChildren) {
			_loc3_ = this.getChildAt(_loc2_);
			if (Std.isOfType(_loc3_, ClockOperateFloating)) {
				cast(_loc3_, ClockOperateFloating).updatePos();
			}
			_loc2_++;
		}
	}

	// FloatingLayer.as:51-55
	private function addedToStage(param1:Event):Void {
		removeEventListener(Event.ADDED_TO_STAGE, this.addedToStage);
		this.init();
	}

	// FloatingLayer.as:57-66（全子件 visible=false + MainData.Stage="wild"）
	private function hideFloating(param1:Event):Void {
		var _loc2_:Int = 0;
		while (_loc2_ < this.numChildren) {
			this.getChildAt(_loc2_).visible = false;
			_loc2_++;
		}
		MainData.Stage = "wild";
	}

	// FloatingLayer.as:68-74
	private function floatingClose(param1:FloatingEvent):Void {
		if (contains(param1.floating)) {
			removeChild(param1.floating);
		}
	}

	// FloatingLayer.as:76-89
	private function init():Void {
		ViewControl.getInstance().addEventListener(FloatingEvent.FLOATING_OPEN, this.floatingOpen, false, 0, true);
		ViewControl.getInstance().addEventListener(FloatingEvent.FLOATING_CLOSE, this.floatingClose, false, 0, true);
		ViewControl.getInstance().addEventListener("addFoodOk", this.clearFloating, false, 0, true);
		this.left = LocalData.rollCollection.scrollRect.x;
		this.top = LocalData.rollCollection.scrollRect.y;
		this.stage.addEventListener(MouseEvent.MOUSE_DOWN, this.onDown);
		this.stage.addEventListener(MouseEvent.MOUSE_MOVE, this.onMouseMove);
		this.stage.addEventListener(MouseEvent.MOUSE_UP, this.onMouseUp);
		MData.getInstance().mainData.addEventListener(MainData.UPDATE_ANIMAL_MATERIAL, this.updateAnimalSkin, false, 0, true);
		ViewControl.getInstance().addEventListener(EvtAPI.SHOW_WILD_STAGE, this.hideFloating);
		ViewControl.getInstance().addEventListener(EvtAPI.SHOW_FARM_STAGE, this.showFloating);
	}

	// FloatingLayer.as:91-100（全子件 visible=true + MainData.Stage="farm"）
	private function showFloating(param1:Event):Void {
		var _loc2_:Int = 0;
		while (_loc2_ < this.numChildren) {
			this.getChildAt(_loc2_).visible = true;
			_loc2_++;
		}
		MainData.Stage = "farm";
	}

	// FloatingLayer.as:102-121
	private function onMouseMove(param1:MouseEvent):Void {
		var _loc2_:Float = Math.NaN;
		var _loc3_:Float = Math.NaN;
		var _loc4_:Int = 0;
		if (this.drag) {
			_loc2_ = LocalData.rollCollection.scrollRect.x - this.left;
			_loc3_ = LocalData.rollCollection.scrollRect.y - this.top;
			_loc4_ = 0;
			while (_loc4_ < this.numChildren) {
				this.getChildAt(_loc4_).x = this.getChildAt(_loc4_).x + -_loc2_;
				this.getChildAt(_loc4_).y = this.getChildAt(_loc4_).y + -_loc3_;
				_loc4_++;
			}
			this.left = LocalData.rollCollection.scrollRect.x;
			this.top = LocalData.rollCollection.scrollRect.y;
		}
	}

	// FloatingLayer.as:123-126
	private function onMouseUp(param1:MouseEvent):Void {
		this.drag = false;
	}

	// FloatingLayer.as:128-134（"addFoodOk" 时清全部飘字）
	private function clearFloating(param1:Event):Void {
		while (this.numChildren > 0) {
			removeChildAt(0);
		}
	}

	// FloatingLayer.as:136-144
	private function floatingOpen(param1:FloatingEvent):Void {
		param1.floating.start();
		addChild(param1.floating);
		if (MainData.Stage == "wild") {
			param1.floating.visible = false;
		}
	}
}
