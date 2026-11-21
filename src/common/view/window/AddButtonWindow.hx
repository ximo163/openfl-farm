package common.view.window;

import com.qzone.qui.controls.Button;
import common.view.window.BaseWindow;
import openfl.display.DisplayObject;
/**
 * common.view.window.AddButtonWindow —— V3b/V3c 模块翻译，闭包 stub（issue #7）。
 * 带附加按钮的提示窗（AddButtonWindow.as）；FarmStage 建层时按 Consts 注册进控件表，本片只保类形态
 * （@:keep 防 dce，供 register/Type.resolveClass 拿到类引用），窗体/动效
 * 随对应片接入。
 * issue #29 最小补了 DogFoodWindow 用到的成员（addChildCache/buttonCache 字段、
 * addWindowChild/removeAllButton），字段/方法体照抄原文行号；其余（init 的
 * 缓存子件上树 + 按钮排布 + toCenterPositon、winButton 内部类）仍属 qui 窗口
 * 片（后续模块依赖）。
 */
@:keep
class AddButtonWindow extends BaseWindow {
	// AddButtonWindow.as:15
	private var addChildCache:Array<Dynamic> = [];

	// AddButtonWindow.as:17
	private var buttonCache:Array<Dynamic> = [];

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

	// AddButtonWindow.as:64-68（缓存进窗，AddButtonWindow.init 上树）
	public function addWindowChild(param1:DisplayObject):DisplayObject {
		this.addChildCache.push(param1);
		return param1;
	}

	// AddButtonWindow.as:70-73
	public function removeAllButton():Void {
		this.buttonCache = [];
	}
}
