"""Read-only environment diagnosis; never changes Xcode selection or builds targets."""
import os
import platform
import re
import shutil
import subprocess
import sys
from pathlib import Path


def probe(command, environment):
    try:
        result = subprocess.run(command, env=environment, capture_output=True, text=True, timeout=10)
        return {'command': command, 'exitCode': result.returncode,
                'output': (result.stdout or result.stderr).strip()}
    except (OSError, subprocess.TimeoutExpired) as error:
        return {'command': command, 'exitCode': None, 'output': str(error)}


def environment_for_xcode(environment=None):
    selected = dict(os.environ if environment is None else environment)
    if selected.get('DEVELOPER_DIR') or platform.system() != 'Darwin':
        return selected
    current = probe(['xcode-select', '-p'], selected)
    path = current['output'] if current['exitCode'] == 0 else ''
    if path and (Path(path) / 'usr/bin/xcodebuild').is_file():
        return selected
    for candidate in ('/Applications/Xcode.app', '/Applications/Xcode-beta.app'):
        developer = Path(candidate) / 'Contents/Developer'
        if (developer / 'usr/bin/xcodebuild').is_file():
            selected['DEVELOPER_DIR'] = str(developer)
            break
    return selected


def version(value):
    match = re.match(r'(\d+)(?:\.(\d+))?', value)
    return tuple(int(part or 0) for part in match.groups()) if match else (0, 0)


def doctor(root):
    environment = environment_for_xcode()
    prerequisites = {'macOS': platform.system() == 'Darwin', 'python310': sys.version_info >= (3, 10),
                     'git': shutil.which('git') is not None, 'plutil': shutil.which('plutil') is not None}
    schemes = sorted(str(path.relative_to(root)) for path in root.glob('*.xcodeproj/xcshareddata/xcschemes/*.xcscheme'))
    prerequisites['sharedTripScheme'] = any(Path(path).name == 'trip.xcscheme' for path in schemes)
    declared = dict(re.findall(r'\.(iOS|macOS|visionOS)\("([\d.]+)"\)',
                              (root / 'Packages/TripKit/Package.swift').read_text()))
    toolchain, sdks = {}, {}
    if prerequisites['macOS']:
        toolchain['xcode'] = probe(['xcodebuild', '-version'], environment)
        toolchain['swift'] = probe(['xcrun', 'swift', '--version'], environment)
        prerequisites['xcode'] = toolchain['xcode']['exitCode'] == 0
        prerequisites['swiftCompiler'] = toolchain['swift']['exitCode'] == 0
        swift = probe(['xcrun', '--find', 'swift'], environment)
        host = Path(swift['output']).parent.parent / 'lib/swift/host'
        prerequisites['swiftSyntax'] = swift['exitCode'] == 0 and (host / 'SwiftSyntax.swiftmodule').exists()
        for sdk, target in {'iphoneos': 'iOS', 'iphonesimulator': 'iOS', 'xrsimulator': 'visionOS', 'macosx': 'macOS'}.items():
            result = probe(['xcrun', '--sdk', sdk, '--show-sdk-version'], environment)
            sdks[sdk] = dict(result, required=declared.get(target),
                             meetsMinimum=bool(declared.get(target)) and result['exitCode'] == 0
                             and version(result['output']) >= version(declared[target]))
    else:
        prerequisites['swiftSyntax'] = False
    return {'schemaVersion': 1, 'readOnly': True, 'platform': platform.platform(),
            'python': platform.python_version(), 'developerDirectory': environment.get('DEVELOPER_DIR', 'system-selected'),
            'prerequisites': prerequisites, 'readyForSourceChecks': all(prerequisites.values()),
            'readyForCompilation': all(prerequisites.values()) and bool(sdks) and all(sdk['meetsMinimum'] for sdk in sdks.values()),
            'deploymentMinimums': declared, 'toolchain': toolchain, 'sdks': sdks, 'sharedSchemes': schemes,
            'outputDirectories': ['.build/audit', '.build/xcode', '.build/visionos', '.build/models', '.build/modules', '.build/performance', '.build/verification'],
            'buildRootOverride': environment.get('TRIP_BUILD_ROOT'),
            'limitations': 'Reports prerequisites only. No source gate, compilation, signing, simulator, or device behavior was verified.'}
