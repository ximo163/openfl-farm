package com.qzone.qui.styles;

import openfl.text.TextFormat;

/**
 * com.qzone.qui.styles.Style —— V3b/V3c 模块翻译，闭包 stub（issue #7）。
 * qui 全局样式表（Style.as 315 loc，各类控件的默认 TextFormat/颜色）属于
 * qui 组件库；Main.setup 只碰 5 个颜色静态，这里保这些静态的形态并给
 * 可改的 TextFormat 实例（颜色赋值不丢），样式体系随 qui 片接入。
 */
@:keep
class Style {
	// Style.as 的静态样式色（Main.setup 赋值）
	public static var color:Int = 0;
	public static var disabledColor:Int = 0;
	public static var textSelectedColor:Int = 0;
	public static var textRollOverColor:Int = 0;
	public static var textColor:Int = 0;
	public static var textDisabledColor:Int = 0;

	// 按钮等控件的格式对象（原版是懒建的单例 TextFormat）
	private static var _buttonFormat:TextFormat = null;
	private static var _buttonOverFormat:TextFormat = null;
	private static var _disabledFormat:TextFormat = null;
	private static var _labelFormat:TextFormat = null;

	public static function getButtonFormat():TextFormat {
		if (_buttonFormat == null) {
			_buttonFormat = new TextFormat();
		}
		return _buttonFormat;
	}

	public static function getButtonOverFormat():TextFormat {
		if (_buttonOverFormat == null) {
			_buttonOverFormat = new TextFormat();
		}
		return _buttonOverFormat;
	}

	public static function getDisabledFormat():TextFormat {
		if (_disabledFormat == null) {
			_disabledFormat = new TextFormat();
		}
		return _disabledFormat;
	}

	public static function getLabelFormat():TextFormat {
		if (_labelFormat == null) {
			_labelFormat = new TextFormat();
		}
		return _labelFormat;
	}
}
