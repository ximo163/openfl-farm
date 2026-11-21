package module.messages.widgets;

import com.qzone.qui.controls.Button;
import com.qzone.utils.HtmlUtil;
import common.Language;
import common.Session;
import common.Settings;
import common.misc.QzoneJSAPI;
import common.misc.Utils;
import common.view.MoneyIcon;
import entities.Player;
import openfl.display.DisplayObjectContainer;
import openfl.display.Loader;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.events.MouseEvent;
import openfl.net.URLRequest;
import openfl.text.TextField;
import openfl.text.TextFormat;
import report.UserActionRecorder;
import shim.As3;
import shim.QQOutlets;

/**
 * module.messages.widgets.ProfileHead —— ProfileHead.as 逐句对应（issue #19）。
 * 个人信息头部：圆角方块（100×100，beginFill 15658734）裁 Loader 头像 +
 * 昵称/等级/经验/现金/人品文本 + 「去 ta 的首页」按钮（头像位与宿主不同才亮）。
 *
 * PORT-NOTE: `param1.uId == _loc2_._uId`（Object == uint 宽松等）按 AS3 数值
 * 化比较：一侧为 Number 时字符串转数、null/undefined → NaN 不等，
 * 以 As3.floatOf 两边转数比较复刻。
 */
class ProfileHead extends Sprite {
	// ProfileHead.as:23
	private var nameText:TextField;

	// ProfileHead.as:25
	private var assets1Text:TextField;

	// ProfileHead.as:27
	private var assets2Text:TextField;

	// ProfileHead.as:29
	private var assets3Text:TextField;

	// ProfileHead.as:31
	private var gradeText:TextField;

	// ProfileHead.as:33
	private var _photoLoader:Loader;

	// ProfileHead.as:35
	private var expText:TextField;

	// ProfileHead.as:37
	private var _homePage:String;

	// ProfileHead.as:39
	private var homeLink:Button;

	// ProfileHead.as:41
	private var _photoHolder:DisplayObjectContainer;

