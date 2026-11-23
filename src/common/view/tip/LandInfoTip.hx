package common.view.tip;

import com.qzone.corelib.net.RSLManager;
import common.CommonData;
import common.Consts;
import common.GetCropID;
import common.Language;
import common.Session;
import common.Settings;
import common.misc.Utils;
import entities.FarmLand;
import openfl.display.MovieClip;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.text.TextField;
import openfl.text.TextFormat;
import shim.As3;

/**
 * common.view.tip.LandInfoTip —— LandInfoTip.as 逐句对应（issue #42，替换
 * #7 的闭包 stub）。地块信息提示（悬停/长按地块的详情窗）：FarmInfoPlus
 * 版面 + 健康值/农时/产量文案，ENTER_FRAME 按 _frequence（<1h 剩余 1s、
 * 否则 5s）自刷新；枯死走 setStep7、成熟走 setOutput、生长走 setInfo +
 * countHealth；种子小图经 RSLManager.requestClass 异步补挂。
 *
 * `_farmInfo:MovieClip` 上调的 setStep7/setOutput/setInfo/setInfoIcon/
 * setOutputIcon 与 `["stepText"]["defaultTextFormat"]` 是 farmui_full_v_40
 * 里 FarmInfoPlus 符号关联类（ABC，无 FFDec 产物）的动态面——方法走
 * Reflect.callMethod 按名派发（ModuleWater 先例），stepText 走 As3.childOf
 * 取出后 cast TextField 写真属性（CLAUDE.md 动态属性三分流）。
 */
@:keep
class LandInfoTip extends Tip {
	// LandInfoTip.as:21
	private var _frequence:Int;

	// LandInfoTip.as:23
	private var _land:FarmLand;

	// LandInfoTip.as:25
	private var _preTime:Int;

	// LandInfoTip.as:27
	private var _farmInfo:MovieClip;

	// LandInfoTip.as:29
	private var _seedIcon:Sprite;

	// LandInfoTip.as:31
	private var _seedClassName:String;

	// LandInfoTip.as:33-44
	public function new() {
		super();
		_tipName = Consts.TIP_NAME_LAND_INFOR;
		this._frequence = 5000;
		this._farmInfo = null;
		this._seedClassName = "";
		this._seedIcon = null;
		this._land = null;
		this._preTime = -1;
		this.addEventListener(Event.REMOVED_FROM_STAGE, this.onRemovedFromStage);
	}

	// LandInfoTip.as:46-57
	private function addFarmInfo():Void {
		if (this._farmInfo == null) {
			// `Utils.getMaterial("FarmInfoPlus") as MovieClip`
			var _mat:Dynamic = Utils.getMaterial("FarmInfoPlus");
			this._farmInfo = Std.isOfType(_mat, MovieClip) ? cast(_mat, MovieClip) : null;
			addChild(this._farmInfo);
		} else if (contains(this._farmInfo) == false) {
			addChild(this._farmInfo);
		}
	}

