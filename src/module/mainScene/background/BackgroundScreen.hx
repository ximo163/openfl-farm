package module.mainScene.background;

import Navigate;
import com.qzone.corelib.net.RSLLoader;
import com.qzone.qui.makers.ButtonMaker;
import com.qzone.qui.styles.Style;
import common.CommonData;
import common.Consts;
import common.Session;
import common.misc.QzoneJSAPI;
import entities.Player;
import events.CommonEvent;
import openfl.display.DisplayObject;
import openfl.display.DisplayObjectContainer;
import openfl.display.LoaderInfo;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.EventDispatcher;
import openfl.events.IOErrorEvent;
import openfl.events.MouseEvent;
import report.UserActionRecorder;
import shim.As3;

/**
 * module.mainScene.background.BackgroundScreen —— V3b 翻译（issue #8）。
 * 场景背景屏（背景/房子/栅栏/狗屋/告示牌五装饰槽 holder + RSLLoader 组装载 +
 * 牧场导航按钮）。BackgroundScreen.as 500 loc 逐句对应。
 * PORT-NOTE(动态取键)：`_diyUrl[i]["url"]` 读写 → Reflect.setField/field；
 * `as int` → As3.intOf；`Boolean(int)` / `int == false` → As3.truthy；
 * `unloadAndStop` 的 hasOwnProperty 鸭子判走 Reflect + Dynamic 调用
 * （openfl Loader 无该成员，本地化资产后该分支不可达）。
 * legacy/decompiled/main3_v_221/scripts/module/mainScene/background/BackgroundScreen.as
 */
class BackgroundScreen extends Sprite {
	// BackgroundScreen.as:25-47
	private var _dogHouseD:DisplayObjectContainer;

	private var _adD:Sprite;

	private var _houseD:DisplayObjectContainer;

	private var _mask:Sprite;

	private var _fenceD:DisplayObjectContainer;

	private var _session:Session;

	private var _diyUrl:Array<Dynamic> = [];

	private var _bgD:DisplayObjectContainer;

	private var _groupLoader:RSLLoader;

	private var _houseAction:Int;

	private var _controller:BackgroundController;

	private var _navButton:Sprite;

	// BackgroundScreen.as:49-77
	public function new(param1:BackgroundController) {
		var _loc2_:Int = 0;
		super();
		name = Consts.SCENE_ZINDEX_BG;
		this.cacheAsBitmap = true;
		this._controller = param1;
		this._session = Session.getInstance();
		this._groupLoader = null;
		this._navButton = null;
		this._houseAction = 0;
		// AS3 new Array(DECOR_INDEX_MAX)：定长空槽表
		this._diyUrl = [for (_ in 0...BackgroundModel.DECOR_INDEX_MAX) null];
		while (_loc2_ < BackgroundModel.DECOR_INDEX_MAX) {
			this._diyUrl[_loc2_] = {
				"url": "",
				"content": null,
				"type": BackgroundModel.INDEX_TO_TYPE_MAP(_loc2_)
			};
			_loc2_++;
		}
		var _loc3d:Dynamic = param1.model;
		var _loc3_:EventDispatcher = Std.isOfType(_loc3d, EventDispatcher) ? cast _loc3d : null;
		if (_loc3_ != null) {
			_loc3_.addEventListener(BackgroundModel.EVENT_DECORS_CHANGED, this.onDecorsChanged, false, 0, true);
		}
		this.preCreateHolders();
		this.createPastureBoard();
	}

	// BackgroundScreen.as:79-122
	private function onDecorsChanged(param1:CommonEvent):Void {
		var _loc5_:Int = 0;
		var _loc2_:BackgroundModel = this._controller.model;
		if (_loc2_ == null) {
			return;
		}
		if (param1 == null || param1.data == null) {
			return;
		}
		var _loc3_:Int = As3.intOf(Reflect.field(param1.data, "type"));
		var _loc4_:Array<Dynamic> = _loc2_.decors;
		if (_loc4_ == null || _loc4_.length == 0) {
			return;
		}
		if (_loc3_ == -1) {
			this.setDIYUrl(Reflect.field(_loc4_[BackgroundModel.DECOR_INDEX_BG], "url"),
				Reflect.field(_loc4_[BackgroundModel.DECOR_INDEX_FENCE], "url"), Reflect.field(_loc4_[BackgroundModel.DECOR_INDEX_HOUSE], "url"),
				Reflect.field(_loc4_[BackgroundModel.DECOR_INDEX_DOG_HOUSE], "url"), Reflect.field(_loc4_[BackgroundModel.DECOR_INDEX_BOARD], "url"));
		} else {
			_loc5_ = BackgroundModel.TYPE_TO_INDEX_MAP(_loc3_);
			if (Reflect.field(_loc4_[_loc5_], "id") == -1) {
				this.removeDecorate(_loc3_);
				Reflect.setField(this._diyUrl[_loc5_], "url", "");
				Reflect.setField(this._diyUrl[_loc5_], "content", null);
			} else if (this._groupLoader != null) {
				if (this._groupLoader.loading == true) {
					return;
				}
				Reflect.setField(this._diyUrl[_loc5_], "url", Reflect.field(_loc4_[_loc5_], "url"));
				Reflect.setField(this._diyUrl[_loc5_], "content", null);
				this._groupLoader.reset();
				this._groupLoader.load([{"url": Reflect.field(_loc4_[_loc5_], "url")}]);
			}
		}
	}

