package module.warehouse.house.widgets;

import com.qzone.qui.controls.Button;
import com.qzone.utils.AlignUtil;
import com.qzone.utils.GraphicsUtil;
import common.Language;
import common.misc.Utils;
import events.ViewEvent;
import openfl.display.Bitmap;
import openfl.display.Loader;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.events.TextEvent;
import openfl.filters.GlowFilter;
import openfl.geom.Rectangle;
import openfl.net.URLRequest;
import openfl.system.LoaderContext;
import openfl.text.TextField;
import openfl.text.TextFieldAutoSize;
import openfl.text.TextFormat;
import shim.As3;

/**
 * module.warehouse.house.widgets.FlowerRenderItem —— FlowerRenderItem.as
 * 逐句对应（issue #36 功能 swf 翻译：仓库）。花束/收到花束瓦格子项（自有
 * CHILD_CLICK/CHILD_OVER/CHILD_OUT，非 BaseTileItem 系）：ItemBg 边框 +
 * Loader 外链花束图 + 名字/预览文本，mode 0 是「可赠送」卡（canMake 真
 * 挂赠送按钮，假挂「材料不足」），mode 非 0 是「收到」卡（friendName +
 * 点击查看）。SEND_FLOWER/PREVIEW/NOT_ENOUGH 三事件冒泡。
 *
 * PORT-NOTE: Loader.load(URLRequest) 外链花束图保持原调用形态（CLAUDE.md：
 * 远程 swf → Assets 的映射只落在 mcloader 加载器类；HarvestAnimationCustom
 * 先例）；contentLoaderInfo 的匿名闭包经 arguments.callee 自摘除 → 捕获
 * 局部 fn 的闭包；`Language.L["赠送花束"]` → Reflect.field；`_item["mode"] == 0`
 * 宽松等值 → As3.floatOf；`canMake == true` → As3.truthy；`pic != undefined`
 * → As3.hasProp（ShopModel 同款约定）；`as Sprite`/`as Bitmap` → 判型直取。
 */
class FlowerRenderItem extends Sprite {
	// FlowerRenderItem.as:25
	public static final SEND_FLOWER:String = "SendFlower";

	// FlowerRenderItem.as:27
	public static final PREVIEW:String = "PreviewFlower";

	// FlowerRenderItem.as:29
	public static final NOT_ENOUGH:String = "NotEnough";

	// FlowerRenderItem.as:31
	public static final CHILD_CLICK:String = "childClick";

	// FlowerRenderItem.as:33
	public static final CHILD_OUT:String = "childOut";

	// FlowerRenderItem.as:35
	public static final CHILD_OVER:String = "childOver";

	// FlowerRenderItem.as:37
	private var _pictureSize:Int;

	// FlowerRenderItem.as:39
	private var _txtDesc:TextField;

	// FlowerRenderItem.as:41（AS3 protected → private）
	private var _item:Dynamic;

	// FlowerRenderItem.as:43
	private var _ld:Loader;

	// FlowerRenderItem.as:45
	private var _border:Sprite;

	// FlowerRenderItem.as:47
	private var _txtName:TextField;

	// FlowerRenderItem.as:49-87
	public function new() {
		super();
		this._pictureSize = 0;
		var borderMat:Dynamic = Utils.getMaterial("ItemBg");
		this._border = Std.isOfType(borderMat, Sprite) ? cast(borderMat, Sprite) : null;
		this._border.name = "ItemBg";
		addChild(this._border);
		this._border.buttonMode = true;
		this._ld = new Loader();
		this._ld.mouseChildren = this._ld.mouseEnabled = false;
		// AS3 匿名闭包经 arguments.callee 自摘除 → 捕获局部 fn（构造一次）
		var fn:Dynamic = null;
		fn = function(ev:Event):Void {
			var _loc2_:Loader = cast(cast(ev.target, openfl.display.LoaderInfo).loader, Loader);
			_loc2_.width = _loc2_.height = _pictureSize - 4;
			_loc2_.x = (_pictureSize - _loc2_.width) / 2;
			_loc2_.y = (_pictureSize - _loc2_.height) / 2;
			cast(_loc2_.content, Bitmap).smoothing = true;
			_loc2_.contentLoaderInfo.removeEventListener(Event.COMPLETE, fn);
		};
		this._ld.contentLoaderInfo.addEventListener(Event.COMPLETE, fn);
		addChild(this._ld);
		this._txtName = new TextField();
		this._txtName.selectable = false;
		this._txtName.height = 22;
		this._txtName.width = 98;
		this._txtName.defaultTextFormat = new TextFormat("Verdana", 12, 6710886);
		addChild(this._txtName);
		this._txtDesc = new TextField();
		this._txtDesc.selectable = false;
		this._txtDesc.defaultTextFormat = new TextFormat("Verdana", 12, 16777215);
		this._txtDesc.filters = [new GlowFilter(30148, 1, 3, 3)];
		this._txtDesc.autoSize = TextFieldAutoSize.LEFT;
		addChild(this._txtDesc);
		GraphicsUtil.draw(this, 16777215, 0, new Rectangle(0, 0, 90, 145));
		this._border.addEventListener(MouseEvent.ROLL_OVER, this.onOver);
		this._border.addEventListener(MouseEvent.ROLL_OUT, this.onOut);
		this._border.addEventListener(MouseEvent.CLICK, this.onSendOutFlower);
		addEventListener(TextEvent.LINK, this.onLinkClicked);
	}