	// LandInfoTip.as:59-170（countHealth：健康值按动作日志与流逝时间的推进。
	// AS3 int 参数/局部逐次赋值截断——:107 的 -= 截在**整式结果**上，:100/:93
	// 同理；`[...].concat(action)` 对标量是包裹语义（Haxe concat 只收数组）；
	// :145 的 --param4 先减再比）
	private function countHealth(param1:Int, param2:Int, param3:Int, param4:Int, param5:Int, param6:Int, param7:Dynamic):Int {
		var _loc14_:Array<Dynamic> = null;
		var _loc15_:Int = 0;
		var _loc8_:Int = 0;
		var _loc9_:Float = 0;
		var _loc10_:Int = 0;
		var _loc11_:Int = 0;
		var _loc12_:Array<Dynamic> = null;
		if (Std.isOfType(param7, Array)) {
			param7 = {"2228612959": null};
		} else {
			Reflect.setField(param7, "2228612959", null);
		}
		_loc12_ = this.jsonToArray(param7);
		var _loc13_:Int = 0;
		while (_loc13_ < _loc12_.length) {
			if (Reflect.field(_loc12_[_loc13_], "action") == null) {
				_loc8_ = As3.intOf(CommonData.serverTime);
			} else {
				_loc8_ = As3.intOf(Reflect.field(_loc12_[_loc13_], "time"));
			}
			_loc9_ = (param3 + param4) * 0.2;
			if (param5 == 0) {
				_loc9_ += 0.6;
			}
			_loc11_ = Std.int(100 - _loc9_ * 50);
			if (_loc9_ == 0) {
				param1 = 100;
			} else {
				_loc10_ = Std.int((param1 - _loc11_) * 60 / _loc9_);
				if (_loc10_ + param2 < _loc8_) {
					param1 = _loc11_;
				} else {
					param1 = Std.int(param1 - (_loc8_ - param2) * _loc9_ / 60);
				}
			}
			param2 = _loc8_;
			if (Reflect.field(_loc12_[_loc13_], "action") != null) {
				_loc14_ = [];
				var _act:Dynamic = Reflect.field(_loc12_[_loc13_], "action");
				if (Std.isOfType(_act, Array)) {
					_loc14_ = _loc14_.concat(cast(_act, Array<Dynamic>));
				} else {
					_loc14_.push(_act);
				}
				_loc15_ = 0;
				while (_loc15_ < _loc14_.length) {
					if (As3.intOf(_loc14_[_loc15_]) == 1) {
						param4 += 1;
						if (param4 > 3) {
							param4 = 3;
						}
					} else if (As3.intOf(_loc14_[_loc15_]) == 2) {
						param3 += 1;
						if (param3 > 3) {
							param3 = 3;
						}
					} else if (As3.intOf(_loc14_[_loc15_]) == 3) {
						param5 = 0;
					} else if (As3.intOf(_loc14_[_loc15_]) == 4) {
						param5 = 1;
						param1 += 30;
					} else if (As3.intOf(_loc14_[_loc15_]) == 5) {
						param4 = param4 - 1;
						if (param4 < 0) {
							param4 = 0;
						}
						param1 += 10;
					} else if (As3.intOf(_loc14_[_loc15_]) == 6) {
						param3--;
						if (param3 < 0) {
							param3 = 0;
						}
						param1 += 10;
					}
					_loc15_++;
				}
			}
			if (param1 > 100) {
				param1 = 100;
			}
			_loc13_++;
		}
		return param1;
	}

