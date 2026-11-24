package module.mainScene.npc;

import MaoPaoFlag;
import com.qzone.allianceActivity.framewrok.manager.ClickReportManager;
import com.qzone.utils.DisplayUtil;
import common.CommonData;
import common.Consts;
import common.Session;
import common.Settings;
import common.misc.QzoneJSAPI;
import common.view.window.WindowControl;
import events.CommonEvent;
import framework.base.BaseLayer;
import module.mainScene.npc.widgets.DogBowl;
import module.mainScene.npc.widgets.DogFoodWindow;
import module.mainScene.npc.widgets.DogRender;
import openfl.display.DisplayObject;
import openfl.display.DisplayObjectContainer;
import openfl.display.Loader;
import openfl.display.LoaderInfo;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.events.MouseEvent;
import openfl.geom.Point;
import openfl.net.URLRequest;
import openfl.system.ApplicationDomain;
import openfl.system.LoaderContext;
import openfl.system.SecurityDomain;
import shim.As3;
import shim.LocalSwfLoader;
import shim.QQOutlets;

/**
 * module.mainScene.npc.NPCView —— V3b 翻译（issue #8）。
 * NPC 层：看门狗渲染/狗粮盆/活动 NPC 与 361 广告位。逐句对应
 * legacy/decompiled/main3_v_221/scripts/module/mainScene/npc/NPCView.as。
 */
class NPCView extends Sprite {
	// NPCView.as:35-47
	private var _activityHolder:Sprite;
	private var _activityNPCData:Dynamic;
	private var m_farmDog:DogRender;
	private var m_middleLayer:DisplayObjectContainer;
	private var m_controller:NPCController;
	private var m_dogBowl:DogBowl;
	private var m_dogFoodWindow:DogFoodWindow;

	// NPCView.as:49-82
	public function new(param1:NPCController) {
		var _loc2_:Settings = null;
		var _loc3_:String = null;
		var _loc4_:Array<String> = null;
		var _loc5_:Date = null;
		var _loc6_:Date = null;
		var _loc7_:Float = Math.NaN;
		super();
		name = Consts.SCENE_ZINDEX_FOREGROUND;
		this.m_farmDog = null;
		this.m_dogBowl = null;
		this.m_dogFoodWindow = null;
		this.m_controller = param1;
		this.m_middleLayer = Std.isOfType(param1.module.container.getChildByName(Consts.SCENE_ZINDEX_MIDDLE),
			DisplayObjectContainer) ? cast(param1.module.container.getChildByName(Consts.SCENE_ZINDEX_MIDDLE),
			DisplayObjectContainer) : null;
		addEventListener(Event.ADDED_TO_STAGE, this.onAddedToStage);
		if (QzoneJSAPI.QPLUS == false && QzoneJSAPI.WB == false) {
			_loc2_ = Settings.getInstance();
			_loc3_ = _loc2_.getStringAttribute("a361");
			if (_loc3_ == null || _loc3_ == "") {
				return;
			}
			_loc4_ = _loc3_.split("-");
			// PORT-NOTE: AS3 的 new Date(字符串) 任意格式解析 → As3.dateOf
			//（仅复刻 m/d/Y[ H:M[:S]] 形态，a361 配置即此形态）。解析失败原版得
			// Invalid Date（time=NaN，比较恒 false 不加载），dateOf 得 null——判
			// null 跳过比较即等价（FarmLand.get__goldLand 同式）
			_loc5_ = As3.dateOf(_loc4_[0]);
			_loc6_ = As3.dateOf(_loc4_[1]);
			// *1000.0：eval 上 Int 表示的 Float 乘 Int 字面量按 Int32 回绕
			//（纪元秒×1000 必爆），js 两者一致（同 FarmLand.get__goldLand）
			_loc7_ = CommonData.serverTime * 1000.0;
			if (_loc5_ != null && _loc6_ != null && _loc7_ >= _loc5_.getTime() && _loc7_ <= _loc6_.getTime()) {
				this.loadAdvertiseIcon("module/ui/361.swf");
			}
		}
	}

