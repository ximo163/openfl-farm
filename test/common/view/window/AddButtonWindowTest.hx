package common.view.window;

import common.Consts;
import common.view.window.AddButtonWindow;
import openfl.display.Shape;
import openfl.display.Sprite;
import utest.Assert;

/**
 * AddButtonWindow 纯逻辑（issue #41）：构造器常量、按钮/子件缓存 API 的
 * 语义（addButton/addSpecialButton 进 buttonCache、addWindowChild 进
 * addChildCache、removeAll* 清空）、间距默认值与访问器。
 *
 * 出处：legacy/decompiled/main3_v_221/scripts/common/view/window/
 * AddButtonWindow.as（ctor :20-27：width=360/height=240/mode=true/
 * windowName=WINDOW_NAME_ABUTTON；字段默认 _buttonSpace=10 :16、
 * _bottomSpace=40 :18；betweenSpace :29-32、bottomSpace :34-37、
 * addSpecialButton :39-43、addWindowChild :45-49、removeAllButton :51-54、
 * addButton :56-61（new winButton + 入 buttonCache + 返回实例，winButton
 * ctor :126-150：text=param1、enabled=param6、width=param3）；removeAll
 * WindowChild :63-66）。
 *
 * addButton 的 winButton 是内部类（:121-176），实现后按原文建 Button 子类；
 * 此处只验纯语义：非空、文案/尺寸/可用态、缓存归属与累计。init 的排布
 * 循环在本部署因 addButton 缺位是原版死代码（类头注释），不测。
 */
@:access(common.view.window.AddButtonWindow)
class AddButtonWindowTest {
	public function new() {}

	// :20-27：构造器常量
	public function test_ctor_constants() {
		var win = new AddButtonWindow(null);
		Assert.equals(360, win.width);
		Assert.equals(240, win.height);
		Assert.isTrue(win.mode);
		Assert.equals(Consts.WINDOW_NAME_ABUTTON, win.windowName);
	}

	// :16/:18 默认 + :29-37 访问器直写
	public function test_space_defaults_and_setters() {
		var win = new AddButtonWindow(null);
		Assert.equals(10, win._buttonSpace);
		Assert.equals(40, win._bottomSpace);
		win.betweenSpace = 25;
		Assert.equals(25, win._buttonSpace);
		win.bottomSpace = 55;
		Assert.equals(55, win._bottomSpace);
	}

	// :56-61 + winButton :126-150：addButton 建钮入缓存，参数落到钮上
	public function test_addButton_creates_button_into_cache() {
		var win = new AddButtonWindow(null);
		var click = function(e) {};
		var btn = win.addButton("确 定", "ButtonOrange", 80, 25, click);
		Assert.notNull(btn); // addButton 返回所建 winButton 实例
		Assert.equals("确 定", btn.text); // winButton :133
		Assert.equals(80, Std.int(btn.width)); // :139
		Assert.equals(25, Std.int(btn.height)); // :140
		Assert.isTrue(btn.enabled); // :138 param6 默认 true
		Assert.equals(1, win.buttonCache.length);
		Assert.equals(btn, win.buttonCache[0]); // :59
		// 多次 addButton 累计（排布循环消费的输入）
		var btn2 = win.addButton("取 消", "ButtonBlue");
		Assert.equals(2, win.buttonCache.length);
		Assert.equals(btn2, win.buttonCache[1]);
		// 清空后再加从零计（:51-54）
		win.removeAllButton();
		Assert.equals(0, win.buttonCache.length);
	}

	// :39-49 + :63-66：特殊按钮/窗体子件的缓存语义与清空
	public function test_special_button_and_window_child_caches() {
		var win = new AddButtonWindow(null);
		var sprite = new Sprite();
		Assert.equals(sprite, win.addSpecialButton(sprite)); // :42 返回原对象
		Assert.isTrue(win.buttonCache.indexOf(sprite) != -1);
		var shape = new Shape();
		Assert.equals(shape, win.addWindowChild(shape)); // :48
		Assert.isTrue(win.addChildCache.indexOf(shape) != -1);
		win.removeAllWindowChild(); // :65
		Assert.equals(0, win.addChildCache.length);
		Assert.equals(1, win.buttonCache.length); // 各清各的
	}
}
