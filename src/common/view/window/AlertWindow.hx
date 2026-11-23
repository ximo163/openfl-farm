package common.view.window;

import com.qzone.corelib.controls.ExtLoader;
import com.qzone.qui.controls.Button;
import common.view.window.BaseWindow;
import openfl.display.Sprite;
import openfl.text.TextField;

/**
 * common.view.window.AlertWindow —— V3b/V3c 模块翻译，闭包 stub（issue #7）。
 * 确认提示窗（AlertWindow.as）；FarmStage 建层时按 Consts 注册进控件表，本片只保类形态
 * （@:keep 防 dce，供 register/Type.resolveClass 拿到类引用），窗体/动效
 * 随对应片接入。
 * issue #41（write-tests）补私有字段表（AlertWindow.as:25-35，签名照原文），
 * setData 分支/文案待本片 implement 真身化。
 */
@:keep
class AlertWindow extends BaseWindow {
	// AlertWindow.as:25
	private var _alertText:TextField;

	// AlertWindow.as:27（Function → Dynamic）
	private var _textLinkHandle:Dynamic;

	// AlertWindow.as:29
	private var _confirmButton:Button;

	// AlertWindow.as:31
	private var _icon:Sprite;

	// AlertWindow.as:33（Function → Dynamic）
	private var _confirmButtonClickHandle:Dynamic;

	// AlertWindow.as:35
	private var _picLoader:ExtLoader;

	public function new(param1:interfaces.IMsgCenter = null) {
		super(param1);
	}
}
