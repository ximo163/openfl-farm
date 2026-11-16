#!/usr/bin/env bash
# legacy/manifest.json 告诉 agent 原部署目录里什么是什么。它写错了，agent 会读错地方，
# 所以任务开始前（preflight）先检查：能解析、必填项都填了、写的路径都存在。
# "placeholder": true 时部署目录还没放进来，只提示、不挡任务。
set -u
node - <<'JS'
const fs = require("fs");
const path = require("path");
const file = "legacy/manifest.json";
const fail = (msg) => { console.log(file + ": " + msg); process.exit(1); };
let m;
try { m = JSON.parse(fs.readFileSync(file, "utf8")); }
catch (e) { fail("读不到或不是合法的 JSON：" + e.message); }
if (m.version !== 1) fail("\"version\" 必须是 1");
if (m.placeholder === true) {
  console.log(file + ": 还是占位（placeholder: true），legacy/deploy/ 尚未放入原部署目录；需要原版依据的任务会 BLOCKED");
  process.exit(0);
}
const errors = [];
if (typeof m.web_root !== "string" || !m.web_root) errors.push("\"web_root\" 必须填写（相对 legacy/ 的游戏应用根目录）");
if (!Array.isArray(m.server?.entries) || m.server.entries.length === 0) errors.push("\"server.entries\" 至少写一个 PHP 入口文件");
if (!Array.isArray(m.client?.swf) || m.client.swf.length === 0) errors.push("\"client.swf\" 至少写一个 swf 文件");
const paths = [];
const collect = (v) => {
  if (typeof v === "string") paths.push(v);
  else if (Array.isArray(v)) v.forEach(collect);
};
collect(m.web_root);
for (const k of ["entries", "include_roots"]) collect(m.server?.[k]);
collect(m.client?.swf);
for (const k of ["config_xml", "assets", "db_schema"]) collect(m[k]);
collect(m.runtime?.source);
for (const k of Object.keys(m.notes ?? {})) collect(k);
for (const p of paths) {
  if (p.startsWith("/") || p.split("/").includes("..")) errors.push(p + "：路径必须相对 legacy/，不能以 / 开头或含 ..");
  else if (!fs.existsSync(path.join("legacy", p))) errors.push(p + "：legacy/ 下不存在这个路径");
}
if (errors.length) fail("\n  - " + errors.join("\n  - "));
console.log(file + ": ok（" + paths.length + " 个路径）");
JS
