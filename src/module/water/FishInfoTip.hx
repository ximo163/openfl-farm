package module.water;

import common.Consts;
import common.Session;
import common.misc.Utils;
import entities.PoolFish;
import openfl.display.DisplayObjectContainer;
import openfl.display.MovieClip;
import openfl.display.Sprite;
import openfl.events.TimerEvent;
import openfl.text.TextField;
import openfl.utils.Timer;
import shim.As3;

/**
 * module.water.FishInfoTip —— FishInfoTip.as 逐句对应（issue #37 功能 swf
 * 翻译：鱼塘 pool_v_13 鱼详情浮签）。素材 MCFishTip：stepText 名称、
 * growText 生长文案、growBar 进度条（120px 满）；左上角 32px 鱼迷你动画
 * （FishAnimationMgr 复用池）；1000ms Timer 每秒刷剩余时间。
 * `_tip["growBar"]` 等时间轴具名子件按 CLAUDE.md 动态属性分流走
 * As3.childOf + cast（真类型写真属性）。
 */
class FishInfoTip extends Sprite {
	// FishInfoTip.as:16
	private var _container:DisplayObjectContainer;

	// FishInfoTip.as:18
	private var _timer:Timer;

	// FishInfoTip.as:20
	private var _leftTime:Int = 0;

	// FishInfoTip.as:22
	private var _mc:MovieClip;

	// FishInfoTip.as:24
	private var _fish:PoolFish;

	// FishInfoTip.as:26
	private var _tip:MovieClip;

	// FishInfoTip.as:28-40
	public function new(param1:DisplayObjectContainer) {
		super();
		this._tip = cast(Utils.getMaterial("MCFishTip"), MovieClip);
		if (this._tip != null) {
			addChild(this._tip);
		}
		this._container = param1;
		this._mc = null;
		this._fish = null;
		this._leftTime = 0;
	}

	// FishInfoTip.as:42-105。leftTime[0] 总秒/[1] 周期秒；Number→int 赋值
	// Std.int 截断
	private function calcLeftTime():String {
		if (this._fish == null) {
			return "";
		}
		var _loc1_:Int = this._fish.level;
		var _loc2_:String = "";
		if (_loc1_ == 0) {
			_loc2_ = "鱼苗期(";
		} else if (_loc1_ == 1) {
			_loc2_ = "幼鱼期(";
		} else if (_loc1_ == 2) {
			_loc2_ = "成熟期(";
		}
		var _loc3_:Array<Dynamic> = this._fish.leftTime;
		if (_loc3_ == null || _loc3_.length == 0) {
			return _loc2_ + ")";
		}
		var _loc4_:Int = Std.int(As3.floatOf(_loc3_[0]) / 3600);
		var _loc5_:Int = Std.int((As3.floatOf(_loc3_[0]) - _loc4_ * 3600) / 60);
		var _loc6_:Int = Std.int(As3.floatOf(_loc3_[0])) % 60;
		if (_loc4_ > 0) {
			_loc2_ += _loc4_ + "小时";
		}
		if (_loc5_ > 0) {
			_loc2_ += _loc5_ + "分钟";
		}
		if (_loc4_ == 0 && _loc6_ >= 0) {
			_loc2_ += _loc6_ + "秒";
		}
		if (_loc1_ == 0) {
			_loc2_ += "至幼鱼期)";
		} else if (_loc1_ == 1) {
			_loc2_ += "至成熟期)";
		} else if (_loc1_ == 2) {
			_loc2_ += "至收获期)";
		}
		var _loc7_:Float = 120 * (1 - As3.floatOf(_loc3_[0]) / As3.floatOf(_loc3_[1]));
		if (_loc7_ > 120) {
			_loc7_ = 120;
		}
		if (_loc7_ < 0) {
			_loc7_ = 0;
		}
		cast(As3.childOf(this._tip, "growBar"), openfl.display.DisplayObject).width = _loc7_;
		return _loc2_;
	}

	// FishInfoTip.as:107-118
	private function removeFish():Void {
		if (this._mc != null) {
			if (this._tip != null && this._tip.contains(this._mc)) {
				this._tip.removeChild(this._mc);
			}
			FishAnimationMgr.getInstance().destroyMC(this._mc);
			this._mc = null;
		}
	}

