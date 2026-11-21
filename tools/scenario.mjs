#!/usr/bin/env node
// scenario —— 场景运行器（issue #17 T1）。场景 = 一串带检查点的操作（点工具→
// 点地块→收获……），声明在 tools/scenarios/<name>.json；本运行器把它在**新版
// html5 产物**上执行（nodeboot 垫 DOM/Canvas/XHR 真跑 export/html5/bin），拦截
// 记录全部 mync XHR（mod/act/参数/顺序），按检查点判定，输出通过/失败清单 +
// 请求序列快照（自录基线 = diff 模式的基线格式，Ruffle 侧人工导出同格式接入）。
//
// 用法：
//   node tools/scenario.mjs run <scenario.json> [--out <record.json>]
//        [--settle <秒>] [--drive-timeout <秒>] [--timeout <秒>]
//     拉起 node tools/nodeboot/nodeboot.mjs --drive 本文件执行场景并落盘记录，
//     收尾对落盘记录离线复验（judge 语义见下）。退出码 0 = 全绿。
//     --out 缺省 <场景所在目录>/<场景名>.record.json。
//   node tools/scenario.mjs diff <a.record.json> <b.record.json>
//     两份运行记录对比，指出第一处不一致（requests 先比、steps 后比，都是
//     逐条比对，params/state 深比且键序无关）。退出码 0 = 完全一致。
//
// 双重身份：run 时本文件作为 nodeboot --drive 的驱动模块被动态 import（argv[1]
// 是 nodeboot.mjs，下面的 CLI 块不执行），export default(ctx) 在游戏进程里跑
// 「执行操作→等请求→等状态→快照」，把记录写进 RECORD_OUT 再交回退出码。
//
// 格式契约（场景声明 = 判定输入，基线记录 = 判定输出，两侧同构；键名路径与
// test/ScenarioRunnerContractTest.hx 钉死的一致，改格式两边要一起动）：
//   scenario = { "name": "...", "steps": [ {
//       "name": "...",
//       // 操作步骤：执行器原语词表——waitForReady（等启动链就绪）| clickLand
//       //（点地块；前置一步可选：setCursor 设光标 / keyUp 按键 / clickTool 点
//       // 工具条按钮，与「点工具→点地块」的操作序列一一对应）
//       "action": { "type": "...", "place": <数>, "setCursor": { "name", "args" },
//                   "keyUp": { "keyCode": <数> }, "clickTool": { "index": <数> } },
//       "checkpoint": {
//         // 期望发出的 mod 请求及参数（params 值一律字符串字面）
//         "requests": [ { "mod": "...", "act": "...", "params": { "k": "v" } } ],
//         // 期望的界面状态：地块号 → 模型字段（数值语义：
//         // FarmLandModel.m_farmlandData[place] 的 _cId/_cropStatus/_humidity）
//         "state": { "lands": { "<place>": { "cId|cropStatus|humidity": <数> } } } } } ] }
//   record   = { "scenario": "...",
//       // 拦截到的全部 mync mod 请求按发送顺序；启动期 user/getNotice、
//       // farmlandstatus/getoutput 等额外请求照录、判定不计红
//       "requests": [ { "mod": "...", "act": "...", "params": { "k": "v" } } ],
//       "steps": [ { "name": "...", "pass": true, "failures": ["..."],
//                    "state": { "lands": { "<place>": { "cId": <数>,
//                              "cropStatus": <数>, "humidity": <数> } } } } ] }
//
// 判定语义（离线复验与驱动内判定同款，ScenarioRunnerContractTest 交叉复验）：
//   - 每步期望请求在记录 requests 里按步序出现（子序列，游标只进不退），期望
//     参数逐键字面相等；body 的公共参数（uIdx/tName/fName 等额外键）不判红；
//   - 每步期望状态 ⊆ 检查点时刻实测状态（逐字段数值相等）；
//   - 期望的 farmlandstatus 操作 act 整份记录恰好声明的次数；记录里的
//     farmlandstatus act 只容场景操作 + 启动期 getoutput（FarmLandModel.
//     reGetOutput 对 step==5 && output==0 的地块在启动窗口发，
//     CropLifecycleLibrariesTest 类头有记录）——出现 scarify 之类即运行器
//     多驱动了一步，判红。
//
// 记录剥掉 farmKey/farmTime 两个参数（VOLATILE_PARAMS）：farmTime =
// CommonData.serverTime 随墙钟走（CommonData.hx:144-148，get_serverTime =
// _serverTime + 经过秒数；实测 user_run 是 0、操作请求随引导后秒数漂移）、
// farmKey = MD5(farmTime+盐)（Main.hx:230-236 getKey），同一次行为两次运行
// 必然不同。它们是传输层校验材料不是行为语义，留在基线里 diff 永远先红在这
// 两个键上；原版（Ruffle）侧导出基线时同样剥这两个键（handbook/
// architecture/scenario-runner.md）。其余参数逐字照录。

