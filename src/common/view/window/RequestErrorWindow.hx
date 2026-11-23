package common.view.window;

import com.qzone.qui.controls.Button;
import common.view.window.BaseWindow;
import openfl.display.Bitmap;
import openfl.text.TextField;

/**
 * common.view.window.RequestErrorWindow —— V3b/V3c 模块翻译，闭包 stub（issue #7）。
 * 请求错误窗（RequestErrorWindow.as）；FarmStage 建层时按 Consts 注册进控件表，本片只保类形态
 * （@:keep 防 dce，供 register/Type.resolveClass 拿到类引用），窗体/动效
 * 随对应片接入。
 * issue #41（write-tests）补私有字段表与 errorUrl 签名（RequestErrorWindow.as:25-46
 * 、:137-236），五路限流文案分岔待本片 implement 真身化。
 */
@:keep
class RequestErrorWindow extends BaseWindow {
	// RequestErrorWindow.as:25
	private var m_info:String;

	// RequestErrorWindow.as:27
	private var m_okButton:Button;

	// RequestErrorWindow.as:29
	private var m_img:Bitmap;

	// RequestErrorWindow.as:31
	private var m_lbInfo:TextField;

	// RequestErrorWindow.as:33
	private var m_imgName:String;

	public function new(param1:interfaces.IMsgCenter = null) {
		super(param1);
	}

	// RequestErrorWindow.as:137-236（errorUrl：按 url 关键词 + RequestChecker
	// 限流记录拼 m_info 文案，待本片 implement）
	private function set_errorUrl(param1:String):String {
		throw new openfl.errors.Error("not implemented");
	}

	public var errorUrl(never, set):String;
}
