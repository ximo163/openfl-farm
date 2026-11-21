package module.friend;

import com.qzone.allianceActivity.AllianceActivityManager;
import com.qzone.allianceActivity.interfaces.IAllianceActivityContext;
import com.qzone.farm.api.interfaces.IPluginProxy;
import com.qzone.qui.makers.ButtonMaker;
import com.qzone.utils.StringUtil;
import common.CommonData;
import common.Session;
import common.Settings;
import common.misc.Cookies;
import common.misc.QzoneJSAPI;
import common.misc.Utils;
import entities.Friend;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.DisplayObject;
import openfl.display.DisplayObjectContainer;
import openfl.display.Graphics;
import openfl.display.Loader;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.events.TimerEvent;
import openfl.geom.Matrix;
import openfl.net.URLRequest;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.utils.Timer;
import framework.api.PluginManager;
import shim.As3;
import shim.ClipProps;
import shim.QQOutlets;

/**
 * module.friend.FriendItemRender —— FriendItemRender.as（728 loc）逐句对应。
 * 好友列表单行渲染（头像/昵称/等级/黄钻标/状态角标/牧场按钮/图鉴角标）。
 * status_mc["s_name"] 是素材剪辑上的动态属性（AS3 Sprite 实为 MovieClip、
 * dynamic 挂写）：读写走 shim.ClipProps 同一通道（FriendsView 读同键）。
 */
class FriendItemRender extends Sprite {
	// FriendItemRender.as:32-77（原版 private var 区，照抄字段序与默认值）
	private var status_mc:Sprite;
	private var _friendData:Friend = null;
	private var _selected:Bool = false;
	private var statusIcon:Sprite;
	private var _vipLevelMaterial:String = "VipL";
	private var vip:Sprite;
	private var _isme:Bool = false;
	private var _preMode:Bool;
	private var mc_btn:Sprite;
	private var highlight:Sprite;
	private var _tjTimer:Timer;
	private var _preTimer:Timer;
	private var _vipLevel:Int = 0;
	private var leveBg:Sprite;
	private var listItem:Sprite;
	private var _icon:String;
	private var userIcon:Sprite;
	private var _preTime:Int;
	private var leve:TextField;
	private var _vipStatus:Int = 0;
	private var userName:TextField;
	private var _userLevel:Int = 0;

	// AS3 get/set 对（原文公共存取器；Haxe 属性字段 + private get_/set_）
	public var fiendData(get, set):Friend;
	public var preTime(get, never):Int;
	public var userlevel(get, set):Int;
	public var user(get, set):String;
	public var selected(never, set):UInt;
	public var tujian(get, never):Int;
	public var isMe(get, set):Bool;
	public var levelBg(never, set):BitmapData;
	public var vipLevel(get, set):Int;
	public var vipStatus(get, set):Int;
	public var preMode(get, never):Bool;
	public var icon(get, set):String;

	// FriendItemRender.as:79-102
	public function new() {
		super();
		this.buttonMode = true;
		this.listItem = cast(Utils.getMaterial("List_Item"), Sprite);
		this.highlight = cast(this.listItem.getChildByName("highLight_mc"), Sprite);
		this.userName = cast(this.listItem.getChildByName("name_txt"), TextField);
		this.userIcon = cast(this.listItem.getChildByName("head_mc"), Sprite);
		this.leve = cast(this.listItem.getChildByName("level_txt"), TextField);
		this.leveBg = cast(this.listItem.getChildByName("level_mc"), Sprite);
		this.vip = cast(this.listItem.getChildByName("vip_mc"), Sprite);
		this.status_mc = cast(this.listItem.getChildByName("status_mc"), Sprite);
		this.mc_btn = cast(this.listItem.getChildByName("mc_btn"), Sprite);
		ButtonMaker.addTarget(this.mc_btn);
		this.highlight.mouseEnabled = false;
		this.leveBg.mouseEnabled = false;
		this.userIcon.mouseEnabled = false;
		this.userIcon.mouseChildren = false;
		this.leve.mouseEnabled = false;
		this.userName.mouseEnabled = false;
		this.userName.selectable = false;
		this.status_mc.mouseChildren = false;
		addChild(this.listItem);
	}

	// FriendItemRender.as:104-110
	public function changBg():Void {
		if(!this._selected) {
			this.highlight.alpha = 0.8;
		}
	}

