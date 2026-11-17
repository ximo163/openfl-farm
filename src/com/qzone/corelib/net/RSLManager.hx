package com.qzone.corelib.net;

import common.misc.QzoneJSAPI;
import openfl.display.LoaderInfo;
import openfl.errors.Error;
import openfl.events.Event;
import openfl.events.HTTPStatusEvent;
import openfl.events.IOErrorEvent;
import openfl.events.SecurityErrorEvent;
import openfl.net.URLRequest;
import openfl.system.ApplicationDomain;
import openfl.system.LoaderContext;
import openfl.utils.Dictionary;
import shim.As3;
import shim.LocalSwfLoader;

// RSLManager.as 逐句对应。
// PORT-NOTE(load-swf)：`new Loader()` → shim.LocalSwfLoader（同 RSLLoader）。
class RSLManager {
	// RSLManager.as:18
	public static var applicationDomain:ApplicationDomain;

	// RSLManager.as:20
	private static var instance:RSLManager;

	// RSLManager.as:22。键是 url（String）
	private var _cache:Dictionary<String, Dynamic>;

	// RSLManager.as:24
	public var rslLoader:RSLLoader;

	// RSLManager.as:26-33
	public function new() {
		if (instance != null) {
			throw new Error("实例化单例类出错");
		}
	}

	// RSLManager.as:35-42
	public static function getClass(param1:String):Class<Dynamic> {
		if (applicationDomain.hasDefinition(param1)) {
			return applicationDomain.getDefinition(param1);
		}
		return null;
	}

	// RSLManager.as:44-51
	public static function getInstance():RSLManager {
		if (instance == null) {
			instance = new RSLManager();
		}
		return instance;
	}

	// RSLManager.as:53-61
	public static function getMaterial(param1:String):Dynamic {
		var _loc2_:Class<Dynamic> = getClass(param1);
		if (As3.truthy(_loc2_)) {
			return Type.createInstance(_loc2_, []);
		}
		return null;
	}

	// RSLManager.as:63-111
	private function handleError(param1:Event):Void {
		var _loc9_:HTTPStatusEvent = null;
		var _loc2_:LoaderInfo = Std.isOfType(param1.target, LoaderInfo) ? cast(param1.target, LoaderInfo) : null;
		if (_loc2_ == null) {
			return;
		}
		var _loc3_:String = param1.type;
		var _loc4_:String = _loc2_.url;
		var _loc5_:Dynamic = this._cache.get(_loc4_);
		if (_loc5_ == null) {
			return;
		}
		var _loc6_:Array<Dynamic> = Reflect.field(_loc5_, "fail");
		var _loc7_:Dynamic = null;
		var _loc8_:Bool = true;
		if (_loc3_ == HTTPStatusEvent.HTTP_STATUS) {
			_loc9_ = cast(param1, HTTPStatusEvent);
			if (_loc9_.status == 404 && _loc4_.indexOf("appimg1.") != -1) {
				for (_loc7_ in _loc6_) {
					_loc7_({"404": true});
				}
			}
			if (_loc9_.status < 300) {
				_loc8_ = false;
			} else {
				QzoneJSAPI.reportError("Download file[ " + _loc4_ + "] status " + _loc9_.status, 1);
			}
		}
		if (_loc8_ == true) {
			_loc2_.removeEventListener(Event.COMPLETE, this.onRequestFileSuccess);
			_loc2_.removeEventListener(_loc3_, this.handleError);
			for (_loc7_ in _loc6_) {
				QzoneJSAPI.reportError("Notify download file error " + _loc3_, 1);
				_loc7_(null);
			}
			this._cache.remove(_loc4_);
		}
	}

