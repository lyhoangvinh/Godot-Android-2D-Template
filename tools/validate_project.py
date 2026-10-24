#!/usr/bin/env python3
"""Static Godot reference/secrets checker. NOT a replacement for the Godot parser."""
from pathlib import Path
import json
import re
import sys

ROOT = Path(__file__).resolve().parents[1]
issues = []
checked = 0
path_pattern = re.compile(r'res://([A-Za-z0-9_./-]+)')
class_pattern = re.compile(r'^class_name\s+([A-Za-z_][A-Za-z_0-9]*)', re.M)
classes = {}
allowed_extensions = {'.gd', '.tscn', '.tres', '.godot', '.cfg', '.json'}
# English-only policy: flag Latin characters with diacritics used in Vietnamese text.
non_english_latin_pattern = re.compile(r'[\u00c0-\u00ff\u0102-\u0103\u0110-\u0111\u01a0-\u01b0\u1ea0-\u1ef9]')

for file in ROOT.rglob('*'):
    if not file.is_file() or any(part in {'.git', '.godot'} for part in file.relative_to(ROOT).parts):
        continue
    if file.suffix.lower() in {'.jks', '.keystore', '.p12', '.aab', '.apk'}:
        issues.append(f'Forbidden artifact/secret file: {file.relative_to(ROOT)}')
    # Documentation and project code must remain English-only.
    if file.suffix.lower() in {'.md', '.gd', '.tscn', '.tres', '.godot', '.cfg', '.json', '.ps1', '.py', '.txt'}:
        content_to_check = file.read_text(encoding='utf-8')
        if non_english_latin_pattern.search(content_to_check):
            issues.append(f'Non-English accented text detected: {file.relative_to(ROOT)}')
    if file.suffix not in allowed_extensions:
        continue
    checked += 1
    contents = file.read_text(encoding='utf-8')
    for match in path_pattern.finditer(contents):
        source = match.group(1).rstrip('.,;:')
        if not (ROOT / source).is_file() and not (ROOT / source).is_dir():
            issues.append(f'{file.relative_to(ROOT)}: missing res://{source}')
    if file.suffix == '.gd':
        for cls in class_pattern.findall(contents):
            if cls in classes:
                issues.append(f'Duplicate class_name {cls}: {classes[cls]}, {file.relative_to(ROOT)}')
            classes[cls] = file.relative_to(ROOT)
    if file.suffix == '.json':
        try:
            json.loads(contents)
        except json.JSONDecodeError as err:
            issues.append(f'{file.relative_to(ROOT)}: {err}')
    if file.suffix in {'.tscn', '.tres'} and '[gd_' not in contents[:100]:
        issues.append(f'{file.relative_to(ROOT)}: missing Godot scene/resource header')

required = ['project.godot', 'app/main.tscn', 'AGENTS.md', 'docs/architecture.md', 'docs/validation.md']
for name in required:
    if not (ROOT / name).exists():
        issues.append(f'Missing required file {name}')


# Basic scene tree cross-check for literal `$Node/Child` references in attached scripts.
# Dynamic paths and programmatic scene construction still require Godot validation.
for scene in ROOT.rglob('*.tscn'):
    scene_text = scene.read_text(encoding='utf-8')
    script_resources = dict(re.findall(r'\[ext_resource type="Script" path="res://([^"]+)" id="([^"]+)"\]', scene_text))
    # Earlier dict maps file -> id; reverse it for script ExtResource lookup.
    script_ids = {resource_id: source for source, resource_id in script_resources.items()}
    blocks = re.split(r'(?=^\[node name=)', scene_text, flags=re.M)
    path_set = set()
    attached = []
    for block in blocks:
        header = re.match(r'\[node name="([^"]+)"(?: type="[^"]+")?(?: parent="([^"]+)")?', block)
        if header is None:
            continue
        name, parent = header.groups()
        node_path = '' if parent is None else (name if parent == '.' else parent + '/' + name)
        path_set.add(node_path)
        linked = re.search(r'^script = ExtResource\("([^"]+)"\)', block, flags=re.M)
        if linked is not None and linked.group(1) in script_ids:
            attached.append(script_ids[linked.group(1)])
    for source in attached:
        script_path = ROOT / source
        if not script_path.is_file():
            continue
        text_data = script_path.read_text(encoding='utf-8')
        for node_ref in re.findall(r'\$([A-Za-z_][A-Za-z_0-9]*(?:/[A-Za-z_][A-Za-z_0-9]*)*)', text_data):
            if node_ref not in path_set:
                issues.append(f'{script_path.relative_to(ROOT)}: NodePath ${node_ref} not in {scene.relative_to(ROOT)}')

print(f'Static audit: {checked} text assets, {len(classes)} registered GDScript classes')
if issues:
    for issue in issues:
        print('ERROR:', issue)
    sys.exit(1)
print('PASS: references, unique class names, JSON, English-only policy, forbidden signing artifacts')
print('NOTE: Godot parser, headless runtime, APK/AAB and Android behavior NOT checked.')
