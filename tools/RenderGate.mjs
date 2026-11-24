#!/usr/bin/env node
// T2 资产渲染对拍门禁（issue #57）——自跑编排 CLI（CI 接线是人管的，本工具
// 只负责「一条命令跑出报告」）。T3 TimelineGate.mjs 同款骨架：每资产一个
// 独立 node 进程、export/ 下落报告（gitignored）。
//
//   node tools/RenderGate.mjs                      # 比对模式：全量 69 资产对基线
//   node tools/RenderGate.mjs --only fish_01       # 只跑清单路径含子串的资产
//   node tools/RenderGate.mjs --update-baseline    # 重建基线（全量或 --only 子集
//                                                  # 替换该资产条目）
//   node tools/RenderGate.mjs --update-baseline --source references
//                                                  # 换源口：legacy/references 真
//                                                  # Flash 采集就位后同管道换源重建
//                                                  # （现在还没采集，人 TODO）
//   node tools/RenderGate.mjs --self-check         # 注入式自检（完成标准 2）：
//                                                  # 正常跑绿 + 注入 scale 后红在
//                                                  # 注入目标的拍点键上
//
// 基线文件：tools/render-baseline.json（入库；先例 tools/swf-code-baseline.json）。
// 形状由 tools/tools/BaselineFile.hx 契约钉死：{"source":"self"|"references",
// "entries":{"<asset>|<symbol>|<shotId>":{"hash","width","height"}}}，键升序、
// 紧凑无空白——本文件写基线时逐字节复刻该序列化（排序 + 字段序 hash/width/
// height），二次重建不产生假 diff。
//
// 比对语义（自回归立场，issue #57 现状节）：基线是首跑 openfl 截图，门禁证明
// 「没变」不证明「和原版一致」；source 字段只记来源（换源口），比对逻辑不按
// 它分支。真 Flash 参考采集（legacy/references，人 TODO）就位后走
// --update-baseline --source references 同管道重建即得保真对拍。
//
// 退出码：0 全通过；1 有红或有错；2 基建坏（haxe 编译失败 / 基线缺文件 /
// 重建时有资产错——不写残缺基线）。

import { execFileSync, spawnSync } from 'node:child_process';
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const REPO = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const PROBE_JS = path.join(REPO, 'export/render-gate/render-probe.js');
const BASELINE = path.join(REPO, 'tools/render-baseline.json');
const PROBE_TIMEOUT_MS = 120_000;

const argv = process.argv.slice(2);
const only = flagValue('--only');
const selfCheck = argv.includes('--self-check');
const update = argv.includes('--update-baseline');
const source = flagValue('--source');
const k = flagValue('--k') || '10';
const outFile = flagValue('--out') || path.join(REPO, 'export/render-gate/report.txt');

if (source !== null && source !== 'self' && source !== 'references') {
  console.error(`--source 只认 self|references（换源口），收到 "${source}"`);
  process.exit(2);
}

function flagValue(name) {
  const i = argv.indexOf(name);
  return i >= 0 ? argv[i + 1] : null;
}

// ---- 1. 编探针 ----
try {
  execFileSync('haxe', [
    '-cp', 'tools', '-cp', 'test',
    '-lib', 'format', '-lib', 'swf', '-lib', 'openfl', '-lib', 'lime',
    '-js', PROBE_JS, '-main', 'RenderProbe',
  ], { cwd: REPO, stdio: ['ignore', 'pipe', 'pipe'] });
} catch (e) {
  console.error('探针编译失败（haxe）:\n' + e.stderr + e.stdout);
  process.exit(2);
}

