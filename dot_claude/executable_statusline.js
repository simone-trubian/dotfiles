#!/usr/bin/env node
'use strict';

const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');

const RESET = '\x1b[0m';

function rgb(r, g, b, bold) {
  return `\x1b[${bold ? '1;' : ''}38;2;${r};${g};${b}m`;
}

function colorize(text, r, g, b, bold) {
  return `${rgb(r, g, b, bold)}${text}${RESET}`;
}

function readStdin() {
  try {
    const data = fs.readFileSync(0, 'utf8');
    return JSON.parse(data);
  } catch (e) {
    return {};
  }
}

function safeExec(cmd, cwd) {
  try {
    return execSync(cmd, { cwd, stdio: ['ignore', 'pipe', 'ignore'] })
      .toString()
      .trim();
  } catch (e) {
    return '';
  }
}

function usageTier(pct) {
  if (pct >= 90) return { emoji: '🚨', color: [220, 40, 20] }; // red
  if (pct >= 70) return { emoji: '🔥', color: [255, 140, 0] }; // orange
  if (pct >= 20) return { emoji: '⚡', color: [220, 200, 0] }; // yellow
  return { emoji: '🟢', color: [0, 200, 80] }; // green
}

// Plan usage limits (claude.ai Settings > Usage), from the rate_limits field
// Claude Code passes in. The reset time only appears from 70%, when it matters.
function limitPart(label, limit, withDay) {
  if (!limit || typeof limit.used_percentage !== 'number') return null;
  const pct = Math.round(limit.used_percentage);
  const [r, g, b] = usageTier(pct).color;
  let text = `${label} ${pct}%`;
  if (pct >= 70 && limit.resets_at) {
    const at = new Date(limit.resets_at * 1000);
    const time = at.toLocaleTimeString('en-GB', { hour: '2-digit', minute: '2-digit' });
    text += `, resets ${withDay ? at.toLocaleDateString('en-GB', { weekday: 'short' }) + ' ' : ''}${time}`;
  }
  return colorize(text, r, g, b, pct >= 70);
}

function main() {
  const input = readStdin();
  const workspace = input.workspace || {};
  const cwd = workspace.current_dir || input.cwd || process.cwd();
  const projectDir = workspace.project_dir || cwd;
  const modelName = (input.model && input.model.display_name) || 'unknown';

  // Repo name: prefer explicit repo metadata, fall back to the project folder name.
  let repoName;
  if (workspace.repo && workspace.repo.name) {
    repoName = workspace.repo.name;
  } else {
    repoName = path.basename(projectDir);
  }

  // Current git branch (skip optional locks so we never fight a concurrent git process).
  let branch = safeExec('git --no-optional-locks rev-parse --abbrev-ref HEAD', cwd);
  if (!branch || branch === 'HEAD') {
    branch = (input.worktree && input.worktree.branch) || branch || 'no-branch';
  }

  // Files changed = modified + untracked + staged, i.e. every path porcelain reports.
  const statusOutput = safeExec('git --no-optional-locks status --porcelain', cwd);
  const filesChanged = statusOutput ? statusOutput.split('\n').filter(Boolean).length : 0;

  // Context usage percentage: use the pre-calculated field when present,
  // otherwise derive it from raw token counts vs. the context window size.
  const cw = input.context_window || {};
  let usedPct = cw.used_percentage;
  if (usedPct === null || usedPct === undefined) {
    const totalInput = cw.total_input_tokens;
    const windowSize = cw.context_window_size;
    if (typeof totalInput === 'number' && typeof windowSize === 'number' && windowSize > 0) {
      usedPct = (totalInput / windowSize) * 100;
    } else {
      usedPct = 0;
    }
  }
  usedPct = Math.max(0, Math.min(100, usedPct));

  const tier = usageTier(usedPct);
  const pctText = `${Math.round(usedPct)}%`;

  const sep = colorize(' | ', 90, 90, 90);

  const parts = [
    colorize(repoName, 255, 215, 0, true),
    colorize(`🌿(${branch})`, 0, 255, 255, true),
    tier.emoji,
    colorize(pctText, tier.color[0], tier.color[1], tier.color[2], true),
    limitPart('session', (input.rate_limits || {}).five_hour, false),
    limitPart('week', (input.rate_limits || {}).seven_day, true),
    String(filesChanged),
    colorize(`🤖 ${modelName}`, 255, 0, 255),
  ].filter(Boolean);

  process.stdout.write(parts.join(sep));
}

main();
