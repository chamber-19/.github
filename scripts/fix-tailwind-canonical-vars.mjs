#!/usr/bin/env node

import { readdir, readFile, writeFile } from 'node:fs/promises';
import path from 'node:path';

const SKIP_DIRS = new Set(['node_modules', 'dist', 'build', '.git']);
const VALID_EXTENSIONS = new Set(['.ts', '.tsx', '.js', '.jsx']);

const BG_PATTERN = /\bbg-\[var\(\s*(--[^)\]\s]+)\s*\)\]/g;
const TEXT_PATTERN = /\btext-\[var\(\s*(--[^)\]\s]+)\s*\)\]/g;

const rootDir = path.resolve(process.argv[2] ?? process.cwd());

async function walk(dir, files = []) {
  const entries = await readdir(dir, { withFileTypes: true });

  for (const entry of entries) {
    const fullPath = path.join(dir, entry.name);

    if (entry.isDirectory()) {
      if (!SKIP_DIRS.has(entry.name)) {
        await walk(fullPath, files);
      }
      continue;
    }

    if (entry.isFile() && VALID_EXTENSIONS.has(path.extname(entry.name))) {
      files.push(fullPath);
    }
  }

  return files;
}

async function main() {
  const files = await walk(rootDir);
  let changedFiles = 0;

  for (const filePath of files) {
    const original = await readFile(filePath, 'utf8');
    const updated = original
      .replace(BG_PATTERN, 'bg-($1)')
      .replace(TEXT_PATTERN, 'text-(color:$1)');

    if (updated !== original) {
      await writeFile(filePath, updated, 'utf8');
      changedFiles += 1;
      console.log(`Updated ${path.relative(rootDir, filePath)}`);
    }
  }

  console.log(`Done. Updated ${changedFiles} file(s).`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