// ---- 2/3. 清单 + libraries.xml 反查（TimelineGate 同款）----
const libIdOf = new Map();
{
  const xml = fs.readFileSync(path.join(REPO, 'libraries.xml'), 'utf8');
  for (const m of xml.matchAll(/<library\s+path="([^"]+)"\s+id="([^"]+)"[^>]*\/>/g)) {
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

// ---- 基线读写（形状契约见文件头）----
function readBaseline() {
  if (!fs.existsSync(BASELINE)) return null;
  const doc = JSON.parse(fs.readFileSync(BASELINE, 'utf8'));
  return { source: doc.source || 'self', entries: doc.entries || {} };
}

// 键升序 + 字段序 hash/width/height + 紧凑——逐字节复刻 BaselineFile.stringify
function writeBaseline(doc) {
  const keys = Object.keys(doc.entries).sort();
  const parts = keys.map(key => {
    const e = doc.entries[key];
    return JSON.stringify(key) + ':{' + `"hash":${JSON.stringify(e.hash)},"width":${e.width}` +
      `,"height":${e.height}}`;
  });
  const text = `{"source":${JSON.stringify(doc.source)},"entries":{${parts.join(',')}}}`;
  fs.writeFileSync(BASELINE, text);
}

// ---- 4. 跑探针 ----
function runProbe(asset, mode) {
  const swf = path.join(REPO, 'assets/legacy', asset);
  const id = libIdOf.get(asset);
  if (!id) {
    return { asset, kind: 'error', detail: `libraries.xml 里没有 ${asset} 的 <library> 行` };
  }
  const zip = path.join(REPO, 'export/html5/bin/lib', `${id}.zip`);
  if (!fs.existsSync(zip)) {
    return { asset, kind: 'error', detail: `缺 ${path.relative(REPO, zip)}（先 haxelib run openfl build html5）` };
  }
  const args = [path.join(REPO, 'tools/run-openfl-node.js'), PROBE_JS, swf, zip, '--k', k];
  if (mode === 'update') {
    args.push('--update');
  } else {
    args.push('--baseline', BASELINE);
    if (mode === 'inject') args.push('--inject', 'scale');
  }
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
  const base = {
    asset, kind: d.pass ? 'pass' : 'red',
    targets: d.targets, shots: d.shots, coverage: d.coverage,
    render: d.render, scriptLog: (d.scriptLog || []).length,
  };
  if (mode === 'update') {
    return { ...base, kind: 'pass', entryKeys: d.entryKeys, entries: d.entries };
  }
  if (mode === 'inject') {
    return { ...base, injectKey: d.inject };
  }
  return base;
}

// ---- 5. 自检模式（完成标准 2）----
if (selfCheck) {
  const target = assets[0];
  const baseline = readBaseline();
  if (!baseline) {
    console.error(`自检须先有基线（${path.relative(REPO, BASELINE)} 不存在，先 --update-baseline）`);
    process.exit(2);
  }
  const normal = runProbe(target, 'compare');
  const injected = runProbe(target, 'inject');
  const lines = [];
  lines.push(`注入式自检（issue #57 完成标准 2）：${target}`);
  const normalOk = normal.kind === 'pass';
  lines.push(`  正常跑：${normalOk ? '通过 ✓' : '没通过 ✗（' + (normal.detail || normal.render.split('\n')[0]) + '）'}`);
  const red = injected.kind === 'red';
  // 红必须落在注入目标的拍点键上（render 行含 |注入键|），不是别处红
  const onTarget = red && injected.injectKey != null && injected.injectKey !== ''
    && injected.render.split('\n').some(l => l.includes(`|${injected.injectKey}|`));
  const injectWhy = injected.injectKey == null || injected.injectKey === ''
    ? '该资产所有记录目标都渲染为空，选不出注入目标（换资产或先修渲染）'
    : (injected.detail || 'exit=' + injected.kind);
  lines.push(`  注入 scale（首个有可见画面的记录目标 scaleX=2）：${red ? '红 ✓' : '没红 ✗（' + injectWhy + '）'}`);
  lines.push(`  红项定位在注入目标（${injected.injectKey}）的拍点键：${onTarget ? '✓' : '✗'}`);
  if (red) lines.push('  ' + injected.render.split('\n').slice(0, 4).join('\n  '));
  const ok = normalOk && red && onTarget;
  lines.push(ok ? '自检结论：门禁有牙齿（改坏一处渲染 → 精确红在该符号的拍点）' : '自检结论：门禁失牙（注入不红 = 门禁形同虚设）');
  const text = lines.join('\n');
  console.log(text);
  fs.mkdirSync(path.dirname(outFile), { recursive: true });
  fs.writeFileSync(outFile, text + '\n');
  process.exit(ok ? 0 : 1);
}

// ---- 5'. 重建基线模式（换源口在 --source）----
if (update) {
  const existing = readBaseline();
  const doc = { source: source !== null ? source : (existing ? existing.source : 'self'), entries: {} };
  if (existing) Object.assign(doc.entries, existing.entries);
  const results = assets.map(a => runProbe(a, 'update'));
  const errs = results.filter(r => r.kind === 'error');
  if (errs.length > 0) {
    // 有资产错就不写基线：残缺基线会让失败资产的拍点悄悄消失（下次比对
    // 该资产全 missing——错误必须挡在重建这一层）
    console.error('重建中止（有资产出错，不写残缺基线）：');
    for (const e of errs) console.error(`  ${e.asset}: ${e.detail}`);
    process.exit(2);
  }
  let total = 0;
  for (const r of results) {
    if (r.entryKeys.length !== r.entries.length) {
      console.error(`重建中止：${r.asset} 的 entryKeys/entries 数量不一致（探针契约破坏）`);
      process.exit(2);
    }
    // 选中的资产整体替换（去掉旧键再加新键）：--only 子集重建不留陈旧拍点
    const prefix = r.asset + '|';
    for (const key of Object.keys(doc.entries)) {
      if (key.startsWith(prefix)) delete doc.entries[key];
    }
    for (let i = 0; i < r.entryKeys.length; i++) {
      doc.entries[r.entryKeys[i]] = r.entries[i];
      total++;
    }
  }
  writeBaseline(doc);
  const shots = results.reduce((s, r) => s + r.shots, 0);
  console.log(`基线已重建：${path.relative(REPO, BASELINE)}（source=${doc.source}，${results.length} 资产、${total} 拍点、${total === shots ? '全部入库' : '数量异常 ' + total + '/' + shots}）`);
  process.exit(0);
}

// ---- 5''. 比对模式（默认）----
const baseline = readBaseline();
if (!baseline) {
  console.error(`缺基线文件 ${path.relative(REPO, BASELINE)}：先 node tools/RenderGate.mjs --update-baseline`);
  process.exit(2);
}
const results = assets.map(a => runProbe(a, 'compare'));
const pass = results.filter(r => r.kind === 'pass');
const red = results.filter(r => r.kind === 'red');
const err = results.filter(r => r.kind === 'error');

// 覆盖数汇总（盲区如实报，不判红：JPEG 黑兜底、动态文本字形盒、实例化失败）
const cov = results.reduce((acc, r) => {
  if (!r.coverage) return acc;
  acc.png += r.coverage.png || 0;
  acc.jpg += r.coverage.jpg || 0;
  acc.fillTextCalls += r.coverage.fillTextCalls || 0;
  acc.fallbackSources += r.coverage.fallbackImageSources || 0;
  acc.instantiateFails += r.coverage.instantiateFailCount || 0;
  if ((r.coverage.decodeFail || []).length > 0) acc.decodeFailAssets.push(r.asset);
  if ((r.coverage.instantiateFails || []).length > 0) acc.instantiateFailAssets.push(r.asset);
  return acc;
}, { png: 0, jpg: 0, fillTextCalls: 0, fallbackSources: 0, instantiateFails: 0, decodeFailAssets: [], instantiateFailAssets: [] });

const lines = [];
lines.push('# T2 资产渲染对拍报告（issue #57，自回归基线：基线=首跑 openfl 截图，证明「没变」）');
lines.push(`基线来源 source=${baseline.source}${baseline.source === 'self' ? '（真 Flash 参考采集是人 TODO；就位后 --update-baseline --source references 换源重建）' : ''}`);
lines.push(`覆盖 ${results.length}/${manifest.length} 个清单资产（${only ? '过滤子串 "' + only + '"；' : ''}k=${k}，${new Date().toISOString()}）`);
lines.push(`通过 ${pass.length}，红 ${red.length}，错误 ${err.length}；拍点 ${results.reduce((s, r) => s + (r.shots || 0), 0)}（符号目标 ${results.reduce((s, r) => s + (r.targets || 0), 0)}）`);
lines.push(`覆盖数：PNG 解码 ${cov.png}、JPEG（黑兜底，format 无解码器）${cov.jpg}、动态文本字形盒 fillText ${cov.fillTextCalls}、位图兜底采样 ${cov.fallbackSources}、实例化失败符号 ${cov.instantiateFails}`);
if (cov.decodeFailAssets.length > 0) lines.push(`位图解码失败资产：${cov.decodeFailAssets.map(a => path.basename(a)).join('、')}`);
if (cov.instantiateFailAssets.length > 0) lines.push(`实例化失败资产：${cov.instantiateFailAssets.map(a => path.basename(a)).join('、')}`);
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
  if (r.coverage && (r.coverage.instantiateFails || []).length > 0) {
    lines.push(`  （实例化失败符号：${r.coverage.instantiateFails.join('；')}）`);
  }
  lines.push('');
}
const text = lines.join('\n');
console.log(text);
fs.mkdirSync(path.dirname(outFile), { recursive: true });
fs.writeFileSync(outFile, text + '\n');
console.error(`报告已落 ${path.relative(REPO, outFile)}（gitignored，贴 issue 评论用）`);
process.exit(red.length + err.length > 0 ? 1 : 0);
