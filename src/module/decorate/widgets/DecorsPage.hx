package module.decorate.widgets;

import com.qzone.qui.containers.Canvas;
import com.qzone.qui.controls.Label;
import com.qzone.qui.controls.scrollClasses.ScrollPolicy;
import com.qzone.qui.utils.TextFormatUtil;
import com.qzone.utils.GraphicsUtil;
import common.Consts;
import common.Language;
import common.view.window.WindowLabelMaker;
import entities.DecorateItem;
import framework.base.BasePage;
import module.decorate.DecorateView;
import openfl.display.DisplayObjectContainer;
import openfl.display.Sprite;
import openfl.geom.Rectangle;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.text.TextFormatAlign;
import openfl.utils.Dictionary;
import shim.As3;

/**
 * module.decorate.widgets.DecorsPage —— DecorsPage.as 逐句对应（issue
 * #38 功能 swf 翻译：DIY 装饰）。装饰页（不用 TileList，onCreateTile 只负责
 * 把基类懒建的 _tile 摘掉）：顶部五类标题（背景/房子/狗窝/栅栏/狗，x=
 * 0/70/210/140/280 y=23）；「当前装饰」Canvas（y=65 h=80）装
 * DecorHeadRenderItem、「已购买装饰」Canvas（y=188 h=160）装
 * DecorRenderItem，两 Canvas 宽 param2-4、滚动全关；arrangeItems 按类型分
 * 列（1→x20、2→x90、3→x160、4→x230、8→x300，y 起 12 步进 60+15）。视觉
 * 参数逐字照抄。
 *
 * PORT-NOTE: ① `Language.L["…"]` → Reflect.field；`param1[0] as Array` 的
 * Dictionary 取组 → get(0) 后落 Array<Dynamic> 局部；for-each 遍历 null 组
 * 是 AS3 零圈 → 判空跳过。② `_loc3_.data._type`/`._id` 是 DecorateItem 实
 * 字段经 Dynamic 属性读 → cast 后取（cpp 动态字段表查不到真属性）。
 * ③ `_alreadyBuyedCanvas.validateNow()` 在 arrangeItems 尾无条件执行（两次
 * arrange 各调一次，含当前区那次——原版如此）。
 */
class DecorsPage extends BasePage {
	// DecorsPage.as:25
	private var _alreadyBuyedCanvas:Canvas;

	// DecorsPage.as:27
	private var _alreadyBuyedContainer:DisplayObjectContainer;

	// DecorsPage.as:29
	private var _currentDecorateContainer:DisplayObjectContainer;

	// DecorsPage.as:31
	private var _currentDecorateCanvas:Canvas;

	// DecorsPage.as:33-57
	public function new(param1:DecorateView, param2:Int, param3:Int) {
		super(param1, param2, param3);
		this.createTopBanner();
		this._currentDecorateContainer = new Sprite();
		this._currentDecorateCanvas = new Canvas();
		this._currentDecorateCanvas.y = 65;
		this._currentDecorateCanvas.height = 80;
		this._currentDecorateCanvas.width = param2 - 4;
		this._currentDecorateCanvas.defaultSkin = null;
		this._currentDecorateCanvas.horizontalScrollPolicy = ScrollPolicy.OFF;
		this._currentDecorateCanvas.verticalScrollPolicy = ScrollPolicy.OFF;
		this._currentDecorateCanvas.content = this._currentDecorateContainer;
		addChild(this._currentDecorateCanvas);
		this._alreadyBuyedContainer = new Sprite();
		this._alreadyBuyedCanvas = new Canvas();
		this._alreadyBuyedCanvas.y = 188;
		this._alreadyBuyedCanvas.height = 160;
		this._alreadyBuyedCanvas.width = param2 - 4;
		this._alreadyBuyedCanvas.defaultSkin = null;
		this._alreadyBuyedCanvas.horizontalScrollPolicy = ScrollPolicy.OFF;
		this._alreadyBuyedCanvas.content = this._alreadyBuyedContainer;
		addChild(this._alreadyBuyedCanvas);
		this.addText();
	}

