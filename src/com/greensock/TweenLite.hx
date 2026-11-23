package com.greensock;

import com.greensock.core.PropTween;
import com.greensock.core.SimpleTimeline;
import com.greensock.core.TweenCore;
import openfl.display.DisplayObject;
import openfl.display.Shape;
import openfl.events.Event;
import openfl.utils.Dictionary;
import shim.As3;

/**
 * com.greensock.TweenLite —— TweenLite.as（506 loc）逐句对应。插值补间 +
 * ENTER_FRAME 帧驱动推进（issue #39 本体翻译，替换 #7 的「终态直写」stub）：
 * _shape 上挂的 updateAll 每帧推 rootTimeline（getTimer 秒轴）/rootFramesTimeline
 * （rootFrame 帧轴），renderTime 按 ease 算 ratio 沿 PropTween 链写目标属性，
 * 终点走 TweenCore.complete 派发 onComplete。core 三类（TweenCore/
 * SimpleTimeline/PropTween）复用 #28 真身。
 *
 * PORT-NOTE（ENTER_FRAME 心跳）：原版 _shape 不进显示列表、纯靠 AVM2 对所有
 * DisplayObject（含脱列）广播 ENTER_FRAME——openfl 9 的 DisplayObject.
 * addEventListener 对 ENTER_FRAME 等五种广播事件走 DisplayObject.
 * __broadcastEvents 注册表（Stage.__broadcastEvent 对 stage==null 的派发器
 * 照发），等价语义成立，照译 addEventListener 即得心跳。
 *
 * PORT-NOTE（静态表示）：AS3 `Dictionary` 按对象身份索引；openfl 的
 * Dictionary 抽象按型参选实现——K 写 Dynamic 会静默落到 StringMap（键被
 * Std.string 化，eval 实测对象键抛 Unexpected value/同内容对象串键），
 * masterList/fastEaseLookup 的键是显示对象/函数，必须型参成 {} 走
 * ObjectMap（overwrite 语义依赖身份键）。delayedCall 的目标是回调函数，
 * 函数引用作 ObjectMap 键同样成立（eval 实测）。
 *
 * PORT-NOTE（动态读写分流）：`target[property]` 的属性名是运行时数据
 * （:305 写、:399 读）。openfl 9 的 x/y/scaleX/scaleY/alpha/rotation 是
 * get/set 属性——Reflect 直写在静态目标不走 setter、js/eval 落影子字段
 * （CLAUDE.md「Dynamic 接收者的字段裸写」+ #8/#10 教训），按「openfl 真属性
 * → cast 真类型读写」分流进 getTargetNumber/setTargetProp；其余键（匿名
 * 对象目标、插件对象的 changeFactor）保持 Reflect 通道。
 *
 * PORT-NOTE（数值强制）：AS3 Number(null)=0、Number(undefined)=NaN，Haxe
 * Reflect 对缺位/置 null 都落 null——沿用仓库 As3.floatOf（null→NaN）口径，
 * 与 #28 TweenCore 一致；仅「字段存在且显式为 null」的读值有 0/NaN 差异，
 * 农场调用方补间的全是数值属性，不经过该支。
 */
@:keep
class TweenLite extends TweenCore {
	// TweenLite.as:12-20
	public static var rootTimeline:SimpleTimeline;

	public static var onPluginEvent:Dynamic;

	public static var rootFramesTimeline:SimpleTimeline;

	public static var overwriteManager:Dynamic;

	// 原版未初始化 Number 静态为 NaN（TweenCore 构造以此为未建标志），
	// Haxe 静态默认 0.0，显式置 NaN
	public static var rootFrame:Float = Math.NaN;

	// TweenLite.as:22
	public static final version:Float = 11.101;

	// TweenLite.as:24
	public static var plugins:Dynamic = {};

	// TweenLite.as:26（键身份约束见类头 PORT-NOTE）
	public static var fastEaseLookup:Dictionary<{}, Dynamic> = new Dictionary<{}, Dynamic>(false);

	// TweenLite.as:28
	public static var killDelayedCallsTo:Dynamic = TweenLite.killTweensOf;

	// TweenLite.as:30
	public static var defaultEase:Dynamic = TweenLite.easeOut;

	// TweenLite.as:32（键身份约束见类头 PORT-NOTE）
	public static var masterList:Dictionary<{}, Array<TweenLite>> = new Dictionary<{}, Array<TweenLite>>(false);

