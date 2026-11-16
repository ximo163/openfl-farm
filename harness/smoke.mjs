// web-smoke：在无头浏览器里加载构建产物，确认能渲染、无报错、冒烟标记出现。
// 由人维护（harness/ 受保护）。用法：node smoke.mjs <index.html 路径>
// 退出码：0 通过；1 失败（失败原因打到 stdout，截图存 harness/smoke-failure.png）。
import { pathToFileURL } from "node:url";
import { existsSync } from "node:fs";
import { chromium } from "playwright";

const target = process.argv[2];
if (!target || !existsSync(target)) {
  console.log(`用法：node smoke.mjs <index.html 路径>（找不到 ${target}）`);
  process.exit(1);
}

const url = pathToFileURL(target).href;
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
}
