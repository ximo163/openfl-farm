package module;

import openfl.text.Font;

/**
 * module.Main_EMBED_FONT_A —— Main_EMBED_FONT_A.as 对应。
 * 原版是 [Embed] 进 main3 的 ttf 字体资产（fontName="embedFontA"、
 * fontFamily="MC_Font"、mx.core.FontAsset），Main.setup 里
 * Font.registerFont(EMBED_FONT_A) 挂进字体表。
 *
 * PORT-NOTE: 嵌入源 /_assets/1_module.Main_EMBED_FONT_A_embedFontA.ttf 只存在于
 * swf 的 DefineFont 标签里，容器没有 FFDec 无法重导出 ttf（CLAUDE.md 环境边界）；
 * 字体资产的接入（assets/legacy-assets.txt + libraries.xml 同 commit 声明）留待
 * 文本渲染的 V3b/V3c 片。这里保持类形态（Font 子类）让 registerFont 的调用点
 * 照原样编译，不注册任何字形。
 */
@:keep
class Main_EMBED_FONT_A extends Font {
	public function new() {
		super();
	}
}
