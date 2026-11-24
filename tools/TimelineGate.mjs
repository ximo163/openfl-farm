#!/usr/bin/env node
// T3 时间轴行为对拍门禁（issue #56）——自跑编排 CLI（CI 接线是人管的，本工具
// 只负责「能一条命令跑出报告」）：
//
//   node tools/TimelineGate.mjs                 # 全量 69 资产：逐个探针 → 汇总大报告
//   node tools/TimelineGate.mjs --only fish_01  # 只跑清单路径含子串的资产（调试用）
//   node tools/TimelineGate.mjs --self-check    # 注入式自检（完成标准 2）：正常跑须
//                                               # 通过 + 注入 skip-frame 后须红在第 2 步
//                                               # currentFrame——门禁有牙齿的证明
//
// 流水线（每资产一个独立 node 进程，互不串状态）：
//   1. 先把 tools/TimelineProbe.hx 编到 export/timeline-gate/timeline-probe.js
//      （export/ 在 .gitignore，产物不进库）；
//   2. assets/legacy-assets.txt（跳 # 注释）逐行 → swf 路径；
//   3. libraries.xml 的 <library path id> 反查库 id → export/html5/bin/lib/<id>.zip
//      （先跑过 haxelib run openfl build html5 才有这些 zip）；
//   4. node tools/run-openfl-node.js <探针> <swf> <zip>，stdout 末行 = 单行 JSON
//      （探针已把库侧日志拦进 JSON 的 scriptLog）；
//   5. 聚合：通过/红/错误、降级（盲区）剪辑与资产数、via=raw（走查 fallback）数，
//      大报告打到 stdout 并落 export/timeline-gate/report.txt（贴 issue 评论用，
//      不提交）。
//
// 退出码：0 全通过；1 有红或有错；2 基建坏（haxe 编译失败 / lib zip 整体缺失）。

import { execFileSync, spawnSync } from 'node:child_process';
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const REPO = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const PROBE_JS = path.join(REPO, 'export/timeline-gate/timeline-probe.js');
const PROBE_TIMEOUT_MS = 120_000;

const argv = process.argv.slice(2);
const only = flagValue('--only');
const selfCheck = argv.includes('--self-check');
const outFile = flagValue('--out') || path.join(REPO, 'export/timeline-gate/report.txt');

function flagValue(name) {
  const i = argv.indexOf(name);
  return i >= 0 ? argv[i + 1] : null;
}

// ---- 1. 编探针 ----
try {
  execFileSync('haxe', [
    '-cp', 'tools', '-cp', 'test',
    '-lib', 'format', '-lib', 'swf', '-lib', 'openfl', '-lib', 'lime',
    '-js', PROBE_JS, '-main', 'TimelineProbe',
  ], { cwd: REPO, stdio: ['ignore', 'pipe', 'pipe'] });
} catch (e) {
  console.error('探针编译失败（haxe）:\n' + e.stderr + e.stdout);
  process.exit(2);
}

