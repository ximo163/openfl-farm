package common.view.window;

import com.qzone.qui.controls.Button;
import common.view.window.BaseWindow;
/**
 * common.view.window.AddButtonWindow —— V3b/V3c 模块翻译，闭包 stub（issue #7）。
 * 带附加按钮的提示窗（AddButtonWindow.as）；FarmStage 建层时按 Consts 注册进控件表，本片只保类形态
 * （@:keep 防 dce，供 register/Type.resolveClass 拿到类引用），窗体/动效
 * 随对应片接入。
 */
@:keep
class AddButtonWindow extends BaseWindow {
	public function new(param1:interfaces.IMsgCenter = null) {
		super(param1);
	}

	// AddButtonWindow.as:56-62（addButton：建 qui Button + 排布 + 挂点按回调，
	// qui 按钮片翻译；本片 PreviewDiyWindow 只调不用返回值。Function → Dynamic）
	public function addButton(param1:String = "Button", param2:String = null, param3:Int = 100, param4:Int = 25,
		param5:Dynamic = null, param6:Bool = true, param7:Int = 16777215, param8:Int = 12, param9:Bool = false,
		param10:String = null, param11:Int = 0):Button {
		return null;
	}
}
