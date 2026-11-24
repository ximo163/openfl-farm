// node 跑 openfl/js 构建产物（如 tools/StepAnimate.hx 编出的 step.js）的最小环境垫片。
// 为什么需要：lime/openfl 的 js 静态初始化链要 location/document/pako，node 里没有；
// 本垫片只服务「装 swf 库 + 时间轴固定步长推进」，不渲染，2d 上下文全 no-op。
//
// 用法：node tools/run-openfl-node.js <step.js> [step.js 的参数...]
// 编译：haxe -cp tools -lib lime -lib swf -lib openfl -js step.js -main StepAnimate
globalThis.pako = require('/usr/local/lib/haxelib/lime/8,3,2/dependencies/pako.min.js');

function mkCtx(el) {
  return new Proxy({}, {
    get(t, k) {
      if (k === "canvas") return el;
      if (k === "getImageData") return (x, y, w, h) => ({ data: new Uint8ClampedArray(w * h * 4), width: w, height: h });
      if (k === "createImageData") return (w, h) => ({ data: new Uint8ClampedArray(w * h * 4), width: w, height: h });
      if (k === "measureText") return () => ({ width: 0 });
      return () => undefined;
    },
    set() { return true; },
  });
}
function mkEl() {
  const el = {
    style: {}, width: 0, height: 0,
    appendChild() {}, removeChild() {}, addEventListener() {}, removeEventListener() {},
    setAttribute() {}, getAttribute() { return null; },
    getContext(kind) { return kind === "2d" ? mkCtx(el) : null; },
    getBoundingClientRect() { return { left: 0, top: 0, right: 0, bottom: 0, width: 0, height: 0 }; },
  };
  return el;
}
globalThis.location = { href: "http://localhost/", search: "", protocol: "http:", replace() {} };
globalThis.navigator = globalThis.navigator || { userAgent: "node", language: "zh", languages: ["zh"], platform: "Linux" };
globalThis.document = {
  createElement: mkEl, createElementNS: mkEl,
  getElementById: () => null, querySelector: () => null,
  documentElement: { style: {} }, body: { appendChild() {}, style: {} }, addEventListener() {},
};
globalThis.window = globalThis;
globalThis.addEventListener = () => {};
globalThis.requestAnimationFrame = (f) => setTimeout(() => f(Date.now()), 16);

// window.Image：node 没有图片解码，而 lime 的 HTML5HTTPRequest.__loadImage
// （:448 new window.Image()）装库里的位图符号（AnimateLibrary.loadImage →
// Image.loadFromBytes → blob: URI）。时间轴门禁只推进帧不渲染，位图只需
// 「加载成功」让 Future 完成：1×1 尺寸 + 设 src 同步派发 load（监听器在
// 赋 src 前就挂好，:462→:489；lime Future 对已完成态补调 onComplete）。
// 真要碰像素的地方由上面 mkCtx 的 no-op 2d 上下文兜底。
class FakeImage {
  constructor() {
    this.width = 1; this.height = 1;
    this.crossOrigin = null;
    this.onload = null; this.onerror = null; this.onprogress = null;
    this._listeners = {}; this._src = null;
  }
  addEventListener(type, fn) { (this._listeners[type] || (this._listeners[type] = [])).push(fn); }
  removeEventListener(type, fn) {
    const l = this._listeners[type];
    if (l) { const i = l.indexOf(fn); if (i >= 0) l.splice(i, 1); }
  }
  _dispatch(type, ev) {
    const e = ev || { type };
    for (const f of (this._listeners[type] || []).slice()) f(e);
    const on = this["on" + type];
    if (typeof on === "function") on(e);
  }
  get src() { return this._src; }
  set src(v) { this._src = v; this._dispatch("load"); }
  decode() { return Promise.resolve(this); }
}
globalThis.Image = FakeImage;

// StepAnimate 的参数适配：node 下 process.argv[2] 是垫片自己的入口，
// 移交给被 require 的脚本前先摘掉
const script = process.argv[2];
process.argv.splice(2, 1);
require(script);
