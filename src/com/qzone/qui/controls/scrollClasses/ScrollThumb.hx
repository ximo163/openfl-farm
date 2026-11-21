package com.qzone.qui.controls.scrollClasses;

import com.qzone.qui.core.Direction;
import com.qzone.qui.makers.ButtonMaker;
import com.qzone.qui.styles.Style;
import com.qzone.utils.AlignUtil;
import openfl.display.Sprite;
import shim.As3;

/**
 * com.qzone.qui.controls.scrollClasses.ScrollThumb —— ScrollThumb.as 逐句
 * 对应（issue #18 qui 收尾：控件片）。滚动条滑块：按方向把 length/position
 * 属性名参数化（height/y ↔ width/x），滑块与图标两符号。
 * PORT-NOTE: `this.thumb[this.lenProp] = param1` 这类按名读写 Sprite 属性，
 * js 上裸 `dyn.prop = v` 只写影子字段（typed 读回 0），必须走
 * Reflect.setProperty/getProperty 才分发到 openfl setter。
 */
class ScrollThumb extends Sprite {
	// ScrollThumb.as:11-24
	private var _direction:String;

	private var pos2Prop:String;

	private var len2Prop:String;

	private var thumbIconSkin:Class<Dynamic>;

	private var thumbIcon:Sprite;

	private var lenProp:String;

	private var thumbSkin:Class<Dynamic>;

	private var thumb:Sprite;

	private var posProp:String;

	private var _scrollBar:ScrollBar;

	// :26-45
	public function new(param1:ScrollBar, param2:Class<Dynamic>, param3:Class<Dynamic>, param4:String) {
		super();
		if (param4 == Direction.VERTICAL) {
			this.lenProp = "height";
			this.posProp = "y";
			this.len2Prop = "width";
			this.pos2Prop = "x";
		} else if (param4 == Direction.HORIZONTAL) {
			this.lenProp = "width";
			this.posProp = "x";
			this.len2Prop = "height";
			this.pos2Prop = "y";
		}
		this._scrollBar = param1;
		this.thumbSkin = param2;
		this.thumbIconSkin = param3;
	}

	// :47-58
	private function setSkin():Void {
		this.thumb = Type.createInstance(this.thumbSkin, []);
		ButtonMaker.addTarget(this.thumb);
		this.thumb.useHandCursor = false;
		this.thumb.tabEnabled = false;
		this.addChild(this.thumb);
		this.thumbIcon = Type.createInstance(this.thumbIconSkin, []);
		this.thumbIcon.mouseEnabled = false;
		this.addChild(this.thumbIcon);
	}

	// :60-77
	public function setThumbSize(param1:Int):Void {
		if (this.thumb == null) {
			this.setSkin();
		}
		if (param1 >= Style.ScrollBarMinSize) {
			Reflect.setProperty(this.thumb, this.lenProp, param1);
			this.thumb.visible = true;
			if (param1 <= Style.ScrollBarMinIconSize) {
				this.thumbIcon.visible = false;
			} else {
				Reflect.setProperty(this.thumbIcon, this.posProp,
					Reflect.getProperty(this.thumb, this.posProp)
					+ Math.floor(AlignUtil.middle(Reflect.getProperty(this.thumb, this.lenProp),
						Reflect.getProperty(this.thumbIcon, this.lenProp))));
				Reflect.setProperty(this.thumbIcon, this.pos2Prop,
					Math.floor(AlignUtil.middle(Reflect.getProperty(this.thumb, this.len2Prop),
						Reflect.getProperty(this.thumbIcon, this.len2Prop))));
				this.thumbIcon.visible = true;
			}
		}
	}
}
