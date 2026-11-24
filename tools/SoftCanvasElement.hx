package;

import SoftCanvasContext;

/**
 * canvas 元素（createElement("canvas") 的产物）。width/height 赋值带复位
 * 语义（canvas 规范：改尺寸清空内容）——openfl 的 ImageCanvasUtil 靠它在
 * 等尺寸 clearRect、变尺寸赋值两条路间切换。真值存在 ctx（避免 defineProperty
 * getter 递归）；用 defineProperty 而非 Haxe 属性，因为外部赋值来自 extern
 * 类型（CanvasElement）编译出的裸赋值。
 */
@:keep
class SoftCanvasElement {
	@:allow(SoftCanvasContext)
	private var ctx:SoftCanvasContext;

	/** DOM 分支偶有 canvas.style.width=… 赋值；收下但不消费。 */
	public var style:Dynamic;

	public function new() {
		style = {};
		ctx = new SoftCanvasContext(this, false);
		ctx.resize(300, 150); // 规范默认尺寸
		#if js
		js.Syntax.code(
			"(function(self){{
				function define(name, get, set) {{
					Object.defineProperty(self, name, {{get: get, set: set, configurable: true}});
				}}
				define('width', function() {{ return self.ctx.width; }}, function(v) {{ self.ctx.resize(v|0, self.ctx.height); }});
				define('height', function() {{ return self.ctx.height; }}, function(v) {{ self.ctx.resize(self.ctx.width, v|0); }});
			}})({0})", this);
		#end
	}

	/** getContext 幂等返回同一实例（真 canvas 如此；lime 缓存它）。 */
	public function getContext(type:String, ?attributes:Dynamic):SoftCanvasContext {
		if (type == null || StringTools.trim(type).indexOf("2d") != 0) return null;
		if (attributes != null && Reflect.hasField(attributes, "alpha") && attributes.alpha == false) {
			// {alpha: false}：非透明画布，规范起始为不透明黑
			ctx.setOpaque(true);
		}
		return ctx;
	}

	public function addEventListener(type:String, listener:Dynamic, ?useCapture:Bool):Void {}
	public function removeEventListener(type:String, listener:Dynamic, ?useCapture:Bool):Void {}
	public function setAttribute(name:String, value:String):Void {}
	public function toDataURL(?type:String):String {
		return "";
	}
}

/** 渐变几何 + 色标（createLinear/RadialGradient 的产物）。canvas 无 spread
 * 模式：t 超出 [0,1] 两端延展 = PAD（openfl 的 REPEAT/REFLECT 靠它自己的
 * 25 色标技巧模拟，本类只按规范内插）。 */
