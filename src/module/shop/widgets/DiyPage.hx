package module.shop.widgets;

import com.qzone.qui.controls.Label;
import com.qzone.qui.controls.scrollClasses.ScrollPolicy;
import common.Language;
import common.view.window.WindowLabelMaker;
import framework.base.BasePage;
import openfl.display.DisplayObjectContainer;
import openfl.display.Sprite;
import openfl.text.TextField;
import openfl.text.TextFormat;

/**
 * module.shop.widgets.DiyPage —— DiyPage.as 逐句对应（issue #35 功能 swf
 * 翻译：商店）。装饰页：顶部说明 + 背景/房子/狗窝/栅栏四栏标题（x 次序
 * 照抄：狗窝 346 在栅栏 235 之前声明）+ 分隔线；瓦片 105x120、paddingH 30。
 */
class DiyPage extends BasePage {
	// DiyPage.as:11
	private var _top:Int = 22;

	// DiyPage.as:13-18
	public function new(param1:DisplayObjectContainer, param2:Int, param3:Int) {
		super(param1, param2, param3);
		this.addText();
	}

	// DiyPage.as:20-28
	private function addline():Sprite {
		var _loc1_:Sprite = new Sprite();
		_loc1_.graphics.beginFill(16777215, 1);
		_loc1_.graphics.drawRect(0, 0, this.width - 4, 1);
		_loc1_.graphics.endFill();
		addChild(_loc1_);
		return _loc1_;
	}

	// DiyPage.as:30-56
	private function initTitle():Void {
		var _loc1_:TextField = null;
		var _loc3_:TextField = null;
		_loc1_ = this.addChildTitle(Reflect.field(Language.L, "背景"));
		_loc1_.selectable = false;
		_loc1_.x = 5;
		_loc1_.y = this._top;
		var _loc2_:TextField = this.addChildTitle(Reflect.field(Language.L, "房子"));
		_loc2_.selectable = false;
		_loc2_.x = 115;
		_loc2_.y = this._top;
		_loc3_ = this.addChildTitle(Reflect.field(Language.L, "狗窝"));
		_loc3_.selectable = false;
		_loc3_.x = 346;
		_loc3_.y = this._top;
		var _loc4_:TextField = this.addChildTitle(Reflect.field(Language.L, "栅栏"));
		_loc4_.selectable = false;
		_loc4_.x = 235;
		_loc4_.y = this._top;
		var _loc5_:Sprite = this.addline();
		_loc5_.x = 2;
		_loc5_.y = this._top + 20;
	}

	// DiyPage.as:58-72
	override private function onCreateTile():Void {
		if (this._tile != null) {
			this._tile.tileWidth = 105;
			this._tile.tileHeight = 120;
			this._tile.paddingH = 30;
			this._tile.itemRenderer = DiyItem;
			this._tile.y = this._top + 21;
			this._tile.height = 285;
			this._tile.width = 495;
			this._tile.defaultSkin = null;
			this._tile.horizontalScrollPolicy = ScrollPolicy.OFF;
		}
	}

	// DiyPage.as:74-82
	private function addChildTitle(param1:String):TextField {
		var _loc2_:TextField = new TextField();
		_loc2_.text = param1;
		_loc2_.setTextFormat(new TextFormat("Verdana", 14, 3355443, null, null, null, null, null, "center"));
		_loc2_.width = 100;
		_loc2_.height = 25;
		addChild(_loc2_);
		return _loc2_;
	}

	// DiyPage.as:84-93
	private function addText():Void {
		var _loc1_:Label = new Label(Reflect.field(Language.L, "diyTileDirection"));
		_loc1_.width = 500 - 4;
		_loc1_.x = 1;
		WindowLabelMaker.addTarget(_loc1_);
		addChild(_loc1_);
		this.initTitle();
	}
}