	// DecorsPage.as:59-111（列 x 与步进 60+15 逐字照抄）
	private function arrangeItems(param1:DisplayObjectContainer):Void {
		var _loc2_:Int = 15;
		var _loc3_:DecorRenderItem = null;
		var _loc4_:Int = 20;
		var _loc5_:Int = 90;
		var _loc6_:Int = 160;
		var _loc7_:Int = 230;
		var _loc8_:Int = 300;
		var _loc9_:Int = 12;
		var _loc10_:Int = 12;
		var _loc11_:Int = 12;
		var _loc12_:Int = 12;
		var _loc13_:Int = 12;
		var _loc14_:Int = param1.numChildren;
		var _loc15_:Int = 0;
		for (_loc15_ in 0..._loc14_) {
			_loc3_ = Std.isOfType(param1.getChildAt(_loc15_), DecorRenderItem) ? cast(param1.getChildAt(_loc15_), DecorRenderItem) : null;
			if (!(_loc3_ != null && _loc3_.data != null)) {
				continue;
			}
			switch (cast(_loc3_.data, DecorateItem)._type) {
				case 1:
					_loc3_.x = _loc4_;
					_loc3_.y = _loc9_;
					_loc9_ += 60 + _loc2_;
				case 2:
					_loc3_.x = _loc5_;
					_loc3_.y = _loc10_;
					_loc10_ += 60 + _loc2_;
				case 3:
					_loc3_.x = _loc6_;
					_loc3_.y = _loc11_;
					_loc11_ += 60 + _loc2_;
				case 4:
					_loc3_.x = _loc7_;
					_loc3_.y = _loc12_;
					_loc12_ += 60 + _loc2_;
				case 8:
					_loc3_.x = _loc8_;
					_loc3_.y = _loc13_;
					_loc13_ += 60 + _loc2_;
			}
		}
		this._alreadyBuyedCanvas.validateNow();
	}

	// DecorsPage.as:113-123
	private function clearContainer(param1:DisplayObjectContainer):Void {
		if (param1 == null) {
			return;
		}
		while (param1.numChildren > 0) {
			param1.removeChildAt(0);
		}
	}

	// DecorsPage.as:125-143
	private function createTopBanner():Void {
		var _loc1_:Int = 23;
		var _loc2_:TextField = this.addTypeTitle(Reflect.field(Language.L, "背景"));
		_loc2_.x = 0;
		_loc2_.y = _loc1_;
		var _loc3_:TextField = this.addTypeTitle(Reflect.field(Language.L, "房子"));
		_loc3_.x = 70;
		_loc3_.y = _loc1_;
		var _loc4_:TextField = this.addTypeTitle(Reflect.field(Language.L, "狗窝"));
		_loc4_.x = 210;
		_loc4_.y = _loc1_;
		var _loc5_:TextField = this.addTypeTitle(Reflect.field(Language.L, "栅栏"));
		_loc5_.x = 140;
		_loc5_.y = _loc1_;
		var _loc6_:TextField = this.addTypeTitle(Reflect.field(Language.L, "狗"));
		_loc6_.x = 280;
		_loc6_.y = _loc1_;
	}

	// DecorsPage.as:145-151（本页不用 TileList：只把基类懒建的 _tile 摘掉）
	override private function onCreateTile():Void {
		if (_tile != null && contains(_tile) == true) {
			removeChild(_tile);
		}
	}

	// DecorsPage.as:153-171
	private function getChildItemByID(param1:Int):DecorRenderItem {
		var _loc4_:DecorRenderItem = null;
		var _loc2_:Int = this._alreadyBuyedContainer.numChildren;
		var _loc3_:Int = 0;
		while (_loc3_ < _loc2_) {
			_loc4_ = Std.isOfType(this._alreadyBuyedContainer.getChildAt(_loc3_), DecorRenderItem) ? cast(this._alreadyBuyedContainer.getChildAt(_loc3_), DecorRenderItem) : null;
			if (_loc4_ != null) {
				if (cast(_loc4_.data, DecorateItem)._id == param1) {
					return _loc4_;
				}
			}
			_loc3_++;
		}
		return null;
	}

	// DecorsPage.as:173-183
	private function addTypeTitle(param1:String):TextField {
		var _loc2_:TextField = new TextField();
		_loc2_.text = param1;
		_loc2_.selectable = false;
		_loc2_.setTextFormat(new TextFormat("Verdana", 14, 39423, null, null, null, null, null, TextFormatAlign.CENTER));
		_loc2_.width = 100;
		_loc2_.height = 25;
		addChild(_loc2_);
		return _loc2_;
	}

