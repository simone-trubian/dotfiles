#!/usr/bin/env node
'use strict';

// PreToolUse hook: any write to an auto-memory folder (~/.claude/projects/<project>/memory)
// needs the user's approval. File tools are matched on their target path; shell commands
// are matched on any mention of a memory folder, since reads and writes can't be told apart
// there. Read/Grep/Glob aren't routed here, so reading memory stays free.

const fs = require('fs');

const MEMORY_PATH = /\.claude\/+projects\/+[^/\s"'`]+\/+memory(\/|$|[\s"'`])/i;

function readStdin() {
  try {
    return JSON.parse(fs.readFileSync(0, 'utf8'));
  } catch (e) {
    return {};
  }
}

function normalise(s) {
  return String(s || '').replace(/\\+/g, '/');
}

function main() {
  const input = readStdin();
  const tool = input.tool_name || '';
  const ti = input.tool_input || {};

  let target;
  if (tool === 'Bash' || tool === 'PowerShell') {
    if (MEMORY_PATH.test(normalise(ti.command) + ' ')) target = 'a shell command touching memory';
  } else {
    const p = normalise(ti.file_path || ti.notebook_path);
    if (MEMORY_PATH.test(p + ' ')) target = p.replace(/^.*\/memory\//i, 'memory/');
  }
  if (!target) return;

  process.stdout.write(JSON.stringify({
    hookSpecificOutput: {
      hookEventName: 'PreToolUse',
      permissionDecision: 'ask',
      permissionDecisionReason: `Memory write (${target}): approve to save it, or deny to keep it out of memory.`,
    },
  }));
}

main();