	// FlowerRenderItem.as:89-94
	private function onSendOutFlower(param1:MouseEvent):Void {
		var _loc2_:ViewEvent = new ViewEvent(SEND_FLOWER, true);
		_loc2_.data = this._item;
		dispatchEvent(_loc2_);
	}

	// FlowerRenderItem.as:96-99 + :109-170（AS3 public get/set data 对）
	public var data(get, set):Dynamic;

	private function get_data():Dynamic {
		return this._item;
	}

	// FlowerRenderItem.as:101-107
	private function onOut(param1:MouseEvent):Void {
		param1.stopPropagation();
		var _loc2_:ViewEvent = new ViewEvent(CHILD_OUT, true);
		_loc2_.data = this._item;
		dispatchEvent(_loc2_);
	}

	// FlowerRenderItem.as:109-170
	private function set_data(param1:Dynamic):Dynamic {
		var _loc2_:Button = null;
		var _loc3_:TextField = null;
		if (this._item == param1) {
			return param1;
		}
		this._item = param1;
		if (this._item == null) {
			return param1;
		}
		if (As3.floatOf(Reflect.field(this._item, "mode")) == 0) {
			this._pictureSize = 90;
			this._txtName.text = Reflect.field(this._item, "fName");
			this._txtName.y = this._pictureSize;
			this._txtDesc.htmlText = "<a href=\'event:view\'>" + "预览" + "</a>";
			this._txtDesc.x = this._pictureSize - this._txtDesc.width - 2;
			this._txtDesc.y = this._pictureSize;
			if (As3.truthy(Reflect.field(this._item, "canMake"))) {
				_loc2_ = new Button();
				_loc2_.defaultSkin = Utils.getClass("ButtonBlue");
				_loc2_.width = 60;
				_loc2_.height = 25;
				_loc2_.text = Reflect.field(Language.L, "赠送花束");
				_loc2_.x = AlignUtil.middle(this._pictureSize, _loc2_.width);
				_loc2_.y = this._txtName.y + 22;
				_loc2_.clickFn = this.onSendOutFlower;
				addChild(_loc2_);
			} else {
				_loc3_ = new TextField();
				_loc3_.defaultTextFormat = new TextFormat("Verdana", 12, 16711680);
				_loc3_.selectable = false;
				_loc3_.width = 80;
				_loc3_.htmlText = "<a href=\"event:cant\">材料不足</a>";
				_loc3_.y = this._txtName.y + 22;
				_loc3_.height = 22;
				addChild(_loc3_);
			}
		} else {
			this._pictureSize = 96;
			this._txtName.text = Reflect.field(this._item, "friendName");
			this._txtName.x = (this._pictureSize - this._txtName.width) * 0.5;
			this._txtName.y = this._pictureSize;
			this._txtName.autoSize = TextFieldAutoSize.CENTER;
			this._txtDesc.htmlText = "<a href=\'event:view\'>" + "点击查看" + "</a>";
			this._txtDesc.x = this._pictureSize - this._txtDesc.width - 2;
			this._txtDesc.y = this._pictureSize - this._txtDesc.height - 2;
		}
		this._border.width = this._border.height = this._pictureSize;
		if (As3.hasProp(this._item, "pic") && Reflect.field(this._item, "pic") != "") {
			this._ld.load(new URLRequest(Reflect.field(this._item, "pic")), new LoaderContext(true));
		}
		return param1;
	}

	// FlowerRenderItem.as:172-178
	private function onOver(param1:MouseEvent):Void {
		param1.stopPropagation();
		var _loc2_:ViewEvent = new ViewEvent(CHILD_OVER, true);
		_loc2_.data = this._item;
		dispatchEvent(_loc2_);
	}

	// FlowerRenderItem.as:180-196
	private function onLinkClicked(param1:TextEvent):Void {
		param1.stopPropagation();
		var _loc2_:ViewEvent = null;
		if (param1.text == "view") {
			_loc2_ = new ViewEvent(PREVIEW, true);
			_loc2_.data = this._item;
			dispatchEvent(_loc2_);
		} else if (param1.text == "cant") {
			_loc2_ = new ViewEvent(NOT_ENOUGH, true);
			_loc2_.data = this._item;
			dispatchEvent(_loc2_);
		}
	}
}
