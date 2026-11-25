#!/usr/bin/env node
// scenario —— 场景运行器（issue #17 T1；issue #59 T1b 视觉升级）。场景 = 一串
// 带检查点的操作（点工具→点地块→收获……），声明在 tools/scenarios/<name>.json；
// 本运行器把它在**新版 html5 产物**上执行（nodeboot 垫 DOM/Canvas/XHR 真跑
// export/html5/bin），拦截记录全部 mync XHR（mod/act/参数/顺序），按检查点判定
// （请求/状态 + 视觉），输出通过/失败清单 + 请求序列快照 + 视觉段（自录基线
// = diff 模式的基线格式，Ruffle 侧人工导出同格式接入）。
//
// 用法：
//   node tools/scenario.mjs run <scenario.json> [--out <record.json>]
//        [--settle <秒>] [--drive-timeout <秒>] [--timeout <秒>]
//        [--self-check] [--update-record]
//     拉起 node tools/nodeboot/nodeboot.mjs --drive --visual 本文件执行场景并
//     落盘记录，收尾对落盘记录离线复验（judge 语义见下）。退出码 0 = 全绿。
//     --out 缺省 <场景所在目录>/<场景名>.record.json。
//     视觉：run 先编 export/scenario-gate/visual-boot.js（tools/ScenarioVisual.hx）
//     再跑；记录的每步带 visual 段（拍法 + 帧指纹 + 能量曲线，见格式契约）。
//     旧记录存在且带 visual 段时，跑完对它做视觉自回归判定（逐张哈希 +
//     曲线逐点），红则退 1 且**不覆盖旧基线**（新鲜记录落 <out>.fresh.json 供
//     检视）；--update-record 跳过比对直接重写基线（首次/有意重建用）。
//     排障：SCENARIO_DUMP_SHOTS=<目录> 时每张快照另存原始 RGBA（两次跑的
//     dump 逐像素比出漂移坐标；gitignore 外的临时目录用完即删）。
//   node tools/scenario.mjs --self-check <scenario.json> [...]
//     注入式自检（issue #59 完成标准 2）：正常跑（含视觉自回归判定）之外，
//     驱动在首个 burst 检查点补一轮「冻住连拍」（不泵帧连拍 → 能量归零），
//     compareBurst 两级判定必须红、且基线侧本来在动——红不了 = 门禁失牙。
//   node tools/scenario.mjs diff <a.record.json> <b.record.json>
//     两份运行记录对比，指出第一处不一致（requests 先比、视觉 meta 后比、
//     steps 最后比，都是逐条比对，params/state/visual 深比且键序无关）。退出
//     码 0 = 完全一致。
//
// 双重身份：run 时本文件作为 nodeboot --drive 的驱动模块被动态 import（argv[1]
// 是 nodeboot.mjs，下面的 CLI 块不执行），export default(ctx) 在游戏进程里跑
// 「执行操作→等请求→等状态→泵帧→拍视觉快照」，把记录写进 RECORD_OUT 再交回
// 退出码。
//
// 格式契约（场景声明 = 判定输入，基线记录 = 判定输出，两侧同构；键名路径与
// test/ScenarioRunnerContractTest.hx / test/tools/SceneShot*Test.hx 钉死的一致，
// 改格式两边要一起动）：
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
//         "state": { "lands": { "<place>": { "cId|cropStatus|humidity": <数> } } },
//         // 视觉拍法（issue #59；未声明 = screenshot 单张）：交互瞬间的连拍
//         // 声明 "burst": { "intervalMs": ≥1, "count": ≥2 }，或显式单张
//         // "screenshot": true。解析/校验归 tools.SceneShotPlan（错值抛）。
//         "screenshot": true | "burst": { "intervalMs": 200, "count": 8 } } } ] }
//   record   = { "scenario": "...",
//       // 拦截到的全部 mync mod 请求按发送顺序；启动期 user/getNotice、
//       // farmlandstatus/getoutput 等额外请求照录、判定不计红
//       "requests": [ { "mod": "...", "act": "...", "params": { "k": "v" } } ],
//       // 视觉采集的环境指纹（协议漂移即红）：帧时长/泵帧数/采集常量（含泵前置
//       // 静默窗——它直接决定确定性，见 REAL_IDLE_BEFORE_PUMP_MS）/覆盖计数
//       "visual": { "frameStepMs": 16.66…, "settleShot": 6, "settleBurstPre": 1,
//                   "bootIdleStreak": 24, "realIdleBeforePumpMs": 200,
//                   "pumpedFrames": <数>, "coverage": {...} },
//       // --self-check 时的注入结论（正常跑不带）
//       "selfCheck": { "step": "...", "pass": true, ... },
//       "steps": [ { "name": "...", "pass": true, "failures": ["..."],
//                    "state": { "lands": { "<place>": { "cId": <数>,
//                              "cropStatus": <数>, "humidity": <数> } } },
//                    // 记录侧同形携带拍法 + 连拍帧指纹 + 能量曲线（帧数 =
//                    // count、曲线点数 = count-1，对齐门 SceneShotDiff.
//                    // recordMatches；screenshot 1 帧 0 点同一条规则）
//                    "visual": { "kind": "screenshot"|"burst", "intervalMs": <数>,
//                                "count": <数>,
//                                "frames": [ { "hash": "<md5>", "width": <数>,
//                                              "height": <数> } ],
//                                "curve": [<数>, ...] } } ] }
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
//   - 视觉（issue #59）：驱动侧按 checkpoint 拍法逐拍（SceneShotPlan 解析、
//     记录对齐门 recordMatches 判红）；离线侧要求每步记录带 visual 段（缺
//     = 记录没录上，不许静默绿）；基线判定 = 新旧记录 visual 段深比（帧
//     指纹逐张、曲线逐点）——像素级容差比对（PixelDiff/compareBurst）留在
//     进程内（--self-check 注入与同帧数据可用时），跨进程基线只有指纹与
//     曲线（#57 render-baseline 同款立场）。
//
// 记录剥掉 farmKey/farmTime 两个参数（VOLATILE_PARAMS）：farmTime =
// CommonData.serverTime 随墙钟走（CommonData.hx:144-148，get_serverTime =
// _serverTime + 经过秒数；实测 user_run 是 0、操作请求随引导后秒数漂移）、
// farmKey = MD5(farmTime+盐)（Main.hx:230-236 getKey），同一次行为两次运行
// 必然不同。它们是传输层校验材料不是行为语义，留在基线里 diff 永远先红在这
// 两个键上；原版（Ruffle）侧导出基线时同样剥这两个键（handbook/
// architecture/scenario-runner.md）。其余参数逐字照录。

