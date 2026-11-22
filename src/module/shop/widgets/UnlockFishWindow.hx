package module.shop.widgets;

import com.qzone.qui.styles.Style;
import com.qzone.utils.AlignUtil;
import common.Consts;
import common.misc.Utils;
import common.view.MaterialProxy;
import common.view.MaterialProxyBig;
import common.view.window.BaseWindow;
import entities.ShopFish;
import framework.api.beast.BeastAPI;
import interfaces.IMsgCenter;
import module.GameGuide;
import module.shop.ShopView;
import openfl.display.DisplayObject;
import openfl.display.InteractiveObject;
import openfl.display.MovieClip;
import openfl.events.MouseEvent;
import openfl.text.TextField;
import shim.As3;

/**
 * module.shop.widgets.UnlockFishWindow —— UnlockFishWindow.as 逐句对应
 * （issue #35 功能 swf 翻译：商店）。鱼苗解锁窗：FishUnlockBg 符号的具名
 * 子件（fishName/fishDetail/unlockBtn/crystalBg/goldBg/lvlBg …）经
 * As3.childOf 取出再读写（swf 动态子件规则）。
 *
 * PORT-NOTE: onMaterialCrystalOver/onUnlockFishSuccess 的水晶分支读
 * BeastAPI.iniData 上的 E4X（xml.crystal.info.(@id==…).@name）。本部署该
 * 数据不可达：beast 配置随牧场片翻译（BeastAPI.hx 仍是闭包 stub，
 * iniData 保持 Dynamic 存取），且 unlock 回包（cgi_fish_unlock.php）只含
 * code/n/n/fid/money、无水晶字段。E4X 无 Haxe 对应物，按首个匹配
 * crystal/info 的 id 属性等价遍历（haxe.xml）；iniData 未装载时守卫为
 * 空跳过（原版此处会 NPE，但原版部署里 beast 配置必然已装载——差异仅在
 * 移植版未装载这一不可达状态）。
 */
class UnlockFishWindow extends BaseWindow {
	// UnlockFishWindow.as:9
	private var _materialGold:MaterialProxy;

	// UnlockFishWindow.as:11
	private var _parent:ShopView;

	// UnlockFishWindow.as:13
	private var _material:MaterialProxyBig;

	// UnlockFishWindow.as:15
	private var _materialCrystal:MaterialProxy;

	// UnlockFishWindow.as:17
	private var _shopFishUnlockBg:MovieClip;

	// UnlockFishWindow.as:19
	private var _materialLvl:MaterialProxy;

	// UnlockFishWindow.as:21-31
	public function new(param1:ShopView) {
		super(Std.isOfType(param1.controller.module.app, IMsgCenter) ? cast(param1.controller.module.app, IMsgCenter) : null);
		width = 390;
		height = 320;
		title = "解锁";
		windowName = Consts.WINDOW_NAME_UNLOCKFISH;
		mode = true;
		this._parent = param1;
	}

	// UnlockFishWindow.as:33-40
	private function onMaterialGoldOver(param1:MouseEvent):Void {
		var _loc2_:ShopFish = Std.isOfType(this.data, ShopFish) ? cast(this.data, ShopFish) : null;
		if (_loc2_._lock_gold > 0) {
			this._parent.controller.showTip(Consts.TIP_NAME_MOUSE, "金币");
		}
	}

	// UnlockFishWindow.as:42-46
	override private function setSize():Void {
		super.setSize();
		panelTitle.x = AlignUtil.middle(_width, panelTitle.width);
	}

	// UnlockFishWindow.as:48-92
	override private function setData():Void {
		this.graphics.clear();
		this._materialCrystal.visible = false;
		this._materialGold.visible = false;
		cast(As3.childOf(this._shopFishUnlockBg, "crystalBg"), DisplayObject).visible = false;
		cast(As3.childOf(this._shopFishUnlockBg, "crystalText"), TextField).htmlText = "";
		cast(As3.childOf(this._shopFishUnlockBg, "goldBg"), DisplayObject).visible = false;
		cast(As3.childOf(this._shopFishUnlockBg, "goldText"), TextField).htmlText = "";
		if (this.isInit == false) {
			return;
		}
		var _loc1_:ShopFish = Std.isOfType(this.data, ShopFish) ? cast(this.data, ShopFish) : null;
		if (_loc1_ == null) {
			return;
		}
		if (_loc1_._lock == 0) {
			cast(As3.childOf(this._shopFishUnlockBg, "unlockBtn"), DisplayObject).filters = cast Style.getDisableFilter();
		} else {
			cast(As3.childOf(this._shopFishUnlockBg, "unlockBtn"), DisplayObject).filters = null;
		}
		cast(As3.childOf(this._shopFishUnlockBg, "fishName"), TextField).htmlText = _loc1_._name;
		cast(As3.childOf(this._shopFishUnlockBg, "fishDetail"), TextField).htmlText = this.buildContent();
		this._material.setContent(Consts.ITEM_TYPE_FISH, _loc1_._id);
		var _loc2_:Array<Dynamic> = _loc1_._lock_crystal.split(",");
		if (_loc2_.length > 0 && As3.intOf(_loc2_[1]) > 0) {
			this._materialCrystal.visible = true;
			this._materialCrystal.setContent(Consts.ITEM_TYPE_CRYSTAL, As3.intOf(_loc2_[0]));
			cast(As3.childOf(this._shopFishUnlockBg, "crystalBg"), DisplayObject).visible = true;
			cast(As3.childOf(this._shopFishUnlockBg, "crystalText"), TextField).htmlText = Std.string(_loc2_[1]);
		}
		if (_loc1_._lock_gold > 0) {
			this._materialGold.visible = true;
			this._materialGold.setContent(Consts.ITEM_TYPE_MONEY, 0);
			cast(As3.childOf(this._shopFishUnlockBg, "goldBg"), DisplayObject).visible = true;
			cast(As3.childOf(this._shopFishUnlockBg, "goldText"), TextField).htmlText = Std.string(_loc1_._lock_gold);
		}
		GameGuide.instance().showStep(GameGuide.WATER_UNLOCK_FISH);
		GameGuide.instance().autoHide(5);
	}