	// TweenLite.as:34（:137 的 ENTER_FRAME 监听在 initClass 里挂，心跳说明
	// 见类头 PORT-NOTE）
	private static var _shape:Shape = new Shape();

	// PORT-NOTE（平台差异垫片，非原版字段；issue #39 测试轮实证）：eval
	// 解释器上无初始化式的静态 Bool 读 null（js/cpp 静态零值 false）——
	// #28 译的 TweenCore._classInitted 守卫 `null == false` 在 eval 恒假，
	// 构造链进不了 initClass 分支，首个 SimpleTimeline 构造即崩在
	// `_loc3_.cachedTotalTime`（TweenCore.hx:81-91）。这里在静态初始化期
	// 把它归一到 AS3 Boolean 默认值 false（读经 Dynamic 判 null，静态目标
	// Bool 不可空），js/cpp 上是 no-op。更合适的家是 TweenCore.hx 给
	// _classInitted 显式 `= false`——超出本 issue 边界（只改本文件与
	// test/），留维护者采纳；采纳后本垫片与字段可删（deviations 候选）。
	private static var _evalClassInittedNormalize:Bool = normalizeClassInitted();

	@:access(com.greensock.core.TweenCore._classInitted)
	private static function normalizeClassInitted():Bool {
		var cur:Dynamic = TweenCore._classInitted;
		if (cur == null) {
			TweenCore._classInitted = false;
			return true;
		}
		return false;
	}

	// TweenLite.as:36-70（保留属性字面量表照抄：init for-in 的过滤依据）
	private static var _reservedProps:Dynamic = {
		"ease": 1,
		"delay": 1,
		"overwrite": 1,
		"onComplete": 1,
		"onCompleteParams": 1,
		"useFrames": 1,
		"runBackwards": 1,
		"startAt": 1,
		"onUpdate": 1,
		"onUpdateParams": 1,
		"roundProps": 1,
		"onStart": 1,
		"onStartParams": 1,
		"onReverseComplete": 1,
		"onReverseCompleteParams": 1,
		"onRepeat": 1,
		"onRepeatParams": 1,
		"proxiedEase": 1,
		"easeParams": 1,
		"yoyo": 1,
		"onCompleteListener": 1,
		"onUpdateListener": 1,
		"onStartListener": 1,
		"onReverseCompleteListener": 1,
		"onRepeatListener": 1,
		"orientToBezier": 1,
		"timeScale": 1,
		"immediateRender": 1,
		"repeat": 1,
		"repeatDelay": 1,
		"timeline": 1,
		"data": 1,
		"paused": 1
	};

	// TweenLite.as:72-88
	private var _hasPlugins:Bool;

	public var propTweenLookup:Dynamic;

	public var cachedPT1:PropTween;

	private var _overwrite:UInt;

	private var _ease:Dynamic;

	public var target:Dynamic;

	public var ratio:Float = 0;

	private var _overwrittenProps:Dynamic;

	private var _notifyPluginsOfEnabled:Bool;

	// TweenLite.as:90-126
	public function new(param1:Dynamic, param2:Float, param3:Dynamic) {
		var _loc5_:TweenLite = null;
		super(param2, param3);
		this.target = param1;
		if (Std.isOfType(this.target, TweenCore) && Reflect.hasField(this.vars, "timeScale")) {
			this.cachedTimeScale = 1;
		}
		this.propTweenLookup = {};
		this._ease = defaultEase;
		// :101（&& 比 || 紧：缺 overwrite 键 || （管理器未启用 && 值 >1）→ 取
		// 管理器 mode，否则取显式值）
		this._overwrite = !Reflect.hasField(param3, "overwrite")
			|| !As3.truthy(Reflect.field(overwriteManager, "enabled")) && As3.floatOf(Reflect.field(param3, "overwrite")) > 1
				? As3.intOf(Reflect.field(overwriteManager, "mode"))
				: As3.intOf(Reflect.field(param3, "overwrite"));
		var _loc4_:Array<TweenLite> = masterList.get(param1);
		if (_loc4_ == null) {
			masterList.set(param1, [this]);
		} else if (this._overwrite == 1) {
			for (_loc5_ in _loc4_) {
				if (!As3.truthy(_loc5_.gc)) {
					_loc5_.setEnabled(false, false);
				}
			}
			masterList.set(param1, [this]);
		} else {
			_loc4_[_loc4_.length] = this;
		}
		if (this.active || As3.truthy(Reflect.field(this.vars, "immediateRender"))) {
			this.renderTime(0, false, true);
		}
	}

