package module.water;

import com.qzone.corelib.net.RSLManager;
import com.qzone.utils.AlignUtil;
import common.Consts;
import common.GetCropID;
import common.misc.Utils;
import common.view.window.BaseWindow;
import entities.PoolFish;
import interfaces.IMsgCenter;
import openfl.display.DisplayObject;
import openfl.display.DisplayObjectContainer;
import openfl.display.MovieClip;
import openfl.display.Sprite;
import openfl.text.TextField;
import shim.As3;

/**
 * module.water.PoolInfoWindow —— PoolInfoWindow.as 逐句对应（issue #37 功能
 * swf 翻译：鱼塘 pool_v_13 池塘详情窗，MSG_SHOW_POOLINFO 派 FishNet 光标点
 * 角标打开）。PoolInfoContent 素材按 type 分组统计（groupFishes），item0-5
 * 行填名称/条数/容量，鱼图标经 RSLManager.requestClass("Fish_<type>") 异步
 * 装配；1-4 帧四档行数对应高度 244..379。
 * `_infoContent["item" + n]`/`["tfSize"]` 等时间轴具名子件按 CLAUDE.md 动态
 * 属性分流走 As3.childOf + cast（真类型写真属性）；分组记录的 `++num` 是匿名
 * 对象字段 → Reflect.setField。
 */
class PoolInfoWindow extends BaseWindow {
	// PoolInfoWindow.as:19
	private var _infoContent:MovieClip;

	// PoolInfoWindow.as:21-30
	public function new(param1:IMsgCenter) {
		super(param1);
		title = "池塘详情";
		width = 360;
		height = 244;
		windowName = "PoolInfo";
		mode = true;
		this.createWindowContent();
	}

	// PoolInfoWindow.as:32-36
	override private function setSize():Void {
		super.setSize();
		panelTitle.x = AlignUtil.middle(_width, panelTitle.width);
	}

	// PoolInfoWindow.as:38-61
	private function onLoaded(param1:Array<Dynamic>):Void {
		if (param1 == null || param1.length != 2) {
			return;
		}
		var _loc2_:String = param1[0];
		var _loc3_:DisplayObjectContainer = param1[1];
		if (_loc2_ == null || _loc3_ == null || _loc2_ == "") {
			return;
		}
		var _loc4_:Sprite = cast(Utils.getMaterial(_loc2_), Sprite);
		if (_loc4_ == null) {
			return;
		}
		this.graphics.clear();
		_loc4_.x = 2;
		_loc4_.scaleX = _loc4_.scaleY = 34 / _loc4_.width;
		_loc4_.y = (40 - _loc4_.height) * 0.5;
		_loc4_.name = "__fish_icon__";
		_loc3_.addChild(_loc4_);
	}

	// PoolInfoWindow.as:63-94。for each → 值遍历；`++_loc5_["num"]` 匿名记录
	// 字段自增 → Reflect.setField
	private function groupFishes(param1:Array<Dynamic>):Array<Dynamic> {
		var _loc4_:PoolFish = null;
		var _loc5_:Dynamic = null;
		var _loc6_:Dynamic = null;
		var _loc2_:Array<Dynamic> = [];
		var _loc3_:Bool = false;
		// for-each：AS3 声明 `_loc4_:PoolFish`，经 typed 收窄——poolSize 是
		// getter，动态接收者上取不到
		var typed:Array<PoolFish> = cast param1;
		for (_loc4_ in typed) {
			_loc3_ = false;
			for (_loc5_ in _loc2_) {
				if (_loc4_._type == Reflect.field(_loc5_, "type")) {
					Reflect.setField(_loc5_, "num",
						As3.floatOf(Reflect.field(_loc5_, "num")) + 1);
					_loc3_ = true;
				}
			}
			if (_loc3_ == false) {
				_loc6_ = {
					"type": _loc4_._type,
					"name": _loc4_.name,
					"size": _loc4_.poolSize,
					"num": 1
				};
				Reflect.setField(_loc6_, "icon", GetCropID.getFishUrl(Reflect.field(_loc6_, "type"), true));
				_loc2_.push(_loc6_);
			}
		}
		return _loc2_;
	}

	// PoolInfoWindow.as:96-104
	override private function addedToLayer():Void {
		super.addedToLayer();
		if (this._infoContent != null) {
			this._infoContent.x = AlignUtil.middle(_width, this._infoContent.width);
			this._infoContent.y = panelTitle.height;
		}
	}