	// UnlockFishWindow.as:94-97
	private function onMaterialOut(param1:MouseEvent):Void {
		this._parent.controller.hideTip();
	}

	// UnlockFishWindow.as:99-108
	private function onUnlock(param1:MouseEvent):Void {
		var _loc2_:ShopFish = Std.isOfType(this.data, ShopFish) ? cast(this.data, ShopFish) : null;
		if (_loc2_._lock != 2) {
			return;
		}
		this._parent.controller.model.unlockFish(_loc2_._id);
		this.close();
	}

	// UnlockFishWindow.as:110-127
	private function buildContent():String {
		var _loc1_:String = "";
		var _loc2_:ShopFish = Std.isOfType(this.data, ShopFish) ? cast(this.data, ShopFish) : null;
		if (_loc2_ == null) {
			return _loc1_;
		}
		_loc1_ += "成熟时间：<font color=\"#0099FF\">" + Std.string(_loc2_._mature) + "</font> 小时";
		_loc1_ += "<br>鱼苗售价：<font color=\"#CC3300\">金币</font><font color=\"#FF6600\">" + Std.string(_loc2_._price)
			+ "</font>";
		_loc1_ += "<br>收获经验：<font color=\"#0099FF\">" + Std.string(_loc2_._exp) + "</font>";
		return _loc1_ + ("<br>占用容量：<font color=\"#FF6600\">" + Std.string(_loc2_._pool_size) + "</font>");
	}

	// UnlockFishWindow.as:129-148（E4X 水晶名查询，见类头 PORT-NOTE）
	private function onMaterialCrystalOver(param1:MouseEvent):Void {
		var crystalName:String = null;
		var e:MouseEvent = param1;
		var fish:ShopFish = Std.isOfType(this.data, ShopFish) ? cast(this.data, ShopFish) : null;
		var unlockCrystal:Array<Dynamic> = fish._lock_crystal.split(",");
		if (unlockCrystal.length > 0 && As3.intOf(unlockCrystal[1]) > 0) {
			var xml:Xml = cast BeastAPI.getInstance().iniData;
			if (xml != null) {
				for (crystal in xml.elementsNamed("crystal")) {
					for (info in crystal.elementsNamed("info")) {
						if (info.get("id") == unlockCrystal[0]) {
							crystalName = info.get("name");
							break;
						}
					}
				}
			}
			this._parent.controller.showTip(Consts.TIP_NAME_MOUSE, crystalName);
		}
	}

	// UnlockFishWindow.as:150-183
	override private function addedToLayer():Void {
		super.addedToLayer();
		this._material = new MaterialProxyBig();
		this._material.x = 29;
		this._material.y = 40;
		addChild(this._material);
		this._shopFishUnlockBg = Std.isOfType(Utils.getMaterial("FishUnlockBg"), MovieClip)
			? cast(Utils.getMaterial("FishUnlockBg"), MovieClip) : null;
		this._shopFishUnlockBg.x = 29;
		this._shopFishUnlockBg.y = 170;
		addChild(this._shopFishUnlockBg);
		this._materialCrystal = new MaterialProxy();
		this._materialCrystal.x = 119;
		this._materialCrystal.y = 209;
		addChild(this._materialCrystal);
		this._materialGold = new MaterialProxy();
		this._materialGold.x = 49;
		this._materialGold.y = 209;
		addChild(this._materialGold);
		cast(As3.childOf(this._shopFishUnlockBg, "unlockBtn"), InteractiveObject).addEventListener(MouseEvent.CLICK, this.onUnlock);
		cast(As3.childOf(this._shopFishUnlockBg, "goldBg"), DisplayObject).visible = false;
		cast(As3.childOf(this._shopFishUnlockBg, "crystalBg"), DisplayObject).visible = false;
		cast(As3.childOf(this._shopFishUnlockBg, "lvlBg"), DisplayObject).visible = false;
		cast(As3.childOf(this._shopFishUnlockBg, "crystalText"), TextField).htmlText = "";
		cast(As3.childOf(this._shopFishUnlockBg, "goldText"), TextField).htmlText = "";
		cast(As3.childOf(this._shopFishUnlockBg, "lvlText"), TextField).htmlText = "";
		this._materialCrystal.addEventListener(MouseEvent.ROLL_OVER, this.onMaterialCrystalOver);
		this._materialGold.addEventListener(MouseEvent.ROLL_OVER, this.onMaterialGoldOver);
		this._materialCrystal.addEventListener(MouseEvent.ROLL_OUT, this.onMaterialOut);
		this._materialGold.addEventListener(MouseEvent.ROLL_OUT, this.onMaterialOut);
	}

	// UnlockFishWindow.as:185-189
	override private function close():Void {
		super.close();
		GameGuide.instance().hide();
	}
}