import { spawn, execFileSync } from "node:child_process";
import { existsSync, mkdirSync, readFileSync, renameSync, rmSync, writeFileSync } from "node:fs";
import { fileURLToPath } from "node:url";
import { dirname, join, resolve } from "node:path";

const HERE = dirname(fileURLToPath(import.meta.url));
const REPO = resolve(HERE, "..");
const NODEBOOT = join(REPO, "tools/nodeboot/nodeboot.mjs");
const BASE_URL = "http://127.0.0.1:8123/";
const VISUAL_BOOT = join(REPO, "export/scenario-gate/visual-boot.js");

const REQ_TIMEOUT_MS = 10000; // 每步期望请求的等待上限
const STATE_TIMEOUT_MS = 10000; // 每步期望状态落地（应答处理完）的等待上限

// 视觉采集协议常量（issue #59；两侧同构地写进记录 visual 段——换值=全量
// 视觉基线重录，和 #57 换哈希算法同权重）：
const BOOT_POLL_MS = 25; // 引导轮询周期（真实毫秒；等网络交付用，不进游戏钟）
const BOOT_IDLE_STREAK = 24; // 就绪 + 网络静默连续轮数（引导 settle：此后开始确定性泵帧）
// 每次泵帧前的最小真实静默窗（#59 实证收敛）：泵是同步 JS，但泵与泵之间的真实
// 间隙里仍可能有「不走红绿黄三计数」的真实异步收尾在跑（Assets.loadLibrary 的
// onComplete 链——素材库字节经虚拟 XHR 交付后，解析/挂树/COMPLETE 都在真实
// tick 上落地，无网络计数可观测）。窗不够大时它落在第 k 泵前还是后就是掷硬币，
// 画布烤进两种离散状态（boot 末方差区两族指纹 2b77e3c8/59d6ed93，引导期逐泵
// 探针实测计数全同而像素分叉）。窗下限要盖住解析/事件循环的真实时延——泵前置
// 200ms 静默后，任何 ≤200ms 的真实异步收尾恒在「触发它的那泵」与「下一泵」之
// 间落地，泵上的画面状态退化为泵计数的纯函数。
const REAL_IDLE_BEFORE_PUMP_MS = 200;
const SETTLE_SHOT_FRAMES = 6; // 单张检查点前置泵帧（应答后的动画走到的定格点）
const SETTLE_BURST_PRE = 1; // 连拍检查点前置泵帧（渲染应答里刚生成的动画首帧）

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
// opts.visual = true（run 的视觉模式）时加判：每步的 visual 段必须在且形状
// 自洽（帧数=声明的 count、曲线点数=count-1、screenshot 恒 1 帧 0 点）——
// 「记录没录上」不许静默绿；selfCheck 段（--self-check 跑出来的）结论为否
// 也在这里判红（门禁失牙 = 红修）。
export function judgeRecord(scenario, record, opts) {
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
  if (record.selfCheck && record.selfCheck.pass !== true) {
    errs.push(`selfCheck 注入未红（step ${record.selfCheck.step}）——门禁失牙`);
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
    if (opts && opts.visual) {
      const v = got.visual;
      const shapeOk = v && typeof v.kind === "string" && Array.isArray(v.frames)
        && Array.isArray(v.curve) && typeof v.count === "number";
      if (!shapeOk) {
        errs.push(`step ${st.name} 的 visual 段缺失或形状不对（视觉模式跑出来的记录必须带视觉段——没录上不许静默绿）`);
      } else {
        // 拍法自洽（对齐门 SceneShotDiff.recordMatches 的同语义复验）：帧数 =
        // 声明的 count、曲线点数 = count - 1（screenshot 恒 1/0）
        const wantCount = v.kind === "burst" ? v.count : 1;
        if (v.kind !== "burst" && v.kind !== "screenshot") {
          errs.push(`step ${st.name} 的 visual.kind=${v.kind}（只容 screenshot|burst）`);
        } else if (v.frames.length !== wantCount || v.curve.length !== wantCount - 1) {
          errs.push(`step ${st.name} 的 visual 段与拍法不对齐（帧 ${v.frames.length}/${wantCount}、曲线 ${v.curve.length}/${wantCount - 1}）`);
        }
      }
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
    || firstDiff(a.visual, b.visual, "visual")
    || firstDiff(a.selfCheck, b.selfCheck, "selfCheck")
    || firstDiff(a.steps, b.steps, "steps");
}

// ---------------------------------------------------------------- 视觉基线比对
// run 的自回归判定（#59）：旧基线 vs 新鲜记录的 visual 段深比——逐张帧指纹
// （#57 render-baseline 同款立场：跨进程只有指纹，像素级容差比对留进程内）+
// 能量曲线逐点 + 环境指纹（root visual）。旧基线无视觉段（#59 之前的记录）
// 返回 legacyOnly：本次跑建立视觉基线，不比。
function compareVisualBaseline(baseline, fresh) {
  const oldSteps = baseline.steps || [];
  if (!baseline.visual || !oldSteps.some((s) => s.visual)) {
    return { legacyOnly: true, errs: [], report: [] };
  }
  const errs = [];
  const report = [];
  const newSteps = fresh.steps || [];
  const n = Math.min(oldSteps.length, newSteps.length);
  for (let i = 0; i < n; i++) {
    const av = oldSteps[i].visual;
    const bv = newSteps[i].visual;
    if (!av || !bv) {
      errs.push(`steps[${i}].visual 缺失（旧 ${av ? "有" : "无"}、新 ${bv ? "有" : "无"}）——视觉段没录上，不许静默绿`);
      continue;
    }
    if (av.kind !== bv.kind || av.intervalMs !== bv.intervalMs || av.count !== bv.count) {
      errs.push(`steps[${i}] 拍法漂移：${av.kind}(${av.intervalMs}ms×${av.count}) → ${bv.kind}(${bv.intervalMs}ms×${bv.count})`);
      continue;
    }
    let stepErr = false;
    if (av.frames.length !== bv.frames.length) {
      errs.push(`steps[${i}].visual.frames 张数 ${av.frames.length} → ${bv.frames.length}`);
      stepErr = true;
    }
    const nf = Math.min(av.frames.length, bv.frames.length);
    for (let k = 0; k < nf; k++) {
      const af = av.frames[k] || {};
      const bf = bv.frames[k] || {};
      if (af.hash !== bf.hash) {
        const sizeDrift = (af.width !== bf.width || af.height !== bf.height)
          ? `，尺寸 ${af.width}×${af.height} → ${bf.width}×${bf.height}` : "";
        errs.push(`steps[${i}] 第 ${k + 1}/${av.frames.length} 张指纹不同（${af.hash} → ${bf.hash}${sizeDrift}）`);
        stepErr = true;
      }
    }
    const ac = av.curve || [];
    const bc = bv.curve || [];
    if (ac.length !== bc.length) {
      errs.push(`steps[${i}].visual.curve 点数 ${ac.length} → ${bc.length}`);
      stepErr = true;
    } else {
      for (let k = 0; k < ac.length; k++) {
        if (ac[k] !== bc[k]) {
          errs.push(`steps[${i}].visual.curve 第 ${k + 1} 点分叉（${ac[k]} → ${bc[k]}）`);
          stepErr = true;
          break;
        }
      }
    }
    report.push({ step: newSteps[i].name, kind: bv.kind, frames: bv.frames.length, curve: bc, ok: !stepErr });
  }
  if (oldSteps.length !== newSteps.length) {
    errs.push(`steps 步数 ${oldSteps.length} → ${newSteps.length}（基线与新鲜记录不同构）`);
  }
  const meta = firstDiff(baseline.visual, fresh.visual, "visual");
  if (meta) errs.push(`视觉环境指纹漂移：${meta}`);
  return { legacyOnly: false, errs, report };
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
// --self-check 注入结论（issue #59 完成标准 2）：正常连拍 vs 冻住连拍
//（visual.frozenBurst：不泵帧连拍 → 帧帧全同 → 能量全零）。有牙 = 两级判定
// 红 + 基线侧本来在动（否则注入根本没碰到动画——「红不了」和「没什么可红」
// 都是门禁失牙）。
function buildSelfCheck(stepName, normal, frozen, visual) {
  const d = visual.compareBurst(normal.frames, frozen.frames);
  const zeroed = (d.curveCurrent || []).every((v) => v === 0);
  const hadEnergy = (d.curveBaseline || []).some((v) => v !== 0);
  const pass = d.pass === false && zeroed && hadEnergy && d.frameFails > 0;
  return {
    step: stepName, pass,
    frameFails: d.frameFails,
    curveBaseline: d.curveBaseline, curveCurrent: d.curveCurrent,
    zeroed, hadEnergy,
  };
}

async function drive(ctx) {
  const { myncLog, sleep, net, realDateNow } = ctx;
  // 视觉模式下全局 Date.now 已是虚拟钟（本模块在 visual-boot 补丁之后才被
  // import，顶层捕获也会拿到虚拟钟）——等待计时必须用 nodeboot 传的真实引用
  const now = realDateNow || Date.now;
  const log = (...a) => console.log("[scenario]", ...a);
  const scenario = JSON.parse(readFileSync(process.env.SCENARIO_PATH, "utf8"));
  const outPath = process.env.RECORD_OUT;
  const selfCheck = process.env.SCENARIO_SELFCHECK === "1";
  const failures = [];
  const visual = globalThis.__openflFarmVisual || null;
  let selfCheckResult = null;
  // SCENARIO_DUMP_SHOTS：每张快照另存原始 RGBA（排障用，见步骤 4 的注释）
  const dumpDir = visual && process.env.SCENARIO_DUMP_SHOTS ? process.env.SCENARIO_DUMP_SHOTS : "";
  if (dumpDir) mkdirSync(dumpDir, { recursive: true });

  // 视觉模式引导协议（#59 确定性虚拟钟的入口，规则见文件头「判定语义」）：
  // 时钟已冻结；真实等待在 sleep（真实毫秒）里发生，游戏无感。网络静默才泵
  // 帧——交付只会发生在驱动的 await 里（泵是同步 JS，单线程下二者不交错），
  // 应答处理器因此恒跑在未前进的虚拟时刻上。**Main 出生前也要泵**：Harness
  // 的 __openflFarmDrive 句柄在 Main 的第一个 ENTER_FRAME 才挂（shim/Harness.hx
  // markMainFirstFrame），而引导链（preloader 进度、xml 配装、Image src 载入）
  // 有真需要帧/定时器推进的环节——「等句柄出现才泵」是死循环（句柄要靠泵才
  // 出现），实测三次挂死两次。就绪 + BOOT_IDLE_STREAK 轮静默视为引导完成——
  // 此后游戏状态完全由泵帧计数决定。泵出的请求（网络静默被打破）自动重置
  // 静默计数，不会出现「边等应答边泵」的竞态。
  if (visual) {
    let streak = 0;
    let lastMuts = net.mutations;
    let lastRecent = 0;
    let rounds = 0;
    let mainAt = -1;
    let lastActivityAt = now(); // 最近一次网络动作/泵帧的真实时刻（静默窗起算点）
    while (!globalThis.__openflFarmReady || streak < BOOT_IDLE_STREAK) {
      ++rounds;
      await sleep(BOOT_POLL_MS);
      const muts = net.mutations;
      if (net.inFlight > 0 || muts !== lastMuts) {
        if (muts !== lastMuts) {
          // 排障日志：每次网络动作落地时的泵帧计数。两次运行逐条对齐——分叉
          // 的那条就是「真实投递时序写进游戏时刻」的泄漏点（#59 确定性攻关）
          const acts = (net.recent || []).slice(lastRecent).join(" | ");
          lastRecent = (net.recent || []).length;
          log(`网络动作 #${muts} 于第 ${rounds} 轮（已泵 ${visual.stats().pumpedFrames} 帧，inFlight=${net.inFlight}）：${acts}`);
        }
        lastMuts = muts;
        lastActivityAt = now();
        streak = 0;
        continue;
      }
      lastMuts = muts;
      // 静默窗（见 REAL_IDLE_BEFORE_PUMP_MS 注释）：窗内只继续轮询，不泵——
      // 真实异步收尾的落点就此从「第 k 泵前后掷硬币」变成「恒在第 k 泵后、
      // 第 k+1 泵前」。轮数不进窗判定（streak 照旧只认网络静默）。
      if (now() - lastActivityAt < REAL_IDLE_BEFORE_PUMP_MS) {
        continue;
      }
      const hd0 = globalThis.__openflFarmDrive;
      if (hd0 && hd0.stage) {
        if (mainAt < 0) {
          mainAt = rounds;
          log(`Main 于第 ${rounds} 轮出现`);
        }
        visual.bindStage(hd0.stage); // 幂等；首绑即校正帧时长（见 ScenarioVisual.hx）
      }
      visual.pump(1);
      lastActivityAt = now();
      if (process.env.SCENARIO_PROBE) {
        // 引导期逐泵探针：分叉的那一轮 = 泄漏发生的真实窗口（#59 确定性攻关）。
        // Main 未生时 stage 未绑、探针抛错——跳过即可（画布还只有 preloader）
        try {
          const ph = visual.probeHash(280, 20, 84, 44);
          log(`BPROBE r=${rounds} p=${visual.stats().pumpedFrames} h=${ph.hash} t=${ph.timers} rand=${ph.rand} m=${muts} e=${ph.elapsed.toFixed(2)}`);
          // SCENARIO_PROBE_DUMP=<目录>：方差区原始像素按泵落盘（家族取证——
          // 两家族各自的区域内容长什么样，逐像素比出差异的视觉成分）
          if (process.env.SCENARIO_PROBE_DUMP) {
            const img = visual.shot();
            const PX = 280, PY = 20, PW = 84, PH = 44;
            const rows = [];
            for (let y = PY; y < PY + PH; y++) {
              const row = [];
              for (let x = PX; x < PX + PW; x++) {
                const i = (img.width * y + x) * 4;
                row.push(`${img.pixels[i]},${img.pixels[i + 1]},${img.pixels[i + 2]},${img.pixels[i + 3]}`);
              }
              rows.push(row.join(" "));
            }
            mkdirSync(process.env.SCENARIO_PROBE_DUMP, { recursive: true });
            writeFileSync(join(process.env.SCENARIO_PROBE_DUMP, `p${visual.stats().pumpedFrames}.txt`),
              rows.join("\n") + "\n");
          }
        } catch { }
      }
      streak = globalThis.__openflFarmReady && net.mutations === muts ? streak + 1 : 0;
      if (rounds % 400 === 0) {
        log(`引导 ${rounds} 轮仍未完成：inFlight=${net.inFlight} muts=${muts} ready=${globalThis.__openflFarmReady} pumped=${visual.stats().pumpedFrames}`);
      }
    }
    log(`引导完成：就绪 + 网络静默 ${BOOT_IDLE_STREAK} 轮（boot 已泵 ${visual.stats().pumpedFrames} 帧，帧时长 ${visual.stats().frameStepMs}ms）`);
    if (process.env.SCENARIO_PROBE) {
      // 排障探针（#59 确定性攻关）：逐帧泵 + 方差区指纹 + 计数器序列，
      // 两次运行的 PROBE 行逐帧 diff，第一个分叉帧即泄漏起点。帧数独立开关：
      // SCENARIO_PROBE 的值同时会被当帧数用（=1 就只探 1 帧），引导期 BPROBE
      // 只想开启时用 SCENARIO_PROBE_FRAMES 控制帧数、SCENARIO_PROBE 写 on。
      const seq = visual.pumpProbe(Number(process.env.SCENARIO_PROBE_FRAMES) || Number(process.env.SCENARIO_PROBE) || 300, 280, 20, 84, 44);
      log(`PROBE ${JSON.stringify(seq)}`);
    }
  }

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
  if (process.env.SCENARIO_DUMP_TREE && visual) {
    // 排障钩子（#59 确定性攻关）：打印与「截图方差区」（实测 enter 快照
    // x[284-359] y[26-60] 一带）相交的显示对象——跨跑换相位的到底是哪个
    let shown = 0;
    walk(stage, (o) => {
      try {
        if (typeof o.getBounds !== "function" && typeof o.get_bounds !== "function") return;
        // openfl js 产物的方法名：DisplayObject.getBounds 是驼峰（实测 bundle 里
        // get_bounds 0 处、getBounds 51 处），自家类的 getter 仍是蛇形
        const b = (typeof o.getBounds === "function" ? o.getBounds(stage) : o.get_bounds(stage));
        if (b == null || Number.isNaN(b.x)) return;
        const hit = !(b.x > 364 || b.y > 64 || b.x + b.width < 280 || b.y + b.height < 22);
        if (!hit && shown >= 12 && !process.env.SCENARIO_DUMP_TREE_ALL) return;
        shown++;
        log(`TREE ${o.__class__ && o.__class__.__name__} name=${String(o.name)}` +
          ` bounds=[${b.x.toFixed(1)},${b.y.toFixed(1)},${(b.x + b.width).toFixed(1)},${(b.y + b.height).toFixed(1)}]` +
          ` alpha=${o.alpha} visible=${o.visible}${hit ? " HIT" : ""}`);
      } catch { /* 无 bounds/未上树的跳过 */ }
    }, 0);
  }
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
    const end = now() + ms;
    while (now() < end) {
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
    // 4. 视觉检查点（#59）：按声明的拍法采（screenshot 单张 / burst 连拍，
    //    拍法解析错按步失败处理）。记录只带指纹与曲线；帧像素留在进程内只
    //    供自检注入用（compareBurst 的像素级比对也因此只在进程内做）。
    //    SCENARIO_DUMP_SHOTS=<目录> 时每张另存原始 RGBA（排障用：两次跑的
    //    dump 逐像素比出漂移坐标，不入库）
    let visualSection = null;
    let dumpIdx = 0;
    const dumpShot = (img) => {
      if (!dumpDir) return;
      writeFileSync(join(dumpDir, `${steps.length}-${step.name}.${dumpIdx++}.rgba`),
        Buffer.from(img.pixels));
    };
    if (visual) {
      try {
        const spec = visual.specOf(step.checkpoint);
        visual.settle(spec.kind === "burst" ? SETTLE_BURST_PRE : SETTLE_SHOT_FRAMES);
        if (spec.kind === "screenshot") {
          const img = visual.shot();
          dumpShot(img);
          visualSection = {
            kind: "screenshot", intervalMs: 0, count: 1,
            frames: [{ hash: visual.hash(img), width: img.width, height: img.height }],
            curve: [],
          };
        } else {
          const per = visual.framesForMs(spec.intervalMs);
          const b = visual.burst(spec.count, per);
          for (const f of b.frames) dumpShot(f);
          visualSection = {
            kind: "burst", intervalMs: spec.intervalMs, count: spec.count,
            frames: b.frames.map((f) => ({ hash: visual.hash(f), width: f.width, height: f.height })),
            curve: b.curve,
          };
          // 对齐门（SceneShotDiff.recordMatches，与离线复验同语义）：拍多少张
          // 就该记多少张、曲线点数恰为张数-1
          if (!visual.recordMatches(spec, b.frames.length, b.curve.length)) {
            errs.push(`连拍记录与声明不对齐（帧 ${b.frames.length}/${spec.count}、曲线 ${b.curve.length}/${spec.count - 1}）`);
          }
          // --self-check 注入（首个 burst 检查点）：冻住连拍 → 能量归零，两级
          // 判定必须红——门禁有牙的证明（issue #59 完成标准 2）
          if (selfCheck && !selfCheckResult) {
            selfCheckResult = buildSelfCheck(step.name, b, visual.frozenBurst(spec.count), visual);
          }
        }
      } catch (e) {
        errs.push(`视觉检查点失败：${e && e.message}`);
      }
    }
    steps.push({
      name: step.name, pass: errs.length === 0, failures: errs,
      state: { lands: observed }, visual: visualSection,
    });
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

  // 视觉环境指纹（#59）：泵帧数/帧时长/采集常量/解码覆盖计数——协议或通道
  // 漂移（帧率改了、解码少了、settle 常量动了）都会在这里先红，不用等画面
  // 对不上再猜。两侧同构：字段就是驱动用的这组常量与 stats() 计数。
  let visualMeta = null;
  if (visual) {
    const st = visual.stats();
    visualMeta = {
      frameStepMs: st.frameStepMs,
      settleShot: SETTLE_SHOT_FRAMES,
      settleBurstPre: SETTLE_BURST_PRE,
      bootIdleStreak: BOOT_IDLE_STREAK,
      realIdleBeforePumpMs: REAL_IDLE_BEFORE_PUMP_MS,
      pumpedFrames: st.pumpedFrames,
      coverage: {
        png: st.png, jpg: st.jpg, decodeFail: st.decodeFail,
        fillTextCalls: st.fillTextCalls, fallbackImageSources: st.fallbackImageSources,
      },
    };
  }
  // 自检注入结论判红（门禁失牙 = 红修，不许绿着过）
  if (selfCheckResult) {
    if (selfCheckResult.pass) {
      log(`自检（${selfCheckResult.step}）：冻住连拍注入已红（frameFails=${selfCheckResult.frameFails}、` +
        `曲线 ${JSON.stringify(selfCheckResult.curveBaseline)} → 全零）——门禁有牙`);
    } else {
      failures.push(`自检（${selfCheckResult.step}）：注入未红或基线无动画` +
        `（curveBaseline=${JSON.stringify(selfCheckResult.curveBaseline)}` +
        ` curveCurrent=${JSON.stringify(selfCheckResult.curveCurrent)}` +
        ` frameFails=${selfCheckResult.frameFails}）——门禁失牙`);
    }
  }

  const record = { scenario: scenario.name, requests };
  if (visualMeta) record.visual = visualMeta;
  if (selfCheckResult) record.selfCheck = selfCheckResult;
  record.steps = steps;
  writeFileSync(outPath, JSON.stringify(record, null, 2) + "\n");
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
  node tools/scenario.mjs run <scenario.json> [--out <record.json>] [--settle <秒>] [--drive-timeout <秒>] [--timeout <秒>] [--self-check] [--update-record]
  node tools/scenario.mjs --self-check <scenario.json> [...同 run 的参数]   # run --self-check 的等价短打
  node tools/scenario.mjs diff <a.record.json> <b.record.json>`);
}

function argOf(args, key, dflt) {
  const i = args.indexOf(key);
  return i >= 0 ? args[i + 1] : dflt;
}

async function cmdRun(args, selfCheckFlag) {
  const selfCheck = selfCheckFlag || args.includes("--self-check");
  const updateRecord = args.includes("--update-record");
  const scenarioPath = resolve(args[0]);
  const scenario = JSON.parse(readFileSync(scenarioPath, "utf8"));
  const outPath = resolve(argOf(args, "--out",
    join(dirname(scenarioPath), `${scenario.name}.record.json`)));
  // 新鲜记录先落 <out>.fresh.json：全绿才搬进 <out>——有红的时候基线不动
  //（自回归的旧基线是诊断材料），新鲜记录留在 fresh 供检视。child 超时/崩了
  // 没落盘时，先删陈货再跑——上次跑剩下的 fresh 不能冒充本次（判绿假阴）
  const freshPath = `${outPath}.fresh.json`;
  if (existsSync(freshPath)) rmSync(freshPath);
  console.log(`[scenario] run：${scenarioPath} → ${outPath}${selfCheck ? "（--self-check）" : ""}`);
  // 视觉引导模块（#59）：先编后跑（nodeboot --visual 在游戏 bundle 前执行它，
  // 顺序语义见 nodeboot.mjs 的 --visual 说明；haxe 失败 = 基建坏，退 2）
  try {
    execFileSync("haxe", ["-cp", "tools", "-lib", "format", "-js", VISUAL_BOOT,
      "-main", "ScenarioVisual"], { cwd: REPO, stdio: ["ignore", "pipe", "pipe"] });
  } catch (e) {
    console.log(`[scenario] FAIL visual-boot 编译失败（haxe -cp tools -lib format -js ${VISUAL_BOOT} -main ScenarioVisual）：${e && (e.stderr || e.message)}`);
    return 2;
  }
  // 自回归基线：跑**之前**读旧记录（跑完要拿它比对；--update-record 是有意
  // 重建，不比）
  let baseline = null;
  if (!updateRecord && existsSync(outPath)) {
    try {
      baseline = JSON.parse(readFileSync(outPath, "utf8"));
    } catch {
      baseline = null; // 旧基线坏了当没有：本次跑重立
    }
  }
  const child = spawn(process.execPath, [
    NODEBOOT,
    "--drive", fileURLToPath(import.meta.url),
    "--visual",
    "--settle", String(argOf(args, "--settle", 3)),
    "--drive-timeout", String(argOf(args, "--drive-timeout", 240)),
    "--timeout", String(argOf(args, "--timeout", 60)),
  ], {
    stdio: "inherit",
    env: {
      ...process.env,
      SCENARIO_PATH: scenarioPath,
      RECORD_OUT: freshPath,
      SCENARIO_SELFCHECK: selfCheck ? "1" : "",
    },
  });
  const code = await new Promise((r) => child.on("exit", (c) => r(c ?? 1)));
  // 离线复验落盘的记录（与驱动内判定同语义，双保险：记录文件本身可判定）
  let fresh = null;
  let judgeErrs = [];
  try {
    fresh = JSON.parse(readFileSync(freshPath, "utf8"));
  } catch (e) {
    judgeErrs = [`记录不可读（${e && e.message}）——驱动是否中途崩了？`];
  }
  if (fresh) judgeErrs = judgeRecord(scenario, fresh, { visual: true });
  if (judgeErrs.length) {
    for (const e of judgeErrs) console.log(`[scenario] FAIL(复验) ${e}`);
  } else {
    console.log(`[scenario] 复验通过：${scenario.steps.length} 步全绿`);
  }
  // 视觉自回归判定（#59 完成标准 1 的主体）：旧基线 vs 新鲜记录——逐张帧
  // 指纹 + 能量曲线逐点 + 环境指纹
  let visualErrs = [];
  let report = [];
  if (baseline && fresh) {
    const cmp = compareVisualBaseline(baseline, fresh);
    if (cmp.legacyOnly) {
      console.log("[scenario] 旧基线无视觉段（#59 之前的记录）——本次跑建立视觉基线");
    } else {
      visualErrs = cmp.errs;
      report = cmp.report;
    }
  } else if (!fresh) {
    // 驱动没落 fresh（崩了/超时，见上面的 FAIL(复验) 记录不可读）——别再误报
    // 「无旧基线」，旧基线在不在跟 fresh 缺失是两回事
  } else {
    console.log(updateRecord
      ? "[scenario] --update-record：跳过比对，直接重立基线"
      : "[scenario] 无旧基线——本次跑建立基线");
  }
  if (report.length) {
    console.log(`[scenario] 视觉自回归报告（${report.length} 个视觉检查点）：`);
    for (const r of report) {
      console.log(`  step ${r.step}：${r.kind === "burst"
        ? `连拍 ${r.frames} 张、能量曲线 [${r.curve.join(", ")}]`
        : "单张"} ${r.ok ? "✓" : "✗"}`);
    }
  }
  for (const e of visualErrs) console.log(`[scenario] FAIL(视觉) ${e}`);
  const green = code === 0 && judgeErrs.length === 0 && visualErrs.length === 0;
  // --self-check 是门禁有牙的元验证（记录里多 selfCheck 段），不是基线采集——
  // 绿了也不落盘，基线保持普通跑的干净形态
  if (green && !selfCheck) {
    if (existsSync(freshPath)) renameSync(freshPath, outPath);
    console.log(`[scenario] 基线已落盘：${outPath}`);
  } else if (existsSync(freshPath)) {
    console.log(selfCheck
      ? `[scenario] 自检绿：新鲜记录留在 ${freshPath}（自检不落基线）`
      : `[scenario] 基线未动（有红）：新鲜记录留在 ${freshPath}`);
  }
  return green ? 0 : 1;
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
  let argv = process.argv.slice(2);
  // --self-check 可作首参短打（完成标准 2 的验牙入口，等价 run --self-check）。
  // 只剥随后的 run 不够：usage() 文档的「--self-check <scenario.json>」形态
  // 会把场景路径当 sub 命令落 usage 退 1（实测复现）——无 run 时补回 run
  let selfCheck = false;
  if (argv[0] === "--self-check") {
    selfCheck = true;
    argv = argv.slice(1);
    if (argv[0] !== "run") argv = ["run", ...argv];
  }
  const [sub, ...rest] = argv;
  let code = 1;
  if (sub === "run" && rest[0]) code = await cmdRun(rest, selfCheck);
  else if (sub === "diff" && rest[0] && rest[1]) code = cmdDiff(rest);
  else usage();
  process.exit(code);
}

export default drive;
