"""Advisory owner and logical-type inventory; does not change the 100/20 policy."""
from collections import defaultdict
import re
from statistics import median
from .catalog import catalog
from source_text import production_mask

TYPES = re.compile(r'\b(struct|class|actor|enum|protocol|extension)\s+([A-Za-z_]\w*(?:\.[A-Za-z_]\w*)*)')
MEMBERS = re.compile(r'\b(?:func\s+\w+|init\s*\(|(?:let|var)\s+\w+|subscript\s*\()')


def metrics(root, owner=None):
    areas = catalog(root)
    if owner and owner not in areas:
        raise ValueError(f'Unknown owner: {owner}')
    owners, types = [], defaultdict(lambda: {'files': set(), 'extensions': 0, 'declarations': 0, 'memberMentions': 0})
    for name, spec in areas.items():
        if owner and name != owner:
            continue
        counts = []
        files = sorted((root / spec['path']).rglob('*.swift'))
        for path in files:
            source = path.read_text()
            counts.append(len(source.splitlines()))
            masked = production_mask(source)
            for match in TYPES.finditer(masked):
                prefix = masked[masked.rfind('\n', 0, match.start()) + 1:match.start()]
                if re.search(r'\bimport\b', prefix) or match[2] in {'func', 'var', 'let'}:
                    continue
                entry = types[(name, match[2])]
                entry['files'].add(str(path.relative_to(root)))
                entry['extensions' if match[1] == 'extension' else 'declarations'] += 1
                opening = masked.find('{', match.end())
                position, depth = opening + 1, 1
                while opening >= 0 and position < len(masked) and depth:
                    depth += (masked[position] == '{') - (masked[position] == '}')
                    position += 1
                if opening >= 0 and depth == 0:
                    entry['memberMentions'] += len(MEMBERS.findall(masked[opening + 1:position - 1]))
        owners.append({'owner': name, 'files': len(files), 'physicalLines': sum(counts),
                       'medianFileLines': median(counts) if counts else 0,
                       'filesUnder20Lines': sum(count < 20 for count in counts),
                       'filesOver100Lines': sum(count > 100 for count in counts),
                       'declaredDependencies': spec.get('dependencies', []) + spec.get('packages', [])})
    logical = [dict(owner=name, type=kind, **{key: value for key, value in item.items() if key != 'files'},
                    fileCount=len(item['files']), files=sorted(item['files'])) for (name, kind), item in types.items()]
    logical.sort(key=lambda item: (-item['fileCount'], -item['memberMentions'], item['owner'], item['type']))
    return {'schemaVersion': 1, 'advisory': True, 'owners': owners, 'logicalTypes': logical,
            'limitations': 'Lexical inventory, not type resolution or complexity. Member mentions include locals/nested declarations; names can collide. Counts do not establish defects or justify extra modules. Existing 100/20 limits remain enforced separately.'}
