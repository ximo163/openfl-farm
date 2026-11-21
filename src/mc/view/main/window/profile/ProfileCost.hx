package mc.view.main.window.profile;

import com.minutes.ui.control.LipiTextArea;
import common.LocalData;
import openfl.display.Shape;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.text.TextField;
import openfl.text.TextFieldType;
import openfl.text.TextFormat;
import mc.control.Command;
import mc.model.MData;
import mc.model.MainData;
import mc.view.ViewEvent;
import mc.view.common.DataLoading;
import shim.As3;

/**
 * mc.view.main.window.profile.ProfileCost —— ProfileCost.as 逐句对应
 * （issue #19）。牧场个人信息窗「消费」页：农/牧场两路消费日志合流、按
 * time 降序渲染。原文件
 * legacy/decompiled/Master2_v_142/scripts/mc/view/main/window/profile/ProfileCost.as。
 */
@:keep
class ProfileCost extends Sprite {
	private var mainData:MainData;

	private var costArr:Array<Dynamic>;

	private final FN_MILL_COST:Int = 1;

	public var requireReload:Bool = true;

	private var dataLoading:DataLoading;

	private var aLipiList:LipiTextArea;

	private var bGetFarmAnimalCost:Bool;

	private var bGetMillCost:Bool;

	private final FN_FARM_ANIMAL_COST:Int = 0;

	public function new() {
		super();
		this.addEventListener(Event.ADDED_TO_STAGE, this.init);
		this.aLipiList = new LipiTextArea();
		this.aLipiList.bgAlpha = 0;
		this.aLipiList.vLipiScrollBar.visible = false;
		this.aLipiList.width = 470;
		this.aLipiList.height = 190;
		this.aLipiList.x = 20;
		this.aLipiList.y = 20;
		this.aLipiList.type = TextFieldType.DYNAMIC;
		addChild(this.aLipiList);
		var _loc1_:Shape = new Shape();
		_loc1_.graphics.lineStyle(1, 16777215);
		_loc1_.graphics.moveTo(0, 0);
		_loc1_.graphics.lineTo(490, 0);
		_loc1_.y = 195;
		_loc1_.x = 3;
		addChild(_loc1_);
		this.mainData = MData.getInstance().mainData;
		this.dataLoading = new DataLoading();
		this.dataLoading.addEventListener(ViewEvent.LINK_CLICK, this.linkClick);
		this.dataLoading.visible = this.mainData.profileLoading;
		this.dataLoading.x = width / 2;
		this.dataLoading.y = height / 2;
		addChild(this.dataLoading);
		var _loc2_:TextField = new TextField();
		var _loc3_:TextFormat = new TextFormat("Verdana", 12, 8999699, null, null, null, null, null, "center");
		_loc2_.backgroundColor = 16777176;
		_loc2_.background = true;
		_loc2_.width = 493;
		_loc2_.height = 18;
		_loc2_.selectable = false;
		addChild(_loc2_);
		_loc2_.defaultTextFormat = _loc3_;
		_loc2_.htmlText = "";
	}

	// ProfileCost.as:77-82
	private function setGetCost():Void {
		this.costArr = [];
		this.bGetFarmAnimalCost = false;
		this.bGetMillCost = false;
	}

	// ProfileCost.as:84-90
	private function compareDate(param1:Date, param2:Date):Int {
		param1 = new Date(param1.getFullYear(), param1.getMonth(), param1.getDate(), 0, 0, 0);
		param2 = new Date(param2.getFullYear(), param2.getMonth(), param2.getDate(), 0, 0, 0);
		// 原文 `var _loc3_:int = Math.abs(...)`：|Δms| 过 2^31（≈24.9 天）
		// 按 int32 回绕——约 49.7-74.6 天的流水回绕成 0/1/2、被错标成
		// 今天/昨天/前天，原版 bug 照抄（js/eval 的 Int 不回绕，走 As3.int32）
		var _loc3_:Int = As3.int32(Math.abs(param2.getTime() - param1.getTime()));
		return Std.int(_loc3_ / 3600 / 24 / 1000);
	}

	// ProfileCost.as:92-100
	private function init(param1:Event):Void {
		if (this.requireReload) {
			this.dataLoading.visible = true;
			this.setGetCost();
			Command.getInstance().mainCommand.getCostInfo(this.getCostInfoFn1, this.getCostInfoFn2);
		}
	}

