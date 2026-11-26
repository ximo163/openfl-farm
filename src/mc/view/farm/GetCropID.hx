package mc.view.farm;

import com.minutes.net.HTTPRequest;
import com.qzone.corelib.js.JSProxy;
import common.INI;
import common.LocalData;
import mc.model.MData;
import mc.view.farm.research.ResearchModel;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.net.URLLoader;
import openfl.net.URLRequest;
import shim.As3;

/**
 * mc.view.farm.GetCropID —— GetCropID.as 逐句对应（issue #87 充真身）。
 * 牧场 id↔名称/URL 映射中枢：商店/仓库/装饰/科研各片都靠它拼资产与图标
 * URL。成员签名逐字取自反编译原文（行号对应 GetCropID.as）。与 main3 侧
 * common.GetCropID（src/common/GetCropID.hx）是两个不同的类。
 * legacy/decompiled/Master2_v_142/scripts/mc/view/farm/GetCropID.as。
 *
 * PORT-NOTE(E4X)：AS3 XML/E4X → haxe Xml，无通用 E4X shim——按调用点
 * 手译（FarmLite.hx:149 先例），共用查询收进类内私有助手（childNamed/
 * childAttr/animalEl/attrEq/textOf/numOf，见文件尾）。`_xml` 静态缓存
 * 位（GetCropID.as:22）在测试里注入 Xml.parse 产物——haxe **Document**
 * 节点，firstElement() 才是 <main> 根元素；缓存时按 Document/Element
 * 两态归一（不改写注入物本身）。
 * PORT-NOTE(E4X 松等)：属性过滤 `(@id == val)` 的 val 为 String 时按
 * 字符串比对；val 为 Number（getAnimalSound/numToNext）时 E4X 数值松等
 * （"1001" == 1001 为真）——attrEq 两态分流。
 * PORT-NOTE(Number())：E4X 结果进 Number() 上下文——空 XMLList/空串
 * 经 toString "" → +0（ECMA-262 Number("")），数字串解析、非数字 NaN。
 * numOf 复刻（与 As3.floatOf 的前缀解析/空串 NaN 语义不同——那是
 * parseFloat 通道）。
 * PORT-NOTE(MainData.LOAD_DIY_CONFIG_COMPLETE)：常量原定义在
 * MainData.as:156（"diy_config"），MainData.hx stub 未收该常量（属后续
 * 牧场数据片）；AS3 static const 编译期内联，此处按字面量直写等价。
 */
@:keep
class GetCropID {
	// GetCropID.as:19-25
	private static var fr:Dynamic;
	private static var _xml:Dynamic;
	public static var _mpXml:Dynamic;
	public static var _loading:Bool = false;

	// GetCropID.as:27-30
	public function new() {}

	// :32-49
	public static function getDiyMP(param1:Int):String {
		var _infos:Array<Xml> = null;
		var i:Int = 0;
		var id:Int = param1;
		if (_mpXml == null) {
			if (_loading == false) {
				getMPXMl();
			}
			return null;
		}
		// E4X `_mpXml.items.item.(@id == id).info.l`：items 的 item 子元素
		// 按 id 过滤 → 其 info 子元素 → info 的 l 子元素列表
		_infos = mpItemL(id);
		i = 0;
		i = Math.floor(_infos.length * Math.random());
		// `_infos[i]` 越界 undefined→null（String 返回位 null 化）
		var el:Xml = (i >= 0 && i < _infos.length) ? _infos[i] : null;
		return el == null ? null : textOf(el);
	}

	// :51-60
	public static function getSwfUrl():String {
		var _loc1_:String = "";
		if (_xml == null) {
			_xml = xmlNormalize(INI.getInstance().data);
		}
		// E4X `_xml.folder.@url`：folder 子元素的 url 属性
		var folder:Xml = childNamed(xmlRoot(), "folder");
		_loc1_ = folder == null ? "" : attrStr(folder.get("url"));
		return addPrefix(_loc1_);
	}

	// :62-67
	public static function getWildAnimalIcon(param1:String, param2:Int):String {
		var _loc3_:String = "";
		_loc3_ = getSwfUrl();
		return _loc3_ + ("farm/wild/pic/" + param1 + "_" + param2 + ".jpg");
	}

