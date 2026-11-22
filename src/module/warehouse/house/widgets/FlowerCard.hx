package module.warehouse.house.widgets;

import ButtonBlue;
import ButtonOrange;
import com.qzone.qfa.events.CommandEvent;
import com.qzone.qui.controls.Button;
import common.Consts;
import common.Language;
import common.Session;
import common.misc.Utils;
import common.view.window.BaseWindow;
import events.CommonEvent;
import events.ViewEvent;
import openfl.display.Bitmap;
import openfl.display.Loader;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.events.TextEvent;
import openfl.filters.GlowFilter;
import openfl.net.URLRequest;
import openfl.text.TextField;
import openfl.text.TextFieldAutoSize;
import openfl.text.TextFormat;
import framework.net.CommandDefs;
import framework.net.NetHelper;
import framework.net.vo.ServiceResultVO;
import interfaces.IMsgCenter;
import module.FarmApplication;
import shim.As3;

/**
 * module.warehouse.house.widgets.FlowerCard —— FlowerCard.as 逐句对应
 * （issue #36 功能 swf 翻译：仓库）。鲜花卡片窗（收到的花束详情）：花束图
 * （外链 Loader，点击发 preview 到来源页）+ 花语/好友名/赠言（CMD_GET_
 * FLOWER_WORDS 拉取，cmdID 不符时兜底「好友没有留言哦」）+ 删除花束
 * （CMD_DEL_MYFLOWER，成功后冒 MSG_FLOWER_DELETED）。
 *
 * PORT-NOTE: Loader.load(URLRequest) 外链花束图保持原调用形态（CLAUDE.md：
 * 远程 swf → Assets 的映射只落在 mcloader 加载器类；HarvestAnimationCustom
 * 先例）；contentLoaderInfo 匿名闭包经 arguments.callee 自摘除 → 捕获局部
 * fn；`as Sprite/TextField/ServiceResultVO/FarmApplication` → isOfType 门 +
 * 直取；`body["cmdID"] == 数` 宽松等值 → As3.floatOf；`m_extra["word"] as
 * String` → 判型直取；`Language.L["…"]` → Reflect.field；`autoSize = "left"`
 * → TextFieldAutoSize 常量；addedToLayer 原版不调 super.addedToLayer()，
 * 照抄。
 */
class FlowerCard extends BaseWindow {
	// FlowerCard.as:31
	private var _txtView:TextField;

	// FlowerCard.as:33
	private var _parent:Sprite;

	// FlowerCard.as:35
	private var _imgBorder:Sprite;

	// FlowerCard.as:37（AS3 const uint 字面量）
	private final _imgWH:UInt = 96;

	// FlowerCard.as:39
	private var _ld:Loader;

	// FlowerCard.as:41
	private var _txtFriendName:TextField;

	// FlowerCard.as:43
	private var _txtWord:TextField;

	// FlowerCard.as:45
	private var _txtMasterName:TextField;

	// FlowerCard.as:47
	private var _txtDesc:TextField;

	// FlowerCard.as:49-59
	public function new(param1:IMsgCenter) {
		super(param1);
		width = 400;
		height = 250;
		mode = true;
		title = "鲜花卡片";
		windowName = Consts.WINDOW_NAME_FLOWER_CARD;
		this._parent = null;
		addEventListener(TextEvent.LINK, this.onLinkClicked);
	}

	// FlowerCard.as:61-70
	private function onImageClicked(param1:MouseEvent):Void {
		var _loc2_:ViewEvent = null;
		if (this._parent != null) {
			_loc2_ = new ViewEvent("preview", true);
			_loc2_.data = Reflect.field(super.data, "flower");
			this._parent.dispatchEvent(_loc2_);
		}
	}

	// FlowerCard.as:72-89（AS3 protected → private 覆写）
	override private function setData():Void {
		this.graphics.clear();
		this._parent = Reflect.field(super.data, "parent");
		var _loc1_:Dynamic = Reflect.field(super.data, "flower");
		if (As3.hasProp(_loc1_, "pic") && Reflect.field(_loc1_, "pic") != "") {
			this._ld.load(new URLRequest(Reflect.field(_loc1_, "pic")));
		}
		this._txtMasterName.htmlText = Session.getInstance().host._userName;
		this._txtFriendName.text = "好友：" + Reflect.field(_loc1_, "friendName");
		this._txtDesc.text = "花语：" + Reflect.field(_loc1_, "desc");
		var _loc2_:Dynamic = {
			"uid": Reflect.field(_loc1_, "fromId"),
			"time": Reflect.field(_loc1_, "time")
		};
		NetHelper.sendRequest(CommandDefs.CMD_GET_FLOWER_WORDS, _loc2_, this.onFlowerWords, this.onNetError);
	}

