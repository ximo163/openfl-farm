package module.levelup;

import com.qzone.corelib.net.RSLLoader;
import com.qzone.qui.managers.PopUpManager;
import common.CommonData;
import common.Settings;
import common.misc.QzoneJSAPI;
import common.misc.Utils;
import entities.Seed;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.MouseEvent;
import module.FarmApplication;
import report.ClickReportManager;
import shim.As3;
import shim.QQOutlets;

/**
 * module.levelup.LevelUpWindow —— LevelUpWindow.as 逐句对应（issue #18 升级
 * 模块片）。升级弹窗：按 shareType 五选面板素材（bigPanel/seedsPanel/
 * landPanel/nextLandPanel/emptyPanel），黄钻双按钮、分享文案三档（≤27/≤69/
 * 70+），地块行 + 种子行排版（AlignUtils），ExternalInterface 走 fusion2 分享
 * （QQOutlets no-op 出口）。面板素材不在时经 RSLLoader 拉 getPanelURL。
 * PORT-NOTE:
 * - `this._panelUI["levelTxt"]` 等（swf 符号具名子件）→ As3.childOf；
 *   `.htmlText =` / `.y +=` / `.visible =` / `.buttonMode =` 按名读写走
 *   Reflect.setProperty/getProperty（js 裸 Dynamic 写只落影子字段）。
 * - `this._landInfo.xxx`（匿名记录）→ Reflect.field / setField。
 * - ExternalInterface.available/call → QQOutlets（deviations no-qzone-jsapi）。
 * - Update.landPanel / nextLandPanel 部署包缺符号（UpdateLandPanel 空壳注）。
 */
@:keep
class LevelUpWindow extends Sprite {
	// LevelUpWindow.as:20-28
	private static final LAND_AND_SEEDS:Int = 1;

	private static final ONLY_SEEDS:Int = 2;

	private static final ONLY_LAND:Int = 3;

	private static final ONLY_LAND_NEXT:Int = 4;

	private static final ONLY_TEXT:Int = 5;

	// :30-44
	private var _shareType:Int;

	private var _level:Int;

	private var _newSeedsInfo:Array<Dynamic>;

	private var _landInfo:Dynamic;

	private var _panelUI:Sprite;

	private var _app:FarmApplication;

	private var _model:LevelUpModel;

	private var _panelClass:Class<Dynamic>;

	// :46-54
	public function new(param1:Int, param2:LevelUpModel, param3:FarmApplication) {
		super();
		this._level = param1;
		this._model = param2;
		this._app = param3;
		this.initData();
		this.initUI();
	}

	// :56-73
	private function getLandTip():String {
		var _loc1_:String = "<font color='#666666'>升级后，可扩建";
		var _loc2_:String = "";
		if (As3.truthy(Reflect.field(this._landInfo, "normal"))) {
			_loc2_ = this.addComma(_loc2_, "黄土地<font color='#FF6600'>1</font>块");
		}
		if (As3.truthy(Reflect.field(this._landInfo, "red"))) {
			_loc2_ = this.addComma(_loc2_, "红土地<font color='#FF6600'>1</font>块");
		}
		if (As3.truthy(Reflect.field(this._landInfo, "black"))) {
			_loc2_ = this.addComma(_loc2_, "黑土地<font color='#FF6600'>1</font>块");
		}
		return _loc1_ + _loc2_ + "</font>";
	}

	// :75-129
	private function createSeedsView(param1:Sprite, param2:Bool):Void {
		var _loc4_:SeedItemRender = null;
		var _loc5_:Int = 0;
		var _loc7_:Sprite = null;
		var _loc3_:Sprite = new Sprite();
		var _loc6_:Sprite = new Sprite();
		var _loc8_:Int = param2 ? 5 : 6;
		var _loc9_:Int = 0;
		// :100 int ← Math.min 的 Number 截断。
		var _loc10_:Int = Std.int(Math.min(this._newSeedsInfo.length, _loc8_));
		while (_loc9_ < _loc10_) {
			_loc4_ = new SeedItemRender(this._newSeedsInfo[_loc9_]);
			if (!param2 && _loc9_ >= 3) {
				_loc5_ = AlignUtils.getPositionX_ROW(_loc9_ - 3, SeedItemRender.ROW_GAP);
				_loc4_.x = _loc5_;
				if (_loc7_ == null) {
					_loc7_ = new Sprite();
				}
				_loc7_.addChild(_loc4_);
			} else {
				_loc5_ = AlignUtils.getPositionX_ROW(_loc9_, SeedItemRender.ROW_GAP);
				_loc4_.x = _loc5_;
				_loc6_.addChild(_loc4_);
			}
			_loc9_++;
		}
		if (param2) {
			_loc3_.addChild(_loc6_);
			AlignUtils.align_TOP_CENTER(param1, _loc3_);
		} else {
			_loc3_.addChild(_loc6_);
			if (_loc7_ != null) {
				_loc3_.addChild(_loc7_);
				AlignUtils.align_TOP_CENTER(_loc3_, _loc7_);
				_loc7_.y = SeedItemRender.COLUMN_GAP;
				_loc3_.addChild(_loc7_);
			}
			AlignUtils.align_CENTER(param1, _loc3_);
		}
		_loc3_.x += param1.x;
		_loc3_.y += param1.y;
		if (this._panelUI != null) {
			this._panelUI.addChild(_loc3_);
		}
	}

