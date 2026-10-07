import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';
import test from 'node:test';
const projectRoot = new URL('../', import.meta.url);
const config = JSON.parse(
  await readFile(new URL('vercel.json', projectRoot), 'utf8'),
);

test('Vercel compiles Flutter web with the Supabase-safe build wrapper', () => {
  assert.equal(config.buildCommand, 'node tools/build_web.mjs');
  assert.equal(config.outputDirectory, 'build/web');
});

test('Vercel keeps the Flutter app route rewrite', () => {
  assert.equal(
    config.rewrites.some((rule) => rule.destination === '/index.html'),
    true,
  );
});