	// NPCView.as:84-102（onFoodLoaded：狗粮状态到位开狗粮窗口）
	private function onFoodLoaded(param1:CommonEvent):Void {
		var _loc2_:WindowControl = null;
		if (Session.getInstance().me == true) {
			if (this.m_dogFoodWindow == null) {
				this.m_dogFoodWindow = new DogFoodWindow(this);
			}
			_loc2_ = this.controller.module.app.farmView.winCtrl;
			if (_loc2_ == null) {
				return;
			}
			_loc2_.open(this.m_dogFoodWindow);
			this.m_dogFoodWindow.data = param1.data;
			this.updateFood();
		}
	}

	// NPCView.as:104-156（installNPC：活动 NPC 入场，冒泡旗 5 秒后移除）
	public function installNPC(param1:Dynamic):Void {
		var container:DisplayObjectContainer = null;
		var removeBubble:Dynamic = null;
		var mcTalk:MaoPaoFlag = null;
		var p:Point = null;
		var lyr:BaseLayer = null;
		var data:Dynamic = param1;
		// 原版 removeBubble 经 setTimeout 传参、体内读 arguments[0]；Haxe 的
		// As3.setTimeout 只收无参闭包，调用点包一层把 mcTalk 送进去，体内照读
		removeBubble = function(param1:Dynamic):Void {
			if (param1 == null) {
				return;
			}
			var _loc2_:Sprite = Std.isOfType(param1, Sprite) ? cast(param1, Sprite) : null;
			// 原版守卫 `_loc2_ == null && _loc2_.parent != null` 恒假（应为
			// != null 才对，疑似笔误），照抄保持死分支
			if (_loc2_ == null && _loc2_.parent != null) {
				return;
			}
			_loc2_.parent.removeChild(_loc2_);
			_loc2_ = null;
		};
		var role:Sprite = Std.isOfType(Reflect.field(data, "role"), Sprite) ? cast(Reflect.field(data, "role"),
			Sprite) : null;
		if (role == null) {
			return;
		}
		role.buttonMode = true;
		role.mouseEnabled = true;
		role.x = role.y = 0;
		container = this.activityHolder;
		container.x = As3.intOf(Reflect.field(data, "x"));
		container.y = As3.intOf(Reflect.field(data, "y"));
		container.addChild(role);
		this._activityNPCData = data;
		// AS3 `!= undefined` 一并排除 null（null == undefined 为真）
		if (Reflect.hasField(data, "bubble") && Reflect.field(data, "bubble") != null && Reflect.field(data, "bubble") != "") {
			mcTalk = new MaoPaoFlag();
			mcTalk.x = 0;
			mcTalk.y = -100;
			mcTalk.mouseChildren = false;
			mcTalk.mouseEnabled = false;
			mcTalk.gotoAndPlay(1);
			// 原版 AS3 写法：气泡文本由 MaoPaoFlag 的帧脚本 frame24 在第 24 帧落上
			//（infoTxt.text = talkInfo）并 stop。talkInfo 是 ABC 类字段（非动态
			// 属性），落在 src/MaoPaoFlag.hx 的字段镜像上；帧脚本本体经
			// shim/FrameScriptCompensation 在 openfl 侧复原（#58）
			Reflect.setField(mcTalk, "talkInfo", Reflect.field(data, "bubble"));
			p = container.localToGlobal(new Point(role.x, role.y));
			lyr = this.controller.module.app.farmView.getLayerByName(Consts.LAYER_TOOLS);
			p = lyr.globalToLocal(p);
			lyr.addChild(mcTalk);
			mcTalk.x = p.x;
			mcTalk.y = p.y - 100;
			As3.setTimeout(function():Void {
				removeBubble(mcTalk);
			}, 5000);
		}
	}