	// :131-170
	private function createLandView(param1:Sprite, param2:Bool):Void {
		var _loc3_:LandRender = null;
		var _loc4_:Sprite = new Sprite();
		var _loc5_:Int = 0;
		if (As3.truthy(Reflect.field(this._landInfo, "normal"))) {
			this.addLand(LandRender.NORMAL_LAND, _loc4_, _loc5_, param2);
			_loc5_++;
		}
		if (As3.truthy(Reflect.field(this._landInfo, "red"))) {
			this.addLand(LandRender.RED_LAND, _loc4_, _loc5_, param2);
			_loc5_++;
		}
		if (As3.truthy(Reflect.field(this._landInfo, "black")) || As3.truthy(Reflect.field(this._landInfo, "next"))) {
			this.addLand(LandRender.BLACK_LAND, _loc4_, _loc5_, param2);
			_loc5_++;
		}
		if (param2) {
			AlignUtils.align_TOP_CENTER(param1, _loc4_);
		} else {
			AlignUtils.align_LEFT_CENTER(param1, _loc4_);
		}
		if (!param2 && _loc5_ == 1) {
			Reflect.setProperty(As3.childOf(this._panelUI, "landTxt"), "y", 230);
			_loc4_.y -= 18;
		}
		_loc4_.x += param1.x;
		_loc4_.y += param1.y;
		if (this._panelUI != null) {
			this._panelUI.addChild(_loc4_);
		}
	}

	// :172-175
	public function onShareSuccess(param1:Dynamic):Void {
		ClickReportManager.reportClick("share.levelUp.page_share_btn_click_nc");
	}

	// :177-192
	private function closeWin(param1:Event = null):Void {
		this._model.removeEventListener(LevelUpModel.EVENT_SEEDS_DATA_LOADED, this.__onSeedInfo);
		if (this._panelUI != null) {
			if (contains(this._panelUI)) {
				removeChild(this._panelUI);
			}
			As3.childOf(this._panelUI, "isYellowBtn").removeEventListener(MouseEvent.CLICK, this.gotoYellow);
			As3.childOf(this._panelUI, "notYellowBtn").removeEventListener(MouseEvent.CLICK, this.gotoYellow);
			As3.childOf(this._panelUI, "shutBtn").removeEventListener(MouseEvent.CLICK, this.closeWin);
			As3.childOf(this._panelUI, "shareBtn").removeEventListener(MouseEvent.CLICK, this.share);
		}
		PopUpManager.removePopUp(this);
	}

	// :194-205
	private function getLevelTxtY():Int {
		if (this._level < 10) {
			return -18;
		}
		if (this._level < 100) {
			return 0;
		}
		return 10;
	}

