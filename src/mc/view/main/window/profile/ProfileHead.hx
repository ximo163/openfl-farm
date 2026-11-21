package mc.view.main.window.profile;

import com.minutes.ui.control.LipiButton;
import com.minutes.ui.core.LipiSkin;
import com.qzone.corelib.js.JSProxy;
import common.LocalData;
import common.MaterialLib;
import openfl.display.Loader;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.events.MouseEvent;
import openfl.net.URLRequest;
import openfl.text.TextField;
import openfl.text.TextFormat;
import mc.control.Command;
import mc.control.Version;
import mc.model.MData;
import mc.model.MainData;
import shim.As3;
import shim.NavigateToURL;
import shim.QQOutlets;

/**
 * mc.view.main.window.profile.ProfileHead —— ProfileHead.as 逐句对应
 * （issue #19）。牧场个人信息头卡：头像（远端 Loader）+ 等级/经验/金币/人品
 * + 「去TA的首页」。原文件
 * legacy/decompiled/Master2_v_142/scripts/mc/view/main/window/profile/ProfileHead.as。
 */
@:keep
class ProfileHead extends Sprite {
	private var gradeText:TextField;

	private var photoLoader:Loader;

	private var loadbg:Sprite;

	private var _homePage:String = "";

	private var expText:TextField;

	private var homeLink:LipiButton;

	private var assets1Text:TextField;

	private var assets2Text:TextField;

	private var assets3Text:TextField;

	private var nameText:TextField;

