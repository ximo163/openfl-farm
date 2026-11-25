package;

import openfl.display.MovieClip;
import shim.SymbolClass;

// NPC 对话气泡旗，NPCView/LandTalkTip 直接 new（farmui_full_v_40.swf SymbolClass
// 导出符号，char#232）。原 swf 里有同名 ABC 类（legacy/decompiled/
// farmui_full_v_40/scripts/MaoPaoFlag.as——「纯符号绑定的壳」，FFDec 导出齐全），
// 构造器 addFrameScript(0, frame1, 23, frame24)：frame1 空体不译（FarmInfoPlus
// 先例）；frame24 = infoTxt.text = talkInfo; stop()——本地化管线丢了帧脚本，
// 复原走 shim/FrameScriptCompensation（#58），时间轴由 SymbolClass.bind 挂。
// ABC 字段表镜像：talkInfo 是代码专用字段（frame24 读它），落 Haxe 实例字段
// （Reflect.setField 的写通道在各目标成立）；infoTxt 是时间轴 PlaceObject 命名
// 的子件，按 FarmInfoPlus 惯例不落字段（As3.childOf → getChildByName）。
@:keep
class MaoPaoFlag extends MovieClip {
	// ABC FVar talkInfo:String（MaoPaoFlag.as:12）
	public var talkInfo:String;

	public function new() {
		super();
		SymbolClass.bind(this, "farmui_full_v_40", "MaoPaoFlag");
	}
}
