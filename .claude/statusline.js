#!/usr/bin/env node
// Line 1: mirrors ~/dotfiles/.bashrc PS1  -> :<cwd> (<branch>*) plus ahead/behind and session name
// Line 2: model · effort · thinking · fast · version
// Line 3: last request tokens · tok/s · cache health and TTL
// Line 4: context window
// Line 5: cost · time · lines changed · rate limits
const fs = require('fs');
const { execFileSync } = require('child_process');

const c = (code, s) => `\x1b[${code}m${s}\x1b[00m`;
const fmt = n => n >= 1e6 ? (n / 1e6).toFixed(1) + 'M' : n >= 1e3 ? (n / 1e3).toFixed(1) + 'k' : String(n);
const dur = secs => {
  secs = Math.max(0, Math.round(secs));
  const dd = Math.floor(secs / 86400), h = Math.floor(secs % 86400 / 3600), m = Math.floor(secs % 3600 / 60), s = secs % 60;
  return dd ? `${dd}d${h}h` : h ? `${h}h${m}m` : m ? `${m}m${s}s` : `${s}s`;
};
const pctColor = p => p >= 80 ? '31' : p >= 50 ? '33' : '32';
const git = (cwd, ...args) => {
  try {
    return execFileSync('git', ['-C', cwd, '--no-optional-locks', ...args], { encoding: 'utf8', stdio: ['ignore', 'pipe', 'ignore'] }).trim();
  } catch { return ''; }
};

// Sum output tokens across the main transcript, deduped by message id (streamed blocks repeat usage)
function sessionOutputTokens(path) {
  const seen = new Map();
  try {
    for (const line of fs.readFileSync(path, 'utf8').split('\n')) {
      if (!line.includes('"output_tokens"')) continue;
      try {
        const msg = JSON.parse(line).message;
        if (msg?.usage) seen.set(msg.id, msg.usage.output_tokens || 0);
      } catch {}
    }
  } catch {}
  let total = 0;
  for (const v of seen.values()) total += v;
  return total;
}

const d = JSON.parse(fs.readFileSync(0, 'utf8'));
const now = Date.now() / 1000;
const sep = c('90', ' · ');
const cwd = d.workspace?.current_dir || d.cwd || process.cwd();

// Line 1
let gitInfo = '';
const branch = git(cwd, 'symbolic-ref', '--short', 'HEAD') || git(cwd, 'rev-parse', '--short', 'HEAD');
if (branch) {
  gitInfo = ` (${branch}${git(cwd, 'status', '--porcelain') ? '*' : ''})`;
  const [behind, ahead] = git(cwd, 'rev-list', '--left-right', '--count', '@{upstream}...HEAD').split(/\s+/).map(Number);
  if (ahead) gitInfo += ` ⇡ ${ahead}`;
  if (behind) gitInfo += ` ⇣ ${behind}`;
}
let line1 = `${c('01;32', '->')} :${c('01;34', cwd)}${c('91', gitInfo)}`;
if (d.session_name) line1 += sep + c('03;37', d.session_name);

// Line 2
const model = [c('01;35', d.model?.display_name || d.model?.id || '?')];
if (d.effort?.level) model.push(`effort ${c('36', d.effort.level)}`);
if (d.thinking) model.push(d.thinking.enabled ? c('36', 'thinking on') : c('90', 'thinking off'));
model.push(d.fast_mode ? c('01;33', 'fast ON') : c('90', 'fast off'));
if (d.version) model.push(c('90', `v${d.version}`));

// Line 3: last request ↑ uncached in ↻ cache read ↓ out · session tok/s · cache health
const tok = [];
const u = d.context_window?.current_usage;
if (u) {
  const uncached = (u.input_tokens || 0) + (u.cache_creation_input_tokens || 0);
  tok.push(`↑ ${fmt(uncached)}  ↻ ${fmt(u.cache_read_input_tokens || 0)}  ↓ ${fmt(u.output_tokens || 0)}`);
}
const apiSecs = (d.cost?.total_api_duration_ms || 0) / 1000;
const outTotal = d.transcript_path ? sessionOutputTokens(d.transcript_path) : 0;
if (apiSecs > 0 && outTotal > 0) tok.push(`${(outTotal / apiSecs).toFixed(1)} t/s`);
const pc = d.prompt_cache;
if (pc) {
  const left = pc.expires_at ? pc.expires_at - now : 0;
  const ttl = pc.warm && left > 0 ? ` (${dur(left)} left)` : ' (cold)';
  if (pc.misses > 0) {
    const cause = pc.last_miss_cause ? ` ${pc.last_miss_cause}` : '';
    tok.push(c('01;31', `cache ✗ ${pc.misses}${cause}`) + c('90', ttl));
  } else {
    tok.push(c('32', `cache ✓ ${Math.round((pc.hit_ratio || 0) * 100)}%`) + c(left > 0 && left < 300 ? '33' : '90', ttl));
  }
}

// Line 4: context bar, used/size, free
const ctx = [];
const cw = d.context_window;
if (cw?.context_window_size) {
  const used = u ? (u.input_tokens || 0) + (u.cache_creation_input_tokens || 0) + (u.cache_read_input_tokens || 0) : 0;
  const pct = cw.used_percentage ?? Math.round(used / cw.context_window_size * 100);
  const color = pctColor(pct);
  const filled = Math.min(10, Math.round(pct / 10));
  ctx.push(`ctx ${c(color, '█'.repeat(filled))}${c('90', '░'.repeat(10 - filled))} ${c(color, pct + '%')}`);
  ctx.push(`${fmt(used)}/${fmt(cw.context_window_size)}`);
  ctx.push(`${fmt(Math.max(0, cw.context_window_size - used))} free`);
  if (d.exceeds_200k_tokens) ctx.push(c('33', '>200k'));
}

// Line 5: cost · wall time (api time) · lines changed · rate limits
const sess = [];
const cost = d.cost;
if (cost) {
  // Subscription isn't billed per token; this is the API-equivalent estimate
  if (cost.total_cost_usd != null) sess.push(c('33', `≈ $${cost.total_cost_usd.toFixed(2)}`) + c('90', ' API'));
  if (cost.total_duration_ms) sess.push(`⏱ ${dur(cost.total_duration_ms / 1000)}` + c('90', ` (api ${dur(apiSecs)})`));
  if (cost.total_lines_added || cost.total_lines_removed) {
    sess.push(`${c('32', '+' + (cost.total_lines_added || 0))} ${c('31', '−' + (cost.total_lines_removed || 0))}`);
  }
}
for (const [key, label] of [['five_hour', '5h'], ['seven_day', '7d']]) {
  const rl = d.rate_limits?.[key];
  if (!rl) continue;
  const reset = rl.resets_at ? c('90', ` (resets ${dur(rl.resets_at - now)})`) : '';
  sess.push(`${label} ${c(pctColor(rl.used_percentage), rl.used_percentage + '%')}${reset}`);
}

process.stdout.write([line1, model.join(sep), tok.join(sep), ctx.join(sep), sess.join(sep)].filter(Boolean).join('\n'));
