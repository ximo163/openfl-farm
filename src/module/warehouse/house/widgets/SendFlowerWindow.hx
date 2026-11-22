package module.warehouse.house.widgets;

import com.qzone.qui.controls.Button;
import com.qzone.utils.StringUtil;
import common.Consts;
import common.Settings;
import common.misc.QzoneJSAPI;
import common.misc.Utils;
import common.view.Line;
import common.view.window.BaseWindow;
import events.CommonEvent;
import openfl.display.Bitmap;
import openfl.display.Loader;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.FocusEvent;
import openfl.events.MouseEvent;
import openfl.net.URLRequest;
import openfl.text.TextField;
import openfl.text.TextFieldAutoSize;
import openfl.text.TextFieldType;
import openfl.text.TextFormat;
import interfaces.IMsgCenter;
import shim.As3;

/**
 * module.warehouse.house.widgets.SendFlowerWindow —— SendFlowerWindow.as
 * 逐句对应（issue #36 功能 swf 翻译：仓库）。包装花束赠送窗：花束图（外链
 * Loader）+ 花语/所需鲜花/缺朵说明 + 受赠好友（qzone 模式手输 uin、其余
 * 模式选好友弹层）+ 50 字留言，确定后经 msgCenter 冒 MSG_FLOWER_SEND。
 *
 * PORT-NOTE: Loader.load(URLRequest) 外链花束图保持原调用形态（CLAUDE.md：
 * 远程 swf → Assets 的映射只落在 mcloader 加载器类；HarvestAnimationCustom
 * 先例）；contentLoaderInfo 匿名闭包经 arguments.callee 自摘除 → 捕获局部
 * fn；`int(text)` → As3.intOf(As3.parseInt(...))；`if(_toUin)` 的 AS3 串真值
 * → As3.truthy；`desc as String` → 判型直取；`["k"] == 数/真值` 宽松语义 →
 * As3.floatOf/truthy；Dynamic 串接 → Std.string；`autoSize = "left"/"right"`
 * → TextFieldAutoSize 常量。
 */
class SendFlowerWindow extends BaseWindow {
	// SendFlowerWindow.as:27
	private var _uinErrorTxt:TextField;

	// SendFlowerWindow.as:29
	private var _lack:TextField;

	// SendFlowerWindow.as:31
	private var _okButton:Button;

	// SendFlowerWindow.as:33
	private var _imgBorder:Sprite;

	// SendFlowerWindow.as:35（AS3 const → static final 同值不可，实例 final）
	private final _imgWH:Int = 120;

	// SendFlowerWindow.as:37
	private var _ld:Loader;

	// SendFlowerWindow.as:39
	private var _txtWord:TextField;

	// SendFlowerWindow.as:41
	private final _defaultWord:String = "花束里的每一朵花，都是我点滴的心意，一枝枝的扎起来送给您。希望能为您带来快乐！";

	// SendFlowerWindow.as:43
	private var _toUin:String;

	// SendFlowerWindow.as:45
	private var _desc:TextField;

	// SendFlowerWindow.as:47
	private var _txtToUin:TextField;

	// SendFlowerWindow.as:49
	private var _txtWordLimit:TextField;

	// SendFlowerWindow.as:51
	private var _pickFriend:Button;

	// SendFlowerWindow.as:53-61
	public function new(param1:IMsgCenter) {
		super(param1);
		width = 400;
		height = 410;
		mode = true;
		title = "包装花束赠送";
		windowName = Consts.WINDOW_NAME_SENDFLOWER;
	}

	// SendFlowerWindow.as:63-89
	private function onOK(param1:MouseEvent):Void {
		var _loc3_:Dynamic = null;
		if (As3.intOf(As3.parseInt(this._txtToUin.text)) > 10000) {
			this._toUin = this._txtToUin.text;
		}
		var _loc2_:String = Std.isOfType(Reflect.field(super.data, "desc"), String) ? cast(Reflect.field(super.data, "desc"), String) : null;
		if (_loc2_ != null && _loc2_.indexOf("<script") != -1) {
			return;
		}
		if (As3.truthy(this._toUin)) {
			_loc3_ = {
				"uin": this._toUin,
				"word": this._txtWord.text,
				"flower": super.data
			};
			m_msgCenter.dispatchEvent(new CommonEvent(Consts.MSG_FLOWER_SEND, _loc3_));
			super.close();
		} else {
			this._uinErrorTxt.text = "*请先选择受赠好友";
		}
	}

	// SendFlowerWindow.as:91-105
	private function onFocus(param1:FocusEvent):Void {
		if (param1.type == FocusEvent.FOCUS_IN) {
			if (this._txtWord.text == this._defaultWord) {
				this._txtWord.text = "";
			}
		} else if (StringUtil.trim(this._txtWord.text) == "") {
			this._txtWord.text = this._defaultWord;
		}
		this.onTextChanged();
	}

