"""Position-preserving lexical helpers; advisory source checks, not Swift parsing."""
import re


def blank(text):
    return ''.join('\n' if character == '\n' else ' ' for character in text)


def code_mask(source):
    """Hide comments and Swift string literals, retaining offsets and line numbers."""
    output, position = [], 0
    while position < len(source):
        start = position
        if source.startswith('//', position):
            position = source.find('\n', position)
            position = len(source) if position < 0 else position
        elif source.startswith('/*', position):
            position, depth = position + 2, 1
            while position < len(source) and depth:
                if source.startswith('/*', position):
                    depth, position = depth + 1, position + 2
                elif source.startswith('*/', position):
                    depth, position = depth - 1, position + 2
                else:
                    position += 1
        else:
            literal = re.match(r'(#+)?("""|")', source[position:]) if source[position] in '#"' else None
            if literal:
                hashes, quote = literal.group(1) or '', literal.group(2)
                position += len(literal.group())
                end = quote + hashes
                escape = '\\' + hashes
                while position < len(source):
                    if source.startswith(escape, position):
                        position += len(escape) + 1
                    elif source.startswith(end, position):
                        position += len(end)
                        break
                    else:
                        position += 1
            else:
                output.append(source[position])
                position += 1
                continue
        output.append(blank(source[start:position]))
    return ''.join(output)


def production_mask(source):
    """Hide only complete #Preview invocations, including their balanced closures."""
    masked = code_mask(source)
    result = list(masked)
    for macro in re.finditer(r'#Preview\b', masked):
        position, parentheses, brackets = macro.end(), 0, 0
        while position < len(masked):
            char = masked[position]
            parentheses += (char == '(') - (char == ')')
            brackets += (char == '[') - (char == ']')
            if char == '{' and parentheses == brackets == 0:
                break
            position += 1
        depth = 1
        position += 1
        while position < len(masked) and depth:
            depth += (masked[position] == '{') - (masked[position] == '}')
            position += 1
        if not depth:
            result[macro.start():position] = blank(masked[macro.start():position])
    return ''.join(result)
