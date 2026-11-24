package common.view.window;

import FarmLoading;
import com.qzone.qui.controls.Button;
import common.Consts;
import common.misc.Utils;
import interfaces.IMsgCenter;
import openfl.display.Loader;
import openfl.display.MovieClip;
import openfl.events.Event;
import openfl.events.TextEvent;
import openfl.net.URLRequest;
import openfl.text.TextField;
import openfl.text.TextFormat;
import report.EventRecorder;
import shim.As3;

/**
 * common.view.window.PostWindow —— PostWindow.as 逐句对应（issue #45：
 * #31 messages 片漏翻补齐，替换 #9 的闭包 stub）。系统公告窗：PostWindowBG
 * 皮肤在域内时换肤收边距（param4=true 走 NoticeWindow 形态边距 3/5/27/5），
 * htmlText 正文 + TextEvent.LINK 上报 HF_POSTCLICK 后关窗，imgUrl 拉公告图
 * （Loader + FarmLoading 转圈，onLoaded 按 _fixSize 定尺寸或 500ms 后按
 * 图幅居中重排），可选按钮（_btnText 非空）走 addButton（y 上提 100），
 * confirmFn 关窗后调 _btnCallback（用后不清，与 ConfirmWindow 相异）。
 */
@:keep
class PostWindow extends AddButtonWindow {
	// PostWindow.as:20（AS3 Function → Dynamic，AddButtonWindow.addButton
	// param5 先例）
	private var _btnCallback:Dynamic;

	// PostWindow.as:22
	private var _postText:TextField;

	// PostWindow.as:24
	private var _text:String;

	// PostWindow.as:26
	private var _btn:Button;

	// PostWindow.as:28
	private var _defaultSkin:Bool;

	// PostWindow.as:30
	private var _btnText:String;

	// PostWindow.as:32
	private var _loader:Loader;

	// PostWindow.as:34（ctor :71 置 true；:101/:183 定尺寸分支）
	private var _fixSize:Bool;

	// PostWindow.as:36
	private var _loading:MovieClip;

	// PostWindow.as:38-72。PORT-NOTE: :50-53 的 `super.marginL = 10` 等——
	// marginL/R/T/B 是 Panel 普通字段，Haxe 禁止 super 访问普通变量（编译
	// 错误），落 this 访问；PostWindow 不遮蔽这些字段，语义与原版一致
	public function new(param1:IMsgCenter = null, param2:String = "", param3:Dynamic = null, param4:Bool = false) {
		var _loc5_:Class<Dynamic> = null;
		super(param1);
		this._defaultSkin = true;
		if (param4 == false) {
			_loc5_ = Utils.getClass("PostWindowBG");
			if (_loc5_ != null) {
				defaultSkin = _loc5_;
				this._defaultSkin = false;
				marginL = 10;
				marginR = 10;
				marginT = 35;
				marginB = 10;
			}
		} else {
			marginL = 3;
			marginR = 5;
			marginT = 27;
			marginB = 5;
		}
		_width = 442.1;
		_height = 435.8;
		mode = true;
		this._text = "";
		this._btn = null;
		this._btnText = param2;
		this._btnCallback = param3;
		windowName = Consts.WINDOW_NAME_SYS_POST_MSG;
		this._fixSize = true;
	}

	// PostWindow.as:74-85（FarmLoading 是 farmui_full_v_40.swf SymbolClass
	// 导出符号的顶层壳类，Crop/DogRender 同款 import）
	private function showLoadingAnimation():Void {
		if (this._loading == null) {
			this._loading = new FarmLoading();
			this._loading.x = width * 0.5;
			this._loading.y = height * 0.5;
			this._loading.mouseEnabled = false;
			this._loading.mouseChildren = false;
			addChild(this._loading);
		}
	}

	// PostWindow.as:87-95
	private function stopLoadingAnimation():Void {
		if (this._loading != null && this.contains(this._loading) == true) {
			this._loading.stop();
			removeChild(this._loading);
			this._loading = null;
		}
	}