	// :69-91
	public static function getActivity(param1:String, param2:Bool = false):Bool {
		var h:String = null;
		var val:String = param1;
		var checkProduct:Bool = param2;
		if (_xml == null) {
			_xml = xmlNormalize(INI.getInstance().data);
		}
		var animal:Xml = animalEl(val);
		if (!checkProduct) {
			h = animal == null ? "" : attrStr(animal.get("isActivity"));
		} else {
			h = animal == null ? "" : attrStr(animal.get("isProductActivity"));
		}
		if (h == "1") {
			return true;
		}
		return false;
	}

	// :93-98
	public static function getWildIcon(param1:String, param2:Int, param3:String):String {
		var _loc4_:String = "";
		_loc4_ = getSwfUrl();
		return _loc4_ + ("farm/wild/pic/" + param1 + "_" + param3 + "_" + param2 + ".jpg");
	}

	// :100-170
	public static function idToDiyUrl2(param1:Float, param2:Dynamic):String {
		var _loc4_:String = null;
		var _loc6_:Int = 0;
		var _loc7_:Int = 0;
		var _loc3_:String = "";
		if (_xml == null) {
			_xml = xmlNormalize(INI.getInstance().data);
		}
		if (Std.string(Reflect.field(param2, "lv")).indexOf("_") != -1) {
			// 原文第二处 `param2["lv"].indexOf("_")` 直调原始值（无 String()
			// 包装）——lv 非字符串时原版 TypeError；cast 真类型复刻同通路
			_loc4_ = Std.string(Reflect.field(param2, "lv")).substr(0, As3.intOf((cast(Reflect.field(param2, "lv"), String)).indexOf("_")));
		} else {
			// 原文 `_loc4_ = param2["lv"]` 赋进 String 强类型局部——AS3 隐式
			// String 化
			_loc4_ = Std.string(Reflect.field(param2, "lv"));
		}
		var _loc5_:ResearchModel = ResearchModel.gi();
		if (As3.intOf(_loc4_) > 8) {
			_loc6_ = 0;
			if (Reflect.field(param2, "id") == "102") {
				_loc7_ = 0;
				while (_loc7_ < _loc5_.UpdataW2.length) {
					// `endtime != 0` 为 AS3 松等（数值/字符串双形态数值化比对）
					if (As3.floatOf(Reflect.field(_loc5_.UpdataW2[_loc7_], "endtime")) != 0) {
						if (_loc5_.canGetDenAnimal(_loc7_)) {
							_loc6_ = 2;
							_loc4_ += "_ok";
							break;
						}
						_loc6_ = 1;
					}
					_loc7_++;
				}
				if (_loc6_ == 1) {
					_loc4_ += "_ing";
				}
			} else if (Reflect.field(param2, "id") == "103") {
				_loc7_ = 0;
				while (_loc7_ < _loc5_.UpdataP2.length) {
					if (As3.floatOf(Reflect.field(_loc5_.UpdataP2[_loc7_], "endtime")) != 0) {
						if (_loc5_.canGetShedAnimal(_loc7_)) {
							_loc6_ = 2;
							_loc4_ += "_ok";
							break;
						}
						_loc6_ = 1;
					}
					_loc7_++;
				}
				if (_loc6_ == 1) {
					_loc4_ += "_ing";
				}
			}
		}
		// 原文 `param2 = "z" + ...` 把 Object 形参重赋为 String（AS3 动态
		// 类型）——Haxe Dynamic 形参可重赋，右侧的 param2["id"] 先按旧值
		// 取后再赋
		param2 = "z" + param1 + "_" + Reflect.field(param2, "id") + "_" + _loc4_ + ".swf";
		_loc3_ = getSwfUrl();
		return _loc3_ + ("farm/diy/" + param2);
	}

	// :172-190
	public static function getWareHouseIconUrl(param1:Float):String {
		var _loc3_:String = null;
		var _loc2_:String = "";
		if (_xml == null) {
			_xml = xmlNormalize(INI.getInstance().data);
		}
		if (param1 > 10000) {
			_loc3_ = "a" + (param1 - 10000) + ".jpg";
		} else {
			_loc3_ = "a" + param1 + "p.jpg";
		}
		_loc2_ = getSwfUrl();
		return _loc2_ + ("farm/animal/" + _loc3_);
	}

	// :192-202
	public static function toolToAnimal(param1:String):Dynamic {
		var _animal:Xml = null;
		var value:String = param1;
		if (_xml == null) {
			_xml = xmlNormalize(INI.getInstance().data);
		}
		// E4X `_xml.animals.animal.(@sf == value)[0]`
		_animal = animalElByAttr("sf", value);
		return _animal;
	}

