package common.misc;

import haxe.Json;
import module.FarmApplication;

// common.misc.ConfigMerger —— ConfigMerger.as 逐句对应（221 loc，启动链的配置
// 合并器：data 配置 parseXMLData、addon 配置 mergeConfig，按原样两段）。
// PORT-NOTE: E4X child()/children()/attributes() 按等价 Xml 遍历改写
//（FarmLite 先例）；`@id == undefined ? name() : @id` 的空属性语义 = get()
// null 时退 nodeName。com.adobe.serialization.json.JSON.decode → haxe.Json.parse。
class ConfigMerger {
	// ConfigMerger.as:11
	private var _app:FarmApplication;

	// ConfigMerger.as:13
	private var _toMerge:Xml;

	// ConfigMerger.as:15-21
	public function new(param1:FarmApplication, param2:String) {
		super();
		this._app = param1;
		this.parseXMLData(param2);
		this._toMerge = null;
	}

	// ConfigMerger.as:23-32
	private function checkTargetData(param1:String):Dynamic {
		var _loc2_:Dynamic = this._app.model.getData(param1);
		if (_loc2_ == null) {
			_loc2_ = {};
			this._app.model.setData(param1, _loc2_);
		}
		return _loc2_;
	}

	// ConfigMerger.as:34-67。`_loc7_.attributes() != undefined` 在 E4X 里恒真
	//（XMLList 永非 undefined），attributes 分支必走、text() 分支死代码——结构照抄。
	private function mergeCommonNode(param1:String):Void {
		var _loc7_:Xml = null;
		var _loc8_:String = null;
		var _loc2_:Xml = firstChildElement(this._toMerge, param1);
		if (_loc2_ == null) {
			return;
		}
		var _loc3_:Dynamic = this.checkTargetData(param1);
		var _loc4_:Dynamic = null;
		var _loc5_:String = "";
		for (_loc7_ in _loc2_.elements()) {
			_loc4_ = {};
			_loc5_ = _loc7_.get("id") == null ? _loc7_.nodeName : _loc7_.get("id");
			for (_loc8_ in _loc7_.attributes()) {
				if (_loc8_ != "id") {
					Reflect.setField(_loc4_, _loc8_, _loc7_.get(_loc8_));
				}
			}
			Reflect.setField(_loc3_, _loc5_, _loc4_);
		}
	}

	// ConfigMerger.as:69-78
	private function checkTargetArrayData(param1:String):Array<Dynamic> {
		var _loc2_:Array<Dynamic> = this._app.model.getData(param1);
		if (_loc2_ == null) {
			_loc2_ = [];
			this._app.model.setData(param1, _loc2_);
		}
		return _loc2_;
	}

	// ConfigMerger.as:80-88
	private function parseJSONData(param1:Dynamic):Void {
		var _loc3_:String = null;
		var _loc2_:Dynamic = Json.parse(param1);
		for (_loc3_ in Reflect.fields(_loc2_)) {
			this._app.model.setData(_loc3_, Reflect.field(_loc2_, _loc3_));
		}
	}

	// ConfigMerger.as:90-129。XMLDocument(ignoreWhite) 的 firstChild.childNodes
	// → Xml.parse 的文档元素遍历（忽略空白节点是 Xml.parse 的默认行为）
	private function parseXMLData(param1:String):Void {
		var _loc2_:Xml = null;
		var _loc3_:Dynamic = null;
		var _loc4_:String = null;
		var _loc5_:Dynamic = null;
		var _loc6_:String = null;
		var _loc7_:Xml = null;
		var _loc8_:String = null;
		var _loc9_:Xml = Xml.parse(param1).firstElement();
		for (_loc7_ in _loc9_.elements()) {
			_loc4_ = _loc7_.nodeName;
			_loc3_ = {};
			if (_loc7_.get("type") == "json") {
				this.parseJSONData(firstTextNode(_loc7_));
			} else if (_loc7_.get("type") == "xml") {
				this._app.model.setData(_loc4_, _loc7_);
			} else {
				for (_loc2_ in _loc7_.elements()) {
					_loc5_ = {};
					_loc6_ = _loc2_.get("id") == null ? _loc2_.nodeName : _loc2_.get("id");
					for (_loc8_ in _loc2_.attributes()) {
						Reflect.setField(_loc5_, _loc8_, _loc2_.get(_loc8_));
					}
					Reflect.setField(_loc3_, _loc6_, _loc5_);
				}
				this._app.model.setData(_loc4_, _loc3_);
			}
		}
	}

	// ConfigMerger.as:131-156
	public function mergeConfig(param1:Xml):Void {
		if (param1 == null || this._app.model == null) {
			return;
		}
		this._toMerge = param1;
		this.mergeCommonNode("environment");
		this.mergeCommonNode("assets");
		this.mergeJsonArrayNode("secondList");
		this.mergeJsonArrayNode("plugins");
		this.mergeJsonArrayNode("boards");
		this.mergeJsonArrayNode("crops");
		this.mergeJsonArrayNode("item_info");
		this.mergeJsonArrayNode("fish_info");
		this.mergeJsonArrayNode("advertisement");
		this.mergeCommonNode("cardsGameRewards");
		this.mergeCommonNode("freegifts");
		this.mergeCommonNode("dynamicTips");
		this.mergeCommonNode("monthEnds");
		this.mergeCommonNode("magiccards");
		this.mergeCommonNode("qdseeds");
		this.mergeCommonNode("bigworlds");
		this.mergeCommonNode("luoyangs");
		this.mergeXml("wild");
	}

	// ConfigMerger.as:158-207
	private function mergeJsonArrayNode(param1:String):Void {
		var name:String = param1;
		var mNode:Xml = firstChildElement(this._toMerge, name);
		if (mNode == null || mNode.get("type") != "json") {
			return;
		}
		var cfg:Array<Dynamic> = this.checkTargetArrayData(name);
		var jsn:Dynamic = null;
		try {
			jsn = Json.parse(firstTextNode(mNode));
		} catch (e:Dynamic) {
			trace("ERROR> parse json data failed.");
			return;
		}
		var exist:Bool = false;
		var toAdd:Array<Dynamic> = [];
		var a:Dynamic = null;
		var t:Dynamic = null;
		var att:String = null;
		for (a in (Reflect.field(jsn, name):Array<Dynamic>)) {
			exist = false;
			for (t in (cfg:Array<Dynamic>)) {
				if (Reflect.field(a, "id") == Reflect.field(t, "id")) {
					for (att in Reflect.fields(a)) {
						Reflect.setField(t, att, Reflect.field(a, att));
					}
					exist = true;
					break;
				}
			}
			if (exist == false) {
				toAdd.push(a);
			}
		}
		cfg = cfg.concat(toAdd);
		this._app.model.setData(name, cfg);
	}

	// ConfigMerger.as:209-218
	private function mergeXml(param1:String):Void {
		var _loc2_:Xml = firstChildElement(this._toMerge, param1);
		if (_loc2_ == null) {
			return;
		}
		this._app.model.setData(param1, _loc2_);
	}

	// E4X child(name) 的等价：第一个同名子元素（E4X 返回列表，取布尔/首元素语义）
	private static function firstChildElement(param1:Xml, param2:String):Xml {
		if (param1 == null) {
			return null;
		}
		for (child in param1.elements()) {
			if (child.nodeName == param2) {
				return child;
			}
		}
		return null;
	}

	// childNodes[0].nodeValue / children()[0]：元素文本内容（json 载荷）
	private static function firstTextNode(param1:Xml):String {
		return param1.firstChild().nodeValue;
	}
}