	// FriendItemRender.as:112-127（["sort"]/["me"] 是 Friend 真字段，直读）
	private function set_fiendData(param1:Friend):Friend {
		this._friendData = param1;
		this.vipLevel = this._friendData._yellowlevel;
		this.vipStatus = this._friendData._yellowstatus;
		this.icon = this._friendData._headPic;
		this.userlevel = this._friendData.sort;
		this.updateStatusFlag();
		this.setMC(0);
		if(this._friendData._userName == "" || this._friendData._userName == null) {
			this._friendData._userName = "农场玩家";
		}
		this.user = this.formatName(this._friendData._userName);
		this.isMe = this._friendData.me;
		return param1;
	}

	// FriendItemRender.as:129-142
	private function drawG(param1:Graphics, param2:BitmapData, param3:Matrix = null):Void {
		param1.clear();
		param1.beginBitmapFill(param2, param3, false, true);
		if(param3 != null) {
			param1.drawRect(0, 0, param2.width * param3.a, param2.height * param3.d);
		} else {
			param1.drawRect(0, 0, param2.width, param2.height);
		}
		param1.endFill();
	}

	// FriendItemRender.as:144-176
	private function onTjTimer(param1:TimerEvent):Void {
		if(this._friendData == null) {
			return;
		}
		var _loc2_:Int = this.tujian;
		if(_loc2_ == 0) {
			return;
		}
		var _loc3_:IAllianceActivityContext = AllianceActivityManager.getInstance().getActivityContext("collecting");
		if(_loc3_ == null) {
			return;
		}
		var _loc4_:BitmapData = cast(_loc3_.execute("10001", _loc2_), BitmapData);
		if(_loc4_ == null) {
			return;
		}
		var _loc5_:Bitmap = new Bitmap(_loc4_, "auto", true);
		_loc5_.scaleX = 0.4;
		_loc5_.scaleY = 0.4;
		var _loc6_:Sprite = new Sprite();
		_loc6_.x = this.mc_btn.x - 2;
		_loc6_.y = this.mc_btn.y - 2;
		_loc6_.name = "tujian";
		_loc6_.mouseChildren = false;
		_loc6_.addChild(_loc5_);
		addChild(_loc6_);
		cast(param1.target, Timer).stop();
	}

	// FriendItemRender.as:178-181
	private function get_fiendData():Friend {
		return this._friendData;
	}

	// FriendItemRender.as:183-189
	public function backBg():Void {
		if(!this._selected) {
			this.highlight.alpha = 0;
		}
	}

	// FriendItemRender.as:191-194
	private function get_preTime():Int {
		return this._preTime;
	}

	// FriendItemRender.as:196-199
	private function get_userlevel():Int {
		return this._userLevel;
	}

	// FriendItemRender.as:201-206
	private function onHeadIconLoaded(param1:Event):Void {
		var _loc2_:Loader = cast(cast(param1.target, openfl.display.LoaderInfo).loader, Loader);
		_loc2_.scaleX = 25 / _loc2_.width;
		_loc2_.scaleY = 25 / _loc2_.height;
	}

	// FriendItemRender.as:208-244
	private function set_user(param1:String):String {
		var i:Int = 0;
		var f:DisplayObject = null;
		var vipDataClass:Class<Dynamic> = null;
		var vipData:BitmapData = null;
		var value:String = param1;
		this.userName.htmlText = StringUtil.htmlEscape(value);
		if(this.vip != null && this.vip.numChildren > 0) {
			i = 0;
			while(i < this.vip.numChildren) {
				f = this.vip.removeChildAt(0);
				f = null;
				i++;
			}
		}
		if(this.vipStatus != 0) {
			try {
				this.vip.y = 10;
				this.vip.x = this.userName.x + this.userName.textWidth + 4;
				vipDataClass = Utils.getClass(this._vipLevelMaterial + this.vipLevel);
				if(vipDataClass != null) {
					// `new vipDataClass(16,13)`：运行期 Class 实例化
					vipData = cast(Type.createInstance(vipDataClass, [16, 13]), BitmapData);
					this.vip.addChild(new Bitmap(vipData));
					addChild(this.vip);
				}
			} catch (e:Dynamic) {
				// 原版 catch(e:Error) 空 catch，照抄
			}
		}
		return param1;
	}

