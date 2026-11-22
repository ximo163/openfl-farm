package module.warehouse.bag;

import EvtAPI;
import com.qzone.qui.controls.Button;
import com.qzone.qui.controls.HList;
import com.qzone.qui.controls.Label;
import com.qzone.utils.AlignUtil;
import common.CommonData;
import common.Consts;
import common.Language;
import common.Session;
import common.Settings;
import common.misc.Utils;
import common.view.DataLoading;
import common.view.cursor.CursorControl;
import entities.BagItem;
import events.CommonEvent;
import events.ViewEvent;
import framework.api.beast.BeastAPI;
import module.GameGuide;
import openfl.display.MovieClip;
import openfl.display.SimpleButton;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.text.TextField;
import openfl.text.TextFieldAutoSize;
import openfl.text.TextFormat;
import openfl.text.TextFormatAlign;
import report.UserActionRecorder;
import shim.As3;

/**
 * module.warehouse.bag.MyBagView —— MyBagView.as 逐句对应（issue #36
 * 功能 swf 翻译：仓库）。背包条（Sprite）：PackBarBg 底条 + PackageTab 三
 * 页签（种子/成鱼/道具）+ HList 六格瓦片 + 空袋/未开通池塘/装载三态。
 * 视觉参数逐字照抄（坐标/颜色/文案原样）。
 *
 * PORT-NOTE: 构造器里 AS3 先 `BeastAPI.getInstance()` 后 super()（Haxe 强制
 * super 先行，getInstance 是无状态单例取值，顺序无副作用）；`x as T` 的
 * material 取件 → Std.isOfType 判型（UnlockFishWindow 先例）；MyBagModel
 * 四个 EVENT_* 原文 private → onAddedToStage 加 @:access 跨类读；
 * `data as Boolean` → As3.truthy；`data == "reload"` → As3.eqString；
 * `new Date(_showTipsEndTime)` 的美式日期串 → As3.dateOf（FarmLand 先例，
 * null 前置判，原版 Invalid Date 比较恒 false 同形）；`_type.toString()`
 * → Std.string（Int 串化后与字串常量直比，等值语义同 AS3）；Int 参与串接
 * 处经 Std.string 显式化；`Language.L["…"]` → Reflect.field（PreviewDiyWindow
 * 先例）。
 */
class MyBagView extends Sprite {
	// MyBagView.as:35
	private var m_bLoading:Bool;

	// MyBagView.as:37
	private var _showTipsEndTime:String = "7/26/2012 23:59:5";

	// MyBagView.as:39
	private var _closeBtnTipsBg:Sprite;

	// MyBagView.as:41
	private var m_controller:MyBagController;

	// MyBagView.as:43
	private var m_list:HList;

	// MyBagView.as:45
	private var m_notOpenText:TextField;

	// MyBagView.as:47
	private var m_switchBtn:MovieClip;

	// MyBagView.as:49
	private var m_emptyText:TextField;

	// MyBagView.as:51
	private var m_mgrLabel:Label;

	// MyBagView.as:53
	private var m_hideTimer:UInt;

	// MyBagView.as:55
	private var _showCloseTips:Bool = true;

	// MyBagView.as:57
	private var m_closeBtn:SimpleButton;

	// MyBagView.as:59
	private var m_model:MyBagModel;

	// MyBagView.as:61
	private var m_btnGoWarehouse:Button;

	// MyBagView.as:63
	private var _api:BeastAPI;

	// MyBagView.as:65
	private var m_bg:Sprite;

	// MyBagView.as:67
	private var m_dataLoading:DataLoading;

	// MyBagView.as:69
	private var _selectTab:String = "normal";

