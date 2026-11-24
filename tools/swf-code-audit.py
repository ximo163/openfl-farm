# -*- coding: utf-8 -*-
"""swf 代码普查对账：防止「自带 AS3 的 swf 被当纯素材」的漏翻（2026-11-24
help.swf 教训，issue #65）。

为什么是普查对账而不是名单枚举：main_swfs 反编译名单两轮都是调用方视角
（加载链/模块反射表），help.swf 两轮都不命中、被归素材、6 个类无人翻。
本工具从**内容视角**全量普查 legacy/deploy 下全部 swf：解压后走标签流，
数字节码标签、扫 DoABC 常量池里的交互 API 引用——带交互代码的 swf 必须
满足其一，否则 CI 红：
  1. 在 scripts/decompile-legacy.sh 的 main_swfs 名单（= 已反编译进翻译链）；
  2. 在 tools/swf-code-baseline.json 登记账（= 有意识的搁置决策，reason 必填，
     支持目录族模式，见账本头注释）。

stub 家族（fish/Crop 物料等，Flash IDE 自动生成的空符号类）自动豁免：
有字节码但常量池无任何交互 API 引用、且无 DefineEditText 文本字段。

用法：python tools/swf_code_audit.py  （在仓库任意 cwd 下都行，锚定脚本自身）
exit 0 = 对账干净；exit 1 = 有 LEAK / 产物缺失 / 账本过期 / 坏文件。
"""
import io, json, os, re, struct, sys, zlib

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DEPLOY = os.path.join(ROOT, "legacy", "deploy", "QFarmFlash")
DECOMPILED = os.path.join(ROOT, "legacy", "decompiled")
DECOMPILE_SH = os.path.join(ROOT, "scripts", "decompile-legacy.sh")
BASELINE = os.path.join(ROOT, "tools", "swf-code-baseline.json")

# 交互 API 标记（DoABC 常量池是明文字节串；IDE 自动 stub 只 import
# flash.display，这些一个都不会出现）。不要加 flash.events/flash.display
# 这类歧义包名。
KEYWORDS = [
    b"addEventListener", b"dispatchEvent", b"URLRequest", b"URLLoader",
    b"navigateToURL", b"ExternalInterface", b"flash.external", b"flash.net",
    b"ENTER_FRAME", b"TimerEvent", b"KeyboardEvent", b"MouseEvent",
    b"gotoAndStop", b"gotoAndPlay", b"SharedObject", b"NetConnection",
    b"Socket", b"flash.utils",
]

TAG_DOABC = (72, 82)
TAG_DOINIT = 59
TAG_DOACTION = 12
TAG_EDITTEXT = 37
TAG_SPRITE = 39


def walk(buf, depth, acc):
    """走标签流（含 DefineSprite 递归），累计字节码/文本/关键词命中。"""
    q, n = 0, len(buf)
    while q < n:
        v = struct.unpack("<H", buf[q:q + 2])[0]
        code, ln = v >> 6, v & 0x3F
        q += 2
        if ln == 0x3F:
            ln = struct.unpack("<I", buf[q:q + 4])[0]
            q += 4
        if code == 0:
            break
        if code in TAG_DOABC:
            acc["abc"] += 1
            blob = buf[q:q + ln]
            acc["abc_bytes"] += ln
            for kw in KEYWORDS:
                if kw in blob:
                    acc["kw"] += 1
        elif code == TAG_DOINIT:
            acc["doinit"] += 1
        elif code == TAG_DOACTION:
            acc["doaction"] += 1
        elif code == TAG_EDITTEXT:
            acc["edittext"] += 1
        elif code == TAG_SPRITE and depth < 5:
            walk(buf[q + 4:q + ln], depth + 1, acc)
        q += ln


def census(path):
    data = open(path, "rb").read()
    sig = data[:3]
    if sig == b"CWS":
        body = data[:8] + zlib.decompress(data[8:])
    elif sig == b"FWS":
        body = data
    else:
        return None
    acc = {"abc": 0, "doinit": 0, "doaction": 0, "edittext": 0,
           "kw": 0, "abc_bytes": 0}
    nb = body[8]
    nbits = nb >> 3
    p = 8 + (5 + 4 * nbits + 7) // 8 + 4
    walk(body[p:], 0, acc)
    return acc


def leak_eligible(acc):
    has_code = acc["abc"] or acc["doinit"] or acc["doaction"]
    return has_code and (acc["kw"] > 0 or acc["edittext"] > 0)


def load_main_swfs():
    """从 decompile-legacy.sh 抽 main_swfs 条目（相对 source/core/module/）。"""
    txt = io.open(DECOMPILE_SH, encoding="utf-8").read()
    m = re.search(r"main_swfs=\((.*?)\)", txt, re.S)
    if not m:
        raise SystemExit("main_swfs 解析失败：decompile-legacy.sh 结构变了？")
    entries = []
    for line in m.group(1).splitlines():
        s = line.strip()
        if s and not s.startswith("#"):
            entries.append(s)
    return entries