	// TweenLite.as:128-145（:137 的 ENTER_FRAME 心跳见类头 PORT-NOTE）
	public static function initClass():Void {
		rootFrame = 0;
		rootTimeline = new SimpleTimeline(null);
		rootFramesTimeline = new SimpleTimeline(null);
		rootTimeline.cachedStartTime = As3.getTimer() * 0.001;
		rootFramesTimeline.cachedStartTime = rootFrame;
		rootTimeline.autoRemoveChildren = true;
		rootFramesTimeline.autoRemoveChildren = true;
		_shape.addEventListener(Event.ENTER_FRAME, updateAll, false, 0, true);
		if (overwriteManager == null) {
			overwriteManager = {
				"mode": 1,
				"enabled": false
			};
		}
	}

	// TweenLite.as:147-171
	public static function killTweensOf(param1:Dynamic, param2:Bool = false):Void {
		var _loc3_:Array<TweenLite> = null;
		var _loc4_:Int = 0;
		if (masterList.exists(param1)) {
			_loc3_ = masterList.get(param1);
			_loc4_ = _loc3_.length;
			while (_loc4_-- > 0) {
				if (!As3.truthy(_loc3_[_loc4_].gc)) {
					if (param2) {
						_loc3_[_loc4_].complete(false, false);
					} else {
						_loc3_[_loc4_].setEnabled(false, false);
					}
				}
			}
			masterList.remove(param1);
		}
	}

	// TweenLite.as:173-181
	public static function from(param1:Dynamic, param2:Float, param3:Dynamic):TweenLite {
		Reflect.setField(param3, "runBackwards", true);
		if (!Reflect.hasField(param3, "immediateRender")) {
			Reflect.setField(param3, "immediateRender", true);
		}
		return new TweenLite(param1, param2, param3);
	}

	// TweenLite.as:183-186（原版默认缓动，公式逐字：1-(1-t/d)²）
	private static function easeOut(param1:Float, param2:Float, param3:Float, param4:Float):Float {
		param1 = 1 - param1 / param4;
		return 1 - param1 * param1;
	}

	// TweenLite.as:188-198
	public static function delayedCall(param1:Float, param2:Dynamic, param3:Array<Dynamic> = null, param4:Bool = false):TweenLite {
		return new TweenLite(param2, 0, {
			"delay": param1,
			"onComplete": param2,
			"onCompleteParams": param3,
			"immediateRender": false,
			"useFrames": param4,
			"overwrite": 0
		});
	}

	// TweenLite.as:200-229（每帧先秒轴后帧轴；rootFrame 每 60 帧清一次
	// masterList 里已 gc 的补间桶）
	private static function updateAll(param1:Event = null):Void {
		rootTimeline.renderTime((As3.getTimer() * 0.001 - rootTimeline.cachedStartTime) * rootTimeline.cachedTimeScale, false, false);
		++rootFrame;
		rootFramesTimeline.renderTime((rootFrame - rootFramesTimeline.cachedStartTime) * rootFramesTimeline.cachedTimeScale, false, false);
		if (!As3.truthy(rootFrame % 60)) {
			// openfl Dictionary 的 iterator() 走键（等价 AS3 对 Dictionary 的
			// for-in），值另取 get
			var _loc2_:Dictionary<{}, Array<TweenLite>> = masterList;
			for (_loc3_ in _loc2_.iterator()) {
				var _loc4_:Array<TweenLite> = _loc2_.get(_loc3_);
				var _loc5_:Int = _loc4_.length;
				while (_loc5_-- > 0) {
					if (As3.truthy(_loc4_[_loc5_].gc)) {
						_loc4_.splice(_loc5_, 1);
					}
				}
				if (_loc4_.length == 0) {
					_loc2_.remove(_loc3_);
				}
			}
		}
	}

	// TweenLite.as:231-234
	public static function to(param1:Dynamic, param2:Float, param3:Dynamic):TweenLite {
		return new TweenLite(param1, param2, param3);
	}