	// DecorsPage.as:185-203
	private function getHeadDecoChildItemByID(param1:Int):DecorHeadRenderItem {
		var _loc4_:DecorHeadRenderItem = null;
		var _loc2_:Int = this._currentDecorateContainer.numChildren;
		var _loc3_:Int = 0;
		while (_loc3_ < _loc2_) {
			_loc4_ = Std.isOfType(this._currentDecorateContainer.getChildAt(_loc3_), DecorHeadRenderItem) ? cast(this._currentDecorateContainer.getChildAt(_loc3_), DecorHeadRenderItem) : null;
			if (_loc4_ != null) {
				if (cast(_loc4_.data, DecorateItem)._id == param1) {
					return _loc4_;
				}
			}
			_loc3_++;
		}
		return null;
	}

	// DecorsPage.as:205-237（说明行宽 _preferedWidth+16、两条分隔题宽 -5）
	private function addText():Void {
		var _loc1_:Label = new Label();
		_loc1_.mouseChildren = true;
		_loc1_.width = _preferedWidth + 16;
		WindowLabelMaker.addTarget(_loc1_);
		_loc1_.textDefaultFormat = TextFormatUtil.clone(_loc1_.textDefaultFormat);
		_loc1_.textDefaultFormat.color = 11171584;
		_loc1_.text = "点击\"已装饰\"装扮，即可将它隐藏。再次点击，即可重新装扮。";
		_loc1_.x = 1;
		_loc1_.y = 0;
		addChild(_loc1_);
		var _loc2_:Label = new Label();
		_loc2_.mouseChildren = false;
		_loc2_.width = _preferedWidth - 5;
		GraphicsUtil.draw(_loc2_, 7855615, 1, null, true);
		GraphicsUtil.hLine(_loc2_, 7855615, 1, new Rectangle(0, _loc2_.height, _loc2_.width));
		_loc2_.textDefaultFormat.align = "center";
		_loc2_.text = "当前装饰";
		_loc2_.x = 3;
		_loc2_.y = 45;
		addChild(_loc2_);
		var _loc3_:Label = new Label();
		_loc3_.mouseChildren = false;
		_loc3_.width = _preferedWidth - 5;
		GraphicsUtil.draw(_loc3_, 7855615, 1, null, true);
		GraphicsUtil.hLine(_loc3_, 7855615, 1, new Rectangle(0, _loc3_.height, _loc3_.width));
		_loc3_.textDefaultFormat.align = "center";
		_loc3_.text = "已购买装饰";
		_loc3_.x = 3;
		_loc3_.y = 166;
		addChild(_loc3_);
	}

	// DecorsPage.as:239-269（-1 是默认背景的哨兵 id，顺带刷它的角标）
	public function forceRefresh(param1:Int, param2:Int):Void {
		var _loc3_:Int = this._currentDecorateContainer.numChildren;
		var _loc4_:DecorHeadRenderItem = null;
		var _loc5_:DecorateItem = null;
		var _loc6_:Int = 0;
		while (_loc6_ < _loc3_) {
			_loc4_ = Std.isOfType(this._currentDecorateContainer.getChildAt(_loc6_), DecorHeadRenderItem) ? cast(this._currentDecorateContainer.getChildAt(_loc6_), DecorHeadRenderItem) : null;
			if (_loc4_ != null && _loc4_.data != null) {
				_loc5_ = Std.isOfType(_loc4_.data, DecorateItem) ? cast(_loc4_.data, DecorateItem) : null;
				if (_loc5_._id == param2 && _loc5_._type == param1) {
					_loc4_.toggleDecorated();
					break;
				}
			}
			_loc6_++;
		}
		var _loc7_:DecorRenderItem = this.getChildItemByID(param2);
		if (_loc7_ != null) {
			_loc7_.toggleDecorated();
		}
		_loc7_ = this.getChildItemByID(-1);
		if (_loc7_ != null) {
			_loc7_.toggleDecorated();
		}
	}

	// DecorsPage.as:271-275
	private function removeAll():Void {
		this.clearContainer(this._currentDecorateContainer);
		this.clearContainer(this._alreadyBuyedContainer);
	}

