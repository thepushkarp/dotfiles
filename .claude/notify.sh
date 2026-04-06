#!/bin/bash
set -euo pipefail

# Pipe the full hook JSON into Python, which handles parsing, context
# extraction, and the osascript call with proper escaping.
cat | python3 -c "
import sys, json, os, subprocess

d = json.load(sys.stdin)
msg = d.get('message', 'Claude needs attention')
ntype = d.get('notification_type', 'unknown')
cwd = d.get('cwd', '')
transcript = d.get('transcript_path', '')

project = os.path.basename(cwd) if cwd else 'unknown'

# --- Extract last tool/action from transcript ---
last_tool = ''
if transcript and os.path.isfile(transcript):
    try:
        with open(transcript, 'r') as f:
            lines = f.readlines()
        for line in reversed(lines):
            entry = json.loads(line)
            if entry.get('type') == 'assistant':
                content = entry.get('message', {}).get('content', [])
                for block in reversed(content if isinstance(content, list) else []):
                    if isinstance(block, dict) and block.get('type') == 'tool_use':
                        name = block.get('name', '')
                        ti = block.get('input', {})
                        if name == 'Bash':
                            cmd = ti.get('command', '')
                            last_tool = f'Running: {cmd[:80]}'
                        elif name == 'Edit':
                            last_tool = f'Editing: {os.path.basename(ti.get(\"file_path\", \"\"))}'
                        elif name == 'Read':
                            last_tool = f'Reading: {os.path.basename(ti.get(\"file_path\", \"\"))}'
                        elif name == 'Write':
                            last_tool = f'Writing: {os.path.basename(ti.get(\"file_path\", \"\"))}'
                        elif name == 'Grep':
                            last_tool = f'Searching: {ti.get(\"pattern\", \"\")[:60]}'
                        elif name == 'Glob':
                            last_tool = f'Finding: {ti.get(\"pattern\", \"\")[:60]}'
                        elif name == 'Agent':
                            last_tool = f'Agent: {ti.get(\"description\", \"\")[:60]}'
                        else:
                            last_tool = f'Tool: {name}'
                        break
                if last_tool:
                    break
    except Exception:
        pass

# --- Build notification parts ---
title = f'Claude Code [{project}]'

type_labels = {
    'permission_prompt':  'Permission Needed',
    'idle_prompt':        'Waiting for Input',
    'auth_success':       'Authentication Complete',
    'elicitation_dialog': 'Question for You',
}
subtitle = type_labels.get(ntype, 'Notification')
if last_tool:
    subtitle = f'{subtitle} | {last_tool}'

sounds = {
    'permission_prompt':  'Funk',
    'elicitation_dialog': 'Pop',
    'idle_prompt':        'Tink',
}
sound = sounds.get(ntype, '')

# --- Escape for AppleScript string literals ---
def esc(s):
    return s.replace('\\\\', '\\\\\\\\').replace('\"', '\\\\\"')

applescript = f'display notification \"{esc(msg)}\" with title \"{esc(title)}\" subtitle \"{esc(subtitle)}\"'
if sound:
    applescript += f' sound name \"{sound}\"'

subprocess.run(['osascript', '-e', applescript], check=True)
"
