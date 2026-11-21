package mc.view.main.window.profile;

import com.minutes.ui.collections.LipiListChild;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.text.TextFormatAlign;
import mc.view.ViewEvent;
import mc.view.common.MaterialLoaderProxy;
import shim.As3;

/**
 * mc.view.main.window.profile.HistoryItem —— HistoryItem.as 逐句对应
 * （issue #19）。成果格：图标（MaterialLoaderProxy）+ 收获数字，悬停向上
 * 冒 CHILD_OVER/CHILD_OUT。原文件
 * legacy/decompiled/Master2_v_142/scripts/mc/view/main/window/profile/HistoryItem.as。
 */
@:keep
class HistoryItem extends LipiListChild {
	// HistoryItem.as:15-19（与 LipiTile2 的同名静态重复声明，原版如此）
	public static var CHILD_OVER:String = "childOver";

	public static var CHILD_OUT:String = "childOut";

	public static var CHILD_MOVE:String = "childMove";

	private var _material:MaterialLoaderProxy;

	// _data 继承 LipiListChild（Haxe 不允许子类重声明同名字段）

	private var text:TextField;

	public function new() {
		super();
		this.init();
	}

	// HistoryItem.as:33-36
	override public function get_data():Dynamic {
		return this._data;
	}

	// HistoryItem.as:38-43
	private function onOut(param1:MouseEvent):Void {
		var _loc2_:ViewEvent = new ViewEvent(ViewEvent.CHILD_OUT, true);
		_loc2_.data = this.data;
		dispatchEvent(_loc2_);
	}

	// HistoryItem.as:45-60
	private function init():Void {
		this._material = new MaterialLoaderProxy();
		addChild(this._material);
		this.text = new TextField();
		this.text.selectable = false;
		this.text.width = 60;
		this.text.height = 22;
		this.text.defaultTextFormat = new TextFormat("Arial", 16, 16737792, true, null, null, null, null, TextFormatAlign.CENTER);
		this.text.x = 0;
		this.text.y = 60;
		this.text.text = "0";
		addChild(this.text);
		addEventListener(MouseEvent.ROLL_OVER, this.onOver);
		addEventListener(MouseEvent.ROLL_OUT, this.onOut);
	}

	// HistoryItem.as:62-64（原版空函数，占位）
	private function onLoadCompete(param1:Event):Void {}

	// HistoryItem.as:66-71
	private function onOver(param1:MouseEvent):Void {
		var _loc2_:ViewEvent = new ViewEvent(ViewEvent.CHILD_OVER, true);
		_loc2_.data = this.data;
		dispatchEvent(_loc2_);
	}

	// HistoryItem.as:73-78
	override public function set_data(param1:Dynamic):Dynamic {
		this._data = param1;
		this._material.setContent("2", As3.intOf(Reflect.field(param1, "cId")));
		this.text.text = Std.string(As3.intOf(Reflect.field(param1, "harvest")) + As3.intOf(Reflect.field(param1, "scrounge")));
		return param1;
	}
}