	// LandInfoTip.as:172-352（onFarmTimer：农时/健康/产量刷新）
	private function onFarmTimer():Void {
		var _loc20_:String = null;
		var _loc21_:Dynamic = null;
		var _loc22_:Dynamic = null;
		var _loc23_:Dynamic = null;
		var _loc24_:String = null;
		var _loc25_:Dynamic = null;
		var _loc28_:String = null;
		var _loc29_:Dynamic = null;
		var _loc30_:String = null;
		if (this._land == null || this._land._cId == 0) {
			this.removeFarmInfo();
			return;
		}
		var _loc1_:Int = this._land._cId;
		var _loc2_:String = "";
		if (_loc1_ > 0) {
			_loc2_ = GetCropID.getSeedUrl(_loc1_);
			this._seedClassName = Settings.getInstance().getSeedName(_loc1_);
		}
		if (_loc2_ == "" || this._seedClassName == "") {
			this.removeFarmInfo();
			return;
		}
		var _loc3_:Dynamic = Settings.getInstance().getCropByID(Std.string(_loc1_));
		if (_loc3_ == null) {
			this.removeFarmInfo();
			return;
		}
		this.addFarmInfo();
		var _loc4_:Int = this._land._step;
		if (_loc4_ == 7) {
			Reflect.callMethod(this._farmInfo, Reflect.field(this._farmInfo, "setStep7"),
				[Std.string(Reflect.field(_loc3_, "name")) + " (已枯萎)"]);
			CommonData.rslManager.requestClass(this._seedClassName, this.onOutputIconLoaded, _loc2_);
			return;
		}
		var _loc5_:Dynamic = GetCropID.remainTime(_loc1_, this._land._plantTime, this._land._bitmap);
		if (_loc5_ == null) {
			return;
		}
		var _loc6_:Int = As3.intOf(Reflect.field(_loc5_, "remain"));
		var _loc7_:Int = Math.floor(_loc6_ / 3600);
		var _loc8_:Int = Math.ceil(_loc6_ % 3600 / 60);
		var _loc9_:Int = Math.ceil(_loc6_ % 3600 % 60);
		var _loc10_:String = "";
		var _loc11_:String = "";
		if (_loc7_ > 0) {
			_loc11_ = Language.replaceText("hrsText", {hrs: _loc7_});
		}
		_loc8_ = _loc8_ - 1;
		if (_loc8_ > 1) {
			if (_loc9_ == 0) {
				_loc8_ += 1;
			}
			_loc8_ = _loc8_ == 60 ? 59 : _loc8_;
		}
		if (_loc8_ > 0) {
			_loc11_ += Language.replaceText("minsText", {mins: _loc8_});
		}
		if (_loc7_ == 0 && _loc8_ < 10) {
			if (_loc8_ == 0) {
				_loc9_ = _loc9_ == 0 ? 60 : _loc9_;
			}
			_loc11_ += _loc9_ + "秒";
		}
		if (_loc7_ == 0) {
			this._frequence = 1000;
		} else {
			this._frequence = 5000;
		}
		if (Reflect.field(_loc3_, "isYouji") == 1) {
			cast(As3.childOf(this._farmInfo, "stepText"), TextField).defaultTextFormat = new TextFormat("Tahoma", 12, 26112);
		} else {
			cast(As3.childOf(this._farmInfo, "stepText"), TextField).defaultTextFormat = new TextFormat("Tahoma", 12, 3355443);
		}
		var _loc12_:String = Std.string(this._land._harvestTimes + 1);
		var _loc13_:String = Reflect.field(_loc5_, "text");
		var _loc14_:Array<Dynamic> = (Reflect.field(_loc3_, "nextText") : String).split(",");
		var _loc15_:String = cast(_loc14_[_loc4_], String);
		var _loc16_:String = Std.string(Reflect.field(_loc3_, "name")) + " (第" + _loc12_ + "季)";
		var _loc17_:Session = Session.getInstance();
		var _loc18_:String = "";
		var _loc19_:Bool = _loc6_ == 0 ? true : false;
		if (_loc19_ == true) {
			_loc20_ = "";
			if (_loc17_.me == false) {
				_loc23_ = this._land._thief;
				_loc24_ = _loc17_.hostId;
				if (_loc23_ != null && As3.hasProp(_loc23_, _loc24_) == true) {
					_loc20_ = "-已摘取";
				}
			}
			_loc21_ = {};
			Reflect.setField(_loc21_, "season", _loc12_);
			Reflect.setField(_loc21_, "units", Std.string(this._land._output));
			Reflect.setField(_loc21_, "left", Std.string(this._land._left));
			Reflect.setField(_loc21_, "ups", "");
			_loc22_ = Reflect.field(_loc3_, "isRed");
			if (this._land._bitmap == 1 && (_loc22_ == null || As3.eqString(_loc22_, "0"))) {
				Reflect.setField(_loc21_, "ups", "<font color=\"#FF6600\">增产10%</font>&nbsp;");
			} else if (this._land._bitmap == 2 && (_loc22_ == null || As3.eqString(_loc22_, "0") || As3.eqString(_loc22_, "1"))) {
				Reflect.setField(_loc21_, "ups", "<font color=\"#FF6600\">提速20%</font>&nbsp;");
			}
			_loc18_ = Language.replaceText("ripeText", _loc21_) + _loc20_;
			if (_loc17_.healthModeValid == true || _loc17_.currentFarmHealthModeValid == true) {
				_loc18_ = "健康模式保护中";
			} else if (_loc17_.healthModeTimeOut == true) {
				_loc18_ = "第" + _loc12_ + "季&nbsp;可收获";
			}
			Reflect.callMethod(this._farmInfo, Reflect.field(this._farmInfo, "setOutput"), [1, _loc18_, _loc16_]);
			CommonData.rslManager.requestClass(this._seedClassName, this.onOutputIconLoaded, _loc2_);
		} else {
			_loc25_ = {timeText: _loc11_, section: _loc13_};
			_loc18_ = _loc15_ + Language.replaceText("growText", _loc25_);
			var _loc26_:Int = As3.intOf(CommonData.serverTime);
			var _loc27_:Int = this.countHealth(this._land._health, this._land._updateTime, As3.intOf(this._land._oldweed),
				As3.intOf(this._land._oldpest), As3.intOf(this._land._oldhumidity), _loc26_, this._land._action);
			_loc28_ = "";
			if (_loc27_ <= 60) {
				_loc28_ = "状态(可怕)";
			} else if (_loc27_ > 60 && _loc27_ <= 70) {
				_loc28_ = "状态(糟糕)";
			} else if (_loc27_ > 70 && _loc27_ <= 80) {
				_loc28_ = "状态(欠佳)";
			} else if (_loc27_ > 80 && _loc27_ <= 95) {
				_loc28_ = "状态(良好)";
			} else if (_loc27_ > 95) {
				_loc28_ = "状态(优秀)";
			}
			_loc29_ = Reflect.field(_loc17_.sceneDecorates, Consts.ITEM_TYPE_FAIRY);
			if (_loc29_ != null && (Reflect.field(_loc29_, "itemId") == Consts.FAIRY_LAND || Reflect.field(_loc29_, "itemId") == Consts.FAIRY_GOD)) {
				_loc30_ = Std.string(Reflect.field(_loc29_, "rate"));
				_loc28_ += "，产量加成" + _loc30_ + "%";
			}
			Reflect.callMethod(this._farmInfo, Reflect.field(this._farmInfo, "setInfo"),
				[_loc27_ / 100, _loc28_, Reflect.field(_loc5_, "progress"), _loc18_, _loc16_]);
			CommonData.rslManager.requestClass(this._seedClassName, this.onInfoIconLoaded, _loc2_);
		}
	}

