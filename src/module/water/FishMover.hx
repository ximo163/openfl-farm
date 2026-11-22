package module.water;

import common.Consts;
import common.misc.Utils;
import entities.PoolFish;
import openfl.display.DisplayObject;
import openfl.display.DisplayObjectContainer;
import openfl.display.MovieClip;
import openfl.errors.ArgumentError;
import openfl.geom.Point;
import openfl.system.ApplicationDomain;

/**
 * module.water.FishMover —— FishMover.as 逐句对应（issue #37 功能 swf 翻译：
 * 鱼塘 pool_v_13 鱼群游动状态机）。每帧由 WaterPool.onEnterFrame 驱动
 * moveFrame()，SWIM/IDLE/ADJUST/CENTER/JUMP 五态 + FAST/NORMAL 两档速度
 * （帧驱动动画，CLAUDE.md 画面保真：帧驱动不许改时间驱动）；formatFishName
 * 是鱼动画符号命名约定（FishAnimationMgr.createFishMC 的键）。
 * AS3 实例 const（FAST_SPEED 等）按 CLAUDE.md 映射译 static final。
 */
class FishMover {
	// FishMover.as:15
	private var _cdt:Int = 0;

	// FishMover.as:17（AS3 实例 const → static final，CLAUDE.md 映射）
	static final FAST_SPEED:Float = 1.2;

	// FishMover.as:19
	private var _nextThinkingTime:Int = 0;

	// FishMover.as:21
	private var _status:Int = 0;

	// FishMover.as:23
	private var _state:String;

	// FishMover.as:25
	static final FAST_DURATION:UInt = 2;

	// FishMover.as:27
	static final IDLE_DURATION:UInt = 8;

	// FishMover.as:29
	private var _frameDuration:Int = 0;

	// FishMover.as:31
	private var _step:Int = 0;

	// FishMover.as:33
	static final BRAKE_ACC:Float = 0.03;

	// FishMover.as:35
	private var _mc:MovieClip;

	// FishMover.as:37
	private var _fish:PoolFish;

	// FishMover.as:39
	private var _spawnPos:Point;

	// FishMover.as:41
	private var _velocity:Point;

	// FishMover.as:43
	private var _acc:Point;

	// FishMover.as:45
	static final NORMAL_SPEED:Float = 0.75;

	// FishMover.as:47
	private var _waterPool:WaterPool;

	// FishMover.as:49
	static final JUMP_SPEED:Float = 0;

	// FishMover.as:51
	static final FAST:UInt = 1;

	// FishMover.as:53
	private var _dir:Int = 0;

	// FishMover.as:55
	static final NORMAL:UInt = 2;

	// FishMover.as:57
	static final NORMAL_DURATION:UInt = 4;

	// FishMover.as:59
	static final MAX_SPEED:Float = 1.4;

	// FishMover.as:61
	private var _corner:Int = 0;

	// FishMover.as:63
	static final ADJUST_SPEED:Float = 0.4;

	// FishMover.as:65
	private var _checkLoading:Bool = false;

	// FishMover.as:67
	private var _wps:Array<Dynamic>;

	// FishMover.as:69
	static final MAX_STEP:UInt = 110;

	// FishMover.as:71-90
	public function new(param1:WaterPool, param2:PoolFish) {
		this._waterPool = param1;
		this._fish = param2;
		this._state = "SWIM";
		this._dir = -1;
		this._status = NORMAL;
		this._frameDuration = NORMAL_DURATION;
		this._step = 0;
		this._nextThinkingTime = 0;
		this._cdt = 0;
		this._corner = 0;
		this._mc = null;
		this._wps = null;
		this._spawnPos = null;
		this._checkLoading = true;
		this._velocity = new Point();
		this._acc = new Point();
	}

	// FishMover.as:92-105
	public function stop():Void {
		this._state = "IDLE";
		this._velocity.x = this._velocity.y = 0;
		this._acc.x = this._acc.y = 0;
		this._frameDuration = IDLE_DURATION;
		this._status = NORMAL;
		this._step = 0;
		this._nextThinkingTime = 99999999;
		if (this._mc != null) {
			Utils.stroke(this._mc);
		}
	}

