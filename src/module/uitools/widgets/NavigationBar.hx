package module.uitools.widgets;

import com.qzone.qui.containers.HBox;
import com.qzone.qui.controls.scrollClasses.ScrollPolicy;
import com.qzone.qui.core.Align;
import com.qzone.qui.makers.ButtonMaker;
import com.qzone.utils.DateUtil;
import common.CommonData;
import common.Consts;
import common.Session;
import common.Settings;
import common.misc.Cookies;
import common.misc.QzoneJSAPI;
import common.misc.Utils;
import entities.Player;
import events.CommonEvent;
import events.ViewEvent;
import module.uitools.UIController;
import openfl.display.DisplayObject;
import openfl.display.MovieClip;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.text.TextField;
import report.ClickReportManager;
import report.EventRecorder;
import report.UserActionRecorder;
import shim.As3;
import shim.ClipProps;

/**
 * module.uitools.widgets.NavigationBar —— NavigationBar.as 逐句对应（issue #9
 * uitools 片）。顶部导航条：8 个固定入口按钮 + 分页箭头（QPLUS/WB 宿主砍掉
 * 牧场/餐厅/加工坊/超市），超市按钮带 monthEndArrow 推广角标（8 秒自动撤），
 * addIcon 挂活动图标。ROLL_OVER/ROLL_OUT 监听照抄——悬停合成在
 * spec/interaction-map.json 落地前不做（映射表缺失，见 BLOCKED 项）。
 */
class NavigationBar extends HBox {
	// NavigationBar.as:33-51
	private static final NAV_FARM:Int = 0;
	private static final NAV_MC:Int = 1;
	private static final NAV_SUPERMARKET:Int = 3;
	private static final NAV_RESTAURANT:Int = 2;
	private static final NAV_MILL:Int = 4;
	private static final NAV_WAREHOUSE:Int = 5;
	private static final NAV_SHOP:Int = 6;
	private static final NAV_DECOREATE:Int = 7;
	private static final NAV_APP_SHOW_MAX:Int = 4;
	private static final NAV_APP_TOTAL:Int = 5;

	// NavigationBar.as:53（addIcon 按活动图标数改写，非常量）
	private var NAV_MAX:Int = 8;

	// NavigationBar.as:55/:59（`*`：素材剪辑，动态字段 name/iconNO 等经动态取）
	private var leftArrow:Dynamic;
	private var showBtnIndex:Int;
	private var rightArrow:Dynamic;
	private var BUTTONS_TIP:Array<Dynamic>;

	// NavigationBar.as:63（AS3 private const → Haxe private final，ctor 赋值）
	private final BUTTONS:Array<Dynamic>;

	private var supermarketTime:UInt;
	private var BUTTONS_NAME:Array<Dynamic>;
	private var m_controller:UIController;
	private var m_buttons:Array<Dynamic>;