	// :204-209
	public static function getFlopUrl():String {
		var _loc1_:String = "";
		_loc1_ = getSwfUrl();
		return _loc1_ + "main/windows/flopGift.swf";
	}

	// :211-220
	public static function addPrefix(param1:String):String {
		// `Boolean(LocalData.parameters.appImgPrefix)`：Dynamic 真值（空串/
		// 缺位为假）；parameters 本身 Dynamic——直读动态字段（eval 实测可）
		if (As3.truthy(Reflect.field(LocalData.parameters, "appImgPrefix")) && param1.indexOf(".appimg") == -1) {
			// AS3 String.replace(字符串模式, 替换串) 只换第一处——replaceFirst
			// 三连按原文顺序
			param1 = As3.replaceFirst(param1, "appimg.", Reflect.field(LocalData.parameters, "appImgPrefix") + ".appimg.");
			param1 = As3.replaceFirst(param1, "appimg1.", Reflect.field(LocalData.parameters, "appImgPrefix") + ".appimg1.");
			param1 = As3.replaceFirst(param1, "appimg3.", Reflect.field(LocalData.parameters, "appImgPrefix") + ".appimg3.");
		}
		return param1;
	}

	// :222-243
	public static function getHunterMP(param1:Int, param2:String):String {
		var _infos:Array<Xml> = null;
		var i:Int = 0;
		var id:Int = param1;
		var value:String = param2;
		if (_mpXml == null) {
			if (_loading == false) {
				getMPXMl();
			}
			return null;
		}
		// E4X `_mpXml.guard.info.(@id == id).l`
		_infos = mpGuardL(id);
		i = 0;
		if (value == "work") {
			i = Math.floor(_infos.length * Math.random()) + 1;
		}
		var el:Xml = (i >= 0 && i < _infos.length) ? _infos[i] : null;
		return el == null ? null : textOf(el);
	}

	// :245-259
	public static function getHunterPicUrl(param1:String, param2:Bool = false):String {
		var _loc3_:String = "";
		if (_xml == null) {
			_xml = xmlNormalize(INI.getInstance().data);
		}
		_loc3_ = getSwfUrl();
		_loc3_ += "farm/hunter/h_" + param1 + ".jpg";
		if (param2) {
			// AS3 .replace("jpg","png") 字符串模式——只换第一处
			_loc3_ = As3.replaceFirst(_loc3_, "jpg", "png");
		}
		return _loc3_;
	}

	// :261-284
	public static function getAnimalURL(param1:String, param2:Int):String {
		var _loc4_:String = null;
		var _loc6_:String = null;
		var _loc3_:String = getSwfUrl() + "farm/aswf/";
		// 原文 `getAnimalV(String(param1))`——param1 已是 String，String()
		// 恒等转换
		var _loc5_:String = getAnimalV(param1);
		if (param2 == 1 || param2 == 2) {
			_loc6_ = "_0";
		} else {
			_loc6_ = "_1";
		}
		if (_loc5_ != "") {
			_loc4_ = _loc3_ + "a" + param1 + _loc6_ + ".swf" + "?v=" + _loc5_;
		} else {
			_loc4_ = _loc3_ + "a" + param1 + _loc6_ + ".swf";
		}
		return _loc4_;
	}

	// :286-308
	public static function getUpdataAnimalIconUrl(param1:Float, param2:Bool = false, param3:Bool = false):String {
		var _loc5_:String = null;
		var _loc4_:String = "";
		if (_xml == null) {
			_xml = xmlNormalize(INI.getInstance().data);
		}
		if (param2) {
			_loc5_ = "a" + param1 + ".jpg";
		} else if (param3) {
			_loc5_ = "a" + param1 + "e_b.png";
		} else {
			_loc5_ = "a" + param1 + "e.png";
		}
		_loc4_ = getSwfUrl();
		return _loc4_ + ("farm/animal/" + _loc5_);
	}

	// :310-320
	public static function idToName(param1:String):String {
		var value:String = param1;
		var _name:String = "";
		if (_xml == null) {
			_xml = xmlNormalize(INI.getInstance().data);
		}
		var animal:Xml = animalEl(value);
		_name = animal == null ? "" : attrStr(animal.get("name"));
		return _name;
	}