	// FishMover.as:107-135。`int` 局部接 Number 乘积 → Std.int 截断
	private function adjustPosition():Void {
		if (this._mc == null) {
			return;
		}
		var _loc1_:Point = this._waterPool.calcCenterVector(this._mc);
		var _loc2_:Int = Std.int(3 * _loc1_.x);
		var _loc3_:Int = Std.int(3 * _loc1_.y);
		var _loc4_:Int = 0;
		var _loc5_:Int = 0;
		var _loc6_:Point = new Point(this._mc.width * 0.5, this._mc.height * 0.5);
		_loc6_ = this._mc.localToGlobal(_loc6_);
		var _loc7_:Int = 20;
		while (_loc7_ > 0) {
			_loc6_.x += _loc2_;
			_loc6_.y += _loc3_;
			_loc4_ += _loc2_;
			_loc5_ += _loc3_;
			if (this._waterPool.cdWithPoolLimit(_loc6_) == true) {
				this._mc.x += _loc4_;
				this._mc.y += _loc5_;
				break;
			}
			_loc7_--;
		}
	}

	// FishMover.as:137-144
	public var x(get, never):Float;

	private function get_x():Float {
		if (this._mc == null) {
			return 0;
		}
		return this._mc.x;
	}

	// FishMover.as:146-153
	public function localToGlobal(param1:Point):Point {
		if (this._mc == null || param1 == null) {
			return param1;
		}
		return this._mc.localToGlobal(param1);
	}

	// FishMover.as:155-199。`uint _loc6_ = width*0.5` → Std.int 截断
	private function spawn(param1:Bool):MovieClip {
		var _loc5_:DisplayObject = null;
		var _loc6_:UInt = 0;
		var _loc7_:Float = Math.NaN;
		var _loc2_:Bool = false;
		if (this._dir == 1 || this._dir == 3) {
			_loc2_ = true;
			this._dir = (this._dir + 1) % 4;
		}
		var _loc3_:String = this.formatFishName(this._state, this._fish._type, this._fish.level, this._dir);
		var _loc4_:MovieClip = FishAnimationMgr.getInstance().createFishMC(_loc3_);
		if (_loc4_ == null) {
			return null;
		}
		if (_loc2_ == true) {
			_loc4_.scaleX = -1;
		}
		if (param1 == true) {
			if (this._spawnPos != null) {
				_loc4_.x = this._spawnPos.x;
				_loc4_.y = this._spawnPos.y;
				this._spawnPos = null;
			} else {
				_loc5_ = this._waterPool.randSpawnCircle();
				if (_loc5_ != null) {
					_loc6_ = Std.int(_loc5_.width * 0.5);
					_loc7_ = Math.random() * 360 * Math.PI / 180;
					_loc4_.x = _loc5_.x + _loc6_ + Math.sin(_loc7_) * _loc6_ - _loc4_.scaleX * _loc4_.width * 0.5;
					_loc4_.y = _loc5_.y + _loc6_ + Math.cos(_loc7_) * _loc6_ - _loc4_.height * 0.5;
				}
			}
		}
		_loc4_.gotoAndStop(1);
		_loc4_.cacheAsBitmap = true;
		return _loc4_;
	}

	// FishMover.as:201-204
	public var loaded(get, never):Bool;

	private function get_loaded():Bool {
		return this._mc != null;
	}

	// FishMover.as:206-213
	public var hFlip(get, never):Bool;

	private function get_hFlip():Bool {
		if (this._mc == null) {
			return false;
		}
		return this._mc.scaleX < 0 ? true : false;
	}

	// FishMover.as:215-218
	private var fishContainer(get, never):DisplayObjectContainer;

	private function get_fishContainer():DisplayObjectContainer {
		return this._waterPool.fishContainer;
	}

	// FishMover.as:220-224
	public function grow():Void {
		this.changeFish();
		this.playFeedEffect();
	}

	// FishMover.as:226-233
	private function next():Void {
		++this._step;
		if (this._step >= this._nextThinkingTime) {
			this.think();
		}
	}

