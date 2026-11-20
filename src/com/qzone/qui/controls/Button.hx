package com.qzone.qui.controls;

/**
 * com.qzone.qui.controls.Button —— 签名 stub（issue #9 qui 子集片重定基：
 * 原版 extends Label，Label 本片已全量翻译，stub 从 Sprite 垫底改为继承
 * 真基类）。Button.as 202 loc > 100 且不在本片清单，点按/换肤状态机随后续
 * 模块翻译；本片 LevelAndExperience 只触碰 ctor + defaultSkin/text/
 * width/height/x/y，defaultSkin 字段照原版声明保留（ctor 里的
 * ButtonDefaultSkin 装配随皮肤片接入）。
 * legacy/decompiled/main3_v_221/scripts/com/qzone/qui/controls/Button.as
 */
@:keep
class Button extends Label {
	// Button.as:27（LevelAndExperience 置换 ButtonOrange 用）
	public var defaultSkin:Class<Dynamic>;

	// Button.as:33-46（ctor 签名；super(param1,param2) 链照原版，
	// Function → Dynamic；皮肤/格式装配随 qui 组件片）
	public function new(param1:String = "Button", param2:Dynamic = null) {
		super(param1, param2);
	}
}