	// :322-342
	public static function getCommonUrlNc():String {
		var _loc1_:Xml = xmlNormalize(INI.getInstance().data);
		var _loc2_:String = "";
		if (_loc1_ != null) {
			var postUrl:Xml = childNamed(_loc1_, "postUrl");
			if (LocalData.mode == "qzone" || LocalData.xymode == "qq.com") {
				_loc2_ = postUrl == null ? "" : attrStr(postUrl.get("commonNc"));
			} else {
				_loc2_ = postUrl == null ? "" : attrStr(postUrl.get("commonNc_pengyou"));
			}
		}
		if (_loc2_ == "") {
			trace("请求地址出错");
		}
		return _loc2_;
	}

	// :344-364
	public static function getCommonUrlFarm():String {
		var _loc1_:Xml = xmlNormalize(INI.getInstance().data);
		var _loc2_:String = "";
		if (_loc1_ != null) {
			var postUrl:Xml = childNamed(_loc1_, "postUrl");
			if (LocalData.mode == "qzone" || LocalData.xymode == "qq.com") {
				_loc2_ = postUrl == null ? "" : attrStr(postUrl.get("commonFarm"));
			} else {
				_loc2_ = postUrl == null ? "" : attrStr(postUrl.get("commonFarm_pengyou"));
			}
		}
		if (_loc2_ == "") {
			trace("请求地址出错");
		}
		return _loc2_;
	}

	// :366-376
	public static function getProductTip(param1:String):String {
		var value:String = param1;
		var _tip:String = "";
		if (_xml == null) {
			_xml = xmlNormalize(INI.getInstance().data);
		}
		// E4X `_xml.warehouse.product.(@id == value).tip`——tip 子元素的文本
		var product:Xml = childAttr(childNamed(xmlRoot(), "warehouse"), "product", "id", value);
		var tip:Xml = product == null ? null : childNamed(product, "tip");
		_tip = tip == null ? "" : textOf(tip);
		return _tip;
	}

	// :378-404
	public static function getShopIconUrl(param1:Float, param2:Bool = false, param3:Bool = false, param4:Bool = false):String {
		var _loc6_:String = null;
		var _loc5_:String = "";
		if (_xml == null) {
			_xml = xmlNormalize(INI.getInstance().data);
		}
		if (param2) {
			_loc6_ = "a" + param1 + "b.jpg";
		} else if (param3) {
			_loc6_ = "a" + param1 + "b.jpg";
		} else if (param4) {
			_loc6_ = "a" + param1 + "b_s.swf";
		} else {
			_loc6_ = "a" + param1 + ".jpg";
		}
		_loc5_ = getSwfUrl();
		return _loc5_ + ("farm/animal/" + _loc6_);
	}

	// :406-416
	public static function getAnimalV(param1:String):String {
		var n:String;
		var val:String = param1;
		if (_xml == null) {
			_xml = xmlNormalize(INI.getInstance().data);
		}
		// 原文 `@v || ""`：属性缺失（空 XMLList→String 化 ""）与空串同落
		// ""——归一后 || 冗余，等价取属性或 ""
		var animal:Xml = animalEl(val);
		n = animal == null ? "" : attrStr(animal.get("v"));
		return n;
	}

	// :418-423
	public static function getVipAnimalURL(param1:String):String {
		var _loc2_:String = "";
		_loc2_ = getSwfUrl();
		return _loc2_ + ("farm/VipAnimal/" + param1);
	}

	// :425-428（原文即恒 false 的完整实现）
	public static function canSellCubTip():Bool {
		return false;
	}

	// :430-440
	public static function getTipInfo(param1:String):String {
		var t:String;
		var val:String = param1;
		if (_xml == null) {
			_xml = xmlNormalize(INI.getInstance().data);
		}
		var animal:Xml = animalEl(val);
		var tip:Xml = animal == null ? null : childNamed(animal, "tip");
		t = tip == null ? "" : textOf(tip);
		return t;
	}

	// :442-460
	public static function numToNext(param1:Float, param2:Float, param3:Float = 0):String {
		var str:String = null;
		var statusList:Array<String> = null;
		var val:Float = param1;
		var num:Float = param2;
		var next:Float = param3;
		if (_xml == null) {
			_xml = xmlNormalize(INI.getInstance().data);
		}
		// E4X `(@id == val)` 的 val 为 Number——数值松等（attrEq 分流）
		var animal:Xml = animalEl(val);
		var nextText:Xml = animal == null ? null : childNamed(animal, "nextText");
		str = nextText == null ? "" : attrStr(nextText.get("value"));
		statusList = str.split(",");
		if (next == 6 && num == 5) {
			return "待收获期";
		}
		// 原文 `statusList[num - 1] as String`——num 为 Number，Haxe 下标需
		// Int；越界 undefined→null（as String 恒转，String 元素直返）
		var idx:Int = Std.int(num - 1);
		if (idx < 0 || idx >= statusList.length) {
			return null;
		}
		return statusList[idx];
	}

