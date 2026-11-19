package module.mainScene.farmLand.widgets;

import com.qzone.utils.DisplayUtil;
import common.misc.Utils;
import openfl.display.DisplayObject;
import openfl.display.DisplayObjectContainer;
import openfl.display.Sprite;

/**
 * module.mainScene.farmLand.widgets.Wasteland —— V3b 翻译（issue #8，17 类
 * 清单内地块控件）。荒地覆盖层 + 开垦按钮。逐句对应
 * legacy/decompiled/main3_v_221/scripts/module/mainScene/farmLand/widgets/
 * Wasteland.as。
 */
class Wasteland {
	// Wasteland.as:15-19
	private var _reclaimButton:Sprite;
	private var _wasteland:DisplayObject;
	private var _parent:DisplayObjectContainer;

	// Wasteland.as:21-26
	public function new(param1:DisplayObjectContainer) {
		this._reclaimButton = null;
		this._parent = param1;
	}

	// Wasteland.as:28-31
	public function clear():Void {
		DisplayUtil.removeChild(this._parent, this._wasteland);
		DisplayUtil.removeChild(this._parent, this._reclaimButton);
	}

	// Wasteland.as:33-44（showWaste：荒地板懒取 com.qzone.ui.Wasteland 符号）
	public function showWaste():Void {
		if (this._parent != null) {
			if (this._wasteland == null) {
				this._wasteland = asDisplayObject(Utils.getMaterial("com.qzone.ui.Wasteland"));
				this._wasteland.cacheAsBitmap = true;
			}
			this._parent.addChild(this._wasteland);
		}
	}

	// Wasteland.as:46-64（showExpandBoard：开垦按钮按需挂/摘，位置逐字照抄）
	public function showExpandBoard(param1:Bool):Void {
		if (param1 == true) {
			if (this._reclaimButton == null) {
				this._reclaimButton = asSprite(Utils.getMaterial("Reclaim"));
				this._reclaimButton.name = "__reclaim__";
				this._reclaimButton.x = 66;
				this._reclaimButton.y = -28;
				this._reclaimButton.buttonMode = true;
				this._reclaimButton.useHandCursor = true;
			}
			this._parent.addChild(this._reclaimButton);
		}
		if (param1 == false) {
			if (this._reclaimButton != null) {
				DisplayUtil.removeChild(this._parent, this._reclaimButton);
			}
		}
	}

	// 原版 `Utils.getMaterial(...) as DisplayObject`
	private static function asDisplayObject(param1:Dynamic):DisplayObject {
		if (Std.isOfType(param1, DisplayObject)) {
			return cast(param1, DisplayObject);
		}
		return null;
	}

	// 原版 `Utils.getMaterial(...) as Sprite`
	private static function asSprite(param1:Dynamic):Sprite {
		if (Std.isOfType(param1, Sprite)) {
			return cast(param1, Sprite);
		}
		return null;
	}
}
