package com.qzone.qui.styles;

import openfl.filters.ColorMatrixFilter;
import openfl.filters.DropShadowFilter;
import openfl.filters.GlowFilter;
import openfl.geom.Point;
import openfl.text.TextFormat;

/**
 * com.qzone.qui.styles.Style —— Style.as 逐句对应（issue #9 qui 子集片）。
 * qui 全局样式表：静态常量 + 懒建单例 TextFormat/滤镜。issue #7 的闭包 stub
 * 只有 Main.setup 碰的几个入口，本片全量照抄（值逐字一致）。
 * PORT-NOTE: 原 stub 曾带 textSelectedColor 等 5 个非原版静态（无引用），
 * 全量翻译时移除。
 */
@:keep
class Style {
	// Style.as:12-46（懒建单例的存储）
	private static var alertTextFormat:TextFormat;
	private static var numericStepperFormat:TextFormat;
	private static var buttonSelectedFormat:TextFormat;
	private static var buttonTextFormat:TextFormat;
	private static var rollOutFilter:Array<Dynamic>;
	private static var textGlowFilter:Array<Dynamic>;
	private static var disableFilter:Array<Dynamic>;
	private static var textTextFormat:TextFormat;
	private static var disabledFormat:TextFormat;
	private static var labelTextFormat:TextFormat;
	private static var shadowFilter:Array<Dynamic>;
	private static var comboBoxFormat:TextFormat;
	private static var buttonOverFormat:TextFormat;
	private static var toolTipTextFormat:TextFormat;
	private static var progressBarTextFormat:TextFormat;
	private static var rollOverFilter:Array<Dynamic>;
	private static var hitFilter:Array<Dynamic>;
	private static var textInputFormat:TextFormat;

	// Style.as:48-144
	public static var toolTipPaddingH:Int = 2;
	public static var toolTipPaddingV:Int = 1;
	public static var toolTipOffset:Point = new Point(0, -5);
	public static var textInputPaddingH:Int = 1;
	public static var textInputPaddingV:Int = 1;
	public static var checkBoxPaddingH:Int = 3;
	public static var radioButtonPaddingH:Int = 3;
	public static var boxPaddingH:Int = 10;
	public static var boxPaddingV:Int = 10;
	public static var boxGapH:Int = 8;
	public static var boxGapV:Int = 6;
	public static var panelPaddingH:Int = 5;
	public static var panelPaddingV:Int = 5;
	public static var panelHeadHeight:Int = 22;
	public static var panelControlBarHeight:Int = 28;
	public static var listPaddingH:Int = 0;
	public static var listPaddingV:Int = 0;
	public static var listBorderSizeH:Int = 1;
	public static var listBorderSizeV:Int = 1;
	public static var canvasBorderSizeH:Int = 1;
	public static var canvasBorderSizeV:Int = 1;
	public static var labelPaddingH:Int = 0;
	public static var buttonPaddingH:Int = 4;
	public static var comboBoxArrowPaddingH:Int = 7;
	public static var comboBoxArrowWidth:Int = 22;
	public static var numericStepperArrowWidth:Int = 18;
	public static var alertPaddingH:Int = 5;
	public static var alertPaddingV:Int = 10;
	public static var popUpModalColor:UInt = 16777215;
	public static var popUpModalAlpha:Float = 0.15;
	public static var vScrollBarWidth:Int = 15;
	public static var hScrollBarHeight:Int = 15;
	public static var ScrollBarMinSize:Int = 8;
	public static var ScrollBarMinIconSize:Int = 12;
	public static var containerBackgroundColor:UInt = 16777215;
	public static var containerBackgroundAlpha:Float = 1;
	public static var boxBackgroundColor:UInt = containerBackgroundColor;
	public static var boxBackgroundAlpha:Float = 0;
	public static var canvasBackgroundColor:UInt = containerBackgroundColor;
	public static var canvasBackgroundAlpha:Float = 0;
	public static var fontSize:Int = 12;
	public static var fontFace:String = "Verdana";
	public static var color:Int = 6389917;
	public static var rollOverColor:Int = 7187687;
	public static var selectedColor:Int = 6389917;
	public static var disabledColor:Int = 12632256;
	public static var toolTipColor:Int = 0;
	public static var sliderTickSize:Int = 2;
	public static var sliderTickColor:UInt = 12632256;

	// Style.as:146-149
	public function new() {}

	// Style.as:151-158
	public static function getToolTipFormat():TextFormat {
		if (toolTipTextFormat == null) {
			toolTipTextFormat = new TextFormat(Style.fontFace, Style.fontSize, Style.toolTipColor);
		}
		return toolTipTextFormat;
	}

	// Style.as:160-167
	public static function getShadowFilter():Array<Dynamic> {
		if (shadowFilter == null) {
			shadowFilter = [new DropShadowFilter(5, 45, 0, 0.6, 5, 5)];
		}
		return shadowFilter;
	}