	// TweenLite.as:236-239（AS3 arguments = 实参表，与 easeParams 拼接后
	// apply 给 proxiedEase；easeParams 由 init 的守卫保证在场）
	private function easeProxy(param1:Float, param2:Float, param3:Float, param4:Float):Float {
		var _loc5_:Array<Dynamic> = [param1, param2, param3, param4];
		var _loc6_:Dynamic = Reflect.field(this.vars, "easeParams");
		if (_loc6_ != null) {
			_loc5_ = _loc5_.concat(_loc6_);
		}
		return Reflect.callMethod(null, Reflect.field(this.vars, "proxiedEase"), _loc5_);
	}

	// TweenLite.as:241-320（三分支：终点/零点/中间时刻；_loc4_ 为完成标志，
	// duration==0 的 zero-duration 补间靠 _rawPrevTime 区分重复派发）
	override public function renderTime(param1:Float, param2:Bool = false, param3:Bool = false):Void {
		var _loc4_:Bool = false;
		var _loc5_:Float = this.cachedTime;
		this.active = true;
		if (param1 >= this.cachedDuration) {
			this.cachedTotalTime = this.cachedTime = this.cachedDuration;
			this.ratio = 1;
			_loc4_ = true;
			if (this.cachedDuration == 0) {
				if ((param1 == 0 || _rawPrevTime < 0) && _rawPrevTime != param1) {
					param3 = true;
				}
				_rawPrevTime = param1;
			}
		} else if (param1 <= 0) {
			this.cachedTotalTime = this.cachedTime = this.ratio = 0;
			if (param1 < 0) {
				this.active = false;
				if (this.cachedDuration == 0) {
					if (_rawPrevTime > 0) {
						param3 = true;
						_loc4_ = true;
					}
					_rawPrevTime = param1;
				}
			}
			if (As3.truthy(this.cachedReversed) && _loc5_ != 0) {
				_loc4_ = true;
			}
		} else {
			this.cachedTotalTime = this.cachedTime = param1;
			this.ratio = this._ease(param1, 0, 1, this.cachedDuration);
		}
		if (this.cachedTime == _loc5_ && !param3) {
			return;
		}
		if (!As3.truthy(this.initted)) {
			this.init();
			if (!_loc4_ && As3.truthy(this.cachedTime)) {
				this.ratio = this._ease(this.cachedTime, 0, 1, this.cachedDuration);
			}
		}
		if (_loc5_ == 0 && As3.truthy(Reflect.field(this.vars, "onStart")) && this.cachedTime != 0 && !param2) {
			var _loc7_:Dynamic = Reflect.field(this.vars, "onStartParams");
			if (_loc7_ != null) {
				Reflect.callMethod(null, Reflect.field(this.vars, "onStart"), _loc7_);
			} else {
				Reflect.callMethod(null, Reflect.field(this.vars, "onStart"), []);
			}
		}
		var _loc6_:PropTween = this.cachedPT1;
		while (_loc6_ != null) {
			setTargetProp(_loc6_.target, _loc6_.property, _loc6_.start + this.ratio * _loc6_.change);
			_loc6_ = _loc6_.nextNode;
		}
		if (_hasUpdate && !param2) {
			var _loc8_:Dynamic = Reflect.field(this.vars, "onUpdateParams");
			if (_loc8_ != null) {
				Reflect.callMethod(null, Reflect.field(this.vars, "onUpdate"), _loc8_);
			} else {
				Reflect.callMethod(null, Reflect.field(this.vars, "onUpdate"), []);
			}
		}
		if (_loc4_) {
			if (As3.truthy(this._hasPlugins) && this.cachedPT1 != null) {
				onPluginEvent("onComplete", this);
			}
			complete(true, param2);
		}
	}

	// TweenLite.as:322-346
	override public function setEnabled(param1:Bool, param2:Bool = false):Bool {
		var _loc3_:Array<TweenLite> = null;
		// PORT-NOTE（eval Bool 零默认，同上 _evalClassInittedNormalize 的坑）：
		// gc 在首次 setEnabled 前没有赋值点（原版 VM 零默认 false），eval 读
		// null 使本方法与 super（TweenCore.setEnabled）的同款 `param1 == gc`
		// 守卫都恒假、禁用路径整段被跳过——先归一到 false 再进守卫，js/cpp
		// 静态零值 false 上是 no-op
		var gcNow:Dynamic = this.gc;
		if (gcNow == null) {
			this.gc = false;
		}
		if (param1 == this.gc) {
			if (param1) {
				_loc3_ = masterList.get(this.target);
				if (_loc3_ == null) {
					masterList.set(this.target, [this]);
				} else {
					_loc3_[_loc3_.length] = this;
				}
			}
			super.setEnabled(param1, param2);
			if (As3.truthy(this._notifyPluginsOfEnabled) && this.cachedPT1 != null) {
				return onPluginEvent(param1 ? "onEnable" : "onDisable", this);
			}
		}
		return false;
	}