	// PostWindow.as:97-123。`var e:Event = param1;` 是 FFDec 还原噪音，照译
	// 保留（FarmStage.showWildStage 先例）；flash.utils.setTimeout →
	// As3.setTimeout（shim 头注释）。:103/:109 的 `super.autoLayout` 同上方
	// PORT-NOTE（Panel 普通字段）；`super.content` 是属性，super 访问合法
	private function onLoaded(param1:Event):Void {
		var e:Event = param1;
		this.stopLoadingAnimation();
		if (this._fixSize == true) {
			autoLayout = false;
			super.content = this._loader;
			this._loader.scaleX = 1;
			this._loader.scaleY = 1;
		} else {
			autoLayout = true;
			super.content = this._loader;
			As3.setTimeout(function():Void {
				if (stage != null) {
					move((stage.stageWidth - (_loader.width + marginL + marginR)) * 0.5,
						(stage.stageHeight - (_loader.height + marginT + marginB)) * 0.5);
				}
			}, 500);
			if (panelTitle != null) {
				panelTitle.x = (_width - panelTitle.width) * 0.5;
			}
		}
	}

	// PostWindow.as:125-145（`this.text || ""` → As3.or，AS3 动态真值短路）
	override private function init():Void {
		if (this._btnText != "") {
			this._btn = addButton(this._btnText, "ButtonGreen", 65, 25, this.confirmFn);
			super.init();
			this._btn.y -= 100;
		}
		this._postText = new TextField();
		this._postText.wordWrap = true;
		this._postText.multiline = true;
		var _loc1_:TextFormat = new TextFormat("Verdana");
		this._postText.defaultTextFormat = _loc1_;
		this._postText.x = 17;
		this._postText.y = 36;
		this._postText.width = 420;
		this._postText.height = 224;
		this._postText.htmlText = As3.or(this.text, "");
		this._postText.addEventListener(TextEvent.LINK, this.onLinkClicked, false, 0, true);
		addChild(this._postText);
	}

	// PostWindow.as:147-153
	public function enableBtn(param1:Bool):Void {
		if (this._btn != null) {
			this._btn.enabled = param1;
		}
	}

	// PostWindow.as:155-166（AS3 setter 无返回值，Haxe 属性 setter 返回入参）
	private function set_text(param1:String):String {
		this._text = param1;
		if (this._postText != null) {
			this._postText.htmlText = param1;
		}
		if (this._loader != null) {
			this._loader.unload();
		}
		return param1;
	}

	// PostWindow.as:168-175（回调用后不清，对照 ConfirmWindow :159 的清空）
	private function confirmFn():Void {
		super.close();
		if (this._btnCallback != null) {
			this._btnCallback();
		}
	}

	// PostWindow.as:177-190
	override public function onEffectEnd():Void {
		if (this._defaultSkin == false) {
			this.y += 80;
		}
		if (this._fixSize == false) {
			if (stage != null) {
				move((stage.stageWidth - (this._loader.width + marginL + marginR)) * 0.5,
					(stage.stageHeight - (this._loader.height + marginT + marginB)) * 0.5);
			}
		}
	}

	// PostWindow.as:192-198（`super.data["text"]`：Dynamic 键下标 →
	// Reflect.field，踩坑 #19）
	override private function setData():Void {
		if (super.data != null) {
			this.text = Reflect.field(super.data, "text");
		}
	}

	// PostWindow.as:200-203
	private function get_text():String {
		return this._text;
	}

	public var text(get, set):String;

	// PostWindow.as:205-229（公告图 URL 来自服务端数据（user_getnotice），
	// 照原调用形态 URLRequest 直拉，不走本地资产通道）
	public var imgUrl(never, set):String;

	private function set_imgUrl(param1:String):String {
		if (param1 == null || param1 == "") {
			return param1;
		}
		if (this._loader == null) {
			this._loader = new Loader();
			this._loader.x = 0;
			this._loader.y = 0;
		} else if (this._loader.contentLoaderInfo != null && this._loader.contentLoaderInfo.url == param1) {
			return param1;
		}
		this._loader.unload();
		this._loader.load(new URLRequest(param1));
		this._loader.contentLoaderInfo.addEventListener(Event.COMPLETE, this.onLoaded);
		this.showLoadingAnimation();
		if (this._postText != null) {
			this._postText.htmlText = "";
		}
		return param1;
	}

	// PostWindow.as:231-235
	private function onLinkClicked(param1:TextEvent):Void {
		EventRecorder.recordSueecssEvent(EventRecorder.HF_POSTCLICK, 0);
		super.close();
	}

	// PostWindow.as:237-240（issue #37：WaterGrayOpen `_tutorial.fixSize =
	// false` 教程窗关尺寸自适应）
	public var fixSize(never, set):Bool;

	private function set_fixSize(param1:Bool):Bool {
		this._fixSize = param1;
		return param1;
	}
}
