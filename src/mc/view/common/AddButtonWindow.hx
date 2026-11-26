package mc.view.common;

import com.minutes.ui.control.LipiButton;
import com.minutes.ui.core.LipiSkin;
import openfl.display.DisplayObject;
import openfl.events.Event;
import common.MaterialLib;

/**
 * mc.view.common.AddButtonWindow —— AddButtonWindow.as 的签名面 stub
 * （原类 161 loc，牧场片真身待译——#pasture；issue #19 只保 PostWindow 用
 * 到的 init/addButton/closeWindow 通道；真身把按钮排在窗口底行，文件内的
 * 内部类 winButton 随真身一起译）。成员清单见
 * legacy/decompiled/Master2_v_142/scripts/mc/view/common/AddButtonWindow.as。
 */
@:keep
class AddButtonWindow extends BaseWindow {
	public function new() {
		super();
	}

	// AddButtonWindow.as:53
	override public function init(param1:openfl.geom.Rectangle = null):Void {
		super.init(param1);
	}

	// AddButtonWindow.as:101（addButton 11 参全默认，返回 LipiButton）
	public function addButton(param1:String = "Button", param2:String = null, param3:Int = 100, param4:Int = 25, param5:Dynamic = null,
			param6:Bool = true, param7:Int = 16777215, param8:Int = 12, param9:Bool = false, param10:String = null, param11:Int = 0):LipiButton {
		var _loc1_:LipiButton = new LipiButton();
		_loc1_.label = param1;
		_loc1_.width = param3;
		_loc1_.height = param4;
		if (param2 != null) {
			_loc1_.bgSkin = new LipiSkin(MaterialLib.getInstance().getClass(param2));
		}
		_loc1_.textColor = param7;
		addChild(_loc1_);
		return _loc1_;
	}

	// AddButtonWindow.as:37
	public function closeWindow(param1:Event = null):Void {
		this.closeHandler();
	}

	// AddButtonWindow.as:42
	public function addWindowChild(param1:DisplayObject):DisplayObject {
		return addChild(param1);
	}

	// AddButtonWindow.as:48
	public function removeAllWindowChild():Void {}

	// AddButtonWindow.as:90
	public function addSpecialButton(param1:DisplayObject):DisplayObject {
		return addChild(param1);
	}

	// AddButtonWindow.as:96
	public function removeAllButton():Void {}
}