def load_baseline():
    """返回 (exact_entries, families)。family 的 pattern 以 /* 结尾，
    匹配 = 路径前缀（pattern 去掉 /* 后作为目录前缀）。"""
    if not os.path.isfile(BASELINE):
        return {}, []
    doc = json.load(io.open(BASELINE, encoding="utf-8"))
    fams = []
    for f in doc.get("families", []):
        pat = f["pattern"]
        if not pat.endswith("/*"):
            raise SystemExit("账本 family pattern 必须以 /* 结尾：%s" % pat)
        fams.append((pat[:-2] + "/", f))
    return doc.get("entries", {}), fams


def baseline_hit(rel, entries, fams):
    if rel in entries:
        return ("entry", entries[rel])
    for prefix, f in fams:
        if rel.startswith(prefix):
            return ("family", f)
    return None


def main():
    if not os.path.isdir(DEPLOY):
        raise SystemExit("找不到 legacy/deploy/QFarmFlash")
    main_swfs = load_main_swfs()
    listed = {}
    for e in main_swfs:
        rel = "source/core/module/" + e
        listed[rel] = os.path.basename(e)[:-4]
    entries, fams = load_baseline()
    fam_files = {prefix: 0 for prefix, _ in fams}

    art = stub = 0
    ok_listed, ok_baseline, known_corrupt = [], [], []
    leaks, stale, errors = [], [], []
    baselined_rels = set()

    for base, _, names in os.walk(DEPLOY):
        for n in names:
            if not n.lower().endswith(".swf"):
                continue
            abspath = os.path.join(base, n)
            rel = os.path.relpath(abspath, DEPLOY).replace("\\", "/")
            try:
                acc = census(abspath)
            except Exception as ex:
                hit = baseline_hit(rel, entries, fams)
                if hit:
                    known_corrupt.append("%s（已登记: %s）" % (
                        rel, str(hit[1].get("reason", ""))[:40]))
                else:
                    errors.append("%s: %s" % (rel, ex))
                continue
            if acc is None:
                errors.append("%s: 非 FWS/CWS" % rel)
                continue
            hit = baseline_hit(rel, entries, fams)
            if hit:
                baselined_rels.add(rel)
                if hit[0] == "family":
                    fam_files[hit[1]["pattern"][:-2] + "/"] += 1
            if not (acc["abc"] or acc["doinit"] or acc["doaction"]):
                art += 1
                continue
            if not leak_eligible(acc):
                stub += 1
                continue
            if rel in listed:
                ok_listed.append(rel)
            elif hit:
                ok_baseline.append((rel, hit[1]))
            else:
                leaks.append((rel, acc))

    for rel in listed:
        if rel not in ok_listed:
            leaks.append((rel, None))  # 名单内但普查未命中（swf 没了/结构异常）

    missing = []
    for rel, name in listed.items():
        if not os.path.isdir(os.path.join(DECOMPILED, name)):
            missing.append("%s -> legacy/decompiled/%s/" % (rel, name))

    # 账本保鲜：精确条目必须仍是漏点形态；族模式至少命中一个文件
    for rel, e in entries.items():
        p = os.path.join(DEPLOY, rel.replace("/", os.sep))
        if not os.path.isfile(p):
            stale.append("%s: 文件不存在" % rel)
            continue
        try:
            acc = census(p)
        except Exception:
            continue  # 损坏已按 known_corrupt 报
        if acc is None or not leak_eligible(acc):
            stale.append("%s: 已不是带交互代码形态（请出账）" % rel)
    for prefix, f in fams:
        if fam_files[prefix] == 0:
            # 族下可能全是损坏文件——文件存在即不算死族
            d = os.path.join(DEPLOY, prefix.replace("/", os.sep))
            if not os.path.isdir(d):
                stale.append("族 %s*: 目录不存在" % f["pattern"])

    print("== swf 代码普查对账 ==")
    print("art(无字节码)          : %d" % art)
    print("stub(IDE自动空类)      : %d" % stub)
    print("在册在译(main_swfs)    : %d" % len(ok_listed))
    print("已登记账本(baseline)   : %d" % len(ok_baseline))
    for rel, e in sorted(ok_baseline):
        print("    %s  (%s)" % (rel, str(e.get("reason", ""))[:70]))
    if known_corrupt:
        print("损坏已登记: %d" % len(known_corrupt))
        for k in known_corrupt:
            print("    %s" % k)
    if missing:
        print("!! 产物缺失(名单内但 legacy/decompiled/ 没有):")
        for m in missing:
            print("    %s" % m)
    if stale:
        print("!! 账本过期:")
        for s in stale:
            print("    %s" % s)
    if leaks:
        print("!! LEAK(带交互代码、既不在名单也不在账本):")
        for rel, acc in leaks:
            if acc is None:
                print("    %s  (名单内但普查未命中)" % rel)
            else:
                print("    %s  ABC=%d blob=%dB kw=%d text=%d" % (
                    rel, acc["abc"], acc["abc_bytes"], acc["kw"],
                    acc["edittext"]))
    if errors:
        print("!! 读不了的文件: %d" % len(errors))
        for e in errors[:10]:
            print("    %s" % e)
    bad = bool(leaks or missing or stale or errors)
    print("结论: %s" % ("FAIL" if bad else "OK —— 无未对账的带代码 swf"))
    sys.exit(1 if bad else 0)


if __name__ == "__main__":
    main()
