package common.view.window;

import com.qzone.qui.controls.Label;
import com.qzone.qui.styles.Style;
import com.qzone.qui.utils.TextFormatUtil;
import com.qzone.utils.GraphicsUtil;
import openfl.geom.Rectangle;
import openfl.text.TextFormat;

/**
 * common.view.window.WindowLabelMaker —— WindowLabelMaker.as 逐句对应
 * （issue #18 qui 收尾：通用窗口片）。窗口分节标题装配器：懒建居中格式
 * （0xBFDDD6），给 Label 画底色块（0xFFFFF8）与下沿横线（0xEEEEEE）。
 */
@:keep
class WindowLabelMaker {
	// WindowLabelMaker.as:13（首用前为 null：addTarget 里懒建）
	public static var labelFormat:TextFormat;

	// :15-18
	public function new() {
		super();
	}

	// :20-35
	public static function addTarget(param1:Label):Void {
		if (param1 == null) {
			return;
		}
		if (labelFormat == null) {
			labelFormat = TextFormatUtil.clone(Style.getLabelFormat());
			labelFormat.color = 12547910;
			labelFormat.align = "center";
		}
		param1.textDefaultFormat = labelFormat;
		GraphicsUtil.draw(param1, 16777176, 1, null, true);
		GraphicsUtil.hLine(param1, 15590344, 1, new Rectangle(0, param1.height, param1.width));
	}
}
