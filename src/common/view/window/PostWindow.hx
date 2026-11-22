package common.view.window;

import interfaces.IMsgCenter;

/**
 * common.view.window.PostWindow —— 闭包 stub（issue #9）。完整类在
 * spec/modules/messages.json :228（公告窗 243 loc，messages 片翻译）；
 * 本片 uitools 的 LeftSideToolBar.openPostWindow/onSystemPostLoaded 引用的
 * 成员：ctor 默认参形态（PostWindow.as:38）、text 存取（:155-166/:200-203）、
 * imgUrl 写入（:205-229）；title/closeFn 继承自 Panel/TitleWindow。窗体显示
 * （皮肤、_postText、Loader 装配）随 messages 片接入，stub 只保成员语义。
 * legacy/decompiled/main3_v_221/scripts/common/view/window/PostWindow.as
 */
@:keep
class PostWindow extends AddButtonWindow {
	// PostWindow.as:24
	private var _text:String;

	// PostWindow.as:34（issue #37：WaterGrayOpen `_tutorial.fixSize = false`；
	// ctor :71 置 true，:101/:183 定尺寸分支随 messages 片）
	private var _fixSize:Bool = true;

	// PostWindow.as:38-72（ctor 默认参形态照抄；PostWindowBG 皮肤、边距、
	// windowName 装配随 messages 片）
	public function new(param1:IMsgCenter = null, param2:String = "", param3:Dynamic = null, param4:Bool = false) {
		super(param1);
		this._text = "";
	}

	// PostWindow.as:200-203
	public var text(get, set):String;

	private function get_text():String {
		return this._text;
	}

	// PostWindow.as:155-166（setText 同时刷 _postText.htmlText/卸 _loader，
	// stub 只存值，随 messages 片接入）
	private function set_text(param1:String):String {
		this._text = param1;
		return param1;
	}

	// PostWindow.as:205-229（set imgUrl：空值守卫照抄；Loader 拉图随
	// messages 片，stub 只过守卫不装配）
	public var imgUrl(never, set):String;

	private function set_imgUrl(param1:String):String {
		if (param1 == null || param1 == "") {
			return param1;
		}
		return param1;
	}

	// PostWindow.as:237-240（issue #37：WaterGrayOpen 教程窗关尺寸自适应）
	public var fixSize(never, set):Bool;

	private function set_fixSize(param1:Bool):Bool {
		this._fixSize = param1;
		return param1;
	}
}