	// LandInfoTip.as:354-369
	override private function set_data(param1:Dynamic):Dynamic {
		super.data = param1;
		this._land = Std.isOfType(param1, FarmLand) ? cast(param1, FarmLand) : null;
		if (this._land == null) {
			this.removeFarmInfo();
			this.onRemovedFromStage(null);
			return param1;
		}
		this._seedClassName = "";
		this._seedIcon = null;
		this.onFarmTimer();
		this._preTime = As3.getTimer();
		addEventListener(Event.ENTER_FRAME, this.onEnterFrame, false, 0, true);
		return param1;
	}

	// LandInfoTip.as:371-385（jsonToArray：动作日志对象 → {time:键,action:值}
	// 数组，按 Number(time) 升序）
	private function jsonToArray(param1:Dynamic):Array<Dynamic> {
		var _loc3_:String = null;
		var _loc4_:Dynamic = null;
		var _loc2_:Array<Dynamic> = [];
		for (_loc3_ in Reflect.fields(param1)) {
			_loc4_ = {};
			Reflect.setField(_loc4_, "time", _loc3_);
			Reflect.setField(_loc4_, "action", Reflect.field(param1, _loc3_));
			_loc2_.push(_loc4_);
		}
		_loc2_.sort(this.sortArray);
		return _loc2_;
	}

	// LandInfoTip.as:387-391
	override private function set_mY(param1:Float):Float {
		super.mY = param1;
		y = param1 - 120;
		return param1;
	}

	// LandInfoTip.as:393-397
	override private function set_mX(param1:Float):Float {
		super.mX = param1;
		x = param1 - 60;
		return param1;
	}

	// LandInfoTip.as:399-411
	private function removeFarmInfo():Void {
		if (this._farmInfo == null) {
			return;
		}
		if (contains(this._farmInfo) == true) {
			removeChild(this._farmInfo);
		}
		removeEventListener(Event.ENTER_FRAME, this.onEnterFrame);
		this._preTime = -1;
	}

	// LandInfoTip.as:413-420（sortArray：Number(time) 升序，恒 1/-1）
	private function sortArray(param1:Dynamic, param2:Dynamic):Int {
		if (As3.floatOf(Reflect.field(param1, "time")) > As3.floatOf(Reflect.field(param2, "time"))) {
			return 1;
		}
		return -1;
	}

	// LandInfoTip.as:422-431
	private function onInfoIconLoaded():Void {
		// `RSLManager.getMaterial(...) as Sprite`
		var _mat:Dynamic = RSLManager.getMaterial(this._seedClassName);
		this._seedIcon = Std.isOfType(_mat, Sprite) ? cast(_mat, Sprite) : null;
		if (this._seedIcon != null) {
			this._seedIcon.scaleX = 0.6;
			this._seedIcon.scaleY = 0.6;
			Reflect.callMethod(this._farmInfo, Reflect.field(this._farmInfo, "setInfoIcon"), [this._seedIcon]);
		}
	}

	// LandInfoTip.as:433-437
	private function onRemovedFromStage(param1:Event):Void {
		removeEventListener(Event.ENTER_FRAME, this.onEnterFrame);
		this._preTime = -1;
	}

	// LandInfoTip.as:439-451
	private function onEnterFrame(param1:Event):Void {
		if (this._preTime < 0) {
			return;
		}
		var _loc2_:Int = As3.getTimer();
		if (_loc2_ - this._preTime > this._frequence) {
			this._preTime = _loc2_;
			this.onFarmTimer();
		}
	}

	// LandInfoTip.as:453-462
	private function onOutputIconLoaded():Void {
		// `RSLManager.getMaterial(...) as Sprite`
		var _mat:Dynamic = RSLManager.getMaterial(this._seedClassName);
		this._seedIcon = Std.isOfType(_mat, Sprite) ? cast(_mat, Sprite) : null;
		if (this._seedIcon != null) {
			this._seedIcon.scaleX = 0.6;
			this._seedIcon.scaleY = 0.6;
			Reflect.callMethod(this._farmInfo, Reflect.field(this._farmInfo, "setOutputIcon"), [this._seedIcon]);
		}
	}
}
