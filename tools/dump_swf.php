<?php
// V1 探路工具（issue #1）：无依赖的 SWF 结构速查。只读二进制，输出每个样本的
// 头部（版本/帧率/帧数/舞台矩形）、标签普查、每个 DefineSprite 的帧数与嵌套、
// DefineSound / StartSound / DoAction / SymbolClass 位置。
// issue #56 增补：帧标签三路全打——根与 sprite 内的 FrameLabel(43)（带 1 基
// 帧号）、DefineSceneAndFrameLabelData(86) 的场景名与帧标签段（变长 u32 + \0
// 结尾串，编码对齐 haxelib swf 3.4.0 的同名 tag 解析器）。动画标签大多在嵌套
// sprite 里，只有 root 扫描会漏。
// 用法：php tools/dump_swf.php <file.swf> [file2.swf ...]
//
// 为什么不用 swf 库的解析器：它 import format.abc（容器里没有 format haxelib，
// CLAUDE.md 禁止加依赖），而这里只需要走一遍标签流。

function die_usage() { fwrite(STDERR, "usage: php dump_swf.php <file.swf> [...]\n"); exit(1); }

class BitReader {
    public $bytes, $pos = 0, $bit = 0;
    function __construct($bytes) { $this->bytes = $bytes; }
    function readBits($n) {
        $v = 0;
        for ($i = 0; $i < $n; $i++) {
            $b = ord($this->bytes[$this->pos]);
            $v = ($v << 1) | (($b >> (7 - $this->bit)) & 1);
            if (++$this->bit === 8) { $this->bit = 0; $this->pos++; }
        }
        return $v;
    }
    function align() { if ($this->bit !== 0) { $this->bit = 0; $this->pos++; } }
    function bytePos() { return $this->pos; }
}

function read_u16(&$d, &$p) { $v = unpack('v', substr($d, $p, 2))[1]; $p += 2; return $v; }
function read_u32(&$d, &$p) { $v = unpack('V', substr($d, $p, 4))[1]; $p += 4; return $v; }

function read_rect(&$d, &$p) {
    $br = new BitReader(substr($d, $p));
    $nbits = $br->readBits(5);
    $mins = [];
    for ($i = 0; $i < 4; $i++) $mins[] = $br->readBits($nbits); // 有符号，本用途只看量级
    $p += $br->bytePos() + ($br->bit !== 0 ? 1 : 0);
    return $mins; // SWF 顺序：Xmin, Xmax, Ymin, Ymax
}

// SWF 变长 u32（DefineSceneAndFrameLabelData 的场景数/帧号用）：低 7 位一档、
// 高位续传，最多 5 字节。与 haxelib swf 3.4.0 SWFData.readEncodedU32 一致。
function read_var_u32(&$d, &$p) {
    $v = 0; $shift = 0;
    for ($i = 0; $i < 5; $i++) {
        $b = ord($d[$p]); $p++;
        $v |= ($b & 0x7F) << $shift;
        if (($b & 0x80) === 0) break;
        $shift += 7;
    }
    return $v;
}

const TAG_NAMES = [
    0=>'End',1=>'ShowFrame',2=>'DefineShape',4=>'PlaceObject',5=>'RemoveObject',6=>'DefineBits',
    7=>'DefineButton',8=>'JPEGTables',9=>'SetBackgroundColor',10=>'DefineFont',11=>'DefineText',
    12=>'DoAction',13=>'DefineFontInfo',14=>'DefineSound',15=>'StartSound',17=>'DefineButtonSound',
    18=>'SoundStreamHead',19=>'SoundStreamBlock',20=>'DefineBitsLossless',21=>'DefineBitsJPEG2',
    22=>'DefineShape2',23=>'DefineButtonCxform',26=>'PlaceObject2',28=>'RemoveObject2',
    32=>'DefineShape3',33=>'DefineText2',34=>'DefineButton2',35=>'DefineBitsJPEG3',36=>'DefineBitsLossless2',
    37=>'DefineEditText',39=>'DefineSprite',41=>'ProductInfo',43=>'FrameLabel',45=>'SoundStreamHead2',
    46=>'DefineMorphShape',48=>'DefineFont2',56=>'ExportAssets',58=>'ImportAssets',
    59=>'EnableDebugger',60=>'EnableDebugger2',63=>'DefineFontInfo2',65=>'ScriptLimits',
    69=>'FileAttributes',70=>'PlaceObject3',71=>'ImportAssets2',72=>'DoABC(untyped)',73=>'FontAlignZones',
    74=>'CSMTextSettings',75=>'DefineFont3',76=>'SymbolClass',77=>'Metadata',78=>'DefineScalingGrid',
    79=>'DoABC',82=>'DoABC2',83=>'DefineShape4',84=>'DefineMorphShape2',86=>'DefineSceneAndFrameLabelData',
    87=>'DefineBinaryData',88=>'DefineFontName',89=>'StartSound2',91=>'DefineFont4',
];