	// MyBagView.as:71-93
	public function new(param1:MyBagController) {
		// PORT-NOTE: AS3 在 super() 前先取 BeastAPI 单例；Haxe 强制 super
		// 先行（取值无副作用，顺序等价）
		super();
		var controller:MyBagController = param1;
		this._api = BeastAPI.getInstance();
		this.m_bg = Std.isOfType(Utils.getMaterial("PackBarBg"), Sprite) ? cast(Utils.getMaterial("PackBarBg"), Sprite) : null;
		if (this.m_bg != null) {
			addChild(this.m_bg);
		}
		this.createButtons();
		this.createList();
		this.m_hideTimer = 0;
		this.m_bLoading = false;
		this.m_controller = controller;
		this.m_model = this.m_controller.model;
		addEventListener(Event.ADDED_TO_STAGE, this.onAddedToStage);
		this._api.addEventListener(EvtAPI.SHOW_BEAST_PACK, this.hideThis);
		this.m_controller.module.app.addEventListener(Consts.MSG_POOL_OPEN, function():Void {
			setVisible();
		});
	}

	// MyBagView.as:95-98
	private function hideThis(param1:EvtAPI):Void {
		this.show(false);
	}

	// MyBagView.as:100-104
	private function onLoadFailed(param1:CommonEvent):Void {
		var _loc2_:String = Reflect.field(Language.L, "请求超时，") + "<a href='event:reload'><u><font color='#ff6600'>"
			+ Reflect.field(Language.L, "点击重试") + "</font></u></a>";
		this.m_dataLoading.errorText = _loc2_;
	}

	// MyBagView.as:106-113
	private function selectNormal(param1:Event = null):Void {
		this._selectTab = "normal";
		this.m_mgrLabel.visible = true;
		this.m_list.dataProvider = this.m_model.fillterType("normal");
		this.setVisible();
		UserActionRecorder.recordAction(UserActionRecorder.HF_BAG_NORAML_CLICKED);
	}

	// MyBagView.as:115-118
	private function onTimeout():Void {
		this.show(false);
	}

	// MyBagView.as:120-145
	private function onChildClick(param1:ViewEvent):Void {
		if (param1 == null || param1.data == null) {
			return;
		}
		var _loc2_:BagItem = Std.isOfType(param1.data, BagItem) ? cast(param1.data, BagItem) : null;
		if (_loc2_ == null) {
			return;
		}
		var _loc3_:String = Std.string(_loc2_._type);
		if (_loc3_ == Consts.ITEM_TYPE_SEED || _loc3_ == Consts.ITEM_TYPE_FISH) {
			this.m_controller.setCursor(Consts.CURSOR_STYLE_CROPSEED, _loc3_ + "," + Std.string(_loc2_._cId));
		} else if (_loc3_ == Consts.ITEM_TYPE_TOOL || _loc3_ == Consts.ITEM_TYPE_FISHFEED) {
			this.m_controller.setCursor(Consts.CURSOR_STYLE_TOOL, _loc3_ + "," + Std.string(_loc2_._cId));
			this.visible = false;
		}
		if (_loc3_ == Consts.ITEM_TYPE_FISH) {
			this.m_controller.module.app.dispatchEvent(new CommonEvent(Consts.MSG_FISH_GUIDE, {"step": GameGuide.WATER_POOL_CENTER}));
		}
	}

	// MyBagView.as:147-174
	private function onDataLoaded(param1:CommonEvent):Void {
		if (param1 == null || param1.data == null) {
			return;
		}
		this.m_bLoading = false;
		var _loc2_:Int = 0;
		if (this.m_list.hScrollBar != null) {
			_loc2_ = Std.int(this.m_list.hScrollBar.scrollPosition);
		}
		switch (this._selectTab) {
			case "normal":
				this.selectNormal();
			case "fish":
				this.selectFish();
			case "tool":
				this.selectTool();
		}
		if (_loc2_ > 0) {
			this.m_list.hScrollBar.scrollPosition = _loc2_;
		}
	}

	// MyBagView.as:176-179
	private function onChildOut(param1:ViewEvent):Void {
		this.m_controller.hideTip();
	}