	// NPCView.as:158-190（updateFood：按狗状态摆/收狗粮盆）
	public function updateFood():Void {
		if (this.m_dogBowl == null) {
			this.m_dogBowl = new DogBowl(this);
			if (this.m_middleLayer != null) {
				this.m_middleLayer.addChildAt(this.m_dogBowl, 0);
			}
		}
		if (this.m_controller.model.dogID <= 0) {
			DisplayUtil.removeChild(this.m_middleLayer, this.m_dogBowl);
		} else {
			// 原版 `dogHungry == 0`（Boolean 对 0：false==0 成立）≡ == false
			if (this.m_controller.model.dogHungry == false) {
				this.m_dogBowl.food = false;
			} else {
				this.m_dogBowl.food = true;
			}
			if (this.m_dogBowl.parent == null) {
				if (this.m_middleLayer != null) {
					this.m_middleLayer.addChildAt(this.m_dogBowl, 0);
				}
			}
		}
	}

	// NPCView.as:192-251（loadAdvertiseIcon：361 广告位，QZone 宿主 JS 弹层）
	private function loadAdvertiseIcon(param1:String):Void {
		var loader:Loader;
		var loadComplete:Dynamic = null;
		var errorHandler:Dynamic = null;
		var onClick361:Dynamic = null;
		var onOver361:Dynamic = null;
		var onOut361:Dynamic = null;
		var url:String = param1;
		loadComplete = function(param1:Event):Void {
			var _loc2_:DisplayObject = null;
			if (Std.isOfType(param1.target, LoaderInfo)) {
				_loc2_ = cast(param1.target, LoaderInfo).content;
			}
			if (_loc2_ == null) {
				return;
			}
			_loc2_.x = 192;
			_loc2_.y = 680;
			_loc2_.addEventListener(MouseEvent.CLICK, onClick361, false, 0, true);
			_loc2_.addEventListener(MouseEvent.MOUSE_OVER, onOver361, false, 0, true);
			_loc2_.addEventListener(MouseEvent.MOUSE_OUT, onOut361, false, 0, true);
			addChild(_loc2_);
		};
		errorHandler = function(param1:IOErrorEvent):Void {};
		onClick361 = function(param1:MouseEvent):Void {
			var _loc2_:String = "";
			if (Settings.getInstance().mode == "") {
				_loc2_ = "";
			}
			CommonData.addCallBackProxy("getGiftBack", on361Callback);
			// PORT-NOTE(qq-outlet)：ExternalInterface.call → QQOutlets.call，
			// 独立部署无 QZone 宿主 JS（spec/deviations.json：no-qq-telemetry）
			QQOutlets.call("QZFL.dialog.create(\'\'," + "\'<iframe src=" + _loc2_ + "&id=0"
				+ " style=\"width:570px; height:460px; border:0px\" scrolling=no border=0 frameBorder=no allowTransparency=true></iframe>\', {width:570,height:460,noBorder:true})");
			ClickReportManager.reportClick("361_Click_Icon_NC");
		};
		onOver361 = function(param1:MouseEvent):Void {
			m_controller.useSystemCursor(true);
		};
		onOut361 = function(param1:MouseEvent):Void {
			m_controller.useSystemCursor(false);
		};
		if (url == "" || url == null) {
			return;
		}
		url = Settings.getInstance().replaceAppImg(url);
		// PORT-NOTE(load-swf)：`new Loader()` → shim.LocalSwfLoader
		//（module/ URL 映射 Assets 库，见该 shim 头注释）
		loader = new LocalSwfLoader();
		loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
		// PORT-NOTE: IOErrorEvent.NETWORK_ERROR 在 openfl 被裁（值 "networkError"
		// 恒定，见 framework/net/core/HttpOperationEx.hx 同注）——同一 handler
		// 双注册的形态保留，openfl 网络错误统一走 ioError，此串不会触发
		loader.contentLoaderInfo.addEventListener("networkError", errorHandler);
		loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadComplete);
		loader.load(new URLRequest(url),
			new LoaderContext(true, ApplicationDomain.currentDomain, SecurityDomain.currentDomain));
	}

	// NPCView.as:253-266（switchNPC：按当前用户切 NPC 层显隐）
	public function switchNPC():Void {
		if (Session.getInstance().me) {
			if (this._activityHolder != null) {
				this._activityHolder.visible = true;
			}
		} else if (this._activityHolder != null) {
			this._activityHolder.visible = false;
		}
	}

	// NPCView.as:268-275（on361Callback：领奖回包后刷作物/背包）
	private function on361Callback(param1:Dynamic):Void {
		// 原版 `param1 as Boolean == true`：as Boolean 只对真 Boolean 过，
		// 数字串一律 null（== true 为假），按同型判断保持
		if (Std.isOfType(param1, Bool) && param1 == true) {
			this.m_controller.module.app.dispatchEvent(new CommonEvent(Consts.DATA_CROP_RELOAD_FLAG, null));
			this.m_controller.module.app.dispatchEvent(new CommonEvent(Consts.DATA_BAG_RELOAD_FLAG, null));
		}
	}

	// NPCView.as:277-288（get activityHolder：懒建 NPC 挂点）
	public var activityHolder(get, never):DisplayObjectContainer;

	private function get_activityHolder():DisplayObjectContainer {
		if (this._activityHolder == null) {
			this._activityHolder = new Sprite();
			this.m_middleLayer.addChild(this._activityHolder);
			this._activityHolder.addEventListener(MouseEvent.ROLL_OVER, this.onNPCOver, false, 0, true);
			this._activityHolder.addEventListener(MouseEvent.ROLL_OUT, this.onNPCOut, false, 0, true);
			this._activityHolder.buttonMode = true;
		}
		return this._activityHolder;
	}

	// NPCView.as:290-293（get controller）
	public var controller(get, never):NPCController;

	private function get_controller():NPCController {
		return this.m_controller;
	}

	// NPCView.as:295-300（onAddedToStage：订阅狗模型事件）
	private function onAddedToStage(param1:Event):Void {
		param1.target.removeEventListener(Event.ADDED_TO_STAGE, this.onAddedToStage);
		this.m_controller.model.addEventListener(NPCModel.EVENT_DOG_LOADED, this.onDogInitialized, false, 0, true);
		this.m_controller.model.addEventListener(NPCModel.EVENT_DOG_FOOD_LOADED, this.onFoodLoaded, false, 0, true);
	}

	// NPCView.as:302-306（onNPCOut）
	private function onNPCOut(param1:MouseEvent):Void {
		this.controller.useSystemCursor(false);
		this.controller.hideTip();
	}

	// NPCView.as:308-315（onNPCOver）
	private function onNPCOver(param1:MouseEvent):Void {
		this.controller.useSystemCursor(true);
		// NPCView.as:311（`["tip"] != undefined` → hasField + field != null 双查，
		// 同文件 :143 bubble 同款；AS3 null == undefined，值 null 也不显示）
		if (this._activityNPCData != null && Reflect.hasField(this._activityNPCData, "tip")
			&& Reflect.field(this._activityNPCData, "tip") != null) {
			this.controller.showTip(Consts.TIP_NAME_MOUSE, Reflect.field(this._activityNPCData, "tip"));
		}
	}

	// NPCView.as:317-338（onDogInitialized：狗数据到位，换 DogRender）
	private function onDogInitialized(param1:CommonEvent):Void {
		this.updateFood();
		var _loc2_:Int = this.m_controller.model.dogID;
		if (this.m_farmDog != null && this.m_farmDog.id != Std.string(_loc2_)) {
			DisplayUtil.removeChild(this.m_middleLayer, this.m_farmDog);
			this.m_farmDog.stop();
			this.m_farmDog = null;
		}
		if (_loc2_ > 0) {
			if (this.m_farmDog == null) {
				this.m_farmDog = new DogRender(_loc2_);
				if (this.m_middleLayer != null) {
					this.m_middleLayer.addChildAt(this.m_farmDog, this.m_middleLayer.getChildIndex(this.m_dogBowl) + 1);
				}
			}
		}
	}
}