	// FlowerCard.as:91-111
	private function onFlowerDeleted(param1:CommandEvent):Void {
		var _loc3_:FarmApplication = null;
		var _loc4_:Dynamic = null;
		if (param1 == null || param1.result == null) {
			return;
		}
		var _loc2_:ServiceResultVO = Std.isOfType(param1.result, ServiceResultVO) ? cast(param1.result, ServiceResultVO) : null;
		if (_loc2_ != null) {
			_loc3_ = Std.isOfType(m_msgCenter, FarmApplication) ? cast(m_msgCenter, FarmApplication) : null;
			_loc4_ = {
				"iconType": "success",
				"text": "成功删除花束！",
				"parent": _loc3_.farmView.getLayerByName(Consts.LAYER_TOPMOST)
			};
			_loc3_.farmView.floatCtrl.open(Consts.FLOAT_TYPE_TEXTTIP, 0, _loc4_);
			_loc3_.dispatchEvent(new CommonEvent(Consts.MSG_FLOWER_DELETED, Reflect.field(super.data, "flower")));
		}
	}

	// FlowerCard.as:113-122
	private function onDeleteFlower(param1:MouseEvent):Void {
		var _loc2_:Dynamic = {
			"text": "删除的花束无法恢复。\n是否删除？",
			"confirmFn": this.deleteFlower
		};
		var _loc3_:FarmApplication = Std.isOfType(m_msgCenter, FarmApplication) ? cast(m_msgCenter, FarmApplication) : null;
		_loc3_.openWindowByName(Consts.WINDOW_NAME_CONFIRM, _loc2_);
		super.close();
	}

	// FlowerCard.as:124-132
	private function deleteFlower():Void {
		var _loc1_:Dynamic = Reflect.field(super.data, "flower");
		var _loc2_:Dynamic = {
			"uid": Reflect.field(_loc1_, "fromId"),
			"time": Reflect.field(_loc1_, "time")
		};
		NetHelper.sendRequest(CommandDefs.CMD_DEL_MYFLOWER, _loc2_, this.onFlowerDeleted, this.onNetError);
	}

	// FlowerCard.as:134-145
	private function onFlowerWords(param1:CommandEvent):Void {
		if (param1 == null || param1.result == null) {
			return;
		}
		var _loc2_:ServiceResultVO = Std.isOfType(param1.result, ServiceResultVO) ? cast(param1.result, ServiceResultVO) : null;
		if (_loc2_ != null) {
			this._txtWord.text = Std.isOfType(Reflect.field(_loc2_.m_extra, "word"), String) ? cast(Reflect.field(_loc2_.m_extra, "word"), String) : null;
		}
	}

	// FlowerCard.as:147-169（body["cmdID"] 键名照原文大写 ID）
	private function onNetError(param1:CommandEvent):Void {
		var _loc2_:FarmApplication = null;
		var _loc3_:Dynamic = null;
		if (param1 == null || param1.body == null) {
			return;
		}
		if (As3.floatOf(Reflect.field(param1.body, "cmdID")) == CommandDefs.CMD_GET_FLOWER_WORDS) {
			this._txtWord.text = "好友没有留言哦。";
		} else if (As3.floatOf(Reflect.field(param1.body, "cmdID")) == CommandDefs.CMD_DEL_MYFLOWER) {
			_loc2_ = Std.isOfType(m_msgCenter, FarmApplication) ? cast(m_msgCenter, FarmApplication) : null;
			_loc3_ = {
				"iconType": "error",
				"text": "删除花束失败！",
				"parent": _loc2_.farmView.getLayerByName(Consts.LAYER_TOPMOST)
			};
			_loc2_.farmView.floatCtrl.open(Consts.FLOAT_TYPE_TEXTTIP, 0, _loc3_);
		}
	}

