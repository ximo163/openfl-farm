package tools;

/**
 * issue #61 cpp typer 全量扫描——临时 hxml 生成（契约由
 * test/tools/CppTyperPlanTest.hx 钉死）。
 *
 * 职责：把 `export/html5/haxe/debug.hxml` 的行变换成 cpp typer 扫描 hxml
 * 的行。脚本侧（tools/scan_cpp_typer.sh）负责读 debug.hxml、mktemp 出
 * -cpp 目录、把返回行 join("\n") 写临时 hxml、调 haxe、按判据收尾——本
 * 类只做行集变换：规则命中的行删、末尾追加两行，其余逐字透传（中间的
 * 空行也是合法行文本，透传不清洗；输入输出都是「行文本数组」，文件尾
 * 换行的切分/补写归脚本侧——读时 split 后 pop 尾空行再喂进来）。
 *
 * recipe 出处（固化时别偏离，脚本头注同钉）：
 * - lessons #18：起点 debug.hxml 的 classpath 与**前三个** `--macro`
 *   （ExtraParams/DefineMacro/AssetsMacro——超出三个的 --macro 行去掉）；
 *   include 的 classPaths 必须限 `['src']`（不限会把 swf 库 classpath 根
 *   的 SWFTimelineContainer 扫进来报无关错）；4.3.6 实际签名
 *   include(pack, rec, ignore, classPaths, strict)。
 * - lessons #29：exclude 表（ignore 参数）用全限定名 `'mx.core.mx_internal'`
 *   （传 'mx_internal' 照红，实测形状见 test/fixtures/cpp-typer-exclude-
 *   error-output.txt）；`-D no-compilation` 必去——留着则 0 错 0 输出退出
 *   0，「只剩 hxcpp 未装」的判据尾巴不会出现。
 * - html5 专属 -D 的「等」（#18 原文带「等」）：issue #61 点名 lime-webgl/
 *   lime-dom/howlerjs/lime-html5/no-compilation；2026-11-25 容器实测补齐
 *   html5/web/openfl-html5/lime-howlerjs/lime-canvas——留任一都会把 js 包
 *   import 拉进 cpp 目标（lime/system/WorkOutput.hx:17 `#if html5` 拉
 *   HTML5Thread → `import js.Browser`；lime-canvas 拉
 *   Canvas2DRenderContext → `js.html.*`），报 "You cannot access the js
 *   package while targeting cpp"（实测形状见 test/fixtures/cpp-typer-
 *   config-error-output.txt，形似代码错实为配置错）。
 *
 * 规则（对行首参数精确匹配；-D 的匹配取 `=` 前的 define 名）：
 * 1. 删 `-main ...` 行——recipe 去的是 `-main ApplicationMain`，规则按
 *    「入口行一律去」落（include 才是扫描的入口，不该再有别的入口）。
 * 2. 删后端输出行 `-js ...`（recipe「换 -cpp」的换边：输出旗标换成 -cpp）。
 * 3. 删 html5 专属 -D 行：html5、web、openfl-html5、lime-html5、
 *    lime-webgl、lime-dom、lime-canvas、lime-howlerjs、howlerjs、
 *    no-compilation。
 * 4. 删第 4 个及以后的 `--macro` 行。
 * 5. 末尾按序追加 `-cpp <cppOutDir>` 与 `--macro include('', true,
 *    ['mx.core.mx_internal'], ['src'])`（-cpp 先、include 后，顺序固定）。
 * 其余一切逐字保留：-cp 全部（含 `export/html5/haxe` 的生成位——include
 * 限 ['src'] 不会把它扫进来）、-D openfl/lime/swf/tools 版本号、
 * lime-threads、disable_preloader_assets、`--remap flash:openfl`、-debug。
 */
class CppTyperPlan {
	/** issue #61 点名的 5 个 + #18「等」实测补齐的 5 个（出处见类头）。 */
	static final HTML5_ONLY_DEFINES:Array<String> = [
		"html5", "web", "openfl-html5", "lime-html5", "lime-webgl",
		"lime-dom", "lime-canvas", "lime-howlerjs", "howlerjs", "no-compilation",
	];

	/** 保留的 --macro 上限（recipe「前三个 bootstrap」）。 */
	static final BOOTSTRAP_MACROS:Int = 3;

	/** debug.hxml 的行（含尾换行切出的空行）→ 扫描 hxml 的行（契约见类头）。 */
	static public function transform(sourceLines:Array<String>, cppOutDir:String):Array<String> {
		var out:Array<String> = [];
		var macroCount = 0;
		for (line in sourceLines) {
			var token = argToken(line);
			// 规则 1/2：入口行、-js 后端输出行（输出旗标换成 -cpp）
			if (token == "-main" || token == "-js") continue;
			// 规则 3：html5 专属 -D（名字匹配取 = 前）
			if (token == "-D" && HTML5_ONLY_DEFINES.indexOf(defineName(line)) >= 0) continue;
			// 规则 4：第 4 个及以后的 --macro（bootstrap 只留前三个）
			if (token == "--macro") {
				macroCount++;
				if (macroCount > BOOTSTRAP_MACROS) continue;
			}
			out.push(line);
		}
		// 规则 5：追加行固定在末尾，-cpp 先、include 后
		out.push("-cpp " + cppOutDir);
		out.push("--macro include('', true, ['mx.core.mx_internal'], ['src'])");
		return out;
	}

	/** 行首参数（到首个空白为止）：「精确匹配」按它判，不吃前缀。 */
	static function argToken(line:String):String {
		var cut = line.length;
		for (i in 0...line.length) {
			var c = line.charCodeAt(i);
			if (c == " ".code || c == "\t".code) {
				cut = i;
				break;
			}
		}
		return line.substr(0, cut);
	}

	/** `-D name[=value]` 的 name：= 前的一段（`-D html5=1` 与 `-D html5` 同名）。 */
	static function defineName(line:String):String {
		var rest = StringTools.ltrim(line.substr(2));
		var end = rest.length;
		for (i in 0...rest.length) {
			var c = rest.charCodeAt(i);
			if (c == "=".code || c == " ".code || c == "\t".code) {
				end = i;
				break;
			}
		}
		return rest.substr(0, end);
	}
}