import { spawn } from "node:child_process";
import { readFileSync, writeFileSync } from "node:fs";
import { fileURLToPath } from "node:url";
import { dirname, join, resolve } from "node:path";

const HERE = dirname(fileURLToPath(import.meta.url));
const REPO = resolve(HERE, "..");
const NODEBOOT = join(REPO, "tools/nodeboot/nodeboot.mjs");
const BASE_URL = "http://127.0.0.1:8123/";

const REQ_TIMEOUT_MS = 10000; // 每步期望请求的等待上限
const STATE_TIMEOUT_MS = 10000; // 每步期望状态落地（应答处理完）的等待上限

// ---------------------------------------------------------------- 记录格式

const VOLATILE_PARAMS = ["farmKey", "farmTime"];

// POST body（URLVariables 的 k=v&…）→ params 对象（值一律字符串字面）
function parseBody(body) {
  const params = {};
  for (const [k, v] of new URLSearchParams(body || "")) params[k] = v;
  for (const k of VOLATILE_PARAMS) delete params[k];
  return params;
}

// myncLog 条目（nodeboot 服务侧记的 { url, body }）→ 记录条目
function logEntryToRequest(entry) {
  const u = new URL(entry.url, BASE_URL);
  return {
    mod: u.searchParams.get("mod") || "",
    act: u.searchParams.get("act") || "",
    params: parseBody(entry.body),
  };
}

// ---------------------------------------------------------------- 判定

// 期望请求是否被实际条目满足：mod/act 相等 + 期望参数逐键字面相等；
// 额外键（body 公共参数）不参与判定
function matchRequest(entry, expMod, expAct, expParams) {
  if (!entry || entry.mod !== expMod || entry.act !== expAct) return false;
  for (const [k, v] of Object.entries(expParams || {})) {
    if (entry.params[k] !== String(v)) return false;
  }
  return true;
}

// 期望状态 ⊆ 实测状态（逐字段数值相等）
function matchState(expectedLands, observedLands) {
  for (const [place, fields] of Object.entries(expectedLands || {})) {
    const obs = observedLands && observedLands[place];
    if (!obs) return false;
    for (const [f, v] of Object.entries(fields)) {
      if (obs[f] !== v) return false;
    }
  }
  return true;
}

// 场景声明的 farmlandstatus 操作计数（"act" -> 次数）
function expectedFarmActs(scenario) {
  const acts = {};
  for (const step of scenario.steps) {
    for (const exp of step.checkpoint.requests) {
      if (exp.mod === "farmlandstatus") {
        acts[exp.act] = (acts[exp.act] || 0) + 1;
      }
    }
  }
  return acts;
}