	// FlowerCard.as:171-184
	private function onLinkClicked(param1:TextEvent):Void {
		var _loc2_:ViewEvent = null;
		param1.stopPropagation();
		if (param1.text == "view") {
			if (this._parent != null) {
				_loc2_ = new ViewEvent("preview", true);
				_loc2_.data = Reflect.field(super.data, "flower");
				this._parent.dispatchEvent(_loc2_);
			}
		}
	}

	// FlowerCard.as:186-247（原版不调 super.addedToLayer()，照抄）
	override private function addedToLayer():Void {
		var tf:TextFormat;
		var delButton:Button;
		var okButton:Button = null;
		var uiMat:Dynamic = Utils.getMaterial("FlowerCardUI");
		var ui:Sprite = Std.isOfType(uiMat, Sprite) ? cast(uiMat, Sprite) : null;
		this._txtDesc = cast(As3.childOf(ui, "txtDesc"), TextField);
		this._txtMasterName = cast(As3.childOf(ui, "txtMasterName"), TextField);
		this._txtWord = cast(As3.childOf(ui, "txtWord"), TextField);
		this._txtFriendName = cast(As3.childOf(ui, "txtFriendName"), TextField);
		addChild(ui);
		tf = new TextFormat("Verdana", 12, 6514536);
		tf.leading = 5;
		this._txtWord.setTextFormat(tf);
		var imgBorderMat:Dynamic = Utils.getMaterial("ItemBg");
		this._imgBorder = Std.isOfType(imgBorderMat, Sprite) ? cast(imgBorderMat, Sprite) : null;
		this._imgBorder.name = "ItemBg";
		this._imgBorder.width = this._imgBorder.height = this._imgWH;
		this._imgBorder.x = 20;
		this._imgBorder.y = 45;
		addChild(this._imgBorder);
		this._imgBorder.addEventListener(MouseEvent.CLICK, this.onImageClicked, false, 0, true);
		this._ld = new Loader();
		this._ld.mouseChildren = this._ld.mouseEnabled = false;
		// AS3 匿名闭包经 arguments.callee 自摘除 → 捕获局部 fn
		var fn:Dynamic = null;
		fn = function(ev:Event):Void {
			var _loc2_:Loader = cast(cast(ev.target, openfl.display.LoaderInfo).loader, Loader);
			_loc2_.width = _loc2_.height = _imgWH - 4;
			_loc2_.x = _imgBorder.x + 2;
			_loc2_.y = _imgBorder.y + 2;
			cast(_loc2_.content, Bitmap).smoothing = true;
			_loc2_.contentLoaderInfo.removeEventListener(Event.COMPLETE, fn);
		};
		this._ld.contentLoaderInfo.addEventListener(Event.COMPLETE, fn);
		addChild(this._ld);
		this._txtView = new TextField();
		this._txtView.selectable = false;
		this._txtView.defaultTextFormat = new TextFormat("Verdana", 12, 16777215);
		this._txtView.filters = [new GlowFilter(30148, 1, 3, 3)];
		this._txtView.autoSize = TextFieldAutoSize.LEFT;
		addChild(this._txtView);
		this._txtView.htmlText = "<a href=\'event:view\'>" + "点击查看" + "</a>";
		this._txtView.x = this._imgBorder.x + this._imgWH - this._txtView.width - 2;
		this._txtView.y = this._imgBorder.y + this._imgWH - this._txtView.height - 2;
		okButton = new Button();
		okButton.defaultSkin = ButtonOrange;
		okButton.width = 64;
		okButton.height = 25;
		okButton.x = width / 2 - 62;
		okButton.y = height - 35;
		okButton.text = Reflect.field(Language.L, "确定");
		okButton.clickFn = this.onOK;
		addChild(okButton);
		delButton = new Button();
		delButton.defaultSkin = ButtonBlue;
		delButton.width = 64;
		delButton.height = 25;
		delButton.x = width / 2 + 22;
		delButton.y = height - 35;
		delButton.text = "删除花束";
		delButton.clickFn = this.onDeleteFlower;
		addChild(delButton);
	}

	// FlowerCard.as:249-252
	private function onOK(param1:MouseEvent):Void {
		super.close();
	}
}
