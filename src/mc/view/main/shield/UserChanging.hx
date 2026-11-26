package mc.view.main.shield;

import openfl.display.Sprite;
import openfl.errors.Error;
import openfl.events.Event;
import openfl.events.TextEvent;
import openfl.text.TextField;

/**
 * mc.view.main.shield.UserChanging —— UserChanging.as 的签名面 stub（原类
 * 75 loc，issue #87「护盾层」片充真身）。切用户遮罩：上屏后建 0.6 白
 * 遮罩 modeSprite + 居中 DataLoading + 隐藏文本（LINK 监听转
 * mainCommand.userReload）；听 MainData.USER_CHANGING 同步遮罩/加载显隐、
 * SET_USER_ERROR 时喂 htmlText 换显文本藏加载。成员签名逐字取自反编译
 * 原文，方法体随 implement 充真身。
 * legacy/decompiled/Master2_v_142/scripts/mc/view/main/shield/UserChanging.as。
 */
@:keep
class UserChanging extends Sprite {
	// UserChanging.as:16-20
	private var dataLoading:mc.view.common.DataLoading;
	private var modeSprite:Sprite;
	private var _textField:TextField;

	// UserChanging.as:22-26（ctor 挂 ADDED_TO_STAGE——有副作用，入 stub 掷）
	public function new() {
		super();
		throw new Error("not implemented");
	}

	// UserChanging.as:28-33
	private function linkClick(param1:TextEvent):Void {
		throw new Error("not implemented");
	}

	// UserChanging.as:35-62
	private function toStage(param1:Event):Void {
		throw new Error("not implemented");
	}

	// UserChanging.as:64-69
	private function setUserError(param1:Event):Void {
		throw new Error("not implemented");
	}

	// UserChanging.as:71-74
	private function userChanging(param1:Event):Void {
		throw new Error("not implemented");
	}
}