	// FishMover.as:235-242
	public function continueMove():Void {
		if (this._mc != null) {
			Utils.unStroke(this._mc);
		}
		this.think();
	}

	// FishMover.as:244-260
	private function formatFishName(param1:String, param2:Int, param3:Int, param4:Int):String {
		var _loc5_:String = "S";
		if (param1 == "IDLE" || param1 == "SWIM" || param1 == "ADJUST") {
			_loc5_ = "S";
		}
		if (param1 == "JUMP") {
			_loc5_ = "J";
		}
		if (param3 > 2) {
			param3 = 2;
		}
		return "F" + _loc5_ + "_" + Utils.formatNumber(param2, 2) + "_" + param3 + "_" + param4;
	}

	// FishMover.as:262-308
	public function moveFrame():Void {
		if (this._mc == null && this._checkLoading == true) {
			this.next();
			return;
		}
		--this._frameDuration;
		if (this._frameDuration < 0) {
			this._frameDuration = this._status == FAST ? (FAST_DURATION) : (NORMAL_DURATION);
			if (this._state == "IDLE" || this._state == "ADJUST") {
				this.playFishAnimation(false, true);
				this._frameDuration = IDLE_DURATION;
			} else if (this._state == "SWIM" || this._state == "CENTER") {
				this.checkCD();
				this.playFishAnimation(this._status == FAST, true);
			} else if (this._state == "JUMP") {
				this.playFishAnimation(true, false);
			}
		}
		if (this._state == "SWIM") {
			this.move(this._velocity, null);
		} else if (this._state == "ADJUST") {
			this.move(this._velocity, null);
		} else if (this._state == "CENTER") {
			this.move(this._velocity, null);
		} else if (this._state == "IDLE") {
			this.move(this._velocity, this._acc, true);
		} else if (this._state == "JUMP") {}
		this.next();
	}

	// FishMover.as:310-316
	private function slowdown():Void {
		var _loc1_:Point = this._waterPool.calcNormalizedVelocity((this._dir + 2) % 4);
		this._acc.x = _loc1_.x * BRAKE_ACC;
		this._acc.y = _loc1_.y * BRAKE_ACC;
		trace("Slow down at acc : " + this._acc.toString());
	}

	// FishMover.as:318-339。注意 :333-336 原版对 `_loc1_ != null && _mc == null`
	// 分支先 `this._mc = _loc1_; playWaterEffect(-1)` 再 :336 无条件重赋——
	// 结果一致，照抄
	private function changeFish():Void {
		var _loc1_:MovieClip = this.spawn(this._mc == null);
		if (_loc1_ != null) {
			if (this._mc != null) {
				_loc1_.x = this._mc.x;
				_loc1_.y = this._mc.y;
				_loc1_.x -= (_loc1_.scaleX * _loc1_.width - this._mc.scaleX * this._mc.width) * 0.5;
				_loc1_.y -= (_loc1_.scaleY * _loc1_.height - this._mc.scaleY * this._mc.height) * 0.5;
				this.removeFish();
			} else {
				this._mc = _loc1_;
				this.playWaterEffect(-1);
			}
			this._mc = _loc1_;
			this.fishContainer.addChild(this._mc);
		}
	}

	// FishMover.as:341-354
	public var fish(get, set):PoolFish;

	private function set_fish(param1:PoolFish):PoolFish {
		var _loc2_:DisplayObject = null;
		if (this._mc != null) {
			_loc2_ = this._mc.getChildByName("__MATURE__");
			if (_loc2_ != null) {
				this._mc.removeChild(_loc2_);
			}
		}
		this.removeFish();
		this._fish = param1;
		return this._fish;
	}

