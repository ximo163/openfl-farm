package support;

import openfl.display.Loader;
import openfl.net.URLRequest;

/**
 * Loader 记录型替身（issue #87 write-tests，CropLoaderTest 用）：CropLoader
 * 的 loadNext 对非空 url 调 `this._loader.load(new URLRequest(url))`
 * （CropLoader.as:107）——openfl 9.5.2 真身 load() 首行读
 * `Lib.current.loaderInfo.url`，eval 无 Lib.current 应用实例，裸 URLLoader
 * 路径直接 null 字段访问崩（容器内实测 "field access on null"）。本类覆写
 * load 只记 url 不出网，让 FIFO 顺序测试能驱动真 url（非空串走真值门进
 * load 分支）而不依赖网络/应用实例。构造零副作用（Loader 真 ctor 本就空转，
 * 无定时器/单例守卫，与 HTTPRequest 不同——可正常 new）。
 */
class RecordingLoader extends Loader {
	// 每次 load 的 url 顺序记录——FIFO 断言的依据
	public var loadedUrls:Array<String> = [];

	public function new() {
		super();
	}

	public override function load(request:URLRequest, context:openfl.system.LoaderContext = null):Void {
		loadedUrls.push(request.url);
	}
}
