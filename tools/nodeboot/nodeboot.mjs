// nodeboot —— openfl html5 构建产物的 node 无头启动器（本地排障用）。
//
// 为什么需要：web-smoke（harness/smoke.mjs）要 playwright + 旧 PHP 后端，
// 容器里都没有；CI 失败时 agent 只拿到 pageerror 栈。本工具在 node 里垫出
// DOM/Canvas/XHR 最小环境，把 export/html5/bin 真跑起来复现启动期崩溃：
//  - *.php 请求由固定应答代替（xml.php 的三个 mod 用 tools/nodeboot/render_xml.php
//    从 legacy 部署包离线渲染，mync user/run 用 fixtures/mync-user-run.json——
//    数值取自 legacy/snapshot/initialized.sql 的 uid=1 行，形状按
//    source/core/source/nc/mod/user_run.php 的 echo 模板）。
//  - 其余请求（lib/*.zip 等）静态回 export/html5/bin。
//  - 2d 上下文用万能 Proxy no-op（不渲染，见 tools/run-openfl-node.js 先例）。
//
// 用法：node tools/nodeboot/nodeboot.mjs
// 选项：--timeout <秒>（默认 30，到点仍未 __openflFarmReady 就把已收的
//  console.error/未捕获异常打出来退 1）；--settle <秒>（默认 3，就绪后继续
//  跑的窗口，模拟 CI web-smoke 的 500ms 渲染等待 + 尾部异步回调）；
//  --keep 退出前不关 8123 端口。退出码 1 的三种来源：就绪超时、未捕获异常、
//  缺失资源（服务器 404 / Image src 文件不存在——CI 里对应 console.error）。
// 排障时可临时在 src/ 加 trace()（html5 的 trace 进 console.log，本工具透传），
// 看完即撤。

import http from "node:http";
import { createServer } from "node:http";
import { readFile, copyFile, mkdir, mkdtemp } from "node:fs/promises";
import { existsSync, statSync } from "node:fs";
import { execFileSync } from "node:child_process";
import { tmpdir } from "node:os";
import { join, dirname, resolve } from "node:path";

import { fileURLToPath } from "node:url";

const HERE = dirname(fileURLToPath(import.meta.url));
const REPO = resolve(HERE, "../..");
const BIN = join(REPO, "export/html5/bin");
const PORT = 8123;

const args = process.argv.slice(2);
const keep = args.includes("--keep");
const timeoutSec = Number(args[args.indexOf("--timeout") + 1]) || 30;

// ---------------------------------------------------------------- php 应答
// xml.php 三个 mod 的渲染：拷 legacy source/core 的依赖子集到临时目录
//（cache.func.php 会按相对路径写 data/ 缓存，不能让它碰只读的 legacy/）。
const XMLMODS = {
  "load_main_v_20120905.xml": "nc_main",
  "data_zh_CN_v_20120905.xml": "nc_data",
  "addon_v_20120905.xml": "nc_addon",
};
const CORE = join(REPO, "legacy/deploy/QFarmFlash/source/core");

async function renderXmls() {
  const work = await mkdtemp(join(tmpdir(), "nodeboot-core-"));
  const dirs = ["source/xml/mod", "source", "config/nc", "data/nc"];
  for (const d of dirs) await mkdir(join(work, d), { recursive: true });
  await copyFile(join(CORE, "source/cache.func.php"), join(work, "source/cache.func.php"));
  for (const m of Object.values(XMLMODS)) {
    await copyFile(join(CORE, `source/xml/mod/${m}.php`), join(work, `source/xml/mod/${m}.php`));
  }
  for (const f of ["cropstime", "cropstype", "itemtype"]) {
    await copyFile(join(CORE, `config/nc/${f}.php`), join(work, `config/nc/${f}.php`));
  }
  const base = `http://127.0.0.1:${PORT}`;
  const bodies = {};
  for (const [mod, php] of Object.entries(XMLMODS)) {
    bodies[mod] = execFileSync(
      "php", [join(HERE, "render_xml.php"), php, base], { cwd: work, maxBuffer: 64 << 20 },
    );
  }
  return bodies;
}