	// FriendItemRender.as:246-413（状态角标主判定：1=成熟可摘 2=浇水 3=除草
	// u=除虫 6=鱼塘 z=召回 7=小仙供奉 pre=将熟计时）
	public function updateStatusFlag():Void {
		var _loc9_:IPluginProxy = null;
		var _loc10_:Int = 0;
		var _loc11_:Int = 0;
		// `delete status_mc["s_name"]`：素材剪辑动态属性，走 ClipProps 通道
		ClipProps.remove(this.status_mc, "s_name");
		if(this.status_mc.numChildren > 0) {
			this.status_mc.removeChildAt(0);
		}
		this._preTime = 0;
		if(this._preTimer != null) {
			this._preTimer.removeEventListener(TimerEvent.TIMER, this.preTimerCom);
			this._preTimer.stop();
			this._preTimer = null;
		}
		var _loc1_:Int = Std.int(this._friendData._uId);
		var _loc2_:Bool = Settings.isQZoneUinMode;
		if(_loc2_ == true) {
			_loc1_ = Std.int(this._friendData._uin);
		}
		var _loc3_:String = Settings.getInstance().getStringAttribute("preYellowlevel");
		if(_loc3_ == "") {
			_loc3_ = "7";
		}
		// `parseInt(_loc3_)`：int >= Number 比较，NaN 恒假（照抄）
		if(Session.getInstance().host._yellowlevel >= As3.parseInt(_loc3_)) {
			this._preMode = true;
		}
		if(this._friendData.status == "") {
			return;
		}
		var _loc4_:Dynamic = this._friendData.status;
		if(_loc4_ == null) {
			return;
		}
		var _loc5_:Float = As3.floatOf(CommonData.serverTime);
		var _loc6_:Bool = this._friendData.me;
		var _loc7_:Class<Dynamic> = null;
		var _loc8_:Bool = false;
		if(As3.hasProp(_loc4_, "7") && _loc6_ == false && QzoneJSAPI.QPLUS == false && QzoneJSAPI.WB == false) {
			_loc9_ = PluginManager.getInstance().getPluginByID(2);
			// `executeCommand(2101,..) == true`：松散相等即 Boolean(x)
			if(_loc9_ != null && As3.truthy(_loc9_.executeCommand(2101, _loc1_))) {
				_loc7_ = cast(_loc9_.executeCommand(2102, null), Class<Dynamic>);
				ClipProps.set(this.status_mc, "s_name", "Status_7");
			}
		}
		if(Settings.getInstance().openZhaoHui() && QzoneJSAPI.QPLUS == false && QzoneJSAPI.WB == false) {
			if(CommonData.BackHandTimeIsToday(_loc1_) == false) {
				Cookies.setObject("z_" + _loc1_, null);
				// `["5"] == 1 || ["5"] == true`：松散相等下两支同义（bool/1/"1"
				// 全过），floatOf==1 等价覆盖（同 FriendsModel.updateLandsStatus）
				if(As3.floatOf(Reflect.field(_loc4_, "5")) == 1) {
					_loc7_ = Utils.getClass("Status_z");
					ClipProps.set(this.status_mc, "s_name", "Status_z");
				}
			}
		}
		if(_loc7_ == null) {
			if(Std.isOfType(Reflect.field(_loc4_, "1"), Bool)) {
				if(Reflect.field(_loc4_, "1") == true) {
					_loc7_ = Utils.getClass("Status_1");
				}
			} else {
				// int 收 parseInt 结果：AS3 int(NaN)=0
				_loc10_ = As3.intOf(As3.parseInt(Reflect.field(_loc4_, "1")));
				var _locT_:Dynamic = Cookies.getObject("t_" + _loc1_);
				// AS3 松散相等 Number 对 null：null 转 0（不是 NaN）
				if(_locT_ == null ? _loc10_ != 0 : As3.floatOf(_locT_) != _loc10_) {
					if(this._preMode == true && (_loc10_ > _loc5_ && _loc10_ <= 600 + _loc5_)) {
						_loc8_ = true;
						if(this._preTimer == null) {
							this._preTimer = new Timer(Std.int((_loc10_ - _loc5_) * 1000), 1);
							this._preTime = _loc10_;
							this._preTimer.addEventListener(TimerEvent.TIMER, this.preTimerCom, false, 0, true);
							this._preTimer.start();
						}
					} else if(_loc10_ > 0 && _loc10_ <= _loc5_) {
						_loc7_ = Utils.getClass("Status_1");
					}
				}
			}
		}
		if(_loc7_ == null) {
			// `["6"] as Boolean == true`：as 只放行真 Boolean，其余 null==true 假
			var _loc6v_:Dynamic = Reflect.field(_loc4_, "6");
			if(Std.isOfType(_loc6v_, Bool) && _loc6v_ == true) {
				_loc7_ = Utils.getClass("Status_6");
				ClipProps.set(this.status_mc, "s_name", "Status_6");
			}
		}
		if(_loc7_ == null) {
			if(Std.isOfType(Reflect.field(_loc4_, "4"), Bool)) {
				if(Reflect.field(_loc4_, "4") == true) {
					_loc7_ = Utils.getClass("Status_u");
				}
			} else {
				// `["4"] as int`：数值截断、其余（含字符串）落 null→0
				var _loc4v_:Dynamic = Reflect.field(_loc4_, "4");
				_loc11_ = (Std.isOfType(_loc4v_, Int) || Std.isOfType(_loc4v_, Float)) ? As3.intOf(_loc4v_) : 0;
				var _locU_:Dynamic = Cookies.getObject("u_" + _loc1_);
				// AS3 关系比较 Number 对 null：null 转 0（先落 Float 局部，
				// 免得期望类型把三元另一支压成 Int）
				var _locUn_:Float = _locU_ == null ? 0 : As3.floatOf(_locU_);
				if(_loc11_ > _locUn_) {
					if(_loc11_ > 0 && _loc11_ >= _loc5_) {
						_loc7_ = Utils.getClass("Status_u");
						ClipProps.set(this.status_mc, "s_name", "Status_u");
					}
				}
			}
		}
		if(_loc7_ == null) {
			// `["2"] === 1 || ["2"] === true`：严格相等只认数值 1 与真 true
			var _loc2v_:Dynamic = Reflect.field(_loc4_, "2");
			if(((Std.isOfType(_loc2v_, Int) || Std.isOfType(_loc2v_, Float)) && _loc2v_ == 1)
				|| (Std.isOfType(_loc2v_, Bool) && _loc2v_ == true)) {
				_loc7_ = Utils.getClass("Status_2");
			} else {
				var _loc3v_:Dynamic = Reflect.field(_loc4_, "3");
				if(((Std.isOfType(_loc3v_, Int) || Std.isOfType(_loc3v_, Float)) && _loc3v_ == 1)
					|| (Std.isOfType(_loc3v_, Bool) && _loc3v_ == true)) {
					_loc7_ = Utils.getClass("Status_3");
				}
			}
		}
		if(_loc8_ == true && _loc7_ == null) {
			_loc7_ = Utils.getClass("Status_pre");
		}
		if(_loc7_ != null) {
			if(this.statusIcon != null && this.status_mc.contains(this.statusIcon)) {
				this.status_mc.removeChild(this.statusIcon);
			}
			// `new _loc7_()`：运行期 Class 实例化
			this.statusIcon = cast(Type.createInstance(_loc7_, []), Sprite);
			if(this.statusIcon != null && this.status_mc != null && ClipProps.get(this.status_mc, "s_name") == "Status_7") {
				this.statusIcon.scaleX = 20 / this.statusIcon.width;
				this.statusIcon.scaleY = 20 / this.statusIcon.height;
				this.statusIcon.x = -6;
				this.statusIcon.y = -3;
			}
			this.status_mc.addChild(this.statusIcon);
		}
		// `["8"] != undefined && ["8"] > 0`：hasProp 门 + Number 关系比较
		if(As3.hasProp(_loc4_, "8") && As3.floatOf(Reflect.field(_loc4_, "8")) > 0 && QzoneJSAPI.WB == false
			&& QzoneJSAPI.QPLUS == false) {
			this.setMC(As3.intOf(Reflect.field(_loc4_, "8")));
		} else {
			this.setMC(0);
		}
	}

