"""Small lexical helpers for source ownership checks, not a Swift type checker."""
import re

DECLARATIONS = re.compile(r"\b(?:struct|class|actor|enum|protocol|typealias)\s+(\w+)")
IMPORTS = re.compile(r"^\s*(?:(?:public|internal|private|@testable)\s+)?import\s+"
                     r"(?:(?:typealias|struct|class|enum|protocol|let|var|func)\s+)?(\w+)", re.M)
IDENTIFIERS = re.compile(r"\b[A-Za-z_]\w*\b")
COMMENTS_AND_STRINGS = re.compile(r'//[^\n]*|/\*.*?\*/|""".*?"""|"(?:\\.|[^"\\])*"', re.S)


def code_only(source):
    """Ignore prose so comments and presentation text do not create dependencies."""
    return COMMENTS_AND_STRINGS.sub(lambda match: "\n" * match[0].count("\n"), source)


def production_source(source):
    """Exclude positive DEBUG blocks; local previews may use PreviewSupport."""
    result, debug_depth, depth = [], None, 0
    for line in source.splitlines():
        directive = line.strip()
        if directive.startswith("#if "):
            depth += 1
            if directive == "#if DEBUG" and debug_depth is None:
                debug_depth = depth
        elif directive == "#else" and debug_depth == depth:
            debug_depth = None
        elif directive == "#endif":
            if debug_depth == depth:
                debug_depth = None
            depth -= 1
        elif debug_depth is None:
            result.append(line)
    return code_only("\n".join(result))


def declared_types(paths):
    return {name for path in paths for name in DECLARATIONS.findall(code_only(path.read_text()))}