	// SendFlowerWindow.as:107-112
	public function onFriendSelected(param1:String, param2:String):Void {
		this._toUin = param1;
		this._txtToUin.htmlText = param2;
		this._uinErrorTxt.text = "";
	}

	// SendFlowerWindow.as:114-117
	private function onTextChanged(param1:Event = null):Void {
		this._txtWordLimit.htmlText = "<font color=\'#ff0000\'>" + Std.string(this._txtWord.text.length) + "</font>/50";
	}

	// SendFlowerWindow.as:119-122
	private function onSelectFriend(param1:MouseEvent):Void {
		QzoneJSAPI.selectFriend(this.onFriendSelected);
	}

	// SendFlowerWindow.as:124-165
	override private function setData():Void {
		var _loc6_:Dynamic = null;
		var _loc6In:Dynamic = null;
		this.graphics.clear();
		var _loc1_:Dynamic = super.data;
		if (As3.hasProp(_loc1_, "pic") && Reflect.field(_loc1_, "pic") != "") {
			this._ld.load(new URLRequest(Reflect.field(_loc1_, "pic")));
		}
		var _loc2_:String = "<p><b><font size=\'26\' color=\'#39983C\'>" + Reflect.field(_loc1_, "fName") + "</font></b></p>";
		_loc2_ += "<font size=\'12\' color=\'#636768\'>";
		_loc2_ += "<p>" + "花语：" + Reflect.field(_loc1_, "desc") + "</p>";
		var _loc3_:String = "";
		var _loc4_:String = "";
		var _loc5_:Bool = true;
		for (_loc6In in cast(Reflect.field(_loc1_, "need"), Array<Dynamic>)) {
			_loc6_ = _loc6In;
			if (_loc5_ == false) {
				_loc3_ += "<p><textformat indent=\'37\'>";
			} else {
				_loc3_ += "<p>需要：<textformat>";
			}
			_loc5_ = false;
			_loc3_ += Reflect.field(_loc6_, "cName") + " <b><font color=\'#39983C\'>" + Std.string(Reflect.field(_loc6_, "amount")) + "</font></b> 朵</textformat></p>";
			if (As3.floatOf(Reflect.field(_loc6_, "lack")) > 0) {
				_loc4_ += "<b>还差 <font color=\'#D2732F\'>" + Std.string(Reflect.field(_loc6_, "lack")) + "</font> 朵</b><br/>";
			} else {
				_loc4_ += "<br/>";
			}
		}
		this._desc.htmlText = _loc2_ + _loc3_ + "</font>";
		this._lack.htmlText = _loc4_;
		this._txtWord.mouseEnabled = As3.truthy(Reflect.field(_loc1_, "canMake"));
		this._pickFriend.enabled = As3.truthy(Reflect.field(_loc1_, "canMake"));
		this._okButton.enabled = As3.truthy(Reflect.field(_loc1_, "canMake"));
	}