// 离线复验：record 对 scenario 的判定（驱动内判定同语义）。返回失败消息数组。
export function judgeRecord(scenario, record) {
  const errs = [];
  const reqs = record.requests || [];
  // 步序子序列：期望请求按步序出现，游标只进不退
  let cursor = 0;
  for (const step of scenario.steps) {
    for (const exp of step.checkpoint.requests) {
      let found = -1;
      for (let i = cursor; i < reqs.length; i++) {
        if (matchRequest(reqs[i], exp.mod, exp.act, exp.params)) {
          found = i;
          break;
        }
      }
      if (found < 0) {
        errs.push(`step ${step.name}：requests[${cursor}] 起没有 ${exp.mod}/${exp.act}` +
          `（期望参数 ${JSON.stringify(exp.params)}，顺序：${scenario.steps.map((s) => s.name).join("→")}）`);
        return errs; // 后续子序列已无意义
      }
      cursor = found + 1;
    }
  }
  // farmlandstatus 操作恰好声明的次数；其余动作只容启动期 getoutput
  const acts = expectedFarmActs(scenario);
  const counts = {};
  for (const r of reqs) {
    if (r.mod === "farmlandstatus") counts[r.act] = (counts[r.act] || 0) + 1;
  }
  for (const [act, n] of Object.entries(acts)) {
    if (counts[act] !== n) {
      errs.push(`farmlandstatus act=${act} 共 ${counts[act] || 0} 次，期望恰好 ${n} 次`);
    }
  }
  for (const act of Object.keys(counts)) {
    if (!acts[act] && act !== "getoutput") {
      errs.push(`farmlandstatus act=${act} 在场景操作+启动 getoutput 之外（多驱动了一步）`);
    }
  }
  // 判定清单：步名按序、全 pass、期望状态 ⊆ 实测
  if ((record.steps || []).length !== scenario.steps.length) {
    errs.push(`steps 共 ${(record.steps || []).length} 步，期望 ${scenario.steps.length}`);
  }
  for (let i = 0; i < Math.min((record.steps || []).length, scenario.steps.length); i++) {
    const got = record.steps[i];
    const st = scenario.steps[i];
    if (got.name !== st.name) errs.push(`steps[${i}].name = ${got.name}，期望 ${st.name}`);
    if (got.pass !== true) errs.push(`step ${st.name} pass != true（${(got.failures || []).join("；")}）`);
    const want = (st.checkpoint.state || {}).lands || {};
    if (!matchState(want, (got.state || {}).lands)) {
      errs.push(`step ${st.name} 实测状态不满足期望：want ${JSON.stringify(want)} got ${JSON.stringify((got.state || {}).lands)}`);
    }
  }
  return errs;
}

// ---------------------------------------------------------------- diff

// 深比（对象键序无关，数组按下标）；返回 null（相等）或首处不一致的描述
function firstDiff(a, b, path) {
  if (Array.isArray(a) && Array.isArray(b)) {
    if (a.length !== b.length) {
      const i = a.findIndex((x, k) => firstDiff(x, b[k], "") !== null);
      const at = i >= 0 ? i : Math.min(a.length, b.length);
      return `${path}[${at}] 只在一侧存在或长度不同（a=${a.length} 项、b=${b.length} 项）：a[${at}]=${JSON.stringify(a[at])} b[${at}]=${JSON.stringify(b[at])}`;
    }
    for (let i = 0; i < a.length; i++) {
      const d = firstDiff(a[i], b[i], `${path}[${i}]`);
      if (d) return d;
    }
    return null;
  }
  if (a && b && typeof a === "object" && typeof b === "object") {
    const keys = [...new Set([...Object.keys(a), ...Object.keys(b)])].sort();
    for (const k of keys) {
      if (!(k in a) || !(k in b)) return `${path}.${k} 只在一侧存在：a=${JSON.stringify(a[k])} b=${JSON.stringify(b[k])}`;
      const d = firstDiff(a[k], b[k], `${path}.${k}`);
      if (d) return d;
    }
    return null;
  }
  if (a !== b) return `${path}：a=${JSON.stringify(a)} b=${JSON.stringify(b)}`;
  return null;
}

function diffRecords(a, b) {
  // 先比 scenario 名（命名场景的自录快照，跨场景比没有意义）
  if (a.scenario !== b.scenario) {
    return `scenario：a="${a.scenario}" b="${b.scenario}"（两份记录不是同一场景）`;
  }
  return firstDiff(a.requests, b.requests, "requests")
    || firstDiff(a.steps, b.steps, "steps");
}