// 走一个标签流（根或 sprite），返回统计数组；$depth 用于嵌套缩进报告。
function walk_tags(&$d, &$p, $end, $ctx, $indent, &$report) {
    $sprite_frames = 0;               // 本层 ShowFrame 数
    $tag_counts = [];                 // code => count
    $startSound_frames = [];          // StartSound 出现时本层已见 ShowFrame 数（1 基帧号）
    $doaction_frames = [];
    $place_chars = [];                // 本层放置过的 character id（去重）
    $framelabels = [];                // FrameLabel(43)：[1 基帧号, 名字]（issue #56 标签扫描）
    while ($p < $end) {
        $codeLen = read_u16($d, $p);
        $code = $codeLen >> 6; $len = $codeLen & 0x3F;
        if ($len === 0x3F) $len = read_u32($d, $p);
        if ($code === 0) break; // End 标签：长度 0，不停就死循环
        $body = $p; $p += $len;
        if ($p > $end) break; // 容错：坏长度就停
        $tag_counts[$code] = ($tag_counts[$code] ?? 0) + 1;
        switch ($code) {
            case 1: $sprite_frames++; break;
            case 11: // StartSound: soundId u16
                $startSound_frames[] = [$sprite_frames + 1, read_u16($d, $body)];
                break;
            case 12: case 72: case 79: case 82: // DoABC 系列：记录出现帧
                $doaction_frames[] = $sprite_frames + 1;
                break;
            case 43: // FrameLabel：体是 \0 结尾名（+可选 anchor 字节）。标签作用在
                // 即将到来的帧上：出现时本层已见 ShowFrame 数 + 1（1 基）
                $r = $body; $s = '';
                while ($r < $body + $len && $d[$r] !== "\0") $s .= $d[$r++];
                $framelabels[] = [$sprite_frames + 1, $s];
                break;
            case 39: // DefineSprite：递归
                $q = $body;
                $charId = read_u16($d, $q);
                $innerFrames = read_u16($d, $q);
                $report['sprites'][] = [
                    'id' => $charId, 'parent' => $ctx, 'frames' => 0,
                    'indent' => $indent, 'inner_declared' => $innerFrames,
                ];
                $idx = count($report['sprites']) - 1;
                $innerEnd = $body + $len;
                $stats = walk_tags($d, $q, $innerEnd, $charId, $indent + 1, $report);
                $report['sprites'][$idx]['frames'] = $stats['frames'];
                $report['sprites'][$idx]['counts'] = $stats['counts'];
                $report['sprites'][$idx]['startSound'] = $stats['startSound'];
                $report['sprites'][$idx]['doAction'] = $stats['doAction'];
                $report['sprites'][$idx]['frameLabels'] = $stats['frameLabels'];
                break;
        }
    }
    return ['frames' => $sprite_frames, 'counts' => $tag_counts,
            'startSound' => $startSound_frames, 'doAction' => $doaction_frames,
            'frameLabels' => $framelabels];
}

function name_tag($code) { return TAG_NAMES[$code] ?? "Tag_$code"; }