	// MyBagView.as:181-195。MyBagModel 的 EVENT_* 原文 private → @:access
	@:access(module.warehouse.bag.MyBagModel)
	private function onAddedToStage(param1:Event):Void {
		param1.target.removeEventListener(Event.ADDED_TO_STAGE, this.onAddedToStage);
		this.adjustPosition();
		addEventListener(MouseEvent.ROLL_OVER, this.onOver);
		addEventListener(MouseEvent.CLICK, this.onClick);
		var _loc2_:MyBagModel = this.m_controller.model;
		if (_loc2_ != null) {
			_loc2_.addEventListener(MyBagModel.EVENT_INITIALZED, this.onDataLoaded);
			_loc2_.addEventListener(MyBagModel.EVENT_LOAD_FAILED, this.onLoadFailed);
			_loc2_.addEventListener(MyBagModel.EVENT_LOADING, this.onDataLoading);
			_loc2_.addEventListener(MyBagModel.EVENT_UPDATED, this.onDataUpdated);
		}
	}

	// MyBagView.as:197-222
	private function setVisible():Void {
		this.m_notOpenText.visible = false;
		if (this.m_bLoading == true) {
			this.m_mgrLabel.visible = false;
			this.m_list.visible = false;
			this.m_dataLoading.visible = true;
			this.m_btnGoWarehouse.visible = false;
			this.m_emptyText.visible = false;
		} else if (this.m_list.dataProvider != null && this.m_list.dataProvider.length > 0) {
			this.m_list.visible = true;
			this.m_dataLoading.visible = false;
			this.m_btnGoWarehouse.visible = false;
			this.m_emptyText.visible = false;
		} else {
			this.m_list.visible = false;
			this.m_dataLoading.visible = false;
			this.m_btnGoWarehouse.visible = true;
			this.m_emptyText.visible = true;
		}
	}

	// MyBagView.as:224-231
	private function selectTool(param1:Event = null):Void {
		this._selectTab = "tool";
		this.m_mgrLabel.visible = false;
		this.m_list.dataProvider = this.m_model.fillterType("tool");
		this.setVisible();
		UserActionRecorder.recordAction(UserActionRecorder.HF_BAG_TOOL_CLICKED);
	}

	// MyBagView.as:233-261
	private function showCloseBtnTips():Void {
		var text:TextField = null;
		var now:Float = CommonData.serverTime * 1000;
		var end:Date = As3.dateOf(this._showTipsEndTime);
		// dateOf 解析失败为 null（原版 Invalid Date 恒 false 的等形；本串可解析）
		if (end != null && now < end.getTime()) {
			this._closeBtnTipsBg = new Sprite();
			this._closeBtnTipsBg.graphics.beginFill(16777215, 0.8);
			this._closeBtnTipsBg.graphics.drawRoundRect(0, 0, 80, 23, 10, 10);
			this._closeBtnTipsBg.graphics.endFill();
			text = new TextField();
			text.text = "点击这里关闭";
			text.height = 20;
			this._closeBtnTipsBg.addChild(text);
			text.y = 1;
			addChild(this._closeBtnTipsBg);
			this._closeBtnTipsBg.x = this.m_closeBtn.x - 37;
			this._closeBtnTipsBg.y = this.m_closeBtn.y - 40;
			As3.setTimeout(function():Void {
				if (this._closeBtnTipsBg.parent != null) {
					this._closeBtnTipsBg.parent.removeChild(this._closeBtnTipsBg);
					this._closeBtnTipsBg = null;
				}
			}, 3000);
		}
	}

	// MyBagView.as:263-277
	private function createList():Void {
		this.m_list = new HList();
		this.m_list.defaultSkin = null;
		this.m_list.itemRenderer = PackItem;
		this.m_list.x = 35;
		this.m_list.y = 25;
		this.m_list.rowCount = 6;
		this.m_list.rowHeight = 63;
		this.m_list.height = 80;
		addChild(this.m_list);
		addEventListener(ViewEvent.CHILD_CLICK, this.onChildClick);
		addEventListener(ViewEvent.CHILD_OVER, this.onChildOver);
		addEventListener(ViewEvent.CHILD_OUT, this.onChildOut);
	}