	// PoolInfoWindow.as:106-174
	override private function setData():Void {
		var _loc9_:Dynamic = null;
		var _loc10_:String = null;
		var _loc1_:Dynamic = super.get_data();
		if (_loc1_ == null) {
			return;
		}
		var _loc2_:Array<Dynamic> = Reflect.field(_loc1_, "fishes");
		if (_loc2_ == null || _loc2_.length == 0) {
			if (this._infoContent != null) {
				this._infoContent.gotoAndStop(4);
			}
			this.reset();
			return;
		}
		var _loc3_:Array<Dynamic> = this.groupFishes(_loc2_);
		if (_loc3_ == null || _loc3_.length == 0) {
			return;
		}
		var _loc4_:Int = 0;
		var _loc5_:DisplayObjectContainer = null;
		var _loc6_:DisplayObject = null;
		var _loc7_:RSLManager = RSLManager.getInstance();
		var _loc8_:Int = 0;
		for (_loc9_ in _loc3_) {
			_loc5_ = cast(As3.childOf(this._infoContent, "item" + _loc4_), DisplayObjectContainer);
			if (_loc5_ != null) {
				cast(As3.childOf(_loc5_, "tfName"), TextField).text = Reflect.field(_loc9_, "name");
				cast(As3.childOf(_loc5_, "tfNum"), TextField).text = Reflect.field(_loc9_, "num");
				// AS3 Number 隐式 ToString 落 text
				cast(As3.childOf(_loc5_, "tfSize"), TextField).text = Std.string(As3.floatOf(Reflect.field(_loc9_, "num"))
					* As3.floatOf(Reflect.field(_loc9_, "size")));
				_loc8_ += As3.intOf(As3.floatOf(Reflect.field(_loc9_, "num")) * As3.floatOf(Reflect.field(_loc9_, "size")));
				if (As3.hasProp(_loc9_, "icon") && Reflect.field(_loc9_, "icon") != "") {
					_loc10_ = "Fish_" + Reflect.field(_loc9_, "type");
					_loc7_.requestClass(_loc10_, this.onLoaded, Reflect.field(_loc9_, "icon"), [_loc10_, _loc5_]);
				}
				_loc5_.visible = true;
				_loc4_++;
			}
		}
		cast(As3.childOf(this._infoContent, "tfSize"), TextField).text = _loc8_ + "/" + Consts.FISH_MAX_SIZE;
		if (_loc4_ == 6) {
			this._infoContent.gotoAndStop(1);
			height = 244 + 3 * 45;
		} else if (_loc4_ == 5) {
			this._infoContent.gotoAndStop(2);
			height = 244 + 2 * 45;
		} else if (_loc4_ == 4) {
			this._infoContent.gotoAndStop(3);
			height = 244 + 1 * 45;
		} else {
			this._infoContent.gotoAndStop(4);
			height = 244;
		}
	}

	// PoolInfoWindow.as:176-183
	private function createWindowContent():Void {
		this._infoContent = cast(Utils.getMaterial("PoolInfoContent"), MovieClip);
		this._infoContent.name = "PoolInfoContent";
		this._infoContent.gotoAndPlay(4);
		addChild(this._infoContent);
		this.reset();
	}

	// PoolInfoWindow.as:185-212
	private function reset():Void {
		if (this._infoContent == null) {
			return;
		}
		cast(As3.childOf(this._infoContent, "tfSize"), TextField).text = "0/0";
		var _loc1_:DisplayObjectContainer = null;
		var _loc2_:DisplayObject = null;
		var _loc3_:Int = 0;
		while (_loc3_ < 6) {
			_loc1_ = cast(As3.childOf(this._infoContent, "item" + _loc3_), DisplayObjectContainer);
			if (_loc1_ != null) {
				cast(As3.childOf(_loc1_, "tfName"), TextField).text = "";
				cast(As3.childOf(_loc1_, "tfNum"), TextField).text = "";
				cast(As3.childOf(_loc1_, "tfSize"), TextField).text = "";
				_loc2_ = _loc1_.getChildByName("__fish_icon__");
				if (_loc2_ != null) {
					_loc1_.removeChild(_loc2_);
				}
				_loc1_.visible = false;
			}
			_loc3_++;
		}
	}
}
