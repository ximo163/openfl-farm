package;

import SoftCanvasElement;
import SoftDOMMatrix;
import SoftPath2D;

/** 安装入口（子系统总说明见 SoftCanvasContext.hx 类头）。 */
class SoftCanvas {
	@:keep
	public static function createCanvasElement():SoftCanvasElement {
		return new SoftCanvasElement();
	}

	#if js
	public static function installNode():Void {
		js.Syntax.code(
			"(function() {{
				if (globalThis.__softCanvasInstalled) return;
				globalThis.__softCanvasInstalled = true;
				var orig = document.createElement.bind(document);
				document.createElement = function(tag) {{
					if (String(tag).toLowerCase() === 'canvas') return {0}();
					return orig(tag);
				}};
				globalThis.Path2D = {1};
				globalThis.DOMMatrix = {2};
				// lime 的 ImageBuffer.set_src 用 instanceof HTMLCanvasElement 分流
				// （裸标识符，node 里没有这个全局）：本类就是我们的 canvas 元素类，
				// 注册后 instanceof 成立，src=canvas 的路径（CanvasGraphics 缓存画布
				// → BitmapData.fromCanvas）不再 ReferenceError。
				globalThis.HTMLCanvasElement = {0};
			}})()", createCanvasElement, SoftPath2D, SoftDOMMatrix);
	}
	#end
}