const myncBody = await readFile(join(HERE, "fixtures/mync-user-run.json"), "utf8");
const xmlBodies = await renderXmls();

// ---------------------------------------------------------------- 静态+php 服务
// missing：本进程发现的所有缺失资源（服务器 404 + Image src 不存在）。
// 与 CI web-smoke 的失败条件对齐（console.error 任一条即 FAIL），就绪后
// settle 窗口内新增的也计入，非零退出。
const missing = [];
const server = createServer(async (req, res) => {
  const u = new URL(req.url, `http://127.0.0.1:${PORT}`);
  const path = decodeURIComponent(u.pathname);
  try {
    if (path.endsWith(".php")) {
      let body = null, type = "text/html; charset=utf-8";
      if (path.endsWith("xml.php")) {
        const mod = u.searchParams.get("mod") || "";
        body = xmlBodies[mod];
        type = "application/xml";
      } else if (path.endsWith("mync.php")) {
        body = myncBody;
      }
      if (body == null) {
        console.log(`[nodeboot] 未应答的 php：${req.method} ${req.url}`);
        res.writeHead(404); res.end(); return;
      }
      res.writeHead(200, { "Content-Type": type, "Cache-Control": "no-cache" });
      res.end(body);
      return;
    }
    const file = join(BIN, path.replace(/^([\\/])+/, ""));
    if (!file.startsWith(BIN) || !existsSync(file) || statSync(file).isDirectory()) {
      console.log(`[nodeboot] 404：${req.url}`);
      missing.push(`404 ${req.url}`);
      res.writeHead(404); res.end(); return;
    }
    const ext = file.slice(file.lastIndexOf(".")).toLowerCase();
    const mime = {
      ".js": "text/javascript", ".html": "text/html", ".css": "text/css",
      ".json": "application/json", ".zip": "application/zip", ".png": "image/png",
      ".swf": "application/x-shockwave-flash", ".ogg": "audio/ogg", ".mp3": "audio/mpeg",
    }[ext] || "application/octet-stream";
    res.writeHead(200, { "Content-Type": mime });
    res.end(await readFile(file));
  } catch (e) {
    console.log(`[nodeboot] 服务出错 ${req.url}: ${e && e.message}`);
    res.writeHead(500); res.end();
  }
});
await new Promise((r) => server.listen(PORT, "127.0.0.1", r));

// ---------------------------------------------------------------- DOM 垫片
// 万能对象：任意属性取值都回到自身，任意调用都返回自身，数值化得 0。
// 渲染相关的 ctx/gradient 等全走它（本工具不渲染画面，只跑逻辑）。
function magic() {
  return new Proxy(function () {}, {
    get(t, k) {
      if (k === Symbol.toPrimitive) return () => 0;
      if (k === "length") return 0;
      if (k === "data") return new Uint8ClampedArray(0);
      return magic();
    },
    set() { return true; },
    apply() { return magic(); },
    construct() { return magic(); },
  });
}

// style 垫片：lime/openfl 会 setProperty/removeProperty + 任意属性直写
function mkStyle() {
  return new Proxy({}, {
    get(t, k) {
      if (k === Symbol.toPrimitive) return () => "";
      if (k in t) return t[k];
      return () => undefined;
    },
    set(t, k, v) { t[k] = v; return true; },
  });
}