	// FishInfoTip.as:120-132
	public function hide():Void {
		if (this._timer != null) {
			this._timer.stop();
		}
		this.removeFish();
		this._fish = null;
		if (parent != null) {
			parent.removeChild(this);
		}
	}

	// FishInfoTip.as:134-141
	public function update():Void {
		if (this._fish == null) {
			return;
		}
		this.calcOutput();
	}

	// FishInfoTip.as:143-159（与 FishMover.formatFishName 的差别：level 钳
	// 到 FISH_MAX_LEVEL-1）
	private function formatFishName(param1:String, param2:Int, param3:Int, param4:Int):String {
		var _loc5_:String = "S";
		if (param1 == "IDLE" || param1 == "SWIM" || param1 == "ADJUST") {
			_loc5_ = "S";
		}
		if (param1 == "JUMP") {
			_loc5_ = "J";
		}
		if (param3 >= Consts.FISH_MAX_LEVEL) {
			param3 = Consts.FISH_MAX_LEVEL - 1;
		}
		return "F" + _loc5_ + "_" + Utils.formatNumber(param2, 2) + "_" + param3 + "_" + param4;
	}

	// FishInfoTip.as:161-173
	private function calcOutput():String {
		if (this._fish == null) {
			return "";
		}
		if (this._fish._output == 0) {
			return "收获期(...)";
		}
		var _loc1_:String = "收获期(产";
		return _loc1_ + (this._fish._output + " 剩" + this._fish._left + ")");
	}

	// FishInfoTip.as:175-228。`parseFloat(hostId) as uint` → floatOf+intOf
	public function show(param1:PoolFish):Void {
		if (this._fish != null && this._fish._id == param1._id) {
			return;
		}
		this._fish = param1;
		if (param1 == null) {
			this.hide();
			return;
		}
		var _loc2_:String = param1.name;
		var _loc3_:Int = param1.level;
		var _loc4_:String = this.formatFishName("SWIM", param1._type, _loc3_, 2);
		var _loc5_:MovieClip = FishAnimationMgr.getInstance().createFishMC(_loc4_);
		if (_loc5_ == null) {
			return;
		}
		this.removeFish();
		_loc5_.gotoAndStop(1);
		_loc5_.scaleX = _loc5_.scaleY = 32 / _loc5_.width;
		_loc5_.x = 0;
		_loc5_.y = (12 - _loc5_.height) * 0.5;
		this._tip.addChild(_loc5_);
		this._mc = _loc5_;
		cast(As3.childOf(this._tip, "stepText"), TextField).text = _loc2_;
		var _loc6_:Array<Dynamic> = param1._thief;
		var _loc7_:UInt = As3.intOf(As3.floatOf(Session.getInstance().hostId));
		if (_loc6_ != null && _loc6_.indexOf(_loc7_) != -1) {
			cast(As3.childOf(this._tip, "stepText"), TextField).text += "(已捞取)";
		}
		if (_loc3_ == Consts.FISH_MAX_LEVEL) {
			cast(As3.childOf(this._tip, "growText"), TextField).text = this.calcOutput();
			cast(As3.childOf(this._tip, "growBar"), openfl.display.DisplayObject).width = 120;
		} else {
			cast(As3.childOf(this._tip, "growText"), TextField).text = this.calcLeftTime();
			if (this._timer == null) {
				this._timer = new Timer(1000);
				this._timer.addEventListener(TimerEvent.TIMER, this.onTimer, false, 0, true);
			}
			this._timer.start();
		}
		if (this._container != null) {
			this._container.addChild(this);
		}
	}

	// FishInfoTip.as:230-250
	private function onTimer(param1:TimerEvent):Void {
		if (this._fish == null || this._tip == null) {
			return;
		}
		var _loc2_:Int = this._fish.level;
		if (_loc2_ == Consts.FISH_MAX_LEVEL) {
			cast(As3.childOf(this._tip, "growText"), TextField).text = this.calcOutput();
			cast(As3.childOf(this._tip, "growBar"), openfl.display.DisplayObject).width = 120;
			if (this._timer != null) {
				this._timer.stop();
			}
		} else {
			cast(As3.childOf(this._tip, "growText"), TextField).text = this.calcLeftTime();
		}
	}
}
