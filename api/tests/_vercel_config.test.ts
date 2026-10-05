import assert from 'node:assert/strict';
import { readdir, readFile } from 'node:fs/promises';
import { join, relative } from 'node:path';
import test from 'node:test';

const root = new URL('../../', import.meta.url).pathname;
const apiRoot = join(root, 'api');
const intendedRoutes = new Set([
  'health.ts',
  'auth/google/start.ts',
  'auth/google/callback.ts',
  'auth/google/me.ts',
  'auth/google/logout.ts',
]);

async function sourceFiles(directory: string): Promise<string[]> {
  const entries = await readdir(directory, { withFileTypes: true });
  const nested = await Promise.all(
    entries.map((entry) => {
      const path = join(directory, entry.name);
      return entry.isDirectory() ? sourceFiles(path) : entry.name.endsWith('.ts') ? [path] : [];
    }),
  );
  return nested.flat();
}

test('Vercel only discovers intentional API handlers and rewrites keep /api out of Flutter routing', async () => {
  const config = JSON.parse(await readFile(join(root, 'vercel.json'), 'utf8')) as {
    rewrites: Array<{ source: string; destination: string }>;
  };
  assert.equal(config.rewrites[0].destination, '/index.html');
  assert.match(config.rewrites[0].source, /api\//);

  const routes = (await sourceFiles(apiRoot))
    .map((path) => relative(apiRoot, path).replaceAll('\\', '/'))
    .filter((path) => !path.split('/').at(-1)!.startsWith('_'));
  assert.deepEqual(new Set(routes), intendedRoutes);
});
