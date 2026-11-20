<?php
// nodeboot 的 xml.php 离线渲染器：把 legacy 部署包里 source/xml/mod/<mod>.php
// 的 heredoc XML 渲染成真实响应体（xml.php 在线版 = common.php 预置变量后
// include 该文件并 echo $$mod）。
//
// 用法：php render_xml.php <nc_main|nc_data|nc_addon> <url>
//   <url>  config 里绝对资产地址的前缀（客户端 LocalSwfLoader 只取文件名，
//         任意 host 均可，如 http://127.0.0.1:0）
//
// 必须以「source/core 的临时副本」为 cwd 运行（nodeboot.mjs 负责拷贝）：
// cache.func.php 的 qf_getCache 会按相对路径写 data/<dir>/<key>.php 缓存，
// 不能让它写进只读的 legacy/。依赖的 config/、source/ 子集随副本一起拷。
//
// 输出：渲染好的 XML 全文（stdout）。

$mod = $argv[1];
$url = $argv[2];

// common.php 在 include xml mod 前预置的缓存变量（nc_data.php 头部的
// qf_getCache 调用在源里被注释，实际靠 common.php 的 xml 生成分支先行加载）
include('source/cache.func.php');
$qf_getCache = 'qf_getCache';
$GLOBALS['cropstime'] = qf_getCache('cropstime', '/nc/');
$GLOBALS['cropstype'] = qf_getCache('cropstype', '/nc/');
$GLOBALS['itemtype'] = qf_getCache('itemtype', '/nc/');
$cropstime = $GLOBALS['cropstime'];
$cropstype = $GLOBALS['cropstype'];
$itemtype = $GLOBALS['itemtype'];

include('source/xml/mod/' . $mod . '.php');
echo $$mod;
