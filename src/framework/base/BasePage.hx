package framework.base;

import com.qzone.qui.containers.TileList;
import common.view.DataLoading;
import events.ViewEvent;
import openfl.display.DisplayObjectContainer;
import openfl.display.Sprite;

/**
 * framework.base.BasePage —— BasePage.as 逐句对应（issue #18 qui 收尾：
 * 框架片）。商店分页基类：居中 DataLoading 转圈/错误层，dataList 首次写入
 * 时懒建 TileList（onCreateTile 覆写点）并 setData；loadingVisible 切换
 * 转圈层与列表的可见性（互斥）。
 */
@:keep
class BasePage extends Sprite {
	// BasePage.as:12-20
	private var _view:DisplayObjectContainer;

	private var _tile:TileList;

	private var _preferedHeight:Int;

	private var _preferedWidth:Int;

	private var _dataLoading:DataLoading;

	// :22-30
	public function new(param1:DisplayObjectContainer, param2:Int, param3:Int) {
		super();
		this._preferedWidth = param2;
		this._preferedHeight = param3;
		this._view = param1;
		this._tile = null;
		this.createLoadingBar();
	}

	// :32-42
	private function createLoadingBar():Void {
		if (this._dataLoading == null) {
			this._dataLoading = new DataLoading();
			this._dataLoading.addEventListener(ViewEvent.LINK_CLICK, this.onLinkClicked);
			this._dataLoading.x = (this._preferedWidth - this._dataLoading.width) / 2;
			this._dataLoading.y = (this._preferedHeight - this._dataLoading.height) / 2;
			addChild(this._dataLoading);
		}
	}

	// :44-46（空实现：子类覆写点）
	private function onCreateTile():Void {}

	// :48-54（AS3 纯 setter errText）
	public var errText(never, set):String;

	private function set_errText(param1:String):String {
		if (this._dataLoading != null) {
			this._dataLoading.errorText = param1;
		}
		return param1;
	}

	// :56-58（空实现：子类覆写点）
	private function setData():Void {}

	// :60-69
	private function onLinkClicked(param1:ViewEvent):Void {
		if (param1 == null || param1.data == null) {
			return;
		}
		var _loc2_:ViewEvent = new ViewEvent(ViewEvent.LINK_CLICK);
		_loc2_.data = param1.data;
		dispatchEvent(_loc2_);
	}

	// :71-78 + :80-90（AS3 public get/set dataList 对）
	public var dataList(get, set):Array<Dynamic>;

	private function get_dataList():Array<Dynamic> {
		if (this._tile == null) {
			return null;
		}
		return this._tile.dataProvider;
	}

	// :80-90
	private function set_dataList(param1:Array<Dynamic>):Array<Dynamic> {
		if (this._tile == null) {
			this._tile = new TileList();
			this.onCreateTile();
			addChild(this._tile);
		}
		this._tile.dataProvider = param1;
		this.setData();
		return param1;
	}

	// :92-102（AS3 纯 setter loadingVisible）
	public var loadingVisible(never, set):Bool;

	private function set_loadingVisible(param1:Bool):Bool {
		if (this._dataLoading != null) {
			this._dataLoading.visible = param1;
		}
		if (this._tile != null) {
			this._tile.visible = !param1;
		}
		return param1;
	}
}