	// BackgroundScreen.as:124-174
	private function preCreateHolders():Void {
		if (this._bgD == null) {
			this._bgD = new Sprite();
			this._bgD.x = 0;
			this._bgD.y = 0;
			this._bgD.mouseEnabled = false;
			addChild(this._bgD);
			this._mask = new Sprite();
			this._mask.graphics.beginFill(16711680);
			this._mask.graphics.drawRect(0, 0, 1024, 810);
			this._mask.graphics.endFill();
		}
		if (this._fenceD == null) {
			this._fenceD = new Sprite();
			this._fenceD.x = 260 + 120;
			this._fenceD.y = 86 + 100;
			this._fenceD.mouseEnabled = false;
			addChild(this._fenceD);
		}
		if (this._dogHouseD == null) {
			this._dogHouseD = new Sprite();
			this._dogHouseD.x = 344 + 120;
			this._dogHouseD.y = 131 + 100;
			this._dogHouseD.mouseEnabled = false;
			addChild(this._dogHouseD);
		}
		if (this._houseD == null) {
			this._houseD = new Sprite();
			this._houseD.x = 501 + 70;
			this._houseD.y = 162 + 80;
			(cast(this._houseD, Sprite)).buttonMode = true;
			addChild(this._houseD);
		}
		if (this._adD == null) {
			this._adD = new Sprite();
			this._adD.x = 48;
			this._adD.y = 240;
			addChild(this._adD);
			this.registerMouseEvent(this._adD);
		}
		if (this._session.me == true) {
			this._adD.buttonMode = true;
		}
	}

	// BackgroundScreen.as:176-255
	public function setDIYUrl(param1:String = "", param2:String = "", param3:String = "", param4:String = "", param5:String = ""):Void {
		var _loc6_:Array<Dynamic> = [];
		if (Reflect.field(this._diyUrl[BackgroundModel.DECOR_INDEX_BG], "url") != param1 || Reflect.field(this._diyUrl[BackgroundModel.DECOR_INDEX_BG],
			"content") == null) {
			this._diyUrl[BackgroundModel.DECOR_INDEX_BG] = {
				"url": param1,
				"content": null,
				"type": Consts.DECOR_BACKGROUND
			};
			_loc6_.push(this._diyUrl[BackgroundModel.DECOR_INDEX_BG]);
			this.removeDecorate(Consts.DECOR_BACKGROUND);
		}
		if (Reflect.field(this._diyUrl[BackgroundModel.DECOR_INDEX_FENCE], "url") != param2) {
			this._diyUrl[BackgroundModel.DECOR_INDEX_FENCE] = {
				"url": param2,
				"content": null,
				"type": Consts.DECOR_FENCE
			};
			_loc6_.push(this._diyUrl[BackgroundModel.DECOR_INDEX_FENCE]);
			this.removeDecorate(Consts.DECOR_FENCE);
		}
		if (Reflect.field(this._diyUrl[BackgroundModel.DECOR_INDEX_HOUSE], "url") != param3) {
			this._diyUrl[BackgroundModel.DECOR_INDEX_HOUSE] = {
				"url": param3,
				"content": null,
				"type": Consts.DECOR_HOUSE
			};
			_loc6_.push(this._diyUrl[BackgroundModel.DECOR_INDEX_HOUSE]);
			this.removeDecorate(Consts.DECOR_HOUSE);
		}
		if (Reflect.field(this._diyUrl[BackgroundModel.DECOR_INDEX_DOG_HOUSE], "url") != param4) {
			this._diyUrl[BackgroundModel.DECOR_INDEX_DOG_HOUSE] = {
				"url": param4,
				"content": null,
				"type": Consts.DECOR_DOGHOUSE
			};
			_loc6_.push(this._diyUrl[BackgroundModel.DECOR_INDEX_DOG_HOUSE]);
			this.removeDecorate(Consts.DECOR_DOGHOUSE);
		}
		if (Reflect.field(this._diyUrl[BackgroundModel.DECOR_INDEX_BOARD], "url") != param5) {
			this._diyUrl[BackgroundModel.DECOR_INDEX_BOARD] = {
				"url": param5,
				"content": null,
				"type": Consts.DECOR_BILLBOARD
			};
			_loc6_.push(this._diyUrl[BackgroundModel.DECOR_INDEX_BOARD]);
			this.removeDecorate(Consts.DECOR_BILLBOARD);
		}
		if (_loc6_.length > 0) {
			if (this._groupLoader == null) {
				this._groupLoader = new RSLLoader();
				this._groupLoader.ignoreError = true;
				this._groupLoader.retryTimes = 1;
				this._groupLoader.contentCheckDelay = 5000;
				// 原版顺序：先取 rslLoader.securityDomain 再判 rslLoader 空值
				this._groupLoader.securityDomain = CommonData.rslLoader.securityDomain;
				this._groupLoader.completeFn = this.onLoaded;
				this._groupLoader.errorFn = this.onLoadFailed;
				if (CommonData.rslLoader != null) {
					this._groupLoader.applicationDomain = CommonData.rslLoader.applicationDomain;
				} else {
					this._groupLoader.applicationDomain = CommonData.applicationDomain;
				}
			} else {
				this._groupLoader.reset();
			}
			this._groupLoader.load(_loc6_);
		}
	}

