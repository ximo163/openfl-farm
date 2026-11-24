import openfl.display.DisplayObject;
import openfl.display.MovieClip;
import openfl.display.Sprite;
import openfl.text.TextField;
import openfl.text.TextFormat;
import shim.As3;
import shim.SymbolClass;

// FarmInfoPlus —— farmui_full_v_40.swf 的 SymbolClass 导出符号（char#184），
// 地块信息提示的版面类，LandInfoTip 经 Utils.getMaterial("FarmInfoPlus")
// 反射构造。类体长在该 swf 的 DoABC2（farmui_full 不在 CI 反编译的五代码
// swf 内，legacy/decompiled 无 FFDec 产物），方法按 ABC 字节码逐句复原
// （tools/DumpAbcMethod.hx retarget 导出；构造器只有 super() +
// addFrameScript(0, frame1) 且 frame1 空体——帧脚本属时间轴胶水，由
// AnimateLibrary 承担，按符号 shim 惯例不译，见 ToolBarBg）。
//
// ABC 字段表：七个具名子件槽（healthText/growText/stepText 文本、bg/bg2/
// healthBar/growBar 图形）由时间轴 PlaceObject 命名填充；seedSprite 是代码
// 建的种子图标宿主。子件不落 Haxe 实例字段——As3.childOf 先走 Reflect.field
// 再 getChildByName，同名字段会挡住时间轴子件查找——方法内用同名局部变量
// 取出（As3.childOf 对 this 上不存在的名字落到 getChildByName）。
//
// 调用方（LandInfoTip.onFarmTimer）setOutput/setStep7 少传尾部图标参数：
// AS3 落 undefined（OToBool 假，图标由 requestClass 回调另行 setInfoIcon/
// setOutputIcon 补挂），Haxe 以 = null 默认参同形。
@:keep
class FarmInfoPlus extends MovieClip {
	// ABC FVar seedSprite（三个 set* 里懒建）
	private var seedSprite:Sprite;

	public function new() {
		super();
		SymbolClass.bind(this, "farmui_full_v_40", "FarmInfoPlus");
	}

	// ABC setInfo（生长中：健康条/生长条/三文本全显；bar 宽 = 比例 * 120）
	public function setInfo(param1:Float, param2:String, param3:Float, param4:String, param5:String, param6:DisplayObject = null):Void {
		var healthText:TextField = cast(As3.childOf(this, "healthText"), TextField);
		var growText:TextField = cast(As3.childOf(this, "growText"), TextField);
		var stepText:TextField = cast(As3.childOf(this, "stepText"), TextField);
		var healthBar:DisplayObject = cast(As3.childOf(this, "healthBar"), DisplayObject);
		var growBar:DisplayObject = cast(As3.childOf(this, "growBar"), DisplayObject);
		var bg:DisplayObject = cast(As3.childOf(this, "bg"), DisplayObject);
		var bg2:DisplayObject = cast(As3.childOf(this, "bg2"), DisplayObject);
		healthText.visible = true;
		healthBar.visible = true;
		bg.visible = true;
		bg2.visible = true;
		growBar.visible = true;
		growText.visible = true;
		if (this.seedSprite == null) {
			this.seedSprite = new Sprite();
			addChild(this.seedSprite);
		}
		// `stepText.defaultTextFormat = growText.defaultTextFormat =
		//  healthText.defaultTextFormat = new TextFormat(...)`：同一实例链式
		// 三落（字节码 ODup/OSetReg 链）
		var _fmt:TextFormat = new TextFormat("Tahoma", 12, 3355443);
		healthText.defaultTextFormat = _fmt;
		growText.defaultTextFormat = _fmt;
		stepText.defaultTextFormat = _fmt;
		healthBar.width = param1 * 120;
		growBar.width = param3 * 120;
		healthText.text = param2;
		growText.htmlText = "<font size=\"12\" face=\"Tahoma\">" + param4 + "</font>";
		stepText.text = param5;
		stepText.y = 0;
		this.setInfoIcon(param6);
	}