	public function new(param1:UIController) {
		// NavigationBar.as:75-79（FFDec 局部）
		var btn:Dynamic;
		var i:Int;
		var scale:Float;
		var _arrow:MovieClip = null;
		var controller:UIController = param1;
		// FFDec 把字段初始化折进 ctor 顶部、super() 前执行，照抄该顺序
		this.BUTTONS = ["ButtonFarm", "ButtonMC", "ButtonRestaurant", "ButtonSuperMarket", "ButtonMill1", "ButtonWarehouse", "ButtonShop", "ButtonDecorate"];
		this.BUTTONS_NAME = ["farm", "mc", "restaurant", "supermarket", "mill", "warehouse", "shop", "decorate"];
		this.BUTTONS_TIP = ["我的农场", "我的牧场", "我的餐厅", "我的超市", "加工坊（可加工化肥、罐头等）", "仓库（收获的果子会在这里）", "农场商店（来这里买种子）", "装饰农场"];
		super(430, 64);
		this.m_controller = controller;
		this.alignH = Align.RIGHT;
		this.alignV = Align.MIDDLE;
		this.gapH = 8;
		this.gapV = 12;
		this.borderSizeH = 0;
		this.borderSizeV = 2;
		this.autoLayout = true;
		this.verticalScrollPolicy = ScrollPolicy.OFF;
		this.horizontalScrollPolicy = ScrollPolicy.OFF;
		this.defaultSkin = null;
		this.specialGapHIndex = 3;
		this.specialGapH = 27;
		scale = 1;
		btn = null;
		this.m_buttons = new Array();
		this.showBtnIndex = 0;
		i = 0;
		// NavigationBar.as:102-145（for 的 continue 前照抄自增，防死循环）
		while (i < this.NAV_MAX) {
			if (QzoneJSAPI.QPLUS == true || QzoneJSAPI.WB == true) {
				if (i == NAV_MC || i == NAV_RESTAURANT || i == NAV_MILL || i == NAV_SUPERMARKET) {
					i++;
					continue;
				}
			}
			btn = Utils.getMaterial(this.BUTTONS[i]);
			ButtonMaker.addTarget(btn);
			// PORT-NOTE: btn 原文是 var btn:*，name/scaleX/scaleY 是 DisplayObject
			// 真属性——AS3 点取走 setter/getter，Dynamic 裸写只落 JS 自有字段、
			// openfl 内部（getChildByName/变换矩阵）看不见。经 (btn : MovieClip)
			// 强类型化走真属性（#8 for-each 同款修法）；tipText 是动态属性，
			// 走 ClipProps 侧表（cpp 裸写抛 "Invalid field"，#10 真机实证）。
			(btn : MovieClip).name = this.BUTTONS_NAME[i];
			ClipProps.set(btn, "tipText", this.BUTTONS_TIP[i]);
			btn.addEventListener(MouseEvent.CLICK, this.buttonClickHandler);
			btn.addEventListener(MouseEvent.ROLL_OVER, this.toolRollOver);
			btn.addEventListener(MouseEvent.ROLL_OUT, this.toolRollOut);
			(btn : MovieClip).scaleX = (btn : MovieClip).scaleY = scale;
			this.m_buttons.push(btn);
			if (!(i >= this.showBtnIndex + NAV_APP_SHOW_MAX && i < NAV_APP_TOTAL)) {
				this.addElement(btn);
				if (this.BUTTONS_NAME[i] == "supermarket") {
					if (isSupermarketNeedTip()) {
						_arrow = cast(this.getChildByName("__supermarketarrow__"), MovieClip);
						if (_arrow == null) {
							_arrow = cast(Utils.getMaterial("monthEndArrow"), MovieClip);
							_arrow.name = "__supermarketarrow__";
							// 素材剪辑的 tipMc.tip 文本链经 As3.childOf 取（时间轴具名子实例）
							cast(As3.childOf(As3.childOf(_arrow, "tipMc"), "tip"), TextField).text = "全新游戏，精彩无限！";
							this.addChild(_arrow);
						}
						_arrow.mouseEnabled = false;
						this.addEventListener(Event.ENTER_FRAME, this.supermarketMove);
						this.supermarketTime = As3.setTimeout(function():Void {
							removeSupermarketTip();
						}, 8000);
						Cookies.setObject("supermarket_new_" + Std.string(Session.getInstance().host._uId), "true");
					}
				}
			}
			i++;
		}
		if (QzoneJSAPI.QPLUS == false && QzoneJSAPI.WB == false) {
			this.leftArrow = Utils.getMaterial("NavigationLeftArrow");
			// leftArrow/rightArrow 原文 var *:name/x/y 是真属性，经强类型化
			// （同上 PORT-NOTE）
			(this.leftArrow : MovieClip).name = "leftArrow";
			this.leftArrow.addEventListener(MouseEvent.CLICK, this.onScrollBar);
			this.addChild(this.leftArrow);
			this.rightArrow = Utils.getMaterial("NavigationRightArrow");
			(this.rightArrow : MovieClip).name = "rightArrow";
			this.rightArrow.addEventListener(MouseEvent.CLICK, this.onScrollBar);
			this.addChild(this.rightArrow);
		}
		this.addEventListener(Event.ADDED_TO_STAGE, this.onAddedToStage, false, 0, true);
	}

