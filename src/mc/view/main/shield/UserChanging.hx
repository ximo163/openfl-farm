package mc.view.main.shield;

import mc.control.Command;
import mc.model.MData;
import mc.model.MainData;
import mc.view.common.DataLoading;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.TextEvent;
import openfl.text.TextField;
import openfl.text.TextFormat;

/**
 * mc.view.main.shield.UserChanging —— UserChanging.as 逐句对应（issue #87
 * 「护盾层」片）。切用户遮罩：上屏后建 0.6 白遮罩 modeSprite + 居中
 * DataLoading + 隐藏文本（LINK 监听转 mainCommand.userReload）；听
 * MainData.USER_CHANGING 同步遮罩/加载显隐、SET_USER_ERROR 时喂 htmlText
 * 换显文本藏加载。
 * legacy/decompiled/Master2_v_142/scripts/mc/view/main/shield/UserChanging.as。
 *
 * PORT-NOTE(跨片依赖)：MainData.USER_CHANGING/SET_USER_ERROR 常量与
 * mainData.userChanging/setUserError 存取（mc/model 数据片）、
 * MainCommand.userReload（控制/命令片）在本片开工时 stub 无签名面——
 * 按原样直引，所属片充真身后编译链闭合（本轮并行片既定做法）。
 */
@:keep
class UserChanging extends Sprite {
	// UserChanging.as:16-20
	private var dataLoading:DataLoading;
	private var modeSprite:Sprite;
	private var _textField:TextField;

	// UserChanging.as:22-26
	public function new() {
		super();
		addEventListener(Event.ADDED_TO_STAGE, this.toStage);
	}

	// UserChanging.as:28-33
	private function linkClick(param1:TextEvent):Void {
		Command.getInstance().mainCommand.userReload();
		this._textField.visible = false;
		this.dataLoading.visible = true;
	}

	// UserChanging.as:35-62
	private function toStage(param1:Event):Void {
		removeEventListener(Event.ADDED_TO_STAGE, this.toStage);
		this.modeSprite = new Sprite();
		this.modeSprite.graphics.beginFill(16777215, 0.6);
		this.modeSprite.graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
		this.modeSprite.graphics.endFill();
		this.modeSprite.visible = false;
		addChild(this.modeSprite);
		this.dataLoading = new DataLoading();
		this.dataLoading.x = stage.stageWidth / 2;
		this.dataLoading.y = stage.stageHeight / 2;
		this.dataLoading.visible = false;
		addChild(this.dataLoading);
		this._textField = new TextField();
		this._textField.addEventListener(TextEvent.LINK, this.linkClick);
		this._textField.defaultTextFormat = new TextFormat("Verdana", 14, 8999699);
		this._textField.width = 200;
		this._textField.height = 25;
		this._textField.x = stage.stageWidth / 2 - 50;
		this._textField.y = stage.stageHeight / 2;
		this._textField.text = "";
		this._textField.selectable = false;
		this._textField.visible = false;
		addChild(this._textField);
		MData.getInstance().mainData.addEventListener(MainData.USER_CHANGING, this.userChanging);
		MData.getInstance().mainData.addEventListener(MainData.SET_USER_ERROR, this.setUserError);
	}

	// UserChanging.as:64-69
	private function setUserError(param1:Event):Void {
		this._textField.htmlText = MData.getInstance().mainData.setUserError;
		this._textField.visible = true;
		this.dataLoading.visible = false;
	}

	// UserChanging.as:71-74（连锁赋值拆开——openfl visible 是 get/set 属性，
	// 连锁形态编不过（lessons #8）；getter 是纯字段回读、无副作用，两次取值
	// 与原文单次求值等价）
	private function userChanging(param1:Event):Void {
		this.dataLoading.visible = MData.getInstance().mainData.userChanging;
		this.modeSprite.visible = MData.getInstance().mainData.userChanging;
	}
}
