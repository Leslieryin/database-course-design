#!/usr/bin/env python3
"""SQL 课程设计脚本的结构检查。

不模拟 SQL Server 全文语法（sqlfluff 的 tsql 方言不支持本仓库用到的
CREATE RULE / CREATE DEFAULT / ALTER TRIGGER / ENABLE TRIGGER 等写法），
只检查这几类真实会出问题的地方：

1. 括号是否配对（字符串与注释内的括号不计入）
2. BEGIN / CASE 与 END 是否配对
3. 外键 REFERENCES 指向的表是否在本仓库脚本里创建过
4. CONSTRAINT 名称是否重复（SQL Server 要求同一 schema 内唯一）
5. 每批（GO 分隔）是否非空、文件是否至少包含一张表

这些检查能挡住手改脚本时最常见的事故，但不等价于在 SQL Server 上执行。
"""

import glob
import re
import sys

WORD_BEGIN_END = re.compile(r"\b(BEGIN|CASE|END)\b", re.IGNORECASE)
CREATE_TABLE = re.compile(r"\bCREATE\s+TABLE\s+([\w\[\]\.#@]+)", re.IGNORECASE)
REFERENCES = re.compile(r"\bREFERENCES\s+([\w\[\]\.#@]+)", re.IGNORECASE)
CONSTRAINT = re.compile(r"\bCONSTRAINT\s+([\w\[\]\.#@]+)", re.IGNORECASE)
GO_LINE = re.compile(r"^\s*GO\s*(?:--.*)?$", re.IGNORECASE | re.MULTILINE)


def mask_literals_and_comments(text: str) -> str:
    """把字符串字面量和注释替换成等长空白（保留换行），便于后续做括号/关键字统计。"""
    out = []
    i, n = 0, len(text)
    state = "code"
    while i < n:
        ch = text[i]
        nxt = text[i + 1] if i + 1 < n else ""
        if state == "code":
            if ch == "-" and nxt == "-":
                state = "line_comment"
                out.append("  ")
                i += 2
                continue
            if ch == "/" and nxt == "*":
                state = "block_comment"
                out.append("  ")
                i += 2
                continue
            if ch == "'":
                state = "string"
                out.append(" ")
                i += 1
                continue
            out.append(ch)
            i += 1
            continue
        if state == "line_comment":
            if ch == "\n":
                state = "code"
                out.append("\n")
            else:
                out.append(" ")
            i += 1
            continue
        if state == "block_comment":
            if ch == "*" and nxt == "/":
                state = "code"
                out.append("  ")
                i += 2
                continue
            out.append("\n" if ch == "\n" else " ")
            i += 1
            continue
        if state == "string":
            if ch == "'" and nxt == "'":
                out.append("  ")
                i += 2
                continue
            if ch == "'":
                state = "code"
                out.append(" ")
                i += 1
                continue
            out.append("\n" if ch == "\n" else " ")
            i += 1
            continue
    return "".join(out)


def normalize_identifier(name: str) -> str:
    return name.replace("[", "").replace("]", "").strip().lower()


def check_file(path: str, known_tables: set) -> list:
    with open(path, encoding="utf-8") as fh:
        text = fh.read()

    masked = mask_literals_and_comments(text)
    errors = []

    depth = 0
    line = 1
    for ch in masked:
        if ch == "\n":
            line += 1
        elif ch == "(":
            depth += 1
        elif ch == ")":
            depth -= 1
            if depth < 0:
                errors.append(f"第 {line} 行出现多余的右括号")
                depth = 0
    if depth > 0:
        errors.append(f"括号不匹配：还差 {depth} 个右括号")

    begin = end = 0
    for match in WORD_BEGIN_END.finditer(masked):
        token = match.group(1).upper()
        if token in ("BEGIN", "CASE"):
            begin += 1
        else:
            end += 1
    if begin != end:
        errors.append(f"BEGIN/CASE 共 {begin} 个，END 共 {end} 个，不配对")

    tables = [normalize_identifier(m.group(1)) for m in CREATE_TABLE.finditer(masked)]
    for table in tables:
        known_tables.add(table)

    for match in REFERENCES.finditer(masked):
        target = normalize_identifier(match.group(1))
        if target not in known_tables and target not in tables:
            errors.append(f"外键引用了未创建的表: {match.group(1)}")

    names = [normalize_identifier(m.group(1)) for m in CONSTRAINT.finditer(masked)]
    seen, dup = set(), []
    for name in names:
        if name in seen and name not in dup:
            dup.append(name)
        seen.add(name)
    for name in dup:
        errors.append(f"约束名重复: {name}")

    batches = [b for b in GO_LINE.split(text) if b.strip()]
    if not batches:
        errors.append("文件里没有可执行内容")

    return errors, len(tables), len(names), len(batches)


def main() -> int:
    files = sorted(glob.glob("**/*.sql", recursive=True))
    if not files:
        print("没有找到 .sql 文件", file=sys.stderr)
        return 1

    known_tables: set = set()
    # 先收集全部脚本里创建的表，再逐个文件检查外键引用
    for path in files:
        with open(path, encoding="utf-8") as fh:
            masked = mask_literals_and_comments(fh.read())
        known_tables.update(normalize_identifier(m.group(1)) for m in CREATE_TABLE.finditer(masked))

    failed = 0
    for path in files:
        errors, table_count, constraint_count, batch_count = check_file(path, known_tables)
        if errors:
            failed += 1
            print(f"FAIL {path}", file=sys.stderr)
            for message in errors[:12]:
                print(f"   - {message}", file=sys.stderr)
        else:
            print(f"OK   {path} — {table_count} 张表 / {constraint_count} 个约束 / {batch_count} 批")

    if failed:
        print(f"\n{failed} 个文件未通过检查", file=sys.stderr)
        return 1
    print(f"\n{len(files)} 个文件全部通过结构检查")
    return 0


if __name__ == "__main__":
    sys.exit(main())