	// FishMover.as:356-375
	private function playFeedEffect():Void {
		if (this._mc == null || this._mc.parent == null) {
			return;
		}
		var _loc1_:MovieClip = cast(Utils.getMaterial("FishFoodEffect"), MovieClip);
		if (_loc1_ == null) {
			return;
		}
		var _loc2_:Point = new Point(this._mc.x, this._mc.y);
		_loc2_.x += this._mc.width * 0.5 * this._mc.scaleX;
		_loc2_.y += this._mc.height * 0.5 * this._mc.scaleY;
		_loc1_.x = _loc2_.x;
		_loc1_.y = _loc2_.y;
		_loc1_.scaleX = _loc1_.scaleY = 0.5;
		this._mc.parent.addChild(_loc1_);
		_loc1_.gotoAndPlay(1);
	}

	// FishMover.as:377-391
	private function playWaterEffect(param1:Int):Void {
		var _loc2_:Point = null;
		if (this._mc == null) {
			return;
		}
		if (this._state == "SWIM" && param1 == NORMAL && this._status == FAST) {
			_loc2_ = new Point(this._mc.x, this._mc.y);
			_loc2_.x += this._mc.width * 0.5 * this._mc.scaleX;
			_loc2_.y += this._mc.height * 0.5 * this._mc.scaleY;
			this._waterPool.showWaterFlower(_loc2_, this._dir);
		}
	}

	// FishMover.as:393-405
	private function checkResource():Bool {
		if (this._mc != null) {
			return true;
		}
		if (this._fish == null) {
			return false;
		}
		var _loc1_:String = this.formatFishName("SWIM", this._fish._type, this._fish.level, 0);
		return ApplicationDomain.currentDomain.hasDefinition(_loc1_);
	}

	// FishMover.as:407-410
	public var spawnPos(never, set):Point;

	private function set_spawnPos(param1:Point):Point {
		this._spawnPos = param1;
		return this._spawnPos;
	}

	// FishMover.as:412-423
	private function equalZeroSpeed(param1:Point):Bool {
		if (param1 == null) {
			return true;
		}
		if (param1.x * param1.x + param1.y * param1.y <= 0.05) {
			return true;
		}
		return false;
	}

	// FishMover.as:425-463。`new Array(1)` = 1 空槽 → [null]
	private function towardCenter():Bool {
		if (this._mc == null) {
			return false;
		}
		var _loc1_:Int = this._waterPool.atCorner(this._mc.x, this._mc.y);
		if (_loc1_ != -1) {
			++this._corner;
			if (this._corner >= 3) {
				this._corner = 0;
				this._state = "CENTER";
				this._frameDuration = IDLE_DURATION;
				this._wps = [null];
				if (_loc1_ == 0 || _loc1_ == 3) {
					this._dir = 1;
					this._wps[0] = _loc1_ == 0 ? 2 : 0;
				} else {
					this._dir = 3;
					this._wps[0] = _loc1_ == 1 ? 2 : 0;
				}
				this.updateVelocity();
				this.changeFish();
				trace("towards center at dir : " + this._dir);
				return true;
			}
		} else {
			this._corner = 0;
			this._wps = null;
		}
		return false;
	}

	// FishMover.as:465-481
	private function changeDir(param1:Int):Void {
		if (this._dir == -1) {
			this._dir = this.randomDir();
		} else {
			if (param1 == -1) {
				param1 = this.randomDir();
			}
			this._dir += param1;
			this._dir %= 4;
		}
		this.updateVelocity();
	}

	// FishMover.as:483-490
	private function canJump(param1:Int):Bool {
		if (this._mc == null || this._fish.level < Consts.FISH_MAX_LEVEL - 1) {
			return false;
		}
		return true;
	}

	// FishMover.as:492-502
	public function hitTest(param1:Float, param2:Float):Bool {
		if (this._mc != null) {
			if (this._mc.hitTestPoint(param1, param2, false) == true) {
				return true;
			}
		}
		return false;
	}