	// FriendItemRender.as:415-456
	private function formatName(param1:String):String {
		var _loc4_:Int = 0;
		var _loc5_:Int = 0;
		var _loc6_:String = null;
		var _loc7_:Int = 0;
		var _loc2_:String = param1;
		var _loc3_:Int = param1.length;
		if(_loc3_ > 7) {
			return param1.substr(0, 7) + "..";
		}
		if(_loc3_ > 4) {
			_loc4_ = 0;
			_loc5_ = 0;
			_loc6_ = "";
			_loc7_ = 0;
			while(_loc7_ < _loc3_) {
				if(param1.charCodeAt(_loc7_) > 255) {
					_loc4_ += 1;
				} else {
					_loc5_ += 1;
				}
				if(_loc4_ + _loc5_ / 2 > 4) {
					break;
				}
				_loc6_ += param1.charAt(_loc7_);
				_loc7_++;
			}
			if(_loc4_ + _loc5_ / 2 > 4) {
				_loc2_ = _loc6_ + "..";
			}
		}
		return _loc2_;
	}

	// FriendItemRender.as:458-470
	private function set_selected(param1:UInt):UInt {
		if(param1 == this._friendData._uId) {
			this._selected = true;
			this.highlight.alpha = 0.8;
		} else {
			this._selected = false;
			this.highlight.alpha = 0;
		}
		return param1;
	}