	// DecorsPage.as:277-293（for-each 遍历 param1 前已有判空早退）
	private function refreshBelow(param1:Array<Dynamic>):Void {
		var _loc3_:DecorateItem = null;
		if (param1 == null || param1.length == 0) {
			return;
		}
		var _loc2_:DecorRenderItem = null;
		var _loc1List:Array<DecorateItem> = cast param1;
		for (_loc3_ in _loc1List) {
			_loc2_ = this.getChildItemByID(_loc3_._id);
			if (_loc2_ != null) {
				_loc2_.toggleDecorated();
			}
		}
	}

	// DecorsPage.as:295-323（for-each 遍历 null 组是 AS3 零圈 → 判空跳过）
	public function buildDecorateList(param1:Dictionary<Int, Array<Dynamic>>):Void {
		var _loc2_:Array<DecorateItem> = null;
		var _loc3_:DecorHeadRenderItem = null;
		var _loc4_:DecorRenderItem = null;
		var _loc5_:DecorateItem = null;
		var _loc6_:DecorateItem = null;
		this.removeAll();
		if (param1 == null) {
			return;
		}
		_loc2_ = cast param1.get(0);
		if (_loc2_ != null) {
			for (_loc5_ in _loc2_) {
				_loc3_ = new DecorHeadRenderItem();
				_loc3_.data = _loc5_;
				this._currentDecorateContainer.addChild(_loc3_);
			}
		}
		_loc2_ = cast param1.get(1);
		if (_loc2_ != null) {
			for (_loc6_ in _loc2_) {
				_loc4_ = new DecorRenderItem();
				_loc4_.data = _loc6_;
				this._alreadyBuyedContainer.addChild(_loc4_);
			}
		}
		this.arrangeItems(this._currentDecorateContainer);
		this.arrangeItems(this._alreadyBuyedContainer);
	}

	// DecorsPage.as:325-332
	public function refresh(param1:Dictionary<Int, Array<Dynamic>>):Void {
		var _loc2_:Array<DecorateItem> = cast param1.get(0);
		this.initCurrentDivChildCache(_loc2_);
		this.arrangeItems(this._currentDecorateContainer);
		_loc2_ = cast param1.get(1);
		this.refreshBelow(_loc2_);
	}

	// DecorsPage.as:334-392（怪逻辑照抄：_loc7_>0 且 _loc5_>_loc7_ 时可能
	// 双建 DecorHeadRenderItem——_loc5_ 是数组下标、_loc7_ 是子件数，两计数
	// 语义不同却直接比大小，原版如此）
	private function initCurrentDivChildCache(param1:Array<DecorateItem>):Bool {
		var _loc3_:DecorHeadRenderItem = null;
		var _loc4_:DecorateItem = null;
		var _loc6_:Bool = false;
		var _loc7_:Int = 0;
		var _loc8_:Int = 0;
		var _loc9_:DecorHeadRenderItem = null;
		var _loc2_:Bool = false;
		var _loc5_:Int = 0;
		while (_loc5_ < param1.length) {
			_loc4_ = param1[_loc5_];
			if (_loc4_._type != Consts.DECOR_BILLBOARD) {
				_loc6_ = true;
				_loc7_ = this._currentDecorateContainer.numChildren;
				if (_loc7_ > 0) {
					_loc8_ = 0;
					while (_loc8_ < _loc7_) {
						_loc9_ = Std.isOfType(this._currentDecorateContainer.getChildAt(_loc8_), DecorHeadRenderItem) ? cast(this._currentDecorateContainer.getChildAt(_loc8_), DecorHeadRenderItem) : null;
						if (_loc9_ != null) {
							if (cast(_loc9_.data, DecorateItem)._type == _loc4_._type) {
								_loc9_.data = _loc4_;
								_loc6_ = false;
								break;
							}
						}
						_loc8_++;
					}
					if (_loc5_ > _loc7_) {
						_loc3_ = new DecorHeadRenderItem();
						_loc3_.data = _loc4_;
						if (_loc4_._status == 1) {
							this._currentDecorateContainer.addChild(_loc3_);
						}
					}
				}
				if (_loc6_) {
					_loc2_ = true;
					_loc3_ = new DecorHeadRenderItem();
					_loc3_.data = _loc4_;
					if (_loc4_._status == 1) {
						this._currentDecorateContainer.addChild(_loc3_);
					}
				}
			}
			_loc5_++;
		}
		return _loc2_;
	}
}
