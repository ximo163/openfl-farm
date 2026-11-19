package shim;

/**
 * flash.net.LocalConnection 的目标相关等价物（CLAUDE.md：openfl 对
 * LocalConnection 支持不完整，等价物进 shim）。
 *
 * 为什么是空实现：原版唯一的调用点是 module.Main.gc（Main.as:160-171）——
 * Flash Player 时代连两次 connect("MoonSpirit") 靠第二次抛错强制 GC 的 hack；
 * openfl/html5 没有这个 GC 通道，也没有跨 swf 的 LocalConnection 语义，
 * 等价物就是无操作（调用点自带 try/catch，抛不抛对外行为一致）。
 */
class LocalConnection {
	public function new() {}

	public function connect(param1:String):Void {}

	public function close():Void {}
}
