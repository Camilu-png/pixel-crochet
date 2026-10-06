#!/usr/bin/env node
import { spawnSync } from 'node:child_process';
import { validateSupabaseBuildEnvironment } from './supabase-build-config.mjs';

try {
  validateSupabaseBuildEnvironment(process.env);
} catch (error) {
  console.error(error.message);
  process.exit(1);
}

const flutterArgs = ['build', 'web', '--release'];
if (process.env.SUPABASE_URL?.trim()) {
  flutterArgs.push(
    `--dart-define=SUPABASE_URL=${process.env.SUPABASE_URL.trim()}`,
    `--dart-define=SUPABASE_PUBLISHABLE_KEY=${process.env.SUPABASE_PUBLISHABLE_KEY.trim()}`,
  );
}

const result = spawnSync('flutter', flutterArgs, { stdio: 'inherit' });
if (result.error) {
  console.error(result.error.message);
  process.exit(1);
}
process.exit(result.status ?? 1);