	// NavigationBar.as:160-173
	public static function isSupermarketNeedTip():Bool {
		var _loc1_:String = Settings.getInstance().getStringAttribute("supermarketTip");
		if (CommonData.serverTime > DateUtil.getDateFromString(_loc1_).getTime() / 1000) {
			return false;
		}
		var _loc2_:UInt = Session.getInstance().host._uId;
		if (Cookies.getObject("supermarket_new_" + Std.string(_loc2_)) == null) {
			return true;
		}
		return false;
	}

	// NavigationBar.as:175-186
	private function switchIcons():Void {
		var _loc1_:Player = Session.getInstance().host;
		if (_loc1_._yellowlevel >= As3.parseInt(Settings.getInstance().getStringAttribute("QQSuperMarketVip")) || _loc1_.level >= As3.parseInt(Settings.getInstance().getStringAttribute("QQSuperMarketLvl"))) {
			this.m_buttons[NAV_SUPERMARKET].gotoAndStop(1);
		} else {
			this.m_buttons[NAV_SUPERMARKET].gotoAndStop(2);
		}
	}

	// NavigationBar.as:188-201
	private function removeSupermarketTip():Void {
		var _loc1_:MovieClip = cast(this.getChildByName("__supermarketarrow__"), MovieClip);
		if (_loc1_ != null) {
			if (_loc1_.parent != null) {
				_loc1_.parent.removeChild(_loc1_);
				_loc1_ = null;
			}
		}
		As3.clearTimeout(this.supermarketTime);
		this.removeEventListener(Event.ENTER_FRAME, this.supermarketMove);
	}

	// NavigationBar.as:203-213（Boolean(x) → x != null，AS3 对象真值）
	private function adjustPosition():Void {
		this.x = this.stage.stageWidth - this.width - this.gapH;
		this.y = 0;
		if (this.leftArrow != null && this.rightArrow != null) {
			// x/y 真属性经强类型化（ctor PORT-NOTE 同款）
			(this.leftArrow : MovieClip).y = (this.rightArrow : MovieClip).y = 22;
			(this.leftArrow : MovieClip).x = -10;
			(this.rightArrow : MovieClip).x = 239;
		}
	}

	// NavigationBar.as:215-218
	private function toolRollOut(param1:MouseEvent):Void {
		this.m_controller.hideTip();
	}

	// NavigationBar.as:220-238（iconNO 的 `!= undefined`：缺位与 null 同判）
	private function onAddedToStage(param1:Event):Void {
		this.removeEventListener(Event.ADDED_TO_STAGE, this.onAddedToStage);
		this.adjustPosition();
		this.currentUserChanged();
		this.switchIcons();
		if (QzoneJSAPI.QPLUS == false && QzoneJSAPI.WB == false) {
			Session.getInstance().m_millOpen = true;
			// iconNO 是素材按钮的时间轴具名子实例（AS3 dynamic 查找），
			// 经 As3.childOf 取；visible 落 DisplayObject 真属性
			var iconNO:Dynamic = As3.childOf(this.m_buttons[NAV_RESTAURANT], "iconNO");
			if (iconNO != null) {
				cast(iconNO, openfl.display.DisplayObject).visible = false;
			}
			iconNO = As3.childOf(this.m_buttons[NAV_MILL], "iconNO");
			if (iconNO != null) {
				cast(iconNO, openfl.display.DisplayObject).visible = false;
			}
		}
	}