	// MyBagView.as:279-295
	private function onEmptyTextClicked(param1:MouseEvent):Void {
		var _loc2_:Int = 0;
		this.show(false);
		switch (this._selectTab) {
			case "normal":
				_loc2_ = 0;
			case "fish":
				_loc2_ = 1;
			case "tool":
				_loc2_ = 2;
		}
		this.m_controller.module.app.dispatchEvent(new CommonEvent(Consts.MSG_SHOW_SHOP, {"tabIndex": _loc2_}));
	}

	// MyBagView.as:297-304
	private function onLoadingLinkClicked(param1:ViewEvent):Void {
		if (As3.eqString(param1.data, "reload")) {
			this.m_controller.model.reload();
			this.m_dataLoading.visible = true;
		}
	}

	// MyBagView.as:306-344
	public function switchTab(param1:Int):Void {
		if (this.m_switchBtn == null) {
			return;
		}
		if (param1 < 0 || param1 >= this.m_switchBtn.totalFrames) {
			return;
		}
		if (param1 + 1 == this.m_switchBtn.currentFrame) {
			return;
		}
		if (param1 == 1) {
			this.m_switchBtn.gotoAndStop(3);
		} else if (param1 == 0) {
			this.m_switchBtn.gotoAndStop(1);
		} else {
			this.m_switchBtn.gotoAndStop(2);
		}
		if (param1 == 0) {
			this.selectNormal();
		} else if (param1 == 1) {
			this.selectFish();
		} else if (param1 == 2) {
			this.selectTool();
		}
	}

	// MyBagView.as:346-351
	public function onPoolOrLandIsFull(param1:Event):Void {
		this.show(false);
		var _loc2_:CursorControl = this.m_controller.module.app.farmView.cursorCtrl;
		_loc2_.setCursor(Consts.CURSOR_STYLE_ARROW);
	}

	// MyBagView.as:353-405
	private function onDataUpdated(param1:CommonEvent):Void {
		var _loc5_:Bool = false;
		var _loc6_:Int = 0;
		if (param1 == null || param1.data == null) {
			return;
		}
		var _loc2_:BagItem = Reflect.field(param1.data, "item");
		if (_loc2_ == null) {
			return;
		}
		var _loc3_:Int = 0;
		var _loc4_:PackItem = null;
		if (_loc2_._amount <= 0) {
			this.m_list.removeItem(_loc2_);
			if (this.m_list.dataProvider == null || this.m_list.dataProvider.length == 0) {
				this.setVisible();
			}
			this.m_controller.setCursor(Consts.CURSOR_STYLE_ARROW, "");
		} else {
			_loc5_ = false;
			_loc6_ = Std.int(this.m_list.content.numChildren);
			_loc3_ = 0;
			while (_loc3_ < _loc6_) {
				_loc4_ = Std.isOfType(this.m_list.content.getChildAt(_loc3_), PackItem) ? cast(this.m_list.content.getChildAt(_loc3_), PackItem) : null;
				if (_loc4_ != null && _loc4_.data == _loc2_) {
					_loc5_ = true;
					break;
				}
				_loc3_++;
			}
			if (_loc5_ == true && _loc4_ != null) {
				_loc4_.setAmount(_loc2_._amount);
			} else if (Std.string(_loc2_._type) == Consts.ITEM_TYPE_SEED) {
				// addItemAt 的 ...rest → 数组参（ListBase 类头 ⑥）
				this.m_list.addItemAt(0, [_loc2_]);
			} else {
				this.m_list.addItemAt(_loc6_, [_loc2_]);
			}
		}
	}

	// MyBagView.as:407-415
	private function onDataLoading(param1:CommonEvent):Void {
		if (param1 == null) {
			return;
		}
		this.m_bLoading = As3.truthy(param1.data);
		this.setVisible();
	}

	// MyBagView.as:417-420
	private function onClose(param1:MouseEvent):Void {
		this.onTimeout();
	}

	// MyBagView.as:422-425
	private function onOver(param1:MouseEvent):Void {
		this.m_controller.useSystemCursor(true);
	}

	// MyBagView.as:427-436
	private function adjustPosition():Void {
		if (this.m_bg != null) {
			this.m_bg.width = 450;
			this.m_bg.height = 110;
		}
		x = stage.mouseX - this.width * 0.5;
		y = stage.stageHeight - 58 - this.height;
	}