	// :462-472
	public static function idToSound(param1:String):Float {
		var _name:Float = Math.NaN;
		var value:String = param1;
		if (_xml == null) {
			_xml = xmlNormalize(INI.getInstance().data);
		}
		var animal:Xml = animalEl(value);
		_name = numOf(animal == null ? null : animal.get("sound"));
		return _name;
	}

	// :474-488
	public static function hasDiyMP(param1:Int):Bool {
		var _infos:Array<Xml> = null;
		var id:Int = param1;
		if (_mpXml == null) {
			if (_loading == false) {
				getMPXMl();
			}
			return false;
		}
		_infos = mpItemL(id);
		return _infos.length > 0 ? true : false;
	}

	// :490-493（原文即完整实现——纯字符串拼接，无状态依赖）
	public static function idToWareName(param1:String):String {
		return "p" + param1;
	}

	// :495-505
	public static function getAnimalInfo(param1:String):Dynamic {
		var ai:Xml;
		var val:String = param1;
		if (_xml == null) {
			_xml = xmlNormalize(INI.getInstance().data);
		}
		ai = animalEl(val);
		return ai;
	}

	// :507-517
	public static function idToCardLockStatus(param1:String):Int {
		var value:String = param1;
		var _lock:String = "";
		if (_xml == null) {
			_xml = xmlNormalize(INI.getInstance().data);
		}
		var card:Xml = childAttr(childNamed(xmlRoot(), "cards"), "card", "id", value);
		_lock = card == null ? "" : attrStr(card.get("isLock"));
		// parseInt 得 Number 再赋 int——NaN 归 0（As3.intOf 复刻）
		return As3.intOf(As3.parseInt(_lock));
	}

	// :519-531
	public static function getAnimalSound(param1:Float):String {
		var info:Array<Xml> = null;
		var i:Float = Math.NaN;
		var id:Float = param1;
		if (_xml == null) {
			_xml = xmlNormalize(INI.getInstance().data);
		}
		// E4X `_xml.animals.animal.(@id == id).info.l`——id 为 Number 数值松等
		var animal:Xml = animalEl(id);
		var infoEl:Xml = animal == null ? null : childNamed(animal, "info");
		info = infoEl == null ? [] : childrenNamed(infoEl, "l");
		i = Math.floor(info.length * Math.random());
		var idx:Int = Std.int(i);
		var el:Xml = (idx >= 0 && idx < info.length) ? info[idx] : null;
		return el == null ? null : textOf(el);
	}

	// :533-542
	public static function getShopDiyUrl(param1:String):String {
		var _loc2_:String = "";
		if (_xml == null) {
			_xml = xmlNormalize(INI.getInstance().data);
		}
		_loc2_ = getSwfUrl();
		return _loc2_ + ("farm/diy/z1_" + param1 + "_1_shop.jpg");
	}

	// :544-550（loadMPXml：mp 配置加载完成回调——原文 XML.ignoreWhitespace/
	// ignoreComments 是 AS3 XML 静态全局开关，haxe Xml 无对应物，丢弃）
	private static function loadMPXml(param1:Event):Void {
		// PORT-NOTE: XML.ignoreWhitespace/ignoreComments 无 haxe 等价——
		// haxe Xml.parse 保留空白文本节点，childNamed/elementsNamed 只取
		// 元素节点，查询通路不受影响
		var data:Dynamic = (cast(param1.target, URLLoader)).data;
		_mpXml = data == null ? null : xmlNormalize(Xml.parse(Std.string(data)));
		MData.getInstance().mainData.dispatchEvent(new Event("diy_config")); // MainData.as:156 LOAD_DIY_CONFIG_COMPLETE 字面量（见类头 PORT-NOTE）
	}

	// :552-562
	public static function idToCardName(param1:String):String {
		var value:String = param1;
		var _name:String = "";
		if (_xml == null) {
			_xml = xmlNormalize(INI.getInstance().data);
		}
		var card:Xml = childAttr(childNamed(xmlRoot(), "cards"), "card", "id", value);
		_name = card == null ? "" : attrStr(card.get("name"));
		return _name;
	}