	public function new() {
		var _loc4_:TextField = null;
		super();
		this.loadbg = cast MaterialLib.getInstance().getMaterial("DefaultHead");
		this.loadbg.width = 100;
		this.loadbg.height = 100;
		this.loadbg.x = 39;
		this.loadbg.y = 18;
		addChild(this.loadbg);
		this.photoLoader = new Loader();
		this.photoLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, this.onComp);
		this.photoLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, this.ioError);
		this.photoLoader.x = 39;
		this.photoLoader.y = 18;
		addChild(this.photoLoader);
		var _loc1_:Sprite = new Sprite();
		_loc1_.graphics.beginFill(15658734);
		_loc1_.graphics.drawRoundRect(0, 0, 100, 100, 10, 10);
		_loc1_.graphics.endFill();
		_loc1_.x = 39;
		_loc1_.y = 18;
		addChild(_loc1_);
		this.photoLoader.mask = _loc1_;
		this.nameText = new TextField();
		this.nameText.selectable = false;
		this.nameText.x = 163;
		this.nameText.y = 26;
		this.nameText.width = 150;
		this.nameText.height = 22;
		this.nameText.defaultTextFormat = new TextFormat("Verdana", 14, 3355443, true);
		this.nameText.text = "";
		addChild(this.nameText);
		var _loc2_:TextField = new TextField();
		_loc2_.selectable = false;
		_loc2_.x = 163;
		_loc2_.y = 65;
		_loc2_.width = 100;
		_loc2_.height = 22;
		_loc2_.defaultTextFormat = new TextFormat("Verdana", 14, 3355443);
		_loc2_.text = "牧场等级:";
		addChild(_loc2_);
		this.gradeText = new TextField();
		this.gradeText.selectable = false;
		this.gradeText.x = 230;
		this.gradeText.y = 63;
		this.gradeText.width = 100;
		this.gradeText.height = 22;
		this.gradeText.defaultTextFormat = new TextFormat("embedFontA", 18, 15886653);
		this.gradeText.embedFonts = true;
		this.gradeText.text = "";
		addChild(this.gradeText);
		var _loc3_:TextField = new TextField();
		_loc3_.selectable = false;
		_loc3_.x = 263;
		_loc3_.y = 65;
		_loc3_.width = 100;
		_loc3_.height = 22;
		_loc3_.defaultTextFormat = new TextFormat("Verdana", 14, 3355443);
		_loc3_.text = "经验:";
		addChild(_loc3_);
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
		_loc4_ = new TextField();
		_loc4_.selectable = false;
		_loc4_.x = 163;
		_loc4_.y = 90;
		_loc4_.width = 100;
		_loc4_.height = 22;
		_loc4_.defaultTextFormat = new TextFormat("embedFontA", 14, 3355443);
		_loc4_.text = "金币:";
		addChild(_loc4_);
		_loc4_ = new TextField();
		_loc4_.selectable = false;
		_loc4_.x = 290;
		_loc4_.y = 90;
		_loc4_.width = 100;
		_loc4_.height = 22;
		_loc4_.defaultTextFormat = new TextFormat("embedFontA", 14, 3355443);
		_loc4_.text = "人品:";
		addChild(_loc4_);
		this.assets1Text = new TextField();
		this.assets1Text.selectable = false;
		this.assets1Text.x = 200;
		this.assets1Text.y = 88;
		this.assets1Text.width = 100;
		this.assets1Text.height = 24;
		this.assets1Text.defaultTextFormat = new TextFormat("embedFontA", 18, 16737792);
		this.assets1Text.embedFonts = true;
		this.assets1Text.text = "";
		addChild(this.assets1Text);
		this.assets3Text = new TextField();
		this.assets3Text.selectable = false;
		this.assets3Text.x = 330;
		this.assets3Text.y = 88;
		this.assets3Text.width = 100;
		this.assets3Text.height = 24;
		this.assets3Text.defaultTextFormat = new TextFormat("embedFontA", 18, 4160774);
		this.assets3Text.embedFonts = true;
		this.assets3Text.text = "";
		addChild(this.assets3Text);
		this.homeLink = new LipiButton();
		this.homeLink.bgAlpha = 0;
		this.homeLink.bgSkin = new LipiSkin(MaterialLib.getInstance().getClass("ButtonGreen"));
		this.homeLink.visible = false;
		this.homeLink.addEventListener(MouseEvent.CLICK, this.onClick);
		this.homeLink.x = 330;
		this.homeLink.y = 26;
		this.homeLink.width = 100;
		this.homeLink.height = 24;
		this.homeLink.label = "去TA的首页";
		this.homeLink.textColor = 16777215;
		addChild(this.homeLink);
	}

	// ProfileHead.as:168-172
	private function ioError(param1:IOErrorEvent):Void {
		trace("profile头像加载错误");
		this.loadbg.visible = true;
	}

	// ProfileHead.as:174-236（原类只有 set data，无 getter）
	public var data(never, set):Dynamic;

	private function set_data(param1:Dynamic):Dynamic {
		var homePageStr:String;
		var uLevel:Int;
		var headURL:String = null;
		var url:String = null;
		var value:Dynamic = param1;
		var mainData:MainData = MData.getInstance().mainData;
		this.nameText.htmlText = Std.string(Reflect.field(value, "uName"));
		this.assets1Text.text = Std.string(Reflect.field(value, "money"));
		this.assets3Text.text = Std.string(Reflect.field(value, "moralexp"));
		this._homePage = Std.string(Reflect.field(value, "homePage"));
		this.gradeText.text = Std.string(Reflect.field(value, "uLevel"));
		Command.getInstance().mainCommand.getMarkListFromJs(function(param1:String):Void {
			nameText.htmlText = param1;
		}, mainData.currentUserUin);
		if (this.assets2Text != null) {
			this.assets2Text.text = Std.string(Reflect.field(value, "FB"));
		}
		uLevel = As3.intOf(Reflect.field(value, "uLevel"));
		this.expText.text = Std.string(MData.getInstance().mainData.gradeToExp(As3.intOf(Reflect.field(value, "uLevel"))) - As3.floatOf(Reflect.field(value, "uExp")));
		if (LocalData.isMe) {
			headURL = mainData.host.headPic;
		} else {
			headURL = mainData.currentUser.headPic;
		}
		this.photoLoader.unload();
		this.photoLoader.visible = false;
		if (Version.value == "qzone") {
			if (LocalData.isMe) {
				url = JSProxy.getHead(Std.string(Reflect.field(mainData.host, "uin")), 100);
			} else {
				url = JSProxy.getHead(mainData.currentUserUin, 100);
			}
			// PORT-NOTE(qq-outlet)：远端头像 Loader.load 统一走 QQOutlets.loadImage
			// （html5 上由宿主页代理加载，其余目标空实现）
			QQOutlets.loadImage(this.photoLoader, new URLRequest(url));
			this.photoLoader.visible = true;
			this.loadbg.visible = true;
		} else if (As3.truthy(headURL)) {
			// PORT-NOTE(qq-outlet)：同上
			QQOutlets.loadImage(this.photoLoader, new URLRequest(new EReg("/30$", "").replace(headURL, "/100")));
			this.photoLoader.visible = true;
			this.loadbg.visible = true;
		}
		homePageStr = Std.string(Reflect.field(value, "homePage"));
		if (MData.getInstance().mainData.me == true
			|| As3.eqString(Reflect.field(mainData.host, "uin"), homePageStr.substring(homePageStr.lastIndexOf("/") + 1, homePageStr.length))) {
			this.homeLink.visible = false;
		} else {
			this.homeLink.visible = true;
		}
		return param1;
	}

	// ProfileHead.as:238-244
	private function onClick(param1:MouseEvent):Void {
		if (this._homePage != "") {
			// PORT-NOTE(openfl)：navigateToURL 在 openfl 支持不完整，走
			// shim.NavigateToURL（html5 上 window.open，其余目标空实现）
			NavigateToURL.navigateToURL(new URLRequest(this._homePage));
		}
	}

	// ProfileHead.as:246-251
	private function onComp(param1:Event):Void {
		this.photoLoader.width = 100;
		this.photoLoader.height = 100;
		this.loadbg.visible = false;
	}
}