	// ABC setStep7（枯死：六子件全隐只剩标题，标题行落 healthText 行 +10）
	public function setStep7(param1:String, param2:DisplayObject = null):Void {
		var healthText:TextField = cast(As3.childOf(this, "healthText"), TextField);
		var growText:TextField = cast(As3.childOf(this, "growText"), TextField);
		var stepText:TextField = cast(As3.childOf(this, "stepText"), TextField);
		healthText.visible = false;
		var healthBar:DisplayObject = cast(As3.childOf(this, "healthBar"), DisplayObject);
		healthBar.visible = false;
		var bg:DisplayObject = cast(As3.childOf(this, "bg"), DisplayObject);
		bg.visible = false;
		var bg2:DisplayObject = cast(As3.childOf(this, "bg2"), DisplayObject);
		bg2.visible = false;
		var growBar:DisplayObject = cast(As3.childOf(this, "growBar"), DisplayObject);
		growBar.visible = false;
		growText.visible = false;
		if (this.seedSprite == null) {
			this.seedSprite = new Sprite();
			addChild(this.seedSprite);
		}
		var _fmt:TextFormat = new TextFormat("Tahoma", 12, 3355443);
		healthText.defaultTextFormat = _fmt;
		growText.defaultTextFormat = _fmt;
		stepText.defaultTextFormat = _fmt;
		stepText.text = param1;
		stepText.y = healthText.y + 10;
		this.setOutputIcon(param2);
	}

	// ABC setOutput（成熟：bg/健康条/健康文本隐，bg2/生长条/生长文本显；
	// 生长条打满；growText 的 defaultTextFormat 在链式之后又单独落了第二枚
	// 同参新实例——字节码两次 OConstructProperty，照抄）
	public function setOutput(param1:Float, param2:String, param3:String, param4:DisplayObject = null):Void {
		var healthText:TextField = cast(As3.childOf(this, "healthText"), TextField);
		var growText:TextField = cast(As3.childOf(this, "growText"), TextField);
		var stepText:TextField = cast(As3.childOf(this, "stepText"), TextField);
		healthText.visible = false;
		var healthBar:DisplayObject = cast(As3.childOf(this, "healthBar"), DisplayObject);
		healthBar.visible = false;
		var bg:DisplayObject = cast(As3.childOf(this, "bg"), DisplayObject);
		bg.visible = false;
		var bg2:DisplayObject = cast(As3.childOf(this, "bg2"), DisplayObject);
		bg2.visible = true;
		var growBar:DisplayObject = cast(As3.childOf(this, "growBar"), DisplayObject);
		growBar.visible = true;
		growText.visible = true;
		if (this.seedSprite == null) {
			this.seedSprite = new Sprite();
			addChild(this.seedSprite);
		}
		var _fmt:TextFormat = new TextFormat("Tahoma", 12, 3355443);
		healthText.defaultTextFormat = _fmt;
		growText.defaultTextFormat = _fmt;
		stepText.defaultTextFormat = _fmt;
		growBar.width = param1 * 120;
		growText.defaultTextFormat = new TextFormat("Tahoma", 12, 3355443);
		growText.htmlText = "<font size=\"12\" face=\"Tahoma\">" + param2 + "</font>";
		stepText.text = param3;
		stepText.y = healthText.y + 10;
		this.setOutputIcon(param4);
	}

	// ABC setOutputIcon（换挂种子小图：x 贴左 36px 基线、y 对齐 healthText
	// 行底；OToBool 对象真值 = 非空）
	public function setOutputIcon(param1:DisplayObject):Void {
		if (this.seedSprite.numChildren > 0) {
			this.seedSprite.removeChildAt(0);
		}
		if (param1 != null) {
			var stepText:TextField = cast(As3.childOf(this, "stepText"), TextField);
			var healthText:TextField = cast(As3.childOf(this, "healthText"), TextField);
			param1.x = 36 - param1.width;
			param1.y = stepText.y - (param1.height - healthText.height);
			this.seedSprite.addChild(param1);
		}
	}

	// ABC setInfoIcon（同上，y 基线对齐 stepText 行底）
	public function setInfoIcon(param1:DisplayObject):Void {
		if (this.seedSprite.numChildren > 0) {
			this.seedSprite.removeChildAt(0);
		}
		if (param1 != null) {
			var stepText:TextField = cast(As3.childOf(this, "stepText"), TextField);
			param1.x = 36 - param1.width;
			param1.y = stepText.y - (param1.height - stepText.height);
			this.seedSprite.addChild(param1);
		}
	}
}