	// NavigationBar.as:240-287（分页循环原文如此：负下标走 +NAV_APP_TOTAL 环回，
	// _loc3_ 越过 SHOW_MAX 后固定插到 NAV_APP_TOTAL 位）
	private function onScrollBar(param1:MouseEvent):Void {
		var _loc2_:Int = this.showBtnIndex;
		// PORT-NOTE: e.target/currentTarget 静态是 openfl Object（=Dynamic），
		// .name 裸读在 js/eval 恒 undefined（openfl get/set 无物理字段，机制见
		// handbook/lessons）——(: DisplayObject) 强类型读恢复 AS3 getter 语义，
		// 本类四处分发同款（FarmLandsView 先例）
		if ((param1.currentTarget : DisplayObject).name == "leftArrow") {
			--this.showBtnIndex;
		} else if ((param1.currentTarget : DisplayObject).name == "rightArrow") {
			++this.showBtnIndex;
		}
		if (this.showBtnIndex >= NAV_APP_TOTAL || this.showBtnIndex <= -NAV_APP_TOTAL) {
			this.showBtnIndex = 0;
		}
		this.removeAllElements();
		var _loc3_:Int = 0;
		var _loc4_:Int = this.showBtnIndex;
		while (_loc4_ < this.NAV_MAX) {
			if (_loc3_ >= NAV_APP_SHOW_MAX) {
				_loc3_ = -1;
				_loc4_ = NAV_APP_TOTAL;
				this.addElement(this.m_buttons[_loc4_]);
			} else if (_loc4_ < 0) {
				this.addElement(this.m_buttons[_loc4_ + NAV_APP_TOTAL]);
				_loc3_++;
			} else if (_loc4_ >= NAV_APP_TOTAL && _loc3_ < NAV_APP_SHOW_MAX && _loc3_ != -1) {
				_loc4_ -= NAV_APP_TOTAL;
				this.addElement(this.m_buttons[_loc4_]);
				_loc3_++;
			} else {
				this.addElement(this.m_buttons[_loc4_]);
				if (_loc3_ != -1) {
					_loc3_++;
				}
			}
			_loc4_++;
		}
	}

	// NavigationBar.as:289-302（`if(_loc3_)` 对象真值 → 判 null）
	private function supermarketMove(param1:Event):Void {
		var _loc2_:MovieClip = cast(this.getChildByName("__supermarketarrow__"), MovieClip);
		var _loc3_:Dynamic = this.content.getChildByName("supermarket");
		if (_loc3_ != null) {
			// PORT-NOTE 同 onScrollBar：x/y 裸读在 js/eval 恒 undefined
			// （NaN 漂移）——(: DisplayObject) 强类型读
			_loc2_.x = (_loc3_ : DisplayObject).x + 35;
			_loc2_.y = (_loc3_ : DisplayObject).y + 30;
		} else {
			this.removeSupermarketTip();
		}
	}

	// NavigationBar.as:304-311
	public function currentUserChanged():Void {
		var _loc1_:Session = Session.getInstance();
		if (_loc1_.host != null) {
			// 原版 `pf2 || _pf`（Boolean||int）的值进 enabled:Boolean 槽位：
			// As3.or 保原值、truthy 复刻槽位强转后的真值
			this.m_buttons[NAV_MC].enabled = As3.truthy(As3.or(_loc1_.host.pf2, _loc1_.host._pf));
		}
	}

