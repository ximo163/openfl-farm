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
//  退出码 2：--visual 基建缺（视觉引导模块未编译）。排障时可临时在 src/ 加
//  trace()（html5 的 trace 进 console.log，本工具透传），看完即撤。

// --drive <mjs>：就绪 + settle 干净后不退出，动态 import 该模块并 await 其
//  default(ctx)——在同一进程/全局里驱动交互链（CI web-smoke 不点鼠标，链路
//  证据在本地补）。ctx = { missing, finish, myncLog, sleep, net, realDateNow }；
//  返回值作退出码，抛异常按 1 退。--drive 时 mync 应答先按 mod/act 查
//  fixtures/mync-<mod>-<act>.json，没有才回落 user_run 整包；所有 mync 请求
//  （URL+POST body）记进 myncLog 供驱动断言。--drive-timeout <秒>（默认 60）
//  是驱动自身的兜底时限。

// --visual（须与 --drive 连用）：先执行 export/scenario-gate/visual-boot.js
//  （tools/ScenarioVisual.hx 编译产物）再跑游戏 bundle——#57 的软画布截图
//  通道 + #59 的确定性虚拟钟（游戏时间冻结、只在驱动泵帧时前进，nodeboot/
//  驱动的自有计时钉在真实引用上）。就绪等待与 settle 全交给驱动的引导协议。
//  net（ctx 传入）= { inFlight, mutations }：在途请求数/网络动作累计数，
//  驱动判「网络静默才泵帧」用。

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
// --visual：装 #59 的视觉引导模块（软画布截图 + 确定性虚拟钟，见
// tools/ScenarioVisual.hx 类头）——游戏时间冻结、只在驱动泵帧时前进，本文件
// 自己的计时必须钉在真实引用上（下方 realSetTimeout 一组），否则看门狗/
// 轮询/sleep 进虚拟域自死锁。非 visual 模式这些引用就是全局本尊，行为不变。
const visual = args.includes("--visual");
const realSetTimeout = setTimeout;
const realClearTimeout = clearTimeout;
const realSetInterval = setInterval;
const realClearInterval = clearInterval;
const realDateNow = Date.now;
const timeoutSec = Number(args[args.indexOf("--timeout") + 1]) || 30;
// indexOf 未命中得 -1，+1 后取到 args[0]：无 --drive 但带任何 flag 的纯启动
// （如 --timeout 45）会把首参当模块路径 import 而炸——必须先判命中。
const driveIdx = args.indexOf("--drive");
const drivePath = driveIdx >= 0 ? args[driveIdx + 1] : undefined;
const driveTimeoutSec = Number(args[args.indexOf("--drive-timeout") + 1]) || 60;
// mync 请求流水（--drive 断言用）：URL + POST body
const myncLog = [];

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
        // POST body 先收：myncLog 记录（URL+body）+ 按 place 选应答都要用它
        let postBody = "";
        await new Promise((r) => { req.on("data", (c) => postBody += c); req.on("end", r); });
        myncLog.push({ url: req.url, body: postBody });
        // --drive 时按 mod/act 精确应答（fixtures/mync-<mod>-<act>.json，形状抄
        // nc/mod 对应 php 的 echo）。带 place 的请求先试
        // fixtures/mync-<mod>-<act>-<place>.json：真实 PHP 把请求的 place 回显进
        // farmlandIndex（farmlandstatus_planting.php:79 "farmlandIndex":$place，
        // water :65 / harvest :94-95 同款），而客户端按应答的 farmlandIndex 落地
        // （onOperateSuccessPlant 等），不分 place 的应答会把「种 4 号地」落到
        // 0 号地（issue #17 场景实测踩中）。没有按 place 的文件再回落
        // mync-<mod>-<act>.json、user_run 整包
        if (drivePath) {
          const mod = u.searchParams.get("mod") || "";
          const act = u.searchParams.get("act") || "";
          const place = new URLSearchParams(postBody).get("place");
          const placeFile = mod && act && place != null ? join(HERE, "fixtures", `mync-${mod}-${act}-${place}.json`) : null;
          const actFile = mod && act ? join(HERE, "fixtures", `mync-${mod}-${act}.json`) : null;
          body = placeFile && existsSync(placeFile) ? await readFile(placeFile, "utf8")
            : actFile && existsSync(actFile) ? await readFile(actFile, "utf8")
              : myncBody;
        } else {
          body = myncBody;
        }
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
// net 计数（--visual 驱动的引导协议用）：inFlight = 在途请求数，mutations =
// 发送+完成的累计动作数——「泵帧只发生在网络静默时」要靠它判静默（一次
// poll 窗口内发送又完成的请求对 inFlight 不可见，对 mutations 可见）。
const net = { inFlight: 0, mutations: 0 };
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
  _done() { if (!this._settled) { this._settled = true; net.inFlight--; net.mutations++; } }
  send(body) {
    const u = new URL(this._url);
    net.inFlight++;
    net.mutations++;
    // 出网请求（http/https 且主机非本进程）：资产已全部本地化，离开本进程的
    // 请求在任何部署外环境都注定失败——CI web-smoke 记一条 console.error 的
    // 资源错。不真发：外网地址在本机可能连上（挂死不结算）也可能拒（看环境），
    // 结果随环境漂移；统一计缺失 + 走 error 事件，与浏览器侧「请求失败」对齐。
    // 检测盲区实锤：#9 头像（headPic=快照 UC_API 的局域网地址）两轮 CI 同点
    // 红，nodeboot 却一直绿——XHR 出网无计数，本条补齐。
    if ((u.protocol === "http:" || u.protocol === "https:") && u.hostname !== "127.0.0.1") {
      console.log(`[nodeboot] 出网请求：${this._method || "GET"} ${this._url}`);
      // 打栈到游戏侧调用方（约 8 帧 openfl/lime 内部之后）：排查正路同 /N?数字
      // 404 的教训（lessons #8 条目）——别猜是谁发的，看帧。
      console.log((new Error("出网请求来源")).stack.split("\n").slice(2, 14).join("\n"));
      missing.push(`off-origin ${this._url}`);
      // 真实 setTimeout：visual 模式下全局 setTimeout 是虚拟定时器（只在泵帧时
      // 触发），错误事件挂进去会让引导协议永远等不到「在途清零」
      realSetTimeout(() => { this._done(); this._fire("error", { message: "off-origin request" }); }, 1);
      return;
    }
    const req = http.request({ hostname: u.hostname, port: u.port || PORT, path: u.pathname + u.search, method: this._method || "GET", headers: { "Content-Type": "application/x-www-form-urlencoded" } }, (up) => {
      const chunks = [];
      up.on("data", (c) => chunks.push(c));
      up.on("end", () => {
        this._done();
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
    req.on("error", (e) => { this._done(); this._fire("error", { message: String(e) }); });
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

const watchdog = realSetTimeout(() => {
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
// --visual：先执行视觉引导模块（#57 软画布钩子 + #59 虚拟钟），再执行游戏
// bundle。顺序不可换：bundle 静态初始化把 performance.now 绑进 HxOverrides.now
// （Timer.stamp 的源头，闭包里够不到本体）——绑定捕获「当时的函数」，补丁
// 晚于 bundle 就永远不生效；canvas/Image 钩子同理（游戏画布在 embed 时创建）。
if (visual) {
  const bootPath = join(REPO, "export/scenario-gate/visual-boot.js");
  if (!existsSync(bootPath)) {
    console.log(`[nodeboot] 缺 ${bootPath}（scenario.mjs run 会先编译；手动跑须 haxe -cp tools -lib format -js 该路径 -main ScenarioVisual）`);
    finish(2);
  }
  vm.runInThisContext(await readFile(bootPath, "utf8"), { filename: "visual-boot.js" });
  if (!globalThis.__openflFarmVisual) {
    console.log("[nodeboot] visual-boot 执行后没有 __openflFarmVisual（编译产物损坏？）");
    finish(2);
  }
}
const bundleCode = await readFile(join(BIN, "OpenflFarm.js"), "utf8");
vm.runInThisContext(bundleCode, { filename: "OpenflFarm.js" });
const lime = globalThis.lime;
if (!lime || !lime.embed) {
  console.log("[nodeboot] 找不到 lime.embed——先 haxelib run openfl build html5");
  finish(1);
}
lime.embed("OpenflFarm", "openfl-content", 860, 500, { parameters: {} });

if (!visual) {
  // 就绪轮询：Main.hx 首帧设 __openflFarmReady（与 harness/smoke.mjs 同一标记）。
  // 就绪后不立即退：CI web-smoke 会再等 500ms 让画面渲染，启动尾部的异步加载
  // （装饰库 COMPLETE 回调、位图 decode）都发生在就绪标记之后——本工具同样
  // 留一个 settle 窗口再收尾，窗口内冒出的缺失资源/异常计入退出码。
  const settleMs = (Number(args[args.indexOf("--settle") + 1]) || 3) * 1000;
  let readyAt = 0;
  // --drive 分支 await 交互驱动，回调升 async（fire-and-forget：drive 内部自兜底）
  const poll = setInterval(async () => {
    if (!globalThis.__openflFarmReady) return;
    if (!readyAt) {
      readyAt = Date.now();
      realClearTimeout(watchdog);
      console.log(`[nodeboot] 就绪：__openflFarmReady 已置位（settle ${settleMs / 1000}s）`);
    }
    if (Date.now() - readyAt >= settleMs) {
      realClearInterval(poll);
      if (missing.length) {
        for (const m of missing) console.log(`[nodeboot] 缺失资源 ${m}`);
        console.log(`[nodeboot] FAIL：${missing.length} 个缺失资源`);
        finish(1);
      }
      if (!drivePath) finish(0);
      else await drive();
    }
  }, 250);
  poll.unref?.();
} else {
  // visual 模式不在此处等就绪：就绪标记在 Main 首帧（ENTER_FRAME）置位，而
  // 游戏时间已冻结——帧由驱动的引导协议泵（[等真实网络交付→网络静默时泵 1
  // 帧] 循环，见 scenario.mjs drive 的引导段）。settle 窗口也一并交给驱动
  // （异步加载的 COMPLETE 回调都在交付时刻跑，缺失资源照进 missing）。
  if (!drivePath) {
    console.log("[nodeboot] --visual 必须与 --drive 连用（视觉引导协议由驱动模块执行）");
    finish(2);
  }
  // 启动看门狗到此为止：引导/驱动的时限由 driveTimeoutSec 看门狗接管
  realClearTimeout(watchdog);
  await drive();
}

// ---------------------------------------------------------------- 交互链驱动
// settle 干净后接 --drive 的模块：跑在同一个 globalThis 里（OpenflFarm.js 经
// runInThisContext 落进来，openfl_Lib/$hxClasses 等全可及）。驱动抛异常或超时
// 都按 FAIL 退；正常结束打 PASS。
// sleep 走真实 setTimeout（驱动自用时游戏钟是冻结的，虚拟 setTimeout 会
// 永不归队）；ctx 附 realDateNow（驱动的等待计时同理由）与 net（引导协议
// 的网络静默判定）。
const sleep = (ms) => new Promise((r) => realSetTimeout(r, ms));
async function drive() {
  const driverWatch = realSetTimeout(() => {
    console.log(`[nodeboot] drive ${driveTimeoutSec}s 超时`);
    finish(1);
  }, driveTimeoutSec * 1000);
  driverWatch.unref?.();
  try {
    const mod = await import(drivePath.startsWith("/") ? drivePath : join(REPO, drivePath));
    const code = await mod.default({ missing, finish, myncLog, sleep, net, realDateNow });
    realClearTimeout(driverWatch);
    if (missing.length) {
      for (const m of missing) console.log(`[nodeboot] 缺失资源 ${m}`);
      console.log(`[nodeboot] FAIL：${missing.length} 个缺失资源`);
    }
    console.log(code === 1 ? "[nodeboot] drive FAIL" : "[nodeboot] drive PASS");
    finish(code === 1 || missing.length ? 1 : 0);
  } catch (e) {
    console.log("[nodeboot] drive 抛异常：");
    console.log(e && e.stack ? e.stack : String(e));
    finish(1);
  }
}