	// TweenLite.as:348-435（vars 的保留属性外的每个键建 PropTween；本作
	// plugins 恒空对象、插件支不触发，仍照译）
	private function init():Void {
		var _loc1_:String = null;
		var _loc2_:Int = 0;
		var _loc3_:Dynamic = null;
		var _loc4_:Bool = false;
		var _loc5_:Array<TweenLite> = null;
		var _loc6_:PropTween = null;
		if (Reflect.isFunction(Reflect.field(this.vars, "ease"))) {
			this._ease = Reflect.field(this.vars, "ease");
		}
		if (As3.truthy(Reflect.field(this.vars, "easeParams"))) {
			Reflect.setField(this.vars, "proxiedEase", this._ease);
			this._ease = this.easeProxy;
		}
		this.cachedPT1 = null;
		this.propTweenLookup = {};
		for (_loc1_ in Reflect.fields(this.vars)) {
			// :369（保留属性放行 timeScale 当且仅当目标本身是补间核心）
			if (!Reflect.hasField(_reservedProps, _loc1_) || _loc1_ == "timeScale" && Std.isOfType(this.target, TweenCore)) {
				// :371（AS3 `_loc1_ in plugins && Boolean(new (... )().onInitTween(...))`
				// 的 && 拆开：成员检查先行，onInitTween 只在有插件键时求值）
				var _loc7_:Bool = false;
				if (Reflect.hasField(plugins, _loc1_)) {
					_loc3_ = Type.createInstance(Reflect.field(plugins, _loc1_), []);
					_loc7_ = As3.truthy(_loc3_.onInitTween(this.target, Reflect.field(this.vars, _loc1_), this));
				}
				if (_loc7_) {
					this.cachedPT1 = new PropTween(_loc3_, "changeFactor", 0, 1,
						As3.intOf(_loc3_.overwriteProps.length) == 1 ? _loc3_.overwriteProps[0] : "_MULTIPLE_", true, this.cachedPT1);
					if (this.cachedPT1.name == "_MULTIPLE_") {
						_loc2_ = As3.intOf(_loc3_.overwriteProps.length);
						while (_loc2_-- > 0) {
							Reflect.setField(this.propTweenLookup, _loc3_.overwriteProps[_loc2_], this.cachedPT1);
						}
					} else {
						Reflect.setField(this.propTweenLookup, this.cachedPT1.name, this.cachedPT1);
					}
					if (As3.truthy(_loc3_.priority)) {
						this.cachedPT1.priority = _loc3_.priority;
						_loc4_ = true;
					}
					if (As3.truthy(_loc3_.onDisable) || As3.truthy(_loc3_.onEnable)) {
						this._notifyPluginsOfEnabled = true;
					}
					this._hasPlugins = true;
				} else {
					// :399（start 取目标当前值、change 取目标值-当前值；typeof
					// "number" 在 Haxe 侧对应 Int|Float 双查——对象字面量里的整
					// 数字面量是 Int）
					var _loc8_:Float = getTargetNumber(this.target, _loc1_);
					var _loc9_:Dynamic = Reflect.field(this.vars, _loc1_);
					var _loc10_:Float = Std.isOfType(_loc9_, Int) || Std.isOfType(_loc9_, Float)
						? As3.floatOf(_loc9_) - _loc8_
						: As3.floatOf(_loc9_);
					this.cachedPT1 = new PropTween(this.target, _loc1_, _loc8_, _loc10_, _loc1_, false, this.cachedPT1);
					Reflect.setField(this.propTweenLookup, _loc1_, this.cachedPT1);
				}
			}
		}
		if (_loc4_) {
			onPluginEvent("onInit", this);
		}
		if (As3.truthy(Reflect.field(this.vars, "runBackwards"))) {
			_loc6_ = this.cachedPT1;
			while (_loc6_ != null) {
				_loc6_.start += _loc6_.change;
				_loc6_.change = -_loc6_.change;
				_loc6_ = _loc6_.nextNode;
			}
		}
		_hasUpdate = Reflect.field(this.vars, "onUpdate") != null;
		if (this._overwrittenProps != null) {
			this.killVars(this._overwrittenProps);
			if (this.cachedPT1 == null) {
				this.setEnabled(false, false);
			}
		}
		if (this._overwrite > 1 && this.cachedPT1 != null) {
			_loc5_ = masterList.get(this.target);
			if (_loc5_ != null && _loc5_.length > 1) {
				if (As3.truthy(Reflect.callMethod(overwriteManager,
					Reflect.field(overwriteManager, "manageOverwrites"),
					[this, this.propTweenLookup, _loc5_, this._overwrite]))) {
					this.init();
				}
			}
		}
		this.initted = true;
	}

