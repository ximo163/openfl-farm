package module.mainScene.farmLand.widgets;

import com.greensock.TweenLite;
import common.misc.Utils;
import openfl.display.DisplayObjectContainer;
import openfl.display.MovieClip;
import openfl.errors.ArgumentError;
import openfl.geom.Point;
import module.mainScene.farmLand.FarmLandsView;

/**
 * module.mainScene.farmLand.widgets.LandPickIcon —— V3b 翻译（issue #8，
 * 17 类清单内地块控件）。可摘星标：canPickIcon 符号随成熟地块移动。
 * 逐句对应 legacy/decompiled/main3_v_221/scripts/module/mainScene/farmLand/
 * widgets/LandPickIcon.as。
 */
class LandPickIcon {
	// LandPickIcon.as:11-15
	private var _startPos:Point;
	private var _parent:DisplayObjectContainer;
	private var _canPickIcon:MovieClip;

	// LandPickIcon.as:17-27
	public function new(param1:DisplayObjectContainer, param2:Int, param3:Int) {
		if (param1 == null) {
			throw new ArgumentError("Invalid parameter");
		}
		this._canPickIcon = null;
		this._parent = param1;
		this._startPos = new Point(param2, param3);
	}

	// LandPickIcon.as:29-38（play：回挂 + 起播 + 置显）
	public function play():Void {
		if (this._canPickIcon != null) {
			if (this._parent != null && this._parent.contains(this._canPickIcon) == false) {
				this._parent.addChild(this._canPickIcon);
			}
		}
		this._canPickIcon.play();
		this._canPickIcon.visible = true;
	}

	// LandPickIcon.as:40-52（creatCanPickIcon：懒建符号，起点即构造位）
	public function creatCanPickIcon(param1:Point = null):Void {
		if (this._parent == null) {
			return;
		}
		this._canPickIcon = asMovieClip(Utils.getMaterial("canPickIcon"));
		this._canPickIcon.mouseChildren = false;
		this._canPickIcon.mouseEnabled = false;
		this._canPickIcon.stop();
		this._canPickIcon.x = this._startPos.x;
		this._canPickIcon.y = this._startPos.y;
		this._parent.addChild(this._canPickIcon);
	}

	// LandPickIcon.as:54-68（moveTo：跟随目标地块，位移/位置逐字照抄）
	public function moveTo(param1:LandItemRender):Void {
		if (param1 == null) {
			return;
		}
		var _loc2_:Point = new Point(param1.x + 100 * FarmLandsView.SCALE, param1.y - 70 * FarmLandsView.SCALE);
		if (this._canPickIcon == null) {
			this.creatCanPickIcon();
		}
		this._canPickIcon.alpha = 1;
		TweenLite.to(this._canPickIcon, 0.25, {
			"x": _loc2_.x,
			"y": _loc2_.y
		});
	}

	// LandPickIcon.as:70-79（remove：摘下并藏）
	public function remove():Void {
		if (this._canPickIcon != null) {
			if (this._parent != null && this._parent.contains(this._canPickIcon) == true) {
				this._parent.removeChild(this._canPickIcon);
			}
			this._canPickIcon.visible = false;
		}
	}

	// LandPickIcon.as:81-89（stop：淡出后停播）
	public function stop():Void {
		if (this._canPickIcon != null) {
			TweenLite.to(this._canPickIcon, 0.3, {"alpha": 0});
			this._canPickIcon.stop();
		}
	}

	// 原版 `Utils.getMaterial(...) as MovieClip`
	private static function asMovieClip(param1:Dynamic):MovieClip {
		if (Std.isOfType(param1, MovieClip)) {
			return cast(param1, MovieClip);
		}
		return null;
	}
}