	// MyBagView.as:438-442
	private function onMgrLinkClicked(param1:Event):Void {
		this.show(false);
		this.m_controller.module.app.dispatchEvent(new CommonEvent(Consts.MSG_SHOW_WAREHOUSE, {"openWithSeeds": true}));
	}

	// MyBagView.as:444-499
	private function createButtons():Void {
		this.m_closeBtn = Std.isOfType(Utils.getMaterial("PackClose"), SimpleButton) ? cast(Utils.getMaterial("PackClose"), SimpleButton) : null;
		this.m_closeBtn.addEventListener(MouseEvent.CLICK, this.onClose);
		addChild(this.m_closeBtn);
		this.m_closeBtn.x = 435;
		this.m_closeBtn.y = 16;
		this.m_mgrLabel = new Label("到仓库管理", this.onMgrLinkClicked);
		this.m_mgrLabel.textDefaultFormat.color = 30148;
		this.m_mgrLabel.x = AlignUtil.right(width, this.m_mgrLabel.width);
		this.m_mgrLabel.y = 5;
		this.m_mgrLabel.useHandCursor = true;
		addChild(this.m_mgrLabel);
		this.m_emptyText = new TextField();
		this.m_emptyText.autoSize = TextFieldAutoSize.LEFT;
		this.m_emptyText.visible = false;
		this.m_emptyText.defaultTextFormat = new TextFormat("Verdana", 16, null, null, null, null, null, null, TextFormatAlign.CENTER);
		this.m_emptyText.height = 35;
		this.m_emptyText.x = 40;
		this.m_emptyText.y = 50;
		this.m_emptyText.htmlText = "<a href='event:1'><font color='#FF6600'>"
			+ Reflect.field(Language.L, "包裹里什么都没有，去商店里逛逛吧！") + "</font></a>";
		this.m_emptyText.addEventListener(MouseEvent.CLICK, this.onEmptyTextClicked);
		addChild(this.m_emptyText);
		this.m_notOpenText = new TextField();
		this.m_notOpenText.autoSize = TextFieldAutoSize.LEFT;
		this.m_notOpenText.visible = false;
		this.m_notOpenText.defaultTextFormat = new TextFormat("Verdana", 16, null, null, null, null, null, null, TextFormatAlign.CENTER);
		this.m_notOpenText.height = 35;
		this.m_notOpenText.x = 40;
		this.m_notOpenText.y = 50;
		this.m_notOpenText.htmlText = "<a href='event:1'><font color='#FF6600'>"
			+ Reflect.field(Language.L, "包裹里什么都没有，去商店里逛逛吧！") + "</font></a>";
		addChild(this.m_notOpenText);
		this.m_btnGoWarehouse = new Button();
		this.m_btnGoWarehouse.visible = false;
		this.m_btnGoWarehouse.addEventListener(MouseEvent.CLICK, this.onEmptyTextClicked);
		this.m_btnGoWarehouse.defaultSkin = Utils.getClass("ButtonBlue");
		this.m_btnGoWarehouse.text = Reflect.field(Language.L, "去商店");
		this.m_btnGoWarehouse.x = this.m_emptyText.x + this.m_emptyText.width + 5;
		this.m_btnGoWarehouse.y = 49;
		this.m_btnGoWarehouse.width = 60;
		this.m_btnGoWarehouse.height = 24;
		addChild(this.m_btnGoWarehouse);
		this.m_dataLoading = new DataLoading();
		this.m_dataLoading.addEventListener(ViewEvent.LINK_CLICK, this.onLoadingLinkClicked, false, 0, true);
		this.m_dataLoading.x = (width - this.m_dataLoading.width) / 2;
		this.m_dataLoading.y = (height - this.m_dataLoading.height) / 2 + 20;
		this.m_dataLoading.visible = false;
		addChild(this.m_dataLoading);
		this.m_switchBtn = Std.isOfType(Utils.getMaterial("PackageTab"), MovieClip) ? cast(Utils.getMaterial("PackageTab"), MovieClip) : null;
		this.m_switchBtn.x = 35;
		this.m_switchBtn.y = -2;
		this.m_switchBtn.addEventListener(Consts.MSG_SWITCH_TO_SEED, this.selectNormal);
		this.m_switchBtn.addEventListener(Consts.MSG_SWITCH_TO_TOOL, this.selectTool);
		this.m_switchBtn.addEventListener(Consts.MSG_SWITCH_TO_FISH, this.selectFish);
		addChild(this.m_switchBtn);
	}