class Element {
  constructor(tag) {
    this.tagName = tag.toUpperCase();
    this.children = [];
    this.style = mkStyle();
    this.width = 0; this.height = 0;
    this._listeners = {};
  }
  appendChild(c) { this.children.push(c); c.parent = this; return c; }
  removeChild(c) { const i = this.children.indexOf(c); if (i >= 0) this.children.splice(i, 1); return c; }
  addEventListener(t, f) { (this._listeners[t] ||= []).push(f); }
  removeEventListener(t, f) { const l = this._listeners[t] || []; const i = l.indexOf(f); if (i >= 0) l.splice(i, 1); }
  setAttribute() {} getAttribute() { return null; }
  getBoundingClientRect() { return { left: 0, top: 0, right: this.width || 860, bottom: this.height || 500, width: this.width || 860, height: this.height || 500 }; }
  getContext(kind) {
    if (kind === "2d") { this._ctx ||= magic(); return this._ctx; }
    return null; // webgl：让 openfl 回退 2d
  }
  focus() {}
}
class CanvasElement extends Element {
  constructor() { super("canvas"); this.width = 860; this.height = 500; }
}
const elements = {};
function mkEl(tag) { return tag.toLowerCase() === "canvas" ? new CanvasElement() : new Element(tag); }
const contentEl = mkEl("div");
elements["openfl-content"] = contentEl;

globalThis.window = globalThis;
globalThis.self = globalThis;
globalThis.location = { href: `http://127.0.0.1:${PORT}/index.html`, hostname: "127.0.0.1", port: String(PORT), protocol: "http:", search: "", replace() {} };
globalThis.navigator = { userAgent: "nodeboot", language: "zh", languages: ["zh"], platform: "Linux", maxTouchPoints: 0, vendor: "" };
globalThis.devicePixelRatio = 1;
globalThis.screen = { width: 860, height: 500 };
globalThis.performance = globalThis.performance || { now: () => Date.now() };
globalThis.addEventListener = () => {};
globalThis.removeEventListener = () => {};
globalThis.dispatchEvent = () => true;
globalThis.localStorage = { getItem: () => null, setItem() {}, removeItem() {} };
globalThis.sessionStorage = globalThis.localStorage;
globalThis.requestAnimationFrame = (f) => setTimeout(() => f(Date.now()), 16);
globalThis.cancelAnimationFrame = (id) => clearTimeout(id);
globalThis.getComputedStyle = () => magic();
globalThis.AudioContext = class { constructor() { return magic(); } };
globalThis.document = {
  createElement: mkEl, createElementNS: (ns, tag) => mkEl(tag),
  getElementById: (id) => elements[id] || null,
  querySelector: () => null, querySelectorAll: () => [],
  documentElement: mkEl("html"), body: mkEl("body"),
  addEventListener() {}, removeEventListener() {},
  createEvent: () => magic(),
  hidden: false,
};

// XMLHttpRequest：走本进程的 8123 服务。SwfUrlBase（src/shim/SwfUrlBase.hx）会
// 包 prototype.open 把相对 *.php 改写成 home/qqfarm/core/ 前缀，这里只管
// URL 解析和取回；responseType=arraybuffer 供 lime 的 zip 字节加载。
class XMLHttpRequest {
  constructor() {
    this.readyState = 0;
    this.status = 0;
    this.responseText = "";
    this._listeners = {};
  }
  open(method, url) {
    this._method = method;
    this._url = new URL(url, globalThis.location.href).href;
  }
  setRequestHeader() {}
  getResponseHeader() { return null; }
  getAllResponseHeaders() { return ""; }
  abort() { this._aborted = true; }
  overrideMimeType() {}
  addEventListener(t, f) { (this._listeners[t] ||= []).push(f); }
  removeEventListener(t, f) { const l = this._listeners[t] || []; const i = l.indexOf(f); if (i >= 0) l.splice(i, 1); }
  _fire(t, ev) { ev = ev || {}; ev.type = t; ev.target = this; const h = this["on" + t]; if (h) h(ev); for (const f of this._listeners[t] || []) f(ev); }
  send(body) {
    const u = new URL(this._url);
    const req = http.request({ hostname: u.hostname, port: u.port || PORT, path: u.pathname + u.search, method: this._method || "GET", headers: { "Content-Type": "application/x-www-form-urlencoded" } }, (up) => {
      const chunks = [];
      up.on("data", (c) => chunks.push(c));
      up.on("end", () => {
        this.status = up.statusCode || 0;
        this.readyState = 4;
        const buf = Buffer.concat(chunks);
        this.responseText = buf.toString("utf8");
        if (this.responseType === "arraybuffer") {
          this.response = buf.buffer.slice(buf.byteOffset, buf.byteOffset + buf.byteLength);
        } else {
          this.response = this.responseText;
        }
        this._fire(up.statusCode >= 400 ? "error" : "load");
        this._fire("readystatechange");
      });
    });
    req.on("error", (e) => { this._fire("error", { message: String(e) }); });
    if (body) req.write(body);
    req.end();
  }
}
globalThis.XMLHttpRequest = XMLHttpRequest;