	// RSLManager.as:113-135
	private function onRequestFileSuccess(param1:Event):Void {
		var _loc5_:Dynamic = null;
		var _loc2_:LoaderInfo = Std.isOfType(param1.target, LoaderInfo) ? cast(param1.target, LoaderInfo) : null;
		if (_loc2_ == null || _loc2_.content == null) {
			throw new Error("System loader error.");
		}
		_loc2_.removeEventListener(Event.COMPLETE, this.onRequestFileSuccess);
		_loc2_.removeEventListener(IOErrorEvent.IO_ERROR, this.handleError);
		_loc2_.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, this.handleError);
		_loc2_.removeEventListener(HTTPStatusEvent.HTTP_STATUS, this.handleError);
		var _loc3_:String = _loc2_.url;
		var _loc4_:Dynamic = this._cache.get(_loc3_);
		if (_loc4_ != null) {
			for (_loc5_ in (Reflect.field(_loc4_, "success") : Array<Dynamic>)) {
				_loc5_(_loc2_.content);
			}
			this._cache.remove(_loc3_);
		}
	}

	// RSLManager.as:137-178。`arguments.callee` 用命名闭包自引用
	public function requestClass(param1:String, param2:Dynamic, param3:String = null, param4:Dynamic = null):Void {
		var name:String = param1;
		var callback:Dynamic = param2;
		var url:String = param3;
		var data:Dynamic = param4;
		// AS3 把 Class 引用当布尔（非 null 恒真）→ 非空判断
		if (getClass(name) != null) {
			if (data != null) {
				if (As3.truthy(callback)) {
					callback(data);
				}
			} else {
				if (As3.truthy(callback)) {
					callback();
				}
			}
		} else {
			if (url == null || url == "") {
				return;
			}
			var completeHandler:Dynamic = null;
			completeHandler = function(param1:Event):Void {
				param1.currentTarget.removeEventListener(Event.COMPLETE, completeHandler);
				requestClass(name, callback, url, data);
			};
			this.rslLoader.loader.contentLoaderInfo.addEventListener(Event.COMPLETE, completeHandler);
			if (url.indexOf("appimg1.") != -1 && callback != null) {
				this.rslLoader.loader.contentLoaderInfo.addEventListener(HTTPStatusEvent.HTTP_STATUS,
					function(param1:HTTPStatusEvent):Void {
						if (param1.status == 404 && data != null) {
							Reflect.setField(data, "404", true);
							callback(data);
						}
					});
			}
			this.rslLoader.load([{"url": url}]);
		}
	}

	// RSLManager.as:180-246
	public function requestFile(param1:String, param2:Dynamic, param3:Dynamic = null):Void {
		var _loc8_:Dynamic = null;
		var _loc9_:Array<Dynamic> = null;
		if (param1 == null || param1 == "") {
			return;
		}
		if (this._cache == null) {
			this._cache = new Dictionary<String, Dynamic>();
		}
		var _loc4_:LocalSwfLoader = null;
		if (this._cache != null && this._cache.get(param1) != null) {
			_loc8_ = this._cache.get(param1);
			if (_loc8_ != null) {
				_loc9_ = Reflect.field(_loc8_, "success");
				if (param2 != null) {
					if (_loc9_ == null) {
						Reflect.setField(_loc8_, "success", [param2]);
					} else if (_loc9_.indexOf(param2) == -1) {
						_loc9_.push(param2);
					}
				}
				_loc9_ = Reflect.field(_loc8_, "fail");
				if (param3 != null) {
					if (_loc9_ == null) {
						Reflect.setField(_loc8_, "fail", [param3]);
					} else if (_loc9_.indexOf(param3) == -1) {
						_loc9_.push(param3);
					}
				}
				return;
			}
		} else {
			_loc4_ = new LocalSwfLoader();
			this._cache.set(param1, {"loader": _loc4_});
			if (param2 != null) {
				Reflect.setField(this._cache.get(param1), "success", [param2]);
			}
			if (param3 != null) {
				Reflect.setField(this._cache.get(param1), "fail", [param3]);
			}
		}
		var _loc5_:LoaderInfo = _loc4_.contentLoaderInfo;
		_loc5_.addEventListener(Event.COMPLETE, this.onRequestFileSuccess, false, 0, true);
		_loc5_.addEventListener(IOErrorEvent.IO_ERROR, this.handleError, false, 0, true);
		_loc5_.addEventListener(SecurityErrorEvent.SECURITY_ERROR, this.handleError, false, 0, true);
		_loc5_.addEventListener(HTTPStatusEvent.HTTP_STATUS, this.handleError, false, 0, true);
		var _loc6_:URLRequest = new URLRequest(param1);
		var _loc7_:LoaderContext = new LoaderContext(false, applicationDomain);
		_loc4_.load(_loc6_, _loc7_);
	}
}