	// BackgroundScreen.as:257-274
	private function onNavBtnClicked(param1:MouseEvent):Void {
		var _loc2_:Player = Session.getInstance().host;
		var _loc3_:Player = Session.getInstance().currentUser;
		if (Session.getInstance().me == true) {
			this._controller.module.app.dispatchEvent(new CommonEvent(Consts.MSG_ENTER_MC, 1));
		} else if (_loc2_._pf > 0 && _loc3_._pf > 0) {
			this._controller.module.app.setExpressUser(_loc3_.exportObject(), 1);
		} else if (_loc2_._pf <= 0 && _loc3_._pf > 0) {
			this._controller.module.app.dispatchEvent(new CommonEvent(Consts.MSG_ENTER_MC, 1));
		}
		UserActionRecorder.recordAction(UserActionRecorder.HF_TO_PASTURE_CLICKED);
	}

	// BackgroundScreen.as:276-281
	private function onLoadFailed(param1:IOErrorEvent):Void {
		var _loc2_:String = param1.text;
		_loc2_ = _loc2_.substr(_loc2_.indexOf("http"));
		QzoneJSAPI.reportError("加载装饰素材失败，素材路径：" + _loc2_, 3);
	}

	// BackgroundScreen.as:283-306
	private function onLoaded(param1:Event):Void {
		var _loc3_:Dynamic;
		if (param1 == null) {
			return;
		}
		var _loc2d:Dynamic = param1.target;
		var _loc2_:LoaderInfo = Std.isOfType(_loc2d, LoaderInfo) ? cast _loc2d : null;
		if (_loc2_ == null || _loc2_.content == null) {
			return;
		}
		// AS3 for-each：按值遍历
		for (_loc3_ in this._diyUrl) {
			if (!(_loc3_ == null || Reflect.field(_loc3_, "url") == "")) {
				if (Reflect.field(_loc3_, "url") == _loc2_.url) {
					this.replaceDecorate(Reflect.field(_loc3_, "type"), _loc2_.content);
					break;
				}
			}
		}
	}

	// BackgroundScreen.as:308-328
	public function updatePastureBoard():Void {
		if (this._navButton == null) {
			return;
		}
		if (As3.truthy(this._session.currentUser._pf) || this._session.currentUser.pf2) {
			this._navButton.filters = [];
		} else if (this._session.me == false) {
			this._navButton.filters = cast Style.getDisableFilter();
		}
		this._navButton.visible = true;
		this.setChildIndex(this._navButton, this.numChildren - 1);
		// AS3 `currentUser._pf == false`：int 与 Boolean 松等 → 真值比较
		if (this._session.me == false && As3.truthy(this._session.currentUser._pf) == false) {
			this._navButton.visible = false;
		}
	}

	// BackgroundScreen.as:330-347
	private function createPastureBoard():Void {
		if (QzoneJSAPI.QPLUS == true || QzoneJSAPI.WB == true) {
			return;
		}
		if (this._navButton == null) {
			this._navButton = new Navigate();
			this._navButton.x = 60;
			this._navButton.y = 480;
			ButtonMaker.addTarget(this._navButton);
			this._navButton.visible = false;
			this.addChild(this._navButton);
			this.registerMouseEvent(this._navButton);
			this.updatePastureBoard();
		}
	}

