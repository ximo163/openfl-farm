package com.qzone.qui.containers;

import com.qzone.qui.controls.Label;
import com.qzone.qui.controls.UIComponent;
import com.qzone.qui.core.Align;
import com.qzone.qui.skins.PanelDefaultSkin;
import com.qzone.qui.styles.Style;
import com.qzone.utils.AlignUtil;
import com.qzone.utils.DisplayUtil;
import openfl.display.DisplayObjectContainer;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.text.TextFormat;

/**
 * com.qzone.qui.containers.Panel —— Panel.as 逐句对应（issue #18 qui 收尾：
 * 容器片整类翻译，替换 #9 的签名 stub）。面板：底板皮肤 + 内容区
 * （marginT 头部/边距四向）+ 标题 Label + 可选 ControlBar。自带 _content/
 * content（UIComponent 链上无 content，与 ScrollBase 系互不相干）。
 */
@:keep
class Panel extends UIComponent {
	// Panel.as:13-35
	public var titleAlign:String = "left";

	public var showControlBar:Bool;

	private var marginB:Int;

	private var _title:String;

	public var controlBarSkin:Class<Dynamic>;

	private var _skin:Sprite;

	private var marginL:Int;

	private var marginR:Int;

	public var defaultSkin:Class<Dynamic>;

	public var titleDefautFormat:TextFormat;

	private var marginT:Int;

	public var controlBar:ControlBar;

	public var autoLayout:Bool;

	private var _content:DisplayObjectContainer;

	private var panelTitle:Label;

	// :37-53
	public function new(param1:String = "Panel", param2:Int = 300, param3:Int = 200) {
		super();
		this._title = param1;
		this._height = param3;
		this._width = param2;
		this.marginT = Style.panelHeadHeight;
		this.marginB = Style.panelControlBarHeight;
		this.marginR = Style.panelPaddingH;
		this.marginL = Style.panelPaddingH;
		this.defaultSkin = PanelDefaultSkin.skin;
		this.controlBarSkin = PanelDefaultSkin.controlBarSkin;
		this.titleDefautFormat = Style.getLabelFormat();
	}

	// :55-64
	public var content(get, set):DisplayObjectContainer;

	private function get_content():DisplayObjectContainer {
		if (this._content == null) {
			this._content = new Sprite();
			this.setContent();
			this.addChild(this._content);
		}
		return this._content;
	}

	// :66-71
	private function contentResize(param1:Event):Void {
		this._width = this._content.width + this.marginL + this.marginR;
		this._height = this._content.height + this.marginT + this.marginB;
		this.setSize();
	}

	// :73-84
	private override function setSize():Void {
		super.setSize();
		if (this._skin != null) {
			this._skin.width = this._width;
			this._skin.height = this._height;
		}
		if (this.controlBar != null) {
			this.controlBar.width = this._width;
			this.controlBar.y = this._height - this.controlBar.height;
		}
	}

	// :86-89
	public var nativeHeight(get, never):Int;

	private function get_nativeHeight():Int {
		return Std.int(this._height - this.marginT - this.marginB);
	}

	// :91-93
	private function get_title():String {
		return this._title;
	}

	// :95-100
	private function set_content(param1:DisplayObjectContainer):DisplayObjectContainer {
		DisplayUtil.removeChild(this, this._content);
		this._content = param1;
		this.setContent();
		this.addChild(this._content);
		return param1;
	}

	// :102-109
	public var title(get, set):String;

	private function set_title(param1:String):String {
		this._title = param1;
		if (this.panelTitle != null) {
			this.panelTitle.text = this._title;
		}
		return param1;
	}

	// :111-125
	private function setContent():Void {
		this._content.y = this.marginT;
		this._content.x = this.marginL;
		if (this.autoLayout) {
			this._width = this._content.width + this.marginL + this.marginR;
			this._height = this._content.height + this.marginT + this.marginB;
			this._content.addEventListener(Event.RESIZE, this.contentResize);
			this.setSize();
		} else {
			this._content.height = this._height - this.marginT - this.marginB;
			this._content.width = this._width - this.marginL - this.marginR;
		}
	}

	// :127-129
	public var nativeWidth(get, never):Int;

	private function get_nativeWidth():Int {
		return Std.int(this._width - this.marginL - this.marginR);
	}

	// :131-159
	private override function setSkin():Void {
		this._skin = cast Type.createInstance(this.defaultSkin, []);
		this.addChildAt(this._skin, 0);
		if (this.showControlBar == true) {
			this.controlBar = new ControlBar();
			this.addChild(this.controlBar);
		}
		if (this.panelTitle == null) {
			this.panelTitle = new Label();
			this.panelTitle.textDefaultFormat = this.titleDefautFormat;
			this.panelTitle.y = 0;
			this.panelTitle.mouseEnabled = false;
			this.addChild(this.panelTitle);
		}
		if (this.titleAlign == Align.CENTER) {
			this.panelTitle.x = AlignUtil.middle(this._width, this.panelTitle.width);
		} else {
			this.panelTitle.x = 4;
		}
		this.panelTitle.text = this._title;
	}
}