	// ProfileCost.as:102-147（uid/uin 局部原版取了未用，略）
	private function genMsg(param1:Dynamic):String {
		var _loc8_:String = null;
		var _loc12_:String = null;
		var _loc2_:String = "";
		var _loc3_:String = Std.string(Reflect.field(param1, "msg"));
		var _loc6_:Array<Dynamic> = MData.getInstance().mainData.friendList;
		var _loc7_:String = "";
		var _loc9_:String = "";
		var _loc10_:Array<Dynamic> = ["", "空间", "校友"];
		if (LocalData.mode == "qzone") {
			_loc10_[1] = "";
		} else {
			_loc10_[2] = "";
		}
		if (As3.hasProp(param1, "domain")) {
			_loc9_ = As3.arrayIndex(_loc10_, Std.string(Reflect.field(param1, "domain")));
		}
		_loc8_ = _loc9_ + _loc3_;
		var _loc11_:Date = Date.fromTime(As3.floatOf(Reflect.field(param1, "time")) * 1000);
		var _loc13_:String = this.twoData(_loc11_.getHours());
		var _loc14_:String = this.twoData(_loc11_.getMinutes());
		if (this.compareDate(_loc11_, Date.now()) == 0) {
			_loc12_ = "    " + "今天" + _loc13_ + ":" + _loc14_;
		} else if (this.compareDate(_loc11_, Date.now()) == 1) {
			_loc12_ = "    " + "昨天" + _loc13_ + ":" + _loc14_;
		} else if (this.compareDate(_loc11_, Date.now()) == 2) {
			_loc12_ = "    " + "前天" + _loc13_ + ":" + _loc14_;
		} else {
			_loc12_ = this.twoData(_loc11_.getMonth() + 1) + "-" + this.twoData(_loc11_.getDate()) + " " + _loc13_ + ":" + _loc14_;
		}
		return "<b>" + _loc12_ + "</b>  " + _loc8_ + "<br>";
	}

	// ProfileCost.as:149-156
	private function twoData(param1:Int):String {
		if (param1 < 10) {
			return "0" + Std.string(param1);
		}
		return Std.string(param1);
	}

	// ProfileCost.as:158-175（AS3 for-each over null 零次迭代，加 null 守卫）
	public var dataList(never, set):Array<Dynamic>;

	private function set_dataList(param1:Array<Dynamic>):Array<Dynamic> {
		var _loc3_:Dynamic = null;
		var _loc2_:String = "";
		if (param1 != null) {
			for (_loc3_ in param1) {
				_loc2_ += this.genMsg(_loc3_);
			}
		}
		this.aLipiList.htmlText = "<textformat leading='8'><font face='Verdana'>" + _loc2_ + "</font></textformat>";
		if (this.aLipiList.textField.numLines > 9) {
			this.aLipiList.vLipiScrollBar.visible = true;
		} else {
			this.aLipiList.vLipiScrollBar.visible = false;
		}
		return param1;
	}

	// ProfileCost.as:177-180
	private function getCostInfoFn1(param1:Dynamic):Void {
		this.getCostInfoFn(param1, this.FN_FARM_ANIMAL_COST);
	}

	// ProfileCost.as:182-191
	private function setCostInfo():Void {
		if (this.bGetFarmAnimalCost && this.bGetMillCost) {
			this.requireReload = false;
			this.dataLoading.visible = false;
			// costArr.sortOn("time", Array.DESCENDING)：AVM2 无 NUMERIC 按
			// 字符串序降序（见 As3.sortOnDesc 注）
			As3.sortOnDesc(this.costArr, "time");
			this.dataList = this.costArr;
		}
	}

	// ProfileCost.as:193-196
	private function getCostInfoFn2(param1:Dynamic):Void {
		this.getCostInfoFn(param1, this.FN_MILL_COST);
	}

	// ProfileCost.as:198-206
	private function linkClick(param1:ViewEvent):Void {
		if (As3.eqString(param1.data, "reload")) {
			this.dataLoading.visible = true;
			this.setGetCost();
			Command.getInstance().mainCommand.getCostInfo(this.getCostInfoFn1, this.getCostInfoFn2);
		}
	}

	// ProfileCost.as:208-231
	private function getCostInfoFn(param1:Dynamic, param2:Int):Void {
		if (As3.floatOf(Reflect.field(param1, "code")) == 1) {
			if (this.FN_FARM_ANIMAL_COST == param2) {
				this.bGetFarmAnimalCost = true;
			} else if (this.FN_MILL_COST == param2) {
				this.bGetMillCost = true;
			}
			if (!As3.truthy(Reflect.field(param1, "cost"))) {
				Reflect.setField(param1, "cost", []);
			}
			this.costArr = this.costArr.concat(Reflect.field(param1, "cost"));
			this.setCostInfo();
		} else {
			this.dataLoading.errorText = "请求超时，" + "<a href='event:reload'><u><font color='#ff6600'>点击重试</font></u></a>";
		}
	}
}