	// SendFlowerWindow.as:167-311（原版不调 super.addedToLayer()，照抄）
	override private function addedToLayer():Void {
		var txt:TextField;
		var tf:TextFormat;
		var l1:Line;
		var wordBg:Sprite;
		var uinBg:Sprite;
		var imgBorderMat:Dynamic = Utils.getMaterial("ItemBg");
		this._imgBorder = Std.isOfType(imgBorderMat, Sprite) ? cast(imgBorderMat, Sprite) : null;
		this._imgBorder.name = "ItemBg";
		this._imgBorder.width = this._imgWH;
		this._imgBorder.height = this._imgWH;
		this._imgBorder.x = 20;
		this._imgBorder.y = 45;
		addChild(this._imgBorder);
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
		this._desc = new TextField();
		this._desc.multiline = true;
		this._desc.selectable = false;
		this._desc.width = 222;
		this._desc.autoSize = TextFieldAutoSize.LEFT;
		this._desc.x = 156;
		this._desc.y = 45;
		addChild(this._desc);
		this._lack = new TextField();
		tf = new TextFormat("Verdana", 12, 6514536);
		tf.color = 3774524;
		this._lack.defaultTextFormat = tf;
		this._lack.selectable = false;
		this._lack.width = 110;
		this._lack.autoSize = TextFieldAutoSize.LEFT;
		this._lack.multiline = this._lack.wordWrap = true;
		this._lack.x = 300;
		this._lack.y = 105;
		addChild(this._lack);
		l1 = new Line(360, 3, 3852787);
		l1.y = this._imgBorder.y + this._imgBorder.height + 10;
		l1.x = this._imgBorder.x;
		addChild(l1);
		txt = new TextField();
		txt.defaultTextFormat = new TextFormat("Verdana", 12, 6514536);
		txt.selectable = false;
		txt.autoSize = TextFieldAutoSize.LEFT;
		txt.text = "赠送给：";
		txt.x = this._imgBorder.x;
		txt.y = l1.y + 10;
		addChild(txt);
		var uinBgMat:Dynamic = Utils.getMaterial("ItemBg");
		uinBg = Std.isOfType(uinBgMat, Sprite) ? cast(uinBgMat, Sprite) : null;
		uinBg.width = 140;
		uinBg.height = 20;
		uinBg.x = this._imgBorder.x;
		uinBg.y = txt.y + txt.height + 4;
		addChild(uinBg);
		this._txtToUin = new TextField();
		this._txtToUin.defaultTextFormat = new TextFormat("Verdana", 12, 6514536);
		this._txtToUin.width = uinBg.width - 4;
		this._txtToUin.height = uinBg.height;
		this._txtToUin.x = uinBg.x + 2;
		this._txtToUin.y = uinBg.y;
		if (Settings.getInstance().mode == "qzone") {
			this._txtToUin.type = TextFieldType.INPUT;
			this._txtToUin.restrict = "0-9";
		} else {
			this._txtToUin.mouseEnabled = this._txtToUin.mouseWheelEnabled = false;
			uinBg.addEventListener(MouseEvent.CLICK, this.onSelectFriend);
		}
		addChild(this._txtToUin);
		this._pickFriend = new Button();
		this._pickFriend.defaultSkin = Utils.getClass("ButtonBlue");
		this._pickFriend.width = 60;
		this._pickFriend.height = 25;
		this._pickFriend.x = uinBg.x + uinBg.width + 20;
		this._pickFriend.y = uinBg.y - 3;
		this._pickFriend.text = "选择好友";
		this._pickFriend.clickFn = this.onSelectFriend;
		addChild(this._pickFriend);
		this._uinErrorTxt = new TextField();
		this._uinErrorTxt.defaultTextFormat = new TextFormat("Verdana", 12, 15829835);
		this._uinErrorTxt.selectable = false;
		this._uinErrorTxt.autoSize = TextFieldAutoSize.LEFT;
		this._uinErrorTxt.x = this._txtToUin.x;
		this._uinErrorTxt.y = uinBg.y + 22;
		addChild(this._uinErrorTxt);
		txt = new TextField();
		txt.defaultTextFormat = new TextFormat("Verdana", 12, 6514536);
		txt.selectable = false;
		txt.autoSize = TextFieldAutoSize.LEFT;
		txt.text = "留言：";
		txt.height = 22;
		txt.x = this._imgBorder.x;
		txt.y = uinBg.y + uinBg.height + 30;
		addChild(txt);
		var wordBgMat:Dynamic = Utils.getMaterial("ItemBg");
		wordBg = Std.isOfType(wordBgMat, Sprite) ? cast(wordBgMat, Sprite) : null;
		wordBg.width = 360;
		wordBg.height = 80;
		wordBg.x = this._imgBorder.x;
		wordBg.y = txt.y + txt.height + 4;
		addChild(wordBg);
		this._txtWordLimit = new TextField();
		this._txtWordLimit.defaultTextFormat = new TextFormat("Verdana", 12, 6514536);
		this._txtWordLimit.selectable = false;
		this._txtWordLimit.width = 50;
		this._txtWordLimit.autoSize = TextFieldAutoSize.RIGHT;
		this._txtWordLimit.x = wordBg.x + wordBg.width - this._txtWordLimit.width;
		this._txtWordLimit.y = txt.y;
		addChild(this._txtWordLimit);
		this._txtWord = new TextField();
		this._txtWord.defaultTextFormat = new TextFormat("Verdana", 12, 6514536);
		this._txtWord.type = TextFieldType.INPUT;
		this._txtWord.width = wordBg.width - 8;
		this._txtWord.height = wordBg.height - 8;
		this._txtWord.text = "";
		this._txtWord.maxChars = 50;
		this._txtWord.multiline = this._txtWord.wordWrap = true;
		this._txtWord.x = wordBg.x + 4;
		this._txtWord.y = wordBg.y + 4;
		this._txtWord.addEventListener(Event.CHANGE, this.onTextChanged);
		this._txtWord.addEventListener(FocusEvent.FOCUS_IN, this.onFocus);
		this._txtWord.addEventListener(FocusEvent.FOCUS_OUT, this.onFocus);
		this._txtWord.text = this._defaultWord;
		addChild(this._txtWord);
		this.onTextChanged();
		this._okButton = new Button();
		this._okButton.defaultSkin = Utils.getClass("ButtonBlue");
		this._okButton.width = 70;
		this._okButton.height = 25;
		this._okButton.x = width / 2 - 35;
		this._okButton.y = height - 35;
		this._okButton.text = "确定赠送";
		this._okButton.clickFn = this.onOK;
		addChild(this._okButton);
	}
}
