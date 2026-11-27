package common;

import openfl.errors.Error;

/**
 * common.INI —— INI.as（mcloader_v_53/scripts，预加载器与 Master2 同应用
 * 域共享，Master2 反编译里无此文件）的签名面 stub（原类 171 loc，mcloader
 * 片真身待译——后续模块；issue #19 只保 Version/ProfileLog 读配置用的
 * getInstance/data）。真身持 xml.php 下发配置的 E4X XML，getPostUrl/getHost
 * 等取值方法随真身补。
 */
@:keep
class INI {
	// INI.as:7
	private static var instance:INI;

	// INI.as:9（XML；stub 以 Dynamic 承接，恒 null）
	private var _data:Dynamic;

	// INI.as:11-18（ctor(param1:XML)，单例守卫）
	public function new(param1:Dynamic) {
		if (instance != null) {
			throw new Error("实例化单例类出错-INI");
		}
		this.data = param1;
	}

	// INI.as:20-27（getInstance(param1:Object = null)：经 XML() 转换后建）
	public static function getInstance(param1:Dynamic = null):INI {
		if (instance == null) {
			instance = new INI(param1);
		}
		return instance;
	}

	// INI.as:60（data）
	public var data(get, set):Dynamic;

	private function get_data():Dynamic {
		return this._data;
	}

	private function set_data(param1:Dynamic):Dynamic {
		this._data = param1;
		return param1;
	}

	// INI.as:30-47（签名面 stub：mode=="qzone" 或 xymode=="" → postUrl.@url
	// 否则 .@url_pengyou——真身随 mcloader 片，issue #88 命令层测试需要签名）
	public function getPostUrl():String {
		throw new Error("not implemented");
	}
}
