package module.water;

import common.Consts;
import common.misc.Utils;
import entities.PoolFish;
import openfl.display.MovieClip;
import openfl.errors.Error;
import openfl.geom.Point;

/**
 * module.water.FishMover —— issue #37 write-tests 签名 stub
 * （FishMover.as 834 loc，pool_v_13 鱼群游动状态机整类翻译）。
 * 每帧由 WaterPool.onEnterFrame 驱动 moveFrame()，SWIM/IDLE/ADJUST/CENTER/
 * JUMP 五态 + FAST/NORMAL 两档速度（帧驱动动画，CLAUDE.md 画面保真：帧驱动
 * 不许改时间驱动）；formatFishName 是鱼动画符号命名约定（FishAnimationMgr
 * createFishMC 的键）。
 * 字段与方法签名照抄 AS3，体 throw not implemented；AS3 实例 const
 * （FAST_SPEED 等）按 CLAUDE.md 映射译 static final；构造器零位（:76-89 的
 * _state "SWIM"、_dir -1、_status NORMAL、_frameDuration NORMAL_DURATION、
 * _checkLoading true）是本类实现内容，stub 不写（ShopModel stub 同口径）。
 * _waterPool 在构造期只存引用不解引用——测试传 null 即可覆盖纯分支。
 */
class FishMover {
	// FishMover.as:15
	private var _cdt:Int;

	// FishMover.as:17（AS3 实例 const → static final，CLAUDE.md 映射）
	static final FAST_SPEED:Float = 1.2;

	// FishMover.as:19
	private var _nextThinkingTime:Int;

	// FishMover.as:21
	private var _status:Int;

	// FishMover.as:23
	private var _state:String;

	// FishMover.as:25
	static final FAST_DURATION:UInt = 2;

	// FishMover.as:27
	static final IDLE_DURATION:UInt = 8;

	// FishMover.as:29
	private var _frameDuration:Int;

	// FishMover.as:31
	private var _step:Int;

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
	private var _dir:Int;

	// FishMover.as:55
	static final NORMAL:UInt = 2;

	// FishMover.as:57
	static final NORMAL_DURATION:UInt = 4;

	// FishMover.as:59
	static final MAX_SPEED:Float = 1.4;

	// FishMover.as:61
	private var _corner:Int;

	// FishMover.as:63
	static final ADJUST_SPEED:Float = 0.4;

	// FishMover.as:65
	private var _checkLoading:Bool;

	// FishMover.as:67
	private var _wps:Array<Dynamic>;

	// FishMover.as:69
	static final MAX_STEP:UInt = 110;

	// FishMover.as:71-90（构造器零位 :76-89 是实现内容，stub 只保可构造）
	public function new(param1:WaterPool, param2:PoolFish) {
		this._waterPool = param1;
		this._fish = param2;
	}

	// FishMover.as:92-105
	public function stop():Void {
		throw new Error("not implemented");
	}

	// FishMover.as:107-135
	private function adjustPosition():Void {
		throw new Error("not implemented");
	}

	// FishMover.as:137-144
	public var x(get, never):Float;

	private function get_x():Float {
		throw new Error("not implemented");
	}

	// FishMover.as:146-153
	public function localToGlobal(param1:Point):Point {
		throw new Error("not implemented");
	}

	// FishMover.as:155-199
	private function spawn(param1:Bool):MovieClip {
		throw new Error("not implemented");
	}

	// FishMover.as:201-204
	public var loaded(get, never):Bool;

	private function get_loaded():Bool {
		throw new Error("not implemented");
	}

	// FishMover.as:206-213
	public var hFlip(get, never):Bool;

	private function get_hFlip():Bool {
		throw new Error("not implemented");
	}

	// FishMover.as:215-218
	private var fishContainer(get, never):Dynamic;

	private function get_fishContainer():Dynamic {
		throw new Error("not implemented");
	}

	// FishMover.as:220-224
	public function grow():Void {
		throw new Error("not implemented");
	}

	// FishMover.as:226-233
	private function next():Void {
		throw new Error("not implemented");
	}

	// FishMover.as:235-242
	public function continueMove():Void {
		throw new Error("not implemented");
	}

	// FishMover.as:244-260
	private function formatFishName(param1:String, param2:Int, param3:Int, param4:Int):String {
		throw new Error("not implemented");
	}

	// FishMover.as:262-308
	public function moveFrame():Void {
		throw new Error("not implemented");
	}

	// FishMover.as:310-316
	private function slowdown():Void {
		throw new Error("not implemented");
	}

	// FishMover.as:318-339
	private function changeFish():Void {
		throw new Error("not implemented");
	}

	// FishMover.as:341-354 + :623-626（get/set 对）
	public var fish(get, set):PoolFish;

	private function get_fish():PoolFish {
		throw new Error("not implemented");
	}

	private function set_fish(param1:PoolFish):PoolFish {
		throw new Error("not implemented");
	}

	// FishMover.as:356-375
	private function playFeedEffect():Void {
		throw new Error("not implemented");
	}

	// FishMover.as:377-391
	private function playWaterEffect(param1:Int):Void {
		throw new Error("not implemented");
	}

	// FishMover.as:393-405
	private function checkResource():Bool {
		throw new Error("not implemented");
	}

	// FishMover.as:407-410
	public var spawnPos(never, set):Point;

	private function set_spawnPos(param1:Point):Point {
		throw new Error("not implemented");
	}

	// FishMover.as:412-423
	private function equalZeroSpeed(param1:Point):Bool {
		throw new Error("not implemented");
	}

	// FishMover.as:425-463
	private function towardCenter():Bool {
		throw new Error("not implemented");
	}

	// FishMover.as:465-481
	private function changeDir(param1:Int):Void {
		throw new Error("not implemented");
	}

	// FishMover.as:483-490
	private function canJump(param1:Int):Bool {
		throw new Error("not implemented");
	}

	// FishMover.as:492-502
	public function hitTest(param1:Float, param2:Float):Bool {
		throw new Error("not implemented");
	}

	// FishMover.as:504-538
	private function updateVelocity():Void {
		throw new Error("not implemented");
	}

	// FishMover.as:540-578
	private function playFishAnimation(param1:Bool, param2:Bool):Void {
		throw new Error("not implemented");
	}

	// FishMover.as:580-612
	private function adjustState():Void {
		throw new Error("not implemented");
	}

	// FishMover.as:614-621
	private function randomDir():Int {
		throw new Error("not implemented");
	}

	// FishMover.as:628-666
	private function move(param1:Point, param2:Point = null, param3:Bool = true):Void {
		throw new Error("not implemented");
	}

	// FishMover.as:668-703
	private function checkCD():Void {
		throw new Error("not implemented");
	}

	// FishMover.as:705-808
	public function think():Void {
		throw new Error("not implemented");
	}

	// FishMover.as:810-817
	public var y(get, never):Float;

	private function get_y():Float {
		throw new Error("not implemented");
	}

	// FishMover.as:819-831
	private function removeFish():Void {
		throw new Error("not implemented");
	}
}