// fetch 垫片：新 lime 部分路径用 fetch 拉字节，统一转 XHR
globalThis.fetch = (url, opts) => new Promise((acc, rej) => {
  const xhr = new XMLHttpRequest();
  xhr.responseType = (opts && opts.responseType) || "arraybuffer";
  xhr.open((opts && opts.method) || "GET", String(url));
  xhr.onload = () => (xhr.status >= 400 ? rej(new Error("fetch " + xhr.status)) : acc({ ok: true, status: xhr.status, arrayBuffer: async () => xhr.response, text: async () => xhr.responseText, json: async () => JSON.parse(xhr.responseText) }));
  xhr.onerror = (e) => rej(new Error("fetch error"));
  xhr.send(opts && opts.body);
});

// ---------------------------------------------------------------- 跑游戏
process.on("uncaughtException", (e) => {
  console.log("[nodeboot] uncaughtException:");
  console.log(e && e.stack ? e.stack : String(e));
  finish(1);
});

let finished = false;
function finish(code) {
  if (finished) return;
  finished = true;
  if (!keep) server.close();
  process.exit(code);
}

const watchdog = setTimeout(() => {
  console.log(`[nodeboot] ${timeoutSec}s 到点仍未就绪（__openflFarmReady=${globalThis.__openflFarmReady}）`);
  finish(1);
}, timeoutSec * 1000);
watchdog.unref?.();

globalThis.HTMLCanvasElement = CanvasElement;
globalThis.HTMLDivElement = Element;
globalThis.HTMLElement = Element;
// Image：lime 的位图加载用 addEventListener("load"/"error") + 属性直读。
// nodeboot 不解码真像素，但必须核 src 对应文件在 export/html5/bin 里真实存在
// 再发 load——否则缺图在本地永远静默（浏览器里是 console.error 404，
// CI web-smoke 挂在这上面两轮而 nodeboot 一直绿，2026-11-19 issue #8 教训）。
class ImageShim {
  constructor() {
    this.width = 0; this.height = 0;
    this._listeners = {};
  }
  addEventListener(t, f) { (this._listeners[t] ||= []).push(f); }
  removeEventListener(t, f) { const l = this._listeners[t] || []; const i = l.indexOf(f); if (i >= 0) l.splice(i, 1); }
  _fire(t) { const ev = { type: t, target: this }; const h = this["on" + t]; if (h) h(ev); for (const f of this._listeners[t] || []) f(ev); }
  set src(v) {
    this._src = v;
    let bad = false;
    try {
      const u = new URL(v, globalThis.location.href);
      if (u.protocol === "http:" || u.protocol === "https:") {
        const p = decodeURIComponent(u.pathname).replace(/^([\\/])+/, "");
        if (!existsSync(join(BIN, p))) bad = true;
      }
    } catch { /* blob:/data: 等非文件 src 不核 */ }
    if (bad) {
      console.log(`[nodeboot] image 404：${v}`);
      missing.push(`image 404 ${v}`);
    }
    // 照旧发 load（nodeboot 不模拟加载失败的错误路径，只负责让缺失可见）
    setTimeout(() => this._fire("load"), 1);
  }
  get src() { return this._src || ""; }
}
globalThis.Image = ImageShim;
globalThis.HTMLImageElement = ImageShim;
globalThis.HTMLVideoElement = Element;
globalThis.HTMLStyleElement = Element;
globalThis.HTMLInputElement = Element;
globalThis.HTMLAnchorElement = Element;
globalThis.HTMLIFrameElement = Element;
globalThis.HTMLDocument = globalThis.document && globalThis.document.constructor;
globalThis.Element = Element;
globalThis.Node = Element;
globalThis.Event = class Event { constructor(type) { this.type = type; } };
globalThis.MouseEvent = class MouseEvent extends globalThis.Event { };
globalThis.KeyboardEvent = class KeyboardEvent extends globalThis.Event { };
globalThis.TouchEvent = class TouchEvent extends globalThis.Event { };
globalThis.WheelEvent = class WheelEvent extends globalThis.Event { };
globalThis.CustomEvent = class CustomEvent extends globalThis.Event { constructor(t, o) { super(t); this.detail = o && o.detail; } };