function dump_file($path) {
    $raw = file_get_contents($path);
    if ($raw === false) { fwrite(STDERR, "cannot read $path\n"); return; }
    $sig = substr($raw, 0, 3);
    if (!in_array($sig, ['FWS', 'CWS'], true)) { fwrite(STDERR, "$path: 未知签名 $sig（ZWS/LZMA 未支持）\n"); return; }
    $version = ord($raw[3]);
    $off = 4;
    $declared = read_u32($raw, $off);
    $body = $sig === 'CWS' ? zlib_decode(substr($raw, 8)) : substr($raw, 8);
    $p = 0;
    $rect = read_rect($body, $p);
    $fps = unpack('v', substr($body, $p, 2))[1] / 256; $p += 2;
    $frameCount = read_u16($body, $p);

    echo "== $path\n";
    echo "  header: sig=$sig v$version 文件长=" . strlen($raw) . "（声明 {$declared}） 帧率={$fps} 帧数={$frameCount}\n";
    echo "  舞台 twips: Xmin={$rect[0]} Xmax={$rect[1]} Ymin={$rect[2]} Ymax={$rect[3]}"
       . " => " . round(($rect[1] - $rect[0]) / 20) . "x" . round(($rect[3] - $rect[2]) / 20) . "px\n";

    $report = ['sprites' => []];
    $tagStart = $p; // 标签流起点（walk_tags 会把 $p 推到流末尾，先存下来）
    $rootStats = walk_tags($body, $p, strlen($body), 'root', 0, $report);

    // 根流普查
    echo "  根时间轴: ShowFrame={$rootStats['frames']}；标签：";
    $parts = [];
    foreach ($rootStats['counts'] as $code => $n) $parts[] = name_tag($code) . "×$n";
    echo implode(', ', $parts) . "\n";
    if ($rootStats['startSound']) {
        echo "  根 StartSound: ";
        foreach ($rootStats['startSound'] as [$f, $id]) echo "帧{$f}→sound#{$id} ";
        echo "\n";
    }
    if ($rootStats['doAction']) echo "  根脚本(DoAction/DoABC) 帧: " . implode(',', $rootStats['doAction']) . "\n";
    // 根帧标签（tag43，含 1 基帧号）——walk_tags 顺带收集
    if ($rootStats['frameLabels']) {
        echo "  根 FrameLabel: ";
        foreach ($rootStats['frameLabels'] as [$f, $s]) echo "帧{$f}→\"{$s}\" ";
        echo "\n";
    }

    // 声音定义
    // 重走一遍根流找 DefineSound / SymbolClass / FrameLabel / ExportAssets 的原始体
    $q = $tagStart;
    $exports = []; $sounds = []; $bgcolor = null; $dsfld = null;
    while ($q < strlen($body)) {
        $codeLen = read_u16($body, $q);
        $code = $codeLen >> 6; $len = $codeLen & 0x3F;
        if ($len === 0x3F) $len = read_u32($body, $q);
        if ($code === 0) break; // End 或坏长度
        $b = $q; $q += $len;
        if ($code === 14) { // DefineSound
            $r = $b;
            $id = read_u16($body, $r);
            $byte = ord($body[$r]);
            $fmt = $byte >> 4; $rate = ($byte >> 2) & 3; $size = ($byte >> 1) & 1; $type = $byte & 1;
            $rateHz = [5512, 11025, 22050, 44100][$rate];
            $fmtName = [ 'uncompressed', 'ADPCM', 'MP3', 'uncompressed-le', 'Nellymoser16k', 'Nellymoser8k', 'Nellymoser', 'Speex' ][$fmt] ?? "?$fmt";
            $samples = read_u32($body, $r + 1);
            $sounds[] = sprintf('#%d %s %dHz %dbit %s 样本%d 数据%dB', $id, $fmtName, $rateHz, $size ? 16 : 8, $type ? 'stereo' : 'mono', $samples, $len - 7);
        } else if ($code === 86) { // DefineSceneAndFrameLabelData：场景数 +（帧标签数
            // 0 基帧号 + \0 结尾名）——编码与 haxelib swf 3.4.0
            // TagDefineSceneAndFrameLabelData.parse 一致（readEncodedU32 + readSTRING）
            $r = $b; $scenes = []; $labels86 = [];
            $sceneCount = read_var_u32($body, $r);
            for ($i = 0; $i < $sceneCount && $r < $q; $i++) {
                read_var_u32($body, $r); // scene offset
                $sn = '';
                while ($r < $q && $body[$r] !== "\0") $sn .= $body[$r++];
                $r++;
                $scenes[] = $sn;
            }
            $labelCount = read_var_u32($body, $r);
            for ($i = 0; $i < $labelCount && $r < $q; $i++) {
                $fn = read_var_u32($body, $r); // 0 基帧号
                $nm = '';
                while ($r < $q && $body[$r] !== "\0") $nm .= $body[$r++];
                $r++;
                $labels86[] = [$fn + 1, $nm]; // 统一 1 基（与 tag43 行一致）
            }
            $dsfld = ['scenes' => $scenes, 'labels' => $labels86];
        } else if ($code === 56 || $code === 76) { // ExportAssets / SymbolClass
            $r = $b; $count = read_u16($body, $r);
            for ($i = 0; $i < $count; $i++) {
                $tid = read_u16($body, $r);
                $s = '';
                while ($r < $q && $body[$r] !== "\0") $s .= $body[$r++]; $r++;
                $exports[] = "$s => char#$tid";
            }
        } else if ($code === 9) {
            $bgcolor = sprintf('#%02x%02x%02x', ord($body[$b]), ord($body[$b+1]), ord($body[$b+2]));
        }
    }
    if ($sounds) { echo "  DefineSound:\n"; foreach ($sounds as $s) echo "    $s\n"; }
    if ($dsfld) {
        echo "  DefineSceneAndFrameLabelData: 场景" . count($dsfld['scenes']) . "（"
           . implode(',', $dsfld['scenes']) . "）帧标签" . count($dsfld['labels']);
        if ($dsfld['labels']) {
            echo "（";
            foreach ($dsfld['labels'] as [$f, $s]) echo "帧{$f}→\"{$s}\" ";
            echo "）";
        }
        echo "\n";
    }
    if ($exports) { echo "  Export/SymbolClass:\n"; foreach ($exports as $e) echo "    $e\n"; }
    if ($bgcolor !== null) echo "  SetBackgroundColor: $bgcolor\n";

    // sprite 树摘要
    $mc = 0; $multi = [];
    foreach ($report['sprites'] as $s) {
        $mc++;
        if ($s['frames'] > 1) {
            $multi[] = sprintf('%s#%d(parent %s): %d帧', str_repeat('  ', $s['indent']), $s['id'], $s['parent'], $s['frames']);
        }
        if ($s['startSound']) {
            echo sprintf('  sprite#%d(parent %s) StartSound: ', $s['id'], $s['parent']);
            foreach ($s['startSound'] as [$f, $id]) echo "帧{$f}→sound#{$id} ";
            echo "\n";
        }
        if ($s['doAction']) echo sprintf("  sprite#%d(parent %s) 脚本帧: %s\n", $s['id'], $s['parent'], implode(',', $s['doAction']));
        // sprite 内帧标签（issue #56：动画标签大多在嵌套 sprite 里，root 扫描看不到）
        if ($s['frameLabels']) {
            echo sprintf('  sprite#%d(parent %s) FrameLabel: ', $s['id'], $s['parent']);
            foreach ($s['frameLabels'] as [$f, $nm]) echo "帧{$f}→\"{$nm}\" ";
            echo "\n";
        }
    }
    echo "  DefineSprite 总数={$mc}，多帧(>1)的 " . count($multi) . " 个：\n";
    foreach (array_slice($multi, 0, 40) as $m) echo "    $m\n";
    if (count($multi) > 40) echo "    ...（其余 " . (count($multi) - 40) . " 个略）\n";
    echo "\n";
}

if ($argc < 2) die_usage();
for ($i = 1; $i < $argc; $i++) dump_file($argv[$i]);