// ---------------------------------------------------------------- 驱动模块
// nodeboot --drive 本文件时被调用：与游戏同进程同 globalThis。交互语义全部
// 沿用 tools/nodeboot/drive-chain9.mjs（#9 全链验证过）：
//  - 构建产物把 Haxe 类关进 lime 的 IIFE，node 侧只有 shim.Harness 挂的
//    __openflFarmDrive 句柄（stage + MouseEvent/KeyboardEvent 构造器）；
//  - 地块点击派发到「地块项的底图子节点」：FarmLandsView 把 CLICK 监听
//    useCapture=true 注册在地块项上（FarmLandsView.hx:143），openfl 的
//    at-target 阶段不放捕获监听，直点地块项一枪不发（lessons #9）；
//  - 工具按钮直点本体（DefineButton2 → SimpleButton 垫片，ToolBar 自挂监听）；
//  - 浇水光标走 stage keyUp Q（ToolBar.onKeyUp 的键盘链）；
//  - 类匹配走 __class__.__name__（bundle 闭包外拿不到类对象本身）。
async function drive(ctx) {
  const { myncLog, sleep } = ctx;
  const log = (...a) => console.log("[scenario]", ...a);
  const scenario = JSON.parse(readFileSync(process.env.SCENARIO_PATH, "utf8"));
  const outPath = process.env.RECORD_OUT;
  const failures = [];

  const hd = globalThis.__openflFarmDrive;
  if (!hd || !hd.stage) {
    log("FAIL __openflFarmDrive 句柄缺失（shim/Harness.hx 未生效？），无法驱动");
    return 1;
  }
  const stage = hd.stage;

  const walk = (o, fn, depth) => {
    if (!o || depth > 60) return;
    fn(o);
    for (const k of o.__children || []) walk(k, fn, depth + 1);
  };
  const findByClassName = (name) => {
    const out = [];
    walk(stage, (o) => {
      if (o.__class__ && o.__class__.__name__ === name) out.push(o);
    }, 0);
    return out;
  };
  const landsView = findByClassName("module.mainScene.farmLand.FarmLandsView")[0];
  const toolBar = findByClassName("module.uitools.widgets.ToolBar")[0];
  if (!landsView || !toolBar) {
    log("FAIL 启动后显示树里没有 ToolBar / FarmLandsView，无法驱动");
    return 1;
  }
  const model = () => landsView.m_controller.m_model;
  const cursorCtrl = () => landsView.m_controller.m_module.get_app().get_farmView().get_cursorCtrl();
  const landOf = (i) => landsView.m_items.find((it) => it.get_index() === i);
  const clickLand = (land) => {
    const kids = (land.__children || []).filter(Boolean);
    const soil = kids.find((c) => c.parent === land && c.name !== "__reclaim__"
      && !String(c.__class__ ? c.__class__.__name__ : "").match(/Crop$|Byproduct/));
    if (!soil) {
      throw new Error(`地块项下没有可点子节点（LandTile 底图缺失？）：` +
        kids.map((c) => `${c.__class__ && c.__class__.__name__}:${c.name}`).join(", "));
    }
    soil.dispatchEvent(new hd.MouseEvent("click"));
  };
  // 检查点时刻的界面状态：FarmLandModel.m_farmlandData[place] 的模型字段
  const readLand = (place) => {
    const f = model().m_farmlandData[place];
    return { cId: f._cId, cropStatus: f._cropStatus, humidity: f._humidity };
  };
  const waitFor = async (pred, ms) => {
    const end = Date.now() + ms;
    while (Date.now() < end) {
      if (pred()) return true;
      await sleep(100);
    }
    return pred();
  };
  // myncLog 是追加写，缓存解析结果避免轮询反复 parse
  const reqCache = [];
  const reqAt = (i) => reqCache[i] || (reqCache[i] = logEntryToRequest(myncLog[i]));

  // 操作步骤：执行器原语（词表见文件头格式契约）
  const actions = {
    waitForReady: async (a) => {
      if (!globalThis.__openflFarmReady) {
        throw new Error("__openflFarmReady 未置位（nodeboot --drive 本就在就绪后接管，这里只作守卫）");
      }
    },
    clickLand: async (a) => {
      if (a.setCursor) {
        cursorCtrl().setCursor(a.setCursor.name, a.setCursor.args || "");
        log(`step 光标：${a.setCursor.name}(${a.setCursor.args || ""})`);
      }
      if (a.keyUp) {
        stage.dispatchEvent(new hd.KeyboardEvent("keyUp", true, false, 0, a.keyUp.keyCode));
        log(`step 按键：keyUp keyCode=${a.keyUp.keyCode}`);
      }
      if (a.clickTool) {
        toolBar._tools[a.clickTool.index].dispatchEvent(new hd.MouseEvent("click"));
        log(`step 点工具：ToolBar._tools[${a.clickTool.index}]`);
      }
      const land = landOf(a.place);
      if (!land) throw new Error(`找不到地块 ${a.place}（LandItemRender.index）`);
      clickLand(land);
    },
  };

  log(`场景 ${scenario.name}：${scenario.steps.map((s) => s.name).join("→")}`);
  const steps = [];
  let cursor = 0; // 期望请求的步序游标（只进不退）
  for (const step of scenario.steps) {
    const errs = [];
    // 1. 执行操作步骤
    const fn = actions[step.action.type];
    if (!fn) {
      errs.push(`action.type=${step.action.type} 不在执行器原语词表（waitForReady|clickLand）`);
    } else {
      try {
        await fn(step.action);
      } catch (e) {
        errs.push(`action ${step.action.type} 执行异常：${e && e.message}`);
      }
    }
    // 2. 期望请求：按序等到出现（或超时判红）。游标从上一步命中的下一位起，
    //    步间夹杂的启动期请求（getNotice/getoutput）不影响子序列
    const findFrom = (from, exp) => {
      for (let i = from; i < myncLog.length; i++) {
        if (matchRequest(reqAt(i), exp.mod, exp.act, exp.params)) return i;
      }
      return -1;
    };
    for (const exp of step.checkpoint.requests) {
      await waitFor(() => findFrom(cursor, exp) >= 0, REQ_TIMEOUT_MS);
      const idx = findFrom(cursor, exp);
      if (idx < 0) {
        errs.push(`未发出 ${exp.mod}/${exp.act}（期望参数 ${JSON.stringify(exp.params)}）`);
      } else {
        log(`step ${step.name} 请求命中 requests[${idx}]：${exp.mod}/${exp.act} ${JSON.stringify(reqAt(idx).params)}`);
        cursor = idx + 1;
      }
    }
    // 3. 期望状态：等到落地（应答处理完）再快照；超时按实测快照判红
    const wantLands = (step.checkpoint.state || {}).lands || {};
    const wantFields = Object.entries(wantLands)
      .flatMap(([p, fs]) => Object.keys(fs).map((f) => `${p}.${f}`));
    const snapshot = () => {
      const lands = {};
      for (const p of Object.keys(wantLands)) lands[p] = readLand(p);
      return lands;
    };
    if (wantFields.length && errs.length === 0) {
      const settled = await waitFor(() => matchState(wantLands, snapshot()), STATE_TIMEOUT_MS);
      if (!settled) errs.push(`期望状态未落地：${wantFields.join("/")}`);
    }
    const observed = wantFields.length ? snapshot() : {};
    if (errs.length === 0 && wantFields.length && !matchState(wantLands, observed)) {
      errs.push(`实测状态不满足期望：${JSON.stringify(observed)}`);
    }
    steps.push({ name: step.name, pass: errs.length === 0, failures: errs, state: { lands: observed } });
    log(`${errs.length === 0 ? "PASS" : "FAIL"} step ${step.name}` +
      (wantFields.length ? ` state=${JSON.stringify(observed)}` : "") +
      (errs.length ? ` —— ${errs.join("；")}` : ""));
  }

  // 请求序列快照 + 整份判红（操作计数/白名单，与离线复验同款）
  const requests = myncLog.map(logEntryToRequest);
  const acts = expectedFarmActs(scenario);
  const counts = {};
  for (const r of requests) {
    if (r.mod === "farmlandstatus") counts[r.act] = (counts[r.act] || 0) + 1;
  }
  for (const [act, n] of Object.entries(acts)) {
    if (counts[act] !== n) failures.push(`farmlandstatus act=${act} 共 ${counts[act] || 0} 次，期望恰好 ${n} 次`);
  }
  for (const act of Object.keys(counts)) {
    if (!acts[act] && act !== "getoutput") {
      failures.push(`farmlandstatus act=${act} 在场景操作+启动 getoutput 之外（多驱动了一步）`);
    }
  }
  for (const s of steps) {
    if (!s.pass) failures.push(`step ${s.name}：${s.failures.join("；")}`);
  }

  writeFileSync(outPath, JSON.stringify({ scenario: scenario.name, requests, steps }, null, 2) + "\n");
  log(`记录已写出：${outPath}（${requests.length} 条请求）`);
  if (failures.length) {
    for (const f of failures) log("FAIL " + f);
    return 1;
  }
  return 0;
}

