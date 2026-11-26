package mx.core;

import mx.utils.NameUtil;
import openfl.display.MovieClip;

// mx.core.FlexMovieClip —— FlexMovieClip.as 逐句对应（issue #86 牧场库底座，
// Flex 资产壳片）。MovieClip 子类：构造时经 NameUtil 起唯一名，toString 走
// displayObjectToString。
// 原版 VERSION 带 mx_internal namespace 修饰（包内可见），平铺成 public。
@:keep
class FlexMovieClip extends MovieClip {
	// FlexMovieClip.as:11（mx_internal static const）
	public static final VERSION:String = "3.2.0.3958";

	// FlexMovieClip.as:13-23
	public function new() {
		super();
		try {
			this.name = NameUtil.createUniqueName(this);
		} catch (e:Dynamic) {}
	}

	// FlexMovieClip.as:25-28
	public override function toString():String {
		return NameUtil.displayObjectToString(this);
	}
}