	// Style.as:169-176
	public static function getButtonOverFormat():TextFormat {
		if (buttonOverFormat == null) {
			buttonOverFormat = new TextFormat(Style.fontFace, Style.fontSize, Style.rollOverColor, null, null, null,
				null, null, "center");
		}
		return buttonOverFormat;
	}

	// Style.as:178-185
	public static function getHitFilter():Array<Dynamic> {
		if (hitFilter == null) {
			hitFilter = [new ColorMatrixFilter([1, 0, 0, 0, -5, 0, 1, 0, 0, -5, 0, 0, 1, 0, -5, 0, 0, 0, 1, 0])];
		}
		return hitFilter;
	}

	// Style.as:187-194
	public static function getAlertFormat():TextFormat {
		if (alertTextFormat == null) {
			alertTextFormat = new TextFormat(Style.fontFace, Style.fontSize, Style.color, null, null, null, null, null,
				"center");
		}
		return alertTextFormat;
	}

	// Style.as:196-203
	public static function getButtonFormat():TextFormat {
		if (buttonTextFormat == null) {
			buttonTextFormat = new TextFormat(Style.fontFace, Style.fontSize, Style.color, false, null, null, null,
				null, "center");
		}
		return buttonTextFormat;
	}

	// Style.as:205-212
	public static function getDisabledFormat():TextFormat {
		if (disabledFormat == null) {
			disabledFormat = new TextFormat(Style.fontFace, Style.fontSize, Style.disabledColor);
		}
		return disabledFormat;
	}

	// Style.as:214-221
	public static function getTextFormat():TextFormat {
		if (textTextFormat == null) {
			textTextFormat = new TextFormat(Style.fontFace, Style.fontSize, Style.color, null, null, null, null, null,
				"left");
		}
		return textTextFormat;
	}

	// Style.as:223-230
	public static function getTextGlowFilter():Array<Dynamic> {
		if (textGlowFilter == null) {
			textGlowFilter = [new GlowFilter(16777215, 1, 3, 3, 7)];
		}
		return textGlowFilter;
	}

	// Style.as:232-241
	public static function getComboBoxFormat():TextFormat {
		if (comboBoxFormat == null) {
			comboBoxFormat = new TextFormat(Style.fontFace, Style.fontSize, Style.color, null, null, null, null, null,
				"left");
			comboBoxFormat.indent = 4;
		}
		return comboBoxFormat;
	}

	// Style.as:243-249
	public static function getNumericStepperFormat():TextFormat {
		if (numericStepperFormat == null) {
			numericStepperFormat = new TextFormat(Style.fontFace, Style.fontSize, Style.color, null, null, null, null,
				null, "left");
		}
		return numericStepperFormat;
	}

	// Style.as:251-258
	public static function getRollOverFilter():Array<Dynamic> {
		if (rollOverFilter == null) {
			rollOverFilter = [new ColorMatrixFilter([1, 0, 0, 0, 15, 0, 1, 0, 0, 15, 0, 0, 1, 0, 15, 0, 0, 0, 1, 0])];
		}
		return rollOverFilter;
	}

	// Style.as:260-267
	public static function getProgressBarFormat():TextFormat {
		if (progressBarTextFormat == null) {
			progressBarTextFormat = new TextFormat(Style.fontFace, Style.fontSize, Style.color, null, null, null, null,
				null, "center");
		}
		return progressBarTextFormat;
	}

	// Style.as:269-276
	public static function getButtonSelectedFormat():TextFormat {
		if (buttonSelectedFormat == null) {
			buttonSelectedFormat = new TextFormat(Style.fontFace, Style.fontSize, Style.selectedColor, false, null,
				null, null, null, "center");
		}
		return buttonSelectedFormat;
	}

	// Style.as:278-285
	public static function getTextInputFormat():TextFormat {
		if (textInputFormat == null) {
			textInputFormat = new TextFormat(Style.fontFace, Style.fontSize, Style.color, null, null, null, null, null,
				"left");
		}
		return textInputFormat;
	}

	// Style.as:287-294
	public static function getRollOutFilter():Array<Dynamic> {
		if (rollOutFilter == null) {
			rollOutFilter = [];
		}
		return rollOutFilter;
	}

	// Style.as:296-303
	public static function getLabelFormat():TextFormat {
		if (labelTextFormat == null) {
			labelTextFormat = new TextFormat(Style.fontFace, Style.fontSize, Style.color, null, null, null, null, null,
				"left");
		}
		return labelTextFormat;
	}

	// Style.as:305-312
	public static function getDisableFilter():Array<Dynamic> {
		if (disableFilter == null) {
			disableFilter = [new ColorMatrixFilter([0.3, 0.6, 0.082, 0, 0, 0.3, 0.6, 0.082, 0, 0, 0.3, 0.6, 0.082, 0,
				0, 0, 0, 0, 1, 0])];
		}
		return disableFilter;
	}
}