// ---------------------------------------------------------------- CLI

function usage() {
  console.log(`用法：
  node tools/scenario.mjs run <scenario.json> [--out <record.json>] [--settle <秒>] [--drive-timeout <秒>] [--timeout <秒>]
  node tools/scenario.mjs diff <a.record.json> <b.record.json>`);
}

function argOf(args, key, dflt) {
  const i = args.indexOf(key);
  return i >= 0 ? args[i + 1] : dflt;
}

async function cmdRun(args) {
  const scenarioPath = resolve(args[0]);
  const scenario = JSON.parse(readFileSync(scenarioPath, "utf8"));
  const outPath = resolve(argOf(args, "--out",
    join(dirname(scenarioPath), `${scenario.name}.record.json`)));
  console.log(`[scenario] run：${scenarioPath} → ${outPath}`);
  const child = spawn(process.execPath, [
    NODEBOOT,
    "--drive", fileURLToPath(import.meta.url),
    "--settle", String(argOf(args, "--settle", 3)),
    "--drive-timeout", String(argOf(args, "--drive-timeout", 120)),
    "--timeout", String(argOf(args, "--timeout", 60)),
  ], {
    stdio: "inherit",
    env: { ...process.env, SCENARIO_PATH: scenarioPath, RECORD_OUT: outPath },
  });
  const code = await new Promise((r) => child.on("exit", (c) => r(c ?? 1)));
  // 离线复验落盘的记录（与驱动内判定同语义，双保险：记录文件本身可判定）
  let judgeErrs = [];
  try {
    judgeErrs = judgeRecord(scenario, JSON.parse(readFileSync(outPath, "utf8")));
  } catch (e) {
    judgeErrs = [`记录不可读（${e && e.message}）——驱动是否中途崩了？`];
  }
  if (judgeErrs.length) {
    for (const e of judgeErrs) console.log(`[scenario] FAIL(复验) ${e}`);
  } else {
    console.log(`[scenario] 复验通过：${scenario.steps.length} 步全绿`);
  }
  return code === 0 && judgeErrs.length === 0 ? 0 : 1;
}

function cmdDiff(args) {
  const a = JSON.parse(readFileSync(resolve(args[0]), "utf8"));
  const b = JSON.parse(readFileSync(resolve(args[1]), "utf8"));
  const first = diffRecords(a, b);
  if (!first) {
    console.log(`[scenario] diff 一致：${(a.requests || []).length} 条请求、${(a.steps || []).length} 步全同`);
    return 0;
  }
  console.log(`[scenario] diff 第一处不一致：${first}`);
  return 1;
}

// 直接作为主程序执行时才跑 CLI（被 nodeboot --drive import 时 argv[1] 是
// nodeboot.mjs，跳过）
const isMain = process.argv[1] && resolve(process.argv[1]) === fileURLToPath(import.meta.url);
if (isMain) {
  const [sub, ...rest] = process.argv.slice(2);
  let code = 1;
  if (sub === "run" && rest[0]) code = await cmdRun(rest);
  else if (sub === "diff" && rest[0] && rest[1]) code = cmdDiff(rest);
  else usage();
  process.exit(code);
}

export default drive;