	// :207-268
	private function initData():Void {
		var _loc1_:Int = 0;
		if (this._level <= 60) {
			_loc1_ = LevelUpModel.NORMAL_LAND_UPDATE_INFO.indexOf(this._level);
			if (_loc1_ > -1) {
				if (this._landInfo == null) {
					this._landInfo = {};
				}
				Reflect.setField(this._landInfo, "normal", true);
			}
			_loc1_ = LevelUpModel.RED_LAND_UPDATE_INFO.indexOf(this._level);
			if (_loc1_ > -1) {
				if (this._landInfo == null) {
					this._landInfo = {};
				}
				Reflect.setField(this._landInfo, "red", true);
			}
			_loc1_ = LevelUpModel.BLACK_LAND_UPDATE_INFO_NUM.indexOf(this._level);
			if (_loc1_ > -1) {
				if (this._landInfo == null) {
					this._landInfo = {};
				}
				Reflect.setField(this._landInfo, "black", true);
			}
		} else if (this._level < 70) {
			if (this._landInfo == null) {
				this._landInfo = {};
			}
			_loc1_ = LevelUpModel.BLACK_LAND_UPDATE_INFO_NUM.indexOf(this._level);
			if (_loc1_ > -1) {
				Reflect.setField(this._landInfo, "black", true);
			} else {
				Reflect.setField(this._landInfo, "next", true);
				_loc1_ = LevelUpModel.BLACK_LAND_UPDATE_INFO_NUM.indexOf(this._level + 1);
				Reflect.setField(this._landInfo, "index", _loc1_ + 1);
			}
		}
		this._newSeedsInfo = this._model.seeds;
		if (this._newSeedsInfo == null) {
			this._model.addEventListener(LevelUpModel.EVENT_SEEDS_DATA_LOADED, this.__onSeedInfo);
			this._model.loadSeedsInfo();
		} else {
			this.__onSeedInfo();
		}
	}

	// :270-283（AS3 for-each(_loc3_:Seed in _loc2_)：值遍历。cast 目标带
	// 类型参数时参数必须是 Dynamic——数组层收窄成 Array<Dynamic>，循环变量
	// 保 Seed 类型（Dynamic 迭代元素隐式统一）。）
	private function __onSeedInfo(param1:Event = null):Void {
		var _loc3_:Seed = null;
		this._newSeedsInfo = [];
		var _loc2_:Array<Dynamic> = this._model.seeds;
		for (_loc3_ in _loc2_) {
			if (_loc3_._lvl == this._level) {
				this._newSeedsInfo.push(_loc3_);
			}
		}
		this.checkAllReady();
	}

	// :285-326（share：ExternalInterface → QQOutlets，PORT-NOTE(qq-outlet)）
	private function share(param1:MouseEvent):Void {
		var _loc8_:String = null;
		ClickReportManager.reportClick("share.levelUp.flash_share_btn_click_nc");
		var _loc2_:String = "";
		var _loc3_:String = "";
		var _loc4_:String = "叮咛啷当吖，咱老百姓呐，今儿真开心哇，我的农场又升一级啦!";
		if (this._level <= 27) {
			_loc3_ = "功夫不负苦心人，农场等级升升升，经过辛勤劳作，农场升到" + this._level
				+ "级啦，还有丰富种子相赠，你也来看看吧！";
		} else if (this._level <= 69) {
			if (this._level == 62 || this._level == 64 || this._level == 66 || this._level == 68) {
				_loc3_ = "在山的那边有一块黑土地，它们肥沃又美丽，它们神秘又神奇，升到" + (this._level + 1)
					+ "级就可以开启我第" + Reflect.field(this._landInfo, "index") + "块黑土地啦！";
			} else {
				_loc3_ = "种菜那件小事，贵在坚持，功到自然成。轻松升到" + this._level
					+ "级了，更广阔的土地、更新奇的作物等着我开垦和收获~";
			}
		} else {
			_loc3_ = "华丽丽的升到" + this._level
				+ "级！种菜神技已被我练得出神入化、炉火纯青、登峰造极（以上省略一万字），来比试一下？";
		}
		var _loc5_:String = this._model.getLevelUpPicURL();
		var _loc6_:String = "";
		_loc6_ = _loc6_ + "%26from%3DlevelUpShare";
		var _loc7_:String = "炫耀一下！";
		CommonData.addCallBackProxy("onSuccess", this.onShareSuccess);
		// PORT-NOTE(qq-outlet)：ExternalInterface.available/call → QQOutlets
		if (QQOutlets.available) {
			_loc8_ = "fusion2.dialog.share(" + "{title:'" + _loc7_ + "',summary:'" + _loc4_ + "',pics:'" + _loc5_
				+ "',desc:'" + _loc3_ + "',url:'" + _loc6_
				+ "',onSuccess:function (opt){swfAppObject.onSuccess(opt);}"
				+ ",onCancel:function (opt){swfAppObject.onCancel(opt);}"
				+ ",onClose:function (opt){swfAppObject.onClose(opt);}})";
			if (Settings.getInstance().getStringAttribute("agent") == "weibo") {
				_loc8_ = "fusion2.dialog.share(" + "{title:'" + _loc7_ + "',summary:'" + _loc4_ + "',pics:'" + _loc5_
					+ "',desc:'" + _loc3_ + "',url:'" + _loc6_
					+ "',onSuccess:function (opt){swfAppObject.onSuccess(opt);}"
					+ ",onCancel:function (opt){swfAppObject.onCancel(opt);}"
					+ ",onClose:function (opt){swfAppObject.onClose(opt);}})";
			}
			QQOutlets.call(_loc8_);
		}
		this.closeWin();
	}

