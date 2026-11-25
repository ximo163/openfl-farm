package tools;

/**
 * issue #61 cpp typer 全量扫描——临时 hxml 生成（write-tests 阶段为 stub，
 * 契约由 test/tools/CppTyperPlanTest.hx 钉死，implement 原地填充）。
 *
 * 职责：把 `export/html5/haxe/debug.hxml` 的行变换成 cpp typer 扫描 hxml
 * 的行。脚本侧（tools/scan_cpp_typer.sh）负责读 debug.hxml、mktemp 出
 * -cpp 目录、把返回行 join("\n") 写临时 hxml、调 haxe、按判据收尾——本
 * 类只做行集变换：规则命中的行删、末尾追加两行，其余逐字透传（空行、
 * 尾随空格不清洗不重排——golden 两侧 fixture 都带尾换行切出的空行）。
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
	/** debug.hxml 的行（含尾换行切出的空行）→ 扫描 hxml 的行（契约见类头）。 */
	static public function transform(sourceLines:Array<String>, cppOutDir:String):Array<String> {
		throw new haxe.Exception("not implemented");
	}
}