	// TweenLite.as:437-490（把属性节点从链表/查表摘除；非插件路径恒返 false）
	public function killVars(param1:Dynamic, param2:Bool = true):Bool {
		var _loc3_:String = null;
		var _loc4_:PropTween = null;
		var _loc5_:Bool = false;
		if (this._overwrittenProps == null) {
			this._overwrittenProps = {};
		}
		for (_loc3_ in Reflect.fields(param1)) {
			if (Reflect.hasField(this.propTweenLookup, _loc3_)) {
				_loc4_ = Reflect.field(this.propTweenLookup, _loc3_);
				if (_loc4_.isPlugin && _loc4_.name == "_MULTIPLE_") {
					_loc4_.target.killProps(param1);
					if (As3.intOf(_loc4_.target.overwriteProps.length) == 0) {
						_loc4_.name = "";
					}
				}
				if (_loc4_.name != "_MULTIPLE_") {
					if (_loc4_.nextNode != null) {
						_loc4_.nextNode.prevNode = _loc4_.prevNode;
					}
					if (_loc4_.prevNode != null) {
						_loc4_.prevNode.nextNode = _loc4_.nextNode;
					} else if (this.cachedPT1 == _loc4_) {
						this.cachedPT1 = _loc4_.nextNode;
					}
					if (_loc4_.isPlugin && As3.truthy(_loc4_.target.onDisable)) {
						_loc4_.target.onDisable();
						if (As3.truthy(_loc4_.target.activeDisable)) {
							_loc5_ = true;
						}
					}
					Reflect.deleteField(this.propTweenLookup, _loc3_);
				}
			}
			if (param2) {
				Reflect.setField(this._overwrittenProps, _loc3_, 1);
			}
		}
		return _loc5_;
	}

	// TweenLite.as:492-502（AS3 连环赋值 _hasUpdate=initted=active=...=false）
	override public function invalidate():Void {
		if (As3.truthy(this._notifyPluginsOfEnabled) && this.cachedPT1 != null) {
			onPluginEvent("onDisable", this);
		}
		this.cachedPT1 = null;
		this._overwrittenProps = null;
		this._notifyPluginsOfEnabled = false;
		this.active = false;
		this.initted = false;
		_hasUpdate = false;
		this.propTweenLookup = {};
	}

	// ---- 动态读写分流（类头 PORT-NOTE；openfl 真属性走 cast，其余走 Reflect）

	private static function getTargetNumber(target:Dynamic, property:String):Float {
		if (Std.isOfType(target, DisplayObject)) {
			var d:DisplayObject = cast target;
			switch (property) {
				case "x":
					return d.x;
				case "y":
					return d.y;
				case "scaleX":
					return d.scaleX;
				case "scaleY":
					return d.scaleY;
				case "alpha":
					return d.alpha;
				case "rotation":
					return d.rotation;
			}
		}
		return As3.floatOf(Reflect.field(target, property));
	}

	private static function setTargetProp(target:Dynamic, property:String, value:Float):Void {
		if (Std.isOfType(target, DisplayObject)) {
			var d:DisplayObject = cast target;
			switch (property) {
				case "x":
					d.x = value;
					return;
				case "y":
					d.y = value;
					return;
				case "scaleX":
					d.scaleX = value;
					return;
				case "scaleY":
					d.scaleY = value;
					return;
				case "alpha":
					d.alpha = value;
					return;
				case "rotation":
					d.rotation = value;
					return;
			}
		}
		Reflect.setField(target, property, value);
	}
}