	// MyBagView.as:501-504
	private function onClick(param1:MouseEvent):Void {
		param1.stopPropagation();
	}

	// MyBagView.as:506-542
	private function onChildOver(param1:ViewEvent):Void {
		var _loc5_:Dynamic = null;
		if (param1 == null || param1.data == null) {
			return;
		}
		var _loc2_:BagItem = Std.isOfType(param1.data, BagItem) ? cast(param1.data, BagItem) : null;
		if (_loc2_ == null) {
			return;
		}
		var _loc3_:String = "";
		var _loc4_:String = Std.string(_loc2_._type);
		if (_loc4_ == Consts.ITEM_TYPE_SEED) {
			_loc3_ = _loc2_._name + "种子" + "\n";
			if (_loc2_._level >= 0) {
				_loc3_ += Std.string(_loc2_._level) + " 级作物，" + Std.string(_loc2_._lifeCycle) + " 小时成熟";
			}
		} else if (_loc4_ == Consts.ITEM_TYPE_TOOL || _loc4_ == Consts.ITEM_TYPE_FISHFEED || _loc4_ == Consts.ITEM_TYPE_WEAPON) {
			_loc3_ = _loc2_._name + "\n" + _loc2_._depict;
		} else if (_loc4_ == Consts.ITEM_TYPE_FISH) {
			_loc5_ = Settings.getInstance().getFishByID(Std.string(_loc2_._cId));
			if (_loc5_ == null) {
				return;
			}
			_loc3_ = _loc2_._name + "\n" + "占用容量" + Reflect.field(_loc5_, "pool_size") + "，"
				+ Std.string(_loc2_._lifeCycle) + " 小时成熟";
		}
		this.m_controller.showTip(Consts.TIP_NAME_MOUSE, _loc3_);
	}

	// MyBagView.as:544-559
	private function selectFish(param1:Event = null):Void {
		this._selectTab = "fish";
		this.m_mgrLabel.visible = false;
		this.m_list.dataProvider = this.m_model.fillterType("fish");
		if (Session.getInstance().m_waterPoolOpen == false) {
			this.m_list.visible = false;
			this.m_notOpenText.visible = true;
			this.m_notOpenText.htmlText = "<font color='#FF6600'>您尚未开通池塘</font>";
			this.m_emptyText.visible = false;
			this.m_btnGoWarehouse.visible = false;
			return;
		}
		this.setVisible();
	}

	// MyBagView.as:561-573
	public function show(param1:Bool):Void {
		if (param1 == true) {
			this.showCloseBtnTips();
			this.visible = true;
			this._api.hideBeastPack();
		} else {
			this.visible = false;
		}
	}

	// MyBagView.as:575-585
	public function toggleVisible():Void {
		if (this.visible == true) {
			this.show(false);
		} else {
			this.show(true);
		}
	}

	// MyBagView.as:587-610
	public function updateBag(param1:Int):Void {
		var _loc2_:Int = 0;
		if (this.m_list.hScrollBar != null) {
			_loc2_ = Std.int(this.m_list.hScrollBar.scrollPosition);
		}
		if (Std.string(param1) == Consts.ITEM_TYPE_SEED) {
			this.m_list.dataProvider = this.m_model.fillterType("normal");
		} else if (Std.string(param1) == Consts.ITEM_TYPE_FISH) {
			this.m_list.dataProvider = this.m_model.fillterType("fish");
		} else {
			this.m_list.dataProvider = this.m_model.fillterType("tool");
		}
		if (_loc2_ > 0) {
			this.m_list.hScrollBar.scrollPosition = _loc2_;
		}
	}
}
