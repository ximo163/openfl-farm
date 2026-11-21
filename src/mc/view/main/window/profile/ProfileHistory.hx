package mc.view.main.window.profile;

import com.minutes.ui.collections.LipiTile2;
import openfl.display.Sprite;
import openfl.events.Event;
import mc.control.Command;
import mc.model.MData;
import mc.model.MainData;
import mc.view.ViewEvent;
import mc.view.common.DataLoading;
import mc.view.main.tip.TipClassLib;
import mc.view.main.tip.TipControl;
import shim.As3;

/**
 * mc.view.main.window.profile.ProfileHistory —— ProfileHistory.as 逐句对应
 * （issue #19）。牧场个人信息窗「成果」页：5 列成果格 + 悬浮 HistoryTip。
 * 原文件
 * legacy/decompiled/Master2_v_142/scripts/mc/view/main/window/profile/ProfileHistory.as。
 */
@:keep
class ProfileHistory extends Sprite {
	// ProfileHistory.as:17（静态：当前窗看的是不是自己）
	public static var me:Bool;

	private var mainData:MainData;

	private var dataLoading:DataLoading;

	private var tile:LipiTile2;

	public function new() {
		super();
		this.addEventListener(Event.ADDED_TO_STAGE, this.init);
		this.tile = new LipiTile2(HistoryItem, 5, 90, 100);
		this.tile.addEventListener(LipiTile2.CHILD_OVER, this.onOver);
		this.tile.addEventListener(LipiTile2.CHILD_OUT, this.onOut);
		this.tile.x = 25;
		this.tile.y = 15;
		this.tile.bgAlpha = 0;
		this.tile.width = 460;
		this.tile.height = 210;
		addChild(this.tile);
		this.mainData = MData.getInstance().mainData;
		this.dataLoading = new DataLoading();
		this.dataLoading.addEventListener(ViewEvent.LINK_CLICK, this.linkClick);
		this.dataLoading.visible = this.mainData.profileLoading;
		this.dataLoading.x = 230;
		this.dataLoading.y = 100;
		addChild(this.dataLoading);
	}

	// ProfileHistory.as:47-50
	public var dataList(get, set):Array<Dynamic>;

	private function get_dataList():Array<Dynamic> {
		return this.tile.dataList;
	}

	private function set_dataList(param1:Array<Dynamic>):Array<Dynamic> {
		this.tile.dataList = param1;
		return param1;
	}

	// ProfileHistory.as:52-65
	private function linkClick(param1:ViewEvent):Void {
		var _loc2_:String = null;
		if (As3.eqString(param1.data, "reload")) {
			this.dataLoading.visible = true;
			_loc2_ = Reflect.field(this.mainData.host, "uId");
			if (!me) {
				_loc2_ = this.mainData.currentUserId;
			}
			Command.getInstance().mainCommand.getHistoryInfo(this.getCostInfoFn, _loc2_);
		}
	}

	// ProfileHistory.as:67-70
	private function onOut(param1:ViewEvent):Void {
		TipControl.hide();
	}

	// ProfileHistory.as:72-81
	private function init(param1:Event):Void {
		this.dataLoading.visible = true;
		var _loc2_:String = Reflect.field(this.mainData.host, "uId");
		if (!me) {
			_loc2_ = this.mainData.currentUserId;
		}
		Command.getInstance().mainCommand.getHistoryInfo(this.getCostInfoFn, _loc2_);
	}

	// ProfileHistory.as:88-99（回调参数原签名 Array；Boolean(param1) 对数组
	// 仅 null 为假）
	private function getCostInfoFn(param1:Array<Dynamic>):Void {
		if (param1 != null) {
			this.dataLoading.visible = false;
			this.dataList = param1;
		} else {
			this.dataLoading.errorText = "系统繁忙！<a href='event:reload'><u><font color='#ff6600'>请重试</font></u></a>";
		}
	}

	// ProfileHistory.as:101-105
	private function onOver(param1:ViewEvent):Void {
		TipClassLib.register("HistoryTip", HistoryTip);
		TipControl.show("HistoryTip", param1.data);
	}
}