	// :564-574
	public static function getProductName2(param1:Dynamic):String {
		var str2:String;
		var val:Dynamic = param1;
		if (_xml == null) {
			_xml = xmlNormalize(INI.getInstance().data);
		}
		// 形参原文 Object 但按 @id 比对——调用方传字符串 id；attrEq 按
		// val 类型分流（String 直比、Number 数值松等）
		var animal:Xml = animalEl(val);
		str2 = animal == null ? "" : attrStr(animal.get("product"));
		return str2;
	}

	// :576-586
	public static function getAnimalInfoIconUrl(param1:Float, param2:String):String {
		var _loc3_:String = "";
		if (_xml == null) {
			_xml = xmlNormalize(INI.getInstance().data);
		}
		var _loc4_:String = param2 + param1 + ".png";
		_loc3_ = getSwfUrl();
		return _loc3_ + ("farm/icon/" + _loc4_);
	}

	// :588-596
	public static function getGameRecord():Float {
		if (_xml == null) {
			_xml = xmlNormalize(INI.getInstance().data);
		}
		// E4X `Number(_xml.game.record[0])`——game 的首个 record 子元素文本
		var game:Xml = childNamed(xmlRoot(), "game");
		var record:Xml = game == null ? null : childNamed(game, "record");
		return numOf(record == null ? null : textOf(record));
	}

	// :598-608
	public static function idToLibName(param1:String):String {
		var value:String = param1;
		var _name:String = "";
		if (_xml == null) {
			_xml = xmlNormalize(INI.getInstance().data);
		}
		var animal:Xml = animalEl(value);
		_name = animal == null ? "" : attrStr(animal.get("className"));
		return _name;
	}

	// :610-624
	public static function getDiyTip(param1:Int):String {
		var id:Int = param1;
		var _tip:String = "";
		if (_mpXml == null) {
			if (_loading == false) {
				getMPXMl();
			}
			return null;
		}
		// E4X `_mpXml.items.item.(@id == id).tip`
		var item:Xml = mpItemEl(id);
		var tip:Xml = item == null ? null : childNamed(item, "tip");
		_tip = tip == null ? "" : textOf(tip);
		return _tip;
	}

	// :626-636
	public static function idToCardSrc(param1:String):String {
		var value:String = param1;
		var _src:String = "";
		if (_xml == null) {
			_xml = xmlNormalize(INI.getInstance().data);
		}
		var card:Xml = childAttr(childNamed(xmlRoot(), "cards"), "card", "id", value);
		_src = addPrefix(card == null ? "" : attrStr(card.get("src")));
		return _src;
	}

	// :638-642（原文即完整实现——纯字符串拼接，无状态依赖）
	public static function idToToolName(param1:String, param2:String):String {
		return "Tool_" + param2 + "_" + param1;
	}

	// :644-656
	public static function getProductName(param1:String):String {
		var str1:String;
		var str2:String = null;
		var val:String = param1;
		if (_xml == null) {
			_xml = xmlNormalize(INI.getInstance().data);
		}
		var animal:Xml = animalEl(val);
		str1 = animal == null ? "" : attrStr(animal.get("u"));
		str2 = animal == null ? "" : attrStr(animal.get("product"));
		return str1 + str2;
	}

	// :658-661
	public static function mpXmlIsNull():Bool {
		return _mpXml == null ? true : false;
	}

	// :663-665（ioErrorHandler 原文即空体）
	private static function ioErrorHandler(param1:IOErrorEvent):Void {}

	// :667-682
	public static function formatString(param1:String):String {
		if (param1.indexOf("<") != -1 || param1.indexOf(">") != -1) {
			// 原文正则带 "g" 标志——全局替换；顺序先 & 后 <>（& 先转义避免
			// 二次转义）
			param1 = StringTools.replace(param1, "&", "&amp;");
			param1 = StringTools.replace(param1, "<", "&lt;");
			param1 = StringTools.replace(param1, ">", "&gt;");
		}
		return param1;
	}

	// :684-694
	public static function getChidNum(param1:String):Float {
		var n:Float;
		var val:String = param1;
		if (_xml == null) {
			_xml = xmlNormalize(INI.getInstance().data);
		}
		var animal:Xml = animalEl(val);
		n = numOf(animal == null ? null : animal.get("childNum"));
		return n;
	}

	// :696-706
	public static function getHouse(param1:String):String {
		var h:String;
		var val:String = param1;
		if (_xml == null) {
			_xml = xmlNormalize(INI.getInstance().data);
		}
		var animal:Xml = animalEl(val);
		h = animal == null ? "" : attrStr(animal.get("house"));
		return h;
	}

