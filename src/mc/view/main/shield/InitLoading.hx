package mc.view.main.shield;

import mc.control.Command;
import mc.view.common.DataLoading;
import openfl.display.Sprite;
import openfl.events.TextEvent;
import openfl.text.TextField;
import openfl.text.TextFormat;

/**
 * mc.view.main.shield.InitLoading —— InitLoading.as 逐句对应（issue #87
 * 「护盾层」片）。初始化加载屏：ctor 摆 DataLoading(250,10) +
 * "数据初始化中..." 文本（Verdana 14 居中 700x20 不可选，挂 LINK 监听）；
 * errorText 写入 htmlText 并藏 DataLoading；linkClick 按 "reload"/"noreg"
 * 转 mainCommand.run/register。
 * legacy/decompiled/Master2_v_142/scripts/mc/view/main/shield/InitLoading.as。
 *
 * PORT-NOTE(跨片依赖)：MainCommand.run/register（mc/control 控制/命令片）
 * 在本片开工时 stub 无签名面——按原样直引，所属片充真身后编译链闭合
 * （本轮并行片既定做法）。
 */
@:keep
class InitLoading extends Sprite {
	// InitLoading.as:13-15
	private var dataLoading:DataLoading;
	private var _textField:TextField;

	// InitLoading.as:17-33
	public function new() {
		super();
		this.dataLoading = new DataLoading();
		this.dataLoading.x = 250;
		this.dataLoading.y = 10;
		this.dataLoading.visible = true;
		addChild(this.dataLoading);
		this._textField = new TextField();
		this._textField.addEventListener(TextEvent.LINK, this.linkClick);
		this._textField.defaultTextFormat = new TextFormat("Verdana", 14, 8999699, null, null, null, null, null, "center");
		this._textField.text = "数据初始化中...";
		this._textField.width = 700;
		this._textField.height = 20;
		this._textField.selectable = false;
		addChild(this._textField);
	}

	// InitLoading.as:35-38
	public var errorText(never, set):String;

	private function set_errorText(param1:String):String {
		this._textField.htmlText = param1;
		this.dataLoading.visible = false;
		return param1;
	}

	// InitLoading.as:40-53
	private function linkClick(param1:TextEvent):Void {
		if (param1.text == "reload") {
			this._textField.text = "数据初始化中...";
			this.dataLoading.visible = true;
			Command.getInstance().mainCommand.run();
		}
		if (param1.text == "noreg") {
			Command.getInstance().mainCommand.register();
		}
	}
}
