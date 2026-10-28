"""Capture each live Android screen, including the system keyboard and bars."""
import argparse
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys

root = Path(__file__).resolve().parents[1]
parser = argparse.ArgumentParser()
parser.add_argument('--device', default='emulator-5554')
parser.add_argument('--only', default='', help='Comma-separated two-digit screen IDs')
args = parser.parse_args()
flutter = shutil.which('flutter')
sdk = Path(os.environ.get('ANDROID_HOME') or os.environ.get('ANDROID_SDK_ROOT') or Path.home() / 'AppData/Local/Android/Sdk')
adb = sdk / 'platform-tools/adb.exe'
if not flutter or not adb.exists():
    sys.exit('Flutter or Android platform-tools could not be found.')

command = ['cmd.exe', '/d', '/c', flutter, 'drive', '-d', args.device,
           '--driver', 'test_driver/screenshots.dart', '--target', 'integration_test/screenshots_test.dart']
if args.only:
    command.append('--dart-define=CAPTURE_ONLY=' + args.only)
capture_dir = root / 'build/native_screenshots'
capture_dir.mkdir(parents=True, exist_ok=True)
log_dir = root / 'docs/validation'
log_dir.mkdir(parents=True, exist_ok=True)
captured = []
process = subprocess.Popen(command, cwd=root, stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
                           text=True, encoding='utf-8', errors='replace', bufsize=1)
log_name = 'android-capture' + ('-' + args.only.replace(',', '-') if args.only else '') + '.log'
with (log_dir / log_name).open('w', encoding='utf-8') as log:
    for line in process.stdout:
        log.write(line)
        log.flush()
        match = re.search(r'NATIVE_CAPTURE:([a-z0-9_]+)', line)
        if match:
            name = match.group(1)
            image = subprocess.check_output([str(adb), '-s', args.device, 'exec-out', 'screencap', '-p'])
            (capture_dir / (name + '.png')).write_bytes(image)
            captured.append(name)
            print(f'Captured {len(captured)}: {name}', flush=True)
        elif any(word in line for word in ['Built ', 'Installing ', 'All tests passed', 'Exception', 'Test failed', 'Failure Details']):
            print(line.rstrip(), flush=True)
code = process.wait()
if code:
    sys.exit(code)
for name in captured:
    shutil.copy2(capture_dir / (name + '.png'), root / 'docs/screenshots' / (name + '.png'))
print(f'Saved {len(captured)} native Android screenshots to docs/screenshots.')