	// :708-748
	public static function setNext(param1:Dynamic):Void {
		var str:String = null;
		var timeList:Array<String> = null;
		var n1:Float = Math.NaN;
		var n2:Float = Math.NaN;
		var n3:Float = Math.NaN;
		var data:Dynamic = param1;
		if (_xml == null) {
			_xml = xmlNormalize(INI.getInstance().data);
		}
		// `(@id == data.cId)`——cId 为 Dynamic，attrEq 按类型松等分流
		var animal:Xml = animalEl(Reflect.field(data, "cId"));
		var nextTime:Xml = animal == null ? null : childNamed(animal, "nextTime");
		str = nextTime == null ? "" : attrStr(nextTime.get("value"));
		timeList = str.split(",");
		// `data.status == 2` 为 AS3 松等（数值/字符串双形态）——数值化比对。
		// data 是匿名数据对象（非显示对象）——字段读写走 Reflect 通道
		// （scan_dyn_writes 禁令/cpp 动态写坑，FarmLandModel.hx 同款先例）
		if (As3.floatOf(Reflect.field(data, "status")) == 2) {
			Reflect.setField(data, "statusNext", 3);
			// timeList 元素是 split 出的字符串——原样赋值（字符串位）
			Reflect.setField(data, "growTimeNext", timeListAt(timeList, 1));
		}
		if (As3.floatOf(Reflect.field(data, "status")) == 3) {
			Reflect.setField(data, "statusNext", 6);
			// `timeList[5] - data.growTime`——AS3 数值减法对字符串/动态操作数
			// 隐式 Number 化（Haxe 动态减法在 eval 抛 Invalid operation——
			// 显式 floatOf 复刻）
			Reflect.setField(data, "growTimeNext", As3.floatOf(timeListAt(timeList, 5)) - As3.floatOf(Reflect.field(data, "growTime")));
		}
		if (As3.floatOf(Reflect.field(data, "status")) == 5) {
			n1 = As3.floatOf(Reflect.field(data, "growTime"));
			n2 = As3.floatOf(timeListAt(timeList, 4));
			n3 = As3.floatOf(timeListAt(timeList, 5));
			if (n1 + n2 >= n3) {
				Reflect.setField(data, "statusNext", 6);
				// 原文 `Number(timeList[5] - data.growTime)`——减法已数值化，
				// Number() 恒等，保形
				Reflect.setField(data, "growTimeNext", As3.floatOf(timeListAt(timeList, 5)) - As3.floatOf(Reflect.field(data, "growTime")));
			} else {
				Reflect.setField(data, "statusNext", 3);
				Reflect.setField(data, "growTimeNext", timeListAt(timeList, 4));
			}
		}
	}

	// :750-764
	public static function getDiySkin(param1:Int):String {
		var id:Int = param1;
		var _skin:String = "";
		if (_mpXml == null) {
			if (_loading == false) {
				getMPXMl();
			}
			return null;
		}
		var item:Xml = mpItemEl(id);
		_skin = item == null ? "" : attrStr(item.get("skin"));
		return _skin;
	}

	// :766-774
	public static function getMPXMl():Void {
		_loading = true;
		var _loc1_:String = JSProxy.addGToken(HTTPRequest.getInstance().httpUrl + "cgi_animal_tips");
		var _loc2_:URLLoader = new URLLoader();
		_loc2_.addEventListener(Event.COMPLETE, loadMPXml);
		_loc2_.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
		_loc2_.load(new URLRequest(_loc1_));
	}

	// ----------------------------------------------------------------
	// E4X 等价查询助手（类内私有——无通用 E4X shim，按调用点手译的共用件）
	// ----------------------------------------------------------------

	// INI.data / _xml 归一：Xml.parse 产物是 Document 节点，firstElement()
	// 才是配置根 <main>；Element 直返。不改写注入物本身
	private static function xmlNormalize(x:Dynamic):Xml {
		if (x == null) {
			return null;
		}
		var xml:Xml = cast x;
		if (xml.nodeType == Xml.Document) {
			return xml.firstElement();
		}
		return xml;
	}

	// 缓存位 _xml 的根元素（null 直通）
	private static function xmlRoot():Xml {
		if (_xml == null) {
			return null;
		}
		return cast _xml;
	}

	// parent 的第一个名为 name 的元素子件（E4X parent.name 单元素取用；
	// parent null 或缺位 → null）
	private static function childNamed(parent:Xml, name:String):Xml {
		if (parent == null) {
			return null;
		}
		for (e in parent.elementsNamed(name)) {
			return e;
		}
		return null;
	}