	// FriendItemRender.as:472-519
	private function set_userlevel(param1:Int):Int {
		this._userLevel = param1;
		this.leve.text = Std.string(param1);
		var _loc2_:Int = 39423;
		if(this.isMe) {
			_loc2_ = 13369344;
		}
		if(param1 < 10) {
			if(param1 <= 3) {
				_loc2_ = 16777215;
				if(this.isMe) {
					_loc2_ = 13369344;
				}
				this.leve.setTextFormat(new TextFormat("embedFontA", 16, _loc2_, true));
			} else {
				this.leve.setTextFormat(new TextFormat("embedFontA", 16, _loc2_, true));
			}
			this.leve.y = 5;
		} else if(param1 >= 10 && param1 < 100) {
			this.leve.setTextFormat(new TextFormat("embedFontA", 13, _loc2_, true));
			this.leve.y = 7;
		} else if(param1 >= 100 && param1 < 1000) {
			this.leve.setTextFormat(new TextFormat("embedFontA", 10, _loc2_, true));
			this.leve.y = 8;
		} else if(param1 >= 1000 && param1 < 10000) {
			this.leve.setTextFormat(new TextFormat("embedFontA", 8, _loc2_, false));
			this.leve.y = 9;
		} else {
			this.leve.setTextFormat(new TextFormat("embedFontA", 6, _loc2_, false));
			this.leve.y = 10;
		}
		this.leve.embedFonts = true;
		return param1;
	}

	// FriendItemRender.as:521-533（int 返回形按 AS3 int() 收值）
	private function get_tujian():Int {
		var _loc1_:Dynamic = null;
		if(this._friendData != null) {
			_loc1_ = this._friendData.status;
			if(_loc1_ != null && As3.hasProp(_loc1_, "8")) {
				return As3.intOf(Reflect.field(_loc1_, "8"));
			}
		}
		return 0;
	}

	// FriendItemRender.as:535-538
	private function preTimerCom(param1:Event):Void {
		this.updateStatusFlag();
	}

	// FriendItemRender.as:540-553
	private function set_isMe(param1:Bool):Bool {
		this._isme = param1;
		if(this._isme) {
			this.userName.setTextFormat(new TextFormat("Verdana", 12, 13369344));
			this.userlevel = this._userLevel;
		} else {
			this.userName.setTextFormat(new TextFormat("Verdana", 12, 3355443));
			this.userlevel = this._userLevel;
		}
		return param1;
	}

	// FriendItemRender.as:555-563
	private function set_levelBg(param1:BitmapData):BitmapData {
		if(param1 != null) {
			this.drawG(this.leveBg.graphics, param1);
			this.leveBg.width = param1.width;
			this.leveBg.height = param1.height;
		}
		return param1;
	}

	// FriendItemRender.as:565-572
	public function clear():Void {
		if(this._preTimer != null) {
			this._preTimer.stop();
			this._preTimer = null;
		}
	}

	// FriendItemRender.as:574-577
	private function set_vipLevel(param1:Int):Int {
		this._vipLevel = param1;
		return param1;
	}

	// FriendItemRender.as:579-582
	private function get_user():String {
		return this.userName.text;
	}

	// FriendItemRender.as:584-593
	private function onHeadIconLoadFailed(param1:IOErrorEvent):Void {
		var _loc2_:Int = 0;
		this.userIcon.graphics.clear();
		while(_loc2_ < this.userIcon.numChildren) {
			this.userIcon.removeChildAt(0);
			_loc2_++;
		}
	}