globalThis.CanvasRenderingContext2D = class CanvasRenderingContext2D { };
globalThis.WebGLRenderingContext = class WebGLRenderingContext { };
globalThis.WebGL2RenderingContext = class WebGL2RenderingContext { };
globalThis.ImageData = class ImageData { constructor(w, h) { this.width = w; this.height = h; this.data = new Uint8ClampedArray(0); } };
globalThis.Path2D = class Path2D { };
globalThis.DOMMatrix = class DOMMatrix { };
globalThis.TextMetrics = class TextMetrics { width = 0; };
globalThis.FormData = class FormData { append() {} };
globalThis.Blob = class Blob { };
globalThis.FileReader = class FileReader { readAsArrayBuffer() { setTimeout(() => this.onload && this.onload(), 1); } readAsText() { setTimeout(() => this.onload && this.onload(), 1); } };
globalThis.WebSocket = class WebSocket { constructor() { return magic(); } };
globalThis.MutationObserver = class MutationObserver { observe() {} disconnect() {} };
globalThis.Worker = class Worker { constructor() { return magic(); } };

// blob: URL：node 的 URL.createObjectURL 只收 node Blob，垫成发号器；
// Image shim 对任意 src 异步触发 onload 即可
globalThis.URL.createObjectURL = () => `blob:nodeboot-${++globalThis.__blobSeq}`;
globalThis.URL.revokeObjectURL = () => {};
globalThis.__blobSeq = 0;

// 以 script 方式执行（vm.runInThisContext）：走 CommonJS require 时 pako 的
// UMD 会整体顶掉 module.exports，lime 命名空间就丢了；script 方式下
// $hx_exports 落到 window（已指向 globalThis），lime.embed 从 window 拿。
// 全局必须先垫齐再执行（见上）。
import vm from "node:vm";
const bundleCode = await readFile(join(BIN, "OpenflFarm.js"), "utf8");
vm.runInThisContext(bundleCode, { filename: "OpenflFarm.js" });
const lime = globalThis.lime;
if (!lime || !lime.embed) {
  console.log("[nodeboot] 找不到 lime.embed——先 haxelib run openfl build html5");
  finish(1);
}
lime.embed("OpenflFarm", "openfl-content", 860, 500, { parameters: {} });

// 就绪轮询：Main.hx 首帧设 __openflFarmReady（与 harness/smoke.mjs 同一标记）。
// 就绪后不立即退：CI web-smoke 会再等 500ms 让画面渲染，启动尾部的异步加载
// （装饰库 COMPLETE 回调、位图 decode）都发生在就绪标记之后——本工具同样
// 留一个 settle 窗口再收尾，窗口内冒出的缺失资源/异常计入退出码。
const settleMs = (Number(args[args.indexOf("--settle") + 1]) || 3) * 1000;
let readyAt = 0;
const poll = setInterval(() => {
  if (!globalThis.__openflFarmReady) return;
  if (!readyAt) {
    readyAt = Date.now();
    clearTimeout(watchdog);
    console.log(`[nodeboot] 就绪：__openflFarmReady 已置位（settle ${settleMs / 1000}s）`);
  }
  if (Date.now() - readyAt >= settleMs) {
    clearInterval(poll);
    if (missing.length) {
      for (const m of missing) console.log(`[nodeboot] 缺失资源 ${m}`);
      console.log(`[nodeboot] FAIL：${missing.length} 个缺失资源`);
      finish(1);
    }
    finish(0);
  }
}, 250);
poll.unref?.();
