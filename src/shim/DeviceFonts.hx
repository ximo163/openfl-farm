package shim;

/**
 * 设备字体兜底——Android 上动态文本 CJK 字形的来源（平台差异胶水）。
 *
 * 原版：动态文本全部用设备字体（qui Style.fontFace=Verdana、飘字 Verdana、
 * RedUpWindow SimSun、embedFontA 嵌入字体、swf 文本符号各自的字体名）。
 * Windows 的 Flash Player 向 OS 字体表解析，浏览器侧还有逐字形回退到系统
 * CJK 字体——汉字从来不是嵌入字体的功劳。
 *
 * openfl：html5 走浏览器 CSS 字体栈照常；Android(cpp) 的文本引擎是
 * **单字体整段渲染、无逐字形回退**（openfl 9.5.2
 * text/_internal/TextEngine.hx getFontInstance）：字体名查不到就落 _serif
 * 默认（Android 即 DroidSerif，无 CJK）→ 汉字全部空白（#10 真机实证）。
 * 嵌入字体 Main_EMBED_FONT_A 又是 stub（原版嵌的 ttf 没有字形来源）。
 *
 * 修法：把系统 CJK 字体注册进 openfl 字体表。只建 **一个** 真 Font——
 * lime 的 native 侧每实例 memcpy 一份字体字节（lime project/src/text/
 * Font.cpp FT_New_Memory_Face），CJK 字体 5-20MB，多实例＝多份拷贝；
 * 别名实例经 lime 自家的 __copyFrom 共享 src（face 句柄）＋openfl 的
 * fontName setter 换名，零新增字节。注册名分两类：
 * - 请求名（TextEngine findFont 按 fontName 扫 __registeredFonts 匹配）：
 *   代码里实际出现的 + 常见 CJK 族名；
 * - 路径名（findFont 同时比对 __fontPath）：挂到 getDefaultFont 请求的
 *   DroidSans/DroidSerif/DroidSansMono 路径串上，使 _sans/_serif/
 *   _typewriter 与一切未列名/null 字体的 _serif 兜底全部命中。
 * 候选文件优先 SC 专版（NotoSansCJK ttc 的 face0 可能是 JP 字形变体，
 * 仅作兜底）。找不到 CJK 字体文件的 ROM 维持现状（汉字空白）不硬造。
 *
 * 已知偏差（deviations.json android-device-cjk-fonts）：英文字形来自 CJK
 * 字体自带 Latin 区，与 Verdana 有差；粗体请求落 regular face（openfl
 * native 不合成粗体）。html5/eval 完全不介入（#if android）。
 */
class DeviceFonts {
	#if android
	private static final ALIAS_NAMES:Array<String> = [
		// src/ 反编译对照能看到的运行时请求名（Style.fontFace、飘字、
		// 窗口、qui 控件、FarmLite 调试框）
		"Verdana", "Times New Roman", "Arial", "SimSun", "Lucida Sans Unicode",
		// swf 文本符号常见的中文族名
		"宋体", "微软雅黑", "Microsoft YaHei",
		// 嵌入字体 stub（Main_EMBED_FONT_A 无字形，这里顶名；findFont 扫
		// __registeredFonts 按注册序，本 shim 在 module.Main.setup 之前）
		"embedFontA"
	];

	// TextEngine.getDefaultFont 在 Android 请求的路径串（fontsDirectory +
	// "/Droid*.ttf"），逐字一致才命中 __fontPath 匹配
	private static final ALIAS_PATHS:Array<String> = [
		"/DroidSans.ttf", "/DroidSerif-Regular.ttf", "/DroidSansMono.ttf"
	];

	private static final CANDIDATE_FILES:Array<String> = [
		"/NotoSansSC-Regular.otf",
		"/DroidSansFallback.ttf",
		"/NotoSansCJK-Regular.ttc",
		"/NotoSansCJKsc-Regular.otf"
	];
	#end

	public static function install():Void {
		#if android
		var fontsDir = lime.system.System.fontsDirectory;
		var real:openfl.text.Font = null;
		for (file in CANDIDATE_FILES) {
			real = openfl.text.Font.fromFile(fontsDir + file);
			if (real != null) {
				break;
			}
		}
		if (real == null) {
			return;
		}
		for (name in ALIAS_NAMES) {
			openfl.text.Font.registerFont(aliasOf(real, name, null));
		}
		for (path in ALIAS_PATHS) {
			openfl.text.Font.registerFont(aliasOf(real, real.fontName, fontsDir + path));
		}
		#end
	}

	#if android
	private static function aliasOf(real:openfl.text.Font, name:String, fontPath:String):openfl.text.Font {
		var alias = new openfl.text.Font(null);
		// lime 自家的字段拷贝：src/度量全数共享（__copyFrom 会把 name 覆盖
		// 成真字体族名，之后用 openfl 的 fontName setter 换回来）
		@:privateAccess alias.__copyFrom(real);
		alias.fontName = name;
		if (fontPath != null) {
			@:privateAccess alias.__fontPath = fontPath;
		}
		return alias;
	}
	#end
}