	// FishMover.as:504-538
	private function updateVelocity():Void {
		var _loc1_:Float = Math.NaN;
		var _loc2_:Int = 0;
		var _loc3_:Point = null;
		if (this._state != "IDLE") {
			if (this._dir == 1 || this._dir == 3) {
				this._status = NORMAL;
				this._frameDuration = NORMAL_DURATION;
			}
			_loc1_ = this._status == FAST ? FAST_SPEED : NORMAL_SPEED;
			if (this._state == "JUMP") {
				_loc1_ = JUMP_SPEED;
			}
			_loc2_ = this._fish.poolSize;
			if (this._fish.poolSize == 2) {
				_loc1_ *= 0.95;
			} else if (this._fish.poolSize == 3) {
				_loc1_ *= 0.9;
			} else if (this._fish.poolSize > 3) {
				_loc1_ *= 0.85;
			}
			_loc3_ = this._waterPool.calcNormalizedVelocity(this._dir);
			this._velocity.x = _loc3_.x * _loc1_;
			this._velocity.y = _loc3_.y * _loc1_;
		}
	}

	// FishMover.as:540-578
	private function playFishAnimation(param1:Bool, param2:Bool):Void {
		if (this._mc == null) {
			return;
		}
		var _loc3_:Int = this._mc.currentFrame;
		if (param1 == false) {
			if (_loc3_ == 1) {
				this._mc.gotoAndStop(2);
			} else if (_loc3_ == 2) {
				this._mc.gotoAndStop(5);
			} else if (_loc3_ == 5) {
				this._mc.gotoAndStop(6);
			} else {
				this._mc.gotoAndStop(1);
			}
		} else if (_loc3_ + 1 <= this._mc.totalFrames) {
			this._mc.gotoAndStop(_loc3_ + 1);
		} else if (param2) {
			this._mc.gotoAndStop(1);
		} else {
			this._mc.stop();
		}
	}

	// FishMover.as:580-612。Number→int 赋值 Std.int 截断
	private function adjustState():Void {
		if (this._mc == null) {
			return;
		}
		this._cdt = 0;
		this._state = "ADJUST";
		this._status = NORMAL;
		this._frameDuration = IDLE_DURATION;
		this._step = 0;
		this._nextThinkingTime = Std.int((Math.random() + 0.5) * MAX_STEP * 0.5);
		var _loc1_:Point = this._waterPool.calcCenterVector(this._mc);
		if (_loc1_.x < 0 && _loc1_.y > 0) {
			this._dir = 2;
		} else if (_loc1_.x <= 0 && _loc1_.y <= 0) {
			this._dir = 3;
		} else if (_loc1_.x >= 0 && _loc1_.y <= 0) {
			this._dir = 0;
		} else if (_loc1_.x >= 0 && _loc1_.y >= 0) {
			this._dir = 1;
		}
		this._velocity.x = _loc1_.x * ADJUST_SPEED;
		this._velocity.y = _loc1_.y * ADJUST_SPEED;
		this.changeFish();
	}

	// FishMover.as:614-621
	private function randomDir():Int {
		if (Math.random() < 0.6) {
			return Math.random() < 0.5 ? 0 : 2;
		}
		return Math.random() < 0.5 ? 1 : 3;
	}

	// FishMover.as:623-626
	private function get_fish():PoolFish {
		return this._fish;
	}

	// FishMover.as:628-666。PORT-NOTE: :648 原版限速判断把 `param1.y` 写成了
	// 第二个 `param1.x`（`x*x + x*x`）——数字照抄不修，只在注释留痕
	private function move(param1:Point, param2:Point = null, param3:Bool = true):Void {
		if (this._mc == null || param1 == null) {
			return;
		}
		if (param2 != null && param3 == false) {
			throw new ArgumentError("Can NOT support speed up!");
		}
		if (param2 == null) {
			this._mc.x += param1.x;
			this._mc.y += param1.y;
		} else if (param2.x != 0 && param2.y != 0) {
			param1.x += param2.x;
			param1.y += param2.y;
			trace("Accellerated velocity : " + param1.x + " , " + param1.y);
			if (Math.sqrt(param1.x * param1.x + param1.x * param1.x) >= MAX_SPEED) {
				param1.x -= param2.x;
				param1.y -= param2.y;
				param2.x = 0;
				param2.y = 0;
			} else if (this.equalZeroSpeed(param1) == false) {
				this._mc.x += param1.x;
				this._mc.y += param1.y;
			} else {
				param2.x = 0;
				param2.y = 0;
			}
		}
	}