	// :328-335
	private function __onLoadOK(param1:Event):Void {
		this._panelClass = Utils.getClass("Update.bigPanel");
		if (this._panelClass != null) {
			this.checkAllReady();
		}
	}

	// :337-348
	private function getLevelTxtSize():Int {
		if (this._level < 10) {
			return 73;
		}
		if (this._level < 100) {
			return 55;
		}
		return 46;
	}

	// :350-366
	private function initUI():Void {
		var _loc1_:String = null;
		var _loc2_:RSLLoader = null;
		this._panelClass = Utils.getClass("Update.bigPanel");
		if (this._panelClass != null) {
			this.checkAllReady();
		} else {
			_loc1_ = this._model.getPanelURL();
			_loc2_ = new RSLLoader();
			_loc2_.listCompleteFn = this.__onLoadOK;
			_loc2_.load([{"url": _loc1_}]);
		}
	}

	// :368-440（每个分支 `Utils.getMaterial(...) as Sprite`：取一次素材再
	// isOfType 门 + 直取，别双调 getMaterial——符号壳会构造两份）
	private function createPanel():Void {
		var _loc1_:Dynamic = null;
		var _loc2_:Dynamic = null;
		if (this._shareType == LAND_AND_SEEDS) {
			_loc2_ = Utils.getMaterial("Update.bigPanel");
			this._panelUI = Std.isOfType(_loc2_, Sprite) ? cast(_loc2_, Sprite) : null;
		} else if (this._shareType == ONLY_SEEDS) {
			_loc2_ = Utils.getMaterial("Update.seedsPanel");
			this._panelUI = Std.isOfType(_loc2_, Sprite) ? cast(_loc2_, Sprite) : null;
		} else if (this._shareType == ONLY_LAND) {
			_loc2_ = Utils.getMaterial("Update.landPanel");
			this._panelUI = Std.isOfType(_loc2_, Sprite) ? cast(_loc2_, Sprite) : null;
		} else if (this._shareType == ONLY_LAND_NEXT) {
			_loc2_ = Utils.getMaterial("Update.nextLandPanel");
			this._panelUI = Std.isOfType(_loc2_, Sprite) ? cast(_loc2_, Sprite) : null;
		} else if (this._shareType == ONLY_TEXT) {
			_loc2_ = Utils.getMaterial("Update.emptyPanel");
			this._panelUI = Std.isOfType(_loc2_, Sprite) ? cast(_loc2_, Sprite) : null;
		}
		if (this._panelUI != null) {
			_loc1_ = As3.childOf(this._panelUI, "levelTxt");
			Reflect.setProperty(_loc1_, "htmlText",
				"<font size='" + this.getLevelTxtSize() + "'>" + Std.string(this._level) + "</font>");
			Reflect.setProperty(_loc1_, "y", Reflect.getProperty(_loc1_, "y") + this.getLevelTxtY());
			if (this._model.isYellow()) {
				Reflect.setProperty(As3.childOf(this._panelUI, "isYellowBtn"), "visible", true);
				Reflect.setProperty(As3.childOf(this._panelUI, "notYellowBtn"), "visible", false);
				Reflect.setProperty(As3.childOf(this._panelUI, "isYellowBtn"), "buttonMode", true);
				As3.childOf(this._panelUI, "isYellowBtn").addEventListener(MouseEvent.CLICK, this.gotoYellow);
			} else {
				Reflect.setProperty(As3.childOf(this._panelUI, "isYellowBtn"), "visible", false);
				Reflect.setProperty(As3.childOf(this._panelUI, "notYellowBtn"), "visible", true);
				Reflect.setProperty(As3.childOf(this._panelUI, "notYellowBtn"), "buttonMode", true);
				As3.childOf(this._panelUI, "notYellowBtn").addEventListener(MouseEvent.CLICK, this.gotoYellow);
			}
			Reflect.setProperty(As3.childOf(this._panelUI, "shutBtn"), "buttonMode", true);
			Reflect.setProperty(As3.childOf(this._panelUI, "shareBtn"), "buttonMode", true);
			As3.childOf(this._panelUI, "shutBtn").addEventListener(MouseEvent.CLICK, this.closeWin);
			As3.childOf(this._panelUI, "shareBtn").addEventListener(MouseEvent.CLICK, this.share);
			if (this._shareType == LAND_AND_SEEDS) {
				Reflect.setProperty(As3.childOf(this._panelUI, "landTxt"), "htmlText", this.getLandTip());
				this.createLandView(cast As3.childOf(this._panelUI, "landHoldr"), false);
				this.createSeedsView(cast As3.childOf(this._panelUI, "seedsHolder"), false);
			} else if (this._shareType == ONLY_SEEDS) {
				this.createSeedsView(cast As3.childOf(this._panelUI, "seedsHolder"), true);
			} else if (this._shareType == ONLY_LAND_NEXT) {
				Reflect.setProperty(As3.childOf(this._panelUI, "landTxt"), "htmlText",
					"<font color='#714423'>再升<font color='#FF6600'>1</font>级，您就可以扩第<font color='#FF6600'>"
					+ Reflect.field(this._landInfo, "index") + "</font>块黑土地了！</font>");
				this.createLandView(cast As3.childOf(this._panelUI, "landHoldr"), true);
			} else if (this._shareType == ONLY_LAND) {
				Reflect.setProperty(As3.childOf(this._panelUI, "landTxt"), "htmlText", this.getLandTip());
				this.createLandView(cast As3.childOf(this._panelUI, "landHoldr"), true);
			} else if (this._shareType == ONLY_TEXT) {
				Reflect.setProperty(As3.childOf(this._panelUI, "tipTxt"), "htmlText",
					"<font color='#714423'>您升级到<font color='#FF6600'>" + this._level
					+ "</font>级了，快来分享给好友吧！</font>");
			}
		}
		addChild(this._panelUI);
		PopUpManager.addPopUp(this, true);
		ClickReportManager.reportClick("share.levelUp.level_up_window_show_nc");
	}