	// NavigationBar.as:313-377
	private function buttonClickHandler(param1:MouseEvent):Void {
		var _loc3_:String = null;
		var _loc4_:String = null;
		var _loc5_:ViewEvent = null;
		// PORT-NOTE 同 onScrollBar：.name 强类型读（裸读恒 undefined，所有导航
		// 按钮会落进 default CHILD_CLICK 分支）
		var _loc2_:String = (param1.currentTarget : DisplayObject).name;
		if (_loc2_ == "mc") {
			this.m_controller.module.app.dispatchEvent(new CommonEvent(Consts.MSG_ENTER_MC, 0));
			UserActionRecorder.recordAction(UserActionRecorder.HF_MYPASTURE_CLICKED);
			ClickReportManager.reportClick("up.banner.icon_pasture.click");
		} else if (_loc2_ == "mill") {
			QzoneJSAPI.toApp(376, "");
			UserActionRecorder.recordAction(UserActionRecorder.HF_MYMILL_CLICKED);
		} else if (_loc2_ == "restaurant") {
			QzoneJSAPI.toApp(Consts.RESTAURANT_APPID, "");
			UserActionRecorder.recordAction(UserActionRecorder.HF_MYRESTAURANT_CLICKED);
			ClickReportManager.reportClick("up.banner.icon_restaurant.click");
		} else if (_loc2_ == "supermarket") {
			// currentFrame 真属性经强类型化（ctor PORT-NOTE 同款）
			if ((cast(this.m_buttons[NAV_SUPERMARKET], MovieClip)).currentFrame == 2) {
				_loc4_ = "";
				if (As3.parseInt(Settings.getInstance().getStringAttribute("QQSuperMarketVip")) > 0) {
					_loc4_ = "VIP Lv" + Settings.getInstance().getStringAttribute("QQSuperMarketVip") + "及以上的用户";
				} else {
					_loc4_ = Settings.getInstance().getStringAttribute("QQSuperMarketLvl") + "级及以上的用户和VIP用户";
				}
				_loc3_ = "<br/><p align='center'><font size='12'>" + "农场QQ超市入口暂时只对" + _loc4_ + "点亮！其他用户请通过空间应用中心进入游戏。" + "</font></p><br/><br/>";
				this.m_controller.openWindow(Consts.WINDOW_NAME_ALERT, {
					"title": "QQ超市",
					"type": Consts.ALERT_TYPE_TEXT,
					"text": _loc3_,
					"width": 350,
					"height": 190
				});
			} else {
				if (Settings.getInstance().getStringAttribute("pgvClickEnable").toString() == "1") {
					EventRecorder.pgvSendClick(EventRecorder.PGVID_TOSUPERMARKET);
				}
				QzoneJSAPI.toApp(21641, "fromapp=353&via=QQ.SHOP.FROMFARM");
				ClickReportManager.reportClick("up.banner.icon_market.click");
			}
		} else {
			_loc5_ = new ViewEvent(ViewEvent.CHILD_CLICK);
			_loc5_.data = {
				"target": param1.currentTarget,
				"name": _loc2_
			};
			this.dispatchEvent(_loc5_);
		}
	}

	// NavigationBar.as:379-402
	private function toolRollOver(param1:MouseEvent):Void {
		var _loc2_:Int = 0;
		if (param1 != null && param1.target != null) {
			// tipText 经 ClipProps（写点在本类 ctor，cpp 上 Reflect 只见物理字段）
			if (ClipProps.has(param1.currentTarget, "tipText") && ClipProps.get(param1.currentTarget, "tipText") != "") {
				this.m_controller.showTip(Consts.TIP_NAME_MOUSE, ClipProps.get(param1.currentTarget, "tipText"));
			} else {
				_loc2_ = 0;
				while (_loc2_ < this.NAV_MAX) {
					// PORT-NOTE 同 onScrollBar：.name 强类型读
					if ((param1.target : DisplayObject).name == this.BUTTONS_NAME[_loc2_]) {
						this.m_controller.showTip(Consts.TIP_NAME_MOUSE, cast(this.BUTTONS_TIP[_loc2_], String));
						break;
					}
					_loc2_++;
				}
			}
		}
	}

	// NavigationBar.as:404-433（addIcon：FFDec 把参数拷进 url/name/tip 局部供
	// requestFile 回调闭包捕获，照抄）
	public function addIcon(param1:String, param2:String, param3:String):Void {
		var url:String = param1;
		var name:String = param2;
		var tip:String = param3;
		this.BUTTONS_NAME.push(name);
		this.BUTTONS_TIP.push(tip);
		this.NAV_MAX = this.BUTTONS_TIP.length;
		CommonData.rslManager.requestFile(url, function(param1:Dynamic):Void {
			var _loc3_:Sprite = null;
			var _loc2_:DisplayObject = cast(param1, DisplayObject);
			if (_loc2_ != null) {
				_loc2_.x = _loc2_.y = 0;
				_loc3_ = new Sprite();
				_loc3_.name = name;
				_loc3_.mouseChildren = false;
				_loc3_.buttonMode = true;
				_loc3_.addEventListener(MouseEvent.CLICK, buttonClickHandler);
				_loc3_.addEventListener(MouseEvent.ROLL_OVER, toolRollOver);
				_loc3_.addEventListener(MouseEvent.ROLL_OUT, toolRollOut);
				_loc3_.addChild(_loc2_);
				m_buttons.push(_loc3_);
				addElement(_loc3_);
				width = 480;
				adjustPosition();
			}
		});
	}
}