	// parent 下名为 name 的全部元素子件（E4X XMLList 多元素取用）
	private static function childrenNamed(parent:Xml, name:String):Array<Xml> {
		var out:Array<Xml> = [];
		if (parent == null) {
			return out;
		}
		for (e in parent.elementsNamed(name)) {
			out.push(e);
		}
		return out;
	}

	// parent 的 name 子元素中 attr==value（attrEq 松等）的首个命中
	// （E4X parent.name.(@attr == value)[0]）
	private static function childAttr(parent:Xml, name:String, attr:String, value:Dynamic):Xml {
		if (parent == null) {
			return null;
		}
		for (e in parent.elementsNamed(name)) {
			if (attrEq(e.get(attr), value)) {
				return e;
			}
		}
		return null;
	}

	// animals.animal.(@id == val) 的首个命中（_xml 根 → animals → animal）
	private static function animalEl(val:Dynamic):Xml {
		return childAttr(childNamed(xmlRoot(), "animals"), "animal", "id", val);
	}

	// animals.animal.(@<attr> == val) 首个命中（toolToAnimal 的 sf 通道）
	private static function animalElByAttr(attr:String, val:Dynamic):Xml {
		return childAttr(childNamed(xmlRoot(), "animals"), "animal", attr, val);
	}

	// E4X 属性过滤的松等比对：XML 属性恒为字符串——val 为 String 直比；
	// val 为 Number 时 E4X 数值松等（"1001" == 1001 为真，两侧数值化）。
	// 属性缺失（null）时该元素不进命中集
	private static function attrEq(attr:String, val:Dynamic):Bool {
		if (attr == null) {
			return false;
		}
		if (Std.isOfType(val, String)) {
			return attr == val;
		}
		return As3.floatOf(attr) == As3.floatOf(val);
	}

	// E4X XMLList→String 的属性上下文：缺失属性（空 XMLList）String 化 ""
	private static function attrStr(s:String):String {
		return s == null ? "" : s;
	}

	// E4X 元素→String 的文本上下文：simple content 的元素 toString 是其
	// 文本（多段文本/CDATA 拼接，元素子件不参与——本类消费点全为纯文本
	// 元素）
	private static function textOf(e:Xml):String {
		if (e == null) {
			return "";
		}
		var buf:StringBuf = new StringBuf();
		for (n in e) {
			if (n.nodeType != Xml.Element) {
				buf.add(n.nodeValue);
			}
		}
		return buf.toString();
	}

	// AS3 Number(字符串) 语义：空串/空白 → +0，合法数字整串 → 数值，其余
	// NaN（与 As3.floatOf 的 parseFloat 前缀通道不同——Number() 是整串
	// 严格转换且空串为 0）
	private static function numOf(s:String):Float {
		if (s == null) {
			return 0;
		}
		var trimmed:String = StringTools.trim(s);
		if (trimmed == "") {
			return 0;
		}
		if (!~/^[-+]?(\d+\.?\d*|\.\d+)([eE][-+]?\d+)?$/.match(trimmed)) {
			return Math.NaN;
		}
		var f:Null<Float> = Std.parseFloat(trimmed);
		return f == null || Math.isNaN(f) ? Math.NaN : f;
	}

	// split 表的下标取（越界 undefined→null——AS3 数组越界语义）
	private static function timeListAt(list:Array<String>, i:Int):Dynamic {
		if (i < 0 || i >= list.length) {
			return null;
		}
		return list[i];
	}

	// _mpXml 的 items.item.(@id == id) 首个命中（id 为 int——数值松等）
	private static function mpItemEl(id:Int):Xml {
		var root:Xml = xmlNormalize(_mpXml);
		return childAttr(childNamed(root, "items"), "item", "id", id);
	}

	// _mpXml 的 items.item.(@id == id).info.l 元素列表
	private static function mpItemL(id:Int):Array<Xml> {
		var item:Xml = mpItemEl(id);
		var info:Xml = item == null ? null : childNamed(item, "info");
		return info == null ? [] : childrenNamed(info, "l");
	}

	// _mpXml 的 guard.info.(@id == id).l 元素列表
	private static function mpGuardL(id:Int):Array<Xml> {
		var root:Xml = xmlNormalize(_mpXml);
		var guard:Xml = childNamed(root, "guard");
		var infoHit:Xml = childAttr(guard, "info", "id", id);
		return infoHit == null ? [] : childrenNamed(infoHit, "l");
	}
}
