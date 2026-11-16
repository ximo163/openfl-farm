package;

import openfl.display.Sprite;
import openfl.text.TextField;
import openfl.text.TextFormat;

/**
 * 启动骨架（V0）。垂直切片（V2/V3）会把它替换成预加载器的翻译版：
 * happyfarm3_v_149.swf 的主文档类 → src/ 下对应类。
 */
class Main extends Sprite {
	public function new() {
		super();
		var tf = new TextField();
		tf.defaultTextFormat = new TextFormat(null, 24, 0x000000);
		tf.text = "openfl-farm skeleton";
		tf.width = stage.stageWidth;
		tf.height = 40;
		tf.y = (stage.stageHeight - tf.height) / 2;
		addChild(tf);
		// 冒烟标记：harness/smoke.mjs 等它出现（垂直切片换成预加载器翻译版时保留）
		#if js
		untyped __js__("if (typeof window !== 'undefined') window.__openflFarmReady = true");
		#end
	}
}
