package com.qzone.qfa.managers;

import com.qzone.qfa.data.Resource;
import com.qzone.qfa.data.ResourceType;
import com.qzone.qfa.events.LoaderEvent;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Loader;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.geom.Matrix;
import openfl.system.ApplicationDomain;
import openfl.utils.Dictionary;
import shim.As3;

// ResourceManager.as 逐句对应。
class ResourceManager {
	// ResourceManager.as:17
	private static var _instance:ResourceManager;

	// ResourceManager.as:19。弱键字典；键是 url（String）
	private var _dataList:Dictionary<String, Resource>;

	// ResourceManager.as:21
	public var loadManager:LoadManager;

	// ResourceManager.as:23-26
	public function new(param1:Enforcer) {
		this._dataList = new Dictionary<String, Resource>(true);
	}

	// ResourceManager.as:28-31
	public static function gi():ResourceManager {
		return _instance = _instance != null ? _instance : new ResourceManager(new Enforcer());
	}

	// ResourceManager.as:33-36
	public static var instance(get, never):ResourceManager;

	private static function get_instance():ResourceManager {
		return gi();
	}

	// ResourceManager.as:38-131
	public function getImageOrSwf(param1:String, param2:Dynamic = null, param3:Int = 0, param4:Int = 0,
			param5:Bool = true, param6:Dynamic = null):Sprite {
		var addImage:Dynamic = null;
		var resource:Resource = null;
		var img:Sprite = null;
		var url:String = param1;
		var onCompleted:Dynamic = param2;
		var width:Int = param3;
		var height:Int = param4;
		var autoBitmap:Bool = param5;
		var failed:Dynamic = param6;
		img = new Sprite();
		if (!As3.truthy(url)) {
			return img;
		}
		img.mouseChildren = false;
		img.cacheAsBitmap = true;
		resource = this.findResource(url);
		addImage = function(param1:Resource):Void {
			var ld:Loader = null;
			var res:Resource = param1;
			var completeHandler:Dynamic = null;
			ld = new Loader();
			completeHandler = function():Void {
				var bmp:Bitmap = null;
				var bmpd:BitmapData = null;
				// `arguments.callee`：匿名函数自引用，Haxe 用命名闭包
				ld.contentLoaderInfo.removeEventListener(Event.COMPLETE, completeHandler);
				try {
					bmp = cast(ld.content, Bitmap);
					if (bmp != null) {
						bmpd = bmp.bitmapData.clone();
						if (width != 0 && height != 0) {
							bmpd = fixWH(bmpd, width, height, true);
						}
						img.addChild(new Bitmap(bmpd, "auto", true));
					}
					if (autoBitmap) {
						bmpd = new BitmapData(Std.int(ld.width), Std.int(ld.height), true, 0);
						bmpd.draw(ld.content);
						if (width != 0 && height != 0) {
							bmpd = fixWH(bmpd, width, height, true);
						}
						img.addChild(new Bitmap(bmpd, "auto", true));
					} else {
						img.addChild(ld);
					}
				} catch (err:Dynamic) {
					img.addChild(ld);
				}
				if (onCompleted != null) {
					// PORT-NOTE: AS3 的 onCompleted.length（形参数）在 Haxe 无可移植
					// 等价；Haxe 回调多传实参会被忽略，这里统一按带参分支调用
					onCompleted(img);
				}
			};
			ld.contentLoaderInfo.addEventListener(Event.COMPLETE, completeHandler);
			ld.loadBytes(res.data);
		};
		if (As3.truthy(resource) && As3.truthy(resource.data) && resource.type == ResourceType.TYPE_BINARY) {
			addImage(resource);
		} else {
			this.loadResource(url, function(param1:Resource):Void {
				addImage(param1);
			}, function():Void {
				if (failed != null) {
					failed();
				}
			}, null, ResourceType.TYPE_BINARY);
		}
		return img;
	}

	// ResourceManager.as:133-145。openfl 的 ApplicationDomain.getDefinition 本身
	// 就是 Type.resolveClass（openfl/system/ApplicationDomain.hx:93-120），原样照翻
	public function getClass(param1:String):Class<Dynamic> {
		var _loc3_:ApplicationDomain = null;
		_loc3_ = ApplicationDomain.currentDomain;
		if (_loc3_.hasDefinition(param1)) {
			return _loc3_.getDefinition(param1);
		}
		return null;
	}

	// ResourceManager.as:147-150
	public function getResource(param1:String):Resource {
		return this.findResource(param1);
	}

	// ResourceManager.as:152-175
	private function fixWH(param1:BitmapData, param2:Float = 670, param3:Float = 800, param4:Bool = false):BitmapData {
		var _loc5_:Int = param1.width;
		var _loc6_:Int = param1.height;
		if (_loc5_ == param2 && _loc6_ == param3) {
			return param1;
		}
		if (_loc5_ / param2 > _loc6_ / param3) {
			_loc6_ = Std.int(_loc6_ / _loc5_ * param2);
			_loc5_ = Std.int(param2);
		} else {
			_loc5_ = Std.int(_loc5_ / _loc6_ * param3);
			_loc6_ = Std.int(param3);
		}
		var _loc7_:Bitmap = new Bitmap(param1, "auto", param4);
		var _loc8_:BitmapData = new BitmapData(_loc5_, _loc6_, true, 0);
		_loc8_.draw(_loc7_, new Matrix(_loc5_ / param1.width, 0, 0, _loc6_ / param1.height, 0, 0), null, null, null,
			param4);
		param1.dispose();
		return _loc8_;
	}

