// web-smoke：在无头浏览器里加载构建产物，确认能渲染、无报错、冒烟标记出现。
// 由人维护（harness/ 受保护）。用法：node smoke.mjs <index.html 路径>
// 退出码：0 通过；1 失败（失败原因打到 stdout，截图存 harness/smoke-failure.png）。
//
// 必须走 http 而不是 file://：swf 库把每个 <library> 编成 lib/<id>.zip，
// 运行时 XHR 加载，file:// 下会被 CORS 拦（真实部署也是 http 提供）。
//
// 旧后端代理：环境变量 LEGACY_BACKEND_URL（如 http://127.0.0.1:8089）设置时，
// *.php 请求转发给旧 PHP 后端。页面和后端因此同源——和原版部署里 swf 与
// xml.php 同站、游戏代码用相对 URL 的语义一致，移植侧不用改 URL 形态。
// 未设置时（V1 无后端模式）行为不变。
import { createServer, request } from "node:http";
import { readFile } from "node:fs/promises";
import { extname, join, normalize, isAbsolute, resolve, dirname } from "node:path";
import { existsSync } from "node:fs";
import { chromium } from "playwright";

const backendUrl = process.env.LEGACY_BACKEND_URL || "";

const target = process.argv[2];
if (!target || !existsSync(target)) {
  console.log(`用法：node smoke.mjs <index.html 路径>（找不到 ${target}）`);
  process.exit(1);
}

const root = dirname(resolve(target));
const MIME = {
  ".html": "text/html", ".js": "text/javascript", ".css": "text/css",
  ".json": "application/json", ".png": "image/png", ".jpg": "image/jpeg",
  ".gif": "image/gif", ".svg": "image/svg+xml", ".zip": "application/zip",
  ".swf": "application/x-shockwave-flash", ".ttf": "font/ttf", ".ogg": "audio/ogg",
  ".mp3": "audio/mpeg", ".wav": "audio/wav",
};
const server = createServer(async (req, res) => {
  try {
    const pathname = decodeURIComponent(new URL(req.url, "http://x").pathname);
    // *.php → 旧后端（方法、查询串、请求体原样转发）
    if (backendUrl && pathname.endsWith(".php")) {
      const upstream = request(`${backendUrl}${req.url}`, {
        method: req.method,
        headers: { ...req.headers, host: new URL(backendUrl).host },
      }, (up) => {
        res.writeHead(up.statusCode || 502, up.headers);
        up.pipe(res);
      });
      upstream.on("error", () => {
        res.writeHead(502, { "Content-Type": "text/plain" });
        res.end("smoke proxy: legacy backend unreachable");
      });
      req.pipe(upstream);
      return;
    }
    // 解码 + 挡目录穿越，回到 root 内
    let p = normalize(pathname);
    if (isAbsolute(p)) p = p.replace(/^([\\/])+/, "");
    const file = join(root, p);
    if (!file.startsWith(root)) { res.writeHead(403); res.end(); return; }
    const body = await readFile(file);
    res.writeHead(200, { "Content-Type": MIME[extname(file).toLowerCase()] || "application/octet-stream" });
    res.end(body);
  } catch {
    res.writeHead(404); res.end();
  }
});
await new Promise((r) => server.listen(0, "127.0.0.1", r));
const url = `http://127.0.0.1:${server.address().port}/index.html`;
const browser = await chromium.launch();
const page = await browser.newPage({ viewport: { width: 860, height: 500 } });

const errors = [];
page.on("pageerror", (e) => errors.push(`pageerror: ${e}`));
page.on("console", (m) => {
  if (m.type() === "error") errors.push(`console.error: ${m.text()}`);
});

try {
  await page.goto(url, { waitUntil: "load", timeout: 30_000 });
  // 等待启动标记（src/Main.hx 在进入第一帧时设置）
  await page.waitForFunction(
    () => !!globalThis.__openflFarmReady,
    null,
    { timeout: 20_000, polling: 250 },
  );
  // 等一帧让画面渲染出来
  await page.waitForTimeout(500);
  await page.screenshot({ path: "smoke.png" });

  // 渲染检查：canvas 像素不全是一张色（openfl html5 用 canvas/webgl 渲染）
  const nonBlank = await page.evaluate(() => {
    const c = document.querySelector("canvas");
    if (!c) return false;
    const ctx = c.getContext("2d");
    if (!ctx) return true; // webgl：拿不到 2d 上下文，视为有渲染
    const d = ctx.getImageData(0, 0, c.width, c.height).data;
    for (let i = 3; i < d.length; i += 400) if (d[i] !== 0) return true;
    return false;
  });

  if (!nonBlank) errors.push("canvas 看起来是空白的");
  if (errors.length) {
    console.log("web-smoke: FAIL");
    for (const e of errors) console.log("  " + e);
    process.exit(1);
  }
  console.log("web-smoke: ok");
  process.exit(0);
} catch (e) {
  await page.screenshot({ path: "smoke-failure.png" }).catch(() => {});
  console.log("web-smoke: FAIL");
  console.log("  " + (e && e.message ? e.message : e));
  for (const er of errors) console.log("  " + er);
  process.exit(1);
} finally {
  await browser.close();
  server.close();
}