	// FishMover.as:668-703
	private function checkCD():Void {
		if (this._mc == null) {
			return;
		}
		var _loc1_:Point = new Point(this._mc.width * 0.5, this._mc.height * 0.5);
		_loc1_ = this._mc.localToGlobal(_loc1_);
		_loc1_.x += this._velocity.x;
		_loc1_.y += this._velocity.y;
		if (this._waterPool.cdWithPoolLimit(_loc1_) == false) {
			++this._cdt;
			if (this._cdt >= 3) {
				this.adjustState();
			} else {
				if (Math.random() < 0.5) {
					this.changeDir(2);
				} else {
					this.changeDir(-1);
				}
				this.changeFish();
				this.adjustPosition();
			}
		} else if (this._cdt > 0) {
			--this._cdt;
		}
	}

	// FishMover.as:705-808。Number→int 赋值 Std.int 截断
	public function think():Void {
		if (this._fish == null) {
			return;
		}
		if (this.checkResource() == false) {
			this._step = 0;
			this._nextThinkingTime = 4;
			this._checkLoading = true;
			return;
		}
		this._checkLoading = false;
		var _loc1_:String = this._state;
		var _loc2_:Int = this._status;
		if (_loc1_ == "CENTER") {
			if (this._wps != null && this._wps.length > 0) {
				this._dir = this._wps.pop();
				this._frameDuration = IDLE_DURATION;
				this._status = NORMAL;
				this._nextThinkingTime = Std.int((Math.random() + 3) * MAX_STEP);
				this.updateVelocity();
				this.changeFish();
				return;
			}
			this._corner = 0;
			this._wps = null;
		}
		var _loc3_:Float = Math.random();
		if (_loc3_ < 0.7) {
			this._state = "SWIM";
		} else if (_loc3_ < 0.85) {
			this._state = "IDLE";
		} else {
			this._state = "JUMP";
		}
		if (this._state == "JUMP" && this._fish.level < Consts.FISH_MAX_LEVEL - 1) {
			this._state = "SWIM";
		}
		this._cdt = 0;
		this._dir = 2;
		_loc3_ = Math.random();
		this._status = _loc3_ < 0.5 ? (FAST) : (NORMAL);
		this._velocity.x = this._velocity.y = 0;
		this._acc.x = this._acc.y = 0;
		this._frameDuration = this._status == FAST ? (FAST_DURATION) : (NORMAL_DURATION);
		this._step = 0;
		this._nextThinkingTime = Std.int((Math.random() + 0.5) * MAX_STEP);
		if (this._state == "IDLE") {
			this._frameDuration = IDLE_DURATION;
			this._status = NORMAL;
			_loc3_ = Math.random();
			if (_loc3_ < 0.5) {
				this._dir = this.randomDir();
			}
			this.changeFish();
			if (_loc1_ == "SWIM") {
				this.slowdown();
			}
		} else {
			if (this.towardCenter() == true) {
				return;
			}
			if (this._state == "JUMP") {
				this._dir = 2;
			} else {
				_loc3_ = Math.random();
				if (_loc3_ < 0.5) {
					this.changeDir(-1);
				}
			}
			this.changeFish();
			if (this._mc != null && this.canJump(this._dir) == false) {
				this._state = "SWIM";
			}
			if (this._state == "JUMP") {
				this._status = NORMAL;
				this._frameDuration = NORMAL_DURATION;
				this._nextThinkingTime = this._frameDuration * this._mc.totalFrames + 1;
			}
			this.playWaterEffect(_loc2_);
		}
	}

	// FishMover.as:810-817
	public var y(get, never):Float;

	private function get_y():Float {
		if (this._mc == null) {
			return 0;
		}
		return this._mc.y;
	}

	// FishMover.as:819-831
	private function removeFish():Void {
		if (this._mc == null) {
			return;
		}
		if (this.fishContainer.contains(this._mc) == true) {
			Utils.unStroke(this._mc);
			FishAnimationMgr.getInstance().destroyMC(this._mc);
		}
		this._mc = null;
	}
}
