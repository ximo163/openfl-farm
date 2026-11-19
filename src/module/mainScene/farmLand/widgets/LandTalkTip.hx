package module.mainScene.farmLand.widgets;

import MaoPaoFlag;
import openfl.display.MovieClip;
import openfl.display.Sprite;
import openfl.geom.Point;
import shim.As3;

/**
 * module.mainScene.farmLand.widgets.LandTalkTip —— V3b 翻译（issue #8，
 * 17 类清单内地块控件）。作物八卦气泡：MaoPaoFlag 挂 5 秒后自动收。
 * 逐句对应 legacy/decompiled/main3_v_221/scripts/module/mainScene/farmLand/
 * widgets/LandTalkTip.as。
 */
class LandTalkTip {
	// LandTalkTip.as:10-14
	private var m_mcTalk:MovieClip;
	private var m_parent:Sprite;
	private var m_timeout:UInt;

	// LandTalkTip.as:16-21
	public function new(param1:Sprite) {
		this.m_parent = param1;
		this.m_mcTalk = null;
		this.m_timeout = 0;
	}

	// LandTalkTip.as:23-31（get visible：还挂在父级上就算在显）
	public var visible(get, never):Bool;

	private function get_visible():Bool {
		if (this.m_parent != null && this.m_mcTalk != null && this.m_parent.contains(this.m_mcTalk) == true) {
			return true;
		}
		return false;
	}

	// LandTalkTip.as:33-60（startTalk：气泡入格，反向缩放抵消地块 SCALE，
	// 5 秒后自动收）
	public function startTalk(param1:String, param2:Point, param3:Float = 1):Void {
		if (this.m_parent == null) {
			return;
		}
		if (param1 == "" || param2 == null) {
			return;
		}
		if (this.m_mcTalk == null) {
			this.m_mcTalk = new MaoPaoFlag();
			this.m_mcTalk.x = param2.x;
			this.m_mcTalk.y = param2.y;
			this.m_mcTalk.mouseChildren = false;
			this.m_mcTalk.mouseEnabled = false;
		}
		var _loc4_:Float = 1 / param3;
		if (this.m_parent.parent != null && this.m_parent.parent.scaleX > 1) {
			_loc4_ /= this.m_parent.parent.scaleX;
		}
		this.m_mcTalk.scaleX = _loc4_;
		this.m_mcTalk.scaleY = _loc4_;
		this.m_mcTalk.gotoAndPlay(1);
		// PORT-NOTE: 原版给 MaoPaoFlag 动态属性 talkInfo 赋值（符号帧脚本读它
		// 填气泡文本；swf 帧脚本不在 openfl 动画运行时里执行，赋值照抄保留，
		// 见 shim.SymbolClass 头注）
		Reflect.setField(this.m_mcTalk, "talkInfo", param1);
		this.m_parent.addChild(this.m_mcTalk);
		this.m_timeout = As3.setTimeout(function():Void {
			stopTalk();
		}, 5000);
	}

	// LandTalkTip.as:62-64（set parent：换格复用同一气泡）
	public var parent(never, set):Sprite;

	private function set_parent(param1:Sprite):Sprite {
		this.m_parent = param1;
		return param1;
	}

	// LandTalkTip.as:66-77（stopTalk：摘气泡、断父、清定时器）
	public function stopTalk():Void {
		if (this.m_mcTalk == null) {
			return;
		}
		if (this.m_parent != null && this.m_parent.contains(this.m_mcTalk) == true) {
			this.m_parent.removeChild(this.m_mcTalk);
		}
		this.m_parent = null;
		if (this.m_timeout != 0) {
			As3.clearTimeout(this.m_timeout);
		}
	}
}