	public function new() {
		super();
		this._homePage = "";
		this._photoHolder = null;
		this._photoLoader = new Loader();
		this._photoLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, this.onLoaded);
		this._photoLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, this.onLoadError);
		this.createView();
	}

	// ProfileHead.as:55-159
	private function createView():Void {
		var _loc1_:Sprite = null;
		var _loc3_:TextField = null;
		var _loc5_:TextField = null;
		_loc1_ = new Sprite();
		_loc1_.graphics.beginFill(15658734);
		_loc1_.graphics.drawRect(0, 0, 100, 100);
		_loc1_.graphics.endFill();
		_loc1_.x = 39;
		_loc1_.y = 16;
		addChild(_loc1_);
		this._photoHolder = _loc1_;
		_loc1_.addChild(this._photoLoader);
		var _loc2_:Sprite = new Sprite();
		_loc2_.graphics.beginFill(15658734);
		_loc2_.graphics.drawRoundRect(0, 0, 100, 100, 10, 10);
		_loc2_.graphics.endFill();
		_loc2_.x = 39;
		_loc2_.y = 16;
		addChild(_loc2_);
		_loc1_.mask = _loc2_;
		this.nameText = new TextField();
		this.nameText.selectable = false;
		this.nameText.x = 163;
		this.nameText.y = 26;
		this.nameText.width = 300;
		this.nameText.height = 22;
		this.nameText.defaultTextFormat = new TextFormat("Verdana", 14, 3355443, true);
		this.nameText.text = "";
		addChild(this.nameText);
		_loc3_ = new TextField();
		_loc3_.selectable = false;
		_loc3_.x = 163;
		_loc3_.y = 65;
		_loc3_.width = 100;
		_loc3_.height = 22;
		_loc3_.defaultTextFormat = new TextFormat("Verdana", 14, 3355443);
		_loc3_.text = Reflect.field(Language.L, "等级:");
		addChild(_loc3_);
		this.gradeText = new TextField();
		this.gradeText.selectable = false;
		this.gradeText.x = 210;
		this.gradeText.y = 63;
		this.gradeText.width = 100;
		this.gradeText.height = 22;
		this.gradeText.defaultTextFormat = new TextFormat("embedFontA", 18, 39423);
		this.gradeText.embedFonts = true;
		this.gradeText.text = "";
		addChild(this.gradeText);
		var _loc4_:TextField = new TextField();
		_loc4_.selectable = false;
		_loc4_.x = 263;
		_loc4_.y = 65;
		_loc4_.width = 100;
		_loc4_.height = 22;
		_loc4_.defaultTextFormat = new TextFormat("Verdana", 14, 3355443);
		_loc4_.text = Reflect.field(Language.L, "经验:");
		addChild(_loc4_);
		this.expText = new TextField();
		this.expText.selectable = false;
		this.expText.x = 303;
		this.expText.y = 63;
		this.expText.width = 100;
		this.expText.height = 22;
		this.expText.defaultTextFormat = new TextFormat("embedFontA", 18, 39423);
		this.expText.embedFonts = true;
		this.expText.text = "";
		addChild(this.expText);
		_loc5_ = new TextField();
		_loc5_.selectable = false;
		_loc5_.x = 163;
		_loc5_.y = 90;
		_loc5_.width = 100;
		_loc5_.height = 22;
		_loc5_.defaultTextFormat = new TextFormat("Verdana", 14, 3355443);
		_loc5_.text = Reflect.field(Language.L, "现金:");
		addChild(_loc5_);
		var _loc6_:MoneyIcon = new MoneyIcon();
		_loc6_.x = 210;
		_loc6_.y = 92;
		addChild(_loc6_);
		this.assets1Text = new TextField();
		this.assets1Text.selectable = false;
		this.assets1Text.x = 248;
		this.assets1Text.y = 90;
		this.assets1Text.width = 100;
		this.assets1Text.height = 24;
		this.assets1Text.defaultTextFormat = new TextFormat("embedFontA", 16, 16737792);
		this.assets1Text.embedFonts = true;
		this.assets1Text.text = "";
		addChild(this.assets1Text);
		this.homeLink = new Button();
		this.homeLink.textDefaultFormat.font = "verdana";
		this.homeLink.defaultSkin = Utils.getClass("ButtonGreen");
		this.homeLink.visible = false;
		this.homeLink.clickFn = this.onClick;
		this.homeLink.x = 330;
		this.homeLink.y = 26;
		this.homeLink.width = 150;
		this.homeLink.height = 24;
		addChild(this.homeLink);
		var _loc7_:TextField = new TextField();
		_loc7_.selectable = false;
		_loc7_.x = 338;
		_loc7_.y = 92;
		_loc7_.width = 100;
		_loc7_.height = 22;
		_loc7_.defaultTextFormat = new TextFormat("embedFontA", 14, 3355443);
		_loc7_.text = "人品：";
		addChild(_loc7_);
		this.assets3Text = new TextField();
		this.assets3Text.selectable = false;
		this.assets3Text.x = 378;
		this.assets3Text.y = 90;
		this.assets3Text.width = 100;
		this.assets3Text.height = 24;
		this.assets3Text.defaultTextFormat = new TextFormat("embedFontA", 16, 4160774);
		this.assets3Text.embedFonts = true;
		this.assets3Text.text = "";
		addChild(this.assets3Text);
	}

	// ProfileHead.as:161-165
	private function onLoaded(param1:Event):Void {
		this._photoLoader.width = 100;
		this._photoLoader.height = 100;
	}

	// ProfileHead.as:167-186
	public function showPhotoPic(param1:Bool):Void {
		if (this._photoHolder == null || this._photoLoader == null) {
			return;
		}
		if (param1 == true) {
			this._photoLoader.visible = param1;
			if (this._photoHolder.contains(this._photoLoader) == false) {
				this._photoHolder.addChild(this._photoLoader);
			}
		} else {
			this._photoLoader.visible = param1;
			if (this._photoHolder.contains(this._photoLoader) == true) {
				this._photoHolder.removeChild(this._photoLoader);
			}
		}
	}

	// ProfileHead.as:188-190
	private function onLoadError(param1:IOErrorEvent):Void {}

	// ProfileHead.as:192-196
	private function onClick(param1:MouseEvent):Void {
		QzoneJSAPI.openWindow(this._homePage);
		UserActionRecorder.recordAction(UserActionRecorder.HF_HOMELINK_CLICKED);
	}

	// ProfileHead.as:198-271（AS3 public set data）
	public var data(never, set):Dynamic;

	private function set_data(param1:Dynamic):Dynamic {
		if (param1 == null) {
			return param1;
		}
		var _loc2_:Player = Session.getInstance().host;
		var _loc3_:String = Reflect.field(param1, "uName");
		if (_loc3_ == null || _loc3_ == "") {
			// `param1.uId == _loc2_._uId`：Object == uint 宽松等（类头 PORT-NOTE）
			if (As3.floatOf(Reflect.field(param1, "uId")) == _loc2_._uId) {
				_loc3_ = _loc2_._userName;
			} else {
				_loc3_ = Session.getInstance().currentUser._userName;
			}
		}
		if (_loc3_ == null || _loc3_ == "") {
			_loc3_ = "农场用户";
		}
		this.nameText.htmlText = As3.or(HtmlUtil.escHTML(_loc3_), "农场用户");
		this.homeLink.text = "去" + HtmlUtil.escHTML(_loc3_) + "的首页";
		this.assets1Text.text = Std.string(Reflect.field(param1, "money"));
		this.assets3Text.text = Std.string(Reflect.field(param1, "moralexp"));
		this.gradeText.text = Std.string(Reflect.field(param1, "uLevel"));
		if (this.assets2Text != null) {
			this.assets2Text.text = Std.string(Reflect.field(param1, "FB"));
		}
		var _loc4_:Int = Std.int(As3.parseInt(Reflect.field(param1, "uLevel")));
		this.expText.text = Std.string(As3.floatOf(Reflect.field(param1, "uExp")) - 100 * _loc4_ * (_loc4_ + 1));
		var _loc5_:String = null;
		if (Std.isOfType(Reflect.field(param1, "headPicBig"), String)) {
			_loc5_ = Reflect.field(param1, "headPicBig");
		}
		if (_loc5_ == null || _loc5_ == "") {
			if (QzoneJSAPI.WB == true) {
				if (As3.floatOf(Reflect.field(param1, "uId")) == _loc2_._uId) {
					_loc5_ = _loc2_._headPic;
				} else {
					_loc5_ = Session.getInstance().currentUser._headPic;
				}
				if (_loc5_ == null || _loc5_ == "") {
					_loc5_ = "http://mat1.gtimg.com/www/mb/images/head_100.jpg";
				} else {
					_loc5_ += "/100";
				}
			} else if (Settings.getInstance().mode == "qzone" || Settings.getInstance().mode == "qplus") {
				if (As3.floatOf(Reflect.field(param1, "uId")) == _loc2_._uId) {
					_loc5_ = QzoneJSAPI.getHead(Std.string(_loc2_.uin), 100);
				} else {
					_loc5_ = QzoneJSAPI.getHead(Std.string(Session.getInstance().currentUser.uin), 100);
				}
			}
		}
		if (_loc5_ != null && _loc5_ != "") {
			if (_loc5_ != this._photoLoader.contentLoaderInfo.url) {
				// PORT-NOTE(qq-outlet)：头像 URL 直 Loader.load → QQOutlets.loadImage
				// （headPic 一族宿主图片出口，独立部署不发送，视觉语义留空头像框）
				QQOutlets.loadImage(this._photoLoader, new URLRequest(_loc5_));
			}
		}
		this.homeLink.visible = As3.floatOf(Reflect.field(param1, "uId")) == _loc2_._uId ? false : true;
		if (Std.isOfType(Reflect.field(param1, "homePage"), String)) {
			this._homePage = Reflect.field(param1, "homePage");
		} else {
			this._homePage = null;
		}
		return param1;
	}
}