	// ResourceManager.as:177-187
	public function toString():String {
		var _loc2_:String = null;
		var _loc1_:String = "";
		for (_loc2_ in this._dataList) {
			_loc1_ += "[Resource]" + _loc2_ + "," + this._dataList.get(_loc2_) + "\n";
		}
		return _loc1_;
	}

	// ResourceManager.as:189-201
	public function addResource(param1:Resource):Bool {
		// 原版 `Boolean(param1 && param1.url) && Boolean(param1.url.length > 4)`
		if (param1 != null && As3.truthy(param1.url) && param1.url.length > 4 && this.findResource(param1.url) == null) {
			this._dataList.set(param1.url, param1);
			return true;
		}
		return false;
	}

	// ResourceManager.as:203-214。Resource 没有 destroy 方法（原版动态类上也没
	// 定义，调了会在 AS3 抛 ReferenceError）——用 Reflect 复刻动态调用，本 swf
	// 的加载链路不触达这里
	public function removeResource(param1:String):Bool {
		var _loc2_:Resource = this.findResource(param1);
		if (_loc2_ != null) {
			Reflect.callMethod(_loc2_, Reflect.field(_loc2_, "destroy"), []);
			this._dataList.remove(param1);
			return true;
		}
		return false;
	}

	// ResourceManager.as:216-301
	public function loadResource(param1:String, param2:Dynamic = null, param3:Dynamic = null, param4:Dynamic = null,
			param5:String = null):Void {
		var newResource:Resource;
		var succes:Dynamic = null;
		var fault:Dynamic = null;
		var url:String = param1;
		var onCompleted:Dynamic = param2;
		var onError:Dynamic = param3;
		var params:Dynamic = param4;
		var resourceType:String = param5;
		var targetResource:Resource = this.findResource(url);
		if (As3.truthy(targetResource)
			&& As3.truthy(targetResource.data)
			&& (resourceType != null ? targetResource.type == resourceType : true)) {
			if (onCompleted != null) {
				// PORT-NOTE: 同 getImageOrSwf——onCompleted.length 形参检查无可
				// 移植等价，统一按带参调用（多参被忽略）
				onCompleted(targetResource);
			}
			return;
		}
		if (this.loadManager == null) {
			this.loadManager = new LoadManager();
		}
		this.loadManager.addEventListener(LoaderEvent.COMPLETE, succes = function(param1:LoaderEvent):Void {
			if (param1.item.url == url) {
				// `arguments.callee`：命名闭包自引用
				loadManager.removeEventListener(LoaderEvent.COMPLETE, succes);
				var _loc3_:Dynamic = findResource(url);
				if (_loc3_ != param1.item) {
					_dataList.remove(url);
					addResource(param1.item);
				}
				if (fault != null) {
					loadManager.removeEventListener(LoaderEvent.ERROR, fault);
				}
				if (onCompleted != null) {
					onCompleted(param1.item);
				}
			}
		});
		if (onError != null) {
			this.loadManager.addEventListener(LoaderEvent.ERROR, fault = function(param1:LoaderEvent):Void {
				if (As3.truthy(param1.item) && param1.item.url == url) {
					loadManager.removeEventListener(LoaderEvent.ERROR, fault);
					if (succes != null) {
						loadManager.removeEventListener(LoaderEvent.COMPLETE, succes);
					}
					onError();
				}
			});
		}
		newResource = this.loadManager.add(url);
		if (newResource != null) {
			if (resourceType != null) {
				newResource.type = resourceType;
			}
			this.addResource(newResource);
			this.loadManager.start();
		}
	}

	// ResourceManager.as:303-312
	public function getClassInstance(param1:String):Dynamic {
		var _loc2_:Class<Dynamic> = this.getClass(param1);
		if (_loc2_ == null) {
			return null;
		}
		return Type.createInstance(_loc2_, []);
	}

	// ResourceManager.as:314-319
	public function destroy():Void {
		this.removeAll();
		this._dataList = null;
		_instance = null;
	}

	// ResourceManager.as:321-330。同 removeResource：destroy 是动态调用
	public function removeAll():Void {
		var _loc1_:String = null;
		for (_loc1_ in this._dataList) {
			Reflect.callMethod(this._dataList.get(_loc1_), Reflect.field(this._dataList.get(_loc1_), "destroy"), []);
			this._dataList.remove(_loc1_);
		}
	}

	// ResourceManager.as:332-335
	private function findResource(param1:String):Resource {
		return this._dataList.get(param1);
	}
}

// ResourceManager.as:337-344：文件级 internal Enforcer，落为模块私有类
private class Enforcer {
	public function new() {
	}
}