	// BackgroundScreen.as:349-389
	private function onMouseEvent(param1:MouseEvent):Void {
		var _loc2d:Dynamic = param1.target;
		var _loc2_:Sprite = Std.isOfType(_loc2d, Sprite) ? cast _loc2d : null;
		if (_loc2_ == null) {
			return;
		}
		if (param1.type == MouseEvent.MOUSE_OVER) {
			if (_loc2_ == this._adD) {
				this._controller.useSystemCursor(true);
				this._controller.showTip("MouseTip", "点击设置告示牌");
			} else if (_loc2_ == this._navButton) {
				this._controller.useSystemCursor(true);
				this._controller.showTip("MouseTip", "转到牧场");
			}
		} else if (param1.type == MouseEvent.MOUSE_OUT) {
			if (_loc2_ == this._adD || _loc2_ == this._navButton) {
				this._controller.useSystemCursor(false);
				this._controller.hideTip();
			}
		} else if (param1.type == MouseEvent.CLICK) {
			if (_loc2_ == this._navButton) {
				this.onNavBtnClicked(param1);
			} else if (_loc2_ == this._adD) {
				this._controller.openDiyWindow();
				UserActionRecorder.recordAction(UserActionRecorder.HF_BILLBOARD_CLICKED);
			}
		}
	}

	// BackgroundScreen.as:391-408
	private function getHolder(param1:Int):DisplayObjectContainer {
		switch (param1) {
			case Consts.DECOR_BACKGROUND:
				return this._bgD;
			case Consts.DECOR_HOUSE:
				return this._houseD;
			case Consts.DECOR_FENCE:
				return this._fenceD;
			case Consts.DECOR_DOGHOUSE:
				return this._dogHouseD;
			case Consts.DECOR_BILLBOARD:
				return this._adD;
			default:
				return null;
		}
	}

	// BackgroundScreen.as:410-447
	private function replaceDecorate(param1:Int, param2:DisplayObject):Void {
		var _loc6_:DisplayObject = null;
		if (this._diyUrl == null || param2 == null) {
			return;
		}
		var _loc3_:Int = BackgroundModel.TYPE_TO_INDEX_MAP(param1);
		if (_loc3_ < 0 || _loc3_ >= this._diyUrl.length) {
			return;
		}
		var _loc4_:Dynamic = this._diyUrl[_loc3_];
		if (_loc4_ == null) {
			return;
		}
		var _loc5_:DisplayObjectContainer = this.getHolder(param1);
		if (_loc5_ != null) {
			if (_loc5_.numChildren > 0) {
				_loc6_ = _loc5_.getChildAt(0);
				if (_loc6_ == param2) {
					return;
				}
			}
			this.removeDecorate(param1);
			_loc5_.addChild(param2);
			Reflect.setField(_loc4_, "content", param2);
			if (_loc3_ == BackgroundModel.DECOR_INDEX_BG) {
				var _loc7d:Dynamic = param2;
				var _loc7_:DisplayObjectContainer = Std.isOfType(_loc7d, DisplayObjectContainer) ? cast _loc7d : null;
				_loc7_.addChild(this._mask);
				param2.mask = this._mask;
			}
		}
	}

	// BackgroundScreen.as:449-477
	private function removeDecorate(param1:Int):Void {
		var _loc3_:DisplayObject = null;
		var _loc4_:Dynamic;
		var _loc2_:DisplayObjectContainer = this.getHolder(param1);
		if (_loc2_ != null) {
			_loc3_ = null;
			while (_loc2_.numChildren > 0) {
				_loc3_ = _loc2_.removeChildAt(0);
				if (_loc3_ != null && _loc3_.loaderInfo != null && _loc3_.loaderInfo.loader != null) {
					// AS3 hasOwnProperty("unloadAndStop")：openfl Loader 无该成员 →
					// 恒 false 不触发；原版释放远程 swf 的语义已由本地化资产机制承担
					var _loc5_:Dynamic = _loc3_.loaderInfo.loader;
					if (Reflect.hasField(_loc5_, "unloadAndStop") == true) {
						_loc5_.unloadAndStop(true);
					}
				}
			}
		}
		if (this._diyUrl != null) {
			// AS3 `!= undefined`：槽对象恒非 undefined（越界/未建槽得 null）
			_loc4_ = this._diyUrl[BackgroundModel.TYPE_TO_INDEX_MAP(param1)];
			if (_loc4_ != null) {
				Reflect.setField(_loc4_, "content", null);
			}
		}
	}

	// BackgroundScreen.as:479-488
	private function registerMouseEvent(param1:EventDispatcher):Void {
		if (param1 == null) {
			return;
		}
		param1.addEventListener(MouseEvent.MOUSE_OVER, this.onMouseEvent, false, 0, true);
		param1.addEventListener(MouseEvent.MOUSE_OUT, this.onMouseEvent, false, 0, true);
		param1.addEventListener(MouseEvent.CLICK, this.onMouseEvent, false, 0, true);
	}

	// BackgroundScreen.as:490-497
	public function enableBillboard(param1:Bool):Void {
		if (this._adD != null) {
			this._adD.mouseEnabled = param1;
			this._adD.mouseChildren = param1;
		}
	}
}