	// FriendItemRender.as:595-598
	private function set_vipStatus(param1:Int):Int {
		this._vipStatus = param1;
		return param1;
	}

	// FriendItemRender.as:600-606
	public function updateIcon():Void {
		if(this._friendData != null) {
			this.icon = this._friendData._headPic;
		}
	}

	// FriendItemRender.as:608-613
	public function setGray():Void {
		this.userName.setTextFormat(new TextFormat("Verdana", 12, 11184810));
		this.userIcon.alpha = 0.5;
		this.leveBg.alpha = 0.5;
	}

	// FriendItemRender.as:615-618
	private function get_preMode():Bool {
		return this._preMode;
	}

	// FriendItemRender.as:620-623
	private function get_vipLevel():Int {
		return this._vipLevel;
	}

	// FriendItemRender.as:625-628
	private function get_isMe():Bool {
		return this._isme;
	}

	// FriendItemRender.as:630-671
	private function set_icon(param1:String):String {
		if(this.userIcon == null) {
			return param1;
		}
		this.userIcon.graphics.clear();
		var _loc2_:DisplayObject = null;
		while(this.userIcon.numChildren > 0) {
			_loc2_ = this.userIcon.removeChildAt(0);
			if(_loc2_ != null && _loc2_.loaderInfo != null && _loc2_.loaderInfo.loader != null) {
				// 原版 hasOwnProperty("unloadAndStop")：js 上 Reflect.hasField
				// 不见原型方法，As3.hasProp 兜底（openfl Loader 有该方法）
				if(As3.hasProp(_loc2_.loaderInfo.loader, "unloadAndStop") == true) {
					cast(_loc2_.loaderInfo.loader, Loader).unloadAndStop(true);
				}
			}
		}
		this._icon = param1;
		if(QzoneJSAPI.WB == true) {
			if(this._icon == "" || this._icon == null) {
				this._icon = "http://mat1.gtimg.com/www/mb/images/head_30.jpg";
			} else {
				this._icon += "/30";
			}
		} else if(this._icon == "" || this._icon == null) {
			return param1;
		}
		var _loc3_:Loader = new Loader();
		_loc3_.contentLoaderInfo.addEventListener(Event.COMPLETE, this.onHeadIconLoaded, false, 0, true);
		_loc3_.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, this.onHeadIconLoadFailed, false, 0, true);
		var _loc4_:URLRequest = new URLRequest(this._icon);
		// PORT-NOTE(host-avatar)：原版 `_loc3_.load(_loc4_)` 直连宿主 ucenter
		// 头像服务（headPic 由 user_run.php 下发；快照 UC_API 是参考部署地址，
		// 照发必挂）——出口并入 shim.QQOutlets（PersonInfo 先例，deviations
		// 候选待人登记）；头像取不到 → IOError 吞掉 → 空头像框，与原版跑本
		// 部署包一致
		QQOutlets.loadImage(_loc3_, _loc4_);
		this.userIcon.addChild(_loc3_);
		return param1;
	}

	// FriendItemRender.as:673-700
	private function setMC(param1:Int):Void {
		var _loc2_:DisplayObjectContainer = null;
		this.mc_btn.visible = false;
		if(param1 > 0) {
			if(this._tjTimer == null) {
				this._tjTimer = new Timer(500, 100);
				this._tjTimer.addEventListener(TimerEvent.TIMER, this.onTjTimer, false, 0, true);
				this._tjTimer.start();
			} else {
				this._tjTimer.reset();
				this._tjTimer.start();
			}
		} else {
			_loc2_ = cast(getChildByName("tujian"), DisplayObjectContainer);
			if(_loc2_ != null && contains(_loc2_) == true) {
				removeChild(_loc2_);
				_loc2_ = null;
			}
		}
	}

	// FriendItemRender.as:702-704
	private function get_icon():String {
		return this._icon;
	}

	// FriendItemRender.as:707-714
	public function updateName():Void {
		var _loc1_:String = this._friendData._userName;
		if(_loc1_ != null && _loc1_ != "") {
			this.user = this.formatName(_loc1_);
		}
	}

	// FriendItemRender.as:716-719
	public function isSelected():Bool {
		return this._selected;
	}

	// FriendItemRender.as:721-724
	private function get_vipStatus():Int {
		return this._vipStatus;
	}
}