// ---- 2/3. 清单 + libraries.xml 反查 ----
const libIdOf = new Map();
{
  const xml = fs.readFileSync(path.join(REPO, 'libraries.xml'), 'utf8');
  for (const m of xml.matchAll(/<library\s+path="([^"]+)"\s+id="([^"]+)"[^>]*\/>/g)) {
    // path 形如 assets/legacy/<清单路径>——键统一成清单路径形态
    const p = m[1].replace(/^assets\/legacy\//, '');
    libIdOf.set(p, m[2]);
  }
}
const manifest = fs.readFileSync(path.join(REPO, 'assets/legacy-assets.txt'), 'utf8')
  .split('\n').map(l => l.trim()).filter(l => l && !l.startsWith('#'));

const assets = manifest.filter(a => !only || a.includes(only));
if (assets.length === 0) {
  console.error(`--only ${only}：清单里没有匹配的资产`);
  process.exit(2);
}

// ---- 4. 跑探针 ----
function runProbe(asset, inject) {
  const swf = path.join(REPO, 'assets/legacy', asset);
  const id = libIdOf.get(asset);
  if (!id) {
    return { asset, kind: 'error', detail: `libraries.xml 里没有 ${asset} 的 <library> 行` };
  }
  const zip = path.join(REPO, 'export/html5/bin/lib', `${id}.zip`);
  if (!fs.existsSync(zip)) {
    return { asset, kind: 'error', detail: `缺 ${path.relative(REPO, zip)}（先 haxelib run openfl build html5）` };
  }
  const args = [path.join(REPO, 'tools/run-openfl-node.js'), PROBE_JS, swf, zip];
  if (inject) args.push('--inject', 'skip-frame');
  const r = spawnSync('node', args, {
    cwd: REPO, timeout: PROBE_TIMEOUT_MS, maxBuffer: 512 * 1024 * 1024,
    encoding: 'utf8',
  });
  if (r.error) {
    return { asset, kind: 'error', detail: `探针进程失败: ${r.error.message}` };
  }
  const lines = (r.stdout || '').split('\n').filter(l => l.trim());
  const jsonLine = lines.length > 0 && lines[lines.length - 1].startsWith('{')
    ? lines[lines.length - 1] : null;
  let d = null;
  try { d = jsonLine ? JSON.parse(jsonLine) : null; } catch { d = null; }
  if (!d) {
    const tail = (r.stdout || '').slice(-300);
    return { asset, kind: 'error', detail: `stdout 末行不是 JSON（exit=${r.status}）… ${tail}` };
  }
  if (d.error) {
    return { asset, kind: 'error', detail: String(d.error).split('\n').slice(0, 3).join(' ') };
  }
  return {
    asset, kind: d.pass ? 'pass' : 'red',
    steps: d.steps, clips: d.recordedClips, downgraded: d.downgraded,
    via: d.via, inject: d.inject || null, render: d.render,
    scriptLog: (d.scriptLog || []).length,
  };
}

// ---- 5. 自检模式 ----
if (selfCheck) {
  const target = assets[0];
  const normal = runProbe(target, false);
  const injected = runProbe(target, true);
  const lines = [];
  lines.push(`注入式自检（issue #56 完成标准 2）：${target}`);
  const normalOk = normal.kind === 'pass';
  lines.push(`  正常跑：${normalOk ? '通过 ✓' : '没通过 ✗（' + (normal.detail || normal.render.split('\n')[0]) + '）'}`);
  const red = injected.kind === 'red';
  const atStep2 = red && /item=currentFrame 第2步/.test(injected.render);
  lines.push(`  注入 skip-frame（首个记录目标第 2 步多跳 1 帧）：${red ? '红 ✓' : '没红 ✗（' + (injected.detail || 'exit=' + injected.kind) + '）'}`);
  lines.push(`  红项定位在第 2 步 currentFrame：${atStep2 ? '✓' : '✗'}`);
  if (red) lines.push('  ' + injected.render.split('\n').filter(l => l.includes('跑偏')).join('\n  '));
  const ok = normalOk && red && atStep2;
  lines.push(ok ? '自检结论：门禁有牙齿（注入一处跑偏 → 精确红在该步该项）' : '自检结论：门禁失牙（注入不红 = 门禁形同虚设）');
  const text = lines.join('\n');
  console.log(text);
  fs.mkdirSync(path.dirname(outFile), { recursive: true });
  fs.writeFileSync(outFile, text + '\n');
  process.exit(ok ? 0 : 1);
}

// ---- 5'. 全量模式 ----
const results = assets.map(a => runProbe(a, false));
const pass = results.filter(r => r.kind === 'pass');
const red = results.filter(r => r.kind === 'red');
const err = results.filter(r => r.kind === 'error');
const blindAssets = results.filter(r => (r.downgraded || 0) > 0);
const downgradedClips = results.reduce((s, r) => s + (r.downgraded || 0), 0);
const rawVia = results.filter(r => r.via === 'raw');

const lines = [];
lines.push('# T3 时间轴行为对拍报告（issue #56，期望=swf 结构静态提取 vs 实跑=探针固定步长）');
lines.push(`覆盖 ${results.length}/${manifest.length} 个清单资产（${only ? '过滤子串 "' + only + '"；' : ''}${new Date().toISOString()}）`);
lines.push(`通过 ${pass.length}，红 ${red.length}，错误 ${err.length}；降级剪辑 ${downgradedClips} 个（盲区不判红，分布在 ${blindAssets.length} 个资产）；走查 fallback（via=raw）${rawVia.length} 个`);
if (red.length > 0) lines.push(`红资产：${red.map(r => path.basename(r.asset)).join('、')}`);
if (err.length > 0) lines.push(`错误资产：${err.map(r => path.basename(r.asset)).join('、')}`);
lines.push('');
for (const r of results) {
  if (r.kind === 'error') {
    lines.push(`资产 ${r.asset}：错误——${r.detail}`);
  } else {
    lines.push(r.render);
  }
  if ((r.scriptLog || 0) > 0) {
    lines.push(`  （库侧日志 ${r.scriptLog} 条进探针 JSON 的 scriptLog，此处不展开）`);
  }
  lines.push('');
}
const text = lines.join('\n');
console.log(text);
fs.mkdirSync(path.dirname(outFile), { recursive: true });
fs.writeFileSync(outFile, text + '\n');
console.error(`报告已落 ${path.relative(REPO, outFile)}（gitignored，贴 issue 评论用）`);
process.exit(red.length + err.length > 0 ? 1 : 0);