	// :442-468（`Boolean(this._landInfo.next)` 显式取真）
	private function checkAllReady():Void {
		if (this._newSeedsInfo != null && this._panelClass != null) {
			if (this._newSeedsInfo.length > 0 && this._landInfo != null) {
				this._shareType = LAND_AND_SEEDS;
			} else if (this._newSeedsInfo.length > 0) {
				this._shareType = ONLY_SEEDS;
			} else if (this._landInfo != null && As3.truthy(Reflect.field(this._landInfo, "next"))) {
				this._shareType = ONLY_LAND_NEXT;
			} else if (this._landInfo != null) {
				this._shareType = ONLY_LAND;
			} else {
				this._shareType = ONLY_TEXT;
			}
			this.createPanel();
		}
	}

	// :470-494
	private function addLand(param1:Int, param2:Sprite, param3:Int, param4:Bool):Void {
		var _loc5_:LandRender = null;
		if (param1 == LandRender.NORMAL_LAND) {
			_loc5_ = new LandRender({"landType": LandRender.NORMAL_LAND});
		} else if (param1 == LandRender.RED_LAND) {
			_loc5_ = new LandRender({"landType": LandRender.RED_LAND});
		} else if (param1 == LandRender.BLACK_LAND) {
			_loc5_ = new LandRender({"landType": LandRender.BLACK_LAND});
		}
		if (param4) {
			_loc5_.x = AlignUtils.getPositionX_ROW(param3, LandRender.ROW_GAP);
		} else {
			_loc5_.y = AlignUtils.getPositionY_COLUMN(param3, LandRender.COLUMN_GAP);
		}
		param2.addChild(_loc5_);
	}

	// :496-499
	private function gotoYellow(param1:Event):Void {
		QzoneJSAPI.openWindow(this._model.getYellowURL());
	}

	// :501-508
	private function addComma(param1:String, param2:String):String {
		if (param1.length > 0) {
			param1 += "，";
		}
		return param1 + param2;
	}

	// :510-517
	private function getCutName(param1:String, param2:Int = 7):String {
		if (param1.length > param2) {
			param1 = param1.substr(0, param2 - 1);
		}
		return param1;
	}
}
